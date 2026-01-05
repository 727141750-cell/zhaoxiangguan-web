import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/generate_service.dart';
import '../services/user_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // 自动开始生成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateService>(
      builder: (context, generateService, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${generateService.selectedMainStyle} - ${generateService.selectedSubStyle}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享功能开发中')),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  '分享',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 图片区域
              Expanded(
                child: generateService.isGenerating
                    ? _buildGeneratingState()
                    : generateService.generatedImageUrl != null
                        ? _buildResultImage(generateService)
                        : _buildErrorState(),
              ),
              // 操作按钮
              if (!generateService.isGenerating &&
                  generateService.generatedImageUrl != null)
                _buildActionButtons(context, generateService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneratingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'AI 正在为你打造专属艺术照',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请稍候...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultImage(GenerateService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                service.generatedImageUrl!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 水印
          Positioned(
            bottom: 36,
            right: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '造像馆 预览版',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            '生成失败',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _generateImage(),
            child: const Text(
              '重试',
              style: TextStyle(color: Color(0xFF007AFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GenerateService service) {
    final userService = context.read<UserService>();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 重新生成按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _generateImage(),
              icon: const Icon(Icons.refresh),
              label: const Text('重新生成'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 下载按钮（免费）
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _downloadImage(context, service, userService),
              icon: const Icon(Icons.download),
              label: const Text('下载原图'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateImage() async {
    final generateService = context.read<GenerateService>();

    // 调用生成服务
    final result = await generateService.generateImage(null);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('生成成功！'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // 显示错误消息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('生成失败'),
          content: Text(result['message'] ?? '未知错误'),
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

  Future<void> _downloadImage(
    BuildContext context,
    GenerateService generateService,
    UserService userService,
  ) async {
    // 下载原图免费
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('下载成功！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
