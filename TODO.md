# TODO List for MQTT Child Status Update

## Completed Tasks
- [x] Analyze MQTTService and onMessageReceived callback
- [x] Understand ChildCardWidget status display mechanism
- [x] Parse MQTT message JSON format
- [x] Update _onMQTTMessageReceived in HomeScreen to parse message and update child status
- [x] Implement status update logic based on msgtype and status from MQTT message
- [x] Add error handling for JSON parsing
- [x] Add logging for status updates and errors

## Pending Tasks
- [x] Test the MQTT message parsing and status update functionality
- [x] Verify UI updates correctly when status changes
- [x] Handle edge cases (invalid JSON, missing fields, etc.)
- [x] Consider adding visual feedback for status changes (animations, colors)

## Notes
- [x] MQTT message format: {"appid":"kiddotrac_transporter","devid":"OR76295500004_44","timestamp":1756899566803,"data":{"msgtype":2,"location":"20.2657871,85.7839107","studentid":"OD92934517","status":1}}
- [x] Status values: 2 = Onboard, 3 = Offboard (based on ChildCardWidget _statusText method)
- [x] Child status is updated in HomeScreen state, which triggers ChildCardWidget rebuild
## Another message
- [x] {"appid":"kiddotrac_transporter","devid":"OR76295500004_44","timestamp":1756899389532,"data":{"msgtype":3,"location":"20.2657871,85.7839107","offlist":["OD92934517"]}}
## Another message for bus active
- [] {"appid":"kiddotrac_transporter","devid":"OR76295500004_44","timestamp":1756975797420,"data":{"msgtype":1}}
## Another message for bus inactive
- [] {"appid":"kiddotrac_transporter","devid":"OR76295500004_44","timestamp":1756807323083,"data":{"msgtype":4}}
