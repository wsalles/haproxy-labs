import http from 'k6/http';
import { check } from 'k6';
import { Rate } from 'k6/metrics';

var baseUrl = __ENV.BASE_URL || 'http://172.10.10.201';

export let errorRate = new Rate('errors');
export let options = {
    thresholds: {
        errors: ['rate<0.1'], // <10% errors
    },
}
export default function () {
    const res = http.get(baseUrl);
    const result = check(res, {
        'status is 200': (r) => r.status == 200,
    });
    errorRate.add(!result);
}
