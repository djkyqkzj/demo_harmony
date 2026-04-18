# demo_harmony

## 项目说明

这是一个基于 HarmonyOS ArkTS 的精简版项目底座。

当前工程已经从原业务项目中裁剪出可复用主框架，目标是作为新项目的起始模板使用，而不是继续承载原有业务功能。

## 当前保留内容

- 启动链路
  - `SplashPage`
  - `GuidePage`
  - `LoginPage`
- 主框架
  - `MainPage`
  - `tab/home`
  - `tab/library`
  - `tab/search`
- 通用页面
  - `WebViewPage`
- 通用能力
  - `common/` 公共常量、工具、网络层
  - `components/` 通用组件
  - `dialog/` 弹框与模态框
  - `resources/` 资源文件


## 当前页面注册

当前 `entry/src/main/resources/base/profile/main_pages.json` 仅保留以下页面：

- `pages/SplashPage`
- `pages/WebViewPage`
- `pages/GuidePage`
- `pages/login/LoginPage`
- `pages/tab/MainPage`
- `pages/tab/home`
- `pages/tab/library`
- `pages/tab/search`

## 目录结构

```text
entry/src/main/ets/
├── common/               # 公共常量、网络层、工具方法
├── components/           # 可复用组件
├── dialog/               # 弹框、抽屉、模态框
├── entryability/         # 应用入口能力
├── entrybackupability/   # 备份能力
└── pages/
    ├── SplashPage.ets
    ├── GuidePage.ets
    ├── WebViewPage.ets
    ├── login/
    │   └── LoginPage.ets
    └── tab/
        ├── MainPage.ets
        ├── home.ets
        ├── library.ets
        └── search.ets
```

## 当前状态说明

`tab/home`、`tab/library`、`tab/search` 已改成模板页，主要用于保留原项目的页面层级、Tab 结构和基础视觉节奏，方便直接替换为新业务内容。

也就是说，现在这三个页面更像是“占位框架”，不是可直接上线的正式业务页面。

## 接手这个项目后建议先做的事

1. 替换 `tab/home`、`tab/library`、`tab/search` 中的占位文案和占位布局。
2. 根据新项目需求重新定义底部 Tab。
3. 检查 `components/` 和 `dialog/` 中是否还包含原项目业务跳转逻辑。
4. 清理未使用的图片资源和旧业务文案。
5. 如果不需要原登录流程，可继续简化 `LoginPage`、网络层与埋点逻辑。

## 需要注意

- 当前保留了组件和弹框文件，但其中部分代码可能仍然包含原项目的旧业务跳转或旧字段命名。
- `common/http/` 和部分 `utils/` 仍带有原项目接口层设计，如果新项目不用这些接口，建议继续裁剪。
- 由于本地环境缺少部分 HarmonyOS 构建插件，当前未完成完整编译验证；如果要正式作为新项目基座使用，建议先在 DevEco Studio 中重新同步依赖并跑一次构建。

## 适合的用途

这个工程目前适合作为以下用途：

- HarmonyOS 新项目 UI 骨架
- ArkTS 页面结构模板
- 带启动页、引导页、登录页、Tab 框架的空白底座

如果后续继续清理，建议下一步优先处理：

- `components/` 中仍绑定旧详情页跳转的组件
- `dialog/` 中仍绑定旧业务页面的抽屉或弹框
- `resources/base/media/` 中未使用的旧资源文件
