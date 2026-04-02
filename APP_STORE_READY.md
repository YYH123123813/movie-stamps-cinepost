# CinePost 上架准备指南 (App Store Submission Guide)

## 1. 隐私权限设置 (Privacy Config)
为了通过 App Store 审核，您必须在 Xcode 的 `Info.plist` 中声明以下权限，否则应用会一启动就崩溃或被拒审：

**Key**: `Privacy - Photo Library Usage Description` (`NSPhotoLibraryUsageDescription`)  
**Value**: "CinePost 需要访问您的相册，以便您选择照片制作 CinePost 电影邮票。"

**Key**: `Privacy - Camera Usage Description` (如果未来需要拍照)  
**Value**: "CinePost 需要使用相机拍摄海报。"

## 2. 本地化 (Localization)
当前代码硬编码了部分中文字符串。为了更好的上架支持，建议在 Xcode 中：
1. Project Settings -> Info -> Localizations
2. 添加 "Chinese, Simplified (zh-Hans)"
3. 将 Base 设置为中文。

## 3. 功能测试checklist
- [x] **无数据启动**: 此时应显示“空信箱”页面。
- [x] **添加电影**: 测试从相册选择图片，输入中文电影名。
- [x] **日期归档**: 添加不同月份的电影，检查“缩放视图”中的信封是否按月份正确分类。
- [x] **删除数据**: 翻转邮票，点击垃圾桶，确认数据被物理删除（重启后不再出现）。

## 4. 营销素材
- **App Name**: CinePost
- **Subtitle**: 您的光影集邮册 (Your Cinema Stamp Collection)
- **Description**: 如果电影是寄给未来的信，那么 CinePost 就是您的专属邮筒...
