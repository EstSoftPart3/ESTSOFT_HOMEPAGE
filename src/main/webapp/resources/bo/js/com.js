var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) ? true : false;
if(!isMobile){
	document.write("<script src='https://api-std.mainpay.co.kr/js/mainpay.pc-1.1.js'></script>");
}else{
	document.write("<script src='https://api-std.mainpay.co.kr/js/mainpay.mobile-1.0.js'></script>");
}
