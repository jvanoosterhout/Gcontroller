# Home Assistant Examples

These example automations assume that [software/HA_automation.yaml](../software/HA_automation.yaml) has been run and that Home Assistant created entities from the MQTT discovery configuration. Replace the entity IDs and notification target with the names used by your installation.

## Doorbell notification

```yaml

alias: g_open_close_roller_door
description: "Open or close the rol-deur with a bthome button"
trigger:
  - platform: device
    device_id: c5c3bcbbff9db90e8a1bbe00dd0cbac2
    domain: bthome
    type: button
    subtype: press
    id: "btn"
  - platform: device
    device_id: 111432bd8076393a1fc09678d8e1cab7
    domain: bthome
    type: button
    subtype: press
    id: "btn"
conditions:
  - condition: trigger
    id:
      - btn
action:
  - service: switch.turn_on
    target:
      entity_id: switch.rol_door_lock
  - delay:
      milliseconds: 250
  - service: cover.toggle
    target:
      entity_id: cover.rol_door
mode: single
```

