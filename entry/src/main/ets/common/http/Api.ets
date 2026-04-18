import { HttpConfig } from "./HttpConfig";
import HttpRequest from "./HttpRequest";

interface HttpResponse {
  code: number | string
  message: string
  data: ESObject
  list: ESObject
}

interface GetSmsCode {
  mobile: string;
}

interface MobileVerify extends GetSmsCode {
  code: string;
}

// 签到相关API参数接口
interface CheckinParams {
  date: string;
  feeling?: number;
}

interface JournalHistoryParams {
  page: number;
  start_date: string;
}

interface QuestionParams {
  category?: string;
  type?: string;
  limit?: number;
}

interface AnswerMapping {
  question_id: string | number
  answer_id: number
}

export interface AnswerQuestionsParams {
  answers: AnswerMapping[];
  date: string;
}

export async function updateImg(uri: string): Promise<HttpResponse> {
  return HttpRequest.upload(uri);
}

export async function reportDataNew(params: ESObject): Promise<HttpResponse> {
  return HttpRequest.post('/playback/report', params);
}

export async function getSmsCode(params: GetSmsCode): Promise<HttpResponse> {
  return HttpRequest.post('/api/login/sendVerifyCode', params, 'formData');
}

export async function getUserInfoApi(): Promise<HttpResponse> {
  return HttpRequest.get('/api/user/info');
}