// 여행 대화 사전 오프라인 캐시. 캐시를 먼저 보여주고 뒤에서 새 버전을 받아 둔다(다음 실행부터 반영)
var CACHE = 'phrasebook-v1';
var FILES = ['index.html', 'manifest.json', 'icon-180.png', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', function(e) {
	e.waitUntil(caches.open(CACHE).then(function(c) { return c.addAll(FILES); }).then(function() { return self.skipWaiting(); }));
});

self.addEventListener('activate', function(e) {
	e.waitUntil(caches.keys().then(function(keys) {
		return Promise.all(keys.filter(function(k) { return k !== CACHE; }).map(function(k) { return caches.delete(k); }));
	}).then(function() { return self.clients.claim(); }));
});

self.addEventListener('fetch', function(e) {
	if (e.request.method !== 'GET') return;
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
