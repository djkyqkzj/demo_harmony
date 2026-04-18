import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import { StorageUtil } from '../common/utils/StorageUtil';
import { StorageConstants } from '../common/constants/StorageConstants';

@Component
export struct PrivacyDialog {
  @State isShow: boolean = false;

  // 退出应用函数
  private exitApplication() {
    let ability = getContext(this) as common.UIAbilityContext;
    ability.terminateSelf().then(() => {
      console.log('Application terminated');
    }).catch((err: BusinessError) => {
      console.error(`Failed to terminate application, code is ${err.code}, message is ${err.message}`);
    });
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {})

      Column() {
        Text($r('app.string.privacy_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.start_window_background'))
          .margin({ bottom: 10 })

        Scroll() {
          Column() {

            Text($r('app.string.privacy_content'))
              .fontSize(14)
              .fontColor($r('app.color.status_bar_content'))

            Text() {
              Span($r('app.string.privacy_user'))
                .fontSize(14)
                .fontColor('#A69B97')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/WebViewPage',
                    params: { url: 'https://img.demo.art/html/x5CACASO1q3dZAZXLfIhsMpkkchrROpi.html' }
                  })
                })

              Span($r('app.string.privacy_user_content'))
                .fontSize(14)
                .fontColor('#666666')
            }
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .width('100%')

            Text() {
              Span($r('app.string.demo'))
                .fontSize(14)
                .fontColor('#666666')

              Span($r('app.string.privacy_policy'))
                .fontSize(14)
                .fontColor('#A69B97')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/WebViewPage',
                    params: { url: 'https://img.demo.art/html/6tEKApsy3eFlsk75xOzoBxWt6g7TgnLT.html' }
                  })
                })

              Span($r('app.string.privacy_children'))
                .fontSize(14)
                .fontColor('#A69B97')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/WebViewPage',
                    params: { url: 'https://img.demo.art/html/jUxeB3b2EYYJGZUZC8791n1gi8uT0V9u.html' }
                  })
                })

              Span($r('app.string.privacy_demo'))
                .fontSize(14)
                .fontColor('#666666')
            }
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .width('100%')

            Text($r('app.string.privacy_pirvace1'))
              .fontSize(16)
              .fontColor($r('app.color.status_bar_content'))

            Text($r('app.string.privacy_pirvace2'))
              .fontSize(16)
              .fontColor($r('app.color.status_bar_content'))

            Text($r('app.string.privacy_pirvace3'))
              .fontSize(16)
              .fontColor($r('app.color.status_bar_content'))

            Text($r('app.string.privacy_pirvace4'))
              .fontSize(16)
              .fontColor($r('app.color.status_bar_content'))
          }
        }.height('85%')

        Row() {
          Button($r('app.string.disagree'))
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.f2f2f2'))
            .fontColor($r('app.color.start_window_background'))
            .borderRadius(20)
            .borderWidth(1)
            .borderColor($r('app.color.f2f2f2'))
            .width('40%')
            .onClick(() => this.exitApplication())

          Button($r('app.string.agree'))
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.secondary'))
            .fontColor($r('app.color.status_bar_bg'))
            .borderRadius(20)
            .width('40%')
            .margin({ left: 16 })
            .onClick(async () => {
              await StorageUtil.putBoolean(StorageConstants.IS_FIRST_LAUNCH, true);
              this.isShow = false;
              router.replace({ url: 'pages/GuidePage' })
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({top: 10})
        .width('100%')
      }
      .width('80%')
      .height("60%")
      .padding(20)
      .backgroundColor($r('app.color.status_bar_bg'))
      .borderRadius(12)
      .shadow({ radius: 20, color: '#33000000', offsetX: 0, offsetY: 4 })
    }
    .visibility(this.isShow ? Visibility.Visible : Visibility.None)
  }
}