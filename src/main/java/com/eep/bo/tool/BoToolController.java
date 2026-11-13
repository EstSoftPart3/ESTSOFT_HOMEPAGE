package com.eep.bo.tool;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.common.upload.Upload;

/** 업무툴 - 파일 용량 줄이기. 공통 Upload 규칙으로 한 파일씩 줄여 바로 돌려준다(서버에 남기지 않음) */
@Controller
public class BoToolController {

	@RequestMapping("/admin/tool/openCompress.do")
	public ModelAndView openCompress() {
		return new ModelAndView("bo/tool/compress");
	}

	/** 줄인 파일을 그대로 내려준다. 원본·결과 크기는 X-Before·X-After, 이름은 X-Name(URL 인코딩) */
	@RequestMapping(value = "/admin/tool/compressData.do", method = RequestMethod.POST)
	public void compressData(@RequestParam("file") MultipartFile file, HttpServletResponse response) throws IOException {
		Upload u;
		try {
			u = Upload.of(file);
		} catch (IllegalArgumentException e) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("text/plain; charset=UTF-8");
			response.getWriter().write(e.getMessage());
			return;
		}
		String name = URLEncoder.encode(u.name, "UTF-8").replace("+", "%20");
		response.setContentType(u.mime);
		response.setHeader("X-Content-Type-Options", "nosniff");
		response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + name);
		response.setHeader("X-Name", name);
		response.setHeader("X-Before", String.valueOf(u.before));
		response.setHeader("X-After", String.valueOf(u.data.length));
		response.setContentLength(u.data.length);
		response.getOutputStream().write(u.data);
	}
}
