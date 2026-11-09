package com.eep.bo.equipment.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.eep.bo.batch.service.GoogleDriveApi;
import com.eep.bo.staff.service.StaffDriveService;
import com.eep.mapper.BoEquipmentMapper;
import com.eep.mapper.BoStaffMapper;

/** 장비대장, 대여·반납, 전수조사, 대여증서. 직원 화면의 본인 확인은 FoEquipmentController 가 세션으로 한다 */
@Service
public class BoEquipmentService {

	private static final Map<String, String> TYPES = new HashMap<>();
	static {
		TYPES.put("NB", "노트북");
		TYPES.put("MT", "모니터");
		TYPES.put("DT", "데스크탑");
		TYPES.put("MU", "마우스");
		TYPES.put("KB", "키보드");
	}
	// 컬럼명이 SQL 에 그대로 들어가므로 허용 목록으로만 받는다
	private static final Set<String> FIELDS = new HashSet<>(Arrays.asList("EQP_NO", "BRAND_NM", "MODEL_NM", "SERIAL_NO", "CPU_SPEC", "MEM_SPEC", "SSD_SPEC", "HDD_SPEC", "LAN_YN", "ETC_TXT", "LOCATION_NM", "AUDIT_EXCL_YN", "MEMO"));
	private static final Set<String> RENT_FIELDS = new HashSet<>(Arrays.asList("HOLDER_NM", "START_DT", "END_DT", "PURPOSE_NM", "PROJECT_NM", "HANDOVER_NM"));
	private static final Pattern IMAGE = Pattern.compile("^data:image/(png|jpeg);base64,[A-Za-z0-9+/=]+$");
	private static final long MAX_FILE = 20L * 1024 * 1024;
	private static final int MAX_IMAGE = 700 * 1024;
	private static final String FOLDER_ROOT = "3. 장비 관리", FOLDER_SIGN = "03. 대여증서", FOLDER_RECEIPT = "01. 구매영수증", FOLDER_ETC = "04. 장비첨부";

	/** 기존 장비대여증서 양식의 법령 인용과 동의 문구 원문 */
	static final String LAW_TEXT = "형법 [시행 2010.10.16] [법률 제10259호, 2010. 4.15, 일부개정]\n"
			+ "제366조(재물손괴등) 타인의 재물, 문서 또는 전자기록등 특수매체기록을 손괴 또는 은닉 기타 방법으로 기 효용을 해한 자는 3년이하의 징역 또는 700만원 이하의 벌금에 처한다. <개정 1995.12.29>\n"
			+ "제371조(미수범) 제366조, 제367조와 제369조의 미수범은 처벌한다\n"
			+ "민법 [시행 2009. 8. 9] [법률 제9650호, 2009. 5. 8, 일부개정]\n"
			+ "제750조 (불법행위의 내용) 고의 또는 과실로 인한 위법행위로 타인에게 손해를 가한 자는 그 손해를 배상할 책임이 있다. 에 의거하여 준수한다.\n\n"
			+ "상기인은(는) 이에스티로부터 장비를 대여 받았음을 증명하며 대여금은 무상으로 하나,\n"
			+ "대여 기간 동안 개인의 부주의로 인한 파손 및 손상에 대해 수리비를 책임져야 함에 동의 합니다.";

	@Autowired
	private BoEquipmentMapper mapper;
	@Autowired
	private BoStaffMapper staffMapper;
	@Autowired
	private GoogleDriveApi drive;
	@Autowired
	private StaffDriveService staffDrive;

	private TransactionTemplate tx;

	@Autowired
	public void setDataSource(@Qualifier("dataSource") DataSource ds) { // dataSourceSpied 와 2개라 이름을 지정해야 기동된다
		tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
	}

	// ── 장비대장 ──

	public Map<String, Object> list() {
		Map<String, Object> out = new HashMap<>();
		out.put("list", mapper.selectEquipmentList());
		out.put("staff", mapper.selectStaffOptions());
		out.put("seal", mapper.selectSeal() != null);
		return out;
	}

	public Map<String, Object> card(Object eqpSq) {
		Map<String, Object> p = one("EQP_SQ", eqpSq), out = new HashMap<>();
		out.put("rents", mapper.selectRentList(p));
		out.put("issues", mapper.selectIssueList(p));
		out.put("files", mapper.selectFileList(p));
		return out;
	}

	public void saveField(Map<String, Object> param) {
		String field = str(param, "FIELD");
		if (!FIELDS.contains(field)) throw new IllegalArgumentException("이 항목은 고칠 수 없습니다.");
		if ("EQP_NO".equals(field)) {
			param.put("VALUE", normalizeNo(str(param, "VALUE")));
			if (str(param, "VALUE").isEmpty()) throw new IllegalArgumentException("장비번호를 입력해 주세요.");
		}
		mapper.updateEquipmentField(param);
	}

	public Object insert(Map<String, Object> param) {
		if (!TYPES.containsKey(str(param, "TYPE_CD"))) throw new IllegalArgumentException("장비 구분을 골라 주세요.");
		String no = normalizeNo(str(param, "EQP_NO"));
		if (no.isEmpty()) throw new IllegalArgumentException("장비번호를 입력해 주세요.");
		param.put("EQP_NO", no);
		mapper.insertEquipment(param);
		return param.get("EQP_SQ");
	}

	public void delete(Object eqpSq) {
		if (mapper.deleteEquipment(one("EQP_SQ", eqpSq)) == 0) throw new IllegalArgumentException("대여이력이 있는 장비는 삭제할 수 없습니다.");
	}

	public String suggestNo(String type) {
		if (!TYPES.containsKey(type)) return "";
		return suggestNo(type, mapper.selectActiveNos(one("TYPE_CD", type)));
	}

	/** 보유 장비가 쓰지 않는 가장 작은 번호. 폐기·분실 장비의 번호도 다시 쓴다 */
	static String suggestNo(String type, List<String> active) {
		Set<Integer> used = new HashSet<>();
		Pattern p = Pattern.compile("-" + type + "-(\\d+)$");
		for (String no : active) {
			Matcher m = p.matcher(no);
			if (m.find()) used.add(Integer.parseInt(m.group(1)));
		}
		int n = 1;
		while (used.contains(n)) n++;
		return String.format("ESTSW-EQPMNT-%s-%03d", type, n);
	}

	static String normalizeNo(String no) {
		return no.trim().replace('_', '-').replace('–', '-').replace('—', '-').replaceAll("\\s", "").toUpperCase();
	}

	// ── 대여·반납 ──

	/** @return RENT_GROUP 과 GUEST(본인 로그인으로 서명할 수 없는 사용자) */
	public Map<String, Object> rent(Map<String, Object> param) {
		List<String> eqps = ids(str(param, "EQP_SQS"));
		if (eqps.isEmpty()) throw new IllegalArgumentException("대여할 장비를 골라 주세요.");
		date(str(param, "START_DT"), "대여일");
		boolean guest = true;
		if (!str(param, "STAFF_SQ").isEmpty()) {
			Map<String, Object> staff = staffMapper.selectStaffOne(one("STAFF_SQ", param.get("STAFF_SQ")));
			if (staff == null) throw new IllegalArgumentException("직원을 찾지 못했습니다.");
			param.put("HOLDER_NM", staff.get("STAFF_NM"));
			guest = staff.get("EMPLY_ID") == null;
		} else if (str(param, "HOLDER_NM").trim().isEmpty()) {
			throw new IllegalArgumentException("사용자를 입력해 주세요.");
		}
		String group = UUID.randomUUID().toString();
		param.put("RENT_GROUP", group);
		tx.execute(status -> {
			for (String eqp : eqps) {
				param.put("EQP_SQ", eqp);
				if (mapper.updateEquipmentRented(param) != 1) throw new IllegalArgumentException("보관중이 아닌 장비가 있어 대여하지 못했습니다. 목록을 새로고침해 주세요.");
				mapper.insertRent(param);
			}
			return null;
		});
		Map<String, Object> out = one("RENT_GROUP", group);
		out.put("GUEST", guest);
		return out;
	}

	public void returnRents(Map<String, Object> param) {
		List<String> rents = ids(str(param, "RENT_SQS"));
		if (rents.isEmpty()) throw new IllegalArgumentException("반납할 장비를 골라 주세요.");
		date(str(param, "END_DT"), "반납일");
		String issue = str(param, "ISSUE").trim();
		param.put("CONTENT", issue);
		tx.execute(status -> {
			for (String rent : rents) {
				param.put("RENT_SQ", rent);
				if (mapper.closeRent(param) != 1) throw new IllegalArgumentException("이미 반납됐거나 반납일이 대여일보다 빠른 장비가 있습니다.");
				mapper.updateEquipmentReturned(param);
				if (!issue.isEmpty()) mapper.insertIssueByRent(param);
			}
			return null;
		});
	}

	public void dispose(Map<String, Object> param) {
		String to = str(param, "STATUS_CD");
		if (!"DISPOSED".equals(to) && !"LOST".equals(to)) throw new IllegalArgumentException("처리 구분이 올바르지 않습니다.");
		date(str(param, "DISPOSE_DT"), "처리일");
		param.put("FROM", "LOST".equals(to) ? Arrays.asList("STOCK", "RENT") : Arrays.asList("STOCK"));
		tx.execute(status -> {
			if (mapper.updateEquipmentDisposed(param) != 1) throw new IllegalArgumentException("폐기하려면 먼저 반납 처리해 주세요.");
			mapper.closeRentByEquipment(param);
			return null;
		});
	}

	public void saveRentField(Map<String, Object> param) {
		String field = str(param, "FIELD"), val = str(param, "VALUE").trim();
		if (!RENT_FIELDS.contains(field)) throw new IllegalArgumentException("이 항목은 고칠 수 없습니다.");
		if ("HOLDER_NM".equals(field) && val.isEmpty()) throw new IllegalArgumentException("사용자를 입력해 주세요.");
		if (field.endsWith("_DT") && !val.isEmpty()) date(val, "날짜");
		mapper.updateRentField(param);
	}

	public void addIssue(Map<String, Object> param) {
		if (str(param, "CONTENT").trim().isEmpty()) throw new IllegalArgumentException("이슈 내용을 입력해 주세요.");
		mapper.insertIssue(param);
	}

	public void closeIssue(Map<String, Object> param) {
		mapper.closeIssue(param);
	}

	public List<Map<String, Object>> staffEquipment(Object staffSq) {
		return mapper.selectStaffEquipment(one("STAFF_SQ", staffSq));
	}

	// ── 첨부 ──

	public void uploadFile(Object eqpSq, String doc, String name, String mime, byte[] data, String loginId) {
		if (!"RECEIPT".equals(doc) && !"ETC".equals(doc)) throw new IllegalArgumentException("첨부 종류가 올바르지 않습니다.");
		Map<String, Object> file = upload(name, mime, data, "RECEIPT".equals(doc) ? FOLDER_RECEIPT : FOLDER_ETC);
		Map<String, Object> p = one("EQP_SQ", eqpSq);
		p.put("DOC_CD", doc);
		p.put("FILE_ID", file.get("id"));
		p.put("FILE_NM", file.get("name"));
		p.put("WEB_LINK", file.get("webViewLink"));
		p.put("UPDT_EMPLY_ID", loginId);
		mapper.insertFile(p);
	}

	public void deleteFile(Map<String, Object> param) {
		mapper.deleteFile(param);
	}

	/** 직원 서류와 같은 드라이브 연결을 쓴다. 폴더는 연결 계정이 볼 수 있는 '3. 장비 관리' 아래에 둔다 */
	private Map<String, Object> upload(String name, String mime, byte[] data, String sub) {
		if (data == null || data.length == 0) throw new IllegalArgumentException("파일이 비어 있습니다.");
		if (data.length > MAX_FILE) throw new IllegalArgumentException("20MB 이하 파일만 올릴 수 있습니다.");
		String token = staffDrive.token();
		List<Map<String, Object>> roots = drive.search("mimeType = '" + GoogleDriveApi.FOLDER + "' and trashed = false and name = '" + FOLDER_ROOT + "'", token);
		if (roots.isEmpty()) throw new IllegalArgumentException("드라이브 연결 계정에서 '" + FOLDER_ROOT + "' 폴더를 찾지 못했습니다. 폴더 편집 권한을 확인해 주세요.");
		String parent = (String) roots.get(0).get("id"), folder = drive.childFolderId(parent, sub, token);
		if (folder == null) folder = drive.createFolder(sub, parent, token);
		return drive.upload(name == null || name.isEmpty() ? "file" : name, mime == null || mime.isEmpty() ? "application/octet-stream" : mime, data, folder, token);
	}

	// ── 전수조사 ──

	public List<Map<String, Object>> audits() {
		return mapper.selectAuditList();
	}

	public Object createAudit(String ym, String loginId) {
		if (!ym.matches("\\d{4}-(0[1-9]|1[0-2])")) throw new IllegalArgumentException("조사 월을 골라 주세요.");
		if (mapper.selectOpenAudit() != null) throw new IllegalArgumentException("진행 중인 회차를 먼저 마감해 주세요.");
		Map<String, Object> p = one("AUDIT_YM", ym);
		p.put("UPDT_EMPLY_ID", loginId);
		tx.execute(status -> {
			mapper.insertAudit(p);
			mapper.insertAuditDetail(p);
			return null;
		});
		return p.get("AUDIT_SQ");
	}

	public List<Map<String, Object>> auditDetail(Object auditSq) {
		return mapper.selectAuditDetail(one("AUDIT_SQ", auditSq));
	}

	public void saveAuditResult(Map<String, Object> param) {
		checkResult(str(param, "RESULT_CD"), true);
		if (mapper.updateAuditResult(param) != 1) throw new IllegalArgumentException("마감된 회차는 고칠 수 없습니다.");
	}

	public void closeAudit(Object auditSq) {
		Map<String, Object> p = one("AUDIT_SQ", auditSq);
		tx.execute(status -> {
			if (mapper.closeAudit(p) != 1) throw new IllegalArgumentException("이미 마감된 회차입니다.");
			mapper.updateLastCheck(p);
			return null;
		});
	}

	private static void checkResult(String result, boolean allowNone) {
		if (!"OK".equals(result) && !"BAD".equals(result) && !(allowNone && "NONE".equals(result))) throw new IllegalArgumentException("결과 값이 올바르지 않습니다.");
	}

	// ── 대여증서 ──

	/** 서명 전에는 현재 정보로, 서명 뒤에는 서명 시점의 내용으로 보여 준다 */
	public Map<String, Object> certificate(String group) {
		List<Map<String, Object>> rows = groupRows(group);
		Map<String, Object> out = new HashMap<>(), sign = mapper.selectSign(one("RENT_GROUP", group));
		out.put("group", group);
		out.put("holder", rows.get(0).get("HOLDER_NM"));
		out.put("guest", rows.get(0).get("EMPLY_ID") == null);
		out.put("staffSq", rows.get(0).get("STAFF_SQ"));
		out.put("seal", mapper.selectSeal());
		out.put("sign", sign);
		String doc = sign == null ? null : (String) sign.get("DOC_TEXT");
		out.put("pages", doc != null ? Arrays.asList(doc.split("\f")) : certificatePages(rows, LocalDate.now()));
		return out;
	}

	static List<String> certificatePages(List<Map<String, Object>> rows, LocalDate today) {
		List<String> pages = new ArrayList<>();
		for (Map<String, Object> r : rows) {
			pages.add("∎성명 : " + str(r, "HOLDER_NM") + "\n∎연락처 : " + str(r, "PHONE") + "\n∎대여 장비 항목 : " + TYPES.getOrDefault(str(r, "TYPE_CD"), str(r, "TYPE_CD"))
					+ "\n∎사내 장비 관리번호 : " + str(r, "EQP_NO") + "\n∎Product number : " + str(r, "MODEL_NM") + "\n∎serial number : " + str(r, "SERIAL_NO")
					+ "\n∎대여일 : " + str(r, "START_DT") + "\n\n" + LAW_TEXT + "\n\n" + today.getYear() + "년 " + today.getMonthValue() + "월 " + today.getDayOfMonth() + "일");
		}
		return pages;
	}

	public void sign(String group, String image, String signerId, String kind, String ip) {
		if (!validImage(image, true)) throw new IllegalArgumentException("서명을 입력해 주세요.");
		Map<String, Object> p = one("RENT_GROUP", group);
		p.put("SIGN_TP", "SCREEN");
		p.put("DOC_TEXT", String.join("\f", certificatePages(groupRows(group), LocalDate.now())));
		p.put("SIGN_IMG", image);
		p.put("SIGNER_ID", signerId);
		p.put("SIGNER_KIND", kind);
		p.put("SIGN_IP", ip);
		mapper.insertSign(p);
	}

	public void uploadSigned(String group, String name, String mime, byte[] data, String loginId, String ip) {
		groupRows(group);
		Map<String, Object> file = upload(name, mime, data, FOLDER_SIGN);
		Map<String, Object> p = one("RENT_GROUP", group);
		p.put("SIGN_TP", "UPLOAD");
		p.put("FILE_ID", file.get("id"));
		p.put("FILE_NM", file.get("name"));
		p.put("WEB_LINK", file.get("webViewLink"));
		p.put("SIGNER_ID", loginId);
		p.put("SIGNER_KIND", "GUEST");
		p.put("SIGN_IP", ip);
		mapper.insertSign(p);
	}

	public void saveSeal(String image, String loginId) {
		if (!validImage(image, false)) throw new IllegalArgumentException("500KB 이하의 PNG 또는 JPG 직인 이미지를 올려 주세요.");
		Map<String, Object> p = one("SEAL_IMG", image);
		p.put("UPDT_EMPLY_ID", loginId);
		mapper.saveSeal(p);
	}

	/** data URL 이 화면에 그대로 들어가므로 형식을 엄격히 본다 */
	static boolean validImage(String image, boolean pngOnly) {
		return image != null && image.length() <= MAX_IMAGE && IMAGE.matcher(image).matches() && (!pngOnly || image.startsWith("data:image/png;"));
	}

	private List<Map<String, Object>> groupRows(String group) {
		List<Map<String, Object>> rows = mapper.selectGroupRents(one("RENT_GROUP", group));
		if (rows.isEmpty()) throw new IllegalArgumentException("대여 건을 찾지 못했습니다.");
		return rows;
	}

	// ── 직원 화면 ──

	public Map<String, Object> staffByLogin(String loginId) {
		return loginId == null ? null : mapper.selectStaffByLogin(one("EMPLY_ID", loginId));
	}

	public List<Map<String, Object>> myRents(Object staffSq) {
		return mapper.selectMyRents(one("STAFF_SQ", staffSq));
	}

	/** 미응답 장비 수 + 서명 대기 묶음 수 */
	public int pending(Object staffSq) {
		int count = 0;
		Set<Object> groups = new LinkedHashSet<>();
		for (Map<String, Object> r : myRents(staffSq)) {
			if ("NONE".equals(r.get("RESULT_CD"))) count++;
			if ("Y".equals(r.get("SIGN_WAIT"))) groups.add(r.get("RENT_GROUP"));
		}
		return count + groups.size();
	}

	public void respond(Map<String, Object> param) {
		checkResult(str(param, "RESULT_CD"), false);
		if ("BAD".equals(param.get("RESULT_CD")) && str(param, "NOTE").trim().isEmpty()) throw new IllegalArgumentException("문제 내용을 입력해 주세요.");
		if (mapper.updateAuditSelf(param) != 1) throw new IllegalArgumentException("지금 응답할 수 있는 장비가 아닙니다.");
	}

	public boolean ownsGroup(String group, Object staffSq) {
		for (Map<String, Object> r : groupRows(group)) {
			if (r.get("STAFF_SQ") == null || !String.valueOf(r.get("STAFF_SQ")).equals(String.valueOf(staffSq))) return false;
		}
		return true;
	}

	// ── 공통 ──

	private static List<String> ids(String csv) {
		List<String> out = new ArrayList<>();
		for (String s : csv.split(",")) {
			if (s.trim().matches("\\d+")) out.add(s.trim());
		}
		return out;
	}

	private static void date(String val, String label) {
		try {
			LocalDate.parse(val);
		} catch (Exception e) {
			throw new IllegalArgumentException(label + "을(를) yyyy-MM-dd 형식으로 입력해 주세요.");
		}
	}

	private static Map<String, Object> one(String k, Object v) {
		Map<String, Object> m = new HashMap<>();
		m.put(k, v);
		return m;
	}

	private static String str(Map<String, Object> m, String k) {
		Object v = m.get(k);
		return v == null ? "" : v.toString();
	}
}
