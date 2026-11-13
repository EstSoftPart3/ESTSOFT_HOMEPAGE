package com.eep.bo.deploy.service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.staff.service.StaffDriveService;
import com.eep.mapper.BoDeployMapper;

/** 투입현황과 매출/매입처. 단가는 급여 권한자에게만 내려보내고 받는다 */
@Service
public class BoDeployService {

	private static final Pattern BIZ_NO = Pattern.compile("\\d{3}-\\d{2}-\\d{5}");
	private static final String[] PARTNER_TEXT = { "BIZ_NO", "CEO_NM", "OPEN_DT", "ADDR", "BIZ_TYPE", "BIZ_ITEM", "MGR_NM", "MGR_POS", "MGR_TEL", "MGR_HP", "MGR_EMAIL", "TAX_EMAIL", "BANK_NM", "ACCOUNT_NO", "ACCOUNT_HOLDER" };
	private static final List<String> FILE_KINDS = Arrays.asList("LICENSE", "LOGO", "SEAL", "BANK");
	private static final String[] DEPLOY_TEXT = { "SALE_PARTNER_SQ", "BUY_PARTNER_SQ", "CLIENT_NM", "PRJ_NM", "WORK_AREA", "GRADE_CD", "END_DT", "PROB_END_DT", "MEMO" };
	private static final List<String> COLUMNS = Arrays.asList("STAFF_NM", "EMP_TYPE_CD", "SALE_PARTNER_NM", "BUY_PARTNER_NM", "SALE_PRICE", "COST_PRICE", "CLIENT_NM", "PRJ_NM", "WORK_AREA", "GRADE_CD", "START_DT", "END_DT", "REMAIN", "TENURE", "HOME_AREA", "PRJ", "DUP", "MEMOS", "HIST");
	private static final String COLUMN_PREF = "DEPLOY_COLUMNS";
	private static final int MAX_FILE = 5 * 1024 * 1024;

	@Autowired
	private BoDeployMapper mapper;

	@Autowired
	private StaffDriveService staffDrive;

	@Autowired
	private GoogleDriveApi drive;

	@Value("${staff.drive.root:}")
	private String driveRoot;

	// ── 공통 ──

	public Map<String, Object> options(String loginId) {
		Map<String, Object> out = new HashMap<>();
		out.put("codes", mapper.selectCodes());
		out.put("staff", mapper.selectStaffOptions());
		out.put("partners", mapper.selectPartnerList());
		out.put("columns", columnOrder(loginId));
		return out;
	}

	private List<String> columnOrder(String loginId) {
		String saved = mapper.selectPref(pref(loginId));
		return saved == null || saved.isEmpty() ? new ArrayList<>() : Arrays.asList(saved.split(","));
	}

	/** 빈 값이면 저장을 지워 기본 순서로 돌아간다. 값은 알려진 컬럼만 받는다 */
	public void saveColumns(String loginId, String order) {
		Map<String, Object> p = pref(loginId);
		if (order == null || order.isEmpty()) {
			mapper.deletePref(p);
			return;
		}
		if (!COLUMNS.containsAll(Arrays.asList(order.split(",")))) {
			throw new IllegalArgumentException("알 수 없는 컬럼입니다.");
		}
		p.put("PREF_VAL", order);
		mapper.savePref(p);
	}

	private static Map<String, Object> pref(String loginId) {
		Map<String, Object> p = new HashMap<>();
		p.put("EMPLY_ID", loginId);
		p.put("PREF_KEY", COLUMN_PREF);
		return p;
	}

	// ── 투입 ──

	/** 사람별 현재 건과 전체 건. 단가는 canPay 일 때만 담는다 */
	public Map<String, Object> deployList(boolean canPay) {
		List<Map<String, Object>> all = mapper.selectDeployList();
		if (!canPay) {
			all.forEach(r -> {
				r.remove("SALE_PRICE");
				r.remove("COST_PRICE");
				r.remove("CLIENT_DIRECT_CD");
				r.remove("CLIENT_DIRECT_AMT");
			});
		}
		Map<String, Object> out = new HashMap<>();
		out.put("all", all);
		out.put("current", current(all, LocalDate.now()));
		out.put("canPay", canPay);
		out.put("memoCounts", mapper.selectDeployMemoCounts());
		out.put("chgCounts", mapper.selectDeployChangeCounts());
		return out;
	}

	/** 진행 중인 건을 모두, 없으면 앞으로 시작할 건, 그것도 없으면 재직자의 마지막 건(대기) */
	static List<Map<String, Object>> current(List<Map<String, Object>> all, LocalDate today) {
		Map<Object, List<Map<String, Object>>> byStaff = new LinkedHashMap<>();
		for (Map<String, Object> r : all) {
			byStaff.computeIfAbsent(r.get("STAFF_SQ"), k -> new ArrayList<>()).add(r);
		}
		List<Map<String, Object>> out = new ArrayList<>();
		for (List<Map<String, Object>> rows : byStaff.values()) {
			List<Map<String, Object>> active = new ArrayList<>();
			Map<String, Object> future = null;
			for (Map<String, Object> r : rows) {
				LocalDate start = PayCalc.date(r.get("START_DT")), end = PayCalc.date(r.get("END_DT"));
				if (start.isAfter(today)) {
					future = future == null ? r : future;
				} else if (end == null || !end.isBefore(today)) {
					active.add(r);
				}
			}
			if (!active.isEmpty()) {
				active.forEach(r -> r.put("STATE", "ACTIVE"));
				out.addAll(active);
			} else if (future != null) {
				future.put("STATE", "FUTURE");
				out.add(future);
			} else if (!"LEFT".equals(rows.get(0).get("STATUS_CD"))) {
				Map<String, Object> last = rows.get(rows.size() - 1);
				last.put("STATE", "WAIT");
				out.add(last);
			}
		}
		return out;
	}

	// ── 바로 수정·수정이력·메모 ──

	/** 수정이력에 남기는 칸. 단가는 급여 권한이 있을 때만 남기고 보여 준다 */
	static final List<String> TRACK = Arrays.asList("EMP_TYPE_CD", "SALE_PARTNER_SQ", "BUY_PARTNER_SQ", "CLIENT_NM", "PRJ_NM", "WORK_AREA", "GRADE_CD",
			"START_DT", "END_DT", "PROB_END_DT", "SALE_PRICE", "COST_PRICE", "MEMO", "CLIENT_DIRECT_CD", "CLIENT_DIRECT_AMT", "OFFICE_YN");
	static final List<String> PRICES = Arrays.asList("SALE_PRICE", "COST_PRICE", "CLIENT_DIRECT_CD", "CLIENT_DIRECT_AMT");
	/** 고객사 직접계약: 매출단가 옆 아이콘 팝업에서만 고친다(saveDirect) */
	static final List<String> DIRECT = Arrays.asList("CLIENT_DIRECT_CD", "CLIENT_DIRECT_AMT");

	private Map<String, Object> deployOne(Object deploySq) {
		Map<String, Object> q = new HashMap<>();
		q.put("DEPLOY_SQ", deploySq);
		return mapper.selectDeployOne(q);
	}

	private static String norm(Object v) {
		return v == null ? "" : v.toString().trim();
	}

	private static String brief(Map<String, Object> d) {
		return (norm(d.get("CLIENT_NM")) + " " + norm(d.get("PRJ_NM"))).trim() + " · " + norm(d.get("START_DT")) + " ~ " + (norm(d.get("END_DT")).isEmpty() ? "미정" : norm(d.get("END_DT")));
	}

	private void change(Object deploySq, Object staffSq, String field, String before, String after, String reason, String loginId) {
		Map<String, Object> h = new HashMap<>();
		h.put("DEPLOY_SQ", deploySq);
		h.put("STAFF_SQ", staffSq);
		h.put("FIELD", field);
		h.put("BEFORE_VAL", before == null || before.isEmpty() ? null : before);
		h.put("AFTER_VAL", after == null || after.isEmpty() ? null : after);
		h.put("REASON", reason);
		h.put("EMPLY_ID", loginId);
		mapper.insertDeployChange(h);
	}

	/** 저장 전후 행을 칸별로 비교해 바뀐 것만 이력에 남긴다 */
	private void diff(Map<String, Object> before, Map<String, Object> after, boolean canPay, String reason, String loginId) {
		for (String f : TRACK) {
			if (PRICES.contains(f) && !canPay) {
				continue;
			}
			String b = norm(before.get(f)), a = norm(after.get(f));
			boolean same = PRICES.contains(f) && !"CLIENT_DIRECT_CD".equals(f) ? BoPayrollService.n(b.isEmpty() ? 0 : before.get(f)) == BoPayrollService.n(a.isEmpty() ? 0 : after.get(f)) : b.equals(a);
			if (!same) {
				change(after.get("DEPLOY_SQ"), after.get("STAFF_SQ"), f, b, a, reason, loginId);
			}
		}
	}

	/** 목록에서 칸 하나를 바로 고친다. 검사는 saveDeploy 와 같다 */
	public void saveField(Object deploySq, String field, String value, boolean canPay, String loginId, String reason) {
		require(TRACK.contains(field), "고칠 수 없는 칸입니다.");
		require(canPay || !PRICES.contains(field), "단가는 급여 권한이 있어야 고칠 수 있습니다.");
		Map<String, Object> row = deployOne(deploySq);
		if (DIRECT.contains(field)) { // 되돌리기로 들어온 직접계약 칸 하나
			require(row != null, "투입 건을 찾지 못했습니다. 새로 고쳐 주세요.");
			String cd = "CLIENT_DIRECT_CD".equals(field) ? value : norm(row.get("CLIENT_DIRECT_CD")), amt = "CLIENT_DIRECT_AMT".equals(field) ? value : norm(row.get("CLIENT_DIRECT_AMT"));
			saveDirect(deploySq, cd, amt, canPay, loginId, reason);
			return;
		}
		require(row != null, "투입 건을 찾지 못했습니다. 새로 고쳐 주세요.");
		Map<String, Object> p = new HashMap<>();
		row.forEach((k, v) -> p.put(k, v == null ? "" : v.toString()));
		p.put(field, value == null ? "" : value.trim());
		p.put("UPDT_EMPLY_ID", loginId);
		p.put("_REASON", reason);
		saveDeploy(p, canPay);
	}

	/** staffSq 는 화면이 보낸 직원. 이력의 직원과 같아야 한다(시크릿 검사를 그 직원으로 했으므로) */
	/**
	 * 고객사 직접계약 종류·금액. 종류가 비면 둘 다 지운다. 금액은 0보다 크고 매출단가보다 작아야 한다.
	 * 종류는 공통코드 HR_CLIENT_DIRECT 값(화면이 공통코드로 고르게 한다)
	 */
	public void saveDirect(Object deploySq, String cd, String amt, boolean canPay, String loginId, String reason) {
		require(canPay, "고객사 직접계약은 급여 권한이 있어야 고칠 수 있습니다.");
		Map<String, Object> before = deployOne(deploySq);
		require(before != null, "투입 건을 찾지 못했습니다. 새로 고쳐 주세요.");
		String c = cd == null ? "" : cd.trim();
		long a = c.isEmpty() ? 0 : money(amt);
		require(c.isEmpty() || c.matches("[A-Z0-9_]{1,20}"), "직접계약 종류가 올바르지 않습니다.");
		require(c.isEmpty() || (a > 0 && a < BoPayrollService.n(before.get("SALE_PRICE"))), "직접계약 금액은 0보다 크고 매출단가보다 작아야 합니다.");
		Map<String, Object> p = new HashMap<>();
		p.put("DEPLOY_SQ", deploySq);
		p.put("CLIENT_DIRECT_CD", c.isEmpty() ? null : c);
		p.put("CLIENT_DIRECT_AMT", c.isEmpty() ? null : a);
		p.put("UPDT_EMPLY_ID", loginId);
		mapper.updateDeployDirect(p);
		diff(before, deployOne(deploySq), true, reason, loginId);
	}

	public void revert(Object chgSq, Object staffSq, boolean canPay, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("CHG_SQ", chgSq);
		Map<String, Object> h = mapper.selectDeployChange(q);
		require(h != null && norm(h.get("STAFF_SQ")).equals(norm(staffSq)), "이력을 찾지 못했습니다.");
		require(!"Y".equals(h.get("REVERTED_YN")), "이미 되돌린 이력입니다.");
		require(TRACK.contains(norm(h.get("FIELD_NM"))), "칸을 고친 이력만 되돌릴 수 있습니다.");
		require(deployOne(h.get("DEPLOY_SQ")) != null, "지운 투입 건은 되돌릴 수 없습니다.");
		saveField(h.get("DEPLOY_SQ"), norm(h.get("FIELD_NM")), norm(h.get("BEFORE_VAL")), canPay, loginId, "되돌리기 #" + chgSq);
		mapper.markDeployReverted(q);
	}

	public List<Map<String, Object>> changes(Object staffSq, boolean canPay) {
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		List<Map<String, Object>> list = mapper.selectDeployChanges(q);
		if (!canPay) {
			list.removeIf(h -> PRICES.contains(norm(h.get("FIELD_NM"))));
		}
		return list;
	}

	public List<Map<String, Object>> memos(Object staffSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		return mapper.selectDeployMemos(q);
	}

	public void addMemo(Object staffSq, String content, String loginId) {
		String c = content == null ? "" : content.trim();
		require(!c.isEmpty() && c.length() <= 1000, "메모는 1~1000자로 입력해 주세요.");
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		q.put("CONTENT", c);
		q.put("EMPLY_ID", loginId);
		mapper.insertDeployMemo(q);
	}

	public String memoStaff(Object memoSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("MEMO_SQ", memoSq);
		return mapper.selectDeployMemoStaff(q);
	}

	public void deleteMemo(Object memoSq, String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("MEMO_SQ", memoSq);
		q.put("EMPLY_ID", loginId);
		require(mapper.deleteDeployMemo(q) == 1, "본인이 남긴 메모만 지울 수 있습니다.");
	}

	public void saveDeploy(Map<String, Object> p, boolean canPay) {
		require(!text(p, "STAFF_SQ").isEmpty() || !text(p, "DEPLOY_SQ").isEmpty(), "직원을 목록에서 골라 주세요.");
		require(!text(p, "EMP_TYPE_CD").isEmpty(), "고용형태를 골라 주세요.");
		LocalDate start = PayCalc.date(p.get("START_DT"));
		require(start != null, "투입일을 입력해 주세요.");
		String end = text(p, "END_DT"), release = text(p, "PROB_END_DT");
		require(end.isEmpty() || (PayCalc.date(end) != null && !PayCalc.date(end).isBefore(start)), "철수일은 투입일보다 빠를 수 없습니다.");
		require(release.isEmpty() || PayCalc.date(release) != null, "수습해제일이 날짜가 아닙니다.");
		for (String f : DEPLOY_TEXT) {
			p.put(f, text(p, f));
		}
		p.put("SALE_PRICE", canPay ? money(p.get("SALE_PRICE")) : 0L);
		p.put("COST_PRICE", canPay ? money(p.get("COST_PRICE")) : 0L);
		p.put("CAN_PAY", canPay);
		String who = text(p, "UPDT_EMPLY_ID"), reason = text(p, "_REASON");
		if (text(p, "DEPLOY_SQ").isEmpty()) {
			mapper.insertDeploy(p);
			change(p.get("DEPLOY_SQ"), p.get("STAFF_SQ"), "NEW", null, brief(p), null, who);
		} else {
			Map<String, Object> before = deployOne(p.get("DEPLOY_SQ"));
			require(before != null, "투입 건을 찾지 못했습니다. 새로 고쳐 주세요.");
			// 내근직: 보내지 않은 요청(칸 바로 수정 등)은 지금 값을 지킨다
			p.put("OFFICE_YN", p.containsKey("OFFICE_YN") ? ("Y".equals(p.get("OFFICE_YN")) ? "Y" : "N") : before.get("OFFICE_YN"));
			mapper.updateDeploy(p);
			diff(before, deployOne(p.get("DEPLOY_SQ")), canPay, reason.isEmpty() ? null : reason, who);
		}
	}

	/** 철수일만 늘린다. 단가는 급여 권한자가 넣었을 때만 바꾸고, 메모는 덧붙인다 */
	public void extendDeploy(Map<String, Object> p, boolean canPay) {
		LocalDate end = PayCalc.date(p.get("END_DT"));
		require(end != null, "새 철수일을 입력해 주세요.");
		p.put("END_DT", end.toString());
		p.put("CAN_PAY", canPay);
		p.put("SALE_PRICE", canPay && !text(p, "SALE_PRICE").isEmpty() ? money(p.get("SALE_PRICE")) : null);
		p.put("COST_PRICE", canPay && !text(p, "COST_PRICE").isEmpty() ? money(p.get("COST_PRICE")) : null);
		String memo = text(p, "MEMO");
		p.put("MEMO", memo.isEmpty() ? "" : "[연장 " + LocalDate.now() + "] " + memo);
		Map<String, Object> before = deployOne(p.get("DEPLOY_SQ"));
		require(before != null && mapper.updateDeployEnd(p) == 1, "철수일은 투입일보다 빠를 수 없습니다.");
		diff(before, deployOne(p.get("DEPLOY_SQ")), canPay, "연장", text(p, "UPDT_EMPLY_ID"));
	}

	/** 사내 투입 건과 인사카드 수행이력을 합쳐 최신 순으로. 진행 중이 맨 위 */
	public List<Map<String, Object>> projectHistory(Object staffSq, boolean canPay) {
		List<Map<String, Object>> out = new ArrayList<>();
		Map<String, Object> q = new HashMap<>();
		q.put("STAFF_SQ", staffSq);
		for (Map<String, Object> r : mapper.selectStaffPrjs(q)) {
			r.put("SRC", "PRJ");
			r.put("START", r.get("START_YM"));
			r.put("END", r.get("END_YM"));
			out.add(r);
		}
		for (Map<String, Object> d : mapper.selectDeployList()) {
			if (!String.valueOf(staffSq).equals(String.valueOf(d.get("STAFF_SQ")))) {
				continue;
			}
			Map<String, Object> r = new HashMap<>();
			r.put("SRC", "DEPLOY");
			r.put("PRJ_NM", d.get("PRJ_NM"));
			r.put("CLIENT_NM", d.get("CLIENT_NM"));
			r.put("WORK_AREA", d.get("WORK_AREA"));
			r.put("EMP_TYPE_CD", d.get("EMP_TYPE_CD"));
			r.put("GRADE_CD", d.get("GRADE_CD"));
			r.put("START", d.get("START_DT"));
			r.put("END", d.get("END_DT"));
			if (canPay) {
				r.put("SALE_PRICE", d.get("SALE_PRICE"));
			}
			out.add(r);
		}
		out.sort((a, b) -> {
			int open = Boolean.compare(b.get("END") == null, a.get("END") == null);
			return open != 0 ? open : String.valueOf(b.get("START")).compareTo(String.valueOf(a.get("START")));
		});
		return out;
	}

	public void deleteDeploy(Map<String, Object> p) {
		require(mapper.countDeployClosed(p) == 0, "마감된 급여에 들어간 투입 건은 삭제할 수 없습니다.");
		Map<String, Object> before = deployOne(p.get("DEPLOY_SQ"));
		mapper.deleteDeploy(p);
		if (before != null) {
			change(before.get("DEPLOY_SQ"), before.get("STAFF_SQ"), "DELETE", brief(before), null, null, text(p, "UPDT_EMPLY_ID"));
		}
	}

	// ── 매출/매입처 ──

	public List<Map<String, Object>> partnerList() {
		return mapper.selectPartnerList();
	}

	/**
	 * files: 종류(LICENSE·LOGO·SEAL·BANK) -> FILE_NM, FILE_TYPE, FILE_DATA. removes: 지울 종류.
	 * 사업자등록증은 거래처 행에, 나머지는 TB_EEP_PARTNER_FILE_R 에 둔다.
	 */
	public void savePartner(Map<String, Object> p, Map<String, Map<String, Object>> files, List<String> removes) {
		require(!text(p, "PARTNER_NM").isEmpty(), "상호를 입력해 주세요.");
		require("Y".equals(p.get("SALE_YN")) || "Y".equals(p.get("BUY_YN")), "매출처·매입처 중 하나 이상 골라 주세요.");
		for (String f : PARTNER_TEXT) {
			p.put(f, text(p, f));
		}
		p.put("PARTNER_NM", text(p, "PARTNER_NM"));
		p.put("SALE_YN", "Y".equals(p.get("SALE_YN")) ? "Y" : "N");
		p.put("BUY_YN", "Y".equals(p.get("BUY_YN")) ? "Y" : "N");
		p.put("USE_YN", "N".equals(p.get("USE_YN")) ? "N" : "Y");
		String sq = text(p, "PARTNER_SQ"), no = text(p, "BIZ_NO");
		require(no.isEmpty() || BIZ_NO.matcher(no).matches(), "사업자등록번호는 000-00-00000 형식으로 입력해 주세요.");
		if (!no.isEmpty()) {
			Map<String, Object> q = new HashMap<>();
			q.put("BIZ_NO", no);
			q.put("PARTNER_SQ", sq.isEmpty() ? 0 : Integer.parseInt(sq));
			require(mapper.countBizNo(q) == 0, "이미 등록된 사업자등록번호입니다.");
		}
		for (String k : files.keySet()) {
			require(FILE_KINDS.contains(k), "알 수 없는 서류 종류입니다.");
			Map<String, Object> f = files.get(k);
			checkFile((String) f.get("FILE_NM"), (byte[]) f.get("FILE_DATA"));
		}
		Map<String, Object> lic = files.get("LICENSE");
		p.put("FILE_NM", lic == null ? null : lic.get("FILE_NM"));
		p.put("FILE_TYPE", lic == null ? null : lic.get("FILE_TYPE"));
		p.put("FILE_DATA", lic == null ? null : lic.get("FILE_DATA"));
		p.put("LICENSE_DEL", lic == null && removes.contains("LICENSE"));
		if (sq.isEmpty()) {
			mapper.insertPartner(p);
		} else {
			mapper.updatePartner(p);
		}
		for (String k : removes) {
			if (!"LICENSE".equals(k) && FILE_KINDS.contains(k) && !files.containsKey(k)) {
				Map<String, Object> q = new HashMap<>();
				q.put("PARTNER_SQ", p.get("PARTNER_SQ"));
				q.put("FILE_CD", k);
				mapper.deletePartnerFile(q);
			}
		}
		for (Map.Entry<String, Map<String, Object>> e : files.entrySet()) {
			if (!"LICENSE".equals(e.getKey())) {
				Map<String, Object> q = new HashMap<>(e.getValue());
				q.put("PARTNER_SQ", p.get("PARTNER_SQ"));
				q.put("FILE_CD", e.getKey());
				q.put("UPDT_EMPLY_ID", p.get("UPDT_EMPLY_ID"));
				mapper.savePartnerFile(q);
			}
		}
	}

	public void deletePartner(Map<String, Object> p) {
		require(mapper.countPartnerUse(p) == 0, "투입 기록이 있어 삭제할 수 없습니다. 사용 중지로 바꿔 주세요.");
		mapper.deletePartnerFile(p);
		mapper.deletePartner(p);
	}

	/** KIND 가 없거나 LICENSE 면 사업자등록증, 아니면 첨부 서류 */
	public Map<String, Object> partnerFile(Map<String, Object> p) {
		String kind = text(p, "KIND");
		if (kind.isEmpty() || "LICENSE".equals(kind)) {
			return mapper.selectPartnerFile(p);
		}
		p.put("FILE_CD", kind);
		return mapper.selectPartnerAttach(p);
	}

	/**
	 * 서류 한 장을 읽어 종류와 칸 값을 돌려준다. kind 가 비면 파일 이름, 그다음 글자로 종류를 맞힌다.
	 * 로고·직인은 글자를 읽지 않는다. 글자 있는 PDF 는 바로, 스캔·사진은 구글 드라이브 OCR 로 읽는다.
	 */
	public Map<String, Object> readDoc(String fileName, String fileType, byte[] data, String kind) throws IOException {
		checkFile(fileName, data);
		String k = kind == null || kind.isEmpty() ? BizLicenseParser.kindByName(fileName) : kind;
		require(k == null || FILE_KINDS.contains(k), "알 수 없는 서류 종류입니다.");
		Map<String, Object> out = new HashMap<>();
		String warning = "";
		Map<String, String> fields = new HashMap<>();
		if (!"LOGO".equals(k) && !"SEAL".equals(k)) {
			String text = isPdf(fileName) ? pdfText(data) : "";
			if (text.trim().length() < 20) {
				try {
					text = ocr(fileName, fileType, data);
				} catch (IllegalArgumentException e) {
					warning = "자동입력을 못 했습니다. " + e.getMessage();
				} catch (Exception e) {
					System.out.println("PARTNER_OCR_ERROR " + e.getClass().getSimpleName());
					warning = "글자를 읽지 못했습니다. 직접 입력해 주세요.";
				}
			}
			if (k == null) {
				k = BizLicenseParser.kindByText(text);
			}
			if ("LICENSE".equals(k)) {
				fields = BizLicenseParser.parse(text);
			} else if ("BANK".equals(k)) {
				fields = BizLicenseParser.bank(text);
			}
		}
		out.put("kind", k);
		out.put("fields", fields);
		out.put("warning", warning);
		return out;
	}

	private String ocr(String fileName, String fileType, byte[] data) {
		require(driveRoot != null && !driveRoot.isEmpty(), "구글 드라이브 설정이 없습니다.");
		String token = staffDrive.token();
		String id = (String) drive.upload("거래처-임시-" + fileName, fileType, data, driveRoot, token).get("id");
		try {
			return drive.ocrText(id, token);
		} finally {
			drive.delete(id, token);
		}
	}

	private static String pdfText(byte[] data) throws IOException {
		try (PDDocument doc = PDDocument.load(data)) {
			return new PDFTextStripper().getText(doc);
		} catch (org.apache.pdfbox.pdmodel.encryption.InvalidPasswordException e) {
			return "";
		}
	}

	private static boolean isPdf(String name) {
		return name != null && name.toLowerCase().endsWith(".pdf");
	}

	private static void checkFile(String name, byte[] data) {
		require(data != null && data.length > 0, "파일이 비어 있습니다.");
		require(data.length <= MAX_FILE, "파일은 5MB 까지 올릴 수 있습니다.");
		require(name != null && name.toLowerCase().matches(".*\\.(pdf|jpg|jpeg|png)"), "PDF, JPG, PNG 파일만 올릴 수 있습니다.");
	}

	static long money(Object v) {
		String s = v == null ? "" : v.toString().replace(",", "").trim();
		if (s.isEmpty()) {
			return 0;
		}
		try {
			return Long.parseLong(s);
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("금액은 숫자로 입력해 주세요.");
		}
	}

	private static String text(Map<String, Object> p, String k) {
		return p.get(k) == null ? "" : p.get(k).toString().trim();
	}

	private static void require(boolean ok, String message) {
		if (!ok) {
			throw new IllegalArgumentException(message);
		}
	}
}
