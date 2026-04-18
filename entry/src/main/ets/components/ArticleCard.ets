import router from '@ohos.router';
import { DisplayUtil } from '../common/utils/DisplayUtil';
import { LanguageUtils } from '../common/utils/LanguageUtils';
import { TagCard } from './TagCard';

@Component
struct ArticleCard {
  private item: ESObject = {};
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Column(){
      Image(this.item.cover_image).alt($r('app.media.ZanyaDefaultImage'))
        .width('100%')
        .objectFit(ImageFit.Cover)
        .height((DisplayUtil.getScreenWidth() -40)/7*3)
        .borderRadius(12)

      Column() {
        Row(){
          TagCard({
            isHot: this.item.is_hot,
            isNew: this.item.is_new,
            isFree: this.item.is_free
          })
            .margin({right: 6})

          Text(LanguageUtils.getSystemLanguage()=== 'zh' ? this.item.title_cn : this.item.title_en)
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
        }
        .width('100%')

        Text(LanguageUtils.getSystemLanguage()=== 'zh' ? this.item.description_cn : this.item.description_en)
          .fontColor('rgba(0, 0, 0, 0.7)')
          .fontSize(12)
          .fontWeight(400)
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)
          .margin({top: 5})

        Row(){
          Image($r('app.media.eye'))
            .width(14)
            .height(14)

          Text(this.item.count + '')
            .fontColor('#A69B97')
            .fontSize(12)
            .fontWeight(500)
            .margin({left: 4})

          Image(this.item.favorited === 1 ? $r('app.media.icon_heart_fill') : $r('app.media.icon_heart'))
            .width(14)
            .height(14)
            .margin({left: 20})

          Text(this.item.favorite_count + '')
            .fontColor('#A69B97')
            .fontSize(12)
            .fontWeight(500)
            .margin({left: 4})
        }
        .width('100%')
        .margin({top: 5})
      }
      .margin({left: 6, top: 10})
    }
    .onClick(() => {
      router.pushUrl({
        url: 'pages/article/ArticleDetail',
        params: { articleDate: this.item}
      })
    })
  }
}

export { ArticleCard };