import { EventBus } from "../common/utils/EventBus"
import { StorageConstants } from "../common/constants/StorageConstants"
import { FastToast } from "../common/utils/FastToast"
import { LanguageUtils } from "../common/utils/LanguageUtils"
import { isCheckin, journalCheckin, journalHistory, questionList } from "../common/http/Api"
import { TimeUtils } from "../common/utils/TimeUtils"

// 心情等级接口
interface JournalItem {
  title_cn: string
  title_en: string
  icon: Resource
  gIcon: Resource
}

// 心情历史数据接口
interface JournalHistory {
  id: number
  datetime: string
  feeling: number
}

// 心情答案数据接口
interface JournalAnswer {
  id: number
  answer: string
  question_id: number
}

// 心情数据总接口
interface JournalData {
  journal_history: JournalHistory[]
  journal_answers: JournalAnswer[]
  max_page: number
}

// 签到状态数据接口
interface CheckStatusData {
  is_checkin: boolean
  feeling: number | null
}

// 问题数据接口
interface QuestionData {
  id: number
  question_cn: string
  question_en: string
}

@Component
export struct CheckIn1Dialog {
  @State isShow: boolean = false
  @State pageType: string = "checkIn" // checkIn | readonly
  @State pageTitle: ResourceStr = ""
  @State selectKey: number = -1
  @State journalList: JournalItem[] = []
  @State journalData: JournalData = {
    journal_history: [],
    journal_answers: [],
    max_page: 0
  }
  @State page: number = 1
  @State @Watch('onLoadingChange') loading: boolean = false
  @State timeInterval: string = ""
  private language: string = LanguageUtils.getSystemLanguage()

  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.initJournalList()
    this.getCheckStatus()
    this.getJournalData(1)
    EventBus.listen<string>(StorageConstants.REFRESH, () => {
      console.log(StorageConstants.REFRESH)
      this.getJournalData(1)
    });
  }


  onPageShow(): void {

  }
  // 监听loading状态变化
  onLoadingChange(): void {
    console.log(`loading状态变化: ${this.loading}`)
  }

  aboutToDisappear(): void {

  }


  // 初始化心情列表
  private initJournalList(): void {
    this.journalList = [
      {
        title_cn: "糟糕",
        title_en: "Awful",
        icon: $r("app.media.j_1"),
        gIcon: $r("app.media.g_1")
      },
      {
        title_cn: "不好",
        title_en: "Bad",
        icon: $r("app.media.j_2"),
        gIcon: $r("app.media.g_2")
      },
      {
        title_cn: "一般",
        title_en: "Okay",
        icon: $r("app.media.j_3"),
        gIcon: $r("app.media.g_3")
      },
      {
        title_cn: "好",
        title_en: "Good",
        icon: $r("app.media.j_4"),
        gIcon: $r("app.media.g_4")
      },
      {
        title_cn: "很好",
        title_en: "Great",
        icon: $r("app.media.j_5"),
        gIcon: $r("app.media.g_5")
      }
    ]
  }

  // 显示弹窗
  async show(): Promise<void> {
    this.isShow = true
    this.loading = true

    try {
      await Promise.all([
        this.getCheckStatus(),
        this.getJournalData(1)
      ])
    } catch (error) {
      console.error('数据加载失败:', error)
    } finally {
      this.loading = false
    }
  }


  // 重置数据
  private resetData(): void {
    this.pageType = "checkIn"
    this.pageTitle = ""
    this.selectKey = -1
  }

  // 获取当前日期
  private getCurrentDate(): string {
    const date = new Date()
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 日期转星期或月-日
  private dateToWeek(time: string): string {
    const date = new Date(time)
    const dayOfWeek = date.getDay() // 0-6
    const weekDaysZn = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const weekDaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

    if (this.page === 1) {
      return this.language === "zh" ? weekDaysZn[dayOfWeek] : weekDaysEn[dayOfWeek]
    } else {
      return time.split('-').slice(1).join("-")
    }
  }

  // 判断是否为当前年份
  private isSameYearAsCurrent(date: string): boolean {
    const inputDate = new Date(date)
    const currentYear = new Date().getFullYear()
    return inputDate.getFullYear() === currentYear
  }

  // 格式化日期为年.月
  private formatDateToYearMonth(dateStr: string): string {
    const parts = dateStr.split('-')
    if (parts.length >= 2) {
      return `${parts[0]}.${parts[1]}`
    }
    return dateStr
  }

  // 获取时间区间
  private getTimeInterval(): string {
    if (!this.journalData.journal_history.length) return ""

    const firstDate = this.journalData.journal_history[0].datetime
    const lastDate = this.journalData.journal_history[6]?.datetime || firstDate

    let left = this.isSameYearAsCurrent(firstDate) ?
      firstDate.split('-').slice(1).join(".") :
      this.formatDateToYearMonth(firstDate)

    let right = this.isSameYearAsCurrent(lastDate) ?
      lastDate.split('-').slice(1).join(".") :
      this.formatDateToYearMonth(lastDate)

    return `${left} - ${right}`
  }

  // 获取签到状态
  private async getCheckStatus(): Promise<void> {
    try {
      const response = await isCheckin({
        date: this.getCurrentDate()
      })
      console.log(JSON.stringify(response),"getCheckStatus")

      if (response.code === 200) {

        const data = response.data as CheckStatusData
        const feelingText = this.language === "zh" ? "我感觉" : "I'm feeling"

        if (data.is_checkin) {
          this.selectKey = Number(data.feeling) - 1
          this.pageType = "readonly"
          const journalItem = this.journalList[Number(data.feeling) - 1]
          const title = this.language === "zh" ? journalItem.title_cn : journalItem.title_en
          this.pageTitle = `${feelingText} ${title}`
        } else {
          this.pageTitle = this.language === "zh" ? $r('app.string.howAreYouToday') : $r('app.string.howAreYouToday')
        }
      }
    } catch (error) {
      console.error('获取签到状态失败:', error)
      // 使用默认值
      this.pageTitle = this.language === "zh" ? $r('app.string.howAreYouToday') : $r('app.string.howAreYouToday')
    }
  }

  // 获取心情历史数据
  private async getJournalData(p: number): Promise<void> {
    try {
      const response = await journalHistory({
        page: p,
        start_date: this.getCurrentDate()
      })

      console.log(JSON.stringify(response),"getJournalData")

      if (response.code === 200) {
        this.page = p
        this.journalData = response.data as JournalData
        this.timeInterval = this.getTimeInterval()

        // 如果没有答案数据，获取问题列表作为默认显示
        if (this.journalData.journal_answers.length === 0) {
          await this.getQuestionList()
        }
      }
    } catch (error) {
      console.error('获取心情数据失败:', error)
    }
  }

  // 获取问题列表
  private async getQuestionList(): Promise<void> {
    try {
      const response = await questionList()

      if (response.code === 200 && response.data) {
        // 将问题转换为答案格式显示（供用户参考）
        const questionData = response.data as QuestionData[]
        const answers: JournalAnswer[] = []
        for (const question of questionData) {
          const answer: JournalAnswer = {
            id: question.id,
            answer: this.language === "zh" ? question.question_cn : question.question_en,
            question_id: question.id
          }
          answers.push(answer)
        }
        this.journalData.journal_answers = answers
      }
    } catch (error) {
      console.error('获取问题列表失败:', error)
    }
  }

  // 获取指定天数前的日期
  private getDateBefore(days: number): string {
    const date = new Date()
    date.setDate(date.getDate() - days)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 翻页功能
  private turnLeft(): void {
    if (this.page < this.journalData.max_page) {
      this.getJournalData(this.page + 1)
    }
  }

  private turnRight(): void {
    if (this.page > 1) {
      this.getJournalData(this.page - 1)
    }
  }

  // 心情选择
  private async selectMood(index: number): Promise<void> {
    if (this.pageType === "readonly") return

    try {
      const response = await journalCheckin({
        date: this.getCurrentDate(),
        feeling: index + 1
      })

      if (response.code === 200) {
        this.pageType = "readonly"
        this.selectKey = index
        const journalItem = this.journalList[index]
        const feeling = this.language === "zh" ? "我感觉" : "I'm feeling"
        const title = this.language === "zh" ? journalItem.title_cn : journalItem.title_en
        this.pageTitle = `${feeling} ${title}`

        // 重新获取数据
        await this.getJournalData(1)
        FastToast.showToast($r('app.string.checkinSuccess'))
        setTimeout(()=>{
          EventBus.send(StorageConstants.CHECK_IN2)
        },1500)


      } else {
        FastToast.showToast($r('app.string.operationFailedRetry'))
      }
    } catch (error) {
      console.error('心情选择失败:', error)
      FastToast.showToast($r('app.string.operationFailedRetry'))
    }
  }

  // 获取心情标题（国际化）
  private getMoodTitle(): ResourceStr {
    return $r('app.string.moodAnalysis')
  }

  // 获取心情影响因素标题
  private getMoodInfluencesTitle(): ResourceStr {
    return $r('app.string.moodInfluences')
  }

  // 获取本周/时间段文本
  private getTimeText(): ResourceStr {
    if (this.page === 1) {
      return $r('app.string.thisWeek')
    }
    return this.timeInterval
  }

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .onClick(() => {
          this.onClose()
        })


        // 主要内容区域
        Column() {

          if (this.loading) {
            // 加载骨架屏
            this.buildSkeletonView()
          } else {
            // 主要内容 - 添加滚动
            Scroll() {
              Column() {
                  // 标题
                  Text(this.pageTitle)
                    .fontColor('#000000')
                    .fontSize(18)
                    .fontWeight(500)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .margin({ bottom: 24 })

                  // 心情选择区域
                  this.buildMoodSelector()

                  // 心情历史记录
                  this.buildMoodHistory()

                  // 心情影响因素
                  this.buildMoodInfluences()
                }
                .padding({ left: 20, right: 20, bottom: 20 })
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('80%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 20, topRight: 20 })
        .padding({ top: 30, bottom: 20 })
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })

    }
    .width('100%')
    .height('100%')
    .zIndex(10)
  }

  // 构建骨架屏
  @Builder
  buildSkeletonView() {
    Column() {
      // 标题骨架
      Row()
        .width('60%')
        .height(24)
        .backgroundColor('#f0f0f0')
        .borderRadius(4)
        .alignSelf(ItemAlign.Center)
        .margin({ bottom: 24 })

      // 心情选择骨架
      Row() {
        ForEach([1, 2, 3, 4, 5], (item: number) => {
          Column() {
            Row()
              .width(42)
              .height(40)
              .backgroundColor('#f0f0f0')
              .borderRadius(20)
              .margin({ bottom: 12 })

            Row()
              .width(40)
              .height(14)
              .backgroundColor('#f0f0f0')
              .borderRadius(4)
          }
          .layoutWeight(1)
        })
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 48 })

      // 心情历史骨架
      Row()
        .width('80%')
        .height(20)
        .backgroundColor('#f0f0f0')
        .borderRadius(4)
        .margin({ bottom: 16 })

      // 模拟心情图表骨架
      Column() {
        ForEach([1, 2, 3, 4, 5], (item: number) => {
          Row() {
            ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
              Row()
                .width(32)
                .height(30)
                .backgroundColor('#f0f0f0')
                .borderRadius(4)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 8 })
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 构建心情选择器
  @Builder
  buildMoodSelector() {
    Row() {
      ForEach(this.journalList, (item: JournalItem, index: number) => {
        Column() {
          Image(this.selectKey === -1 ? item.icon : (this.selectKey === index ? item.icon : item.gIcon))
            .width(42)
            .height(40)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 12 })

          Text(this.language === "zh" ? item.title_cn : item.title_en)
            .fontColor(this.selectKey === -1 ? '#000000' : (this.selectKey === index ? '#000000' : 'rgba(0, 0, 0, 0.30)'))
            .fontSize(12)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.selectMood(index)
        })
      })
    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 48 })
  }

  // 构建心情历史记录
  @Builder
  buildMoodHistory() {
    Column() {
      // 时间选择器
      Row() {
        Text(this.getMoodTitle())
          .fontColor('#000000')
          .fontSize(16)
          .fontWeight(500)

        Row() {
          Text(this.getTimeText())
            .fontColor('#000000')
            .fontSize(12)
            .fontWeight(500)
            .margin({ right: 10 })

          Image($r('app.media.t_l'))
            .width(16)
            .height(16)
            .onClick(() => {
              this.turnLeft()
            })

          Image($r('app.media.t_r'))
            .width(16)
            .height(16)
            .onClick(() => {
              this.turnRight()
            })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#F6F6F6')
        .borderRadius(100)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })

      // 心情图表 - 从5到1的倒序
      ForEach([5, 4, 3, 2, 1], (feeling: number, rowIndex: number) => {
        Row() {
          ForEach(this.journalData.journal_history, (item: JournalHistory, index: number) => {
            if (item.feeling === feeling) {
              Image(this.journalList[feeling - 1].icon)
                .width(32)
                .height(30)
                .objectFit(ImageFit.Contain)
                .margin({top:7})
            } else {
              Row()
                .width(32)
                .height(30)
            }
          })
        }
        .width('100%')
        .height(30)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: rowIndex === 0 ? 0 : 8 })
        .border({
          width: { top:  1, left: 0, right: 0, bottom: 0 },
          color: '#F2F2F2'
        })
      })

      // 分隔线
      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#F2F2F2')
        .margin({ top: 12, bottom: 10 })

      // 星期标签
      Row() {
        ForEach(this.journalData.journal_history, (item: JournalHistory, index: number) => {
          Text(this.dateToWeek(item.datetime))
            .fontColor('#000000')
            .fontSize(11)
            .fontWeight(400)
            .width(32)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .height(30)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 0 ,bottom:8})
    }
    .width('100%')
  }

  // 构建心情影响因素
  @Builder
  buildMoodInfluences() {
    Column() {
      Text(this.getMoodInfluencesTitle())
        .fontColor('#000000')
        .fontSize(16)
        .fontWeight(500)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.journalData.journal_answers, (item: JournalAnswer, index: number) => {
          Text(item.answer)
            .fontColor('#000000')
            .fontSize(12)
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#F2F2F2' })
            .borderRadius(24)
            .textAlign(TextAlign.Center)
            .margin({ right: (index + 1) % 3 === 0 ? 0 : '5%', bottom: 8 })
            .onClick(() => {
              // 可以添加点击事件
            })
        })
      }
      .width('100%')
    }
    .width('100%')
  }
}