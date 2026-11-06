"""staff_export.ps1 이 만든 JSON 을 TB_EEP_HR_STAFF_M 에 넣는다 (서버에서 실행, 전체 교체).

사용: python3 -I staff_import.py <staff.json> <운영 WAR 경로>
- 주민번호·계좌번호는 WAR 안 config/db.properties 의 rrn.key 로 암호화한다 (common.util.RrnCipher 와 같은 형식).
- 넣기 전 표 전체를 /DATA/est_homepage/staff_backup_<시각>.sql 로 남긴다 (권한 600, 암호문만 들어 있다).
- shortcut: 화면에서 고친 값도 엑셀 값으로 덮어쓴다. 엑셀과 병행하는 동안 최종 최신화 때만 다시 돌린다.
  병행을 끝내고 화면을 원본으로 쓰게 되면 이 스크립트는 더 쓰지 않는다.
"""
import base64, datetime, json, os, subprocess, sys, zipfile
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

COLS = ["STATUS_CD", "SEQ_NO", "ORG_NM", "DEPT_NM", "POSITION_NM", "STAFF_NM", "RRN_ENC", "PHONE", "EMAIL", "ADDR", "STATION",
        "JOIN_DT", "LEAVE_DT", "HS_NM", "HS_MAJOR", "HS_GRAD", "UNIV_NM", "UNIV_MAJOR", "UNIV_GRAD", "FINAL_EDU",
        "MIL_IN_DT", "MIL_OUT_DT", "MIL_EXEMPT", "EDU_NM", "EDU_START_DT", "EDU_END_DT", "EDU_ORG", "CERT_DT", "BANK_NM", "ACCOUNT_ENC",
        "DOC_REG", "DOC_ID", "DOC_GRAD", "DOC_BANK", "DOC_PHOTO", "DOC_HI", "DOC_CONTRACT", "DOC_BIZ", "DOC_EI", "DOC_SEC",
        "DOC_EDU", "DOC_NEP", "DOC_PRIV", "DOC_CRIME", "DOC_MIL", "EMG_REL1", "EMG_TEL1", "EMG_REL2", "EMG_TEL2",
        "PREV_CAREER", "HOBBY", "LANG_SKILL", "SPECIALTY", "MEMO", "SCORE", "GAPIL_YN", "AUTO_APLY_YN", "GRADE_NM", "REAL_CAREER",
        "WISH_PRICE", "SK_FE", "SK_BE", "WORK_DOMAIN", "WISH_LOC", "ETC1", "SK_LANG", "REPORT", "SK_FW", "SK_DB", "SK_IDE", "SK_VCS",
        "ETC2", "EXPERTISE", "SK_OS"]
SECRET = {"RRN_ENC": "RRN", "ACCOUNT_ENC": "ACCOUNT"}
DB = ["docker", "exec", "-i", "mariadb", "mariadb", "-uadmin", "-p" + os.environ.get("DB_ADMIN_PW", ""), "est_eep_db"]


def war_key(war):
    with zipfile.ZipFile(war) as z:
        for line in z.read("WEB-INF/classes/config/db.properties").decode("utf-8").splitlines():
            if line.startswith("rrn.key="):
                key = base64.b64decode(line.split("=", 1)[1].strip())
                assert len(key) == 32, "rrn.key 는 32바이트여야 한다"
                return key
    raise SystemExit("WAR 의 db.properties 에 rrn.key 가 없다")


def enc(key, plain):
    iv = os.urandom(12)
    return "enc:v1:" + base64.b64encode(iv + AESGCM(key).encrypt(iv, plain.encode("utf-8"), None)).decode()


def lit(v):
    if v is None or v == "":
        return "NULL"
    return "CONVERT(UNHEX('%s') USING utf8mb4)" % v.encode("utf-8").hex()


def main(path, war):
    if not os.environ.get("DB_ADMIN_PW"):
        raise SystemExit("DB_ADMIN_PW 환경변수가 필요하다")
    key = war_key(war)
    rows = json.load(open(path, encoding="utf-8-sig"))
    if isinstance(rows, dict):
        rows = [rows]
    assert rows and all(r.get("STAFF_NM") and r.get("STATUS_CD") in ("WORK", "LEFT") for r in rows), "성명·재직 상태가 빈 행이 있다"

    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup = "/DATA/est_homepage/staff_backup_%s.sql" % stamp
    old = os.umask(0o077)
    with open(backup, "wb") as f:
        subprocess.run(["docker", "exec", "mariadb", "mariadb-dump", "-uadmin", "-p" + os.environ["DB_ADMIN_PW"], "est_eep_db", "TB_EEP_HR_STAFF_M"],
                       stdout=f, check=True)
    os.umask(old)

    sql = ["START TRANSACTION;", "DELETE FROM TB_EEP_HR_STAFF_M;"]
    for r in rows:
        vals = []
        for c in COLS:
            v = r.get(SECRET[c]) if c in SECRET else r.get(c)
            vals.append(lit(enc(key, v) if c in SECRET and v else v))
        sql.append("INSERT INTO TB_EEP_HR_STAFF_M (%s, UPDT_EMPLY_ID, UPDT_DT) VALUES (%s, 'IMPORT', NOW());" % (", ".join(COLS), ", ".join(vals)))
    sql.append("COMMIT;")
    subprocess.run(DB, input="\n".join(sql).encode("utf-8"), check=True)

    # 확인: 건수와 암호문이 모두 원문으로 돌아오는지
    out = subprocess.run(DB + ["-N", "-B", "-e", "SELECT STATUS_CD, COUNT(*) FROM TB_EEP_HR_STAFF_M GROUP BY STATUS_CD;"
                               "SELECT 'S', IFNULL(RRN_ENC,''), IFNULL(ACCOUNT_ENC,'') FROM TB_EEP_HR_STAFF_M"],
                         stdout=subprocess.PIPE, check=True).stdout.decode("utf-8")
    want_rrn = sorted(r["RRN"] for r in rows if r.get("RRN"))
    want_acc = sorted(r["ACCOUNT"] for r in rows if r.get("ACCOUNT"))
    got_rrn, got_acc = [], []
    for line in out.splitlines():
        p = line.split("\t")  # -B 출력은 열 사이만 탭이다 (값 안의 탭은 \t 글자로 바뀐다)
        if p[0] == "S":
            for val, acc in ((p[1], got_rrn), (p[2], got_acc)):
                if val:
                    raw = base64.b64decode(val[len("enc:v1:"):])
                    acc.append(AESGCM(key).decrypt(raw[:12], raw[12:], None).decode("utf-8"))
        else:
            print("건수", line)
    assert sorted(got_rrn) == want_rrn and sorted(got_acc) == want_acc, "복호화 결과가 원문과 다르다"
    print("넣음 %d명, 주민번호 %d건·계좌번호 %d건 복호화 일치, 이전 표 백업 %s" % (len(rows), len(got_rrn), len(got_acc), backup))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
