// entry/src/main/ets/common/utils/AVSessionManager.ets

import avSession from '@ohos.multimedia.avsession';
import { BusinessError } from '@kit.BasicServicesKit';
import { Music } from '../constants/Model';
import { EventBus } from './EventBus';
import { StorageConstants } from '../constants/StorageConstants';

/**
 * 播放控制命令类型
 */
export interface PlaybackCommand {
  type: 'play' | 'pause' | 'playNext' | 'playPrevious' | 'seek';
  value?: number;
}

/**
 * AVSession 管理器 - 负责锁屏和通知栏的媒体控制
 */
export class AVSessionManager {
  private static instance: AVSessionManager | null = null;
  private session: avSession.AVSession | null = null;
  private isSessionActive: boolean = false;

  private constructor() {}

  public static getInstance(): AVSessionManager {
    if (!AVSessionManager.instance) {
      AVSessionManager.instance = new AVSessionManager();
    }
    return AVSessionManager.instance;
  }

  /**
   * 创建并激活 AVSession
   */
  public async createSession(context: Context): Promise<void> {
    try {
      if (this.session) {
        // console.log('[AVSessionManager] Session 已存在，先销毁');
        await this.destroySession();
      }

      // 创建 AVSession
      this.session = await avSession.createAVSession(context, 'demoMusic', 'audio');
      // console.log('[AVSessionManager] AVSession 创建成功');

      // 激活 Session
      await this.session.activate();
      this.isSessionActive = true;
      // console.log('[AVSessionManager] AVSession 激活成功');

      // 注册控制命令回调
      this.registerControlCallbacks();
    } catch (error) {
      console.error('[AVSessionManager] 创建 Session 失败:', error);
    }
  }

  /**
   * 注册播放控制回调
   */
  private registerControlCallbacks(): void {
    if (!this.session) {
      console.error('[AVSessionManager] Session 未初始化');
      return;
    }

    try {
      // 播放
      this.session.on('play', () => {
        // console.log('[AVSessionManager] 收到播放命令');
        // 通过 EventBus 发送播放命令
        const command: PlaybackCommand = { type: 'play' };
        EventBus.send(StorageConstants.AVSESSION_COMMAND, command);
      });

      // 暂停
      this.session.on('pause', () => {
        // console.log('[AVSessionManager] 收到暂停命令');
        const command: PlaybackCommand = { type: 'pause' };
        EventBus.send(StorageConstants.AVSESSION_COMMAND, command);
      });

      // 下一首
      this.session.on('playNext', () => {
        // console.log('[AVSessionManager] 收到下一首命令');
        const command: PlaybackCommand = { type: 'playNext' };
        EventBus.send(StorageConstants.AVSESSION_COMMAND, command);
      });

      // 上一首
      this.session.on('playPrevious', () => {
        // console.log('[AVSessionManager] 收到上一首命令');
        const command: PlaybackCommand = { type: 'playPrevious' };
        EventBus.send(StorageConstants.AVSESSION_COMMAND, command);
      });

      // 跳转
      this.session.on('seek', (time: number) => {
        // console.log('[AVSessionManager] 收到跳转命令:', time);
        const command: PlaybackCommand = { type: 'seek', value: time };
        EventBus.send(StorageConstants.AVSESSION_COMMAND, command);
      });

      // console.log('[AVSessionManager] 控制回调注册成功');
    } catch (error) {
      console.error('[AVSessionManager] 注册控制回调失败:', error);
    }
  }

  /**
   * 更新媒体元数据（歌曲信息）
   */
  public async updateMetadata(music: Music, currentPlayIndex: number = 0, actualDuration?: number): Promise<void> {
    if (!this.session) {
      // console.log('[AVSessionManager] Session 未初始化，跳过元数据更新');
      return;
    }

    try {
      const currentSong = music.musics?.[currentPlayIndex];
      if (!currentSong) {
        console.error('[AVSessionManager] 当前歌曲信息无效');
        return;
      }

      // 优先使用实际播放器获取的时长，如果没有则使用歌曲信息中的时长
      let duration = actualDuration;
      if (!duration || duration <= 0) {
        duration = currentSong.source_duration || music.duration || 0;
      }

      // console.log(`[AVSessionManager] 设置通知栏时长: ${duration}ms (实际播放器时长: ${actualDuration}ms)`);

      const metadata: avSession.AVMetadata = {
        assetId: String(currentSong.id || 0),
        title: music.title_cn || music.title_en || '未知歌曲',
        artist: music.description_cn || music.description_en || '未知艺术家',
        album: music.description_cn || music.description_en || '未知专辑',
        duration: duration,
        mediaImage: music.cover_image, // 封面图片 URL
      };

      await this.session.setAVMetadata(metadata);
      // console.log('[AVSessionManager] 元数据更新成功:', currentSong.name);
    } catch (error) {
      console.error('[AVSessionManager] 更新元数据失败:', error);
    }
  }

  /**
   * 更新播放状态
   */
  public async updatePlaybackState(
    state: avSession.PlaybackState,
    position: number = 0,
    speed: number = 1.0
  ): Promise<void> {
    if (!this.session) {
      // console.log('[AVSessionManager] Session 未初始化，跳过状态更新');
      return;
    }

    try {
      const playbackState: avSession.AVPlaybackState = {
        state: state,
        position: {
          elapsedTime: position,
          updateTime: Date.now()
        },
        speed: speed,
      };

      await this.session.setAVPlaybackState(playbackState);
      // console.log(`[AVSessionManager] 播放状态更新: ${state}, position=${position}ms`);
    } catch (error) {
      console.error('[AVSessionManager] 更新播放状态失败:', error);
    }
  }

  /**
   * 设置为播放状态
   */
  public async setPlaying(position: number = 0): Promise<void> {
    await this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PLAY, position, 1.0);
  }

  /**
   * 设置为暂停状态
   */
  public async setPaused(position: number = 0): Promise<void> {
    await this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE, position, 0);
  }

  /**
   * 设置为停止状态
   */
  public async setStopped(): Promise<void> {
    await this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_STOP, 0, 0);
  }

  /**
   * 销毁 Session
   */
  public async destroySession(): Promise<void> {
    if (this.session) {
      try {
        // 取消注册所有回调
        this.session.off('play');
        this.session.off('pause');
        this.session.off('playNext');
        this.session.off('playPrevious');
        this.session.off('seek');

        // 停用 Session
        if (this.isSessionActive) {
          await this.session.deactivate();
          this.isSessionActive = false;
        }

        // 销毁 Session
        await this.session.destroy();
        this.session = null;
        // console.log('[AVSessionManager] AVSession 销毁成功');
      } catch (error) {
        console.error('[AVSessionManager] 销毁 Session 失败:', error);
      }
    }
  }
}

export default AVSessionManager.getInstance();
