/**
 * 时间工具类 (HarmonyOS ArkTS 严格模式版本)
 */

interface FormatObj {
  YYYY: number;
  MM: string;
  DD: string;
  HH: string;
  mm: string;
  ss: string;
}

export class TimeUtils {
/**
 * 获取当前日期 (格式: YYYY-MM-DD)
 * @returns {string} 例如: 2025-01-02
 */
static getCurrentDate(): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = TimeUtils.padZero(date.getMonth() + 1);
  const day = TimeUtils.padZero(date.getDate());
  return `${year}-${month}-${day}`;
}

/**
 * 获取当前时间 (格式: HH:mm)
 * @returns {string} 例如: 12:30
 */
static getCurrentTime(): string {
  const date = new Date();
  const hours = TimeUtils.padZero(date.getHours());
  const minutes = TimeUtils.padZero(date.getMinutes());
  return `${hours}:${minutes}`;
}

/**
 * 获取当前完整日期时间 (格式: YYYY-MM-DD HH:mm:ss)
 * @returns {string} 例如: 2025-04-24 10:22:33
 */
static getCurrentDateTime(): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = TimeUtils.padZero(date.getMonth() + 1);
  const day = TimeUtils.padZero(date.getDate());
  const hours = TimeUtils.padZero(date.getHours());
  const minutes = TimeUtils.padZero(date.getMinutes());
  const seconds = TimeUtils.padZero(date.getSeconds());
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

/**
 * 格式化指定的日期时间
 * @param date Date对象或时间戳
 * @param format 格式化模板
 * @returns {string} 格式化后的时间字符串
 */
static formatDateTime(date: Date | number, format: string): string {
  let d: Date;
  if (typeof date === 'number') {
    d = new Date(date);
  } else {
    d = date;
  }

  const formatObj: FormatObj = {
    YYYY: d.getFullYear(),
    MM: TimeUtils.padZero(d.getMonth() + 1),
    DD: TimeUtils.padZero(d.getDate()),
    HH: TimeUtils.padZero(d.getHours()),
    mm: TimeUtils.padZero(d.getMinutes()),
    ss: TimeUtils.padZero(d.getSeconds())
  };

  return format.replace(/(YYYY|MM|DD|HH|mm|ss)/g, (match: string) => {
    switch (match) {
      case 'YYYY':
        return formatObj.YYYY.toString();
      case 'MM':
        return formatObj.MM;
      case 'DD':
        return formatObj.DD;
      case 'HH':
        return formatObj.HH;
      case 'mm':
        return formatObj.mm;
      case 'ss':
        return formatObj.ss;
      default:
        return match;
    }
  });
}

/**
 * 将时间戳转换为指定格式的时间字符串
 * @param timestamp 时间戳（毫秒）
 * @param format 格式化模板
 * @returns {string} 格式化后的时间字符串
 */
static timestampToDateTime(timestamp: number, format: string): string {
  const totalSeconds = Math.floor(timestamp / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (format === 'HH:mm:ss') {
    return `${TimeUtils.padZero(hours)}:${TimeUtils.padZero(minutes)}:${TimeUtils.padZero(seconds)}`;
  } else if (format === 'mm:ss') {
    return `${TimeUtils.padZero(minutes)}:${TimeUtils.padZero(seconds)}`;
  }

  return TimeUtils.formatDateTime(timestamp, format);
}

  static getVipExpireDate(expireTimestamp: number): string {
    const date = new Date(expireTimestamp * 1000);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${year}.${month}.${day}`;
  };

/**
 * 获取今天的开始时间（00:00:00）
 * @returns {Date}
 */
static getTodayStart(): Date {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  return date;
}

/**
 * 获取今天的结束时间（23:59:59）
 * @returns {Date}
 */
static getTodayEnd(): Date {
  const date = new Date();
  date.setHours(23, 59, 59, 999);
  return date;
}

/**
 * 补零方法
 * @param num 数字
 * @returns 补零后的字符串
 */
private static padZero(num: number): string {
  return num < 10 ? `0${num}` : num.toString();
}
}

// 使用示例
// @Entry
// @Component
// struct TimeExample {
//     build() {
//         Column() {
//             Text(`当前日期: ${TimeUtils.getCurrentDate()}`)
//             Text(`当前时间: ${TimeUtils.getCurrentTime()}`)
//             Text(`完整日期时间: ${TimeUtils.getCurrentDateTime()}`)
//             Text(`格式化日期: ${TimeUtils.formatDateTime(new Date(), 'YYYY年MM月DD日')}`)
//             Text(`时间戳转换: ${TimeUtils.timestampToDateTime(Date.now(), 'HH:mm:ss')}`)
//         }
//         .width('100%')
//         .height('100%')
//         .justifyContent(FlexAlign.Center)
//         .alignItems(HorizontalAlign.Center)
//     }
// }