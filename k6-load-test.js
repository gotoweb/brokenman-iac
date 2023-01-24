import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '3m',
};

export default function () {
  http.get('http://brokenman-dev-alb-2033042884.ap-northeast-2.elb.amazonaws.com');
  sleep(1);
}
