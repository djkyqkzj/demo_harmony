import router from '@ohos.router';
import { AddEvent } from '../common/http/addEvent';
import { LanguageUtils } from '../common/utils/LanguageUtils';
import { TimeUtils } from '../common/utils/TimeUtils';
import { TagCard } from './TagCard';

@Component
struct MusicCard {
  private item: ESObject = {};
  private language: string = LanguageUtils.getSystemLanguage()

  build() {
    Row(){
      Image(this.item.cover_image)
        .alt($r('app.media.ZanyaDefaultImage'))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(40)

      Column() {
        Row(){
          TagCard({
            isHot: this.item.is_hot,
            isNew: this.item.is_new,
            isFree: this.item.is_free
          })

          Text(LanguageUtils.getSystemLanguage() === 'zh' ? this.item.title_cn : this.item.title_en)
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
            .layoutWeight(1)
        }
        .width('100%')

        Text(LanguageUtils.getSystemLanguage() === 'zh' ? this.item.description_cn : this.item.description_en)
          .fontColor('rgba(0, 0, 0, 0.7)')
          .fontSize(12)
          .fontWeight(400)
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)
          .margin({top: 5})
          .width('100%')

        Row(){
          Image($r('app.media.icon_clockhistory'))
            .width(14)
            .height(14)

          Text(TimeUtils.timestampToDateTime(this.item.duration, this.item.duration >= 3600000 ? "HH:mm:ss" : "mm:ss"))
            .fontColor('#A69B97')
            .fontSize(12)
            .fontWeight(500)
            .margin({left: 4})

          Image($r('app.media.icon_soundwave'))
            .width(14)
            .height(14)
            .margin({left: 20})

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
      .margin({left: 6})
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .onClick(() => {
      AddEvent.addClickEvent("playlist_click",  { target_id: this.item.id, target_type: this.item.content_type, target_name: LanguageUtils.getSystemLanguage() === 'zh' ? this.item.title_cn : this.item.title_en }, "home", "home")
      router.pushUrl({
        url: 'pages/music/MusicDetail',
        params: { musicDate: this.item}
      })
    })
  }
}

export { MusicCard };