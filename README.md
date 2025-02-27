# Web2Wave

Web2Wave is a lightweight Flutter package that provides a simple interface for managing user subscriptions and properties through a REST API.

## Features

- Fetch subscription status for users
- Check for active subscriptions
- Manage user properties
- Set third-parties profiles
- Thread-safe singleton design
- Async/await API support
- Built-in error handling

## Installation

### Pub.dev

Add the following to your `pubspec.yaml` file:

```dart
  web2wave: ^1.0.0
```

or run

```dart
  flutter pub add web2wave
```

## Setup

Before using Web2Wave, you need to configure API key:

```dart
  Web2Wave.shared.initialize(apiKey: 'your-api-key');
```

## Usage

### Checking Subscription Status

```dart
  // Fetch subscriptions
  final subscriptions = await Web2Wave.shared.fetchSubscriptions(web2waveUserId: 'userID');

  // Check if user has an active subscription
  final isActive = await Web2Wave.shared.hasActiveSubscription(web2waveUserId: 'userID');
```

### Managing User Properties

```dart
  // Fetch user properties
  final properties = await Web2Wave.shared.fetchUserProperties(web2waveUserId: 'userID');

  // Update a user property
  final result = await Web2Wave.shared.updateUserProperty(
      web2waveUserId: userID,
      property: 'preferredTheme',
      value: 'dark');

  switch (result.isSuccess) {
    case true:
      print('Property updated successfully');
    case false:
      print('Failed to update property with error - ${result.errorMessage}');
  }
```

### Managing third-party profiles

```dart
  // Save Adapty profileID
  final resultAdapty = await Web2Wave.shared.setAdaptyProfileID(
      web2waveUserId: userID,
      adaptyProfileId: "{adaptyProfileID}");

  switch (resultAdapty.isSuccess) {
    case true:
      print('Adapty profileID saved');
    case false:
      print(
          'Failed to save Adapty profileID with error - ${result.errorMessage}');
  }

  // Save Revenue Cat profileID
  final resultRevcat = await Web2Wave.shared.setRevenuecatProfileID(
      web2waveUserId: userID, revenuecatProfileId: "{revenueCatProfileID}");

  switch (resultRevcat.isSuccess) {
    case true:
      print('RevenueCat profileID saved');
    case false:
      print(
          'Failed to save RevenueCat profileID with error - ${result.errorMessage}');
  }

  // Save Qonversion profileID
  final resultQonversion = await Web2Wave.shared.setQonversionProfileID(
      web2waveUserId: userID,
      qonverionProfileId: "{qonversionProfileID}");

  switch (resultQonversion.isSuccess) {
    case true:
      print('Qonversion profileID saved');
    case false:
      print(
          'Failed to save Qonversion profileID with error - ${result.errorMessage}');
  }
```

## API Reference

### `Web2Wave.shared`

The singleton instance of the Web2Wave client.

### Methods

#### `Future<List<dynamic>?> fetchSubscriptions({required String web2waveUserId})`

Fetches the subscription status for a given user ID.

#### `Future<bool> hasActiveSubscription({required String web2waveUserId})`

Checks if the user has an active subscription (including trial status).

#### `Future<Map<String, String>?> fetchUserProperties({required String web2waveUserId})`

Retrieves all properties associated with a user.

#### `Future<Web2WaveResponse> updateUserProperty({required String web2waveUserId, required String property, required String value})`

Updates a specific property for a user.

#### `Future<Web2WaveResponse> setRevenuecatProfileID({required String web2waveUserId, required String revenuecatProfileId})`

Set Revenuecat profileID

#### `Future<Web2WaveResponse> setAdaptyProfileID({required String web2waveUserId, required String adaptyProfileId})`

Set Adapty profileID

#### `Future<Web2WaveResponse> setQonversionProfileID({required String web2waveUserId, required String qonverionProfileId})`

Set Qonversion ProfileID

## Requirements

- Flutter SDK >= 3.0.0

## License

MIT
