import router from '@ohos.router';
import { FastToast } from '../../common/utils/FastToast';
import { NetworkUtils } from '../../common/utils/NetworkUtils';
import { PhoneValidator } from '../../common/utils/PhoneValidator';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';
import { getSmsCode, mobileVerify } from '../../common/http/Api'
import { StorageUtil } from '../../common/utils/StorageUtil';
import { StorageConstants } from '../../common/constants/StorageConstants';
import { AddEvent } from '../../common/http/addEvent';

@Entry
@Component
struct LoginPage {
  @State inputBorderColor: string = '#F2F2F2';
  @State codeBorderColor: string = '#F2F2F2';
  @State phone: string = '';
  @State code: string = '';
  @State check: boolean = false;
  @State count: number = 0
  @State isCounting: boolean = false
  private timer: number | null = null
  private totalSeconds: number = 60 // 总倒计时秒数’
  @State isShow: boolean = false;
  private networkUtils: NetworkUtils = NetworkUtils.getInstance(getContext(this));

  aboutToAppear(): void {
    StatusBarUtil.setStatusBar('#ffffff', '#000000', false);
  }

  // 开始倒计时
  private startCountDown() {
    this.isCounting = true
    this.count = this.totalSeconds

    this.timer = setInterval(() => {
      this.count--

      if (this.count <= 0) {
        this.stopCountDown()
      }
    }, 1000)
  }

  // 停止倒计时
  private stopCountDown() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
    this.isCounting = false
    this.count = 0
  }

  // 组件销毁时清理定时器
  aboutToDisappear() {
    this.stopCountDown()
  }

  private async getCode() {
    const isConnected = await this.networkUtils.isConnected();

    if (!isConnected) {
      FastToast.showToast($r('app.string.incorrectPhone'))
      return
    }
    if (!PhoneValidator.validate(this.phone)) {
      FastToast.showToast($r('app.string.incorrectPhone'))
      return
    }
    if (!this.check) {
      this.isShow = true
      return
    }
    const res = await getSmsCode({
      mobile: this.phone,
    });
    if (res.code === 200) {
      FastToast.showToast(res.data.msg)
      this.startCountDown()
    } else {
      FastToast.showToast(res.message)
    }
  }

  private async login() {
    const isConnected = await this.networkUtils.isConnected();

    if (!isConnected) {
      FastToast.showToast($r('app.string.incorrectPhone'))
      return
    }
    if (!PhoneValidator.validate(this.phone)) {
      FastToast.showToast($r('app.string.incorrectPhone'))
      return
    }
    if (!this.code) {
      FastToast.showToast($r('app.string.enterVerification'))
      return
    }
    if (!this.check) {
      FastToast.showToast($r('app.string.placeCheck'))
      return
    }
    const res = await mobileVerify({
      mobile: this.phone,
      code: this.code
    });
    if (res.code === 200) {
      AddEvent.addEventEvent("user_registed",{ type: "mobile", is_success: 1 })
      StorageUtil.putBoolean(StorageConstants.IS_LOGGED_IN, true)
      StorageUtil.putString(StorageConstants.TOKEN, res.data.token)
      StorageUtil.putString(StorageConstants.UID, res.data.uid)
      router.replace({ url: 'pages/tab/MainPage' })
    } else {
      FastToast.showToast(res.message)
    }
  }

  build() {
    Stack() {
      Column() {
        Text($r('app.string.loginTitle'))
          .height(50)
          .width("100%")
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.start_window_background'))
          .textAlign(TextAlign.Center)

        TextInput({ placeholder: $r('app.string.phone') })
          .width('90%')
          .height(50)
          .margin({ top: 30 })
          .backgroundColor($r('app.color.status_bar_bg'))
          .placeholderColor('rgba(0, 0, 0, 0.30)')
          .fontColor($r('app.color.start_window_background'))
          .fontSize(14)
          .fontWeight(500)
          .maxLength(11)
          .type(InputType.Number)
          .border({
            width: 1,
            color: this.inputBorderColor,
            radius: 100
          })
          .onChange((value: string) => {
            this.phone = value;
          })
          .onEditChange((isEditing: boolean) => {
            // 获取焦点时设置边框颜色
            if (isEditing) {
              this.inputBorderColor = '#A69B97';
            }
          })
          .onBlur(() => {
            // 失去焦点时设置边框颜色
            this.inputBorderColor = '#F2F2F2';
          })

        Row() {
          TextInput({ placeholder: $r('app.string.code') })
            .width('70%')
            .height(50)
            .backgroundColor($r('app.color.status_bar_bg'))
            .placeholderColor('rgba(0, 0, 0, 0.30)')
            .fontColor($r('app.color.start_window_background'))
            .fontSize(14)
            .fontWeight(500)
            .maxLength(4)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.code = value;
            })
            .onEditChange((isEditing: boolean) => {
              // 获取焦点时设置边框颜色
              if (isEditing) {
                this.codeBorderColor = '#A69B97';
              }
            })
            .onBlur(() => {
              // 失去焦点时设置边框颜色
              this.codeBorderColor = '#F2F2F2';
            })

          Text(this.isCounting ? `${this.count}s` : $r('app.string.getCode'))
            .fontSize(14)
            .height(50)
            .fontWeight(500)
            .margin({ right: 20 })
            .fontColor($r('app.color.secondary'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (!this.isCounting) {
                this.getCode()
              }
            })
        }
        .width('90%')
        .height(50)
        .margin({ top: 12 })
        .border({
          width: 1,
          color: this.codeBorderColor,
          radius: 100
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Button($r('app.string.loginBtnTxt'))
          .type(ButtonType.Normal)
          .backgroundColor($r('app.color.secondary'))
          .fontColor($r('app.color.status_bar_bg'))
          .borderRadius(100)
          .width('90%')
          .height(50)
          .margin({ top: 12 })
          .onClick(async () => {
            this.login()
          })

        Row() {
          Image(this.check ? $r('app.media.radio_check') : $r('app.media.radio'))
            .width(20)
            .height(20)
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
            .onClick(() => {
              this.check = !this.check
            })

          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            Text($r('app.string.policy1'))
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.7)')

            Text($r('app.string.privacy_user'))
              .fontSize(14)
              .fontColor($r('app.color.secondary'))
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/WebViewPage',
                  params: {
                    url: 'https://img.demo.art/html/x5CACASO1q3dZAZXLfIhsMpkkchrROpi.html'
                  }
                })
              })

            Text($r('app.string.policy2'))
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.7)')

            Text($r('app.string.privacy_policy'))
              .fontSize(14)
              .fontColor($r('app.color.secondary'))
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/WebViewPage',
                  params: {
                    url: 'https://img.demo.art/html/6tEKApsy3eFlsk75xOzoBxWt6g7TgnLT.html'
                  }
                })
              })
          }
          .margin({ left: 10 })
        }
        .width('85%')
        .margin({ top: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      if (this.isShow) {
        Stack() {
          // Overlay
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
            })

          Column() {
            Text($r('app.string.srviceAgreement'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.start_window_background'))
              .margin({ bottom: 16 })

            Text() {
              Span($r('app.string.pleaseRead'))
                .fontSize(14)
                .fontColor('#666666')

              Span($r('app.string.privacy_user'))
                .fontSize(14)
                .fontColor('#A69B97')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/WebViewPage',
                    params: { url: 'https://img.demo.art/html/x5CACASO1q3dZAZXLfIhsMpkkchrROpi.html' }
                  })
                })

              Span($r('app.string.privacy_policy'))
                .fontSize(14)
                .fontColor('#A69B97')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/WebViewPage',
                    params: { url: 'https://img.demo.art/html/6tEKApsy3eFlsk75xOzoBxWt6g7TgnLT.html' }
                  })
                })
            }
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .width('100%')

            Row() {
              Button($r('app.string.disagree'))
                .type(ButtonType.Normal)
                .backgroundColor($r('app.color.f2f2f2'))
                .fontColor($r('app.color.start_window_background'))
                .borderRadius(20)
                .borderWidth(1)
                .margin({left: 10})
                .borderColor($r('app.color.f2f2f2'))
                .width('40%')
                .onClick(() => this.isShow = false)

              Button($r('app.string.agree'))
                .type(ButtonType.Normal)
                .backgroundColor($r('app.color.secondary'))
                .fontColor($r('app.color.status_bar_bg'))
                .borderRadius(20)
                .width('40%')
                .margin({ right: 10 })
                .onClick(() => {
                  this.isShow = false;
                  this.check = true;
                  this.getCode()
                })
            }
            .margin({ top: 16 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('80%')
          .padding(20)
          .backgroundColor($r('app.color.status_bar_bg'))
          .borderRadius(12)
        }
      }
    }
  }
}