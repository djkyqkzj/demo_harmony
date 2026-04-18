import display from '@ohos.display';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

export class DisplayUtil {
  private static statusBarHeight: number = 40;
  private static screenHeight: number = 0;
  private static screenWidth: number = 0;
  private static windowHeight: number = 0;
  private static initialized: boolean = false;

  /**
   * 初始化显示工具类
   * @param context 可选上下文对象
   */
  static async init(context?: common.UIAbilityContext) {
    if (DisplayUtil.initialized) return;

    try {
      // 获取默认显示信息
      const displayArea = await display.getDefaultDisplaySync();

      // 设置屏幕尺寸
      DisplayUtil.screenHeight = px2vp(displayArea.height);
      DisplayUtil.screenWidth = px2vp(displayArea.width);

      if (context) {
        const windowClass = await window.getLastWindow(context);
        const windowRect = await windowClass.getProperties();
        const avoidArea = await windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);

        DisplayUtil.windowHeight = px2vp(windowRect.windowRect.height);
        DisplayUtil.statusBarHeight = px2vp(avoidArea.topRect.height);
      }

      DisplayUtil.initialized = true;
    } catch (err) {
      console.error('Failed to init display utils:', err);
      // 使用默认值继续运行
    }
  }

  // 获取状态栏高度(px)
  static getStatusBarHeight(): number {
    return DisplayUtil.statusBarHeight;
  }

  // 获取屏幕高度(px)
  static getScreenHeight(): number {
    return DisplayUtil.screenHeight;
  }

  // 获取屏幕宽度(px)
  static getScreenWidth(): number {
    return DisplayUtil.screenWidth;
  }

  // 获取窗口高度(px)
  static getWindowHeight(): number {
    return DisplayUtil.windowHeight;
  }

  // 获取可用内容高度(屏幕高度-状态栏高度)(px)
  static getContentHeight(): number {
    return DisplayUtil.screenHeight - DisplayUtil.statusBarHeight;
  }

  // 转换为虚拟像素(vp)
  static px2vp(px: number): number {
    return px / (DisplayUtil.screenWidth / 360); // 基于360vp基准宽度
  }
}