// src/main/ets/common/constants/StorageConstants.ets

/**
 * 本地存储键名常量
 */
export abstract class StorageConstants {
  // 是否是第一次启动
  public static readonly IS_FIRST_LAUNCH: string = 'is_first_launch'

  // 用户登录状态
  public static readonly IS_LOGGED_IN: string = 'is_logged_in'

  // 用户Token
  public static readonly TOKEN: string = 'token'

  // 用户信息
  public static readonly USER_INFO: string = 'userInfo'

  // 用户ID
  public static readonly UID: string = 'uid'

  // 用户名
  public static readonly NICK_NAME: string = 'nickname'

  // 用户头像
  public static readonly AVATAR: string = 'avatar'

  // 更新用户名
  public static readonly UPDATE_NICKNAME: string = 'update_nickname'

  // 更新用户名
  public static readonly UPDATE_WELCOME: string = 'update_welcome'

  public static readonly UPDATE_TAB: string = 'update_tab'

  // 更新用户头像
  public static readonly UPDATE_AVATAR: string = 'update_avatar'

  // 语言设置
  public static readonly LANGUAGE: string = 'language'
  public static readonly UPDATE_TOPIC: string = 'update_topic'
  public static readonly UPDATE_VIP: string = 'update_vip'
  public static readonly APP_SHARE: string = 'app_share'

  public static readonly CHECK_IN1: string = 'checkIn1'
  public static readonly CHECK_IN2: string = 'checkIn2'
  public static readonly REFRESH: string = 'refresh'


  // 更新收藏
  public static readonly HOME_COLLECT: string = 'homeCollect'
  public static readonly HOME_COLLECT_CHANNEL: string = 'homeCollectChannel'
  public static readonly HOME_COLLECT_COLLECT: string = 'homeCollectList'


  public static readonly APP_ID = 'wx212857d7a976d03e'
  public static readonly APP_SECRET = '3053ed4a47583182164528e7d56d21a8'

  // 播放器事件
  static readonly PLAYER_STATE_CHANGE: string = 'player_state_change';
  static readonly PLAYER_TIME_UPDATE: string = 'player_time_update';
  static readonly PLAYER_ERROR: string = 'player_error';
  static readonly PLAYER_COMPLETED: string = 'player_completed';
  
  // AVSession 命令事件（新增）
  static readonly AVSESSION_COMMAND: string = 'avsession_command';
  static readonly TIMER_PLAY_START: string = 'timer_play_start';
  static readonly TIMER_PLAY_STOP: string = 'timer_play_stop';
  static readonly TIMER_PLAY_UPDATE: string = 'timer_play_update';
  static readonly START_BACKGROUND_TASK: string = 'start_background_task';
  static readonly STOP_BACKGROUND_TASK: string = 'stop_background_task';
}