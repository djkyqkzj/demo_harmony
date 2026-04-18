import { Music } from "../common/constants/Model"
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { LanguageUtils } from "../common/utils/LanguageUtils";
import HttpRequest from "../common/http/HttpRequest";
import { StorageConstants } from "../common/constants/StorageConstants";
import { FastToast } from "../common/utils/FastToast";

@Component
struct ShareModal {
  @State date: Music = {}
  @State type: number = 0
  private language: string = LanguageUtils.getSystemLanguage()
  @State isShowPoster: boolean = false
  onClose: () => void = () => {
  }

  aboutToAppear(): void {

  }

  private async share(scene: number) {
    // const imageData = await HttpRequest.download(this.date.cover_image, 'downloaded_image', 'png');
    try {
      const wxApi = wxopensdk.WXAPIFactory.createWXAPI(StorageConstants.APP_ID)
      if (!wxApi.isWXAppInstalled()) {
        FastToast.showToast('请安装微信')
        return
      }

      const webpageObject = new wxopensdk.WXWebpageObject()
      const shareUrl = this.type === 0
        ? `https://m.demo.art?pId=${this.date?.id}&l=${this.language}&t=m`
        : `https://m.demo.art/article?aId=${this.date?.id}&l=${this.language}&t=a`

      webpageObject.webpageUrl = shareUrl

      const mediaMessage = new wxopensdk.WXMediaMessage()
      mediaMessage.mediaObject = webpageObject
      mediaMessage.title = this.language == "zh" ? this.date.title_cn : this.date.title_en
      mediaMessage.description = this.language == "zh" ? this.date.description_cn : this.date.description_en

      if (this.date.cover_image) {
        try {
          const imageData = await HttpRequest.download(this.date.cover_image, 'downloaded_image', 'png')
          const thumbPixel = image.createImageSource(imageData).createPixelMapSync()

          // 调整缩略图尺寸（微信要求小于32KB）
          const thumbBuffer = await image.createImagePacker().packToData(thumbPixel, {
            format: "image/jpeg", // 使用JPEG格式减小文件大小
            quality: 20  // 降低质量以减小文件大小
          })

          // 检查缩略图大小
          if (thumbBuffer.byteLength > 32 * 1024) {
            console.warn('缩略图过大，可能会影响分享')
          }

          mediaMessage.thumbData = new Uint8Array(thumbBuffer)
        } catch (thumbError) {
          console.warn('缩略图处理失败，使用默认分享:', thumbError)
          // 可以选择不设置缩略图或使用默认图片
        }
      }

      const req = new wxopensdk.SendMessageToWXReq()
      req.scene = scene === 0
        ? wxopensdk.SendMessageToWXReq.WXSceneSession
        : wxopensdk.SendMessageToWXReq.WXSceneTimeline
      req.message = mediaMessage

      // 7. 发送请求
      const result = wxApi.sendReq(getContext(this) as common.UIAbilityContext, req)
      if (!result) {
        FastToast.showToast('分享失败，请重试')
      }
    } catch (error) {
      console.error('微信分享错误:', error)
      FastToast.showToast('分享失败，请检查网络连接')
    }
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

      Column() {
        Text($r('app.string.share'))
          .fontColor('#000000')
          .fontSize(15)
          .fontWeight(500)
          .width('100%')
          .textAlign(TextAlign.Start)

        Row() {
          Column() {
            Image($r('app.media.wechat'))
              .width(48)
              .height(48)

            Text($r('app.string.wechat'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .margin({ top: 10 })
          }
          .onClick(() => {
            this.share(0)
          })

          Column() {
            Image($r('app.media.friendsCircle'))
              .width(48)
              .height(48)

            Text($r('app.string.friendsCircle'))
              .fontColor('#000000')
              .fontSize(14)
              .fontWeight(500)
              .margin({ top: 10 })
          }
          .margin({ left: 30 })
          .onClick(() => {
            this.share(1)
          })

          // if (!this.isShowPoster) {
          //   Column(){
          //     Image($r('app.media.icon_poster'))
          //       .width(48)
          //       .height(48)
          //
          //     Text($r('app.string.poster'))
          //       .fontColor('#000000')
          //       .fontSize(14)
          //       .fontWeight(500)
          //       .margin({top: 10})
          //   }
          //   .margin({left: 30})
          //   .onClick(() => {
          //     this.isShowPoster = true
          //   })
          // }

        }
        .width('100%')
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

export { ShareModal }