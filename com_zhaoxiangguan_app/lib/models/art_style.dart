class ArtStyle {
  final String name;
  final String category;
  final List<SubStyle> subStyles;

  ArtStyle({
    required this.name,
    required this.category,
    required this.subStyles,
  });
}

class SubStyle {
  final String name;
  final String description;

  SubStyle({
    required this.name,
    required this.description,
  });
}

class ArtStyles {
  static List<ArtStyle> allStyles = [
    ArtStyle(
      name: '写真',
      category: 'portrait',
      subStyles: [
        SubStyle(name: '日系清新', description: '自然柔和'),
        SubStyle(name: '欧美时尚', description: '高级感'),
        SubStyle(name: '性感风', description: '魅力四射'),
        SubStyle(name: '学院风', description: '青春活力'),
        SubStyle(name: '甜美风', description: '可爱甜美'),
      ],
    ),
    ArtStyle(
      name: '艺术',
      category: 'artistic',
      subStyles: [
        SubStyle(name: '时尚杂志', description: '杂志封面'),
        SubStyle(name: '情节艺术', description: '故事感'),
        SubStyle(name: '抽象艺术', description: '艺术创意'),
        SubStyle(name: '油画风', description: '油画质感'),
      ],
    ),
    ArtStyle(
      name: '古风',
      category: 'ancient',
      subStyles: [
        SubStyle(name: '唐朝', description: '盛世大唐'),
        SubStyle(name: '宋朝', description: '雅致宋代'),
        SubStyle(name: '明朝', description: '华美明朝'),
        SubStyle(name: '魏晋', description: '风骨魏晋'),
        SubStyle(name: '汉服', description: '传统汉服'),
      ],
    ),
    ArtStyle(
      name: '复古',
      category: 'vintage',
      subStyles: [
        SubStyle(name: '港风', description: '香港80年代'),
        SubStyle(name: '民国', description: '上海滩'),
        SubStyle(name: '胶片', description: '胶片质感'),
        SubStyle(name: '黑白复古', description: '经典黑白'),
      ],
    ),
    ArtStyle(
      name: '婚纱',
      category: 'wedding',
      subStyles: [
        SubStyle(name: '室内主纱', description: '室内婚纱'),
        SubStyle(name: '清新森系', description: '森林婚纱'),
        SubStyle(name: '中式', description: '传统婚礼'),
        SubStyle(name: '浪漫夜景', description: '夜景婚纱'),
        SubStyle(name: '海边漫步', description: '海边婚纱'),
      ],
    ),
    ArtStyle(
      name: '证件',
      category: 'idphoto',
      subStyles: [
        SubStyle(name: '一寸', description: '标准一寸'),
        SubStyle(name: '二寸', description: '标准二寸'),
        SubStyle(name: '小二寸', description: '护照照片'),
        SubStyle(name: '五寸', description: '大五寸'),
      ],
    ),
  ];
}