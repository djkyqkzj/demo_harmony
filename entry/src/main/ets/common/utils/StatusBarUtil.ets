import window from '@ohos.window';

export class StatusBarUtil {
  static setStatusBar(bgColor: string, contentColor: string, isFullScreen?: boolean) {

    window.getLastWindow(getContext(), (err, data) => {
      let win: window.Window;
      if (err.code) {
        console.error("error code :" + JSON.stringify(err.code))
        return;
      }
      try {
        win = data;
        //设置窗口为全屏模式
        win.setWindowLayoutFullScreen(isFullScreen);
        // 设置状态栏
        win.setWindowSystemBarProperties({
          // 设置状态栏颜色为其他颜色
          statusBarColor: bgColor,
          // 设置状态栏文本颜色为白色
          statusBarContentColor: contentColor
        })
      } catch (e) {
        console.error("error cause :" + JSON.stringify(e))
      }
    })
  }
}