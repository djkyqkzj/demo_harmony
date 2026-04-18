import { StorageUtil } from '../../common/utils/StorageUtil';
import { getUserInfoApi } from '../http/Api';
import { EventBus } from '../utils/EventBus';
import { IGlobalPlayerStore, Music } from './Model';
import { StorageConstants } from './StorageConstants';

class GlobalPlayerStore implements IGlobalPlayerStore {
  // 当前播放列表 ID
  public _playerListId: number = 0;

  public get playerListId(): number {
    return this._playerListId;
  }

  // 当前播放 URL
  public _playerUri: string = "";

  public get playerUri(): string {
    return this._playerUri;
  }

  // 播放列表
  public _list: string[] = [];

  public get list(): string[] {
    return this._list;
  }

  // 剩余播放时间
  public _playerTime: number = 0;

  public get playerTime(): number {
    return this._playerTime;
  }

  // 播放进度
  public _playSchedule: number = 0;

  public get playSchedule(): number {
    return this._playSchedule;
  }

  // 是否正在播放
  public _playing: boolean = false;

  public get playing(): boolean {
    return this._playing;
  }

  // 详情页打开方式
  public _detailOpenType: string = "right";

  public get detailOpenType(): string {
    return this._detailOpenType;
  }

  // 播放方式
  public _playMethod: string = "list";

  public get playMethod(): string {
    return this._playMethod;
  }

  // 播放列表信息
  public _playListInfo: Music = {};

  public get playListInfo(): Music {
    return this._playListInfo;
  }

  // 播放状态信息
  public _playStatus: ESObject = {};

  public get playStatus(): ESObject {
    return this._playStatus;
  }

  // 是否正在加载
  public _playingLoading: boolean = false;

  public get playingLoading(): boolean {
    return this._playingLoading;
  }

  // 歌曲总时长(秒)
  public _songDuration: number = 0;

  public get songDuration(): number {
    return this._songDuration;
  }

  // 已播放时长(秒)
  public _songPlayedDuration: number = 0;

  public get songPlayedDuration(): number {
    return this._songPlayedDuration;
  }

  // 当前播放ID
  public _playId: number = 0;

  public get playId(): number {
    return this._playId;
  }



  // 设置当前播放列表ID
  setPlayerListId(id: number): void {
    this._playerListId = id;
  }

  // 设置当前播放URL
  setPlayerUri(uri: string): void {
    this._playerUri = uri;
  }

  // 设置播放列表
  setAudioList(list: string[]): void {
    this._list = [...list];
  }

  // 设置剩余播放时间
  setPlayerTime(time: number): void {
    this._playerTime = time;
  }

  // 设置播放进度
  setPlaySchedule(schedule: number): void {
    this._playSchedule = schedule;
  }

  // 设置播放状态
  setPlaying(isPlaying: boolean): void {
    this._playing = isPlaying;
  }

  // 设置详情页打开方式
  setDetailOpenType(type: string): void {
    this._detailOpenType = type;
  }

  // 设置播放方式
  setPlayMethod(type: string): void {
    this._playMethod = type;
  }

  // 设置播放列表信息
  async setPlayListInfo(data: Music): Promise<void> {
    this._playListInfo = data;

    // 获取用户信息
    try {
      const isLoggedIn = await StorageUtil.getBoolean(StorageConstants.IS_LOGGED_IN, false)
      if (isLoggedIn) {
        const uid = await StorageUtil.getString(StorageConstants.UID, '')
        if (data && data.id && data.id > 0) {
          await StorageUtil.put(`${uid}-playListInfoHistory`, data);
        }

        const res = await getUserInfoApi();
        if (res.code === 200) {
          StorageUtil.put(StorageConstants.USER_INFO, res.data)
          StorageUtil.putString(StorageConstants.NICK_NAME, res.data.userInfo.nickname)
          StorageUtil.putString(StorageConstants.AVATAR, res.data.userInfo.avatar)
          EventBus.send(StorageConstants.UPDATE_NICKNAME, res.data.userInfo.nickname)
          EventBus.send(StorageConstants.UPDATE_AVATAR, res.data.userInfo.avatar)
        }
      }
    } catch (error) {
      console.error('Failed to handle play list info:', error);
    }
  }

  // 其他setter方法...
  setPlayState(status: object): void {
    this._playStatus = status;
  }

  setPlayingLoading(loading: boolean): void {
    this._playingLoading = loading;
  }

  setSongDuration(duration: number): void {
    this._songDuration = duration;
  }

  setSongPlayedDuration(duration: number): void {
    this._songPlayedDuration = duration;
  }

  setPlayId(id: number): void {
    this._playId = id;
  }
}

// 创建全局单例
const globalPlayerStore = new GlobalPlayerStore();

export default globalPlayerStore;