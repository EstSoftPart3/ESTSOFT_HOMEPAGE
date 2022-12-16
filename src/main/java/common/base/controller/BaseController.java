package common.base.controller;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;

@Controller
public class BaseController {

	Logger log = Logger.getLogger(this.getClass());

	protected String getString(Object object) {
		String returnStr = "";
		
		if ( object != null ) {
			returnStr = object.toString();
		}
		
		return returnStr;
	}
	
}
