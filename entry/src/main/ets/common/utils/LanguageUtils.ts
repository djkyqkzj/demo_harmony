import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { StorageUtil } from './StorageUtil';


/**
 * 语言工具类，用于获取和设置系统语言、区域及货币信息
 */
export class LanguageUtils {
  /**
   * 获取系统当前语言
   * @returns 当前系统语言代码（如 "zh"、"en"）
   */

  static getSystemLanguage(): string {
    const language = StorageUtil.getStringSync('language','')
    if(language){
      return language
    }
    try {
      const fullLanguage = i18n.System.getSystemLanguage();

      let locale = new Intl.Locale(fullLanguage);
      return locale.language;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return 'zh';
    }
  }

  /**
   * 获取系统当前区域
   * @returns 当前系统区域代码（如 "CN"、"US"）
   */
  static getSystemRegion(): string {
    try {
      const region = i18n.System.getSystemRegion();
      return region.toLowerCase();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return 'cn';
    }
  }

  /**
   * 获取系统Locale标识（语言+区域组合）
   * @returns 当前系统Locale（如 "zh-Hans-CN"）
   */
  static getSystemLocale(): string {
    try {
      return i18n.System.getSystemLocale();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return 'en-US'; // 默认返回美式英语
    }
  }

  /**
   * 设置应用偏好语言（不影响系统语言）
   * @param languageCode 语言代码（如 "zh-Hans"）
   */
  static setAppPreferredLanguage(languageCode: string): void {
    try {
      i18n.System.setAppPreferredLanguage(languageCode);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
    }
  }

  /**
   * 获取系统支持的所有语言列表
   * @returns 支持的语言代码数组
   */
  static getSupportedLanguages(): string[] {
    try {
      return i18n.System.getSystemLanguages();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return ['en']; // 默认返回英文
    }
  }

  /**
   * 判断当前是否为镜像语言（如阿拉伯语RTL布局）
   * @returns 是否是镜像语言
   */
  static isMirrorLanguage(): boolean {
    const language = this.getSystemLanguage();
    // 镜像语言通常包括阿拉伯语（ar）、希伯来语（he）等
    return ['ar', 'he', 'fa', 'ug'].includes(language);
  }

  /**
   * 判断当前是否为特定语言（如中文）
   * @param targetLanguage 目标语言代码
   * @returns 是否匹配
   */
  static isCurrentLanguage(targetLanguage: string): boolean {
    return this.getSystemLanguage() === targetLanguage;
  }
  static getSystemCurrency(): string {
    try {
      const region = this.getSystemRegion();
      return this.getCurrencyByRegion(region);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return 'USD'; // 默认返回美元
    }
  }

  /**
   * 根据区域代码获取对应货币（部分常见国家映射）
   * @param regionCode 区域代码（如 "CN"、"US"）
   * @returns ISO 4217货币代码
   */
  private static getCurrencyByRegion(regionCode: string): string {
    const currencyMap: Record<string, string> = {
      CN: 'CNY', // 中国-人民币
      US: 'USD', // 美国-美元
      JP: 'JPY', // 日本-日元
      GB: 'GBP', // 英国-英镑
      EU: 'EUR', // 欧盟-欧元
      KR: 'KRW', // 韩国-韩元
      RU: 'RUB', // 俄罗斯-卢布
      HK: 'HKD', // 香港-港币
      TW: 'TWD', // 台湾-新台币
      IN: 'INR', // 印度-卢比
    };
    return currencyMap[regionCode] || 'USD'; // 默认返回美元
  }

  /**
   * 获取人民币符号（CNY）
   * @returns "¥"符号
   */
  static getCNYSymbol(): string {
    return '¥'; // 人民币符号固定为¥
  }

  /**
   * 获取当前货币符号（动态根据区域）
   * @returns 对应货币符号（如 "$"、"¥"、"€"）
   */
  static getCurrentCurrencySymbol(): string {
    const currency = this.getSystemCurrency();
    const symbolMap: Record<string, string> = {
      CNY: '¥',
      USD: '$',
      EUR: '€',
      GBP: '£',
      JPY: '¥',
      KRW: '₩',
    };
    return symbolMap[currency] || '$';
  }

  /**
   * 判断当前货币是否为人民币
   * @returns 是否是CNY
   */
  static isCNY(): boolean {
    return this.getSystemCurrency() === 'CNY';
  }
}
