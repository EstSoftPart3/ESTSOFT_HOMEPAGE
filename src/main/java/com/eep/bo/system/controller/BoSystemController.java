package com.eep.bo.system.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.eep.bo.system.service.BoSystemService;

/** 메뉴·권한 관리. 접근 제어는 /admin/** 인터셉터가 맡고 쓰기는 POST 만 받는다 */
@Controller
public class BoSystemController {

	@Autowired
	private BoSystemService service;

	/** 로그인 뒤와 화면 전환 토글의 진입점. 권한이 있는 첫 메뉴로 보낸다 */
	@RequestMapping(BoSystemService.HOME)
	public ModelAndView home(HttpSession session) {
		String url = service.access(loginId(session)).firstUrl();
		return new ModelAndView(url != null ? "redirect:" + url : "bo/system/no_access");
	}

	@RequestMapping("/admin/system/menu/openMenuManage.do")
	public ModelAndView openMenuManage() {
		return new ModelAndView("bo/system/menu_manage");
	}

	@RequestMapping("/admin/system/role/openRoleManage.do")
	public ModelAndView openRoleManage() {
		return new ModelAndView("bo/system/role_manage");
	}

	@RequestMapping(value = "/admin/system/menu/menuListData.do", method = RequestMethod.POST)
	public ModelAndView menuListData() {
		return call(service::menus);
	}

	@RequestMapping(value = "/admin/system/menu/saveMenuData.do", method = RequestMethod.POST)
	public ModelAndView saveMenuData(@RequestParam Map<String, Object> param, HttpSession session) {
		param.put("UPDT_EMPLY_ID", loginId(session));
		return call(() -> { service.saveMenu(param); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/menu/sortMenuData.do", method = RequestMethod.POST)
	public ModelAndView sortMenuData(@RequestParam("MENU_ORDER") String order) {
		return call(() -> { service.sortMenus(order); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/menu/deleteMenuData.do", method = RequestMethod.POST)
	public ModelAndView deleteMenuData(@RequestParam("MENU_CODE") String code) {
		return call(() -> { service.deleteMenu(code); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/role/roleListData.do", method = RequestMethod.POST)
	public ModelAndView roleListData() {
		return call(service::roles);
	}

	@RequestMapping(value = "/admin/system/role/saveRoleData.do", method = RequestMethod.POST)
	public ModelAndView saveRoleData(@RequestParam Map<String, Object> param) {
		return call(() -> { service.saveRole(param); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/role/deleteRoleData.do", method = RequestMethod.POST)
	public ModelAndView deleteRoleData(@RequestParam("ROLE_SQ") int roleSq) {
		return call(() -> { service.deleteRole(roleSq); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/role/saveRoleMenuData.do", method = RequestMethod.POST)
	public ModelAndView saveRoleMenuData(@RequestParam("ROLE_SQ") int roleSq, @RequestParam(value = "MENU_CODES", required = false) String codes) {
		return call(() -> { service.saveRoleMenus(roleSq, codes); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/role/addRoleUserData.do", method = RequestMethod.POST)
	public ModelAndView addRoleUserData(@RequestParam("ROLE_SQ") int roleSq, @RequestParam("EMPLY_ID") String emplyId, HttpSession session) {
		String login = loginId(session);
		return call(() -> { service.addRoleUser(roleSq, emplyId, login, service.access(login).superUser); return "OK"; });
	}

	@RequestMapping(value = "/admin/system/role/removeRoleUserData.do", method = RequestMethod.POST)
	public ModelAndView removeRoleUserData(@RequestParam("ROLE_SQ") int roleSq, @RequestParam("EMPLY_ID") String emplyId, HttpSession session) {
		String login = loginId(session);
		return call(() -> { service.removeRoleUser(roleSq, emplyId, login, service.access(login).superUser); return "OK"; });
	}

	private interface Call {
		Object run() throws Exception;
	}

	private static ModelAndView call(Call call) {
		ModelAndView mv = new ModelAndView("jsonView");
		try {
			mv.addObject("result", call.run());
		} catch (IllegalArgumentException e) {
			mv.addObject("error", e.getMessage());
		} catch (DataIntegrityViolationException e) {
			mv.addObject("error", "입력값이 너무 길거나 이미 있는 값입니다.");
		} catch (Exception e) {
			System.out.println("SYSTEM_ERROR " + e.getClass().getSimpleName());
			mv.addObject("error", "처리하지 못했습니다. (" + e.getClass().getSimpleName() + ")");
		}
		return mv;
	}

	@SuppressWarnings("unchecked")
	private static String loginId(HttpSession session) {
		Map<String, Object> info = (Map<String, Object>) session.getAttribute("loginInfo");
		List<Map<String, Object>> list = (List<Map<String, Object>>) info.get("loginInfo");
		return (String) list.get(0).get("emplyId");
	}
}
