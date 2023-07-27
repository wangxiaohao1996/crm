<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" +
request.getServerName() + ":" + request.getServerPort() +
request.getContextPath() + "/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){
		//给“下次联系时间”标签添加日历格式
		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoclose:true,//设置选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true, //设置是否显示“今天”按钮，默认设计false
			clearBtn:true  //设置是否显示“清空”按钮，默认是false

		})
		//当线索主页面加载完成之后,显示所有数据的第一页
		queryActivityByConditionForPage(1,10);


		//给“创建”按钮绑定单击事件
		$("#createClueBtn").click(function (){
			//给创建的模态窗口初始化
			$("#createClueFrom")[0].reset();
			//弹出创建的模态窗口
			$("#createClueModal").modal("show");
		})

		//给“保存”按钮添加单击事件
		$("#saveCreateClueBtn").click(function (){
			//收集参数
	    	var fullname=$.trim($("#create-fullname").val());
	    	var appellation=$("#create-appellation").val();
	    	var owner=$("#create-owner").val();
	    	var company=$.trim($("#create-company").val());
	    	var job=$.trim($("#create-job").val());
	    	var email=$.trim($("#create-email").val());
	    	var phone=$.trim($("#create-phone").val());
	    	var website=$.trim($("#create-website") .val());
	    	var mphone=$.trim($("#create-mphone").val());
	    	var state=$("#create-state").val();
	    	var source=$("#create-source").val();
	    	var description=$.trim($("#create-description").val());
	    	var contactSummary=$.trim($("#create-contactSummary").val());
	    	var nextContactTime=$.trim($("#create-nextContactTime").val());
	    	var address=$.trim($("#create-address").val());
             //表单验证
			var regExp1 = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
			var regExp2 = /\d{3}-\d{8}|\d{4}-\d{7}/;
			var regExp3 = /[a-zA-z]+:\/\/[^\s]*/;
			var regExp4 = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
			if (owner==""){
					  alert("所有者不能为空");
					  return;
				  }else if (company==""){
					  alert("公司不能为空");
					  return;
				  }else if (fullname==""){
					  alert("姓名不能为空");
					  return;
				  } else if (!regExp1.test(email)){
				      alert("输入的邮箱格式不正确")
				      return;
			      }else if (!regExp2.test(phone)){
				       alert("输入的公司座机格式不正确")
				       return;
			}else if (!regExp3.test(website)){
				       alert("输入的公司网址格式不正确")
				return;
			}else if (!regExp4.test(mphone)){
				alert("输入的手机号码格式不正确")
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/clue/saveCreateClue.do',
				data:{
                       fullname          :fullname       ,
                       appellation       :appellation    ,
                       owner             :owner          ,
                       company           :company        ,
                       job               :job            ,
                       email             :email          ,
                       phone             :phone          ,
                       website           :website        ,
                       mphone            :mphone         ,
                       state             :state          ,
                       source            :source         ,
                       description       :description    ,
                       contactSummary    :contactSummary ,
                       nextContactTime   :nextContactTime,
                       address           :address
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code==1){
						//关闭模态窗口
						$("#createClueModal").modal("hide");
						//刷新线索列表，显示第一页数据，保持每页显示条数不变
						queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
					}else {
						alert(data.message);
						$("#createClueModal").modal("show");
					}
				}
			});
		})

		//给“查询”按钮绑定单击事件
         $("#searchBtn").click(function (){
			 //用户在线索主页面填写查询条件,点击"查询"按钮,显示所有符合条件的数据的第一页;
			 queryActivityByConditionForPage(1,10);
		 })




		//复选框全选
		$("#checkAll").click(function (){
			var checked=this.checked;
			$("#tBody input[type='checkbox']").prop("checked",checked)
		})
		//给tbody的所有复选框绑定单击事件，取消全选
		$("#tBody").on("click","input[type='checkbox']",function (){
			//获取所有的复选框和所有选中的复选框
			//获取tBody下所有的复选框和选中的复选框
			var checkboxs = $("#tBody input[type='checkbox']");
			var checkeds = $("#tBody input[type='checkbox']:checked");
			//判断是否相等，相等全选，不相等，取消全选
			$("#checkAll").prop("checked",checkboxs.size()==checkeds.size());
		})



		//给‘删除’按钮绑定单击事件
		$("#deleteBtn").click(function (){
			//获取复选框选中个数
			var checkedNum = $("#tBody input[type='checkbox']:checked");
			if (checkedNum.size()==0){
				alert("请选择您要删除的线索");
				return;
			}
			if (window.confirm("确定要删除吗？")){
				//收集参数
				var ids="";
				$.each(checkedNum,function (index,obj){
					ids+="id="+this.value+"&";
				})
				//去掉最后一个多余的&
				ids=ids.substr(0,ids.length-1);
				$.ajax({
					url:'workbench/clue/deleteCuleByIds.do',
					data:ids,
					type:'post',
					dataType:'json',
					success:function (data){
						if (data.code=="1"){
							//刷新线索列表，保持当前页和每页条数
							queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
						}else {
							//提示信息
							alert(data.message);
						}
					}
				})
			}
		})




		//给‘修改’按钮绑定单击事件
		$("#updateBtn").click(function (){
			//获取选中的复选框
			var checkedNum = $("#tBody input[type='checkbox']:checked");
			//每次只能修改一条线索
			if (checkedNum.size()==0){
				alert("请选择您要修改的线索");
				return;
			}else if (checkedNum.size()>1){
				alert("每次只能修改一条线索");
				return;
			}
			var id = checkedNum.val();
			$.ajax({
				url:'workbench/clue/queryClueById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data){
					//给修改模态窗口表单默认赋值
					//所有者默认选中
					var selected1=$("#edit-clueOwner option")
					$.each(selected1,function (index,obj){
						if ($(this).html()==data.owner){
							$(this).prop("selected",true);
						}
					})
					//称呼默认选中
					var selected2=$("#edit-call option")
					$.each(selected2,function (index,obj){
						if ($(this).html()==data.appellation){
							$(this).prop("selected",true);
						}
					})
					//来源默认选中
					var selected3=$("#edit-source option")
					$.each(selected3,function (index,obj){
						if ($(this).html()==data.source){
							$(this).prop("selected",true);
						}
					})
					//线索状态默认选中
					var selected4=$("#edit-status option")
					$.each(selected4,function (index,obj){
						if ($(this).html()==data.state){
							$(this).prop("selected",true);
						}
					})
					   $("#hidden-clueId").val(data.id);
					   $("#edit-company").val(data.company);
					   $("#edit-surname").val(data.fullname);
					   $("#edit-job").val(data.job);
					   $("#edit-email").val(data.email);
					   $("#edit-phone").val(data.phone);
					   $("#edit-website").val(data.website);
					   $("#edit-mphone").val(data.mphone);
					   $("#edit-describe").val(data.description);
					   $("#edit-contactSummary").val(data.contactSummary);
					   $("#edit-nextContactTime").val(data.nextContactTime);
					   $("#edit-address").val(data.address);
					   //打开模态窗口
					$("#editClueModal").modal("show");
				}
			})
		})




		//给“更新”按钮绑定单击事件
		$("#updateClueBtn").click(function (){
			//收集参数
		var	id                =$("#hidden-clueId").val();
		var	owner             =$("#edit-clueOwner").val();
		var	company           =$.trim($("#edit-company").val());
		var	appellation       =$("#edit-call").val();
		var	fullname          =$.trim($("#edit-surname").val());
		var	job               =$.trim($("#edit-job").val());
		var	email             =$.trim($("#edit-email").val());
		var	phone             =$.trim($("#edit-phone").val());
		var	website           =$.trim($("#edit-website").val());
		var	mphone            =$.trim($("#edit-mphone").val());
		var	state             =$("#edit-status").val();
		var	source            =$("#edit-source").val();
        var description       =$.trim($("#edit-describe").val());
        var contactSummary    =$.trim($("#edit-contactSummary").val());
        var nextContactTime   =$.trim($("#edit-nextContactTime").val());
        var address           =$.trim($("#edit-address").val());


		//表单验证，同创建
		var regExp1 = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
		var regExp2 = /\d{3}-\d{8}|\d{4}-\d{7}/;
		var regExp3 = /[a-zA-z]+:\/\/[^\s]*/;
		var regExp4 = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
		if (owner==""){
			alert("所有者不能为空");
			return;
		}else if (company==""){
			alert("公司不能为空");
			return;
		}else if (fullname==""){
			alert("姓名不能为空");
			return;
		} else if (!regExp1.test(email)){
			alert("输入的邮箱格式不正确")
			return;
		}else if (!regExp2.test(phone)){
			alert("输入的公司座机格式不正确")
			return;
		}else if (!regExp3.test(website)){
			alert("输入的公司网址格式不正确")
			return;
		}else if (!regExp4.test(mphone)){
			alert("输入的手机号码格式不正确")
			return;
		}

		 $.ajax({
			 url:'workbench/clue/updateClueById.do',
			 data:{
				id             :id             ,
				owner          :owner          ,
				company        :company        ,
				appellation    :appellation    ,
				fullname       :fullname       ,
				job            :job            ,
				email          :email          ,
				phone          :phone          ,
				website        :website        ,
				mphone         :mphone         ,
				state          :state          ,
				source         :source         ,
				description    :description    ,
				contactSummary :contactSummary ,
				nextContactTime:nextContactTime,
				address        :address

			 },
			 type:'post',
			 dataType:'json',
			 success:function (data){
				 if (data.code=="1"){
					 //刷新线索列表，保持当前页数和每页显示条数
					 queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
                     //关闭模态窗口
					 $("#editClueModal").modal("hide");
				 }else {
					 //提示信息
					 alert(data.message);
					 //模态窗口不关闭
					 $("#editClueModal").modal("show");
				 }
			 }
		 })


		})



	});








	//根据条件查询线索列表
	function queryActivityByConditionForPage(pageNo,pageSize){
		//收集参数

		var	fullname = $("#search-fullname").val();
		var	owner    = $("#search-owner").val();
		var	company  = $("#search-company").val();
		var	phone    = $("#search-phone").val();
		var	mphone   = $("#search-mphone").val();
		var	state    = $("#search-state").val();
		var	source   = $("#search-source").val();



		$.ajax({
			url: 'workbench/clue/queryClueByCondition.do',
			data: {
				fullname:fullname,
				owner  :owner  ,
				company:company,
				phone  :phone  ,
				mphone :mphone ,
				state  :state  ,
				source :source ,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType: 'json',
			success:function (data){

				//显示线索列表，遍历retData，拼接所有行数据
				var tBodyHtml = "";
				$.each(data.clueList,function (index,obj){

					tBodyHtml +="<tr>"
					tBodyHtml +="	<td><input type=\"checkbox\" value='"+obj.id+"'/></td>"
					tBodyHtml +="	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/clue/toClueDetail.do?clueId="+obj.id+"';\">"+obj.fullname+obj.appellation+"</a></td>"
					tBodyHtml +="	<td>"+obj.company+"</td>"
					tBodyHtml +="	<td>"+obj.phone+"</td>"
					tBodyHtml +="	<td>"+obj.mphone+"</td>"
					tBodyHtml +="	<td>"+obj.source+"</td>"
					tBodyHtml +="	<td>"+obj.owner+"</td>"
					tBodyHtml +="	<td>"+obj.state+"</td>"
					tBodyHtml +="</tr>"

				})
				//
				$("#tBody").html(tBodyHtml);

				//取消全选
				$("#checkAll").prop("checked",false);
				//计算总页数
				var totalPages=1;
				if (data.totalRows%pageSize==0){
					//能整除则直接赋值
					totalPages=data.totalRows/pageSize;
				}else {
					//不能整除，则取整后+1
					totalPages=parseInt(data.totalRows/pageSize)+1;
				}

				//对容器调用bs_pagination工具函数，显示翻页信息
				$("#bs_paginationDiv").bs_pagination({
					currentPage:pageNo,//当前页号，相当于pageNo
					rowsPerPage:pageSize,//每页显示条数，相当于pageSize
					totalRows:data.totalRows,//总条数
					totalPages:totalPages,//总页数，必填参数
					visiblePageLinks: 5,//最多可以显示的卡片数
					showGoToPage: true,//是否显示“跳转到”部分，默认true--显示,当totalPages大于visiblePageLinks时显示。
					showRowsPerPage: true,//是否显示“每页显示条数部分。默认true--显示
					showRowsInfo: true,//是否显示记录的信息，默认true--显示


					//用户每次切换页号，都自动触发本函数，每次返回切换页号之后的pageNo和pageSize
					//pageObj.currentPage:当前页,pageObj.rowsPerPage:每页显示条数
					onChangePage:function (event,pageObj){
						queryActivityByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage)
					}
				})

			}


		})
	}
	
</script>
</head>
<body>

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createClueFrom">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<option></option>
									<c:forEach items="${usersList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
									<option></option>
									<c:forEach items="${appellationList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--

								  <option>先生</option>
								  <option>夫人</option>
								  <option>女士</option>
								  <option>博士</option>
								  <option>教授</option>--%>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-nextContactTime" readonly>
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
									<option></option>
									<c:forEach items="${clueStateList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								 <%--
								  <option>试图联系</option>
								  <option>将来联系</option>
								  <option>已联系</option>
								  <option>虚假线索</option>
								  <option>丢失线索</option>
								  <option>未联系</option>
								  <option>需要条件</option>--%>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
									<option></option>
									<c:forEach items="${sourceList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								 <%--
								  <option>广告</option>
								  <option>推销电话</option>
								  <option>员工介绍</option>
								  <option>外部介绍</option>
								  <option>在线商场</option>
								  <option>合作伙伴</option>
								  <option>公开媒介</option>
								  <option>销售邮件</option>
								  <option>合作伙伴研讨会</option>
								  <option>内部研讨会</option>
								  <option>交易会</option>
								  <option>web下载</option>
								  <option>web调研</option>
								  <option>聊天</option>--%>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-mphone" class="col-sm-2 control-label">手机</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="create-mphone">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
							</div>
						</div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary"  id="saveCreateClueBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					<input type="hidden" id="hidden-clueId">
						<div class="form-group">
							<label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueOwner">
									<c:forEach items="${usersList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								 <%-- <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-call">
									<option></option>
									<c:forEach items="${appellationList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								 <%--
								  <option selected>先生</option>
								  <option>夫人</option>
								  <option>女士</option>
								  <option>博士</option>
								  <option>教授</option>--%>
								</select>
							</div>
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-surname" value="李四">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
							<label for="edit-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-status">
									<option></option>
									<c:forEach items="${clueStateList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--
								  <option>试图联系</option>
								  <option>将来联系</option>
								  <option selected>已联系</option>
								  <option>虚假线索</option>
								  <option>丢失线索</option>
								  <option>未联系</option>
								  <option>需要条件</option>--%>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<option></option>
									<c:forEach items="${sourceList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								 <%--
								  <option selected>广告</option>
								  <option>推销电话</option>
								  <option>员工介绍</option>
								  <option>外部介绍</option>
								  <option>在线商场</option>
								  <option>合作伙伴</option>
								  <option>公开媒介</option>
								  <option>销售邮件</option>
								  <option>合作伙伴研讨会</option>
								  <option>内部研讨会</option>
								  <option>交易会</option>
								  <option>web下载</option>
								  <option>web调研</option>
								  <option>聊天</option>--%>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">这是一条线索的描述信息</textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control mydate" id="edit-nextContactTime" value="2017-05-01" readonly>
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴区大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateClueBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;" >
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="search-company">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${sourceList}" var="obj">
							  <option value="${obj.value}">${obj.value}</option>
						  </c:forEach>
					  	  <%--
					  	  <option>广告</option>
						  <option>推销电话</option>
						  <option>员工介绍</option>
						  <option>外部介绍</option>
						  <option>在线商场</option>
						  <option>合作伙伴</option>
						  <option>公开媒介</option>
						  <option>销售邮件</option>
						  <option>合作伙伴研讨会</option>
						  <option>内部研讨会</option>
						  <option>交易会</option>
						  <option>web下载</option>
						  <option>web调研</option>
						  <option>聊天</option>--%>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="search-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
						  <option></option>
						  <c:forEach items="${clueStateList}" var="obj">
							  <option value="${obj.value}">${obj.value}</option>
						  </c:forEach>
					  <%--
					  	<option>试图联系</option>
					  	<option>将来联系</option>
					  	<option>已联系</option>
					  	<option>虚假线索</option>
					  	<option>丢失线索</option>
					  	<option>未联系</option>
					  	<option>需要条件</option>--%>
					  </select>
				    </div>
				  </div>

				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createClueBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updateBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/toClueDetail.do?clueId=c0842639f8d1480ab59fb8ccea65fc0c';">李四先生</a></td>
							<td>动力节点</td>
							<td>010-84846003</td>
							<td>12345678901</td>
							<td>广告</td>
							<td>zhangsan</td>
							<td>已联系</td>
						</tr>--%>
                       <%-- <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>



			<div style="height: 50px; position: relative;top: 60px;" >
                  <div id="bs_paginationDiv"></div>
				<%--<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>--%>
				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>