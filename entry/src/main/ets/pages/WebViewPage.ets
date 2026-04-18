import { webview } from '@kit.ArkWeb';
import router from '@ohos.router';
import { StatusBarUtil } from '../common/utils/StatusBarUtil';
import { NvBar } from '../components/NvBar';

@Entry
@Component
struct WebViewPage {
  private controller: webview.WebviewController = new webview.WebviewController();

  @State url: string = (router.getParams() as Record<string, string>)?.url || 'about:blank';
  @State title: string = '';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State progressValue: number = 0;

  onPageShow(): void {
    StatusBarUtil.setStatusBar('#ffffff', '#000000', false);
    // 启用 Web 调试（静态方法）
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  updateTitle() {
    try {
      const title = this.controller.getTitle();
      this.title = title && title.length > 0 ? title : '无标题';
      // console.info('===========页面标题:', this.title);
    } catch (error) {
      // console.error('==============获取标题失败:', error);
      this.title = '无标题';
    }
  }

  // 重新加载方法
  reloadPage() {
    this.isLoading = true;
    this.hasError = false;
    this.progressValue = 0;
    this.title = '重新加载中...';
    this.controller.refresh(); // 使用 refresh 而不是 reload
  }

  build() {
    Column() {
      NvBar({ title: this.title })

      // 加载进度条
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007DFF')
          Text('加载中...' + this.progressValue + '%')
            .fontSize(16)
            .margin({ left: 10 })
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      }

      Column() {
        Web({
          controller: this.controller,
          src: this.url
        })
          .width('100%')
          .height('100%')
          .javaScriptAccess(true)
          .domStorageAccess(true)  // 启用DOM存储
          .fileAccess(true)        // 启用文件访问
          .imageAccess(true)       // 启用图片访问
          .verticalScrollBarAccess(false)
          .onPageEnd(() => {
            // console.info('===============页面加载完成');
            this.isLoading = false;
            this.hasError = false;
            this.progressValue = 100;
            this.updateTitle();
          })
          .onPageBegin(() => {
            // console.info('=================开始加载页面');
            this.isLoading = true;
            this.hasError = false;
            this.progressValue = 0;
          })
          .onProgressChange((event) => {
            // 直接使用 event 对象，不访问 progress 属性
            // console.info('==================加载进度事件:', JSON.stringify(event));
            if (event) {
              // 根据实际情况调整进度值
              this.progressValue = Math.min(99, this.progressValue + 20);
              if (event.newProgress === 100) {
                this.isLoading = false;
                this.hasError = false;
                this.updateTitle();
              }
            }
          })
          // .onHttpErrorReceive(() => {
          //   console.error('================HTTP错误发生');
          //   this.title = '加载失败(HTTP错误)';
          //   this.isLoading = false;
          //   this.hasError = true;
          // })
          .onErrorReceive(() => {
            // console.error('=================页面错误发生');
            this.title = '加载失败';
            this.isLoading = false;
            this.hasError = true;
          })
      }
      .padding(10)
      .width('100%')
      .height('100%')

      // 错误状态页面
      if (this.hasError) {
        Column() {
          // 使用系统图标或文本代替图片
          Text('⚠️')
            .fontSize(60)
            .fontColor('#ff6b35')
          Text('页面加载失败')
            .fontSize(18)
            .fontColor('#666')
            .margin({ top: 20 })
          Text('请检查网络连接或稍后重试')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
          Button('重新加载')
            .width(120)
            .margin({ top: 20 })
            .onClick(() => {
              this.reloadPage();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .position({ x: 0, y: 0 })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .padding({bottom: 30})
  }
}