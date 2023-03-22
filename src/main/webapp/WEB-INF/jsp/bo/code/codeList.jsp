<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ include file="/WEB-INF/jsp/bo/boinclude/include_top.jspf"%>

<style type="text/css">
	#gridCodeList, #subGridCodeList {
		font-size : 11px;
	}
	.jsgrid-table {overflow-x: hidden;}
	.jsgrid-grid-header {overflow-x: hidden;}
	.jsgrid-grid-body {overflow-x: hidden;}
</style>

<body class="hold-transition sidebar-mini">

<input type="hidden" name="COMN_CD_SQ" id="COMN_CD_SQ">
<input type="hidden" name="mainTitleData" id="mainTitleData">
<input type="hidden" id="rowClickCdSq">

	<div class="wrapper">
	
		<%@ include file="/WEB-INF/jsp/bo/boinclude/include_left.jspf"%>
		
		 <div class="content-wrapper">
		 
		 	<!-- Main content -->
    		<section class="content">
    			<div class="card-header">
	               	<h3 class="card-title bTitle"><b>공통코드</b></h3>
				</div>
			
				<div class="card-body" style="background-color:#ffffff;">
					
					<div class="card-body table-responsive p-0" style="overflow:hidden;">
						<section class="content">
						
							<div class="container-fluid" style="padding-left:3px;">
								<div class="row">
									<div>
										<div class="card-body" style="width:100%;" align="right">
											
											<!-- 공통코드명 -->
											<div style="float:left">
												<div style="padding:5px;">
													<button id="BtnAddgridCodeList" type="button" onclick="AddClick('gridCodeList')" style="font-size:12px;">코드추가</button>
												</div>
											
												<div id="gridCodeList"></div>
											</div>
											<div style="float:left;padding-left:10px;">
												<div style="padding:5px">
													<div style="float:left;width:50%;text-align:left">
														<span id="mainTitle" style="font-size:13px;font-weight: bold;" >Main Title</span>
													</div>
													<div style="float:right;width:50%;">
														<button id="btnAddsubGridCodeList" type="button" onclick="AddClick('subGridCodeList')" style="font-size:12px;">코드추가</button>
													</div>
												</div>
												<div id="subGridCodeList"></div>
											</div>
										</div>
									</div>
									
									
								</div>
							</div>
							
						</section>
					</div>
					
				</div>
			</section>
		 </div>	
	</div>
     
   	<%@ include file="/WEB-INF/jsp/bo/boinclude/include_bottom.jspf"%>
   
	<script>
   	/* TEST */
   	var id = "${loginInfo.loginInfo[0].emplySq}";
   	
   	function AddClick(gridId) {  
		console.log("AddClick_"+gridId);
	    
	    if ($('#'+gridId+' .jsgrid-insert-row').css('display') == "none") {
	      	//Add 버튼 보이기, Show Add Button
	      	$('#'+gridId+' .jsgrid-insert-row').css({ display: 'table-row' });
	      	$('#'+gridId+' .jsgrid-insert-row.rownum').css({ display: 'none' });
	      	console.log($('#'+gridId+' .jsgrid-insert-row'));
	      	$('#BtnAdd'+gridId).text('닫기');
	      	return false;
	    }
	    
	    if ($('#'+gridId+' .jsgrid-insert-row').css('display') == "table-row") {
	      	//Add 버튼 숨기기, Hide Add Button 
	      	$('#'+gridId+' .jsgrid-insert-row').css({ display: 'none' });
	      	$('#BtnAdd'+gridId).text('코드추가');
	      	return false;
	    }

   	}
   
   	function fn_insertItem() {
	  	$("#gridCodeList").jsGrid("insertItem");
   	}
   
   	function fn_subInsertItem() {
		$("#subGridCodeList").jsGrid("insertItem");
	}
  
   
   	function fn_GpCmCd(str) {
		let params = {
			COMN_CD_SQ : str
	   	}

	   	$("#gridCodeList").jsGrid({
		   	locale:"ko",
           	height: "700px",
           	width: "400px",
           	inserting: false,
           	editing: true,
           	sorting: false,
           	paging: false,
           	autoload: true,
           	pageSize: 10,
           	deleteConfirm: "정말 삭제 하시겠습니까?",
           	controller: {
            	loadData: function (filter) {
            		var d = $.Deferred();
                   	$.ajax({
          	    	 	type: "post",
        	    	 	url: "/admin/code/codeBoardListData.do",
        	         	data: params,
        	         	dataType: "json"
        	      	}).done(function(response) {
        	      		d.resolve(response.comCodeList.comCodeListData);
					});
                   	return d.promise();
               	},
               	insertItem: function (item) {
               		item.REG_EMPLY_SQ = id;
            	   	return $.ajax({
                       	type: "POST",
                       	url: "/admin/code/codeBoardIsertData.do",
                       	data: item
                   	}).done(function(response) {
                		AddClick('gridCodeList');
          	    		$("#gridCodeList").jsGrid("loadData");
          	      	});
               	},
               	updateItem: function (item) {
               		item.UPDT_EMPLY_SQ = id;
            	   	return $.ajax({
                       	type: "POST",
                       	url: "/admin/code/codeBoardUpdateData.do",
                       	data: item
                   	}).done(function(response) {
          	    	 	$("#gridCodeList").jsGrid("loadData");
          	      	});
               	},
               	deleteItem: function (item) {
               		item.UPDT_EMPLY_SQ = id;
            	   	return $.ajax({
                       	type: "POST",
                       	url: "/admin/code/codeBoardDeleteData.do",
                       	data: item
                   	}).done(function(response) { 	    	 	
          	    		$("#gridCodeList").jsGrid("loadData");
          	      	});
               	}
           	},
           	fields: [
           		{ name: "ROWNUM"		,title:"", width: 150,align:"center" ,width:20},
        	   	{ name: "COMN_CD_SQ"	,title:"코드 순번", type: "text", width: 150,align:"center" ,width:100, visible: false},
        	   	{ name: "COMN_CD"		,title:"코드", type: "text", width: 150,align:"center" ,width:100, validate: "required" },
        	   	{ name: "COMN_CD_NM"	,title:"코드명", type: "text", width: 200,align:"center",width:100, validate: "required" },
        	   	{ type: "control"		,deleteButton: true },
        	   
           	],
           	rowClick: function(args) {
       	    	var getData = args.item.COMN_CD_SQ;
       	   		$('#COMN_CD_SQ').val(getData);
         		$('#mainTitleData').val(args.item.COMN_CD_NM);
         		$('#mainTitle').html(args.item.COMN_CD_NM);     		
         		fn_SubGpCmCd(getData);  
           	}          
       });
   	}
   
  	let subfields = [
	  	{ name: "COMN_CD_SQ"	,title:"코드순번", type: "text", width: 150,align:"center" ,width:100, visible: false},
	  	{ name: "COMN_DTL_CD_SQ"	,title:"상세코드순번", type: "text", width: 150,align:"center" ,width:100, visible: false},
      	{ name: "COMN_DTL_CD"	,title:"상세코드", type: "text", width: 200,align:"center",width:100 ,validate: "required"},
	  	{ name: "COMN_DTL_CD_NM"	,title:"상세코드명", type: "text", width: 200,align:"center",width:100 ,validate: "required"},
	  	{ name: "NOTE"	,title:"비고", type: "text", width: 200,align:"center",width:100},
	  	{ type: "control",deleteButton: true }
  	]
  
  	function fn_SubGpCmCd(str) {	      
		let subParams = {
			COMN_CD_SQ : str
		}

		$("#subGridCodeList").jsGrid({
			locale:"ko",
		  	height: "700px",
		    width: "700px",
		    paging: false,
		    autoload: true,
      		inserting: false,
		    editing: true,
		    fields : subfields,
		    deleteConfirm: "정말 삭제 하시겠습니까?",
			controller: {
				loadData: function (filter) {			   
					var comnCdSqValue =	$('#COMN_CD_SQ').val();
				   	var d = $.Deferred();
		            $.ajax({
		     	    	type: "post",
		   	    	 	url: "/admin/code/codeSubBoardListData.do",
		   	         	data: subParams,
		   	         	dataType: "json"
		   	      	}).done(function(response) {
		   	    	 	d.resolve(response.comCodeList.comSubCodeListData);	 
		   	    		$('#COMN_CD_SQ').val(comnCdSqValue);
		   	    		var mainTitleData = $('#mainTitleData').val();
     	         		$('#mainTitle').html(mainTitleData);    	
		   	      	});
		            return d.promise();
				},
		        insertItem: function (item) {
		       	   	var comnCdSqValue =	$('#COMN_CD_SQ').val();
		       	   	let iParam = {
		       	   		COMN_CD_SQ : comnCdSqValue,   
		       	   		REG_EMPLY_SQ : id,
		       	   		COMN_DTL_CD : item.COMN_DTL_CD,
		       	   		COMN_DTL_CD_NM : item.COMN_DTL_CD_NM,
		       	 		NOTE : item.NOTE
		       	   	}  
		       	   	return $.ajax({
		            	type: "POST",
		                url: "/admin/code/codeSubBoardIsertData.do",
		                data: iParam
		            }).done(function(response) {	     	    	 	
		     	    	$("#subGridCodeList").jsGrid("loadData");
		     	    	$('#COMN_CD_SQ').val(comnCdSqValue);	
		     	    	var mainTitleData = $('#mainTitleData').val();
		     	        $('#mainTitle').html(mainTitleData);
					});    
				},
		        updateItem: function (item) {
		       		var comnCdSqValue =	$('#COMN_CD_SQ').val();
		       	   	let uParam = {
		       			COMN_CD_SQ : comnCdSqValue,
		       			UPDT_EMPLY_SQ : id,
		       			COMN_DTL_CD_SQ : item.COMN_DTL_CD_SQ,
		       			COMN_DTL_CD : item.COMN_DTL_CD,
		       			COMN_DTL_CD_NM : item.COMN_DTL_CD_NM,
		       			NOTE : item.NOTE
		       	   	}
		       	   	return $.ajax({
		            	type: "POST",
		                url: "/admin/code/codeSubBoardUpdateData.do",
		                data: uParam
		            }).done(function(response) {
		     	   		$("#subGridCodeList").jsGrid("loadData");
		     	    	$('#COMN_CD_SQ').val(comnCdSqValue);    	 
		     	    	var mainTitleData = $('#mainTitleData').val();
	     	         	$('#mainTitle').html(mainTitleData);
		     	    });
				},
		        deleteItem: function (item) { 
		       		var comnCdSqValue =	$('#COMN_CD_SQ').val();       	  		       	    
		       	  	let dParam = {
		       	  		COMN_CD_SQ : comnCdSqValue,
		       	  		UPDT_EMPLY_SQ : id,
		       			COMN_DTL_CD_SQ : item.COMN_DTL_CD_SQ,
		       			COMN_DTL_CD : item.COMN_DTL_CD,
		       			COMN_DTL_CD_NM : item.COMN_DTL_CD_NM,
		       			NOTE : item.NOTE
		       	    }
		       	    return $.ajax({
		            	type: "POST",
		                url: "/admin/code/codeSubBoardDeleteData.do",
		                data: dParam
		            }).done(function(response) {	     	    	 
		     	    	$("#subGridCodeList").jsGrid("loadData");
		     	    	$('#COMN_CD_SQ').val(comnCdSqValue);	
		     	    	var mainTitleData = $('#mainTitleData').val();
		     	        $('#mainTitle').html(mainTitleData);
		     	    });
				}
			}
		});
  	}
   
 	$( document ).ready(function() {
	 	fn_GpCmCd();
	 	fn_SubGpCmCd();
 	});
   
	</script>
 
 
</body>
</html>