import router from '@ohos.router';

@Component
struct NvBarBg {
  private title?: string = '';
  private isShare?: boolean = false;
  private onRightPress: () => void = () => {};

  build() {
    Row(){
      Image($r('app.media.backButtonImage'))
        .width(56)
        .height(40)
        .margin({ left: 12 })
        .onClick(() => {
          router.back();
        })

      if (this.title) {
        Text(this.title)
          .fontSize(18)
          .layoutWeight(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .margin({ left: 10, right: this.isShare ? 10 : 78 })
          .textAlign(TextAlign.Center)
      }

      if (this.isShare) {
        Image($r('app.media.icon_share'))
          .width(56)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.onRightPress()
          })
      }

    }
    .width('100%')
    .height(44)
    .zIndex(10)
    .backgroundColor('#ffffff')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}

export { NvBarBg };