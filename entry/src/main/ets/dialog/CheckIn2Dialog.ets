import { Music } from "../common/constants/Model"
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { LanguageUtils } from "../common/utils/LanguageUtils";
import HttpRequest from "../common/http/HttpRequest";
import { StorageConstants } from "../common/constants/StorageConstants";
import { FastToast } from "../common/utils/FastToast";
import { getShareImgApi, isCheckin, questionList, answerQuestions, AnswerQuestionsParams } from '../common/http/Api';
import { JSON } from "@kit.ArkTS";
import fs from '@ohos.file.fs';
import { EventBus } from "../common/utils/EventBus";

// 心情等级接口
interface JournalItem {
  title_cn: string
  title_en: string
  icon: Resource
  gIcon: Resource
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
  answer: string
}

// 答案映射接口
interface AnswerMapping {
  question_id: string | number
  answer_id: number
}

// HTTP响应接口
interface HttpResponse {
  code: number | string
  message: string
  data: ESObject
  list: ESObject
}

@Component
struct CheckIn2Dialog {
  @State date: Music = {}
  @State type: number = 0
  @State shareImg: string = ''
  private language: string = LanguageUtils.getSystemLanguage()
  @State isShowPoster: boolean = false
  @State question_id: string | number = ''

  // 签到状态相关状态
  @State pageTitle1: ResourceStr = ""
  @State pageTitle2: ResourceStr = ""
  @State isCheckin: boolean = false
  @State journalList: JournalItem[] = []

  // 问题列表相关状态
  @State questionList: QuestionData[] = []
  @State selectedQuestionIds: number[] = []

  onClose: () => void = () => {
  }



  aboutToAppear(): void {
    this.initJournalList()
    this.getCheckStatus()
    this.getQuestionList()
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

  // 获取当前日期
  private getCurrentDate(): string {
    const date = new Date()
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 获取签到状态
  private async getCheckStatus(): Promise<void> {
    try {
      const response = await isCheckin({
        date: this.getCurrentDate()
      })

      if (response.code === 200) {
        const data = response.data as CheckStatusData
        const feelingText = this.language === "zh" ? "我感觉" : "I'm feeling"

        if (data.is_checkin && data.feeling) {
          this.isCheckin = true
          const journalItem = this.journalList[Number(data.feeling) - 1]
          const title = this.language === "zh" ? journalItem.title_cn : journalItem.title_en
          this.pageTitle1 = feelingText
          this.pageTitle2 = title
        } else {
          this.isCheckin = false
          this.pageTitle1 = ''
          this.pageTitle2 = ''
        }
      } else {
        this.pageTitle1 = ''
        this.pageTitle2 = ''
      }
    } catch (error) {
      console.error('获取签到状态失败:', error)
    }
  }

  // 获取问题列表
  private async getQuestionList(): Promise<void> {
    try {
      const response = await questionList()

      console.log(JSON.stringify(response), "getQuestionList")

      if (response.code === 200 && response.data) {
        this.questionList = response.data[0]['answers'] as QuestionData[]
        this.question_id = response.data[0].id
      }
    } catch (error) {
      console.error('获取问题列表失败:', error)
    }
  }

  // 切换问题选择状态
  private toggleQuestionSelection(questionId: number): void {
    const index = this.selectedQuestionIds.indexOf(questionId)
    if (index > -1) {
      // 已选中，取消选择
      this.selectedQuestionIds.splice(index, 1)
    } else {
      // 未选中，检查是否已选满5个
      if (this.selectedQuestionIds.length < 5) {
        this.selectedQuestionIds.push(questionId)
      } else {
        FastToast.showToast(this.language === "zh" ? "最多选择5个问题" : "Maximum 5 questions can be selected")
      }
    }
    console.log('当前选中的问题IDs:', this.selectedQuestionIds)
  }

  // 检查问题是否被选中
  private isQuestionSelected(questionId: number): boolean {
    return this.selectedQuestionIds.indexOf(questionId) > -1
  }

  // 提交答案
  private async submitAnswers(): Promise<void> {
    try {

      const answerMapping: AnswerMapping[] = []
      for (const i of this.selectedQuestionIds) {
        const mapping: AnswerMapping = {
          question_id: this.question_id,
          answer_id: i
        }
        answerMapping.push(mapping)
      }

      const answerParams: AnswerQuestionsParams = {
        answers: answerMapping,
        date: this.getCurrentDate()
      }
      const response = await answerQuestions(answerParams)
      if (response.code === 200) {
        EventBus.send(StorageConstants.REFRESH)
        FastToast.showToast(this.language === "zh" ? "提交成功" : "Submit successful")
        this.onClose()
      } else {
        FastToast.showToast(this.language === "zh" ? "提交失败" : "Submit failed")
      }
    } catch (error) {
      console.error('提交答案失败:', JSON.stringify(error))
      FastToast.showToast(this.language === "zh" ? "提交失败" : "Submit failed")
    }
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
          // 关闭按钮
          Row() {
            Image($r('app.media.close'))
              .width(56)
              .height(40)
              .onClick(() => { this.onClose() })
          }
          .width("100%")
          .justifyContent(FlexAlign.End)

          // 标题区域
          Text(this.pageTitle1)
            .fontColor('#000000')
            .fontSize(12)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 5 })

          Text(this.pageTitle2)
            .fontColor('#000000')
            .fontSize(32)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 24 })

          Text("什么对你影响最大？")
            .fontColor('#000000')
            .fontSize(14)
            .fontWeight(500)
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ bottom: 16 })

          // 问题列表滚动区域
          Scroll() {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(this.questionList, (item: QuestionData, index: number) => {
                Text(item.answer)
                  .width("30%")
                  .fontColor(this.isQuestionSelected(item.id) ? '#FFFFFF' : '#000000')
                  .fontSize(12)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 12, bottom: 12, left: 16, right: 16 })
                  .border({
                    width: 1,
                    color: this.isQuestionSelected(item.id) ? '#A69B97' : '#F2F2F2'
                  })
                  .borderRadius(24)
                  .backgroundColor(this.isQuestionSelected(item.id) ? '#A69B97' : '#FFFFFF')
                  .margin({ right: (index + 1) % 3 === 0 ? 0 : 8, bottom: 8 })
                  .onClick(() => {
                    this.toggleQuestionSelection(item.id)
                  })
              })
            }
            .width('100%')
            .padding({ bottom: 80 }) // 为底部按钮留空间
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .width('100%')
          .layoutWeight(1) // 占用剩余空间

          Text('提交')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
            .width('100%')
            .height(50)
            .backgroundColor(this.selectedQuestionIds.length > 0 ? '#A69B97' : '#CCCCCC')
            .borderRadius(25)
            .onClick(() => {
              if (this.selectedQuestionIds.length > 0) {
                this.submitAnswers()
              } else {
                FastToast.showToast(this.language === "zh" ? "请至少选择一个问题" : "Please select at least one question")
              }
          })

        }
          .width('100%')
          .height('60%')
          .padding(20)
          .backgroundColor("#fff")
          .borderRadius({ topLeft: 20, topRight: 20 })

          .position({ x: 0, y: '100%' })
          .translate({ y: '-95%' })
    }
    .width('100%')
    .height('100%')
    .zIndex(11)
  }
}

export { CheckIn2Dialog }