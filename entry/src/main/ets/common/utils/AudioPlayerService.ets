// entry/src/main/ets/common/utils/AudioPlayerService.ets
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Music, Play, UserInfo } from '../constants/Model';
import globalPlayerStore from '../constants/GlobalPlayerStore';
import { EventBus } from './EventBus';
import { StorageConstants } from '../constants/StorageConstants';
import { FastToast } from './FastToast';
import avSessionManager, { PlaybackCommand } from './AVSessionManager';
import { fileIo } from '@kit.CoreFileKit';
import { StorageUtil } from './StorageUtil';
import { FastTool } from './FastTool';
import { router } from '@kit.ArkUI';

/**
 * 播放器错误信息接口
 */
export interface PlayerErrorInfo {
  code: number;
  message: string;
}

/**
 * 播放时间更新信息接口
 */
export interface PlayerTimeUpdateInfo {
  currentTime: number;
  duration: number;
  progress: number;
}

/**
 * 播放状态变化信息接口
 */
export interface PlayerStateChangeInfo {
  isPlaying: boolean;
  isPaused: boolean;
  currentTime: number;
  duration: number;
  currentMusic: Music | null;
  playerUri: string;  // 添加 playerUri 字段
}

/**
 * 播放器状态接口
 */
export interface PlayerState {
  isPlaying: boolean;
  isPaused: boolean;
  currentTime: number;
  duration: number;
  currentMusic: Music | null;
  currentPlayIndex: number;
  playerUri: string;  // 添加这行
}

/**
 * 定时播放信息接口
 */
export interface TimerPlayInfo {
  isActive: boolean;
  remainingTime: number; // 剩余时间（毫秒）
  totalTime: number;     // 总定时时间（毫秒）
  endTime: number;       // 结束时间戳
}


/**
 * 全局音频播放服务 - 单例模式
 * 管理整个应用的音频播放功能
 */
export class AudioPlayerService {
  private static instance: AudioPlayerService | null = null;
  // 播放器实例
  private avPlayer: media.AVPlayer | null = null;
  private isPlayerInitialized: boolean = false;
  private isPreparing: boolean = false;
  private currentUri: string = '';
  // 播放状态
  private _isPlaying: boolean = false;
  private _isPaused: boolean = false;
  private _currentTime: number = 0;
  private _duration: number = 0;
  private _currentMusic: Music | null = null;
  private _currentPlayIndex: number = 0;

  // 播放完成处理标志
  private isHandlingCompletion: boolean = false;

  // 记录上次播放完成处理的时间，防止短时间内重复触发
  private lastCompletionTime: number = 0;

  // seek 冷静期
  private lastSeekTime: number = 0;

  private context: Context | null = null;  // 新增：保存 context

  private backgroundCompletionCheckInterval: number | null = null;
  private lastKnownTime: number = 0;
  private stuckTimeCheckCount: number = 0;

  // 定时播放相关属性
  private timerPlayInfo: TimerPlayInfo = {
    isActive: false,
    remainingTime: 0,
    totalTime: 0,
    endTime: 0
  };
  private timerInterval: number | null = null;  // 定时器ID

  // 私有构造函数，防止外部实例化
  private constructor() {
    this.initPlayer();
    this.listenToAVSessionCommands();  // 新增：监听 AVSession 命令
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): AudioPlayerService {
    if (!AudioPlayerService.instance) {
      AudioPlayerService.instance = new AudioPlayerService();
    }
    return AudioPlayerService.instance;
  }

  /**
   * 初始化播放器
   */
  private async initPlayer(): Promise<void> {
    try {
      if (this.avPlayer) {
        await this.releasePlayer();
      }

      this.avPlayer = await media.createAVPlayer();
      this.isPlayerInitialized = true;
      // console.log('[AudioPlayerService] AVPlayer 创建成功');

      this.setupPlayerListeners();
    } catch (error) {
      console.error('[AudioPlayerService] AVPlayer 创建失败:', error);
      this.isPlayerInitialized = false;
    }
  }

  /**
   * 释放播放器资源
   */
  private async releasePlayer(): Promise<void> {
    if (this.avPlayer) {
      try {
        // 停止播放
        await new Promise<void>((resolve) => {
          this.avPlayer!.stop((err: BusinessError) => {
            if (err) {
              console.error('[AudioPlayerService] 停止播放器失败:', err);
            }
            resolve();
          });
        });

        // 重置播放器
        await new Promise<void>((resolve) => {
          this.avPlayer!.reset((err: BusinessError) => {
            if (err) {
              console.error('[AudioPlayerService] 重置播放器失败:', err);
            }
            resolve();
          });
        });

        // 释放资源
        await new Promise<void>((resolve) => {
          this.avPlayer!.release((err: BusinessError) => {
            if (err) {
              console.error('[AudioPlayerService] 释放播放器失败:', err);
            }
            resolve();
          });
        });

        this.avPlayer = null;
        this.isPlayerInitialized = false;
        this.isPreparing = false;
        this.currentUri = '';
        // console.log('[AudioPlayerService] AVPlayer 释放成功');
      } catch (error) {
        console.error('[AudioPlayerService] 释放播放器失败:', error);
      }
    }
  }

  /**
   * 确保播放器处于可用状态
   */
  private async ensurePlayerState(): Promise<boolean> {
    if (!this.avPlayer) {
      console.error('[AudioPlayerService] 播放器未初始化');
      return false;
    }

    const currentState = this.avPlayer.state;
    // console.log(`[AudioPlayerService] 当前播放器状态: ${currentState}`);

    try {
      switch (currentState) {
        case 'idle':
        case 'initialized':
          return true;

        case 'prepared':
        case 'playing':
        case 'paused':
        case 'completed':
        case 'stopped':
          // console.log('[AudioPlayerService] 重置播放器到初始状态');
          await new Promise<void>((resolve, reject) => {
            this.avPlayer!.reset((err: BusinessError) => {
              if (err) {
                console.error('[AudioPlayerService] 重置播放器失败:', err);
                reject(err);
                return;
              }
              // console.log('[AudioPlayerService] 播放器重置成功');
              resolve();
            });
          });
          return true;

        case 'error':
          // console.log('[AudioPlayerService] 播放器处于错误状态，重新初始化');
          await this.releasePlayer();
          await this.initPlayer();
          return this.avPlayer !== null;

        default:
          console.error(`[AudioPlayerService] 未知的播放器状态: ${currentState}`);
          return false;
      }
    } catch (error) {
      console.error('[AudioPlayerService] 确保播放器状态失败:', error);
      return false;
    }
  }

  /**
   * 等待播放器进入特定状态
   */
  private waitForPlayerState(expectedStates: string[], timeoutMs: number): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.avPlayer) {
        reject(new Error('[AudioPlayerService] 播放器未初始化'));
        return;
      }

      const currentState = this.avPlayer.state;
      if (expectedStates.includes(currentState)) {
        // console.log(`[AudioPlayerService] 播放器已处于期望状态: ${currentState}`);
        resolve();
        return;
      }

      const timeoutId = setTimeout(() => {
        this.avPlayer?.off('stateChange', stateChangeHandler);
        reject(new Error(`[AudioPlayerService] 等待状态超时: 期望 ${expectedStates.join('/')}, 当前 ${this.avPlayer?.state}`));
      }, timeoutMs);

      const stateChangeHandler = (state: string) => {
        // console.log(`[AudioPlayerService] 状态变化: ${state}, 期望: ${expectedStates.join('/')}`);
        if (expectedStates.includes(state)) {
          clearTimeout(timeoutId);
          this.avPlayer?.off('stateChange', stateChangeHandler);
          resolve();
        }
      };

      this.avPlayer.on('stateChange', stateChangeHandler);
    });
  }

  /**
   * 设置播放器事件监听
   */
  private setupPlayerListeners(): void {
    if (!this.avPlayer) {
      return;
    }

    // 移除之前的监听器
    this.avPlayer.off('error');
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('stateChange');

    // 错误监听
    this.avPlayer.on('error', (err: BusinessError) => {
      console.error(`[AudioPlayerService] 播放器错误: code=${err.code}, msg=${err.message}`);
      this.isPreparing = false;
      this._isPlaying = false;
      this._isPaused = false;

      // 确保调用 updateGlobalState
      this.updateGlobalState();

      // 通知错误
      const errorInfo: PlayerErrorInfo = {
        code: err.code,
        message: err.message
      };
      EventBus.send(StorageConstants.PLAYER_ERROR, errorInfo);

      switch (err.code) {
        case 5400102:
          FastToast.showToast('媒体文件无法播放');
          break;
        case 5400103:
          FastToast.showToast('播放失败');
          break;
        default:
          FastToast.showToast(`播放错误: ${err.message}`);
      }

      this.updateGlobalState();
    });

    // 时间更新监听
    this.avPlayer.on('timeUpdate', (time: number) => {
      this._currentTime = time;

      // 确保时长已获取
      if (this.avPlayer && this._duration <= 0) {
        const duration = this.avPlayer.duration;
        if (duration > 0) {
          this._duration = duration;
          globalPlayerStore.setSongDuration(duration);

          // 更新 AVSession 的元数据，使用实际获取的时长
          if (this._currentMusic) {
            avSessionManager.updateMetadata(this._currentMusic, this._currentPlayIndex, this._duration);
          }

          // console.log(`[AudioPlayerService] 在timeUpdate中获取时长: ${duration}ms`);
        }
      }

      if (this._duration > 0) {
        const progress = (time / this._duration) * 100;
        globalPlayerStore.setPlaySchedule(progress);
        globalPlayerStore.setSongPlayedDuration(time);

        // 检测播放完成
        const remaining = this._duration - time;
        const progressPercent = (time / this._duration) * 100;

        // 检查是否在 seek 冷静期内（seek 后 1 秒内不触发播放完成检测）
        const timeSinceLastSeek = Date.now() - this.lastSeekTime;
        const isInSeekCooldown = timeSinceLastSeek < 1000;

        // 修改检测条件：不依赖 isPlaying 状态，而是检查播放器状态和是否已处理
        const playerState = this.avPlayer?.state;
        const isActuallyPlaying = playerState === 'playing' || this._isPlaying;

        // 增加条件：不在 seek 冷静期内
        if ((remaining <= 200 || progressPercent >= 99) &&
            isActuallyPlaying &&
            !this.isHandlingCompletion &&
            !this.isPreparing &&
            !isInSeekCooldown) {

          // console.log(`[AudioPlayerService] ========== [timeUpdate] 检测到播放即将完成 ==========`);
          // console.log(`[AudioPlayerService] 当前时间: ${time}ms, 总时长: ${this._duration}ms`);
          // console.log(`[AudioPlayerService] 剩余时间: ${remaining}ms, 进度: ${progressPercent.toFixed(2)}%`);
          // console.log(`[AudioPlayerService] 播放器状态: ${playerState}`);
          // console.log(`[AudioPlayerService] _isPlaying: ${this._isPlaying}, isPreparing: ${this.isPreparing}`);
          // console.log(`[AudioPlayerService] seek冷静期: ${isInSeekCooldown} (距离上次seek ${timeSinceLastSeek}ms)`);

          // 设置标志，防止重复触发
          this.isHandlingCompletion = true;

          // 停止当前播放状态
          this._isPlaying = false;
          this._isPaused = false;
          this.updateGlobalState();

          // console.log('[AudioPlayerService] [timeUpdate] 准备执行自动播放下一首...');

          // 延迟执行自动播放下一首（改为 800ms，给足够时间）
          setTimeout(() => {
            // console.log('[AudioPlayerService] [timeUpdate] 开始执行 handlePlayCompleted');
            this.handlePlayCompleted();
            // 延迟重置标志，确保其他触发源也能被阻止
            setTimeout(() => {
              this.isHandlingCompletion = false;
              // console.log('[AudioPlayerService] [timeUpdate] 重置 isHandlingCompletion 标志');
            }, 1000);
          }, 800);
        } else if (isInSeekCooldown && progressPercent >= 99) {
          // 如果在 seek 冷静期内且接近结尾，打印日志
          // console.log(`[AudioPlayerService] 在seek冷静期内(${timeSinceLastSeek}ms)，跳过播放完成检测`);
        }
      }

      // 广播时间更新事件
      const timeUpdateInfo: PlayerTimeUpdateInfo = {
        currentTime: time,
        duration: this._duration,
        progress: this._duration > 0 ? (time / this._duration) * 100 : 0
      };
      EventBus.send(StorageConstants.PLAYER_TIME_UPDATE, timeUpdateInfo);
    });

    // 状态变化监听
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      // console.log(`[AudioPlayerService] 播放器状态: ${state}, 原因: ${reason}`);

      switch (state) {
        case 'idle':
          // console.log('[AudioPlayerService] 播放器空闲');
          this.isPreparing = false;
          break;
        case 'initialized':
          // console.log('[AudioPlayerService] 播放器初始化完成');
          this.isPreparing = false;
          break;
        case 'prepared':
          if (this.avPlayer) {
            this._duration = this.avPlayer.duration;
            this._currentTime = this.avPlayer.currentTime;

            // 如果时长获取失败，打印警告
            if (this._duration <= 0) {
              console.warn('[AudioPlayerService] 警告: 在prepared状态未能获取到有效时长');
            } else {
              globalPlayerStore.setSongDuration(this._duration);
              this.updateGlobalState();
              // console.log(`[AudioPlayerService] 准备完成: 总时长=${this._duration}ms, 当前位置=${this._currentTime}ms`);
            }

            this.isPreparing = false;
          }
          break;
        case 'playing':
          // console.log('[AudioPlayerService] ========== stateChange: playing ==========');
          // console.log(`[AudioPlayerService] 之前状态 - isPlaying: ${this._isPlaying}, isPaused: ${this._isPaused}`);

          this._isPlaying = true;
          this._isPaused = false;
          this.isPreparing = false;

          // console.log(`[AudioPlayerService] 更新后状态 - isPlaying: ${this._isPlaying}, isPaused: ${this._isPaused}`);

          // 在 playing 状态再次确认时长（作为备份）
          if (this.avPlayer && this._duration <= 0) {
            // console.log('[AudioPlayerService] 在playing状态重新获取时长');
            this._duration = this.avPlayer.duration;
            if (this._duration > 0) {
              globalPlayerStore.setSongDuration(this._duration);
              // console.log(`[AudioPlayerService] 重新获取时长成功: ${this._duration}ms`);
            }
          }

          // 确保 playerUri 已同步
          globalPlayerStore.setPlayerUri(this.currentUri);
          // console.log(`[AudioPlayerService] 当前播放URI: ${this.currentUri}`);

          this.updateGlobalState();
          break;
        case 'paused':
          console.log('[AudioPlayerService] 播放暂停');
          this._isPaused = true;
          this._isPlaying = false;  // 添加这行：确保 playing 状态为 false
          this.isPreparing = false;
          this.updateGlobalState();
          // console.log(`[AudioPlayerService] 暂停状态更新：isPlaying=${this._isPlaying}, isPaused=${this._isPaused}`);
          break;
        case 'completed':
          // console.log('[AudioPlayerService] ========== [stateChange] AVPlayer completed 状态触发 ==========');

          // 如果还没有处理过完成事件，则处理
          if (!this.isHandlingCompletion) {
            this.isHandlingCompletion = true;

            this._isPlaying = false;
            this._isPaused = false;
            this.isPreparing = false;
            this.updateGlobalState();

            // console.log('[AudioPlayerService] [stateChange] 通过 completed 状态触发自动播放');
            setTimeout(() => {
              // console.log('[AudioPlayerService] [stateChange] 开始执行 handlePlayCompleted');
              this.handlePlayCompleted();
              // 延迟重置标志
              setTimeout(() => {
                this.isHandlingCompletion = false;
                // console.log('[AudioPlayerService] [stateChange] 重置 isHandlingCompletion 标志');
              }, 1000);
            }, 800);
          } else {
            // console.log('[AudioPlayerService] [stateChange] completed 状态已被处理，跳过');
          }
          break;
        case 'stopped':
          // console.log('[AudioPlayerService] 播放停止');
          this._isPlaying = false;
          this._isPaused = false;
          this._currentTime = 0;
          this.isPreparing = false;
          this.updateGlobalState();
          break;
        case 'error':
          // console.log('[AudioPlayerService] 播放器错误状态');
          this._isPlaying = false;
          this._isPaused = false;
          this.isPreparing = false;
          this.updateGlobalState();
          break;
      }
    });
  }

  /**
   * 监听来自 AVSession 的控制命令
   */
  private listenToAVSessionCommands(): void {
    EventBus.listen<PlaybackCommand>(StorageConstants.AVSESSION_COMMAND, (command) => {
      if (!command) return;

      // console.log(`[AudioPlayerService] 收到 AVSession 命令: ${command.type}`);

      switch (command.type) {
        case 'play':
          this.resume();
          break;
        case 'pause':
          this.pause();
          break;
        case 'playNext':
          this.playNext();
          break;
        case 'playPrevious':
          this.playPrevious();
          break;
        case 'seek':
          if (command.value !== undefined) {
            this.seek(command.value);
          }
          break;
      }
    });
  }

  /**
   * 初始化 AVSession（需要在应用启动时调用）
   */
  public async initAVSession(context: Context): Promise<void> {
    this.context = context;
    await avSessionManager.createSession(context);
    // console.log('[AudioPlayerService] AVSession 初始化完成');
  }

  /**
   * 更新全局状态
   */
  private updateGlobalState(): void {
    // console.log(`[AudioPlayerService] ========== 更新全局状态 ==========`);
    // console.log(`[AudioPlayerService] isPlaying: ${this._isPlaying}`);
    // console.log(`[AudioPlayerService] isPaused: ${this._isPaused}`);
    // console.log(`[AudioPlayerService] currentTime: ${this._currentTime}ms`);
    // console.log(`[AudioPlayerService] duration: ${this._duration}ms`);
    // console.log(`[AudioPlayerService] playerUri: ${this.currentUri}`);

    // 更新 GlobalPlayerStore
    globalPlayerStore.setPlaying(this._isPlaying);
    globalPlayerStore.setSongDuration(this._duration);
    globalPlayerStore.setSongPlayedDuration(this._currentTime);
    globalPlayerStore.setPlayerUri(this.currentUri);

    if (this._currentMusic) {
      globalPlayerStore.setPlayListInfo(this._currentMusic);
    }

    // 广播播放状态变化
    const stateChangeInfo: PlayerStateChangeInfo = {
      isPlaying: this._isPlaying,
      isPaused: this._isPaused,
      currentTime: this._currentTime,
      duration: this._duration,
      currentMusic: this._currentMusic,
      playerUri: this.currentUri
    };
    EventBus.send(StorageConstants.PLAYER_STATE_CHANGE, stateChangeInfo);

    // 同步到 AVSession
    if (this._isPlaying && !this._isPaused) {
      avSessionManager.setPlaying(this._currentTime);
    } else if (this._isPaused) {
      avSessionManager.setPaused(this._currentTime);
    } else {
      avSessionManager.setStopped();
    }

    // console.log('[AudioPlayerService] 全局状态已更新并广播');
  }

  /**
   * 处理播放完成
   */
  private handlePlayCompleted(): void {
    // console.log('[AudioPlayerService] ========== handlePlayCompleted 被调用 ==========');

    // 防重复检查：如果距离上次处理不足 2 秒，跳过
    const now = Date.now();
    const timeSinceLastCompletion = now - this.lastCompletionTime;

    if (timeSinceLastCompletion < 2000) {
      // console.log(`[AudioPlayerService] 距离上次播放完成仅 ${timeSinceLastCompletion}ms，跳过重复处理`);
      return;
    }

    // 记录本次处理时间
    this.lastCompletionTime = now;
    // console.log('[AudioPlayerService] 记录播放完成时间，防止重复触发');

    // 广播播放完成事件
    EventBus.send(StorageConstants.PLAYER_COMPLETED, this._currentMusic);

    // 检查播放列表有效性
    if (!this._currentMusic) {
      console.error('[AudioPlayerService] 无法播放下一首：_currentMusic 为空');
      this.isHandlingCompletion = false;  // 重置标志
      return;
    }

    if (!this._currentMusic.musics || this._currentMusic.musics.length === 0) {
      console.error('[AudioPlayerService] 无法播放下一首：播放列表为空');
      this.isHandlingCompletion = false;  // 重置标志
      return;
    }

    // console.log(`[AudioPlayerService] 当前音乐: ${this._currentMusic.title_cn || this._currentMusic.title_en}`);
    // console.log(`[AudioPlayerService] 当前索引: ${this._currentPlayIndex}/${this._currentMusic.musics.length}`);
    // console.log(`[AudioPlayerService] 当前歌曲: ${this._currentMusic.musics[this._currentPlayIndex]?.name}`);

    const playMethod = globalPlayerStore.playMethod;
    // console.log(`[AudioPlayerService] 播放模式: ${playMethod}`);

    if (playMethod === 'single') {
      // 单曲循环：重新播放当前歌曲
      // console.log('[AudioPlayerService] 单曲循环模式，重新播放当前歌曲');
      const currentSong = this._currentMusic.musics[this._currentPlayIndex];
      // console.log(`[AudioPlayerService] 重播: ${currentSong?.name}`);

      // 延迟一点再播放，确保之前的播放完全停止
      setTimeout(() => {
        this.playMusic(this._currentMusic!, this._currentPlayIndex);
      }, 100);
    } else {
      // 列表循环或顺序播放：播放下一首
      // console.log('[AudioPlayerService] 列表播放模式，播放下一首');
      const nextIndex = this._currentPlayIndex + 1;

      if (nextIndex < this._currentMusic.musics.length) {
        const nextSong = this._currentMusic.musics[nextIndex];
        // console.log(`[AudioPlayerService] 播放第 ${nextIndex + 1} 首: ${nextSong?.name}`);
      } else {
        // console.log('[AudioPlayerService] 已到最后一首，循环到第一首');
        const firstSong = this._currentMusic.musics[0];
        // console.log(`[AudioPlayerService] 播放第 1 首: ${firstSong?.name}`);
      }

      // 延迟一点再播放
      setTimeout(() => {
        this.playNext();
      }, 100);
    }
  }

  private async getFileFd(filePath: string): Promise<number> {
    try {
      // console.log(`[AudioPlayerService] 尝试打开文件: ${filePath}`);

      // 移除 file:// 前缀（如果存在）
      if (filePath.startsWith('file://')) {
        filePath = filePath.substring(7);
      }

      // 使用鸿蒙文件 API 打开文件
      const file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
      const fd = file.fd;
      // console.log(`[AudioPlayerService] 文件打开成功，fd: ${fd}`);
      return fd;
    } catch (error) {
      console.error(`[AudioPlayerService] 文件打开失败:`, error);
      throw new Error(`无法打开文件: ${filePath}`);
    }
  }

  private async checkVipStatus(music: Music): Promise<boolean> {
    const userInfo: string = await StorageUtil.getString(StorageConstants.USER_INFO, '')
    const isLoggedIn = await StorageUtil.getBoolean(StorageConstants.IS_LOGGED_IN, false)
    let info: UserInfo = {}
    if (userInfo) {
      info = JSON.parse(userInfo)
    }
    if (music?.is_free === 1) {
      return true;
    }
    if (music?.isGuest === 1) {
      return true;
    }
    if (!isLoggedIn) {
      return true;
    }
    if (music && music.musics && music.musics.length > 0 && music.musics[0] &&
    music.musics[0].local_music_address_2 && music.musics[0].local_music_address_2.length > 0) {
      return Number((new Date().getTime() / 1000).toFixed()) <= Number(info?.vipInfo?.vipExpireTime);
    }
    //获取本地用户信息
    if (info) {
      if (Number((new Date().getTime() / 1000).toFixed()) <= Number(info?.vipInfo?.vipExpireTime)) {
        return true;
      } else {
        return false
      }
    } else {
      return false;
    }
    return false;
  }


  /**
   * 播放音乐
   * @param music 音乐信息
   * @param playIndex 播放列表中的索引（可选）
   */
  public async playMusic(music: Music, playIndex: number = 0): Promise<void> {

    const flag = await this.checkVipStatus(music);
    if (!flag) {
      // FastToast.showToast(FastTool.getString($r('app.string.vip_tip')))
      router.pushUrl({
        url: 'pages/member/member'
      })
      this._isPlaying = false;
      if (this.avPlayer) {
        await this.releasePlayer();
      }
      return
    }
    // 重置播放完成处理标志
    this.isHandlingCompletion = false;

    // 重置 seek 冷静期时间
    this.lastSeekTime = 0;

    // 重置上次播放完成时间（开始新播放）
    this.lastCompletionTime = 0;

    if (this.isPreparing) {
      // console.log('[AudioPlayerService] 播放器正在准备中，请稍后');
      return;
    }

    if (!this.avPlayer || !this.isPlayerInitialized) {
      console.error('[AudioPlayerService] 播放器未初始化');
      await this.initPlayer();
      if (!this.avPlayer) {
        FastToast.showToast('播放器未就绪');
        return;
      }
    }

    const currentPlayItem = music?.musics?.[playIndex];

    // 优先使用本地地址，如果没有则使用在线地址
    let uri = currentPlayItem?.local_music_address_2;
    let isLocalFile = false;
    let fileFd: number | undefined;
    // console.log('[AudioPlayerService] 检测到本地音乐文件，优先使用', JSON.stringify(currentPlayItem));
    if (uri && uri.length > 0) {
      // 有本地地址，使用本地文件
      // uri = this.getImageUri(uri)
      isLocalFile = true;
      // console.log('[AudioPlayerService] 检测到本地音乐文件，优先使用');
      try {
        // 获取文件描述符
        fileFd = await this.getFileFd(uri);
        // 使用 fd:// 协议格式
        uri = `fd://${fileFd}`;
        // console.log(`[AudioPlayerService] 使用 fd 协议: ${uri}`);
      } catch (error) {
        console.error('[AudioPlayerService] 本地文件打开失败，尝试使用在线地址');
        // 如果本地文件打开失败，回退到在线地址
        uri = currentPlayItem?.music_address_2;
        isLocalFile = false;
        fileFd = undefined;
      }
    } else {
      // 没有本地地址，使用在线地址
      uri = currentPlayItem?.music_address_2;
      // console.log('[AudioPlayerService] 未找到本地文件，使用在线地址');
    }

    if (!uri || uri.length === 0) {
      console.error('[AudioPlayerService] 音乐URL无效：本地和在线地址都为空');
      FastToast.showToast('音乐地址无效');
      return;
    }

    // console.log(`[AudioPlayerService] 播放源: ${isLocalFile ? '本地文件' : '在线流媒体'}`);
    // console.log(`[AudioPlayerService] 音乐地址: ${uri}`);
    // console.log(`[AudioPlayerService] 歌曲名称: ${currentPlayItem?.name || '未知'}`);

    // 获取需要跳过的开头时间（毫秒）
    const skipStartTime = currentPlayItem?.x || 0;

    // 如果是同一首歌曲且正在播放，直接返回
    if (this.currentUri === uri && this._isPlaying) {
      // console.log('[AudioPlayerService] 同一首歌曲正在播放中');
      return;
    }

    // console.log('[AudioPlayerService] 开始加载音乐:', uri);
    if (skipStartTime > 0) {
      // console.log(`=====================[AudioPlayerService] 将跳过开头 ${skipStartTime} 毫秒`);
    }

    this.isPreparing = true;
    this._currentMusic = music;
    this._currentPlayIndex = playIndex;

    try {
      const stateReady = await this.ensurePlayerState();
      if (!stateReady) {
        FastToast.showToast('播放器状态异常');
        this.isPreparing = false;
        return;
      }

      await this.waitForPlayerState(['idle', 'initialized'], 3000);

      this.avPlayer.url = uri;
      this.currentUri = uri;
      globalPlayerStore.setPlayerUri(uri);
      // console.log('[AudioPlayerService] URL设置成功，当前状态:', this.avPlayer.state);

      await this.waitForPlayerState(['initialized'], 3000);
      // console.log('[AudioPlayerService] 播放器已进入initialized状态');

      await new Promise<void>((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          reject(new Error('准备超时'));
        }, 10000);

        const prepareCallback = (err: BusinessError) => {
          clearTimeout(timeoutId);

          if (err) {
            console.error('[AudioPlayerService] 准备失败:', JSON.stringify(err));
            this.avPlayer?.reset(() => {
              // console.log('[AudioPlayerService] 准备失败后重置播放器');
            });
            reject(err);
            return;
          }
          // console.log('[AudioPlayerService] 准备成功');
          resolve();
        };

        const currentState = this.avPlayer!.state;
        // console.log('[AudioPlayerService] 准备前状态:', currentState);

        if (currentState !== 'initialized') {
          clearTimeout(timeoutId);
          reject(new Error(`状态错误: 当前状态是 ${currentState}，无法prepare`));
          return;
        }

        this.avPlayer!.prepare(prepareCallback);
      });

      await this.waitForPlayerState(['prepared'], 5000);

      // 在播放前设置起始位置（如果需要跳过开头）
      if (skipStartTime > 0) {
        const skipTimeMs = skipStartTime + 2000;
        // console.log(`[AudioPlayerService] 在播放前设置起始位置: ${skipTimeMs}ms`);

        // 在 prepared 状态后，播放前设置起始位置
        this.avPlayer!.seek(skipTimeMs);
        this._currentTime = skipTimeMs;
        // console.log('[AudioPlayerService] 起始位置设置完成');
      }

      await new Promise<void>((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          reject(new Error('播放超时'));
        }, 5000);

        this.avPlayer!.play((err: BusinessError) => {
          clearTimeout(timeoutId);

          if (err) {
            console.error('[AudioPlayerService] 播放失败:', JSON.stringify(err));
            reject(err);
            return;
          }

          // console.log('[AudioPlayerService] ========== play() 回调成功 ==========');

          // 立即设置播放状态为 true
          this._isPlaying = true;
          this._isPaused = false;
          // console.log(`[AudioPlayerService] 设置状态：isPlaying=${this._isPlaying}, isPaused=${this._isPaused}`);

          // 立即更新全局状态
          this.updateGlobalState();

          resolve();
        });
      });

      // 播放成功后，更新 AVSession 元数据
      await avSessionManager.updateMetadata(music, playIndex, this._duration);

      // console.log('[AudioPlayerService] play() 调用完成，等待状态更新');

      // 启动后台播放完成检测
      this.startBackgroundCompletionCheck();

    } catch (error) {
      console.error('[AudioPlayerService] 播放流程失败:', error);

      if (error.code === 5400102) {
        FastToast.showToast('媒体资源加载失败，请检查网络或音乐地址');
      } else if (error.message?.includes('超时')) {
        FastToast.showToast('播放准备超时，请重试');
      } else if (error.message?.includes('状态错误')) {
        FastToast.showToast(error.message);
      } else {
        FastToast.showToast('播放失败，请重试');
      }

      this._isPlaying = false;
      this._isPaused = false;
      this.updateGlobalState();

      await this.initPlayer();
    } finally {
      this.isPreparing = false;
    }
  }

  /**
   * 暂停播放
   */
  public pause(): void {
    if (!this.avPlayer || !this._isPlaying) {
      // console.log('[AudioPlayerService] 无法暂停：播放器未初始化或未在播放');
      return;
    }

    // console.log('[AudioPlayerService] 开始暂停播放');

    // 停止后台检测
    this.stopBackgroundCompletionCheck();

    this.avPlayer.pause((err: BusinessError) => {
      if (err) {
        console.error('[AudioPlayerService] 暂停失败:', err);
        FastToast.showToast('暂停失败');
      } else {
        // console.log('[AudioPlayerService] 暂停成功');
        this._isPaused = true;
        this._isPlaying = false;  // 添加这行：确保 playing 状态为 false
        this.updateGlobalState();

        // 更新 AVSession 状态
        avSessionManager.setPaused(this._currentTime);

        // console.log(`[AudioPlayerService] 状态更新：isPlaying=${this._isPlaying}, isPaused=${this._isPaused}`);
      }
    });
  }

  /**
   * 恢复播放
   */
  public resume(): void {
    if (!this.avPlayer || !this._isPaused) {
      return;
    }

    console.log('[AudioPlayerService] 恢复播放');
    this.avPlayer.play((err: BusinessError) => {
      if (err) {
        console.error('[AudioPlayerService] 恢复播放失败:', err);
        FastToast.showToast('播放失败');
      } else {
        // console.log('[AudioPlayerService] 恢复播放成功');
        this._isPaused = false;
        this._isPlaying = true;
        this.updateGlobalState();

        // 更新 AVSession 状态
        avSessionManager.setPlaying(this._currentTime);
      }
    });
  }

  /**
   * 切换播放/暂停
   */
  public togglePlayPause(): void {
    // console.log(`[AudioPlayerService] togglePlayPause 调用：isPlaying=${this._isPlaying}, isPaused=${this._isPaused}`);

    if (this._isPlaying && !this._isPaused) {
      // 正在播放 -> 暂停
      // console.log('[AudioPlayerService] 当前正在播放，切换到暂停');
      this.pause();
    } else if (this._isPaused) {
      // 已暂停 -> 恢复播放
      // console.log('[AudioPlayerService] 当前已暂停，恢复播放');
      this.resume();
    } else {
      // 未在播放 -> 开始播放
      console.log('[AudioPlayerService] 当前未在播放，状态异常');
    }
  }

  /**
   * 停止播放
   */
  public stop(): void {
    if (!this.avPlayer) {
      return;
    }

    console.log('[AudioPlayerService] 停止播放');

    // 停止后台检测
    this.stopBackgroundCompletionCheck();

    this.avPlayer.stop((err: BusinessError) => {
      if (err) {
        console.error('[AudioPlayerService] 停止失败:', err);
      } else {
        // console.log('[AudioPlayerService] 停止成功');
        this._isPlaying = false;
        this._isPaused = false;
        this._currentTime = 0;
        this.updateGlobalState();  // 确认这行存在
        // console.log('[AudioPlayerService] 停止状态已更新');
      }
    });
  }

  /**
   * 跳转到指定位置
   * @param position 位置（毫秒）
   */
  public seek(position: number): void {
    if (!this.avPlayer) {
      // console.log('[AudioPlayerService] seek: 播放器未初始化');
      return;
    }

    // console.log(`[AudioPlayerService] ========== seek 到 ${position}ms ==========`);
    // console.log(`[AudioPlayerService] 当前时长: ${this._duration}ms`);
    // console.log(`[AudioPlayerService] seek 进度: ${((position / this._duration) * 100).toFixed(2)}%`);

    try {
      // 重置播放完成处理标志
      this.isHandlingCompletion = false;

      // 记录 seek 时间，用于冷静期判断
      this.lastSeekTime = Date.now();

      // console.log('[AudioPlayerService] 重置 isHandlingCompletion 标志');

      this.avPlayer.seek(position);
      // console.log('[AudioPlayerService] 跳转成功');
      this._currentTime = position;
      this.updateGlobalState();
    } catch (err) {
      console.error('[AudioPlayerService] 跳转失败:', err);
      FastToast.showToast('跳转失败');
    }
  }

  /**
   * 播放下一首
   */
  public playNext(): void {
    // console.log('[AudioPlayerService] ========== playNext 被调用 ==========');

    if (!this._currentMusic) {
      console.error('[AudioPlayerService] playNext: _currentMusic 为空');
      return;
    }

    if (!this._currentMusic.musics || this._currentMusic.musics.length === 0) {
      console.error('[AudioPlayerService] playNext: musics 数组为空或长度为0');
      return;
    }

    const currentIndex = this._currentPlayIndex;
    const totalSongs = this._currentMusic.musics.length;
    // console.log(`[AudioPlayerService] playNext: 当前索引=${currentIndex}, 总曲目数=${totalSongs}`);

    const nextIndex = currentIndex + 1;

    if (nextIndex < totalSongs) {
      // console.log(`[AudioPlayerService] playNext: 播放索引 ${nextIndex} (第 ${nextIndex + 1} 首)`);
      this.playMusic(this._currentMusic, nextIndex);
    } else {
      // console.log(`[AudioPlayerService] playNext: 已到列表末尾，循环播放第 1 首`);
      this.playMusic(this._currentMusic, 0);
    }
  }

  /**
   * 播放上一首
   */
  public playPrevious(): void {
    if (!this._currentMusic || !this._currentMusic.musics) {
      return;
    }

    const prevIndex = this._currentPlayIndex - 1;
    if (prevIndex >= 0) {
      this.playMusic(this._currentMusic, prevIndex);
    } else {
      // 循环播放最后一首
      const lastIndex = this._currentMusic.musics.length - 1;
      this.playMusic(this._currentMusic, lastIndex);
    }
  }

  /**
   * 获取当前播放状态
   */
  public getPlayState(): PlayerState {
    const state: PlayerState = {
      isPlaying: this._isPlaying,
      isPaused: this._isPaused,
      currentTime: this._currentTime,
      duration: this._duration,
      currentMusic: this._currentMusic,
      currentPlayIndex: this._currentPlayIndex,
      playerUri: this.currentUri  // 添加这行
    };
    return state;
  }

  /**
   * 启动定时播放
   * @param durationMinutes 定时时间（分钟）
   */
  public startTimerPlay(durationMinutes: number): void {
    if (durationMinutes <= 0) {
      console.error('[AudioPlayerService] 定时播放时间必须大于0');
      FastToast.showToast('定时时间必须大于0分钟');
      return;
    }

    // 如果已有定时器在运行，先关闭
    this.stopTimerPlay();

    const totalTimeMs = durationMinutes * 60 * 1000; // 转换为毫秒
    const endTime = Date.now() + totalTimeMs;

    this.timerPlayInfo = {
      isActive: true,
      remainingTime: totalTimeMs,
      totalTime: durationMinutes,
      endTime: endTime
    };

    // console.log(`[AudioPlayerService] 启动定时播放: ${durationMinutes} 分钟`);
    FastToast.showToast(`定时播放已设置: ${durationMinutes} 分钟`);

    // 启动定时器，每秒更新一次
    this.timerInterval = setInterval(() => {
      this.updateTimerPlay();
    }, 1000);

    // 广播定时播放开始事件
    EventBus.send(StorageConstants.TIMER_PLAY_START, this.timerPlayInfo);
  }

  /**
   * 停止定时播放
   */
  public stopTimerPlay(): void {
    if (!this.timerPlayInfo.isActive) {
      return;
    }

    // console.log('[AudioPlayerService] 停止定时播放');

    // 清除定时器
    if (this.timerInterval !== null) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }

    // 重置定时播放信息
    this.timerPlayInfo = {
      isActive: false,
      remainingTime: 0,
      totalTime: 0,
      endTime: 0
    };

    // 广播定时播放停止事件
    EventBus.send(StorageConstants.TIMER_PLAY_STOP, null);
    FastToast.showToast('定时播放已关闭');
  }

  public getRemainingTimeTotal(): number {
    if (!this.timerPlayInfo.isActive) {
      return 0;
    }
    return this.timerPlayInfo.totalTime;
  }

  /**
   * 获取剩余时间（秒）
   */
  public getRemainingTimeSeconds(): number {
    if (!this.timerPlayInfo.isActive) {
      return 0;
    }
    return Math.ceil(this.timerPlayInfo.remainingTime / 1000);
  }

  /**
   * 获取剩余时间（分钟）
   */
  public getRemainingTimeMinutes(): number {
    if (!this.timerPlayInfo.isActive) {
      return 0;
    }
    return Math.ceil(this.timerPlayInfo.remainingTime / (60 * 1000));
  }

  /**
   * 更新定时播放状态
   */
  private updateTimerPlay(): void {
    if (!this.timerPlayInfo.isActive) {
      return;
    }

    const now = Date.now();
    const remainingTime = Math.max(0, this.timerPlayInfo.endTime - now);

    this.timerPlayInfo.remainingTime = remainingTime;

    // 广播剩余时间更新事件
    EventBus.send(StorageConstants.TIMER_PLAY_UPDATE, this.timerPlayInfo);

    // 如果时间到了，停止播放
    if (remainingTime <= 0) {
      // console.log('[AudioPlayerService] 定时播放时间到，停止播放');
      this.stopTimerPlay();
      this.stop(); // 停止音乐播放
      FastToast.showToast('定时播放时间到');
    }
  }

  /**
   * 启动后台播放完成检测
   */
  private startBackgroundCompletionCheck(): void {
    // 清除之前的检测
    this.stopBackgroundCompletionCheck();

    // console.log('[AudioPlayerService] 启动后台播放完成检测');

    this.backgroundCompletionCheckInterval = setInterval(() => {
      this.checkBackgroundCompletion();
    }, 1000); // 每秒检测一次
  }

  /**
   * 停止后台播放完成检测
   */
  private stopBackgroundCompletionCheck(): void {
    if (this.backgroundCompletionCheckInterval !== null) {
      clearInterval(this.backgroundCompletionCheckInterval);
      this.backgroundCompletionCheckInterval = null;
      // console.log('[AudioPlayerService] 停止后台播放完成检测');
    }
  }

  /**
   * 后台播放完成检测
   */
  private checkBackgroundCompletion(): void {
    if (!this.avPlayer || !this._isPlaying || this.isPreparing) {
      return;
    }

    try {
      const currentTime = this.avPlayer.currentTime;
      const duration = this.avPlayer.duration;

      if (duration <= 0) {
        return;
      }

      // 检测播放是否卡住（时间没有变化）
      if (Math.abs(currentTime - this.lastKnownTime) < 100) {
        this.stuckTimeCheckCount++;
      } else {
        this.stuckTimeCheckCount = 0;
        this.lastKnownTime = currentTime;
      }

      // 如果时间卡住超过5秒，可能是播放完成
      if (this.stuckTimeCheckCount >= 5) {
        // console.log('[AudioPlayerService] [后台检测] 检测到播放可能卡住或完成');
        const remaining = duration - currentTime;
        const progressPercent = (currentTime / duration) * 100;

        if (remaining <= 500 || progressPercent >= 99) {
          // console.log('[AudioPlayerService] [后台检测] 确认播放完成');
          this.handleBackgroundCompletion();
        }
      }

      // 直接检测播放完成
      const remaining = duration - currentTime;
      const progressPercent = (currentTime / duration) * 100;

      if ((remaining <= 500 || progressPercent >= 99.5) &&
          !this.isHandlingCompletion &&
          !this.isPreparing) {

        // console.log('[AudioPlayerService] [后台检测] 检测到播放完成');
        this.handleBackgroundCompletion();
      }

    } catch (error) {
      console.error('[AudioPlayerService] 后台播放检测出错:', error);
    }
  }

  /**
   * 处理后台播放完成
   */
  private handleBackgroundCompletion(): void {
    if (this.isHandlingCompletion) {
      return;
    }

    // console.log('[AudioPlayerService] [后台检测] 开始处理播放完成');

    this.isHandlingCompletion = true;
    this._isPlaying = false;
    this._isPaused = false;
    this.updateGlobalState();

    // 停止后台检测
    this.stopBackgroundCompletionCheck();

    // 延迟执行自动播放下一首
    setTimeout(() => {
      // console.log('[AudioPlayerService] [后台检测] 执行自动播放下一首');
      this.handlePlayCompleted();
      // 重置标志
      setTimeout(() => {
        this.isHandlingCompletion = false;
      }, 1000);
    }, 500);
  }

  /**
   * 销毁服务（应用退出时调用）
   */
  public async destroy(): Promise<void> {
    // 停止定时播放
    this.stopTimerPlay();

    // 停止后台检测
    this.stopBackgroundCompletionCheck();

    await this.releasePlayer();
    await avSessionManager.destroySession();
    AudioPlayerService.instance = null;
  }
}

// 导出单例实例
export default AudioPlayerService.getInstance();