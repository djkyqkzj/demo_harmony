import { TimeUtils } from "../common/utils/TimeUtils";

@Component
struct LocalTimeModal {
  private timer: number | null = null
  @State time: string = TimeUtils.getCurrentTime();
  onClose: () => void = () => {
  }

  aboutToAppear(): void {
    this.startCountDown()
  }

  aboutToDisappear(): void {
    this.stopCountDown()
  }

  onPageShow() {

  }

  private startCountDown() {
    this.timer = setInterval(() => {
      this.time = TimeUtils.getCurrentTime();
    }, 1000)
  }

  // 停止倒计时
  private stopCountDown() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .backdropBlur(80)
        .onClick(() => {
          this.onClose()
        })

      Column() {
        Text(this.time)
          .fontColor('#ffffff')
          .fontSize(50)
          .fontWeight(500)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .zIndex(999)
  }
}

export { LocalTimeModal }