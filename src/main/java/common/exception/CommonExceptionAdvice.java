package common.exception;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class CommonExceptionAdvice{
	
	final static Log log = LogFactory.getLog(CommonExceptionAdvice.class);

    @ExceptionHandler(Exception.class)
    public void commSystemExceptionHandler(Exception e) {
    	
    	log.info("########################## commSystemExceptionHandler : " +  e.toString());
        
    }
    
}