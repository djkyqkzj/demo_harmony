import { LanguageUtils } from "../common/utils/LanguageUtils"
import { getPlayListApi } from '../common/http/Api'
import { Music, Play, Tag } from "../common/constants/Model";
import globalPlayerStore from "../common/constants/GlobalPlayerStore";
import { TimeUtils } from "../common/utils/TimeUtils";
import { CircularCard } from "../components/CircularCard";
import { AddEvent } from "../common/http/addEvent";

@Component
struct MusicModal {
  @State playDate: Music = {}
  private language: string = LanguageUtils.getSystemLanguage()
  @State playerUri: string = globalPlayerStore.playerUri;
  @State playListInfo: Music = globalPlayerStore.playListInfo;
  @State playing: boolean = globalPlayerStore.playing;
  @State tagId: number = 0;
  @State page: number = 1;
  @State contentList: Music[] = [];
  @State hasMore: boolean = false;
  onChange: (index: number) => void = () => {
  }
  onClose: () => void = () => {
  }

  aboutToAppear(): void {
    this.contentList = []
    this.page = 1
    this.getPlayList()
  }

  private isSameSong(filePath1: string | number | undefined, filePath2: string | number | undefined) {
    if (this.playDate.id !== this.playListInfo.id) {
      return false;
    }

    if (!filePath1 || !filePath2) {
      return false;
    }

    try {
      const fileName1 = this.getFileNameId(filePath1);
      const fileName2 = this.getFileNameId(filePath2);
      if (!fileName1 || !fileName2 || fileName1 == 'undefined' || fileName2 == 'undefined') {
        return false;
      }

      return fileName1 === fileName2;
    } catch (error) {
      return false;
    }
  }

  private getFileNameId(filePath: string | number | undefined) {
    if (!filePath) {
      return '';
    }

    // 如果是数字类型，直接转换为字符串返回
    if (typeof filePath === 'number') {
      return String(filePath);
    }

    // 如果不是字符串类型，返回空
    if (typeof filePath !== 'string') {
      return '';
    }

    try {
      if (filePath.startsWith("file://")) {
        const number2 = filePath.match(/\d+(?=\.mp3)/)?.[0];
        return number2 || '';
      } else if (filePath.startsWith("http://") || filePath.startsWith("https://")) {
        //说明是在线地址 从playListInfo中去取歌曲id
        const songId = this.playListInfo?.musics?.find((item: Play) => item?.music_address_2 === filePath)?.id;
        return String(songId) || '';
      } else {
        return filePath;
      }
    } catch (error) {
      return '';
    }
  }

  private async handleTag(tag: Tag) {
    this.tagId = tag.id!
    this.contentList = []
    this.page = 1
    this.getPlayList()
  }

  private async getPlayList() {
    const res = await getPlayListApi({
      playlist_id: this.playDate.id,
      tag_id: this.tagId,
      page: this.page,
      page_size: 21
    })
    if (res.code === 200) {
      if (res?.data?.list?.length < 21) {
        this.hasMore = false
      } else {
        this.hasMore = true
      }
      if (res.data?.list?.length > 0) {
        this.page = this.page + 1
        if (this.page === 1) {
          this.contentList = res?.data.list
        } else {
          this.contentList = this.contentList.concat(res?.data.list || []);
        }
      }
    }
  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')

      Column() {
        Row() {
          Text($r('app.string.playlist'))
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#8D8481')

          Image($r('app.media.icon_close1'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.onClose()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        List() {
          ForEach(this.playDate.musics, (item: Play, index: number) => {
            ListItem() {
              Row() {
                if (this.playerUri && (this.isSameSong(this.playerUri, item.music_address_2) ||
                this.isSameSong(this.playerUri, item.local_music_address_2)
                  || this.isSameSong(this.playerUri, item.id))) {
                  Image(this.playing ? $r('app.media.playing') : $r('app.media.soundwave'))
                    .width(30)
                    .height(30)
                    .margin({ right: 6 })
                }

                Text(item.name)
                  .fontColor('#000000')
                  .fontSize(14)
                  .fontWeight(500)
                  .maxLines(1)
                  .layoutWeight(1)
                  .margin({ right: 6 })
                  .ellipsisMode(EllipsisMode.END)

                Text(TimeUtils.timestampToDateTime(item.source_duration!,
                  item.source_duration! >= 3600000 ? "HH:mm:ss" : "mm:ss"))
                  .fontColor('rgba(0, 0, 0, 0.3)')
                  .fontSize(14)
                  .fontWeight(400)

              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .padding({ top: 8, bottom: 8 })
              .onClick(() => {
                AddEvent.addClickEvent("playlist_song_list_click",  { target_id: item.id }, "playlist_detail", "playlist_detail")
                this.onChange(index)
              })
            }
          })
        }
        .width('100%')
        .margin({ top: 10 })
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Text($r('app.string.more'))
          .fontSize(14)
          .fontWeight(500)
          .width('100%')
          .margin({ top: 10 })
          .textAlign(TextAlign.Start)
          .fontColor('#8D8481')
        Column() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.playDate.tags, (tag: Tag) => {
              Text(this.language === 'zh' ? tag.name_cn : tag.name_en)
                .fontSize(12)
                .fontColor(tag.id === this.tagId ? '#ffffff' : '#8D8481')
                .backgroundColor(tag.id === this.tagId ? '#A69B97' : 'rgba(166, 155, 151, 0.1)')
                .borderRadius(100)
                .padding({
                  left: 12,
                  right: 12,
                  top: 4,
                  bottom: 4
                })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.handleTag(tag)
                })
            })
          }
          .width('100%')
          .margin({ top: 12 })

          List() {
            ListItem() {
              Column() {
                if (this.contentList.length > 0) {
                  Grid() {
                    ForEach(this.contentList, (item: Music) => {
                      GridItem() {
                        CircularCard({
                          item: item, cardWidth: 98, cardHeight: 98
                        })
                      }
                    })
                  }
                  .columnsTemplate('1fr 1fr 1fr')
                  .rowsGap(10)
                  .columnsGap(10)
                  .width('100%')
                }

                if (!this.hasMore) {
                  Text($r('app.string.noMore'))
                    .fontSize(14)
                    .fontColor('rgba(0, 0, 0, 0.3)')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .padding(15)
                    .margin({ bottom: 10, top: 10 })
                }
              }
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .onReachEnd(() => {
            if (this.contentList.length > 0) {
              this.getPlayList();
            }
          })
        }
        .width('100%')
        .layoutWeight(1)

      }
      .width('100%')
      .height('85%')
      .padding(20)
      .margin({ bottom: 60 })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 20, topRight: 20 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
    }
    .width('100%')
    .height('100%')
    .zIndex(10)
  }
}

export { MusicModal }