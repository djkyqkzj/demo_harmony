import { promptAction } from '@kit.ArkUI';

export class FastToast {
  static showToastDuration(message: ResourceStr | string, duration: number) {
    promptAction.showToast({ message: message, duration: duration, alignment: 0 || 1,  offset: { dx: 0, dy: 30 } });
  }

  static showToast(message: ResourceStr | string) {
    FastToast.showToastDuration(message, 3000);
  }

  static longToast(message: ResourceStr | string) {
    FastToast.showToastDuration(message, 5000);
  }
}