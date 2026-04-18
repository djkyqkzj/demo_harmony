// SettingChannelDialog.ets
import { FastToast } from "../common/utils/FastToast"
import { LanguageUtils } from "../common/utils/LanguageUtils"
import { setChannelApi } from '../common/http/Api'
import { ChannelItem } from "../common/constants/Model";

interface Channel {
  channel_id: number;
  sort_order: number;
}

@Component
struct SettingChannelDialog {
  @State homeList: ChannelItem[] = []
  @State moreList: ChannelItem[] = []
  @State randomOffset: number = Math.random() * 4 - 2
  @State selectedChannels: ChannelItem[] = []
  @State availableChannels: ChannelItem[] = []
  onSend: () => void = () => {
  }
  onClose: () => void = () => {
  }

  private async onSave() {
    if (this.homeList.length < 3) {
      FastToast.showToast($r('app.string.upToMin'))
      return
    }

    let channels: Channel[] = []
    this.homeList.forEach((item: ChannelItem, index: number) => {
      let channel: Channel = {
        channel_id: item.id!,
        sort_order: this.homeList.length - index
      }
      channels.push(channel)
    });
    const res = await setChannelApi({"channels": channels})
    if (res.code === 200) {
      FastToast.showToast($r('app.string.settingChannelSuccess'))
      this.onSend()
    } else {
      FastToast.showToast($r('app.string.settingChannelFail'))
    }
  }

  private handleAddChannel(item: ChannelItem) {
    if (this.homeList.length < 7) {
      this.homeList = [...this.homeList, item]
      this.moreList = this.moreList.filter(channel => channel.id !== item.id)
    } else {
      FastToast.showToast($r('app.string.upTo'))
    }
  }

  private handleRemoveChannel(item: ChannelItem) {
    this.homeList = this.homeList.filter(channel => channel.id !== item.id)
    this.moreList = [...this.moreList, item]
  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')


      Image($r('app.media.close'))
        .width(56)
        .height(40)
        .position({ right: 20, bottom: '72%' })
        .onClick(() => {this.onClose()})

      Column() {
        Row() {
          Column() {
            Text($r('app.string.editShortcut'))
              .fontSize(20)
              .fontWeight(500)
              .fontColor('#000000')

            Text($r('app.string.upTo'))
              .fontSize(12)
              .fontWeight(400)
              .fontColor('rgba(0, 0, 0, 0.5)')
              .margin({top: 12})
          }
          .alignItems(HorizontalAlign.Start)

          Text($r('app.string.save'))
            .fontSize(12)
            .fontWeight(400)
            .fontColor('#ffffff')
            .backgroundColor('#A69B97')
            .borderRadius(100)
            .padding({top: 6, left: 12, bottom: 6, right: 12})
            .onClick(() => {
              this.onSave()
            })

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            Grid() {
              ForEach(this.homeList, (item: ChannelItem) => {
                GridItem() {
                  Column() {
                    Stack() {
                      Image($r('app.media.icon_remove'))
                        .width(24)
                        .height(24)
                        .objectFit(ImageFit.Cover)
                        .position({ left: 0, top: 0 })

                      Image(item.icon)
                        .width(70)
                        .height(70)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(35)
                    }
                    .width(70)
                    .height(70)
                    Text(LanguageUtils.getSystemLanguage() === 'zh' ? item.title_cn : item.title_en)
                      .fontColor('#000000')
                      .fontSize(12)
                      .fontWeight(400)
                      .width(70)
                      .margin({ top: 6 })
                      .maxLines(1)
                      .ellipsisMode(EllipsisMode.END)
                      .textAlign(TextAlign.Center)
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .animation({
                    duration: 100,
                    iterations: -1,
                    curve: Curve.EaseInOut
                  })
                  .translate({
                    x: this.randomOffset
                  })
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.handleRemoveChannel(item)
                  })
                }

              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
            .width('100%')

            Grid() {
              ForEach(this.moreList, (item: ChannelItem) => {
                GridItem() {
                  Column() {
                    Stack() {
                      Image($r('app.media.icon_add'))
                        .width(24)
                        .height(24)
                        .objectFit(ImageFit.Cover)
                        .position({ left: 0, top: 0 })

                      Image(item.icon)
                        .width(70)
                        .height(70)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(35)
                    }
                    .width(70)
                    .height(70)
                    Text(LanguageUtils.getSystemLanguage() === 'zh' ? item.title_cn : item.title_en)
                      .fontColor('#000000')
                      .fontSize(12)
                      .fontWeight(400)
                      .width(70)
                      .margin({ top: 6 })
                      .maxLines(1)
                      .ellipsisMode(EllipsisMode.END)
                      .textAlign(TextAlign.Center)
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.handleAddChannel(item)
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsGap(10)
            .margin({top: 20})
            .columnsGap(10)
            .width('100%')
          }
          .padding({bottom: 30})
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('70%')
      .padding(20)
      .margin({bottom: 60})
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 20, topRight: 20 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
    }
    .width('100%')
    .height('100%')
    .zIndex(999999)
  }
}

export { SettingChannelDialog }