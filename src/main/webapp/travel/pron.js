// 발음: 상대 언어 문장을 내 언어 글자로 적은 것. 키는 data.js 문장의 한국어 틀
// PRON[한국어 틀][상대 언어][내 언어] = 발음 ({n}/{w} 칸은 data.js 와 같다, 숫자는 숫자 그대로 둔다)
// PRON_W[한국어 틀][단어 번호][상대 언어][내 언어] = 단어 칸 발음
// 실제 내용은 상대 언어별 파일(pron_vi.js 등)이 P() 로 채운다. 발음은 Claude 초안이라 근사치다
var PRON = {};
var PRON_W = {};

// P(상대 언어, 한국어 틀, { 내 언어: 발음 }, [단어 칸 순서대로 { 내 언어: 발음 }])
function P(them, ko, byMe, words) {
	PRON[ko] = PRON[ko] || {};
	PRON[ko][them] = byMe;
	if (!words) return;
	PRON_W[ko] = PRON_W[ko] || [];
	words.forEach(function(w, i) {
		PRON_W[ko][i] = PRON_W[ko][i] || {};
		PRON_W[ko][i][them] = w;
	});
}
