import router from '@ohos.router';
import { StatusBarUtil } from '../common/utils/StatusBarUtil';
import { DisplayUtil } from '../common/utils/DisplayUtil';

@Entry
@Component
struct GuidePage {
  onPageShow(): void {
    StatusBarUtil.setStatusBar('#ffffff', '#000000', false);
  }
  build() {
    Column() {
      Image($r('app.media.guide'))
        .width('100%')
        .height(DisplayUtil.getWindowHeight() - 200)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

      Text($r('app.string.slogan1'))
        .fontSize(36)
        .fontWeight(500)
        .fontColor($r('app.color.start_window_background'))
        .margin({ top: -50 })

      Text($r('app.string.slogan2'))
        .fontSize(36)
        .fontWeight(500)
        .fontColor($r('app.color.start_window_background'))

      Image($r('app.media.start'))
        .width(50)
        .height(49.5)
        .margin({top: 30})
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(async () => {
          router.replace({ url: 'pages/login/LoginPage' })
        })
    }
  }
}