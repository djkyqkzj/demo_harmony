import { LanguageUtils } from '../../common/utils/LanguageUtils';

@Entry
@Component
export struct library {
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Column() {
      Text(this.language === 'zh' ? '功能页框架' : 'Feature Template')
        .fontColor('#2A2624')
        .fontSize(26)
        .fontWeight(700)
        .margin({ top: 24 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.language === 'zh'
        ? '适合作为我的、资源库、工作台这类二级主页面。'
        : 'A reusable shell for profile, library, or workspace-style tabs.')
        .fontColor('rgba(42, 38, 36, 0.65)')
        .fontSize(14)
        .margin({ top: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Column() {
        Text(this.language === 'zh' ? '模块区 01' : 'Module 01')
          .fontSize(18)
          .fontWeight(600)
          .fontColor('#2A2624')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.language === 'zh'
          ? '原来的收藏、下载、最近播放已经移除，建议在这里替换成你的常用业务入口。'
          : 'The old collection and download logic is removed. Use this area for your primary shortcuts.')
          .fontSize(14)
          .fontColor('rgba(42, 38, 36, 0.65)')
          .margin({ top: 8 })
          .width('100%')
      }
      .width('100%')
      .padding(20)
      .margin({ top: 24 })
      .backgroundColor('#FFFFFF')
      .borderRadius(24)

      Column() {
        Text(this.language === 'zh' ? '模块区 02' : 'Module 02')
          .fontSize(18)
          .fontWeight(600)
          .fontColor('#2A2624')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.language === 'zh'
          ? '保留了页面层级、留白和卡片感，方便继续往里塞列表、卡片和设置项。'
          : 'The spacing and card structure stay intact so you can add lists, cards, or settings later.')
          .fontSize(14)
          .fontColor('rgba(42, 38, 36, 0.65)')
          .margin({ top: 8 })
          .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)
      .margin({ top: 16, bottom: 24 })
      .backgroundColor('#F4EEEA')
      .borderRadius(24)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FAF8F6')
  }
}
