import preferences from '@ohos.data.preferences'
import { Context } from '@kit.AbilityKit';

export class StorageUtil {
  private static preferencesInstance: preferences.Preferences | null = null

  static async initialize(context: Context): Promise<void> {
    try {
      StorageUtil.preferencesInstance = await preferences.getPreferences(context, 'app_preferences')
    } catch (err) {
      console.error(`Failed to initialize preferences. Code: ${err.code}, message: ${err.message}`)
    }
  }

  static getStringSync(key: string, defaultValue: string = ''): string {
    if (!StorageUtil.preferencesInstance) {
      console.error('Preferences not initialized')
      return defaultValue
    }

    try {
      // 注意：Preferences API 没有真正的同步方法
      // 这里使用 try-catch 封装，适用于简单场景
      // 如果需要真正的同步，考虑使用其他同步存储方案
      const value = StorageUtil.preferencesInstance.getSync(key, defaultValue)
      return typeof value === 'string' ? value : defaultValue
    } catch (err) {
      console.error(`Sync get error. Code: ${err.code}, message: ${err.message}`)
      return defaultValue
    }
  }

  static async put(key: string, value: Object) {
    if (typeof value === "object") {
      if (Array.isArray(value)) {
        await StorageUtil.putValue(key, JSON.stringify(value));
      } else {
        await StorageUtil.putValue(key, JSON.stringify(value));
      }
    } else {
      await StorageUtil.putValue(key, value);
    }
  }

  static async get(key: string): Promise<Object | undefined> {
    let value: Object | undefined = undefined;
    value = await StorageUtil.getValue(key);
    return value;
  }

  // 字符串操作
  static async putString(key: string, value: string): Promise<void> {
    await StorageUtil.putValue(key, value)
  }

  static async getString(key: string, defaultValue: string): Promise<string> {
    const value = await StorageUtil.getValue(key)
    return typeof value === 'string' ? value : defaultValue
  }

  // 布尔值操作（添加类型转换）
  static async putBoolean(key: string, value: boolean): Promise<void> {
    await StorageUtil.putValue(key, value)
  }

  static async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    const value = await StorageUtil.getValue(key)
    if (typeof value === 'boolean') {
      return value
    }
    // 处理字符串形式的布尔值
    if (typeof value === 'string') {
      return value === 'true'
    }
    return defaultValue
  }

  // 数字操作
  static async putNumber(key: string, value: number): Promise<void> {
    await StorageUtil.putValue(key, value)
  }

  static async getNumber(key: string, defaultValue: number): Promise<number> {
    const value = await StorageUtil.getValue(key)
    return typeof value === 'number' ? value : defaultValue
  }

  // 私有方法处理基础存储操作
  private static async putValue(key: string, value: preferences.ValueType): Promise<void> {
    if (!StorageUtil.preferencesInstance) {
      console.error('Preferences not initialized')
      return
    }
    try {
      await StorageUtil.preferencesInstance.put(key, value)
      await StorageUtil.preferencesInstance.flush()
    } catch (err) {
      console.error(`Storage error. Code: ${err.code}, message: ${err.message}`)
    }
  }

  private static async getValue(key: string): Promise<preferences.ValueType | undefined> {
    if (!StorageUtil.preferencesInstance) {
      console.error('Preferences not initialized')
      return undefined
    }
    try {
      return await StorageUtil.preferencesInstance.get(key, undefined)
    } catch (err) {
      console.error(`Retrieval error. Code: ${err.code}, message: ${err.message}`)
      return undefined
    }
  }

  // 删除数据
  static async remove(key: string): Promise<void> {
    if (!StorageUtil.preferencesInstance) {
      console.error('Preferences not initialized')
      return
    }
    try {
      await StorageUtil.preferencesInstance.delete(key)
      await StorageUtil.preferencesInstance.flush()
    } catch (err) {
      console.error(`Deletion error. Code: ${err.code}, message: ${err.message}`)
    }
  }

  // 清空存储
  static async clear(): Promise<void> {
    if (!StorageUtil.preferencesInstance) {
      console.error('Preferences not initialized')
      return
    }
    try {
      await StorageUtil.preferencesInstance.clear()
      await StorageUtil.preferencesInstance.flush()
    } catch (err) {
      console.error(`Clear error. Code: ${err.code}, message: ${err.message}`)
    }
  }
}