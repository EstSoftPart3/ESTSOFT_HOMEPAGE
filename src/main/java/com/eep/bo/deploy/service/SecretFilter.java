package com.eep.bo.deploy.service;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.eep.mapper.BoDeployMapper;

/**
 * 시크릿: 시크릿 계정에 연결된 직원은 시크릿 계정에게만 보인다.
 * 서버가 아예 내려보내지 않고, 그 직원을 가리키는 요청은 '찾지 못했다'로 거부한다. 시크릿 표시(SECRET)도 시크릿 계정에게만 붙인다.
 */
@Service
public class SecretFilter {

	@Autowired
	private BoDeployMapper mapper;

	public View view(String loginId) {
		Map<String, Object> q = new HashMap<>();
		q.put("EMPLY_ID", loginId);
		return new View(mapper.countSecretViewer(q) > 0, new HashSet<>(mapper.selectSecretStaff()));
	}

	public String staffOfDeploy(Object deploySq) {
		Map<String, Object> q = new HashMap<>();
		q.put("DEPLOY_SQ", deploySq);
		return mapper.selectDeployStaff(q);
	}

	public String staffOfChange(Object chgSq) {
		Map<String, Object> q = new HashMap<>();
		q.put("CHG_SQ", chgSq);
		Map<String, Object> h = mapper.selectChange(q);
		return h == null ? null : String.valueOf(h.get("STAFF_SQ"));
	}

	public static final class View {
		public final boolean secret;
		private final Set<String> staff;

		View(boolean secret, Set<String> staff) {
			this.secret = secret;
			this.staff = staff;
		}

		public boolean hides(Object staffSq) {
			return !secret && staffSq != null && staff.contains(String.valueOf(staffSq));
		}

		/** 숨길 직원 행을 빼고, 시크릿 계정에게는 시크릿 직원 행에 SECRET 을 붙인다. key 는 직원 번호 칸 */
		public <T extends Collection<Map<String, Object>>> T filter(T rows, String key) {
			if (rows == null) {
				return null;
			}
			rows.removeIf(r -> hides(r.get(key)));
			if (secret) {
				rows.forEach(r -> {
					if (staff.contains(Objects.toString(r.get(key), ""))) {
						r.put("SECRET", true);
					}
				});
			}
			return rows;
		}

		public <T extends Collection<Map<String, Object>>> T filter(T rows) {
			return filter(rows, "STAFF_SQ");
		}

		/** 숨긴 직원을 가리키면 없는 것처럼 거부한다 */
		public void guard(Object staffSq) {
			if (hides(staffSq)) {
				throw new IllegalArgumentException("직원을 찾지 못했습니다.");
			}
		}

		@SuppressWarnings("unchecked")
		public Map<String, Object> filterMap(Map<String, Object> out, String... listKeys) {
			for (String k : listKeys) {
				if (out.get(k) instanceof List) {
					filter((List<Map<String, Object>>) out.get(k));
				}
			}
			return out;
		}
	}
}
