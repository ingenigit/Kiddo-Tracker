# TODO: Implement Notification Badge Counter

- [x] Add `_notificationCount` state variable initialized to 0 in `_MainScreenState`
- [x] Add `incrementNotificationCount()` method to increment the count
- [x] Update the badge `Text` widget to display `_notificationCount.toString()`
- [x] Modify `IconButton` `onPressed` to reset `_notificationCount` to 0 before navigating
- [ ] Add callback to HomeScreen to notify MainScreen of new MQTT messages
- [ ] Call incrementNotificationCount in HomeScreen's _onMQTTMessageReceived
