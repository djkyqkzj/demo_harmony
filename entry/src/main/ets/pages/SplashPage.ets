import { StorageUtil } from '../common/utils/StorageUtil'
import {StorageConstants} from '../common/constants/StorageConstants'
import router from '@ohos.router';
import { PrivacyDialog } from '../dialog/showPrivacyDialog';
import { StatusBarUtil } from '../common/utils/StatusBarUtil';
import { AddEvent } from '../common/http/addEvent';

@Entry
@Component
struct Index {
  @State showPrivacyDialog: boolean = false;
  onPageShow(): void {
    StatusBarUtil.setStatusBar( '#000000', '#ffffff', true);
    AddEvent.addEventEvent("app_start")
  }


  build() {
    RelativeContainer() {
      Image($r('app.media.launch_screen'))
        .width(100)
        .height(110)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onAppear(() => {
          setTimeout(() => {
            this.checkFirstLaunch()
          }, 500)
        })
      if (this.showPrivacyDialog) {
        PrivacyDialog({isShow: true})
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor("#000000")
  }
  // 检查是否是第一次启动
  private async checkFirstLaunch() {
    const isFirstLaunch = await StorageUtil.getBoolean(StorageConstants.IS_FIRST_LAUNCH, false);
    if (!isFirstLaunch) {
      this.showPrivacyDialog = true;
    } else {
      this.checkLoginStatus();
    }
  }

  // 检查登录状态
  private async checkLoginStatus() {
    const isLoggedIn = await StorageUtil.getBoolean(StorageConstants.IS_LOGGED_IN, false)
    if (isLoggedIn) {
      router.replace({ url: 'pages/tab/MainPage' })
    } else {
      router.replace({ url: 'pages/login/LoginPage' })
    }
  }
}