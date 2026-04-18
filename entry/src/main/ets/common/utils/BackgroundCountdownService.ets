import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import reminderAgentManager from '@ohos.reminderAgentManager';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

interface BackgroundTaskInfo {
  requestId: number;
  actualDelayTime: number;
}

interface CountdownStatus {
  isRunning: boolean;
  countdownTime: number;
  remainingTime: number;
}

export class BackgroundCountdownService {
  private countdownTime: number = 0; // 倒计时总秒数
  private remainingTime: number = 0; // 剩余秒数
  private isRunning: boolean = false;
  private startTime: number = 0;
  private context: common.UIAbilityContext;
  private continuousTaskId: number = 0;
  private countdownInterval: number | null = null;
  private delaySuspendInfo: backgroundTaskManager.DelaySuspendInfo | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // 开始倒计时
  async startCountdown(seconds: number): Promise<void> {
    if (this.isRunning) {
      this.stopCountdown();
    }

    this.countdownTime = seconds;
    this.remainingTime = seconds;
    this.startTime = new Date().getTime();
    this.isRunning = true;

    // 申请持续任务
    await this.requestContinuousTask();

    // 开始倒计时循环
    this.startCountdownLoop();
  }

  // 申请后台持续任务
  private async requestContinuousTask(): Promise<void> {
    try {
      // 检查是否已有任务在运行
      if (this.delaySuspendInfo) {
        await this.stopContinuousTask();
      }

      this.delaySuspendInfo = await backgroundTaskManager.requestSuspendDelay(
        'CountdownTask',
        () => {
          // console.log('=======应用即将挂起，倒计时将继续在后台运行');
          // 这里可以保存倒计时状态，确保应用被挂起后能恢复
        }
      );

      // 保存请求ID
      this.continuousTaskId = this.delaySuspendInfo.requestId;
      // console.log('=======后台任务申请成功, ID:', this.continuousTaskId);
    } catch (error) {
      console.error('=======后台任务申请失败:', error);
    }
  }

  // 停止后台任务
  private async stopContinuousTask(): Promise<void> {
    try {
      if (this.delaySuspendInfo) {
        backgroundTaskManager.cancelSuspendDelay(this.delaySuspendInfo.requestId);
        this.delaySuspendInfo = null;
        this.continuousTaskId = 0;
        // console.log('=======后台任务已停止');
      }
    } catch (error) {
      console.error('=======停止后台任务失败:', error);
    }
  }

  // 倒计时循环
  private startCountdownLoop(): void {
    // 清除之前的定时器
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
    }

    this.countdownInterval = setInterval(() => {
      if (!this.isRunning) {
        if (this.countdownInterval) {
          clearInterval(this.countdownInterval);
          this.countdownInterval = null;
        }
        return;
      }

      const currentTime = new Date().getTime();
      const elapsedSeconds = Math.floor((currentTime - this.startTime) / 1000);
      this.remainingTime = Math.max(0, this.countdownTime - elapsedSeconds);

      // console.log(`=======倒计时剩余: ${this.remainingTime}秒`);

      // 更新通知
      // this.updateNotification();

      // 检查是否结束
      if (this.remainingTime <= 0) {
        this.isRunning = false;
        if (this.countdownInterval) {
          clearInterval(this.countdownInterval);
          this.countdownInterval = null;
        }
        this.onCountdownFinished();
        this.stopContinuousTask();
      }
    }, 1000) as number;
  }

  // 停止倒计时
  stopCountdown(): void {
    this.isRunning = false;
    this.remainingTime = 0;

    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
      this.countdownInterval = null;
    }

    this.stopContinuousTask();
    // console.log('=======倒计时已停止');
  }

  // 暂停倒计时
  pauseCountdown(): void {
    this.isRunning = false;
    // console.log('=======倒计时已暂停');
  }

  // 继续倒计时
  resumeCountdown(): void {
    if (this.remainingTime > 0 && !this.isRunning) {
      this.isRunning = true;
      this.startTime = new Date().getTime() - (this.countdownTime - this.remainingTime) * 1000;
      this.startCountdownLoop();
      // console.log('=======倒计时已继续');
    }
  }

  // 获取剩余时间
  getRemainingTime(): number {
    return this.remainingTime;
  }

  // 获取格式化时间
  getFormattedTime(): string {
    const hours = Math.floor(this.remainingTime / 3600);
    const minutes = Math.floor((this.remainingTime % 3600) / 60);
    const seconds = this.remainingTime % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  // 更新通知
  private async updateNotification(): Promise<void> {
    try {
      const reminderRequest: reminderAgentManager.ReminderRequest = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
        timeInterval: Math.floor(Date.now() / 1000) + this.remainingTime,
        actionButton: [
          {
            title: '停止',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ],
        wantAgent: {
          pkgName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        },
        notificationId: 1001,
        title: '倒计时',
        content: `剩余时间: ${this.getFormattedTime()}`,
        expiredContent: '倒计时结束',
      };

      // 发布或更新提醒
      await reminderAgentManager.publishReminder(reminderRequest);
    } catch (error) {
      console.error('=======更新通知失败:', error);
    }
  }

  // 倒计时结束处理
  private onCountdownFinished(): void {
    // console.log('=======倒计时结束');

    // 发送结束通知
    // this.sendFinishedNotification();

    // 触发结束回调
    if (this.onFinishedCallback) {
      this.onFinishedCallback();
    }
  }

  // 发送结束通知
  private async sendFinishedNotification(): Promise<void> {
    try {
      const reminderRequest: reminderAgentManager.ReminderRequest = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
        timeInterval: Math.floor(Date.now() / 1000),
        actionButton: [
          {
            title: '确定',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ],
        wantAgent: {
          pkgName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        },
        notificationId: 1002,
        title: '倒计时结束',
        content: '设定的时间已经到了！',
        expiredContent: '倒计时结束',
      };

      await reminderAgentManager.publishReminder(reminderRequest);
    } catch (error) {
      console.error('=======发送结束通知失败:', error);
    }
  }

  // 回调函数
  private onFinishedCallback?: () => void;

  // 设置结束回调
  setOnFinishedCallback(callback: () => void): void {
    this.onFinishedCallback = callback;
  }

  // 清理资源
  destroy(): void {
    this.stopCountdown();
    this.onFinishedCallback = undefined;
  }

  // 获取后台任务状态
  getBackgroundTaskInfo(): BackgroundTaskInfo | null {
    if (this.delaySuspendInfo) {
      const taskInfo: BackgroundTaskInfo = {
        requestId: this.delaySuspendInfo.requestId,
        actualDelayTime: this.delaySuspendInfo.actualDelayTime
      };
      return taskInfo;
    }
    return null;
  }

  // 获取倒计时状态
  getCountdownStatus(): CountdownStatus {
    const status: CountdownStatus = {
      isRunning: this.isRunning,
      countdownTime: this.countdownTime,
      remainingTime: this.remainingTime
    };
    return status;
  }
}