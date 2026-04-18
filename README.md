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

## 音乐播放器使用说明

### 核心位置

播放器核心是全局单例服务：

- `entry/src/main/ets/common/utils/AudioPlayerService.ets`

相关配套模块：

- `entry/src/main/ets/common/constants/GlobalPlayerStore.ets`
- `entry/src/main/ets/common/utils/AVSessionManager.ets`
- `entry/src/main/ets/common/constants/StorageConstants.ets`

### 当前架构

这个项目的播放器不是页面级实例，而是全局单例。

它负责：

- 创建和管理 `AVPlayer`
- 播放、暂停、恢复、停止、跳转进度
- 上一首、下一首、自动切歌
- 定时停止播放
- 同步全局播放状态
- 通过 `EventBus` 广播状态给页面
- 对接 HarmonyOS `AVSession`，支持锁屏和系统媒体控制

### 初始化方式

播放器相关初始化在应用入口中完成：

- `entry/src/main/ets/entryability/EntryAbility.ets`

主要做了两件事：

- 应用启动时执行 `audioPlayerService.initAVSession(this.context)`
- 应用销毁时执行 `audioPlayerService.destroy()`

因此在页面中一般不需要重复创建播放器实例，直接使用全局单例即可。

### 开始播放

最核心的方法是：

```ts
audioPlayerService.playMusic(music, playIndex)
```

参数说明：

- `music`：整个歌单或播放列表对象，类型为 `Music`
- `playIndex`：播放 `music.musics` 中的第几首，默认 `0`

播放器的数据结构依赖当前项目的模型：

- 歌单级信息在 `Music`
- 单曲信息在 `Play`
- 实际播放列表在 `music.musics`

当前逻辑会优先播放：

1. `local_music_address_2`
2. `music_address_2`

也就是说，若本地已下载，会优先播放本地文件；否则回退到在线地址。

### 常用控制方法

```ts
audioPlayerService.playMusic(music, index)
audioPlayerService.pause()
audioPlayerService.resume()
audioPlayerService.togglePlayPause()
audioPlayerService.stop()
audioPlayerService.seek(positionMs)
audioPlayerService.playNext()
audioPlayerService.playPrevious()
audioPlayerService.getPlayState()
```

其中 `getPlayState()` 返回的信息包括：

- `isPlaying`
- `isPaused`
- `currentTime`
- `duration`
- `currentMusic`
- `currentPlayIndex`
- `playerUri`

### 页面如何获取播放状态

播放器状态主要通过两种方式同步到 UI：

1. `globalPlayerStore`
2. `EventBus`

`globalPlayerStore` 中保存了：

- 当前播放 URI
- 是否正在播放
- 当前歌单信息
- 播放模式
- 当前播放进度
- 总时长

播放器事件定义在 `StorageConstants` 中，常用事件有：

- `PLAYER_STATE_CHANGE`
- `PLAYER_TIME_UPDATE`
- `PLAYER_ERROR`
- `PLAYER_COMPLETED`
- `TIMER_PLAY_START`
- `TIMER_PLAY_STOP`
- `TIMER_PLAY_UPDATE`

页面通常这样接：

```ts
EventBus.listen(StorageConstants.PLAYER_STATE_CHANGE, (state) => {
  // 更新播放按钮、当前歌曲等
});

EventBus.listen(StorageConstants.PLAYER_TIME_UPDATE, (info) => {
  // 更新进度条
});
```

### 播放模式

自动切歌逻辑会读取：

```ts
globalPlayerStore.playMethod
```

当前项目主要支持：

- `single`：单曲循环
- `list`：列表循环

设置方式：

```ts
globalPlayerStore.setPlayMethod('single')
globalPlayerStore.setPlayMethod('list')
```

### 定时停止播放

项目内已有定时停止播放能力，对应弹框：

- `entry/src/main/ets/dialog/RegularTime.ets`

使用方法：

```ts
audioPlayerService.startTimerPlay(minutes)
audioPlayerService.stopTimerPlay()
```

定时状态会通过以下事件广播：

- `TIMER_PLAY_START`
- `TIMER_PLAY_STOP`
- `TIMER_PLAY_UPDATE`

### 系统媒体控制

播放器已接入 HarmonyOS `AVSession`，相关逻辑在：

- `entry/src/main/ets/common/utils/AVSessionManager.ets`

支持的系统控制命令有：

- 播放
- 暂停
- 下一首
- 上一首
- 跳转进度

系统命令会通过 `AVSESSION_COMMAND` 事件回传给 `AudioPlayerService`。

### 后台播放

应用进入后台后，会在 `EntryAbility` 中尝试启动后台长时任务。

前提是：

- 当前播放器确实处于播放状态

相关事件：

- `START_BACKGROUND_TASK`
- `STOP_BACKGROUND_TASK`

### 当前项目中的典型使用方式

1. 页面或弹框拿到一个完整 `Music` 对象
2. 调用 `audioPlayerService.playMusic(music, index)`
3. 页面通过 `EventBus` 或 `globalPlayerStore` 刷新 UI
4. 用户通过按钮调用暂停、恢复、切歌、seek

最小调用示例：

```ts
import audioPlayerService from '../common/utils/AudioPlayerService';

await audioPlayerService.playMusic(musicData, 0);
audioPlayerService.togglePlayPause();
audioPlayerService.playNext();
audioPlayerService.seek(30000);
```

### 需要注意的耦合点

这个播放器当前还没有完全业务解耦，仍然和原项目绑定了几块逻辑：

- `playMusic()` 中有 VIP 校验
- 校验失败时会跳转旧会员页 `pages/member/member`
- `globalPlayerStore.setPlayListInfo()` 中会顺带刷新用户信息
- 部分组件和弹框仍保留原业务跳转方式

如果后续要把播放器单独复用到新项目，建议优先做这几步：

1. 去掉 `playMusic()` 中的会员页跳转
2. 去掉 `globalPlayerStore` 中和用户资料接口绑定的逻辑
3. 把播放器输入模型改成更通用的播放列表结构
