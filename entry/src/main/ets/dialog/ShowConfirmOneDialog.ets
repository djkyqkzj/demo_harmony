
@Component
struct ShowConfirmOneDialog {
  @State content: string = ''
  @State title: string = ''
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
        Text(this.title ? this.title : $r('app.string.hint'))
          .fontSize(18)
          .fontWeight(500)
          .fontColor('#000000')

        Text(this.content)
          .fontSize(14)
          .fontWeight(400)
          .margin({top: 20})
          .fontColor('#000000')

        Button($r('app.string.vip_tip_btn'))
          .type(ButtonType.Normal)
          .backgroundColor($r('app.color.secondary'))
          .fontColor($r('app.color.status_bar_bg'))
          .borderRadius(20)
          .margin({top: 20})
          .width('100%')
          .onClick(async () => {
            this.onClose()
          })

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

export { ShowConfirmOneDialog }