#!/usr/bin/env bash
set -euo pipefail

service_name="mk_controller"
service_user="${SUDO_USER:-${USER}}"
install_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
broker=""
port="1883"
username=""
password=""
location="meterkast"
rate="300"

usage() {
	cat <<EOF
Usage: sudo $0 --broker HOST [options]

Options:
  --service-name NAME  systemd service name (default: ${service_name})
  --install-dir PATH   repository directory (default: ${install_dir})
  --broker HOST       MQTT broker hostname or IP address (required)
  --port PORT         MQTT port (default: ${port})
  --username USER     MQTT username
  --password PASS     MQTT password
  --location NAME     HMD-DGB location (default: ${location})
  --rate SECONDS      HMD-DGB update rate (default: ${rate})
  --help              Show this help
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--service-name) service_name="$2"; shift 2 ;;
		--install-dir) install_dir="$2"; shift 2 ;;
		--broker) broker="$2"; shift 2 ;;
		--port) port="$2"; shift 2 ;;
		--username) username="$2"; shift 2 ;;
		--password) password="$2"; shift 2 ;;
		--location) location="$2"; shift 2 ;;
		--rate) rate="$2"; shift 2 ;;
		--help) usage; exit 0 ;;
		*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
	esac
done

[[ "$service_name" =~ ^[A-Za-z0-9_.@-]+$ ]] || { echo "Invalid service name: $service_name" >&2; exit 2; }
install_dir="$(cd -- "$install_dir" && pwd)"
env_file="/etc/${service_name}.env"
[[ -n "$broker" ]] || { echo "MQTT broker is required." >&2; usage; exit 2; }

sudo apt-get update
sudo apt-get install -y gcc python3-dev build-essential python3-venv

python3 -m venv "$install_dir/venv"
"$install_dir/venv/bin/python" -m pip install --upgrade pip
"$install_dir/venv/bin/pip" install git+https://github.com/jvanoosterhout/HMD-DGB.git@v1.0.0b4

sudo install -m 600 /dev/null "$env_file"
sudo tee "$env_file" >/dev/null <<EOF
MQTT_BROKER=$(printf '%q' "$broker")
MQTT_PORT=$(printf '%q' "$port")
MQTT_USERNAME=$(printf '%q' "$username")
MQTT_PASSWORD=$(printf '%q' "$password")
DGB_LOCATION=$(printf '%q' "$location")
DGB_RATE=$(printf '%q' "$rate")
EOF

sudo tee "/etc/systemd/system/${service_name}.service" >/dev/null <<EOF
[Unit]
Description=HMD-DGB service for the MKcontroller
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${service_user}
WorkingDirectory=${install_dir}
EnvironmentFile=${env_file}
ExecStart=${install_dir}/venv/bin/python3 -m DGB.DGBservice --name "MK-controller" --broker "\${MQTT_BROKER}" --port "\${MQTT_PORT}" --username "\${MQTT_USERNAME}" --password "\${MQTT_PASSWORD}" --location "\${DGB_LOCATION}" --rate "\${DGB_RATE}"
Restart=always
RestartSec=15s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now "$service_name.service"
sudo systemctl --no-pager --full status "$service_name.service"