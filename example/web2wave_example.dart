import 'package:web2wave/web2wave.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv()..load();
  String apiKey = env['API_KEY'] ?? 'default_value';
  String userID = env['USER_ID'] ?? 'default_value';
  print('API Key: $apiKey \nUserID: $userID');

  Web2Wave.shared.initialize(apiKey: apiKey);

  final subscriptions =
      await Web2Wave.shared.fetchSubscriptions(web2waveUserId: userID);
  print('subscriptions: $subscriptions');

  final isActive =
      await Web2Wave.shared.hasActiveSubscription(web2waveUserId: userID);
  print('isActive: $isActive');

  final properties =
      await Web2Wave.shared.fetchUserProperties(web2waveUserId: userID);
  print('User properties: ($properties)');

  final result = await Web2Wave.shared.updateUserProperty(
      web2waveUserId: userID, property: 'preferredTheme', value: 'dark');
  switch (result.isSuccess) {
    case true:
      print('Property updated successfully');
    case false:
      print('Failed to update property with error - ${result.errorMessage}');
  }

  final resultAdapty = await Web2Wave.shared.setAdaptyProfileID(
      web2waveUserId: userID, adaptyProfileId: "{adaptyProfileID}");
  switch (resultAdapty.isSuccess) {
    case true:
      print('Adapty profileID saved');
    case false:
      print(
          'Failed to save Adapty profileID with error - ${result.errorMessage}');
  }

  final resultRevcat = await Web2Wave.shared.setRevenuecatProfileID(
      web2waveUserId: userID, revenuecatProfileId: "{revenueCatProfileID}");
  switch (resultRevcat.isSuccess) {
    case true:
      print('RevenueCat profileID saved');
    case false:
      print(
          'Failed to save RevenueCat profileID with error - ${result.errorMessage}');
  }

  final resultQonversion = await Web2Wave.shared.setQonversionProfileID(
      web2waveUserId: userID, qonverionProfileId: "{qonversionProfileID}");
  switch (resultQonversion.isSuccess) {
    case true:
      print('Qonversion profileID saved');
    case false:
      print(
          'Failed to save Qonversion profileID with error - ${result.errorMessage}');
  }

  final resultCancelSubscription = await Web2Wave.shared.cancelSubscription(
      paySystemId: 'sub_1PzNJzCsRq5tBi2bbfNsAf86', comment: 'no money');
  switch (resultCancelSubscription.isSuccess) {
    case true:
      print('Subscription canceled');
    case false:
      print(
          'Failed to cancel subscription with error - ${resultCancelSubscription.errorMessage}');
  }

  final resultRefundSubscription = await Web2Wave.shared.refundSubscription(
      paySystemId: 'sub_1PzNJzCsRq5tBi2bbfNsAf86',
      invoiceId: 'someUUID',
      comment: 'no money');
  switch (resultRefundSubscription.isSuccess) {
    case true:
      print('Subscription redunded');
    case false:
      print(
          'Failed to refund subscription with error - ${resultRefundSubscription.errorMessage}');
  }
}
