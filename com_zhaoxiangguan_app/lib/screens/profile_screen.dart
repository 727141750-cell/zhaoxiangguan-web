import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, _) {
        return Container(
          color: const Color(0xFFF5F5F7),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 用户卡片
                  _buildUserCard(context, userService),
                  const SizedBox(height: 20),
                  // 菜单列表
                  _buildMenuList(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserService userService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userService.isLoggedIn
                      ? (userService.phone ?? '用户')
                      : '未登录',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userService.isLoggedIn ? '已登录 · 免费使用' : '登录后免费使用',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // 登录/退出按钮
          if (!userService.isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('登录'),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showLogoutDialog(context, userService),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.download,
            iconColor: const Color(0xFF4CAF50),
            iconBgColor: const Color(0xFFE8F5E9),
            title: '我的下载',
            subtitle: '查看下载记录',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history,
            iconColor: const Color(0xFF2196F3),
            iconBgColor: const Color(0xFFE3F2FD),
            title: '生成历史',
            subtitle: '查看生成记录',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: const Color(0xFFFF9800),
            iconBgColor: const Color(0xFFFFF3E0),
            title: '关于我们',
            subtitle: '了解更多',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            iconColor: const Color(0xFF9C27B0),
            iconBgColor: const Color(0xFFF3E5F5),
            title: '隐私政策',
            subtitle: '了解我们如何保护您的信息',
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description,
            iconColor: const Color(0xFF607D8B),
            iconBgColor: const Color(0xFFECEFF1),
            title: '用户协议',
            subtitle: '服务条款和使用规则',
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  void _showLogoutDialog(BuildContext context, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              userService.logout();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于造像馆'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本：1.0.0'),
            SizedBox(height: 8),
            Text('造像馆是一款AI智能艺术照生成应用'),
            SizedBox(height: 8),
            Text('支持多种艺术风格'),
            SizedBox(height: 8),
            Text('完全免费使用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
