export interface Music {
  id?: number
  content_type?: number
  is_hot?: number
  is_new?: number
  is_free?: number
  isGuest?: number
  count?: number
  liked?: number
  is_published?: number
  play_type?: number
  play_count?: number
  user_ratings?: number
  favorite_count?: number
  like_count?: number
  favorited?: number
  duration?: number
  view_count?: number
  created_at?: number
  title_cn?: string
  title_en?: string
  description_cn?: string
  description_en?: string
  content_cn?: string
  content_en?: string
  cover_image?: string
  tags?: Tag[]
  musics?: Play[]
  playlists?: Music[]
}

export interface ChannelItem {
  id?: number
  title_cn?: string
  title_en?: string
  icon?: string | Resource
  sort_order?: number
  rotateAngle?: number
}

export interface Topic {
  url?: string
  img_url?: string
  closable?: boolean
  user_status?: boolean
}

export interface TabItem {
  name?: string
  selectedIcon?: Resource
  unselectedIcon?: Resource
  page?: string
}

export interface UserInfo {
  honorInfo?: HonorInfo
  messageRead?: number
  userInfo?: UInfo
  vipInfo?: VipInfo
}

export interface HonorInfo {
  honorNum?: number
  honorList?: Honor[]
}

export interface Honor {
  medal_id?: number
  name?: string
  img_small?:number
  img_big?:number
}

export interface VipInfo {
  vipType?: number
  vipExpireTime?: number
  member_type?:number
  free_play_days?:number
}

export interface UInfo {
  uid?: string
  nickname?: string
  avatar:string
}
export interface Tag {
  id?: number
  sort_order?: number
  name_cn?: string
  name_en?: string
}

export interface Url {
  type?: number
  agre_url?: string
  key?: string
  language?: string
  title?: string
  version?: string
}

export interface Wechat {
  app_id?: string
  partner_id?: string
  prepay_id?: string
  nonce_str?: string
  timestamp?: string
  sign?: string
  order_id?: string
}

export interface Product {
  id?: number
  type?: number
  cash?: number
  cash_type?: number
  benefit_type?: number
  benefit_value?: number
  code?: string
  name?: string
  description?: string
  unit?: string
}

export interface Play {
  id?: number
  duration?: number
  mp3_size?: number
  aac_size?: number
  x?: number
  sort_order?: number
  source_duration?: number
  name?: string
  alias?: string
  lyrics?: string
  description?: string
  source_address?: string
  music_address_1?: string
  music_address_2?: string
  local_music_address_2?: string
  music_address_3?: string
  music_address_4?: string
  music_address_5?: string
}

export interface IGlobalPlayerStore {
  // Properties
  playerListId: number;
  playerUri: string;
  list: string[];
  playerTime: number;
  playSchedule: number;
  playing: boolean;
  detailOpenType: string;
  playMethod: string;
  playListInfo: Music;
  playStatus: object;
  playingLoading: boolean;
  songDuration: number;
  songPlayedDuration: number;
  playId: number;

  // Methods
  setPlayerListId(id: number): void;
  setPlayerUri(uri: string): void;
  setAudioList(list: string[]): void;
  setPlayerTime(time: number): void;
  setPlaySchedule(schedule: number): void;
  setPlaying(isPlaying: boolean): void;
  setDetailOpenType(type: string): void;
  setPlayMethod(type: string): void;
  setPlayListInfo(data: Music): Promise<void>;
  setPlayState(status: object): void;
  setPlayingLoading(loading: boolean): void;
  setSongDuration(duration: number): void;
  setSongPlayedDuration(duration: number): void;
  setPlayId(id: number): void;
}

export interface Message {
  content?: string
  create_time?: string
  id?: number
  lang?: string
  messages_type?: string
  reference_id?: number
  title?: string
}

export interface PointEvent {
  event: string;  //事件名
  timestamp?: number; //时间戳
  platform?: string; //设备品牌
  uid?: string; //用户id
  session_id?: string;   //每次启动app生成1个新的
  uuid?: string;  //设备id  ，一直保持同一个？
  oaid?:string;
  aaid?:string;
  vaid?:string;
  ch?: string; //渠道
  error?: string;
  user_agent?: ESObject; //
  from_module?: string;
  page?: string;
  module?: string;
  ver?: string;  //app版本号
  imeicode?: string;
  signal_status?: string; // 信号状态
  network_type?: string; // 网络类型
  client_ip?: string; // 客户端ip
  event_type?: string;
  region?: string,
  extra?: ESObject;
  env: string | number;
}

// 免费歌单项数据接口
export interface FreePlaylistItem {
  "id":number;
  "content_type":number;
  "title_cn":string;
  "title_en":string;
  "description_cn":string;
  "description_en":string;
  "cover_image":string;
  "is_hot":number;
  "is_new":number;
  "is_free":number;
  "count":number;
  "favorite_count":number;
  "like_count":number;
  "favorited":number;
  "duration":number;
  "created_at":number

}

// 勋章数据接口
export interface Medal {
  medal_id: number;
  name: string;
  type: number;
  rule_desc: string;
  progress: number;
  max_progress: number;
  img_small: string;
  img_big: string;
  is_have: boolean;
  got_time: number;
  wear_status: number;
}

export interface MedalCategory {
  id: number;
  name: string;
  medals: Medal[];
}