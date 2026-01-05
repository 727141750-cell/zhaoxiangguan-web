# 使用 Codemagic 构建 APK - 快速指南

## 为什么选择 Codemagic？

GitHub Actions 一直因为 Java/Gradle 兼容性问题失败，Codemagic 是专业的 Flutter CI/CD 服务，可以可靠地构建 APK。

## 步骤 1: 注册 Codemagic

1. 访问 https://codemagic.io/
2. 点击 "Get started" 或 "Sign up"
3. **使用 GitHub 账号登录**（推荐）- 点击 "Sign in with GitHub"
4. 授权 Codemagic 访问你的 GitHub 仓库

## 步骤 2: 添加项目

1. 登录后，点击 "Add a new project" 或 "Add App"
2. 选择 GitHub
3. 找到并选择 `727141750-cell/zhaoxiangguan-web` 仓库
4. 点击 "Select repository" 或 "Add repository"

## 步骤 3: 配置构建

Codemagic 会自动检测到这是一个 Flutter 项目。

### 基本设置：
- **Project type**: Flutter app
- **Flutter workflow**: Standard (Android)
- **Build type**: Release (APK)

### 无需配置：
- ✅ 不需要上传 keystore（可以先构建 debug APK 测试）
- ✅ 不需要配置签名（Codemagic 会使用默认的 debug keystore）

## 步骤 4: 开始构建

1. 点击 "Start new build" 或 "Build now"
2. 等待构建完成（通常 5-10 分钟）
3. 构建成功后，会显示绿色的 ✅

## 步骤 5: 下载 APK

1. 在构建列表中，找到成功的构建
2. 点击构建详情
3. 在 "Artifacts" 或 "构建产物" 部分
4. 下载 `app-release.apk` 文件

## 构建配置文件（可选）

如果你想更精确地控制构建，可以在项目根目录创建 `codemagic.yaml`：

```yaml
workflows:
  default-workflow:
    name: Default Workflow
    environment:
      flutter: stable
    scripts:
      - cd com_zhaoxiangguan_app
      - flutter pub get
      - flutter build apk --release
    artifacts:
      - com_zhaoxiangguan_app/build/app/outputs/flutter-apk/*.apk
```

但通常不需要这个文件，Codemagic 的默认配置就很好。

## 常见问题

### Q: 构建需要多长时间？
A: 第一次构建约 10-15 分钟（需要下载 Flutter SDK），后续构建约 5 分钟。

### Q: 免费版有什么限制？
A: 免费版每月有 100 分钟的构建时间，完全够用。

### Q: 构建失败怎么办？
A: 查看 Codemagic 的构建日志，通常问题会显示在日志中。

## 成功标志

构建成功后，你会看到：
- ✅ Build successful
- 📥 APK 下载链接
- 📱 安装到手机进行测试

---

**准备好了吗？访问 https://codemagic.io/ 开始吧！**

构建完成后，APK 文件会准备好供你下载和测试。
