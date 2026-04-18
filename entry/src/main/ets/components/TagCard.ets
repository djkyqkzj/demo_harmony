import { LanguageUtils } from "../common/utils/LanguageUtils";

interface TagInfo {
  tagText: string;
  bgColor: string;
}

@Component
struct TagCard {
  private isHot: number = 0;
  private isNew: number = 0;
  private isFree: number = 0;

  private getTagInfo(): TagInfo {
    const language = LanguageUtils.getSystemLanguage()
    const result: TagInfo = { tagText: '', bgColor: '' };

    if (this.isFree === 1) {
      result.tagText = language === 'zh' ? '免费' : 'Free';
      result.bgColor = '#34A353';
    } else if (this.isNew === 1) {
      result.tagText = language === 'zh' ? '最新' : 'New';
      result.bgColor = '#E85500';
    } else if (this.isHot === 1) {
      result.tagText = language === 'zh' ? '热门' : 'Hot';
      result.bgColor = '#A69B97';
    }

    return result;
  }

  build() {
    if (this.isFree === 1 || this.isHot === 1 || this.isNew === 1) {
      Row() {
        Text(this.getTagInfo().tagText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .fontFamily('HarmonyOS Sans')
      }
      .borderRadius(6)
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .margin({right: 6})
      .backgroundColor(this.getTagInfo().bgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .zIndex(10)
    }
  }
}

export { TagCard };