// src/main/ets/common/http/HttpRequest.ets
import http from '@ohos.net.http'
import { HttpConfig } from './HttpConfig'
import { StorageUtil } from '../utils/StorageUtil'
import { FastTool } from '../utils/FastTool'
import { StorageConstants } from '../constants/StorageConstants'
import { BusinessError } from '@ohos.base'
import { deviceInfo } from '@kit.BasicServicesKit';
import util from '@ohos.util';
import router from '@ohos.router';
import { abilityAccessCtrl } from '@kit.AbilityKit'
import { identifier } from '@kit.AdsKit'
import { AAID } from '@kit.PushKit'
import { LanguageUtils } from '../utils/LanguageUtils'
import { common } from "@kit.AbilityKit";
import fileIO from '@ohos.fileio';
import fs from '@ohos.file.fs';

// 1. 定义严格的类型接口
interface HttpResponse {
  code: number | string
  message: string
  data: ESObject
  list: ESObject
  retcode: number | string
  errmsg: string
}

interface HttpError {
  code: number
  message: string
}

// 在类定义前添加文件上传相关类型
interface UploadFileOptions {
  filePath: string
  fileName: string
  formData?: Record<string, string | number>
}

interface UploadFileItem {
  filename: string
  name: string
  uri: string
  type: string
}

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

interface MimeTypes {
  jpg: string
  jpeg: string
  png: string
  gif: string
  bmp: string
  webp: string
  heic: string
  heif: string
}

interface UploadRequestOptions extends http.HttpRequestOptions {
  files?: UploadFileItem[]
  data?: Record<string, string | number>
}

interface GeneratedObjectLiteralInterface_1 {}

class HttpRequest {
  private static instance: HttpRequest
  private httpRequest: http.HttpRequest

  private constructor() {
    this.httpRequest = http.createHttp()
  }

  public static getInstance(): HttpRequest {
    if (!HttpRequest.instance) {
      HttpRequest.instance = new HttpRequest()
    }
    return HttpRequest.instance
  }

  static async GetSystemOAID() {
    try {
      // 首先需要获取用户授权
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      let authRes = await atManager.requestPermissionsFromUser(getContext(), ["ohos.permission.APP_TRACKING_CONSENT"])
      if (authRes.authResults[0] == 0) {
        let oaid = await identifier.getOAID();
        return oaid
      } else {
        return "";
      }
    } catch (err) {
      return "";
    }
  }

  static async GetSystemAAID(): Promise<string> {
    try {
      let aaid = await AAID.getAAID()
      return aaid
    } catch (e) {
      return "";
    }
  }

  static async GetDeviceId() {
    let oaid = await HttpRequest.GetSystemOAID()

    if (oaid !== '' && oaid !== '00000000-0000-0000-0000-000000000000') {
      return oaid
    }
    let aaid = await HttpRequest.GetSystemAAID()
    return aaid
  }

  private async getHeaders(): Promise<Record<string, string | number>> {
    const token = await StorageUtil.getString(StorageConstants.TOKEN, '')
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
      vaid: '',
      br: deviceInfo?.brand || '',
      deviceId: await HttpRequest.GetDeviceId() || '',
    }
    // console.log('================ua', JSON.stringify(UA))
    const encoder = new util.TextEncoder();
    const data = encoder.encode(JSON.stringify(UA));
    const base64 = new util.Base64Helper().encodeToStringSync(data)
    return {
      'Authorization': token,
      'env': HttpConfig.CUSTOM_ENV,
      'language': LanguageUtils.getSystemLanguage(), //zh
      'it': deviceInfo.deviceType == 'tablet' ? "1" : "0",
      'platform': 'android',
      'uid': uid,
      'region': LanguageUtils.getSystemRegion() || 'cn',
      'currency': LanguageUtils.getSystemCurrency() || 'CNY',
      'timezone': new Intl.DateTimeFormat().resolvedOptions().timeZone,
      'sessionid': sessionid,
      'oaid': await HttpRequest.GetSystemOAID() || '',
      'aaid': await HttpRequest.GetSystemAAID() || '',
      'vaid': '',
      'br': deviceInfo.brand,
      'ua': base64,
    }

  }

  public static async get(url: string, params?: Record<string, string | number>): Promise<HttpResponse> {
    if (params) {
      url += '?' + Object.keys(params).map(key => `${key}=${encodeURIComponent(params[key].toString())}`).join('&')
    }
    return HttpRequest.getInstance().request(http.RequestMethod.GET, url, params)
  }

  public static async post(url: string, params?: object, dataType?: string): Promise<HttpResponse> {
    return HttpRequest.getInstance().request(http.RequestMethod.POST, url, params, dataType)
  }

  public static async put(url: string, params?: object): Promise<HttpResponse> {
    return HttpRequest.getInstance().request(http.RequestMethod.PUT, url, params)
  }

  public static async delete(url: string, params?: object): Promise<HttpResponse> {
    return HttpRequest.getInstance().request(http.RequestMethod.DELETE, url, params)
  }

  public static async download(url: string | undefined, name: string, type: string): Promise<string> {
    return HttpRequest.getInstance().downloadImage(url, name, type)
  }

  public static async upload(url: string): Promise<HttpResponse> {
    return HttpRequest.getInstance().uploadFile(url)
  }

  private async request(
    method: http.RequestMethod,
    url: string,
    params?: object,
    dataType?: string
  ): Promise<HttpResponse> {
    const headers = await this.getHeaders()
    const httpRequest = http.createHttp()
    const options: ESObject = {
      "credentials": "include",
      "method": method,
    }

    // if (params) {
    //   Object.keys(params).forEach(key => {
    //     options[key] = params[key];
    //   });
    // }
    if (method === 'GET') {
      headers['Content-Type'] = 'application/json'
      options['header'] = headers
    } else if (method === 'POST') {
      const multiFormDataList: Array<http.MultiFormData> = [];
      if (dataType === 'formData' && params) {
        // 安全遍历params对象
        Object.keys(params).forEach(key => {
          multiFormDataList.push({
            name: key,
            data: params[key],
            contentType: 'text/plain'
          });
        });
      }
      headers['Content-Type'] = dataType === 'formData' ? 'multipart/form-data' : dataType === 'string' ? 'text/plain' : 'application/json'
      options['header'] = headers
      options['body'] = dataType === 'formData' ? multiFormDataList : JSON.stringify(params)
      options['extraData'] = dataType === 'formData' ? multiFormDataList : JSON.stringify(params)
      options['multiFormDataList'] = dataType === 'formData' ? multiFormDataList : JSON.stringify(params)
    }
    // console.log('=================', JSON.stringify(options))
    return new Promise((resolve, reject) => {
      httpRequest.request(
        HttpConfig.containsHttpOrHttps(url) ? url : HttpConfig.API + url,
        options,
        (err: BusinessError, data: http.HttpResponse) => {
          // console.log('===============data', JSON.stringify(data), JSON.stringify(err))
          if (err) {
            reject({ code: err.code, message: err.message } as HttpError)
          } else {
            try {
              const result = JSON.parse(data.result as string) as HttpResponse
              // console.log('===============result', JSON.stringify(result))
              if (result.code == 205 || result.code == 203 || result.code == 203) {
                reject({ code: result.code, message: 'Token expired' })
                if (url != "/api/pay/apple_recovery") { // 排除苹果支付查询接口
                  HttpRequest.handleTokenExpire()
                }
              } else {
                // if (Array.isArray(result.data)) {
                //   const modifiedResult: HttpResponse = {
                //     code: result.code,
                //     message: result.message,
                //     data: { list: result.data },
                //     list: result.list || {}
                //   };
                //   resolve(modifiedResult)
                // }else {
                //   resolve(result)
                // }
                resolve(result)
              }
            } catch (parseError) {
              reject({ code: -1, message: 'Parse error' })
            }
          }
        }
      )
    })
  }

  private  async uploadFile(uri: string): Promise<HttpResponse> {
    const context = getContext(this) as common.UIAbilityContext;
    const headers = await this.getHeaders()
    const httpRequest = http.createHttp()

    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let fileFD = file.fd;
    let destPath = context.cacheDir;
    let fileName = Date.now().toString() + '.jpg';
    let fullPath = destPath + '/' + fileName;
    fs.copyFileSync(fileFD, fullPath);
    let realUri = "internal://cache/" + fileName;
    // console.log('=================', fullPath)
    // console.log('=================', realUri)
    const multiFormDataList: Array<http.MultiFormData> = [
      {
        name: 'fileForm',
        filePath: fullPath,
        contentType: this.getMimeTypeFromUri(uri),
        remoteFileName: fileName
      }
    ];
    headers['Content-Type'] = 'multipart/form-data'
    const type: string = "2"
    const requestOptions: ESObject = {
      method: http.RequestMethod.POST,
      httpMethod: http.RequestMethod.POST,
      uploadType: 1,
      header: headers,
      fieldName: "fileForm",
      multiFormDataList: multiFormDataList,
      body: multiFormDataList,
      extraData: multiFormDataList,
      connectTimeout: 60000,
      readTimeout: 60000,
      maxLimit: 100 * 1024 * 1024,
    };
    // console.log('=================', JSON.stringify(requestOptions))
    return new Promise((resolve, reject) => {
      httpRequest.request(HttpConfig.API + "/api/user/upload/img",
        requestOptions,
        (err: BusinessError, data: http.HttpResponse) => {
          if (err) {
            reject({
              code: err.code,
              message: err.message
            } as HttpError)
            return
          }

          try {
            // console.log('=================', data.result)
            const result = JSON.parse(data.result as string) as HttpResponse

            resolve(result)
          } catch (parseError) {
            reject({
              code: -1,
              message: 'Parse error'
            })
          }
        }
      )
    })
  }

  private getMimeTypeFromUri(uri: string): string {
    const extension = uri.split('.').pop()?.toLowerCase() || ''
    const mimeTypes: MimeTypes = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      gif: 'image/gif',
      bmp: 'image/bmp',
      webp: 'image/webp',
      heic: 'image/heic',
      heif: 'image/heif'
    }
    switch (extension) {
      case 'jpg':
        return mimeTypes.jpg
      case 'jpeg':
        return mimeTypes.jpeg
      case 'png':
        return mimeTypes.png
      case 'gif':
        return mimeTypes.gif
      case 'bmp':
        return mimeTypes.bmp
      case 'webp':
        return mimeTypes.webp
      case 'heic':
        return mimeTypes.heic
      case 'heif':
        return mimeTypes.heif
      default:
        return 'image/jpeg'
    }
  }

  private async downloadImage(url: string | undefined, name: string, type: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const request = http.createHttp();

      request.request(url, {
        method: http.RequestMethod.GET, // 使用枚举值而不是字符串
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000, // 60 seconds
        readTimeout: 300000,
        maxLimit: 100 * 1024 * 1024,
      }, async (err, data) => {
        if (err) {
          // console.log('=======网络下载失败:', JSON.stringify(err));
          reject(new Error(`网络下载失败: ${err.code}`));
        } else {
          // console.log('=======请求成功，响应数据:', JSON.stringify(data));

          if (data.result instanceof ArrayBuffer) {
            // const imageData = new Uint8Array(data.result);
            try {
              const imageData = new Uint8Array(data.result);

              // 获取应用内部存储路径
              const context = getContext(this) as common.UIAbilityContext;
              const filesDir = context.filesDir;

              // 创建文件名
              const timestamp = new Date().getTime();
              const fileName = `${name}_${timestamp}.${type}`;
              const filePath = `${filesDir}/${fileName}`;

              let file = await fileIO.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
              // 写入文件
              await fileIO.write(file, imageData.buffer);

              // console.log('=======保存成功:', filePath);
              resolve(filePath); // 返回本地地址
            } catch (error) {
              // console.error('===保存文件失败:', error);
              reject(new Error('保存文件失败'));
            }
            // resolve(new Uint8Array(data.result));
          }
        }
      });
    });
  }

  // 7. Token过期处理
  private static handleTokenExpire(): void {
    StorageUtil.putBoolean(StorageConstants.IS_LOGGED_IN, false)
    StorageUtil.remove(StorageConstants.TOKEN)
    // 这里可以添加跳转到登录页的逻辑
    if (router.getState()?.path === "/pages/login/LoginPage") {
      return;
    }
    router.replace({ url: 'pages/login/LoginPage' })
  }
}

export default HttpRequest