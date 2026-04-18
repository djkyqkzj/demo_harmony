import { LanguageUtils } from '../../common/utils/LanguageUtils';

@Entry
@Component
export struct home {
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Column() {
      Column() {
        Text(this.language === 'zh' ? '首页框架' : 'Home Template')
          .fontColor('#2A2624')
          .fontSize(26)
          .fontWeight(700)
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.language === 'zh'
          ? '保留顶部结构、内容分区和视觉节奏，方便直接改造成新项目首页。'
          : 'This keeps the hero layout and section rhythm as a starter home screen for a new project.')
          .fontColor('rgba(42, 38, 36, 0.65)')
          .fontSize(14)
          .margin({ top: 8 })
          .width('100%')
      }
      .padding({ left: 20, right: 20, top: 24 })

      Scroll() {
        Column() {
          Column() {
            Text(this.language === 'zh' ? 'Hero 区域' : 'Hero Section')
              .fontSize(18)
              .fontWeight(600)
              .fontColor('#2A2624')
              .width('100%')
              .textAlign(TextAlign.Start)

            Text(this.language === 'zh'
              ? '这里适合放品牌主视觉、欢迎语和主操作按钮。'
              : 'Use this area for branding, welcome copy, and the primary CTA.')
              .fontSize(14)
              .fontColor('rgba(42, 38, 36, 0.65)')
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F4EEEA')
          .borderRadius(24)

          Column() {
            Text(this.language === 'zh' ? '功能入口' : 'Quick Actions')
              .fontSize(18)
              .fontWeight(600)
              .fontColor('#2A2624')
              .width('100%')
              .textAlign(TextAlign.Start)

            Text(this.language === 'zh'
              ? '原项目的频道、推荐、专题位已经清空，可替换成你的业务模块。'
              : 'The old channel and recommendation logic is removed. Replace it with your own modules.')
              .fontSize(14)
              .fontColor('rgba(42, 38, 36, 0.65)')
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ top: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(24)

          Column() {
            Text(this.language === 'zh' ? '内容列表占位' : 'Content Placeholder')
              .fontSize(18)
              .fontWeight(600)
              .fontColor('#2A2624')
              .width('100%')
              .textAlign(TextAlign.Start)

            Text(this.language === 'zh'
              ? '组件和弹框文件仍保留在工程中，后续按需重新接回这里即可。'
              : 'Component and dialog files remain in the project and can be reconnected here later.')
              .fontSize(14)
              .fontColor('rgba(42, 38, 36, 0.65)')
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ top: 16, bottom: 24 })
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF8F6')
  }
}
