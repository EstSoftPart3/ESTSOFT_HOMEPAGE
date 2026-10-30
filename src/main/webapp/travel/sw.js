// 여행 대화 사전 오프라인 캐시. 화면 파일은 캐시를 먼저 보여주고 뒤에서 새 버전을 받아 둔다(다음 실행부터 반영).
// 공유 상태(*.do)는 네트워크를 먼저 쓰고, 안 되면 마지막으로 받은 것을 쓴다
var CACHE = 'phrasebook-v4';
var FILES = ['index.html', 'data.js', 'pron.js', 'pron_ko.js', 'pron_en.js', 'pron_vi.js', 'pron_ja.js', 'pron_zh.js', 'pron_th.js',
	'manifest.json', 'icon-180.png', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', function(e) {
	e.waitUntil(caches.open(CACHE).then(function(c) { return c.addAll(FILES); }).then(function() { return self.skipWaiting(); }));
});

self.addEventListener('activate', function(e) {
	e.waitUntil(caches.keys().then(function(keys) {
		return Promise.all(keys.filter(function(k) { return k !== CACHE; }).map(function(k) { return caches.delete(k); }));
	}).then(function() { return self.clients.claim(); }));
});

self.addEventListener('fetch', function(e) {
	var url = new URL(e.request.url);
	// 번역 API 등 다른 사이트 요청과 쓰기 요청은 건드리지 않는다
	if (e.request.method !== 'GET' || url.origin !== self.location.origin) return;
	if (/\.do$/.test(url.pathname)) {
		e.respondWith(caches.open(CACHE).then(function(c) {
			return fetch(e.request).then(function(res) {
				if (res.ok) c.put(e.request, res.clone());
				return res;
			}).catch(function() { return c.match(e.request); });
		}));
		return;
	}
	e.respondWith(caches.open(CACHE).then(function(c) {
		return c.match(e.request, { ignoreSearch: true }).then(function(hit) {
			var net = fetch(e.request).then(function(res) {
				if (res.ok) c.put(e.request, res.clone());
				return res;
			}).catch(function() { return hit; });
			return hit || net;
		});
	}));
});
