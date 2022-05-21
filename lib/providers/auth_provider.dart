import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  var log = Logger();
  late String _token;
  DateTime? _expiryDate;
  late String _userId;
  Timer? _authTimer;
  late String _email;

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != '') {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  String get email {
    return _email;
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://10.0.2.2:3001/api/v1/users/login');
    final headers = {"Content-type": "application/json"};
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['token'];
      _userId = responseData['data']['user']['_id'];
      _email = responseData['data']['user']['email'];
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 6000000),
      );

      log.i(responseData);
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
      log.i(prefs.getString('userData')!);
    } catch (error) {
      throw HttpException('Login Error is $error');
    }
  }

  Future<void> signup(
      String email, String password, String passwordConfirm) async {
    final url = Uri.parse('http://10.0.2.2:3001/api/v1/users/signup');
    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm
        },
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['token'];
      _userId = responseData['data']['user']['_id'];
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 600000),
      );

      log.i(responseData);
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw HttpException('Signup Error is $error');
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
