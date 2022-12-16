/************/
/** TIP    **/
/************/
/*	
	//** 소스 보기 막는것
	<body oncontextmenu='return false' ondragstart='return false' onselectstart='return false'>
	또는 아래와 같이 객체 접근도 가능
	document.oncontextmenu = function(){return false;}
	document.ondragstart = function(){return false;}
	document.onselectstart = function(){return false;}
	//document.body.onload = goBoard

	//**이미지 표시할때 X 안보이게 하기
	<img src="" onerror="javascript:this.src='empty.jpg';">

*/


/************/
/** OBJECT **/
/************/

/**
* isEmptyMessage(param1,param2) 
* 해당 객체의 값이 null 또는 빈값인지 검사한다.
* obj     : 검사할 객체
* message : 검사후 null 이나 빈값일경우 보여줄 message
**/
function isEmptyMessage(obj,message){
	var varObj = obj.value;
	if(varObj == '' || varObj == null){
		alert(message);
		obj.focus();
		return false;
	}
	return true;
}

/**
* onlyNum()
* 숫자만 입력한다. 기본적으로 영문키값을 배제 하기 때문에 입력모드를 영문모드로 변경하면 된다.
* 참고 사항 : onkeypress='onlyNum()' style="ime-mode:disabled;"
* style="ime-mode:auto"          (자동변경)   (한/영 전환 가능) 
* style="ime-mode:active"        (한글 모드)  (한/영 전환 가능) 
* style="ime-mode:inactive"      (영문 모드)  (오직 영문) 
* style="ime-mode:disabled"      (영문 모드)  (한/영 전환 가능) 
* style="ime-mode:deactivated"   (한글 모드)  (한/영 전환 가능) 
* 숫자이외에 허용해야 할키값이 있을경우 
**/
function onlyNum(){
	if (event.keyCode < 48 || event.keyCode > 57) event.returnValue = false;
}

/**
* checkDecimals(param1,param2)
* 숫자만 입력가능하고 입력 받은 소숫점 자리만큼 검사하여 준다.
* obj : 소수점을 입력받을 객체
* num : 허용할 자리수
**/
function checkDecimals(obj, num) {
		var objValue = obj.value;
		var dectext = "";
		decallowed = num;  
		if (isNaN(objValue) || objValue == "") {
			alert("잘못 입력 하셨습니다.");
			obj.select();
			obj.focus();
			return false;
		}else if(objValue.substring(0,1) == '.'){
			alert("첫번째 자리에 소숫점을 찍을수 없습니다.");
			return false;
		}else {
			if (objValue.indexOf('.') == -1){
				objValue += ".";
				dectext = objValue.substring(objValue.indexOf('.')+1, objValue.length);
				return false;
			}
			
			if (dectext.length > decallowed){
				alert ("소수점은 " + decallowed + " 자리 까지만 입력 가능합니다.");
				obj.select();
				obj.focus();
				return false;
			}else{
				return true;
			}
		 }
	}

/**
* isInputDate(param)
* 입력된 날짜형식 확인
* obj : 날짜를 입력받을 객체
* message : 형식 오류시 보여줄 message 예)"날짜 형식이 잘못되었습니다.\n예)2007-01-01"
**/
function isInputDate(obj,message){
	if(obj.value.length > 0){
		if(/^\d{4}-\d{2}-\d{2}$/g.test(obj.value)){
			return true;
		}else{
			alert(message);
			obj.value="";
			obj.focus();
			return false;
		}
	}else{
			alert("날짜를 입력하여 주십시오.");
			obj.focus();
			return false;
	}	
}

/*********************/
/** CHECKBOX OBJECT **/
/*********************/

/**
* isEmptyCheckBoxMessage(param1,param2) 
* 해당 CheckBox가 모두 선택되지 않았는지의 여부
* obj     : 검사할 CheckBox 객체
* message : 검사후 null 이나 빈값일경우 보여줄 message
**/
function isEmptyCheckBoxMessage(obj,message){
	var len = obj.length;
	if(len == null){
		if(obj.checked == false){
			alert(message);
			obj.focus();
			return false;
		}
	}else{
		var totCnt = 0;
		for(var i=0 ; i < len ; i++){
			if(obj[i].checked == false)totCnt++;
		}
		if(len == totCnt){
			alert(message);
			obj[0].focus();
			return false;
		}
	}
	return true;
}

/**
* isAllCheckBoxChecked(param1,param2) 
* Master CheckBox의 값에 따라 Sub CheckBox들의 값을 Master 와 동일하게 설정한다.
* mObj : Master CheckBox 객체
* sObj : Sub  CheckBox 객체
**/
function checkBoxAllChecked(mObj,sObj){
		var len = sObj.length;

		if(mObj.checked == true){
			if(len == null){
				sObj.checked = true;
			}else{
				for(var i=0 ; i < len ; i++){
					sObj[i].checked = true;
				}
			}
		}else if(mObj.checked == false){
			if(len == null){
				sObj.checked = false;
			}else{
				for(var i=0 ; i < len ; i++){
					sObj[i].checked = false;
				}
			}

		}
}

/**
* isAllCheckBoxChecked(param1,param2) 
* Master CheckBox의 값에 따라 Sub CheckBox들의 값을 반전시킨다.
* obj : 반전될 객체
**/
function checkBoxReverseChecked(obj){
		var len = obj.length;
		
		if(len == null){
			if(obj.checked == true)obj.checked = false;

			if(obj.checked == false)obj.checked = true;

		}else{
			var excute = false;
			for(var i=0 ; i < len ; i++){
				if(obj[i].checked == true){
					obj[i].checked = false;
					excute = true;
				}
				
				if(obj[i].checked == false && excute == false){
					obj[i].checked = true;
					excute = true;
				}
				excute = false;
			}
		}
}

/******************/
/** RADIO OBJECT **/
/******************/

/**
* isEmptyRadioMessage(param1,param2) 
* 해당 Radio 모두 선택되지 않았는지의 여부
* obj     : 검사할 Radio 객체
* message : 검사후 null 이나 빈값일경우 보여줄 message
**/
function isEmptyRadioMessage(obj,message){
	var len = obj.length;
	if(len == null){
		if(obj.checked == false){
			alert(message);
			obj.focus();
			return false;
		}
	}else{
		var totCnt = 0;
		for(var i=0 ; i < len ; i++){
			if(obj[i].checked == false)totCnt++;
		}
		if(len == totCnt){
			alert(message);
			obj[0].focus();
			return false;
		}
	}
	return true;
}


/******************/
/** REGEXP CHECK **/
/******************/

/**
* isCheckUrl(param1,param2,param3) 
* URL입력시 http:// 의 정규식 여부와 . 의 정규식 여부 검사.
* obj     : URL 입력 객체
* message1: 검사후 null 이나 빈값일경우 보여줄 message
* message2: 검사후 정규식이 아닌경우 보여줄 message
**/
function isCheckUrl(obj,message){
//	/(?:^|")(http|ftp|mailto):(?://)?(\w+(?:[\.:@]\w+)*?)(?:/|@)([^"\?]*?)(?:\?([^\?"]*?))?(?:$|")/

	 if(obj.value.length > 0){
		 if(/(http|ftp|mailto)/g.test(obj.value)){		
			return true;
		 }else{
			alert(message);
			obj.focus();
			return false;
		 }
		 }else{
				alert("URL 을 입력하여 주십시오.");
				obj.focus();
				return false;
		}	
}

/**
* 전화번호 유효성 검사
*
**/
function isPhoneNumber(obj,message){
}

/**
* 핸드폰 번호 유효성 검사
*
**/
function isHpNumber(hp,message1,message2){
	return eval("(/01[016789]" + arg + "[1-9]{1}[0-9]{2,3}" + arg + "[0-9]{4}$/).test(this)");
}

/**
* Email 유효성 검사
*
**/
function isEmail(obj,message){

	if(obj.value.length > 0){		
		if(/^(\w+)@(\w+)[.](\w+)$/ig.test(obj.value)==true || /^(\w+)@(\w+)[.](\w+)[.](\w+)$/ig.test(obj.value) == true){
			return true;
		}else{
			alert(message);
			obj.value="";
			obj.focus();
			return false;
		}
	}else{
			alert("Email 을 입력하여 주십시오.");
			obj.focus();
			return false;
	}	
}


/******************/
/** Text 제한    **/
/******************/

/************************/
/** isLimitByteMessage **/
/************************/
function isLimitByteMessage(obj,limitMax,msg) {
	var temp = 0;
	var onechar;
	var tcount = 0;
	var aquery = obj.value; 
	var tmpStr2 = "";

	tmpStr = new String(aquery);
	temp = tmpStr.length;
	
	for (k=0;k<temp;k++){
		onechar = tmpStr.charAt(k);
		if (escape(onechar).length > 4) {
			tcount += 2;
		}else{
			tcount++;
		}
		if(tcount>limitMax) {
			if(escape(tmpStr.charAt(tcount-2)).length == 3){
				k=k-1;
			}
			tmpStr2 = tmpStr.substring(0,k);
			break;
		}else{
			tmpStr2 += onechar; 
		}
	}		

	if(tcount > Number(limitMax)) {
		reserve = tcount-Number(limitMax);
		alert(msg);
		obj.value = tmpStr2;
	return;
	}
}


/************************/
/** clearEditTextArea **/
/************************/
/**
* TextArea의 문자길이 제한을 사용할때 사용한다.
* obj     : 
**/

function clearEditTextArea(obj,limitMax){
	if(obj.value == limitMax+"자까지 입력 가능합니다.")
		obj.value = "";
}

//TextArea 사용시.
function calPreTextArea(form,obj,limitMax){
	if(form.value != limitMax+"자까지 입력 가능합니다.")
		calByte(form,obj,obj.value,limitMax);
}

//문자열 byte 계산
var tcount = 0;
function calByte(form,obj,aquery,limitMax) {
	var temp = 0;
	var onechar;
		tcount = 0;

	tmpStr = new String(aquery);
	temp = tmpStr.length;

	for (k=0;k<temp;k++){
		onechar = tmpStr.charAt(k);
		if (escape(onechar).length > 4) {
			tcount += 2;
		}else if (onechar!='\r') {
			tcount++;
		}
	}
	
	document.all.charByteSubject.innerHTML="<strong>"+tcount+"</strong>/1000";
    form.input13.value = tcount;

	if(tcount > Number(limitMax)) {
		reserve = tcount-Number(limitMax);
		alert("입력 내용은 "+limitMax+"바이트 이상은 입력하실 수 없습니다.\r\n 쓰신 메세지는 "+reserve+"바이트가 초과되었습니다.\r\n 초과된 부분은 자동으로 삭제됩니다.");
		cutTextTextArea(form,obj,limitMax);
	return;
	}
}	

//초과 메시지 제어
function cutTextTextArea(form,obj,limitMax){
	netsCheck(form,obj,obj.value,limitMax,limitMax);
}

//초과 메시지 계산
function netsCheck(form,obj,aquery,max,limitMax){
	var tmpStr;
	var temp=0;
	var onechar;
	var tcount= 0;

	tmpStr = new String(aquery);
	temp = tmpStr.length;

	for(k=0;k<temp;k++){
		onechar = tmpStr.charAt(k);
		if(escape(onechar).length > 4) {
			tcount += 2;
		}else if(onechar!='\r') {
			tcount++;
		}
		if(tcount>max) {
			tmpStr = tmpStr.substring(0,k);
			break;
		}
	}

	if (max == limitMax) {
        obj.value = tmpStr;
		calByte(form,obj,tmpStr,max);
	}
	return tmpStr;
}



/******************/
/** 3Depth Combo **/
/******************/

/**
* 동적 3단콤보 생성
* obj     : 
**/
//---------------------------
//3단 콤보 시작
//---------------------------
window.onload = function(){
    initform(document.frm);    
}

function Category(value, text) {
    this.value = value;
    this.text = text;
    this.length = 0;
}

function addCategory(category, value, text) {
    category[category.length] = new Category(value, text);
    category.length++;
}

//listCategory start..
var category = new Category();

addCategory(category,"","선택1");
addCategory(category[0],"","선택2");
addCategory(category[0][0],"","선택3");

addCategory(category,"0001","요금제");
addCategory(category,"0002","부가서비스"); 
addCategory(category,"0003","폰꾸미기");

addCategory(category[1], '', '선택2');
addCategory(category[2], '', '선택2');
addCategory(category[3], '', '선택2');
addCategory(category[1], '1001', '기본요금제');
addCategory(category[1][0], '', '선택3');
addCategory(category[1][1], '', '선택3');
addCategory(category[1][1], '4001', '표준요금제');
addCategory(category[1][1], '4002', '투게더 요금제');
addCategory(category[1][1], '4003', 'TTL요금제');
addCategory(category[1][1], '4004', 'Ting요금제');
addCategory(category[1][1], '4005', '약정할인요금제');
addCategory(category[1][1], '4006', 'WCDMA 전용요금제');
addCategory(category[1][1], '4007', 'PDA요금제');
addCategory(category[1], '1009', '부가요금제');
addCategory(category[1][0], '', '선택3');
addCategory(category[1][2], '', '선택3');
addCategory(category[1][2], '4008', 'DATA요금제');
addCategory(category[1][2], '4009', '음성옵션요금제');
addCategory(category[1][2], '4010', '영상통화요금제');
addCategory(category[1][2], '4011', 'T로밍요금제');
addCategory(category[1][2], '4012', 'T MAP 네비게이션 요금제');
addCategory(category[1][2], '4013', '안전운전 서비스');
addCategory(category[1], '1017', '위성 DMB 요금제');
addCategory(category[1][0], '', '선택3');
addCategory(category[1][3], '', '선택3');
addCategory(category[1][3], '4015', '위성DMB 요금제');
addCategory(category[1][3], '4016', '위성DMB 부가요금제');
addCategory(category[1], '1021', '결합상품');
addCategory(category[1][0], '', '선택3');
addCategory(category[1][4], '', '선택3');
addCategory(category[1][4], '4017', '위성DMB TU 결합상품');
addCategory(category[1][4], '4018', '초고속 인터넷 결합상품');
addCategory(category[2], '2001', '통화');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][1], '', '선택3');
addCategory(category[2][1], '4020', '단말기 부재');
addCategory(category[2][1], '4021', '발신자 표시');
addCategory(category[2][1], '4022', '부재중 통화');
addCategory(category[2][1], '4023', '수신자 부담통화');
addCategory(category[2][1], '4025', '통화중 통화');
addCategory(category[2][1], '4026', '통화필터링');
addCategory(category[2][1], '4065', '통화대기');
addCategory(category[2], '2009', '문자서비스');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][2], '', '선택3');
addCategory(category[2][2], '4027', '메시징');
addCategory(category[2][2], '4028', '문자꾸미기');
addCategory(category[2][2], '4029', '문자로밍');
addCategory(category[2][2], '4030', '문자저장');
addCategory(category[2][2], '4031', '문자할인');
addCategory(category[2][2], '4032', '수신확인');
addCategory(category[2][2], '4033', '주소록');
addCategory(category[2], '2017', '커뮤니티');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][3], '', '선택3');
addCategory(category[2][3], '4034', '모바일 커뮤니티');
addCategory(category[2][3], '4035', '미팅 커뮤니티');
addCategory(category[2], '2020', '엔터테인먼트');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][4], '', '선택3');
addCategory(category[2][4], '4036', '만화');
addCategory(category[2][4], '4037', '방송');
addCategory(category[2][4], '4038', '영화');
addCategory(category[2][4], '4039', '포토');
addCategory(category[2], '2025', '금융/재테크');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][5], '', '선택3');
addCategory(category[2][5], '4040', '증권');
addCategory(category[2][5], '4041', '뱅킹');
addCategory(category[2][5], '4042', '재태크');
addCategory(category[2], '2029', '뉴스/생활/정보');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][6], '', '선택3');
addCategory(category[2][6], '4043', '뉴스');
addCategory(category[2][6], '4044', '생활');
addCategory(category[2][6], '4045', '정보');
addCategory(category[2], '2033', '학습/여성/유아');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][7], '', '선택3');
addCategory(category[2][7], '4046', '학습');
addCategory(category[2][7], '4047', '여성');
addCategory(category[2][7], '4048', '유아');
addCategory(category[2], '2037', '복권/운세');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][8], '', '선택3');
addCategory(category[2][8], '4049', '복권');
addCategory(category[2][8], '4050', '운세');
addCategory(category[2], '2040', '쇼핑/쿠폰/제휴');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][9], '', '선택3');
addCategory(category[2][9], '4051', '쇼핑');
addCategory(category[2][9], '4052', '쿠폰');
addCategory(category[2][9], '4053', '제휴');
addCategory(category[2], '2044', '교통/안전');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][10], '', '선택3');
addCategory(category[2][10], '4054', '교통정보');
addCategory(category[2][10], '4055', '길 찾기');
addCategory(category[2][10], '4056', '안전서비스');
addCategory(category[2], '2048', 'T서비스');
addCategory(category[2][0], '', '선택3');
addCategory(category[2][11], '', '선택3');
addCategory(category[2][11], '4058', 'T-INTERACTIVE');
addCategory(category[2][11], '4064', 'T-LIVE');
addCategory(category[3], '3001', '정액제/부가서비스');
addCategory(category[3][0], '', '선택3');
addCategory(category[3][1], '', '선택3');
addCategory(category[3][1], '4059', '컬러링 부가서비스');
addCategory(category[3][1], '4060', '벨소리 정액제');
addCategory(category[3][1], '4061', '배경화면 서비스');
addCategory(category[3][1], '4062', '뮤직서비스');
addCategory(category[3][1], '4063', '게임 정액제');

//listCategory end..
var bSubject    = false;
var bContents   = false;
var bComponents = false;

function initform(form) {
    form.subject.length = category.length;

    for (i = 0; i < category.length; i++){
        form.subject[i].value = category[i].value;
        form.subject[i].text = category[i].text;
        
        if(form.subject[i].value == ''){
            form.subject.selectedIndex = i;
            bSubject = true;
        }
        if(bSubject == false){
           form.subject.sesubjectndex = 0;
        }
        form.contents.selectedIndex = 0;
    }

    change_subject(form);
}

function change_subject(form) {
    var i = form.subject.selectedIndex;
    
    if(category[i].length != null){
        form.contents.length = category[i].length;
    
        for (j = 0; j < form.contents.length; j++){
            form.contents[j].value = category[i][j].value;
            form.contents[j].text  = category[i][j].text;
            if(form.contents[j].value == ''){
                form.contents.selectedIndex = j;
                bContents = true;
            }
            if(bContents == false){
                form.contents.selectedIndex = 0;
            }
        }
        change_contents(form);
    }
}

function change_contents(form) {
    var i = form.subject.selectedIndex
    var j = form.contents.selectedIndex;
    
    if(j > -1){
        form.components.length = category[i][j].length;
    
        for (k = 0; k < form.components.length; k++){
            form.components[k].value = category[i][j][k].value;
            form.components[k].text  = category[i][j][k].text;
            if(form.components[k].value == ''){
                 form.components.selectedIndex = k;
                 bComponents = true;
            }
            if(bComponents == false){
                form.components.selectedIndex = 0;
            }
        }
    }else{
        form.components[0].value = '';
        form.components[0].text  = '';
        form.components.selectedIndex = 0;
    }
}

function change_compo(form){
    var l = form.components.selectedIndex;   
	
}
//---------------------------
//3단 콤보 종료
//---------------------------


/******************/
/** 파일명제어   **/
/******************/

/**
* 첨부 파일명 및 확장자 구분하기
* obj     : 
**/
function setFileName(path){

	// 먼저 파일의 경로에서 디렉토리를 제외한 순수 파일이름과 . 을 포함한 확장자까지만 뽑습니다. (파일이름.확장자)				
	var	firstName = "";
	var	file = "";
		firstName = path.substring(0,7);

		if(firstName == "file://"){
			//File:///
			path = path.substring(8,path.length);
			file = path.substring(path.lastIndexOf('/')+1,path.length);
		}else if(firstName == "http://"){
			//Http://
			path = path.substring(7,path.length);
			file = path.substring(path.lastIndexOf('/')+1,path.length);
		}else{
			file = path.substring(path.lastIndexOf('\\')+1,path.length);
		}

   // 파일이름과 확장자를 뽑습니다. 파일이름에도 점 기호 ( . ) 를 사용하는 경우가 있으므로 이러한 경우까지
   // 염두해서 소스를 만들었습니다. 파일이름에 점기호가 있는 파일을 선택해서 확인해보세요.
   // 파일확장자가 아예 없는 경우도 있으므로 이 경우에는 별도로 메시지를 띄우기로 하겠습니다.
   var filename; 
   var exp;

   if(file.indexOf('.')>=0) {
		filename = file.substring(0,file.lastIndexOf('.'));
		exp = file.substring(file.lastIndexOf('.')+1,file.length);
   } else {
		filename = file;
		exp = '';
   }

   if(exp == "jpg" || exp == "JPG" || exp == "jpge" || exp == "JPGE" || exp == "bmp" || exp == "BMP" || exp == "gif" || exp == "GIF" ){		   
		document.all.id15_1.innerHTML = "<img src='../img/070/v5_icon_file.gif' align='absmiddle'>&nbsp;"+filename+"&nbsp;<a href=\"javascript:deleteFileName('image')\"><img src='../img/070/v5_bn_del_file2.gif' align='absmiddle' border='0'></a>";
   }else if(exp == "wav" || exp == "WAV"){
		document.all.id15_2.innerHTML = "<img src='../img/070/v5_icon_file.gif' align='absmiddle'>&nbsp;"+filename+"&nbsp;<a href=\"javascript:deleteFileName('music')\"><img src='../img/070/v5_bn_del_file2.gif' align='absmiddle' border='0'></a>";
   }
/*
	// 파일확장자 유무를 반환하여 확장자가 있으면 확장자를 소문자로 반환합니다. 없으면 별도 메시지를 반환합니다.
	var expMsg = exp!='' ? exp.toLowerCase() : '선택하신 파일에 확장자가 없습니다.';
	alert('파일명 : '+filename+'\n'+'확장자 : '+expMsg);
*/
}

//첨부 파일 삭제 하기
function deleteFileName(temp){
	if(temp == "image"){
		document.all.imageFileName.innerHTML ="";
		ifr_edit.document.screenImg0.removeNode(true);
		document.all.attachImagePath.value = "";
	}else if(temp == "music"){
		document.all.musicFileName.innerHTML ="";
		document.all.attachWavePath.value = "";
	}
}

/******************/
/** IframeResize **/
/******************/

/**
* IframeResize()
* Iframe Resize 한다.
* obj     : 
**/

/*******************Iframe 내용만큼 자동 Resize START **********************/
var iframeids=["ifrmMarkReview"]; //iframe 사이즈 자동조절

var iframehide="yes" ;

//실행순서 : 1
function resizeCaller() {
	var dyniframe=new Array() 
		for (i=0; i<iframeids.length; i++){ 
		if (document.getElementById) 
			resizeIframe(iframeids[i]) 
		if ((document.all || document.getElementById) && iframehide=="no"){ 
			var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i]) 
			tempobj.style.display="block" 
		} 
	} 
} 

//실행순서 : 2
function resizeIframe(frameid){ 
	var inc = 0;
	if(frameid == 'ifrmMarkQa')inc =10;

	var currentfr=document.getElementById(frameid) 
	if (currentfr && !window.opera){ 
		currentfr.style.display="block" 
		if (currentfr.contentDocument && currentfr.contentDocument.body.offsetHeight) //ns6 syntax 
			currentfr.height = currentfr.contentDocument.body.offsetHeight+inc; 
		else if (currentfr.Document && currentfr.Document.body.scrollHeight) //ie5+ syntax 
			currentfr.height = currentfr.Document.body.scrollHeight+inc; 
		if (currentfr.addEventListener) 
			currentfr.addEventListener("load", readjustIframe, false) 
		else if (currentfr.attachEvent) 
			currentfr.attachEvent("onload", readjustIframe) 
	}
	//작업종료후 최종 윈도우 Onload
	loadWindowResize();
} 
//실행순서 : ?
function readjustIframe(loadevt) { 
	var crossevt=(window.event)? event : loadevt 
	var iframeroot=(crossevt.currentTarget)? crossevt.currentTarget : crossevt.srcElement 
		if (iframeroot) 
			resizeIframe(iframeroot.id); 
} 
//실행순서 : ?
function loadintoIframe(iframeid, url){
	if (document.getElementById) 
		document.getElementById(iframeid).src=url 
} 

//실행순서 : 5
function loadWindowResize(){
	if (window.addEventListener) 
		window.addEventListener("load", resizeCaller, false) 
	else if (window.attachEvent) 
		window.attachEvent("onload", resizeCaller) 
	else 
		window.onload=resizeCaller 
}

/*******************Iframe 내용만큼 자동 Resize END **********************/


/* --------------------------------------------------------------------- */
//                          테스트 페이지 미반영
/* --------------------------------------------------------------------- */

/******************/
/** UTIL         **/
/******************/

/**
* modifyDay(param1) 
* 입력받은 2007101 - > 20071001 로 변환한다.
* date     : 날짜
**/
function modifyDay(date){
	var tempYMD = date;
	var tempYM  = date.substring(0,6);
	var tempD   = date.substring(6,date.length);
	
	if(Number(tempD) < 10)tempYMD = tempYM+"0"+tempD;
	
	return tempYMD;
}

/**
* TRIM
**/

String.prototype.ltrim = function(){
	var re = /\s*((\S+\s*)*)/;
	return this.replace(re,"$1");
}

String.prototype.rtrim = function(){
	var re = /((\s*\S+)*)\s*/;
	return this.replace(re,"$1");
}

String.prototype.trim = function(){
    return this.replace(/(^\s*)|(\s*$)/gi, "");
}

/**
* var str = 문자열.replaceAll("a", "1");  //문자열 내에서 'a'를 찾아 전부 '1'로 바꾸라는 의미
**/
String.prototype.replaceAll = function(str1, str2){
	var temp_str = "";

	if (this.trim() != "" && str1 != str2){
		temp_str = this.trim();

		while (temp_str.indexOf(str1) > -1){
			temp_str = temp_str.replace(str1, str2);
		}
	}
	return temp_str;
}
//-----------------------------------------------------------------------------
// 문자의 좌, 우 공백 제거
// @return : String
//-----------------------------------------------------------------------------
String.prototype.trim = function() {
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

//-----------------------------------------------------------------------------
// 문자의 좌 공백 제거
// @return : String
//-----------------------------------------------------------------------------
String.prototype.ltrim = function() {
    return this.replace(/(^\s*)/, "");
}

//-----------------------------------------------------------------------------
// 문자의 우 공백 제거
// @return : String
//-----------------------------------------------------------------------------
String.prototype.rtrim = function() {
    return this.replace(/(\s*$)/, "");    
}

//-----------------------------------------------------------------------------
// 문자열의 byte 길이 반환
// @return : int
//-----------------------------------------------------------------------------
String.prototype.byte = function() {
    var cnt = 0;
    for (var i = 0; i < this.length; i++) {
        if (this.charCodeAt(i) > 127)
            cnt += 2;
        else
            cnt++;
    }
    return cnt;
}

//-----------------------------------------------------------------------------
// 정수형으로 변환
// @return : String
//-----------------------------------------------------------------------------
String.prototype.int = function() {
    if(!isNaN(this)) {
        return parseInt(this);
    }else {
        return null;    
    }
}

//-----------------------------------------------------------------------------
// 숫자만 가져 오기
// @return : String
//-----------------------------------------------------------------------------
String.prototype.num = function() {
    return (this.trim().replace(/[^0-9]/g, ""));
}

//-----------------------------------------------------------------------------
// 숫자에 3자리마다 , 를 찍어서 반환
// @return : String
//-----------------------------------------------------------------------------
String.prototype.money = function() {
    var num = this.trim();
    while((/(-?[0-9]+)([0-9]{3})/).test(num)) {
        num = num.replace((/(-?[0-9]+)([0-9]{3})/), "$1,$2");
    }
    return num;
}

//-----------------------------------------------------------------------------
// 숫자의 자리수(cnt)에 맞도록 반환
// @return : String
//-----------------------------------------------------------------------------
String.prototype.digits = function(cnt) {
    var digit = "";
    if (this.length < cnt) {
        for(var i = 0; i < cnt - this.length; i++) {
            digit += "0";
        }
    }
    return digit + this;
}

//-----------------------------------------------------------------------------
// " -> &#34; ' -> &#39;로 바꾸어서 반환
// @return : String
//-----------------------------------------------------------------------------
String.prototype.quota = function() {
    return this.replace(/"/g, "&#34;").replace(/'/g, "&#39;");
}

//-----------------------------------------------------------------------------
// 파일 확장자만 가져오기
// @return : String
//-----------------------------------------------------------------------------
String.prototype.ext = function() {
    return (this.indexOf(".") < 0) ? "" : this.substring(this.lastIndexOf(".") + 1, this.length);    
}

//-----------------------------------------------------------------------------
// URL에서 파라메터 제거한 순수한 url 얻기
// @return : String
//-----------------------------------------------------------------------------    
String.prototype.uri = function() {
    var arr = this.split("?");
    arr = arr[0].split("#");
    return arr[0];    
}

//-------------------------------------------------------------------------------*\
//각종 체크 함수들
//-------------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// 정규식에 쓰이는 특수문자를 찾아서 이스케이프 한다.
// @return : String
//-----------------------------------------------------------------------------
String.prototype.meta = function() {
    var str = this;
    var result = ""
    for(var i = 0; i < str.length; i++) {
        if((/([\$\(\)\*\+\.\[\]\?\\\^\{\}\|]{1})/).test(str.charAt(i))) {
            result += str.charAt(i).replace((/([\$\(\)\*\+\.\[\]\?\\\^\{\}\|]{1})/), "\\$1");
        }else {
            result += str.charAt(i);
        }
    }
    return result;
}

//-----------------------------------------------------------------------------
// 정규식에 쓰이는 특수문자를 찾아서 이스케이프 한다.
// @return : String
//-----------------------------------------------------------------------------
String.prototype.remove = function(pattern) {
    return (pattern == null) ? this : eval("this.replace(/[" + pattern.meta() + "]/g, \"\")");
}

//-----------------------------------------------------------------------------
// 최소 최대 길이인지 검증
// str.isLength(min [,max])
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isLength = function() {
    var min = arguments[0];
    var max = arguments[1] ? arguments[1] : null;
    var success = true;
    if(this.length < min) {
        success = false;
    }
    if(max && this.length > max) {
        success = false;
    }
    return success;
}

//-----------------------------------------------------------------------------
// 최소 최대 바이트인지 검증
// str.isByteLength(min [,max])
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isByteLength = function() {
    var min = arguments[0];
    var max = arguments[1] ? arguments[1] : null;
    var success = true;
    if(this.byte() < min) {
        success = false;
    }

    if(max && this.byte() > max) {
        success = false;
    }
    return success;
}

//-----------------------------------------------------------------------------
// 공백이나 널인지 확인
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isBlank = function() {
    var str = this.trim();
    for(var i = 0; i < str.length; i++) {
        if ((str.charAt(i) != "\t") && (str.charAt(i) != "\n") && (str.charAt(i)!="\r")) {
            return false;
        }
    }
    return true;
}

//-----------------------------------------------------------------------------
// 숫자로 구성되어 있는지 학인
// arguments[0] : 허용할 문자셋
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isNum = function() {
    return (/^[0-9]+$/).test(this.remove(arguments[0])) ? true : false;
}

//-----------------------------------------------------------------------------
// 영어만 허용 - arguments[0] : 추가 허용할 문자들
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isEng = function() {
    return (/^[a-zA-Z]+$/).test(this.remove(arguments[0])) ? true : false;
}

//-----------------------------------------------------------------------------
// 숫자와 영어만 허용 - arguments[0] : 추가 허용할 문자들
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isEngNum = function() {
    return (/^[0-9a-zA-Z]+$/).test(this.remove(arguments[0])) ? true : false;
}

//-----------------------------------------------------------------------------
// 숫자와 영어만 허용 - arguments[0] : 추가 허용할 문자들
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isNumEng = function() {
    return this.isEngNum(arguments[0]);
}

//-----------------------------------------------------------------------------
// 아이디 체크 영어와 숫자만 체크 첫글자는 영어로 시작 - arguments[0] : 추가 허용할 문자들
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isUserid = function() {
    return (/^[a-zA-z]{1}[0-9a-zA-Z]+$/).test(this.remove(arguments[0])) ? true : false;
}

//-----------------------------------------------------------------------------
// 한글 체크 - arguments[0] : 추가 허용할 문자들
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isKor = function() {
    return (/^[가-힣]+$/).test(this.remove(arguments[0])) ? true : false;
}

//-----------------------------------------------------------------------------
// 주민번호 체크 - arguments[0] : 주민번호 구분자
// XXXXXX-XXXXXXX
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isJumin = function() {

    var arg = arguments[0] ? arguments[0] : "";

    var jumin = eval("this.match(/[0-9]{2}[01]{1}[0-9]{1}[0123]{1}[0-9]{1}" + arg + "[1234]{1}[0-9]{6}$/)");

    if(jumin == null) {

        return false;

    }

    else {

        jumin = jumin.toString().num().toString();

    }

    // 생년월일 체크

    var birthYY = (parseInt(jumin.charAt(6)) == (1 ||2)) ? "19" : "20";

    birthYY += jumin.substr(0, 2);

    var birthMM = jumin.substr(2, 2) - 1;

    var birthDD = jumin.substr(4, 2);

    var birthDay = new Date(birthYY, birthMM, birthDD);

    if(birthDay.getYear() % 100 != jumin.substr(0,2) || birthDay.getMonth() != birthMM || birthDay.getDate() != birthDD) {

        return false;

    }        

    var sum = 0;

    var num = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]

    var last = parseInt(jumin.charAt(12));

    for(var i = 0; i < 12; i++) {

        sum += parseInt(jumin.charAt(i)) * num[i];

    }

    return ((11 - sum % 11) % 10 == last) ? true : false;

}

//-----------------------------------------------------------------------------
// 외국인 등록번호 체크 - arguments[0] : 등록번호 구분자
// XXXXXX-XXXXXXX
// @return : boolean
//-----------------------------------------------------------------------------

String.prototype.isForeign = function() {

    var arg = arguments[0] ? arguments[0] : "";

    var jumin = eval("this.match(/[0-9]{2}[01]{1}[0-9]{1}[0123]{1}[0-9]{1}" + arg + "[5678]{1}[0-9]{1}[02468]{1}[0-9]{2}[6789]{1}[0-9]{1}$/)");

    if(jumin == null) {

        return false;

    }

    else {

        jumin = jumin.toString().num().toString();

    }

    // 생년월일 체크

    var birthYY = (parseInt(jumin.charAt(6)) == (5 || 6)) ? "19" : "20";

    birthYY += jumin.substr(0, 2);

    var birthMM = jumin.substr(2, 2) - 1;

    var birthDD = jumin.substr(4, 2);

    var birthDay = new Date(birthYY, birthMM, birthDD);

    if(birthDay.getYear() % 100 != jumin.substr(0,2) || birthDay.getMonth() != birthMM || birthDay.getDate() != birthDD) {

        return false;

    }

    if((parseInt(jumin.charAt(7)) * 10 + parseInt(jumin.charAt(8))) % 2 != 0) {

        return false;

    }

    var sum = 0;

    var num = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]

    var last = parseInt(jumin.charAt(12));

    for(var i = 0; i < 12; i++) {

        sum += parseInt(jumin.charAt(i)) * num[i];

    }

    return (((11 - sum % 11) % 10) + 2 == last) ? true : false;

}    

//-----------------------------------------------------------------------------
// 사업자번호 체크 - arguments[0] : 등록번호 구분자
// XX-XXX-XXXXX
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isBiznum = function() {

    var arg = arguments[0] ? arguments[0] : "";

    var biznum = eval("this.match(/[0-9]{3}" + arg + "[0-9]{2}" + arg + "[0-9]{5}$/)");

    if(biznum == null) {

        return false;

    }

    else {

        biznum = biznum.toString().num().toString();

    }

    var sum = parseInt(biznum.charAt(0));

    var num = [0, 3, 7, 1, 3, 7, 1, 3];

    for(var i = 1; i < 8; i++) sum += (parseInt(biznum.charAt(i)) * num[i]) % 10;

    sum += Math.floor(parseInt(parseInt(biznum.charAt(8))) * 5 / 10);

    sum += (parseInt(biznum.charAt(8)) * 5) % 10 + parseInt(biznum.charAt(9));

    return (sum % 10 == 0) ? true : false;

}

//-----------------------------------------------------------------------------
// 법인 등록번호 체크 - arguments[0] : 등록번호 구분자
// XXXXXX-XXXXXXX
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isCorpnum = function() {

    var arg = arguments[0] ? arguments[0] : "";

    var corpnum = eval("this.match(/[0-9]{6}" + arg + "[0-9]{7}$/)");

    if(corpnum == null) {

        return false;

    }

    else {

        corpnum = corpnum.toString().num().toString();

    }

    var sum = 0;

    var num = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]

    var last = parseInt(corpnum.charAt(12));

    for(var i = 0; i < 12; i++) {

        sum += parseInt(corpnum.charAt(i)) * num[i];

    }

    return ((10 - sum % 10) % 10 == last) ? true : false;

}

//-----------------------------------------------------------------------------
// 이메일의 유효성을 체크
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isEmail = function() {
    return (/\w+([-+.]\w+)*@\w+([-.]\w+)*\.[a-zA-Z]{2,4}$/).test(this.trim());
}

//-----------------------------------------------------------------------------
// 전화번호 체크 - arguments[0] : 전화번호 구분자
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isPhone = function() {
    var arg = arguments[0] ? arguments[0] : "";
    return eval("(/(02|0[3-9]{1}[0-9]{1})" + arg + "[1-9]{1}[0-9]{2,3}" + arg + "[0-9]{4}$/).test(this)");
}

//-----------------------------------------------------------------------------
// 핸드폰번호 체크 - arguments[0] : 핸드폰 구분자
// @return : boolean
//-----------------------------------------------------------------------------
String.prototype.isMobile = function() {
    var arg = arguments[0] ? arguments[0] : "";
    return eval("(/01[016789]" + arg + "[1-9]{1}[0-9]{2,3}" + arg + "[0-9]{4}$/).test(this)");
}


/******************/
/** Layer Control**/
/******************/

/**
* Layer Control
* Layer Control 한다.
* obj     : 
**/
//화면제어
function hideMe(arg){
	var layer = document.getElementById(arg);
	layer.style.display = "none";
}

/* 레이어 팝업 */
function layerView(num,name){

	var max = document.getElementsByName(name);
	for(i=1; i<=max.length;i++){

		if(num == i)
		{
			document.getElementById("theLayer"+i).style.display ="block";
			
		}else {
			document.getElementById("theLayer"+i).style.display = "none";
		}
	}
}	

//탭별메뉴보기
function tabmenu(obj,num){
	var max = document.getElementsByName("idrimage");
	for(i=1;i<=max.length;i++){
		var txt = max[i-1].src;
		var lastIndex = txt.lastIndexOf("_");  
		if(num == i)
		{
			if(txt.substring(lastIndex+1) != '.gif'){
			
				document.getElementById("add0"+i).style.display = "block";
				max[i-1].src = max[i-1].src.replace(".gif","_.gif");
			}
				document.getElementById("add0"+i).style.display = "block";					
			
		}else {
			max[i-1].src = max[i-1].src.replace("_.gif",".gif");
			document.getElementById("add0"+i).style.display = "none";
		}
	}	
}	

//<div><img src="/img/service/add/add_service_tab01_.gif" class="hand" onclick="tabmenu(this,1)" name="idrimage" alt="서비스 개요" /></div>
//	<div class="item" id="add01">



//	-------------------------------------------------------------------------------------------------------------------------------
/**
* 핸드폰 액정화면에서 사용했던것으로 입력 메시지길이 제한과 초과한 분량만큼의 삭제가 가능하다.
**/
/*
function calPre(){
	if(ifr_edit.document.body.innerText != "300자까지 입력 가능합니다.")
		calByte(ifr_edit.document.body.innerText);
}

//문자 메시지 byte 계산
var tcount = 0;
function calByte(aquery) {
	var temp = 0;
	var onechar;
		tcount = 0;

	tmpStr = new String(aquery);
	temp = tmpStr.length;

	for (k=0;k<temp;k++){
		onechar = tmpStr.charAt(k);
		if (escape(onechar).length > 4) {
			tcount += 2;
		}else if (onechar!='\r') {
			tcount++;
		}
	}
	
	document.all.charByte.innerHTML="<b>"+tcount+"</b>/1000";

	if(tcount > 80) {
		reserve = tcount-80;
		//alert("메시지 내용은 80바이트 이상은 전송하실수 없습니다.\r\n 쓰신 메세지는 "+reserve+"바이트가 초과되었습니다.\r\n 초과된 부분은 자동으로 삭제됩니다.");
		//cutText();
	return;
	}
}	

//초과 메시지 제어
function cutText(obj){
	netsCheck(ifr_edit.document.body.innerText,80);
}

//초과 메시지 계산
function netsCheck(aquery,max){
	var tmpStr;
	var temp=0;
	var onechar;
	var tcount= 0;

	tmpStr = new String(aquery);
	temp = tmpStr.length;

	for(k=0;k<temp;k++){
		onechar = tmpStr.charAt(k);
		if(escape(onechar).length > 4) {
			tcount += 2;
		}else if(onechar!='\r') {
			tcount++;
		}
		if(tcount>max) {
			tmpStr = tmpStr.substring(0,k);
			break;
		}
	}

	if (max == 80) {
		document.all.message.value = tmpStr;
		calByte(tmpStr);
	}
	return tmpStr;
}
*/

/*
//IMG 태그를 생성하고 생성된 태그에 이미지 값을 설정한다.
var img_url = document.images["recMessageImg"+num].src;
ifr_edit.document.body.innerHTML = "<img name='screenImg0' src='" + img_url + "' unselectable='on' width='103' height='85' >\n"+document.all.recMessage[num].innerText;
setFileName(img_url);
document.all.attachImagePath.value = img_url;
calPre();

//객체 아이디 접근방법
document.getElementById('recommendation').style.display='';
document.getElementById('recommendationImage').style.display='none';


//입력된 핸드폰 번호 확인
function checkReceivedPhone(obj){
	if(obj.value.length > 0){
		if(!eval("(/01[016789][1-9]{1}[0-9]{2,3}[0-9]{4}$/).test(obj.value)")){
			alert("번호 형식이 잘못되었습니다.");
			obj.value="";
			return false;
		}
	}
}


//첨부 파일명 및 확장자 구분하기
	function setFileName(path){

		// 먼저 파일의 경로에서 디렉토리를 제외한 순수 파일이름과 . 을 포함한 확장자까지만 뽑습니다. (파일이름.확장자)				
		var	firstName = "";
		var	file = "";
			firstName = path.substring(0,7);

			if(firstName == "file://"){
				//File:///
				path = path.substring(8,path.length);
				file = path.substring(path.lastIndexOf('/')+1,path.length);
			}else if(firstName == "http://"){
				//Http://
				path = path.substring(7,path.length);
				file = path.substring(path.lastIndexOf('/')+1,path.length);
			}else{
				file = path.substring(path.lastIndexOf('\\')+1,path.length);
			}

	   // 파일이름과 확장자를 뽑습니다. 파일이름에도 점 기호 ( . ) 를 사용하는 경우가 있으므로 이러한 경우까지
	   // 염두해서 소스를 만들었습니다. 파일이름에 점기호가 있는 파일을 선택해서 확인해보세요.
	   // 파일확장자가 아예 없는 경우도 있으므로 이 경우에는 별도로 메시지를 띄우기로 하겠습니다.
	   var filename; 
	   var exp;

	   if(file.indexOf('.')>=0) {
			filename = file.substring(0,file.lastIndexOf('.'));
			exp = file.substring(file.lastIndexOf('.')+1,file.length);
	   } else {
			filename = file;
			exp = '';
	   }

	   if(exp == "jpg" || exp == "JPG" || exp == "jpge" || exp == "JPGE" || exp == "bmp" || exp == "BMP" || exp == "gif" || exp == "GIF" ){		   
			document.all.imageFileName.innerHTML = "<img src='../img/070/v5_icon_file.gif' align='absmiddle'>&nbsp;"+filename+"&nbsp;<a href=\"javascript:deleteFileName('image')\"><img src='../img/070/v5_bn_del_file2.gif' align='absmiddle' border='0'></a>";
	   }else if(exp == "wav" || exp == "WAV"){
			document.all.musicFileName.innerHTML = "<img src='../img/070/v5_icon_file.gif' align='absmiddle'>&nbsp;"+filename+"&nbsp;<a href=\"javascript:deleteFileName('music')\"><img src='../img/070/v5_bn_del_file2.gif' align='absmiddle' border='0'></a>";
	   }

		// 파일확장자 유무를 반환하여 확장자가 있으면 확장자를 소문자로 반환합니다. 없으면 별도 메시지를 반환합니다.
		var expMsg = exp!='' ? exp.toLowerCase() : '선택하신 파일에 확장자가 없습니다.';
		alert('파일명 : '+filename+'\n'+'확장자 : '+expMsg);

	}

	//첨부 파일 삭제 하기
	function deleteFileName(temp){
		if(temp == "image"){
			document.all.imageFileName.innerHTML ="";
			ifr_edit.document.screenImg0.removeNode(true);
			document.all.attachImagePath.value = "";
		}else if(temp == "music"){
			document.all.musicFileName.innerHTML ="";
			document.all.attachWavePath.value = "";
		}
	}
*/
