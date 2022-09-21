import 'dart:async';
import 'dart:convert' show json, jsonEncode;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

abstract class IFCMNotificationService {
  Future<void> sendNotificationToUser({
    required String fcmToken,
    required String title,
    required String body,
  });
  Future<void> sendNotificationToGroup({
    required String group,
    required String title,
    required String body,
  });
  Future<void> unsubscribeFromTopic({
    required String topic,
  });
  Future<void> subscribeToTopic({
    required String topic,
  });
}

class FCMNotificationService extends IFCMNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _endpoint = 'https://api.rnfirebase.io/messaging/send';
  final String _contentType = 'aapplication/json; charset=UTF-8';
  final String _authorization =serverToken;
  int _messageCount = 0;
  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<http.Response?> _sendNotification(
      String to,
      String title,
      String body,
      ) async {
print("token = ${to}");
    if (to == null) {
      print('Unable to send FCM message, no token exists.');
      return null;
    }

    try {
      http.Response response = await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(to),
      );
      print('FCM request for device sent!');
      print('response ::');
print(response.statusCode);
print(response.body);
print(response.headers);
print(response.contentLength);

      return response;
    } catch (e) {
      print(e);
    }

  }

  @override
  Future<void> unsubscribeFromTopic({required String topic}) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<void> subscribeToTopic({required String topic}) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }


  @override
  Future<void> sendNotificationToUser({
    required String fcmToken,
    required String title,
    required String body,
  }) {
    return _sendNotification(
      fcmToken,
      title,
      body,
    );
  }

  @override
  Future<void> sendNotificationToGroup(
      {required String group, required String title, required String body}) {
    return _sendNotification('/topics/' + group, title, body);
  }
}