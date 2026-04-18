// entry/src/main/ets/entryability/EntryAbility.ets

import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { StorageUtil } from '../common/utils/StorageUtil';
import { NetworkUtils } from '../common/utils/NetworkUtils';
import { DisplayUtil } from '../common/utils/DisplayUtil';
import audioPlayerService from '../common/utils/AudioPlayerService';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { EventBus } from '../common/utils/EventBus';
import { StorageConstants } from '../common/constants/StorageConstants';
import { WXApi, WXEventHandler } from '../common/utils/WXApiWrap';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private networkUtils: NetworkUtils = NetworkUtils.getInstance(getContext(this));
  private backgroundTaskId: number | undefined = -1;
  private wantAgent: WantAgent | null = null;

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.log('[EntryAbility] onCreate');
    
    // 监听音乐播放事件，自动启动长时任务
    EventBus.listen<string>(StorageConstants.START_BACKGROUND_TASK, () => {
      console.log('[EntryAbility] 收到音乐播放事件，准备启动长时任务');
      this.startBackgroundTask();
    });

    
    // 初始化 WantAgent
    await this.initWantAgent();
    
    // 初始化 AVSession
    try {
      await audioPlayerService.initAVSession(this.context);
      console.log('[EntryAbility] AVSession 初始化成功');
    } catch (error) {
      console.error('[EntryAbility] AVSession 初始化失败:', error);
    }
    this.handleWeChatCallIfNeed(want)
  }

  onDestroy(): void {
    console.log('[EntryAbility] onDestroy');
    // 停止长时任务
    this.stopBackgroundTask();
    // 销毁播放器和 AVSession
    audioPlayerService.destroy();
  }

  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    StorageUtil.initialize(this.context);
    DisplayUtil.init(this.context);
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.handleWeChatCallIfNeed(want)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    // 应用回到前台时，停止长时任务
    this.stopBackgroundTask();
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    // 应用进入后台时，启动长时任务
    this.startBackgroundTask();
  }

  /**
   * 初始化 WantAgent
   */
  private async initWantAgent(): Promise<void> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context.abilityInfo.bundleName,
            abilityName: this.context.abilityInfo.name,
            action: 'action.system.home',
            entities: ['entity.system.home']
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      this.wantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      console.log('[EntryAbility] WantAgent 初始化成功');
    } catch (error) {
      console.error('[EntryAbility] WantAgent 初始化失败:', error);
    }
  }

  /**
   * 启动长时任务
   */
  private async startBackgroundTask(): Promise<void> {
    try {
      // 检查是否已有长时任务在运行
      if (this.backgroundTaskId !== -1) {
        console.log('[EntryAbility] 长时任务已在运行中');
        return;
      }

      // 检查是否有音乐正在播放
      const playState = audioPlayerService.getPlayState();
      if (!playState.isPlaying) {
        console.log('[EntryAbility] 没有音乐播放，无需启动长时任务');
        return;
      }

      // 创建 WantAgent 信息
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context.abilityInfo.bundleName,
            abilityName: this.context.abilityInfo.name,
            action: 'action.system.home',
            entities: ['entity.system.home']
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
        try {
          // 音乐播放长时任务类型
          let list: Array<string> = ["audioPlayback"];
          
          // 启动长时任务
          backgroundTaskManager.startBackgroundRunning(this.context, list, wantAgentObj).then((res: backgroundTaskManager.ContinuousTaskNotification) => {
            console.info("[EntryAbility] 音乐播放长时任务启动成功");
            console.info("[EntryAbility] 长时任务ID:", res.continuousTaskId);
            
            // 保存长时任务ID
            this.backgroundTaskId = res.continuousTaskId;
            
            // 此处执行具体的音乐播放长时任务逻辑
            console.info("[EntryAbility] 音乐播放长时任务已启动，应用将在后台持续播放音乐");
            
          }).catch((error: BusinessError) => {
            console.error(`[EntryAbility] 启动音乐播放长时任务失败. code is ${error.code} message is ${error.message}`);
            this.backgroundTaskId = -1;
          });
        } catch (error) {
          console.error(`[EntryAbility] 启动音乐播放长时任务异常. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
          this.backgroundTaskId = -1;
        }
      }).catch((error: BusinessError) => {
        console.error(`[EntryAbility] 获取WantAgent失败. code is ${error.code} message is ${error.message}`);
        this.backgroundTaskId = -1;
      });
      
    } catch (error) {
      console.error(`[EntryAbility] 启动长时任务失败. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
      this.backgroundTaskId = -1;
    }
  }

  /**
   * 停止长时任务
   */
  private async stopBackgroundTask(): Promise<void> {
    try {
      if (this.backgroundTaskId === -1) {
        console.log('[EntryAbility] 没有运行中的长时任务');
        return;
      }

      // 停止长时任务
      await backgroundTaskManager.stopBackgroundRunning(this.context);
      console.log('[EntryAbility] 音乐播放长时任务已停止, ID:', this.backgroundTaskId);
      
      this.backgroundTaskId = -1;
    } catch (error) {
      console.error('[EntryAbility] 停止长时任务失败:', error);
      this.backgroundTaskId = -1;
    }
  }
}