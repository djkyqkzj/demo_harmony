import common from '@ohos.app.ability.common';
import connection from '@ohos.net.connection';
import { BusinessError } from '@ohos.base';

export class NetworkUtils {
  private static instance: NetworkUtils | null = null;
  private netConnection: connection.NetConnection | null = null;
  private context: common.Context;

  private constructor(context: common.Context) {
    this.context = context;
  }

  public static getInstance(context: common.Context): NetworkUtils {
    if (!NetworkUtils.instance) {
      NetworkUtils.instance = new NetworkUtils(context);
    }
    return NetworkUtils.instance;
  }

  /**
   * 注册网络状态监听
   */
  public registerNetworkListener(callback: (isConnected: boolean, networkType: string) => void): void {
    if (this.netConnection) {
      console.warn('网络监听已存在，请先取消之前的监听');
      return;
    }

    try {
      // 1. 创建网络连接监听器
      this.netConnection = connection.createNetConnection();

      // 2. 设置监听回调
      this.netConnection.on('netAvailable', async (data) => {
        console.log('网络已连接:', JSON.stringify(data));
        const type = await this.getNetworkType();
        callback(true, type);
      });

      this.netConnection.on('netCapabilitiesChange', async (data) => {
        console.log('网络能力变化:', JSON.stringify(data));
        const type = await this.getNetworkType();
        callback(true, type);
      });

      this.netConnection.on('netUnavailable', () => {
        console.log('网络不可用');
        callback(false, 'none');
      });

      this.netConnection.on('netLost', () => {
        console.log('网络丢失');
        callback(false, 'none');
      });

      // 3. 注册监听
      this.netConnection.register((err: BusinessError) => {
        if (err) {
          console.error('注册网络监听失败:', JSON.stringify(err));
          this.netConnection = null;
        } else {
          console.log('网络监听注册成功');
        }
      });

    } catch (error) {
      console.error('创建网络监听失败:', JSON.stringify(error));
      this.netConnection = null;
    }
  }

  /**
   * 取消网络状态监听
   */
  public unregisterNetworkListener(): void {
    if (!this.netConnection) {
      console.warn('没有活跃的网络监听可取消');
      return;
    }

    try {
      // 1. 取消注册
      this.netConnection.unregister((err: BusinessError) => {
        if (err) {
          console.error('取消网络监听失败:', JSON.stringify(err));
        } else {
          console.log('网络监听取消成功');
        }
        this.netConnection = null;
      });

    } catch (error) {
      console.error('取消网络监听异常:', JSON.stringify(error));
      this.netConnection = null;
    }
  }

  /**
   * 检查网络连接状态
   */
  public async isConnected(): Promise<boolean> {
    try {
      const netHandle = await connection.getDefaultNet();
      return netHandle !== null;
    } catch (error) {
      console.error('检查网络连接失败:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * 获取当前网络类型
   */
  public async getNetworkType(): Promise<string> {
    try {
      const netHandle = await connection.getDefaultNet();
      if (!netHandle) return 'none';

      const netCap = await connection.getNetCapabilities(netHandle);
      if (!netCap) return 'unknown';

      // 使用类型守卫确保 bearerTypes 存在且是数组
      if ('bearerTypes' in netCap && Array.isArray(netCap.bearerTypes)) {
        if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
          return 'wifi';
        } else if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
          return 'cellular';
        } else if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
          return 'ethernet';
        }
      }
      return 'unknown';
    } catch (error) {
      console.error('获取网络类型失败:', JSON.stringify(error));
      return 'unknown';
    }
  }

  /**
   * 销毁实例
   */
  public static destroyInstance(): void {
    if (NetworkUtils.instance) {
      NetworkUtils.instance.unregisterNetworkListener();
      NetworkUtils.instance = null;
    }
  }
}