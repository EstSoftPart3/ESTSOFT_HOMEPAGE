package com.eep.travel.service;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.travel.dao.TravelDao;

@Service
public class TravelServiceImpl implements TravelService {

	/** 화면(travel/index.html)의 LANGS 와 같은 순서 */
	public static final List<String> LANGS = Arrays.asList("ko", "en", "vi", "ja", "zh", "th");
	/** 화면의 SITUATIONS 개수 */
	public static final int SITUATION_COUNT = 8;
	public static final int MAX_TEXT = 300;

	// 기본 문장은 'b:' + 한국어 문장, 추가한 문장은 'a:' + 번호
	private static final Pattern KEY = Pattern.compile("^(b:.{1," + MAX_TEXT + "}|a:\\d{1,10})$", Pattern.DOTALL);

	@Autowired
	TravelDao TravelDao;

	@Override
	public List<Map<String, Object>> PhraseList() {
		return TravelDao.PhraseList();
	}

	@Override
	public Map<String, Object> PhraseAdd(int sitIdx, String srcLang, Map<String, String> texts, String ip) {
		if (sitIdx < 0 || sitIdx >= SITUATION_COUNT) throw new IllegalArgumentException("bad situation");
		if (!LANGS.contains(srcLang)) throw new IllegalArgumentException("bad language");
		Map<String, Object> param = new HashMap<>();
		for (String lang : LANGS) {
			String txt = texts.get(lang) == null ? "" : texts.get(lang).trim();
			if (txt.isEmpty() || txt.length() > MAX_TEXT) throw new IllegalArgumentException("bad text: " + lang);
			param.put("TXT_" + lang.toUpperCase(), txt);
		}
		param.put("SIT_IDX", sitIdx);
		param.put("SRC_LANG", srcLang);
		param.put("REG_IP", ip);
		Map<String, Object> saved = TravelDao.PhraseInsert(param);
		saved.remove("REG_IP");
		return saved;
	}

	@Override
	public List<String> HideKeyList() {
		return TravelDao.HideKeyList();
	}

	@Override
	public void Hide(String key, String ip) {
		TravelDao.Hide(checkKey(key), ip);
	}

	@Override
	public void Unhide(String key) {
		TravelDao.Unhide(checkKey(key));
	}

	private static String checkKey(String key) {
		if (key == null || !KEY.matcher(key).matches()) throw new IllegalArgumentException("bad key");
		return key;
	}
}
