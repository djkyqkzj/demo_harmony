import { TimeUtils } from "../common/utils/TimeUtils"
import audioPlayerService, { TimerPlayInfo } from '../common/utils/AudioPlayerService';
import { EventBus } from "../common/utils/EventBus";
import { StorageConstants } from "../common/constants/StorageConstants";

@Component
struct RegularTime {
  @State remainingTime: number = 0
  @State checkRemainingTime: number = 0
  onClose: () => void = () => {
  }

  aboutToAppear(): void {
    this.remainingTime = audioPlayerService.getRemainingTimeSeconds();
    this.checkRemainingTime = audioPlayerService.getRemainingTimeTotal()
    EventBus.listen<TimerPlayInfo>(StorageConstants.TIMER_PLAY_UPDATE, (info) => {
      if (info) {
        this.remainingTime = info.remainingTime
        // 更新UI显示剩余时间
      }
    });
  }


  private checkTime(time: number) {
    if (time === 0) {
      audioPlayerService.stopTimerPlay();
    } else {
      audioPlayerService.startTimerPlay(time);
    }

    this.onClose()
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
          // if (this.remainingTime > 0) {
          //   this.stopCountDown()
          // }
        })

      Column() {
        if (this.remainingTime > 0) {
          Text(){
            Span(TimeUtils.timestampToDateTime(this.remainingTime!,
              this.remainingTime! >= 3600000 ? "HH:mm:ss" : "mm:ss"))
            Span(" ")
            Span($r('app.string.checkTimeEnd'))
          }
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .width('100%')
            .textAlign(TextAlign.Start)
        } else {
          Text($r('app.string.checkTime'))
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .width('100%')
            .textAlign(TextAlign.Start)
        }

        Row() {
          Text($r('app.string.checkTimeClose'))
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor('#F2F2F2')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.checkTime(0)
            })

          Text("15'")
            .fontColor(this.checkRemainingTime === 15 ? '#ffffff' : '#000000')
            .fontSize(14)
            .fontWeight(500)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.checkRemainingTime === 15 ? '#A69B97' : '#F2F2F2')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.checkTime(15)
            })

          Text("30'")
            .fontColor(this.checkRemainingTime === 30 ? '#ffffff' : '#000000')
            .fontSize(14)
            .fontWeight(500)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.checkRemainingTime === 30 ? '#A69B97' : '#F2F2F2')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.checkTime(30)
            })

          Text("60'")
            .fontColor(this.checkRemainingTime === 60 ? '#ffffff' : '#000000')
            .fontSize(14)
            .fontWeight(500)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.checkRemainingTime === 60 ? '#A69B97' : '#F2F2F2')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.checkTime(60)
            })

          Text("120'")
            .fontColor(this.checkRemainingTime === 120 ? '#ffffff' : '#000000')
            .fontSize(14)
            .fontWeight(500)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.checkRemainingTime === 120 ? '#A69B97' : '#F2F2F2')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.checkTime(120)
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 20 })
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

export { RegularTime }