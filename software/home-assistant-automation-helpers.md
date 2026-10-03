# Home Assistant Examples

These example automations assume that [software/HA_automation.yaml](../software/HA_automation.yaml) has been run and that Home Assistant created entities from the MQTT discovery configuration. Replace the entity IDs and notification target with the names used by your installation.

## Open or close the roller door

```yaml
alias: Garage rol-deur openen/sluiten
description: ''
triggers:
  - device_id: c5c3bcbbff9db90e8a1bbe00dd0cbac2
    domain: bthome
    type: button
    subtype: press
    id: Garagedeur knop 1
    trigger: device
  - device_id: 111432bd8076393a1fc09678d8e1cab7
    domain: bthome
    type: button
    subtype: press
    id: Garagedeur knop 2
    trigger: device
conditions: []
actions:
  - if:
      - condition: or
        conditions:
          - condition: trigger
            id: Garagedeur knop 1
          - condition: trigger
            id: Garagedeur knop 2
    then:
      - target:
          entity_id: input_text.g_roldeur_pw
        data:
          value: ok
        action: input_text.set_value
      - action: switch.turn_on
        metadata: {}
        target:
          entity_id: switch.rol_deur_rol_deur_actief
        data: {}
  - target:
      entity_id: cover.rol_deur
    action: cover.toggle
  - target:
      device_id: 6fff33d7c2170f33c379d41bf82eccd1
    action: cover.toggle
    data: {}
  - target:
      entity_id: input_text.g_roldeur_pw
    data:
      value: ''
    action: input_text.set_value
mode: single
```

## Notify open door

```yaml
alias: Garage deur alarm
description: ''
triggers:
  - entity_id:
      - binary_sensor.rol_deur_rol_deur_is_dicht
    to:
      - 'off'
    for:
      minutes: 10
    trigger: state
conditions: []
actions:
  - if:
      - condition: state
        entity_id: binary_sensor.rol_deur_rol_deur_is_dicht
        state:
          - 'off'
    then:
      - repeat:
          sequence:
            - data:
                title: Garagedeur Alarm
                message: Deur staat +10 minuten open
                data:
                  push:
                    sound:
                      name: default
                      critical: 1
                      volume: 0.5
              action: notify.mobile_app_iphone_jeroen
            - delay:
                hours: 0
                minutes: 10
                seconds: 0
                milliseconds: 0
          while:
            - condition: state
              entity_id: binary_sensor.rol_deur_rol_deur_is_dicht
              state:
                - 'off'
mode: single

```