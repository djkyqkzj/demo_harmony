import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class FastTool {
  // 获取应用包名的方法
  public static get bundleName(): string {
    const info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
    return info.name;
  }

  // 获取App名称
  public static get appName(): string {
    const info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    return info.appInfo.label;
  }

  // 获取App版本号
  public static get getVersionName(): string {
    const info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
    return info.versionName;
  }

  // 获取App版本号code
  public static get getVersionCode(): number {
    const info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
    return info.versionCode;
  }

  public static getString(res: string | Resource): string {
    try {
      if (typeof res === 'string') {
        return res;
      }
      return getContext().resourceManager.getStringSync(res.id); // 同步获取资源字符串
    } catch (error) {
      return '';
    }
  }

  public static getUri(filePath: string): string {
    return `file://${filePath}`;
  }
}