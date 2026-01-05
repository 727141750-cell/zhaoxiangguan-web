import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
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
              _buildSectionTitle('用户服务协议'),
              const SizedBox(height: 8),
              _buildText('更新日期：2025年1月'),
              const SizedBox(height: 20),
              _buildSectionTitle('1. 协议的接受'),
              _buildText('欢迎使用造像馆AI艺术照生成应用！'),
              _buildText('在使用本应用前，请仔细阅读本协议。'),
              _buildText('使用本应用即表示您同意本协议的所有条款。'),
              _buildText('如果您不同意本协议的任何部分，请停止使用本应用。'),
              const SizedBox(height: 20),
              _buildSectionTitle('2. 服务说明'),
              _buildText('造像馆是一款AI艺术照生成应用，提供以下服务：'),
              _buildBullet('• AI智能风格转换（6种主风格、多种子风格）'),
              _buildBullet('• 用户账户管理'),
              _buildBullet('• 积分充值系统'),
              _buildBullet('• 图片保存和分享'),
              _buildText('我们保留随时修改、暂停或终止服务的权利。'),
              const SizedBox(height: 20),
              _buildSectionTitle('3. 用户账户'),
              _buildText('3.1 注册要求'),
              _buildBullet('• 您必须年满18周岁，或在监护人的同意下使用'),
              _buildBullet('• 提供真实、准确、完整的注册信息'),
              _buildBullet('• 保管好您的账户和密码'),
              _buildBullet('• 对您账户下的所有活动负责'),
              const SizedBox(height: 12),
              _buildText('3.2 账户安全'),
              _buildBullet('• 如发现账户被盗用，请立即通知我们'),
              _buildBullet('• 您对账户的未经授权使用承担责任'),
              const SizedBox(height: 20),
              _buildSectionTitle('4. 积分系统'),
              _buildText('4.1 积分获取'),
              _buildBullet('• 注册奖励：新用户注册赠送100积分'),
              _buildBullet('• 充值购买：通过应用内购买获取积分'),
              _buildBullet('• 活动赠送：参与推广活动获取积分'),
              const SizedBox(height: 12),
              _buildText('4.2 积分使用'),
              _buildBullet('• 每次生成图片消耗20积分'),
              _buildBullet('• 积分一旦消耗，不予退还'),
              _buildBullet('• 积分有效期为自获取之日起12个月'),
              const SizedBox(height: 12),
              _buildText('4.3 退款政策'),
              _buildBullet('• 未使用的积分可申请退款'),
              _buildBullet('• 已充值但未使用的积分，按90%退款'),
              _buildBullet('• 退款将在7个工作日内处理'),
              const SizedBox(height: 20),
              _buildSectionTitle('5. 用户行为规范'),
              _buildText('使用本应用时，您同意：'),
              _buildBullet('• 不上传违法违规、色情暴力、侵犯他人权益的内容'),
              _buildBullet('• 不利用本应用进行任何非法活动'),
              _buildBullet('• 不干扰或破坏应用的正常运行'),
              _buildBullet('• 不上传他人的照片，除非获得明确授权'),
              _buildBullet('• 尊重他人的肖像权和隐私权'),
              const SizedBox(height: 12),
              _buildText('违反上述规定的用户，我们有权：'),
              _buildBullet('• 警告或限制账户功能'),
              _buildBullet('• 暂停或终止账户'),
              _buildBullet('• 删除违规内容'),
              _buildBullet('• 保留追究法律责任的权利'),
              const SizedBox(height: 20),
              _buildSectionTitle('6. 知识产权'),
              _buildText('6.1 应用内容'),
              _buildBullet('• 应用界面、设计、代码等归我们所有'),
              _buildBullet('• 受版权法、商标法等法律保护'),
              const SizedBox(height: 12),
              _buildText('6.2 生成内容'),
              _buildBullet('• 您保留原始照片的所有权'),
              _buildBullet('• AI生成的艺术照，您拥有使用权'),
              _buildBullet('• 可用于个人和商业用途'),
              _buildBullet('• 我们有权在营销中使用匿名样例'),
              const SizedBox(height: 20),
              _buildSectionTitle('7. 免责声明'),
              _buildText('7.1 服务质量'),
              _buildBullet('• 本应用按"现状"提供服务'),
              _buildBullet('• 我们不保证服务不间断或无错误'),
              _buildBullet('• 因网络、设备等原因可能导致服务中断'),
              const SizedBox(height: 12),
              _buildText('7.2 AI生成结果'),
              _buildBullet('• AI生成结果可能不完全符合预期'),
              _buildBullet('• 我们不对生成效果做出绝对保证'),
              _buildBullet('• 用户对生成结果有最终决定权'),
              const SizedBox(height: 12),
              _buildText('7.3 责任限制'),
              _buildBullet('• 在法律允许的最大范围内，我们不对间接损失承担责任'),
              _buildBullet('• 包括但不限于利润损失、数据损失等'),
              const SizedBox(height: 20),
              _buildSectionTitle('8. 协议变更'),
              _buildText('我们保留随时修改本协议的权利。'),
              _buildText('修改后的协议将在应用内发布。'),
              _buildText('继续使用应用即表示您接受修改后的协议。'),
              _buildText('建议您定期查看本协议的最新版本。'),
              const SizedBox(height: 20),
              _buildSectionTitle('9. 争议解决'),
              _buildText('9.1 协商优先'),
              _buildBullet('• 如发生争议，双方应首先友好协商解决'),
              const SizedBox(height: 12),
              _buildText('9.2 管辖法律'),
              _buildBullet('• 本协议受中华人民共和国法律管辖'),
              _buildBullet('• 争议由被告所在地人民法院管辖'),
              const SizedBox(height: 12),
              _buildText('9.3 可分割性'),
              _buildBullet('• 如某条款被认定无效，不影响其他条款的效力'),
              const SizedBox(height: 20),
              _buildSectionTitle('10. 其他条款'),
              _buildText('10.1 完整协议'),
              _buildBullet('• 本协议构成您与我们之间的完整协议'),
              _buildBullet('• 取代之前的所有口头或书面协议'),
              const SizedBox(height: 12),
              _buildText('10.2 转让'),
              _buildBullet('• 您不得转让本协议项下的权利义务'),
              _buildBullet('• 我们可以转让本协议给关联公司'),
              const SizedBox(height: 12),
              _buildText('10.3 弃权'),
              _buildBullet('• 我们未行使权利不视为放弃该权利'),
              const SizedBox(height: 20),
              _buildSectionTitle('11. 联系我们'),
              _buildText('如有任何疑问或需要帮助，请联系：'),
              const SizedBox(height: 12),
              _buildContactItem('客服邮箱', 'support@zhaoxiangguan.com'),
              _buildContactItem('客服热线', '400-123-4567'),
              _buildContactItem('工作时间', '周一至周五 9:00-18:00'),
              const SizedBox(height: 30),
              _buildNoticeBox('感谢您选择造像馆！'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBox(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
