import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/generate_service.dart';
import '../services/user_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAFAFA), Color(0xFFF0F0F2)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const _Header(),
                const SizedBox(height: 150),
                const _MainButtons(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '造像馆',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI智能艺术照生成',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _MainButtons extends StatelessWidget {
  const _MainButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildButton(
          context,
          icon: Icons.camera_alt,
          label: '拍摄自拍',
          isPrimary: true,
          source: 'camera',
        ),
        const SizedBox(height: 16),
        _buildButton(
          context,
          icon: Icons.photo_library,
          label: '相册上传',
          isPrimary: false,
          source: 'gallery',
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeature('⚡', '秒级生成'),
            const SizedBox(width: 24),
            _buildFeature('🖌️', '6种风格'),
            const SizedBox(width: 24),
            _buildFeature('✨', '高清无水印'),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required String source,
  }) {
    return GestureDetector(
      onTap: () => _pickImage(context, source),
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isPrimary ? Colors.white : const Color(0xFF007AFF),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF007AFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, String source) async {
    debugPrint('=== 开始选择图片: $source ===');

    final userService = context.read<UserService>();

    // 检查是否登录
    if (!userService.isLoggedIn) {
      debugPrint('用户未登录，显示登录对话框');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('需要登录'),
          content: const Text('请先登录后再使用生成功能'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('去登录'),
            ),
          ],
        ),
      );
      return;
    }

    debugPrint('用户已登录，开始选择图片');
    final generateService = context.read<GenerateService>();
    final ImageSource imageSource =
        source == 'camera' ? ImageSource.camera : ImageSource.gallery;

    debugPrint('调用 pickImage, imageSource = $imageSource');
    final picked = await generateService.pickImage(imageSource);
    debugPrint('pickImage 结果: $picked');

    if (picked && context.mounted) {
      debugPrint('图片选择成功，准备跳转到风格选择页');
      // 跳转到风格选择页
      Navigator.pushNamed(context, '/style');
      debugPrint('已调用 Navigator.pushNamed(/style)');
    } else {
      debugPrint('图片选择失败或context已失效');
    }
  }

  Widget _buildFeature(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
