import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF5F5F7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('隐私政策'),
              const SizedBox(height: 8),
              _buildText('更新日期：2025年1月'),
              const SizedBox(height: 20),
              _buildSectionTitle('1. 信息收集'),
              _buildText('我们收集以下类型的信息：'),
              _buildBullet('• 账户信息：注册时提供的用户名、手机号、邮箱'),
              _buildBullet('• 图片信息：您上传的照片（用于生成艺术照）'),
              _buildBullet('• 设备信息：设备型号、操作系统版本'),
              _buildBullet('• 使用数据：应用使用情况、生成记录'),
              const SizedBox(height: 20),
              _buildSectionTitle('2. 信息使用'),
              _buildText('我们使用收集的信息用于：'),
              _buildBullet('• 提供AI艺术照生成服务'),
              _buildBullet('• 改善应用功能和用户体验'),
              _buildBullet('• 处理支付和积分管理'),
              _buildBullet('• 发送服务相关通知'),
              const SizedBox(height: 20),
              _buildSectionTitle('3. 信息共享'),
              _buildText('我们不会向第三方出售您的个人信息。'),
              _buildText('仅在以下情况下共享信息：'),
              _buildBullet('• 获得您的明确同意'),
              _buildBullet('• 法律法规要求'),
              _buildBullet('• 保护我们的合法权益'),
              const SizedBox(height: 20),
              _buildSectionTitle('4. 数据安全'),
              _buildText('我们采取安全措施保护您的信息：'),
              _buildBullet('• SSL加密传输'),
              _buildBullet('• 数据加密存储'),
              _buildBullet('• 定期安全审计'),
              _buildBullet('• 严格的访问控制'),
              const SizedBox(height: 20),
              _buildSectionTitle('5. 用户权利'),
              _buildText('您有权：'),
              _buildBullet('• 访问您的个人信息'),
              _buildBullet('• 更正不准确的信息'),
              _buildBullet('• 删除您的账户和信息'),
              _buildBullet('• 撤销授权'),
              _buildBullet('• 导出您的数据'),
              const SizedBox(height: 20),
              _buildSectionTitle('6. Cookie使用'),
              _buildText('我们使用Cookie和类似技术来：'),
              _buildBullet('• 记住您的登录状态'),
              _buildBullet('• 分析应用使用情况'),
              _buildBullet('• 个性化服务体验'),
              const SizedBox(height: 20),
              _buildSectionTitle('7. 未成年人保护'),
              _buildText('我们特别重视未成年人的个人信息保护。'),
              _buildText('如果您是未成年人，请在监护人的陪同下使用本应用。'),
              const SizedBox(height: 20),
              _buildSectionTitle('8. 政策更新'),
              _buildText('我们可能会不时更新本隐私政策。'),
              _buildText('更新后的政策将在应用内发布，并标注更新日期。'),
              _buildText('继续使用应用即表示您接受更新后的政策。'),
              const SizedBox(height: 20),
              _buildSectionTitle('9. 联系我们'),
              _buildText('如您对本隐私政策有任何疑问，请通过以下方式联系我们：'),
              const SizedBox(height: 8),
              _buildContactItem('邮箱', 'support@zhaoxiangguan.com'),
              _buildContactItem('客服热线', '400-123-4567'),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  '造像馆 · AI艺术照生成',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }
}
