import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService extends ChangeNotifier {
  String? _phone;
  String? _userId;
  String? _nickname;
  int _points = 0;
  bool _isLoggedIn = false;
  String? _token;

  String? get phone => _phone;
  String? get userId => _userId;
  String? get nickname => _nickname;
  int get points => _points;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  UserService() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('phone');
    _userId = prefs.getString('userId');
    _nickname = prefs.getString('nickname');
    _points = prefs.getInt('points') ?? 0;
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _token = prefs.getString('token');
    notifyListeners();
  }

  // 登录/注册（新用户自动注册并赠送100积分）
  Future<bool> login(String phone, {String? nickname}) async {
    try {
      debugPrint('开始登录: phone=$phone');

      final response = await ApiService.post('/api/login', body: {
        'phone': phone,
        'password': '123456', // 免费版，任意密码都可以
        if (nickname != null) 'nickname': nickname,
      });

      debugPrint('登录响应: $response');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _phone = phone;
        _userId = data['userId']?.toString() ?? data['id']?.toString();
        _points = data['points'] ?? 999999;
        _nickname = data['nickname'];
        _isLoggedIn = true;
        await _saveUserData();
        notifyListeners();

        debugPrint('登录成功！用户ID: $_userId, 积分: $_points');

        return true;
      } else {
        debugPrint('登录失败: response success = ${response['success']}');
        return false;
      }
    } catch (e) {
      debugPrint('登录异常: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _phone = null;
    _userId = null;
    _nickname = null;
    _points = 0;
    _isLoggedIn = false;
    _token = null;
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_phone != null) await prefs.setString('phone', _phone!);
    if (_userId != null) await prefs.setString('userId', _userId!);
    if (_nickname != null) await prefs.setString('nickname', _nickname!);
    await prefs.setInt('points', _points);
    await prefs.setBool('isLoggedIn', _isLoggedIn);
    if (_token != null) await prefs.setString('token', _token!);
  }

  // 扣除积分（生成照片时调用）
  Future<bool> deductPoints(int amount) async {
    if (_points < amount) return false;
    _points -= amount;
    await _saveUserData();
    notifyListeners();
    return true;
  }

  // 增加积分（充值成功后调用）
  Future<void> addPoints(int amount) async {
    _points += amount;
    await _saveUserData();
    notifyListeners();
  }

  // 从服务器刷新用户信息
  Future<void> refreshUserInfo() async {
    if (_userId == null) return;

    try {
      final response = await ApiService.get('/api/user/$_userId');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _points = data['points'] ?? _points;
        _nickname = data['nickname'] ?? _nickname;
        await _saveUserData();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('刷新用户信息失败: $e');
    }
  }
}
