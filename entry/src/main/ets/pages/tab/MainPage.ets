import { StatusBarUtil } from '../../common/utils/StatusBarUtil'
import { home } from './home'
import { library } from './library'
import { search } from './search'
import { TabItem } from '../../common/constants/Model'
import { LanguageUtils } from '../../common/utils/LanguageUtils'

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0
  @State @Watch('onLanguageChange') currentLanguage: string = 'zh'
  @State tabs: TabItem[] = []
  @State tabRefreshKey: number = 0
  private controller: TabsController = new TabsController()

  onPageShow(): void {
    StatusBarUtil.setStatusBar('#ffffff', '#000000', false);
    this.currentLanguage = LanguageUtils.getSystemLanguage();
    this.initTabs();
  }

  private initTabs(): void {
    this.tabs = [
      {
        name: this.currentLanguage == 'zh' ? '清屿' : 'Home',
        selectedIcon: $r('app.media.home_active'),
        unselectedIcon: $r('app.media.home'),
        page: 'HomePage'
      },
      {
        name: this.currentLanguage == 'zh' ? '心界' : 'Library',
        selectedIcon: $r('app.media.library_active'),
        unselectedIcon: $r('app.media.library'),
        page: 'LibraryPage'
      },
      {
        name: this.currentLanguage == 'zh' ? '寻悟' : 'Discover',
        selectedIcon: $r('app.media.search_active'),
        unselectedIcon: $r('app.media.search'),
        page: 'SearchPage'
      }
    ];
  }

  onLanguageChange(): void {
    this.tabRefreshKey += 1;
    this.initTabs();
  }

  @Builder
  TabBarItem(item: TabItem, index: number) {
    Row() {
      Image(this.currentIndex === index ? item.selectedIcon : item.unselectedIcon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .opacity(this.currentIndex === index ? 1 : 0.6)

      Text(item.name || '')
        .fontSize(14)
        .fontWeight(600)
        .fontColor(this.currentIndex === index ? '#ffffff' : 'rgba(0, 0, 0, 0.6)')
        .margin({ left: 4 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.currentIndex === index ? '#A69B97' : '')
    .margin({ top: 10 })
    .borderRadius(100)
    .padding({ top: 5, bottom: 5, left: 20, right: 20 })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.controller,
        index: this.currentIndex
      }) {
        ForEach(this.tabs, (item: TabItem) => {
          TabContent() {
            if (item.page === 'HomePage') {
              home()
            } else if (item.page === 'LibraryPage') {
              library()
            } else {
              search()
            }
          }
          .tabBar('')
        }, (item: TabItem) => item.page + '_' + this.tabRefreshKey)
      }
      .barMode(BarMode.Fixed)
      .barWidth(0)
      .barHeight(0)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .layoutWeight(1)

      Row() {
        ForEach(this.tabs, (item: TabItem, index: number) => {
          Column() {
            this.TabBarItem(item, index)
          }
          .width('33.3%')
          .height(50)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.currentIndex = index
            this.controller.changeIndex(index)
          })
        }, (item: TabItem) => item.page + '_' + this.tabRefreshKey)
      }
      .width('100%')
      .height(50)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 5,
        color: '#F1F1F1',
        offsetX: 0,
        offsetY: -2
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
