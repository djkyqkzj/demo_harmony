
@Component
struct SliderModal {
  @State rang: number = 0
  private timeoutId: number | null = null;

  onChange: (value: number) => void = () => {
  }

  onClose: () => void = () => {
  }

  aboutToAppear(): void {

  }

  resetInactivityTimer() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }
    this.startInactivityTimer();
  }

  startInactivityTimer() {
    this.timeoutId = setTimeout(() => {
      this.onChange(this.rang)
      this.resetInactivityTimer()
    }, 3000);
  }

  private onSelect(value: number){
    this.resetInactivityTimer()
    this.rang = value
    this.startInactivityTimer()
  }

  private getStarIcon(starIndex: number): Resource {
    // 如果当前星星序号 <= 选中的评分，显示高亮状态
    if (starIndex <= this.rang) {
      return $r(`app.media.icon_star${this.rang}`); // 高亮星星
    } else {
      return $r('app.media.icon_star'); // 默认星星
    }
  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')

      Column() {
        Row() {
          Text()
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#8D8481')

          Image($r('app.media.icon_close1'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.onClose()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        if (this.rang === 0) {
          Text($r('app.string.feel'))
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#A69B97')
            .backgroundColor('rgba(166, 155, 151, 0.1)')
            .padding({left: 12, right: 12, top: 8, bottom: 8})
            .borderRadius(20)
        } else {
          Text(){
            Span(this.rang.toString())
            Span($r('app.string.point'))
          }
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#ffffff')
            .backgroundColor(this.rang === 1 ? '#FFBC78' : this.rang === 2 ? '#9DD8F8' : this.rang === 3 ? '#87DBC8' : this.rang === 4 ? '#FFA5B2' : '#C2E687')
            .padding({left: 12, right: 12, top: 8, bottom: 8})
            .borderRadius(20)
        }

        Row() {
          ForEach([1, 2, 3, 4, 5], (index: number) => {
            Image(this.getStarIcon(index))
              .width(24)
              .height(24)
              .margin({ right: 3, left: 3 })
              .onClick(() => {
                this.onSelect(index);
              })
          })
        }
        .margin({top: 30})

      }
      .width('100%')
      .height('25%')
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

export { SliderModal }