export class PhoneValidator {
  /**
   * 验证手机号是否符合基本规则
   * @param phone 待验证的手机号字符串
   * @returns 验证结果对象 { isValid: boolean, message: string }
   */
  public static validate(phone: string): boolean {
    // 去除所有空白字符
    const cleanedPhone = phone.replace(/\s/g, '');

    const readonly = /^1[3-9]\d{9}$/;

    // 验证1: 是否为11位
    if (cleanedPhone.length !== 11) {
      console.log('================1')
      return false
    }

    // 验证2: 首位是否是1
    if (!cleanedPhone.startsWith('1')) {
      console.log('================2')
      return false;
    }

    // 验证3: 前两位
    if (!readonly.test(cleanedPhone)) {
      console.log('================3')
      return false;
    }

    // 验证4: 是否全部为数字
    if (!/^\d+$/.test(cleanedPhone)) {
      console.log('================4')
      return false;
    }

    return true;
  }

  /**
   * 快速验证手机号是否有效
   * @param phone 待验证的手机号字符串
   * @returns 是否有效的布尔值
   */
  public static isValid(phone: string): boolean {
    const cleanedPhone = phone.replace(/\s/g, '');
    return cleanedPhone.length === 11 &&
    cleanedPhone.startsWith('1') &&
    /^\d+$/.test(cleanedPhone);
  }
}