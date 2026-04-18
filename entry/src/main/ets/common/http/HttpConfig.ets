/**
 * 网络请求配置
 */
interface IEnvironmentConfig {
  API: string;
  REPORT: string;
  AGREEMENT: string;
  IMG: string;
}

type EnvironmentType = 'development' | 'alpha' | 'production';

const DEVELOPMENT_CONFIG: IEnvironmentConfig = {
  API: 'https://appapi.demo.art',
  REPORT: 'https://r.demo.art',
  AGREEMENT: 'https://img.demo.art',
  IMG: 'https://img.demo.art/app/medal/',
};

const ALPHA_CONFIG: IEnvironmentConfig = {
  API: 'http://192.168.100.231:4006',
  REPORT: 'https://r.demo.art',
  AGREEMENT: 'https://img.demo.art',
  IMG: 'https://img.demo.art/app/medal/',
};

const PRODUCTION_CONFIG: IEnvironmentConfig = {
  API: 'https://appapi.demo.art',
  REPORT: 'https://r.demo.art',
  AGREEMENT: 'https://img.demo.art',
  IMG: 'https://img.demo.art/app/medal/',
};

export class HttpConfig {
  // 当前环境类型
  private static currentEnvType: EnvironmentType = 'production';

  public static readonly CUSTOM_ENV: number = 1 // 0:测试环境 1:正式环境

  // 环境配置映射
  private static readonly envConfigMap: Map<EnvironmentType, IEnvironmentConfig> = new Map([
    ['development', DEVELOPMENT_CONFIG],
    ['alpha', ALPHA_CONFIG],
    ['production', PRODUCTION_CONFIG]
  ]);

  // 获取当前配置
  private static get currentConfig(): IEnvironmentConfig {
    return this.envConfigMap.get(this.currentEnvType) || PRODUCTION_CONFIG;
  }

  public static get API(): string {
    return this.currentConfig.API;
  }

  public static get REPORT(): string {
    return this.currentConfig.REPORT;
  }

  public static get AGREEMENT(): string {
    return this.currentConfig.AGREEMENT;
  }

  public static get IMG(): string {
    return this.currentConfig.IMG;
  }
  /**
   * 设置当前环境
   * @param envType 环境类型
   */
  public static setEnvironment(envType: EnvironmentType): void {
    if (HttpConfig.CUSTOM_ENV === 0){
      if (['development', 'alpha', 'production'].includes(envType)) {
        HttpConfig.currentEnvType = envType;
      }
    } else {
      HttpConfig.currentEnvType = 'production'
    }

  }

  public static containsHttpOrHttps(str: string): boolean {
    const urlPattern = /^https?:\/\//i;
    return urlPattern.test(str);
  }

}