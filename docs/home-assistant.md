# Home Assistant Examples

These examples assume that [software/HA_automation.yaml](../software/HA_automation.yaml) has been run and that Home Assistant created entities from the MQTT discovery configuration. Replace the entity IDs and notification target with the names used by your installation.

## Doorbell notification

```yaml
alias: MK-controller - doorbell notification
description: Notify when the doorbell is pressed.
triggers:
  - trigger: state
    entity_id: binary_sensor.deurbel_detectie
    to: "on"
actions:
  - action: notify.mobile_app_your_phone
    data:
      title: Deurbel
      message: Er is aangebeld.
mode: single
```

## Temporarily silence the doorbell

This turns the doorbell off for two hours and then restores it. Replace the switch entity ID and notification target as needed.

```yaml
alias: MK-controller - temporarily silence doorbell
description: Silence the doorbell for two hours.
triggers:
  - trigger: state
    entity_id: input_boolean.doorbell_silenced
    to: "on"
actions:
  - action: switch.turn_off
    target:
      entity_id: switch.deurbel_aan_uit
  - delay: "02:00:00"
  - action: switch.turn_on
    target:
      entity_id: switch.deurbel_aan_uit
  - action: input_boolean.turn_off
    target:
      entity_id: input_boolean.doorbell_silenced
mode: restart
```

Create the `input_boolean.doorbell_silenced` helper in Home Assistant before using the second automation. Confirm the relay behavior locally before relying on automation for a safety or accessibility requirement.