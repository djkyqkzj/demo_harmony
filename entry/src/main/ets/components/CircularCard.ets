import router from '@ohos.router';
import { LanguageUtils } from '../common/utils/LanguageUtils';
import { TagCard } from './TagCard';

@Component
struct CircularCard {
  private item: ESObject = {};
  private cardWidth: number = 0;
  private cardHeight: number = 0;
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Column(){
      Stack(){
        Image(this.item.cover_image)
          .alt($r('app.media.ZanyaDefaultImage'))
          .width(this.cardWidth)
          .height(this.cardHeight)
          .borderRadius(this.cardWidth / 2)
          .objectFit(ImageFit.Cover)

        TagCard({
          isHot: this.item.is_hot,
          isNew: this.item.is_new,
          isFree: this.item.is_free
        }).position({top: 0, left: 0})
      }
      .width(this.cardWidth)
      .height(this.cardHeight)

      Text(LanguageUtils.getSystemLanguage() === 'zh' ? this.item.title_cn : this.item.title_en)
        .fontColor('#000000')
        .fontSize(12)
        .fontWeight(500)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .margin({top: 15})

    }
    .width(this.cardWidth)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
        router.pushUrl({
          url: 'pages/music/MusicDetail',
          params: { musicDate: this.item}
        })
    })
  }
}

export { CircularCard };