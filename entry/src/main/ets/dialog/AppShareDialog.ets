import { Music } from "../common/constants/Model"
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { LanguageUtils } from "../common/utils/LanguageUtils";
import HttpRequest from "../common/http/HttpRequest";
import { StorageConstants } from "../common/constants/StorageConstants";
import { FastToast } from "../common/utils/FastToast";
import { getShareImgApi } from '../common/http/Api';
import { JSON } from "@kit.ArkTS";
import fs from '@ohos.file.fs';


@Component
struct AppShareDialog {
  @State date: Music = {}
  @State type: number = 0
  @State shareImg:string=''
  private language: string = LanguageUtils.getSystemLanguage()
  @State isShowPoster: boolean = false
  onClose: () => void = () => {
  }

  aboutToAppear(): void {
  this.getShareImg()
  }

  private  async getShareImg(){
    const res = await getShareImgApi()
    if(res.code ==200){
      this.shareImg = res.data.url
    }
  }



  private async share(scene: number) {
    // const imageData = await HttpRequest.download(this.date.cover_image, 'downloaded_image', 'png');
    try {
      const wxApi = wxopensdk.WXAPIFactory.createWXAPI(StorageConstants.APP_ID)
      if (!wxApi.isWXAppInstalled()) {
        FastToast.showToast($r('app.string.installWechat'))
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
        FastToast.showToast($r('app.string.shareFailedRetry'))
      }
    } catch (error) {
      console.error('微信分享错误:', error)
      FastToast.showToast($r('app.string.shareFailedCheckNetwork'))
    }
  }

  private async generateShareImage(): Promise<string | null> {
    try {
      const context = getContext(this) as common.UIAbilityContext

      // 创建离屏Canvas
      const canvasWidth = 375  // 移动端屏幕宽度
      const canvasHeight = 423  // 与容器高度一致

      // 创建图片生成组件 - 使用现有的shareImg作为背景
      const backgroundImagePath = await HttpRequest.download(this.shareImg, 'bg_image', 'png')

      // 创建一个新的PixelMap来绘制分享内容
      const imageSource = image.createImageSource(backgroundImagePath)
      const pixelMap = imageSource.createPixelMapSync()

      // 创建图片打包器
      const imagePacker = image.createImagePacker()

      // 将图片编码为JPEG格式
      const imageBuffer = await imagePacker.packToData(pixelMap, {
        format: "image/jpeg",
        quality: 85
      })

      // 保存到临时目录
      const tempDir = context.tempDir
      const fileName = `share_${Date.now()}.jpg`
      const filePath = `${tempDir}/${fileName}`

      // 写入文件
      const file = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      await fs.write(file.fd, imageBuffer)
      fs.close(file)

      console.log('分享图片生成成功:', filePath)
      return filePath
    } catch (error) {
      console.error('生成分享图片失败:', error)
      return null
    }
  }

  private async shareAsImage(scene: number) {
    try {
      // 显示加载提示
      FastToast.showToast($r('app.string.generatingShareImage'))

      // 验证配置
      if (!this.validateWeChatConfig()) {
        FastToast.showToast($r('app.string.wechatConfigError'))
        return
      }

      const wxApi = wxopensdk.WXAPIFactory.createWXAPI(StorageConstants.APP_ID)
      if (!wxApi.isWXAppInstalled()) {
        FastToast.showToast($r('app.string.installWechat'))
        return
      }

      // 生成分享图片
      const shareImagePath = await this.generateShareImage()
      if (!shareImagePath) {
        FastToast.showToast($r('app.string.generateShareImageFailed'))
        return
      }

      // 创建图片对象
      const imageObject = new wxopensdk.WXImageObject()
      imageObject.imageData = shareImagePath // 使用截图文件路径

      // 创建媒体消息
      const mediaMessage = new wxopensdk.WXMediaMessage()
      mediaMessage.mediaObject = imageObject
      mediaMessage.title = this.language === "zh" ? "demo - 疗愈身心静享平和" : "demo - Listen Inward, Find Balance"
      mediaMessage.description = this.language === "zh" ?
        "加入 demo，与众多志同道合者一起为健康和幸福努力！" :
        "Join demo and join many like-minded people working towards health and happiness!"

      // 设置缩略图 - 使用截图生成缩略图
      try {
        const imageSource = image.createImageSource(shareImagePath)
        const pixelMap = imageSource.createPixelMapSync()

        // 调整缩略图尺寸（微信要求小于32KB）
        const thumbBuffer = await image.createImagePacker().packToData(pixelMap, {
          format: "image/jpeg",
          quality: 20
        })

        if (thumbBuffer.byteLength <= 32 * 1024) {
          mediaMessage.thumbData = new Uint8Array(thumbBuffer)
        }
      } catch (thumbError) {
        console.warn('缩略图处理失败:', thumbError)
      }

      // 创建分享请求
      const req = new wxopensdk.SendMessageToWXReq()
      req.scene = scene === 0
        ? wxopensdk.SendMessageToWXReq.WXSceneSession
        : wxopensdk.SendMessageToWXReq.WXSceneTimeline
      req.message = mediaMessage

      // 发送分享请求
      const result = wxApi.sendReq(getContext(this) as common.UIAbilityContext, req)
      if (result) {
        FastToast.showToast($r('app.string.shareSuccess'))
        this.onClose()
      } else {
        FastToast.showToast($r('app.string.shareFailedRetry'))
      }
    } catch (error) {
      console.error('图片分享异常:', error)
      FastToast.showToast($r('app.string.shareErrorRetry'))
    }
  }

  private validateWeChatConfig(): boolean {
    console.log('=== 微信配置验证 ===')
    console.log('AppID:', StorageConstants.APP_ID)
    console.log('包名:', 'com.demo.app')

    // 检查AppID格式
    const appID = StorageConstants.APP_ID
    if (!appID || !appID.startsWith('wx')) {
      console.error('AppID格式错误:', appID)
      return false
    }

    if (appID.length !== 18) {
      console.error('AppID长度错误，应为18位:', appID.length)
      return false
    }

    console.log('微信配置验证通过')
    return true
  }

  private async shareAsWebPage(scene: number) {
    try {
      FastToast.showToast($r('app.string.generatingShareLink'))

      const wxApi = wxopensdk.WXAPIFactory.createWXAPI(StorageConstants.APP_ID)
      if (!wxApi.isWXAppInstalled()) {
        FastToast.showToast($r('app.string.installWechat'))
        return
      }

      // 创建网页分享对象
      const webpageObject = new wxopensdk.WXWebpageObject()
      // 使用应用下载链接或官网链接
      webpageObject.webpageUrl = "https://m.demo.art"

      const mediaMessage = new wxopensdk.WXMediaMessage()
      mediaMessage.mediaObject = webpageObject
      mediaMessage.title = this.language === "zh" ? "demo - 疗愈身心静享平和" : "demo - Listen Inward, Find Balance"
      mediaMessage.description = this.language === "zh" ?
        "加入 demo，与众多志同道合者一起为健康和幸福努力！" :
        "Join demo and join many like-minded people working towards health and happiness!"

      // 设置缩略图
      try {
        if (this.shareImg) {
          const thumbImagePath = await HttpRequest.download(this.shareImg, 'thumb_image', 'png')
          const imageSource = image.createImageSource(thumbImagePath)
          const pixelMap = imageSource.createPixelMapSync()

          const thumbBuffer = await image.createImagePacker().packToData(pixelMap, {
            format: "image/jpeg",
            quality: 20
          })

          if (thumbBuffer.byteLength <= 32 * 1024) {
            mediaMessage.thumbData = new Uint8Array(thumbBuffer)
          }
        }
      } catch (thumbError) {
        console.warn('缩略图处理失败:', thumbError)
      }

      const req = new wxopensdk.SendMessageToWXReq()
      req.scene = scene === 0
        ? wxopensdk.SendMessageToWXReq.WXSceneSession
        : wxopensdk.SendMessageToWXReq.WXSceneTimeline
      req.message = mediaMessage

      const result = wxApi.sendReq(getContext(this) as common.UIAbilityContext, req)
      if (result) {
        FastToast.showToast($r('app.string.shareSuccess'))
        this.onClose()
      } else {
        FastToast.showToast($r('app.string.shareFailedRetry'))
      }
    } catch (error) {
      console.error('网页分享错误:', error)
      FastToast.showToast($r('app.string.shareFailedCheckNetwork'))
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

        Column() {


          Image(this.shareImg)
            .width(200)
            .height(200)
            .objectFit(ImageFit.Cover)
            .margin({ top: 20, bottom: 20 })

          Text($r('app.string.joindemo'))
            .fontColor('#000000')
            .fontSize(18)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 20 })

          // 横向容器，包含两个左右对齐的子容器
          Row() {
            // 左侧容器 - 宽度自适应
            Row() {
              // Logo图片
              Image($r('app.media.icon'))
                .width(50)
                .height(50)
                .objectFit(ImageFit.Cover)

              // 三行文字 - 上下排列
              Column() {
                Text('demo')
                  .fontSize(16)
                  .fontColor('#000000')
                  .fontWeight(600)
                  .margin({ bottom: 4 })

                Text($r('app.string.healingBodyMind'))
                  .fontSize(14)
                  .fontColor('#000000')
                  .margin({ bottom: 4 })

                Text($r('app.string.enjoyPeace'))
                  .fontSize(14)
                  .fontColor('#000000')
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            // 右侧容器 - 固定图片
            Image($r('app.media.app_share'))
              .width(58)
              .height(58)
              .objectFit(ImageFit.Cover)
          }
          .width('100%')
          .margin({ bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)

        }
        .width("100%")
        .padding(20)
        .height(423)
        .backgroundColor('#dddddd')
        .margin({bottom:20})
        .justifyContent(FlexAlign.Center)
  

        Text("分享给你的朋友和家人")
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
            this.shareAsImage(0) // 分享到微信会话
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
            this.shareAsImage(1) // 分享到朋友圈
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
      .height('80%')
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

export { AppShareDialog }