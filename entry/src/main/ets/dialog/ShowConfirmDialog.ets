
@Component
struct ShowConfirmDialog {
  @State content: string = ''
  onConfirm: () => void = () => {
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

      Column() {
        Text($r('app.string.hint'))
          .fontSize(18)
          .fontWeight(500)
          .fontColor('#000000')

        Text(this.content)
          .fontSize(14)
          .fontWeight(400)
          .margin({top: 20})
          .fontColor('#000000')

        Row() {
          Button($r('app.string.cancel'))
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.f2f2f2'))
            .fontColor($r('app.color.start_window_background'))
            .borderRadius(20)
            .borderWidth(1)
            .borderColor($r('app.color.f2f2f2'))
            .width('48%')
            .onClick(() => this.onClose())

          Button($r('app.string.agree'))
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.secondary'))
            .fontColor($r('app.color.status_bar_bg'))
            .borderRadius(20)
            .width('48%')
            .margin({ left: 16 })
            .onClick(async () => {
              this.onConfirm()
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({top: 20})
        .width('100%')

      }
      .width('80%')
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .backgroundColor($r('app.color.status_bar_bg'))
      .borderRadius(12)
      .shadow({ radius: 20, color: '#33000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
    .zIndex(10)
  }
}

export { ShowConfirmDialog }