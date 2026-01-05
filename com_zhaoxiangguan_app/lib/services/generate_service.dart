import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'user_service.dart';

class GenerateService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _generatedImageUrl;
  bool _isGenerating = false;
  String? _selectedMainStyle;
  String? _selectedSubStyle;

  File? get selectedImage => _selectedImage;
  String? get generatedImageUrl => _generatedImageUrl;
  bool get isGenerating => _isGenerating;
  String? get selectedMainStyle => _selectedMainStyle;
  String? get selectedSubStyle => _selectedSubStyle;

  Future<bool> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedImage = File(image.path);
        _generatedImageUrl = null;
        _selectedMainStyle = null;
        _selectedSubStyle = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return false;
    }
  }

  void selectStyle(String mainStyle, String subStyle) {
    _selectedMainStyle = mainStyle;
    _selectedSubStyle = subStyle;
    notifyListeners();
  }

  // 生成图片（免费使用）
  Future<Map<String, dynamic>> generateImage(UserService? userService) async {
    if (_selectedImage == null || _selectedMainStyle == null || _selectedSubStyle == null) {
      return {'success': false, 'message': '请先选择图片和风格'};
    }

    // 检查用户是否登录
    if (userService != null && (!userService.isLoggedIn || userService.userId == null)) {
      return {'success': false, 'message': '请先登录'};
    }

    _isGenerating = true;
    notifyListeners();

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await ApiService.post('/api/generate', body: {
        if (userService != null) 'userId': userService!.userId,
        'image': base64Image,
        'style': _selectedMainStyle,
        'substyle': _selectedSubStyle,
      });

      if (response['success'] == true && response['imageUrl'] != null) {
        _generatedImageUrl = response['imageUrl'];

        return {
          'success': true,
          'imageUrl': response['imageUrl'],
        };
      } else {
        _generatedImageUrl = null;
        return {
          'success': false,
          'message': response['message'] ?? '生成失败'
        };
      }
    } catch (e) {
      debugPrint('生成失败: $e');
      _generatedImageUrl = null;
      return {
        'success': false,
        'message': '生成失败: $e'
      };
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _generatedImageUrl = null;
    _selectedMainStyle = null;
    _selectedSubStyle = null;
    _isGenerating = false;
    notifyListeners();
  }
}
