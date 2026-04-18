import { LanguageUtils } from "../../common/utils/LanguageUtils"

@Entry
@Component
export struct search {
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Column() {
      Text(this.language === 'zh' ? '发现页框架' : 'Discover Template')
        .fontColor('#2A2624')
        .fontSize(26)
        .fontWeight(700)
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 24 })

      Text(this.language === 'zh'
        ? '保留搜索入口和探索式页面结构，原有频道与热门内容业务已移除。'
        : 'The discovery layout remains, while the original channel and popular-content logic is removed.')
        .fontColor('rgba(42, 38, 36, 0.65)')
        .fontSize(14)
        .margin({ top: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Column() {
        Text(this.language === 'zh' ? '搜索入口' : 'Search Entry')
          .fontSize(18)
          .fontWeight(600)
          .fontColor('#2A2624')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.language === 'zh'
          ? '后续可以在这里接你的搜索页、筛选页或推荐词模块。'
          : 'Connect your search flow, filters, or suggestion modules here later.')
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
        Text(this.language === 'zh' ? '推荐区域占位' : 'Recommendation Area')
          .fontSize(18)
          .fontWeight(600)
          .fontColor('#2A2624')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.language === 'zh'
          ? '如果新项目需要瀑布流、专题、标签云，可以从这里继续扩展。'
          : 'Extend this area into a feed, topics, or tag cloud if the new project needs discovery.')
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
    .padding(20)
    .backgroundColor('#FAF8F6')
  }
}
