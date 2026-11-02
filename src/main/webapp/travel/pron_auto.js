// 검색으로 추가한 문장의 발음을 자동으로 만든다 (기본 문장은 pron_*.js 의 직접 쓴 표를 쓴다)
// 내 언어가 한국어면 한글로, 나머지 언어는 로마자로 적는다. 규칙 변환이라 근사치다
// 한자·가나·한글은 글자만으로 읽는 법을 알 수 없어 번역할 때 받아 둔 로마자(roma)를 바탕으로 한다
(function(global) {
	var L = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
	var V = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ';
	var T = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
	var Y = { 'ㅏ': 'ㅑ', 'ㅓ': 'ㅕ', 'ㅗ': 'ㅛ', 'ㅜ': 'ㅠ', 'ㅔ': 'ㅖ', 'ㅐ': 'ㅒ' };
	var W = { 'ㅏ': 'ㅘ', 'ㅓ': 'ㅝ', 'ㅗ': 'ㅝ', 'ㅔ': 'ㅞ', 'ㅐ': 'ㅙ', 'ㅣ': 'ㅟ' };
	var UNY = { 'ㅑ': 'ㅏ', 'ㅕ': 'ㅓ', 'ㅛ': 'ㅗ', 'ㅠ': 'ㅜ', 'ㅖ': 'ㅔ', 'ㅒ': 'ㅐ' };

	function H(l, v, t) { return String.fromCharCode(0xAC00 + (L.indexOf(l) * 21 + V.indexOf(v)) * 28 + T.indexOf(t || '')); }

	// 첫소리 l + 모음 조각들 [[모음, 받침?], ...]. 첫 조각에 l 과 glide(y/w)를 붙이고 나머지 조각은 ㅇ 으로 시작한다
	function syl(l, glide, pieces) {
		var v0 = pieces[0][0];
		if (glide === 'y') v0 = Y[v0] || v0;
		if (glide === 'w') v0 = W[v0] || v0;
		if ('ㅈㅉㅊ'.indexOf(l) >= 0) v0 = UNY[v0] || v0; // 한국어 표기 관례: 쟈 → 자
		return pieces.map(function(p, i) { return H(i ? 'ㅇ' : l, i ? p[0] : v0, p[1]); }).join('');
	}

	// 낱말만 바꾸고 숫자·문장부호·띄어쓰기는 그대로 둔다. 바꾸지 못한 낱말은 원래 글자로 남긴다
	function words(s, re, fn) { return s.replace(re, function(w) { return fn(w) || w; }); }
	function stripMarks(s) { return s.normalize('NFD').replace(/[̀-ͯ]/g, '').normalize('NFC'); }

	// ---------- 일본어: 헵번식 로마자 → 한글 ----------
	var JA_ON = { ky: ['ㅋ', 'y'], gy: ['ㄱ', 'y'], sh: ['ㅅ', 'y'], ch: ['ㅊ', 'y'], ts: ['ㅊ', ''], ny: ['ㄴ', 'y'], hy: ['ㅎ', 'y'], my: ['ㅁ', 'y'], ry: ['ㄹ', 'y'], by: ['ㅂ', 'y'], py: ['ㅍ', 'y'],
		j: ['ㅈ', 'y'], k: ['ㅋ', ''], g: ['ㄱ', ''], s: ['ㅅ', ''], z: ['ㅈ', ''], t: ['ㅌ', ''], d: ['ㄷ', ''], n: ['ㄴ', ''], h: ['ㅎ', ''], f: ['ㅎ', ''], b: ['ㅂ', ''], p: ['ㅍ', ''], m: ['ㅁ', ''], y: ['ㅇ', 'y'], r: ['ㄹ', ''], w: ['ㅇ', 'w'], v: ['ㅂ', ''] };
	var JA_V = { a: 'ㅏ', i: 'ㅣ', u: 'ㅜ', e: 'ㅔ', o: 'ㅗ' };
	function jaWord(w) {
		w = stripMarks(w.toLowerCase());
		var out = [], i = 0; // [첫소리, glide, 모음, 받침]
		var addFinal = function(t) { var o = out[out.length - 1]; if (o && !o[3]) o[3] = t; };
		while (i < w.length) {
			var c = w[i], next = w[i + 1];
			if (c === "'") { i++; continue; }
			if (JA_V[c]) { out.push(['ㅇ', '', JA_V[c]]); i++; continue; }
			// っ: kk, tt, ss, tch → 앞 글자 받침 ㅅ
			if ((c === next && c !== 'n') || (c === 't' && next === 'c')) { addFinal('ㅅ'); i++; continue; }
			// ん: 뒤에 모음·y 가 없는 n (헵번식은 b·p·m 앞에서 m)
			if ((c === 'n' || c === 'm') && !JA_V[next] && next !== 'y') { addFinal(c === 'n' ? 'ㄴ' : 'ㅁ'); i++; continue; }
			var on = JA_ON[w.substr(i, 2)] && JA_V[w[i + 2]] ? w.substr(i, 2) : JA_ON[c] && JA_V[next] ? c : null;
			if (!on) return null;
			var vw = w[i + on.length], v = JA_V[vw];
			if (vw === 'u' && (on === 's' || on === 'ts' || on === 'z')) v = 'ㅡ'; // す つ ず
			if (on === 'w' && vw === 'o') out.push(['ㅇ', '', 'ㅗ']); // を
			else out.push([JA_ON[on][0], JA_ON[on][1], v]);
			i += on.length + 1;
		}
		return out.map(function(o) { return syl(o[0], o[1], [[o[2], o[3]]]); }).join('');
	}
	function ja(roma) { return words(roma, /[A-Za-z'À-ɏ̀-ͯ]+/g, jaWord); }

	// ---------- 중국어: 병음 → 한글 (외래어 표기법에 가깝게) ----------
	var ZH_INIT = { zh: 'ㅈ', ch: 'ㅊ', sh: 'ㅅ', b: 'ㅂ', p: 'ㅍ', m: 'ㅁ', f: 'ㅍ', d: 'ㄷ', t: 'ㅌ', n: 'ㄴ', l: 'ㄹ', g: 'ㄱ', k: 'ㅋ', h: 'ㅎ', j: 'ㅈ', q: 'ㅊ', x: 'ㅅ', r: 'ㄹ', z: 'ㅉ', c: 'ㅊ', s: 'ㅆ' };
	// 운모 → 모음 조각. ü 는 v 로 적는다
	var ZH_FIN = {
		a: [['ㅏ']], o: [['ㅗ']], e: [['ㅓ']], ai: [['ㅏ'], ['ㅣ']], ei: [['ㅔ'], ['ㅣ']], ao: [['ㅏ'], ['ㅗ']], ou: [['ㅓ'], ['ㅜ']],
		an: [['ㅏ', 'ㄴ']], en: [['ㅓ', 'ㄴ']], ang: [['ㅏ', 'ㅇ']], eng: [['ㅓ', 'ㅇ']], er: [['ㅓ', 'ㄹ']], ong: [['ㅜ', 'ㅇ']],
		i: [['ㅣ']], ia: [['ㅑ']], iao: [['ㅑ'], ['ㅗ']], ie: [['ㅖ']], iu: [['ㅠ']], ian: [['ㅖ', 'ㄴ']], 'in': [['ㅣ', 'ㄴ']], iang: [['ㅑ', 'ㅇ']], ing: [['ㅣ', 'ㅇ']], iong: [['ㅠ', 'ㅇ']],
		u: [['ㅜ']], ua: [['ㅘ']], uo: [['ㅝ']], uai: [['ㅘ'], ['ㅣ']], ui: [['ㅜ'], ['ㅣ']], uan: [['ㅘ', 'ㄴ']], un: [['ㅜ', 'ㄴ']], uang: [['ㅘ', 'ㅇ']],
		v: [['ㅟ']], ve: [['ㅞ']], van: [['ㅟ'], ['ㅏ', 'ㄴ']], vn: [['ㅟ', 'ㄴ']]
	};
	// 첫소리 없이 y·w 로 시작하는 음절
	var ZH_ZERO = { yi: 'i', ya: 'ia', ye: 'ie', yao: 'iao', you: 'iu', yan: 'ian', yin: 'in', yang: 'iang', ying: 'ing', yong: 'iong', yu: 'v', yue: 've', yuan: 'van', yun: 'vn',
		wu: 'u', wa: 'ua', wo: 'uo', wai: 'uai', wei: [['ㅞ'], ['ㅣ']], wan: 'uan', wen: [['ㅝ', 'ㄴ']], wang: 'uang', weng: [['ㅝ', 'ㅇ']] };
	function zhSyl(s) {
		if (ZH_ZERO[s]) { var z = ZH_ZERO[s]; return syl('ㅇ', '', typeof z === 'string' ? ZH_FIN[z] : z); }
		var ini = ZH_INIT[s.slice(0, 2)] ? s.slice(0, 2) : ZH_INIT[s[0]] ? s[0] : '';
		var fin = s.slice(ini.length);
		if (ini && 'jqx'.indexOf(ini) >= 0 && fin[0] === 'u') fin = 'v' + fin.slice(1); // ju = jü
		if (fin === 'i' && /^(zh|ch|sh|r|z|c|s)$/.test(ini)) return syl(ZH_INIT[ini], '', [['ㅡ']]); // zhi chi shi
		if (!ZH_FIN[fin] || (!ini && 'aoe'.indexOf(fin[0]) < 0)) return null;
		return syl(ini ? ZH_INIT[ini] : 'ㅇ', '', ZH_FIN[fin]);
	}
	// 붙여 쓴 낱말(shénme)은 가능한 음절로 나눈다. 앞에서부터 긴 음절을 먼저 시도한다
	function zhWord(w) {
		w = stripMarks(w.toLowerCase().replace(/[üǖǘǚǜ]/g, 'v'));
		var memo = {};
		function seg(i) {
			if (i === w.length) return '';
			if (i in memo) return memo[i];
			memo[i] = null;
			if (w[i] === "'") return (memo[i] = seg(i + 1));
			for (var n = Math.min(6, w.length - i); n > 0; n--) {
				var h = zhSyl(w.substr(i, n));
				if (h == null) continue;
				var rest = seg(i + n);
				if (rest != null) return (memo[i] = h + rest);
			}
			return null;
		}
		return seg(0);
	}
	function zh(roma) { return words(roma, /[A-Za-z'À-ɏ̀-ͯ]+/g, zhWord); }

	// ---------- 베트남어: 글자 → 한글 ----------
	var VI_INIT = [['ngh', 'ㅇ'], ['ng', 'ㅇ'], ['nh', 'ㄴ', 'y'], ['gh', 'ㄱ'], ['gi', 'ㅈ'], ['ch', 'ㅉ'], ['tr', 'ㅉ'], ['th', 'ㅌ'], ['ph', 'ㅍ'], ['kh', 'ㅋ'], ['qu', 'ㄲ', 'w'],
		['b', 'ㅂ'], ['c', 'ㄲ'], ['k', 'ㄲ'], ['d', 'ㅈ'], ['đ', 'ㄷ'], ['g', 'ㄱ'], ['h', 'ㅎ'], ['l', 'ㄹ'], ['m', 'ㅁ'], ['n', 'ㄴ'], ['p', 'ㅃ'], ['r', 'ㄹ'], ['s', 'ㅅ'], ['t', 'ㄸ'], ['v', 'ㅂ'], ['x', 'ㅆ']];
	var VI_FIN = [['ng', 'ㅇ'], ['nh', 'ㄴ'], ['ch', 'ㄱ'], ['c', 'ㄱ'], ['m', 'ㅁ'], ['n', 'ㄴ'], ['p', 'ㅂ'], ['t', 'ㅅ']];
	var VI_ONE = { a: 'ㅏ', 'ă': 'ㅏ', 'â': 'ㅓ', e: 'ㅐ', 'ê': 'ㅔ', i: 'ㅣ', y: 'ㅣ', o: 'ㅗ', 'ô': 'ㅗ', 'ơ': 'ㅓ', u: 'ㅜ', 'ư': 'ㅡ' };
	var VI_NUC = { oa: ['ㅘ'], 'oă': ['ㅘ'], oe: ['ㅙ'], 'uâ': ['ㅝ'], 'uơ': ['ㅝ'], uy: ['ㅟ'], 'uê': ['ㅞ'], 'ươ': ['ㅡ', 'ㅓ'], 'iê': ['ㅣ', 'ㅔ'], 'yê': ['ㅣ', 'ㅔ'],
		'uô': ['ㅜ', 'ㅗ'], oai: ['ㅘ', 'ㅣ'], oay: ['ㅘ', 'ㅣ'], 'uây': ['ㅝ', 'ㅣ'], uya: ['ㅟ', 'ㅓ'], 'uyê': ['ㅟ', 'ㅔ'], oo: ['ㅗ'], 'ôô': ['ㅗ'] };
	function viWord(w) {
		// 성조 부호만 지우고 모음 모양(â ê ô ơ ư ă)은 남긴다
		w = w.toLowerCase().normalize('NFD').replace(/[̣̀́̃̉]/g, '').normalize('NFC');
		var ini = VI_INIT.filter(function(x) { return w.indexOf(x[0]) === 0; })[0] || ['', 'ㅇ'];
		var rest = w.slice(ini[0].length);
		if (ini[0] === 'gi' && !VI_ONE[rest[0]]) rest = 'i' + rest; // gì, gìn
		var fin = VI_FIN.filter(function(x) { return rest.length > x[0].length && rest.slice(-x[0].length) === x[0]; })[0] || ['', ''];
		var nuc = rest.slice(0, rest.length - fin[0].length);
		if (!nuc || nuc.split('').some(function(c) { return !VI_ONE[c]; })) return null;
		var vs = VI_NUC[nuc] || (nuc === 'a' && (fin[0] === 'nh' || fin[0] === 'ch') ? ['ㅏ', 'ㅣ'] : nuc.split('').map(function(c) { return VI_ONE[c]; }));
		var pieces = vs.map(function(v) { return [v]; });
		pieces[pieces.length - 1][1] = fin[1];
		return syl(ini[1], ini[2] || '', pieces);
	}
	function vi(text) { return words(text, /[A-Za-zÀ-ỹđĐ̀-ͯ]+/g, viWord); }

	// ---------- 태국어: 글자 → 음절(첫소리·모음·끝소리) → 로마자 또는 한글 ----------
	// shortcut: 사전 없이 규칙으로 음절을 나눠 숨은 모음(ถนน 같은 낱말) 일부는 틀린다. 품질이 문제되면 사전 기반으로 바꾼다
	var TH_LAT = { 'ก': 'k', 'ข': 'kh', 'ฃ': 'kh', 'ค': 'kh', 'ฅ': 'kh', 'ฆ': 'kh', 'ง': 'ng', 'จ': 'ch', 'ฉ': 'ch', 'ช': 'ch', 'ซ': 's', 'ฌ': 'ch', 'ญ': 'y', 'ฎ': 'd', 'ฏ': 't', 'ฐ': 'th', 'ฑ': 'th', 'ฒ': 'th', 'ณ': 'n',
		'ด': 'd', 'ต': 't', 'ถ': 'th', 'ท': 'th', 'ธ': 'th', 'น': 'n', 'บ': 'b', 'ป': 'p', 'ผ': 'ph', 'ฝ': 'f', 'พ': 'ph', 'ฟ': 'f', 'ภ': 'ph', 'ม': 'm', 'ย': 'y', 'ร': 'r', 'ล': 'l', 'ว': 'w', 'ศ': 's', 'ษ': 's', 'ส': 's', 'ห': 'h', 'ฬ': 'l', 'อ': '', 'ฮ': 'h' };
	var TH_KO = { 'ก': 'ㄲ', 'ข': 'ㅋ', 'ฃ': 'ㅋ', 'ค': 'ㅋ', 'ฅ': 'ㅋ', 'ฆ': 'ㅋ', 'ง': 'ㅇ', 'จ': 'ㅉ', 'ฉ': 'ㅊ', 'ช': 'ㅊ', 'ซ': 'ㅆ', 'ฌ': 'ㅊ', 'ญ': 'ㅇ', 'ฎ': 'ㄷ', 'ฏ': 'ㄸ', 'ฐ': 'ㅌ', 'ฑ': 'ㅌ', 'ฒ': 'ㅌ', 'ณ': 'ㄴ',
		'ด': 'ㄷ', 'ต': 'ㄸ', 'ถ': 'ㅌ', 'ท': 'ㅌ', 'ธ': 'ㅌ', 'น': 'ㄴ', 'บ': 'ㅂ', 'ป': 'ㅃ', 'ผ': 'ㅍ', 'ฝ': 'ㅍ', 'พ': 'ㅍ', 'ฟ': 'ㅍ', 'ภ': 'ㅍ', 'ม': 'ㅁ', 'ย': 'ㅇ', 'ร': 'ㄹ', 'ล': 'ㄹ', 'ว': 'ㅇ', 'ศ': 'ㅆ', 'ษ': 'ㅆ', 'ส': 'ㅆ', 'ห': 'ㅎ', 'ฬ': 'ㄹ', 'อ': 'ㅇ', 'ฮ': 'ㅎ' };
	var TH_FIN = { k: 'กขคฆ', ng: 'ง', t: 'จชซฌฎฏฐฑฒดตถทธศษส', n: 'ญณนรลฬ', p: 'บปพฟภ', m: 'ม', i: 'ย', o: 'ว' };
	var TH_FIN_KO = { k: 'ㄱ', ng: 'ㅇ', t: 'ㅅ', n: 'ㄴ', p: 'ㅂ', m: 'ㅁ' };
	var TH_V_LAT = { a: 'a', aa: 'a', i: 'i', ii: 'i', ue: 'ue', uee: 'ue', u: 'u', uu: 'u', e: 'e', ae: 'ae', o: 'o', or: 'o', oe: 'oe', ia: 'ia', uea: 'uea', ua: 'ua', ai: 'ai', ao: 'ao', am: 'am', oei: 'oei' };
	var TH_V_KO = { a: ['ㅏ'], aa: ['ㅏ'], i: ['ㅣ'], ii: ['ㅣ'], ue: ['ㅡ'], uee: ['ㅡ'], u: ['ㅜ'], uu: ['ㅜ'], e: ['ㅔ'], ae: ['ㅐ'], o: ['ㅗ'], or: ['ㅓ'], oe: ['ㅓ'],
		ia: ['ㅣ', 'ㅏ'], uea: ['ㅡ', 'ㅏ'], ua: ['ㅜ', 'ㅏ'], ai: ['ㅏ', 'ㅣ'], ao: ['ㅏ', 'ㅗ'], am: ['ㅏ'], oei: ['ㅓ', 'ㅣ'] };
	var DEP = 'ัิีึืุูาะ็ำ';
	function isCons(c) { return !!c && TH_LAT[c] !== undefined; }
	function isDep(c) { return !!c && DEP.indexOf(c) >= 0; }
	function finOf(c) { for (var k in TH_FIN) if (TH_FIN[k].indexOf(c) >= 0) return k; return ''; }

	function thSyllables(s) {
		s = s.replace(/[่้๊๋]/g, '').replace(/[ก-ฮ][ิุ]?์/g, ''); // 성조 부호는 쓰지 않고, ์ 가 붙은 글자는 읽지 않는다
		var out = [], i = 0;
		while (i < s.length) {
			var lead = 'เแโใไ'.indexOf(s[i]) >= 0 ? s[i++] : '';
			var c1 = s[i];
			if (!isCons(c1)) { i++; continue; } // 규칙에 안 맞는 모음 기호는 건너뛴다
			i++;
			var c0 = '';
			if (c1 === 'ห' && 'งญนมยรลว'.indexOf(s[i]) >= 0 && s[i]) c1 = s[i++]; // ห 는 소리 없이 성조만 바꾼다
			else if (c1 === 'อ' && s[i] === 'ย') c1 = s[i++];
			else if ('กขคตปผพ'.indexOf(c1) >= 0 && 'รล'.indexOf(s[i]) >= 0 && s[i] && (lead || isDep(s[i + 1]) || s[i + 1] === 'อ')
				|| 'กขค'.indexOf(c1) >= 0 && s[i] === 'ว' && (lead || isDep(s[i + 1]))) { c0 = c1; c1 = s[i++]; } // 겹첫소리 kr kl kw pr pl ...
			var v = '', open = false, m = s[i];
			if (lead === 'เ') {
				if (m === 'ี' && s[i + 1] === 'ย') { v = 'ia'; i += 2; if (s[i] === 'ะ') { i++; open = true; } }
				else if (m === 'ื' && s[i + 1] === 'อ') { v = 'uea'; i += 2; if (s[i] === 'ะ') { i++; open = true; } }
				else if (m === 'า') { i++; if (s[i] === 'ะ') { i++; v = 'o'; } else v = 'ao'; open = true; }
				else if (m === 'อ') { v = 'oe'; i++; if (s[i] === 'ะ') { i++; open = true; } }
				else if (m === 'ิ') { v = 'oe'; i++; }
				else if (m === 'ะ') { v = 'e'; i++; open = true; }
				else if (m === '็') { v = 'e'; i++; }
				else if (m === 'ย' && !isDep(s[i + 1])) { v = 'oei'; i++; open = true; }
				else v = 'e';
			} else if (lead === 'แ') { v = 'ae'; if (m === 'ะ') { i++; open = true; } else if (m === '็') i++; }
			else if (lead === 'โ') { v = 'o'; if (m === 'ะ') { i++; open = true; } }
			else if (lead) { v = 'ai'; }
			else if (m === 'ั') { if (s[i + 1] === 'ว') { v = 'ua'; i += 2; } else { v = 'a'; i++; } }
			else if (m === 'ื') { v = 'uee'; i++; if (s[i] === 'อ') i++; }
			else if ('ิีึุูา'.indexOf(m) >= 0 && m) { v = { 'ิ': 'i', 'ี': 'ii', 'ึ': 'ue', 'ุ': 'u', 'ู': 'uu', 'า': 'aa' }[m]; i++; }
			else if (m === 'ะ') { v = 'a'; i++; open = true; }
			else if (m === 'ำ') { v = 'am'; i++; open = true; }
			else if (m === '็') { v = 'o'; i++; }
			else if (m === 'อ' && !isDep(s[i + 1])) { v = 'or'; i++; }
			else if (m === 'ว' && isCons(s[i + 1]) && !isDep(s[i + 2])) { v = 'ua'; i++; }
			else if (m === 'ร' && s[i + 1] === 'ร') { v = 'a'; i += 2; if (!isCons(s[i]) || isDep(s[i + 1])) { out.push({ c0: c0, c1: c1, v: v, f: 'n' }); continue; } }
			else if (isCons(m) && !isDep(s[i + 1]) && 'เแโใไ'.indexOf(m) < 0) v = 'o'; // 숨은 모음 o + 끝소리
			else { v = 'a'; open = true; } // 숨은 모음 a (열린 음절)
			var f = '';
			// 다음 자음 뒤에 모음 기호나 모음 อ 가 오면 그 자음은 다음 음절의 첫소리다
			if (!open && isCons(s[i]) && 'อหฮ'.indexOf(s[i]) < 0 && !isDep(s[i + 1]) && !(s[i + 1] === 'อ' && !isDep(s[i + 2]))
				&& (v !== 'ai' || s[i] === 'ย')) f = finOf(s[i++]);
			out.push({ c0: c0, c1: c1, v: v, f: f });
		}
		return out;
	}
	function thLatin(x) {
		var f = x.f === 'i' && /i$/.test(TH_V_LAT[x.v]) || x.f === 'o' && /o$/.test(TH_V_LAT[x.v]) ? '' : x.f;
		return (x.c0 ? TH_LAT[x.c0] : '') + TH_LAT[x.c1] + TH_V_LAT[x.v] + f;
	}
	function thKorean(x) {
		var pieces = TH_V_KO[x.v].map(function(v) { return [v]; });
		var last = pieces[pieces.length - 1];
		if (x.v === 'am') last[1] = 'ㅁ';
		if (x.f === 'i') { if (last[0] !== 'ㅣ') pieces.push(['ㅣ']); }
		else if (x.f === 'o') { if (last[0] !== 'ㅗ' && last[0] !== 'ㅜ') pieces.push(['ㅜ']); }
		else if (x.f) last[1] = TH_FIN_KO[x.f];
		var glide = 'ยญ'.indexOf(x.c1) >= 0 ? 'y' : x.c1 === 'ว' ? 'w' : '';
		var pre = x.c0 ? H(TH_KO[x.c0], 'ㅡ') : x.c1 === 'ง' ? '응' : ''; // 겹첫소리 kr → 크ㄹ, ng → 응
		return pre + syl(TH_KO[x.c1], glide, pieces);
	}
	function thSplit(text) {
		if (typeof Intl !== 'undefined' && Intl.Segmenter) {
			return Array.from(new Intl.Segmenter('th', { granularity: 'word' }).segment(text), function(x) { return x.segment; });
		}
		return text.split(/(\s+)/);
	}
	function th(text, toKorean) {
		var out = [], prev = '';
		thSplit(text).forEach(function(w) {
			if (!/[ก-ฮ]/.test(w)) { out.push(w === 'ๆ' ? ' ' + prev : w); return; }
			prev = thSyllables(w.replace(/ๆ/g, '')).map(toKorean ? thKorean : thLatin).join('');
			out.push((out.length && /\S$/.test(out[out.length - 1]) ? ' ' : '') + prev);
		});
		return out.join('').trim();
	}

	// ---------- 영어: 철자 → 한글 (자주 쓰는 낱말은 표, 나머지는 철자 규칙이라 거친 근사치) ----------
	var EN_DICT = { i: '아이', "i'm": '아임', "i'd": '아이드', "i'll": '아일', you: '유', your: '유어', me: '미', my: '마이', we: '위', our: '아워', he: '히', she: '쉬', they: '데이', it: '잇', "it's": '잇츠',
		is: '이즈', are: '아', am: '앰', was: '워즈', be: '비', a: '어', an: '언', the: '더', this: '디스', that: '댓', "that's": '댓츠', these: '디즈', those: '도즈',
		what: '왓', "what's": '왓츠', where: '웨어', "where's": '웨어즈', when: '웬', who: '후', why: '와이', how: '하우', which: '위치', much: '머치', many: '매니',
		please: '플리즈', thank: '땡크', thanks: '땡스', sorry: '쏘리', hello: '헬로', hi: '하이', bye: '바이', goodbye: '굿바이', yes: '예스', no: '노', not: '낫', "don't": '돈트', "can't": '캔트', "doesn't": '더즌트',
		can: '캔', could: '쿠드', would: '우드', will: '윌', do: '두', does: '더즈', did: '디드', have: '해브', has: '해즈', want: '원트', need: '니드', like: '라이크', go: '고', get: '겟', take: '테이크', give: '기브',
		to: '투', for: '포', of: '오브', in: '인', on: '온', at: '앳', with: '위드', from: '프롬', and: '앤드', or: '오어', but: '벗', here: '히어', there: '데어', some: '썸', any: '애니',
		one: '원', two: '투', three: '쓰리', four: '포', five: '파이브', six: '식스', seven: '세븐', eight: '에잇', nine: '나인', ten: '텐', good: '굿', very: '베리', room: '룸', water: '워터', money: '머니', price: '프라이스', cash: '캐시', card: '카드' };
	var EN_V = [['ee', 'ㅣ'], ['ea', 'ㅣ'], ['oo', 'ㅜ'], ['ou', 'ㅏ', 'ㅜ'], ['ow', 'ㅏ', 'ㅜ'], ['oa', 'ㅗ'], ['ai', 'ㅔ', 'ㅣ'], ['ay', 'ㅔ', 'ㅣ'], ['ey', 'ㅔ', 'ㅣ'], ['oi', 'ㅗ', 'ㅣ'], ['oy', 'ㅗ', 'ㅣ'],
		['au', 'ㅗ'], ['aw', 'ㅗ'], ['ie', 'ㅣ'], ['ue', 'ㅜ'], ['a', 'ㅐ'], ['e', 'ㅔ'], ['i', 'ㅣ'], ['o', 'ㅗ'], ['u', 'ㅓ'], ['y', 'ㅣ']];
	var EN_LONG = { a: ['ㅔ', 'ㅣ'], i: ['ㅏ', 'ㅣ'], o: ['ㅗ'], u: ['ㅠ'], e: ['ㅣ'] };
	var EN_C = [['tch', 'ㅊ'], ['ch', 'ㅊ'], ['sh', 'ㅅ', 'y'], ['th', 'ㅆ'], ['ph', 'ㅍ'], ['ck', 'ㅋ'], ['ng', 'ng'], ['qu', 'ㅋ', 'w'], ['wh', 'ㅇ', 'w'], ['gh', ''], ['wr', 'ㄹ'], ['kn', 'ㄴ'],
		['b', 'ㅂ'], ['c', 'ㅋ'], ['d', 'ㄷ'], ['f', 'ㅍ'], ['g', 'ㄱ'], ['h', 'ㅎ'], ['j', 'ㅈ'], ['k', 'ㅋ'], ['l', 'ㄹ'], ['m', 'ㅁ'], ['n', 'ㄴ'], ['p', 'ㅍ'], ['r', 'ㄹ'], ['s', 'ㅅ'], ['t', 'ㅌ'], ['v', 'ㅂ'], ['w', 'ㅇ', 'w'], ['x', 'x'], ['y', 'ㅇ', 'y'], ['z', 'ㅈ']];
	// 받침으로 쓸 수 있는 자음과 그 받침
	var EN_FIN = { 'ㅋ': 'ㄱ', 'ㄱ': 'ㄱ', 'ㄴ': 'ㄴ', 'ㄹ': 'ㄹ', 'ㅁ': 'ㅁ', 'ㅍ': 'ㅂ', 'ㅂ': 'ㅂ', 'ㅌ': 'ㅅ', 'ng': 'ㅇ' };
	function enWord(w) {
		w = w.toLowerCase();
		if (EN_DICT[w]) return EN_DICT[w];
		if (/[^a-z]/.test(w)) return null;
		var toks = [], i = 0;
		while (i < w.length) {
			var rest = w.slice(i);
			// 끝의 묵음 e 와 '모음+자음+e' 의 긴 모음 (make, time, home)
			var mg = /^([aiou])([bcdfgklmnprstvz])e$/.exec(rest) || /^([aiou])([bcdfgklmnprstvz])e[sd]$/.exec(rest);
			if (mg) {
				toks.push({ v: EN_LONG[mg[1]] });
				toks.push({ c: EN_C.filter(function(x) { return x[0] === mg[2]; })[0] });
				if (rest.length > 3) toks.push({ c: EN_C.filter(function(x) { return x[0] === rest.slice(-1); })[0] });
				break;
			}
			if (rest === 'e' && toks.length) break;
			var isVowelPos = rest[0] !== 'y' || (i > 0 && !/[aeiou]/.test(w[i - 1]));
			var vv = isVowelPos && EN_V.filter(function(x) { return rest.indexOf(x[0]) === 0; })[0];
			if (vv) { toks.push({ v: vv.slice(1) }); i += vv[0].length; continue; }
			var cc = EN_C.filter(function(x) { return rest.indexOf(x[0]) === 0; })[0];
			if (!cc) return null;
			if (cc[1] === 'x') { toks.push({ c: ['k', 'ㅋ'] }); toks.push({ c: ['s', 'ㅅ'] }); }
			else if (cc[1] && !(toks.length && toks[toks.length - 1].c && toks[toks.length - 1].c[0] === cc[0])) toks.push({ c: cc });
			i += cc[0].length;
		}
		var out = '', pend = null; // pend: 아직 모음을 못 만난 자음
		for (var k = 0; k < toks.length; k++) {
			var tk = toks[k];
			if (tk.v) {
				var l = pend ? (pend[1] === 'ng' ? 'ㅇ' : pend[1]) : 'ㅇ';
				out += syl(l, pend ? pend[2] || '' : '', tk.v.map(function(v) { return [v]; }));
				pend = null;
				continue;
			}
			if (pend) out += consAlone(pend);
			pend = tk.c;
			var nextV = toks[k + 1] && toks[k + 1].v;
			// 모음 뒤, 다음이 모음이 아닌 자음은 받침으로
			if (!nextV && out && toks[k - 1] && toks[k - 1].v) {
				var fin = EN_FIN[pend[1]];
				var lastCode = out.charCodeAt(out.length - 1) - 0xAC00;
				if (pend[0] === 'r') { pend = null; continue; } // car → 카
				if (fin && lastCode >= 0 && lastCode % 28 === 0) { out = out.slice(0, -1) + String.fromCharCode(0xAC00 + lastCode + T.indexOf(fin)); pend = null; }
			}
		}
		if (pend) out += consAlone(pend);
		return out || null;
	}
	function consAlone(c) {
		if (c[1] === 'ng') return '';
		if (c[2] === 'y') return H(c[1], 'ㅣ'); // sh → 시
		if (c[1] === 'ㅊ' || c[1] === 'ㅈ') return H(c[1], 'ㅣ');
		return c[2] === 'w' ? H('ㅇ', 'ㅜ') : H(c[1], 'ㅡ');
	}
	function en(text) { return words(text, /[A-Za-z']+/g, function(w) { return enWord(w.replace(/^'+|'+$/g, '')); }); }

	// them 언어 문장 text 를 me 언어 글자로. roma = { ko, ja, zh } 번역할 때 받아 둔 로마자. 만들 수 없으면 null
	global.autoPron = function(them, me, text, roma) {
		roma = roma || {};
		var r;
		if (me === 'ko') {
			r = them === 'ja' ? roma.ja && ja(roma.ja) : them === 'zh' ? roma.zh && zh(roma.zh) : them === 'vi' ? vi(text) : them === 'th' ? th(text, true) : them === 'en' ? en(text) : null;
		} else {
			// 영어·베트남어는 원래 로마자라 따로 적지 않는다
			r = them === 'ko' || them === 'ja' || them === 'zh' ? roma[them] : them === 'th' ? th(text, false) : null;
		}
		return r && r !== text ? r : null;
	};
	global.AUTO_PRON_TEST = { ja: ja, zh: zh, vi: vi, th: th, en: en };
})(typeof window !== 'undefined' ? window : globalThis);
