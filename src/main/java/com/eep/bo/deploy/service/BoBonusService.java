package com.eep.bo.deploy.service;

import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.mapper.BoDeployMapper;

/** 상여관리(조건)와 직원관리의 상여 적용 토글. 금액 계산은 BonusCalc, 급여 반영은 BoPayrollService.sync */
@Service
public class BoBonusService {

	@Autowired
	private BoDeployMapper mapper;

	@Autowired
	private BoPayrollService payroll;

	public Map<String, Object> list() {
		Map<String, Object> out = new HashMap<>();
		out.put("items", mapper.selectBonusList());
		out.put("applies", mapper.selectBonusApplies());
		return out;
	}

	/** 직원관리용: 조건, 켠 것, 단계별 지급 예정(마우스 올림 설명), 추천인 고를 직원 */
	public Map<String, Object> staffData() {
		Map<String, Object> out = list();
		out.put("plans", payroll.bonusPlans());
		out.put("staff", mapper.selectStaffOptions());
		return out;
	}

	public void save(Map<String, Object> p, String loginId) {
		String nm = str(p.get("BONUS_NM")).trim();
		require(!nm.isEmpty() && nm.length() <= 50, "상여 항목 이름은 1~50자로 입력해 주세요.");
		require(BonusCalc.BASES.contains(str(p.get("BASE_CD"))), "기준일을 골라 주세요.");
		require("SELF".equals(p.get("TARGET_CD")) || "REFERRER".equals(p.get("TARGET_CD")), "받는 사람을 골라 주세요.");
		List<Map<String, Object>> steps = BonusCalc.steps(str(p.get("STEPS")));
		require(steps.size() <= 12, "지급 단계는 12개까지입니다.");
		p.put("BONUS_NM", nm);
		p.put("STEPS", steps.stream().map(s -> s.get("MONTHS") + ":" + s.get("COND") + ":" + s.get("AMT")).collect(Collectors.joining(",")));
		p.put("PER_AMT_YN", "Y".equals(p.get("PER_AMT_YN")) ? "Y" : "N");
		p.put("USE_YN", "N".equals(p.get("USE_YN")) ? "N" : "Y");
		p.put("UPDT_EMPLY_ID", loginId);
		if (str(p.get("BONUS_SQ")).isEmpty()) {
			mapper.insertBonus(p);
		} else {
			require(mapper.updateBonus(p) == 1, "상여 항목을 찾지 못했습니다.");
		}
	}

	public void setUse(Object bonusSq, boolean on, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("BONUS_SQ", bonusSq);
		q.put("USE_YN", on ? "Y" : "N");
		q.put("UPDT_EMPLY_ID", loginId);
		require(mapper.updateBonusUse(q) == 1, "상여 항목을 찾지 못했습니다.");
	}

	public void delete(Object bonusSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("BONUS_SQ", bonusSq);
		require(mapper.deleteBonus(q) == 1, "켠 직원이 있어 지울 수 없습니다. 사용을 끄면 다음 계산부터 빠집니다.");
	}

	/** 직원 한 명에게 상여를 켜거나 끈다. 켜고 끈 것은 이번 달 수정이력에 남는다 */
	public void apply(Map<String, Object> p, String loginId) {
		Map<String, Object> item = mapper.selectBonusList().stream().filter(b -> str(b.get("BONUS_SQ")).equals(str(p.get("BONUS_SQ")))).findFirst().orElse(null);
		require(item != null, "상여 항목을 찾지 못했습니다.");
		require(!str(p.get("STAFF_SQ")).isEmpty(), "직원을 골라 주세요.");
		Map<String, Object> q = new HashMap<>();
		q.put("BONUS_SQ", item.get("BONUS_SQ"));
		q.put("STAFF_SQ", p.get("STAFF_SQ"));
		q.put("EMPLY_ID", loginId);
		String nm = str(item.get("BONUS_NM")), reason;
		if ("N".equals(p.get("ON"))) {
			mapper.deleteBonusApply(q);
			reason = nm + " 끔";
		} else {
			String amt = str(p.get("AMT")).replace(",", "").trim(), ref = str(p.get("REFERRER_SQ")).trim();
			boolean per = "Y".equals(item.get("PER_AMT_YN")), referral = "REFERRER".equals(item.get("TARGET_CD"));
			q.put("AMT", per && !amt.isEmpty() ? BoDeployService.money(amt) : null);
			require(q.get("AMT") == null || (Long) q.get("AMT") >= 0, "금액은 0 이상이어야 합니다.");
			q.put("REFERRER_SQ", referral && !ref.isEmpty() ? ref : null);
			require(!ref.equals(str(p.get("STAFF_SQ"))), "자기 자신을 추천인으로 고를 수 없습니다.");
			mapper.saveBonusApply(q);
			reason = nm + " 켬" + (q.get("AMT") != null ? " · 금액 " + String.format("%,d", (Long) q.get("AMT")) : "") + (referral ? (ref.isEmpty() ? " · 추천인 미지정" : " · 추천인 " + mapper.selectStaffOptions().stream()
					.filter(s -> str(s.get("STAFF_SQ")).equals(ref)).map(s -> str(s.get("STAFF_NM"))).findFirst().orElse("#" + ref)) : "");
		}
		payroll.change(YearMonth.now().toString(), p.get("STAFF_SQ"), "BONUS", null, null, reason, loginId);
	}

	private static String str(Object v) {
		return Objects.toString(v, "");
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}
}
