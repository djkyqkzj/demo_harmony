import http from '@ohos.net.http';

interface IPResponse {
  ip?: string;
  ipAddress?: string;
}

export class PublicIPUtil {
  /**
   * 通过多个服务获取公网IP（提高成功率）
   */
  public static async getPublicIPWithFallback(): Promise<string> {
    const ipServices = [
      'https://api.ipify.org?format=json',
      'https://api.my-ip.io/ip.json',
      'https://ipapi.co/json/'
    ];

    for (const service of ipServices) {
      try {
        const ip = await PublicIPUtil.getIPFromService(service);
        if (ip && ip !== '0.0.0.0') {
          return ip;
        }
      } catch (error) {
        console.warn(`IP服务 ${service} 失败:`, error);
        continue;
      }
    }

    return '0.0.0.0';
  }

  /**
   * 从指定服务获取IP
   */
  private static async getIPFromService(url: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });

      if (response.responseCode === 200) {
        const result: IPResponse = JSON.parse(response.result.toString());
        return result.ip || result.ipAddress || '0.0.0.0';
      }
      return '0.0.0.0';
    } catch (error) {
      throw new Error(`获取IP失败: ${error}`);
    } finally {
      httpRequest.destroy();
    }
  }
}