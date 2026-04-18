import router from '@ohos.router';
import { StorageUtil } from '../common/utils/StorageUtil';
import { StorageConstants } from '../common/constants/StorageConstants';
import { EventBus } from '../common/utils/EventBus';
import { FastToast } from '../common/utils/FastToast';
import { FastTool } from '../common/utils/FastTool';
import { AddEvent } from '../common/http/addEvent';

@Component
export struct UserDrawer {
  @State avatar: string = ""
  @State nickname: string = ""
  private drawerWidth: string = '85%'
  private animationDuration: number = 300
  onClose: () => void = () => {
  }


  aboutToAppear(): void {
    this.getUser()

    EventBus.listen<string>(StorageConstants.UPDATE_NICKNAME, (newNickname) => {
      if (newNickname) {
        this.nickname = newNickname;
      }
    });

    EventBus.listen<string>(StorageConstants.UPDATE_AVATAR, (newAvatar) => {
      if (newAvatar) {
        this.avatar = newAvatar;
      }
    });
  }

  private async getUser() {
    this.avatar = await StorageUtil.getString(StorageConstants.AVATAR, '')
    this.nickname = await StorageUtil.getString(StorageConstants.NICK_NAME, '')
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .onClick(() => {
            this.onClose()
          })

      Column() {
        Column() {
          Row(){
            Image(this.avatar)
              .width(64)
              .height(64)
              .objectFit(ImageFit.Cover)
              .borderRadius(32)

            Text(this.nickname)
              .fontColor('#000000')
              .fontSize(20)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)

            Image($r('app.media.right'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

          }
          .width('100%')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/userInfo/userInfo'
            })
            this.onClose()
          })

          Row(){
            Image($r('app.media.membership'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.membership'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:24})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            AddEvent.addClickEvent("my_vip_button_click")
            // EventBus.send(StorageConstants.UPDATE_VIP)
            router.pushUrl({
              url: 'pages/member/member'
            })
            this.onClose()
          })

          Row(){
            Image($r('app.media.checkin'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.checkin'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:16})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            EventBus.send(StorageConstants.CHECK_IN1)
          })

          Row(){
            Image($r('app.media.notifi'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.notifi'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:16})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/message/message'
            })
            this.onClose()
          })

          Row(){
            Image($r('app.media.friends'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.shareWithFriends'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:16})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            EventBus.send(StorageConstants.APP_SHARE)
          })

        }
        .width('100%')

        Column() {
          Row(){
            Image($r('app.media.help'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.help'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:16})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/feedBack/feedBack'
            })
            this.onClose()
          })

          Row(){
            Image($r('app.media.setting'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Cover)

            Text($r('app.string.setting'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .layoutWeight(1)
              .margin({right: 12, left: 12})
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
          }
          .width('100%')
          .margin({top:16})
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/setting/setting'
            })
            this.onClose()
          })
        }
        .width('100%')
      }
      .width(this.drawerWidth)
      .height('100%')
      .padding(20)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
      .borderRadius({topRight: 20, bottomRight: 20})
      .offset({
        x: 0,
        y: 0
      })
      .animation({
        duration: this.animationDuration,
        curve: Curve.EaseOut
      })
      .gesture(
        PanGesture({ direction: PanDirection.Right, distance: 30 })
          .onActionStart(() => {
            this.onClose
          })
      )
    }
    .width('100%')
    .height('100%')
  }
}