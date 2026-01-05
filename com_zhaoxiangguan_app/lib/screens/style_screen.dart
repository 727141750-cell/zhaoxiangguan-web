import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/art_style.dart';
import '../services/generate_service.dart';
import '../services/user_service.dart';
import 'result_screen.dart';

class StyleScreen extends StatelessWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateService>(
      builder: (context, generateService, _) {
        return Container(
          color: const Color(0xFFF5F5F7),
          child: SafeArea(
            child: Column(
              children: [
                // 已选照片预览
                if (generateService.selectedImage != null)
                  _buildPhotoPreview(generateService),
                // 标题
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '请为您的照片选择一种风格',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ),
                // 风格列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: ArtStyles.allStyles.length,
                    itemBuilder: (context, index) {
                      final style = ArtStyles.allStyles[index];
                      return _buildStyleCategory(context, style);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPreview(GenerateService service) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          service.selectedImage!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStyleCategory(BuildContext context, ArtStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主风格标题
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '${style.name}风格',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          // 子风格网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: style.subStyles.length,
            itemBuilder: (context, index) {
              final subStyle = style.subStyles[index];
              return _buildSubStyleCard(
                context,
                style.name,
                subStyle,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubStyleCard(
    BuildContext context,
    String mainStyle,
    SubStyle subStyle,
  ) {
    return GestureDetector(
      onTap: () => _selectStyle(context, mainStyle, subStyle),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预览区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF007AFF),
                      const Color(0xFF007AFF).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mainStyle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subStyle.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subStyle.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStyle(
    BuildContext context,
    String mainStyle,
    SubStyle subStyle,
  ) {
    final generateService = context.read<GenerateService>();
    generateService.selectStyle(mainStyle, subStyle.name);

    // 跳转到结果页
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
      ),
    );
  }
}
