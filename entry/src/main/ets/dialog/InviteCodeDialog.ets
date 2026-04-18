import { BackgroundCountdownService } from "../common/utils/BackgroundCountdownService";
import { TimeUtils } from "../common/utils/TimeUtils"
import common from '@ohos.app.ability.common';

@Component
struct InviteCodeDialog {
  @State inputBorderColor: string = '#F2F2F2';
  @State code : string = ''
  onConfirm: (code: string) => void = () => {
  }
  onClose: () => void = () => {
  }

  aboutToAppear(): void {

  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .onClick(() => {
          this.onClose()
        })

      Column(){
        TextInput({ placeholder: $r('app.string.invitecode') })
          .width('100%')
          .height(50)
          .backgroundColor($r('app.color.status_bar_bg'))
          .placeholderColor('rgba(0, 0, 0, 0.30)')
          .fontColor($r('app.color.start_window_background'))
          .fontSize(14)
          .fontWeight(500)
          .border({
            width: 1,
            color: this.inputBorderColor,
            radius: 100
          })
          .onChange((value: string) => {
            this.code = value;
          })

        Button($r('app.string.submit'))
          .type(ButtonType.Normal)
          .backgroundColor($r('app.color.secondary'))
          .fontColor($r('app.color.status_bar_bg'))
          .borderRadius(100)
          .width('100%')
          .height(50)
          .margin({ top: 12 })
          .onClick(async () => {
            this.onConfirm(this.code)
          })

      }
      .width('100%')
      .height('20%')
      .padding(20)
      .margin({ bottom: 60 })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 20, topRight: 20 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
    }
    .width('100%')
    .height('100%')
    .zIndex(10)
  }
}

export { InviteCodeDialog }