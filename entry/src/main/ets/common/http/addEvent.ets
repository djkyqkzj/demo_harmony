import { PointEvent } from "../constants/Model";
import { StorageConstants } from "../constants/StorageConstants";
import { StorageUtil } from "../utils/StorageUtil";
import util from '@ohos.util';
import HttpRequest from "./HttpRequest";
import { FastTool } from "../utils/FastTool";
import { deviceInfo } from "@kit.BasicServicesKit";
import network from '@system.network';
import { LanguageUtils } from "../utils/LanguageUtils";
import { PublicIPUtil } from "../utils/PublicIPUtil";
import { reportPointEvents } from "./Api";
import { HttpConfig } from "./HttpConfig";

interface UA {
  ver?: string;
  bi?: string;
  dn?: string;
  v?: string;
  s?: number;
  t?: string;
  c?: string;
  ov?: string;
  sca?: string[];
  it?: string;
  oaid?: string;
  aaid?: string;
  vaid?: string;
  br?: string;
  deviceId?: string
}

interface Event{
  eventID: string,
  event_type: string,
  extra?: Extra,
  module?: string,
  fromModule?: string,
  customImeicode?: string,
  customPlatform?: string,
  customVer?: string
}

interface Extra{
  target_id?: string | number
  is_success?: number
  error?: string
  target_type?: string | number | undefined
  target_name?: string
  type?: string
}

export class AddEvent {
  /**
   * 添加加载事件
   * @param eventID 事件ID
   * @param extra 额外参数
   * @param module 模块名
   * @param fromModule 来源模块
   */
  public static async addLoadEvent(eventID: string, extra?: Extra, module?: string, fromModule?: string): Promise<void> {
    const params: Event = {
      eventID,
      event_type: "load",
      extra,
      module,
      fromModule
    }
    await AddEvent.addPointEvent(params);
  }

  /**
   * 添加点击事件
   * @param eventID 事件ID
   * @param extra 额外参数
   * @param module 模块名
   * @param fromModule 来源模块
   */
  public static async addClickEvent(eventID: string, extra?: Extra, module?: string, fromModule?: string): Promise<void> {
    const params: Event = {
      eventID,
      event_type: "load",
      extra,
      module,
      fromModule
    }
    await AddEvent.addPointEvent(params);
  }

  /**
   * 添加曝光事件
   * @param eventID 事件ID
   * @param extra 额外参数
   * @param module 模块名
   * @param fromModule 来源模块
   */
  public static async addEventEvent(eventID: string, extra?: Extra, module?: string, fromModule?: string): Promise<void> {
    const params: Event = {
      eventID,
      event_type: "event",
      extra,
      module,
      fromModule
    }
    await AddEvent.addPointEvent(params);
  }

  /**
   * 私有方法：添加埋点事件
   */
  private static async addPointEvent(params: Event): Promise<void> {
    try {
      // 构建埋点数据
      const uid = await StorageUtil.getString(StorageConstants.UID, '')
      const sessionid = util.generateRandomUUID();
      let strArray: string[] = [];
      strArray.push(deviceInfo?.hardwareModel)
      let UA: UA = {
        ver: 'demo', // App名称
        bi: FastTool.bundleName || '', // 包名
        dn: deviceInfo.marketName, // 设备名称
        v: FastTool.getVersionName, // 版本号
        s: 0, // 状态栏高度
        t: 'android', // 平台
        c: 'harmony', // 渠道
        ov: deviceInfo?.osFullName || '', // 操作系统版本
        sca: strArray, // 支持的CPU架构
        it: deviceInfo.deviceType == 'tablet' ? "1" : "0",
        oaid: await HttpRequest.GetSystemOAID() || '',
        aaid: await HttpRequest.GetSystemAAID() || '',
        vaid:'',
        br: deviceInfo?.brand || '',
        deviceId: await HttpRequest.GetDeviceId() || '',
      }

      const event: PointEvent = {
        event: params.eventID,
        timestamp: Date.now(),
        platform: 'android',
        uid: uid,
        uuid: await HttpRequest.GetSystemOAID() || '',
        oaid: await HttpRequest.GetSystemAAID() || '',
        aaid: await HttpRequest.GetSystemAAID() || '',
        vaid:'',
        session_id: sessionid,
        ch: 'harmony',
        user_agent: UA,
        from_module: params.fromModule ? params.fromModule : "",
        page: "",
        module: params.module ? params.module : "",
        ver: params.customVer || FastTool.getVersionName,
        imeicode: "",
        signal_status: "",
        network_type: await AddEvent.getNetworkType() || '',
        client_ip: await PublicIPUtil.getPublicIPWithFallback() || '',
        event_type: params.event_type,
        region: LanguageUtils.getSystemRegion() || 'cn',
        extra: params.extra|| {},
        env: HttpConfig.CUSTOM_ENV,

      };

      await reportPointEvents(event)

    } catch (error) {
      console.error('埋点上报失败:', error);
      // 可以根据需要决定是否抛出错误
      // throw error;
    }
  }

  public static getNetworkType(): Promise<string> {
    return new Promise((resolve, reject) => {
      network.getType({
        success: (data) => {
          console.info('获取网络类型成功:', data.type);
          resolve(data.type);
        },
        fail: (error: string, code: number) => {
          console.error('获取网络类型失败:', error, code);
          resolve('unknown');
        }
      });
    });
  }

}