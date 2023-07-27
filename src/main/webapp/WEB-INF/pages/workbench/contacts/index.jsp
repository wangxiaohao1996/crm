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
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>


	<script type="text/javascript">

	$(function(){
		//给查询条件”生日“标签、创建模态窗口”生日“标签、下次联系时间标签、修改模态窗口”生日“标签、下次联系时间标签设置成日历
		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoclose:true,//设置选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true, //设置是否显示“今天”按钮，默认设计false
			clearBtn:true  //设置是否显示“清空”按钮，默认是false

		})

		//页面加载完成，查询联系人列表，显示第一页，每页显示10条记录
		queryActivityByConditionForPage(1,10)
		//点击页面‘查询’按钮，根据条件查询联系人列表，显示第一页，每页显示条数不变
		$("#searchBtn").click(function (){
			queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
		})




		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//获取创建和修改的“客户名称”标签容器，对容器调用bs_typeahead工具函数
		$(".customerName").typeahead({
			source:function (jquery,process){//jquery:容器的value值，process：jquery模糊查询源['xxx','xxxx','xxxx'....]
				$.ajax({
					url: 'workbench/transaction/queryCustomerByName.do',
					data: {
						name:jquery
					},
					type: 'post',
					dataType: 'json',
					success:function (data){
						process(data);
					}
				});
			}
		})


		//给”创建“按钮绑定单击事件
		$("#createContactsBtn").click(function (){
			//创建模态窗口初始化
			$("#createFrom")[0].reset();
			//弹出模态窗口
			$("#createContactsModal").modal("show");
		})


		//给”保存“创建联系人的按钮绑定单击事件
		$("#saveContactsBtn").click(function (){
			//收集参数
			 var owner          =$("#create-contactsOwner").val();
			 var source         =$("#create-clueSource").val();
			 var customerName     =$.trim($("#create-customerName").val());
			 var fullname       =$.trim($("#create-surname").val());
			 var appellation    =$("#create-call").val();
			 var email          =$.trim($("#create-email").val());
			 var birth          =$("#create-birth").val();
			 var mphone         =$.trim($("#create-mphone").val());
			 var job            =$.trim($("#create-job").val());
			 var description    =$.trim($("#create-describe").val());
			 var contactSummary =$.trim($("#create-contactSummary1").val());
			 var nextContactTime=$.trim($("#create-nextContactTime1").val());
			 var address        =$.trim($("#edit-address1").val());

			 var retExg1=/^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
			 var retExg2=/^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
             //表单验证
              if (owner==""){
				  alert("所有者不能为空");
				  return;
			  }else if (fullname==""){
				  alert("姓名不能为空");
				  return;
			  }else if (!retExg1.test(mphone)){
				  alert("输入的手机号码格式不正确");
				  return;
			  }else if (!retExg2.test(email)){
				  alert("输入的邮箱格式不正确");
				  return;
			  }

			  //发送请求
			$.ajax({
				url: 'workbench/contacts/createContacts.do',
				data: {
					 owner          :owner          ,
					 source         :source         ,
					 customerName   :customerName   ,
					 fullname       :fullname       ,
					 appellation    :appellation    ,
					 email          :email          ,
					 birth          :birth          ,
					 mphone         :mphone         ,
					 job            :job            ,
					 description    :description    ,
					 contactSummary :contactSummary ,
					 nextContactTime:nextContactTime,
					 address        :address
				},
				type: 'post',
				dataType: 'json',
				success:function (data){
					if (data.code=="1"){
						//关闭创建模态窗口
						$("#createContactsModal").modal("hide");
						queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
					}else {
						//提示信息
						alert(data.message);
						$("#createContactsModal").modal("show");
					}
				}
			});
		})




		//给全选框绑定单击事件
		$("#checkAll").click(function (){
			//获取全选框选中状态
			var checkState = $(this).prop("checked");
			//将选中状态赋值给tBody下所有的复选框
			$("#tBody input[type='checkbox']").prop("checked",checkState);
		})

        //给tBody下所有的复选框绑定单击事件，全选或者取消全选
		$("#tBody").on("click","input[type='checkbox']",function (){
			//判断tBody下所有的复选框选中的数量是否等于所有的数量
			var checkboxNum = $("#tBody input[type='checkbox']");
			var checkedNum = $("#tBody input[type='checkbox']:checked");
			//给全选框的checked赋值
			$("#checkAll").prop("checked",checkboxNum.size()==checkedNum.size());
		})


		//给“修改”按钮绑定单击事件
		$("#updateContactsBtn").click(function (){
			//每次只能修改一个联系人
			var checkedNum = $("#tBody input[type='checkbox']:checked");
			if (checkedNum.size()==0){
				alert("请选择要修改的联系人");
				return;
			}else if (checkedNum.size()>1){
				alert("每次只能修改一条联系人信息");
				return;
			}
			//收集参数
			var id = $("#tBody input[type='checkbox']:checked").val();
			$.ajax({
				url:'workbench/contacts/searchContactsForUpdateById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data){
					//给修改模态窗口初始化
					  var selected1=$("#edit-contactsOwner option")
					  $.each(selected1,function (index,obj){
						  if ($(this).html()==data.owner){
							  $(this).prop("selected",true);
						  }
					  })

					var selected2=$("#edit-clueSource1 option");
					$.each(selected2,function (index,obj){
						if ($(this).html()==data.source){
							$(this).prop("selected",true);
						}
					})
					  $("#edit-surname").val(data.fullname);

					var selected3 = $("#edit-call option");
					$.each(selected3,function (index,obj){
						if ($(this).html()==data.appellation){
							$(this).prop("selected",true);
						}
					})
					  $("#edit-email          ").val(data.email);
					  $("#edit-birth          ").val(data.birth);
					  $("#edit-mphone         ").val(data.mphone);
					  $("#edit-job            ").val(data.job);
					  $("#edit-describe    ").val(data.description);
					  $("#edit-contactSummary ").val(data.contactSummary );
					  $("#edit-nextContactTime").val(data.nextContactTime);
					  $("#edit-address2        ").val(data.address);
					  $("#edit-customerName").val(data.customerId);
					  $("#contactsId").val(data.id);


					 //弹出修改的模态窗口
					   $("#editContactsModal").modal("show");
				}
			});
		})


		//给“更新”按钮绑定单击事件
		$("#updateBtn").click(function (){
			//收集参数
		var owner          =	$("#edit-contactsOwner").val();
		var source         =	$("#edit-clueSource1").val();
		var fullname       =	$.trim($("#edit-surname").val());
		var appellation    =	$("#edit-call    ").val();
		var email          =	$.trim($("#edit-email          ").val());
		var birth          =	$("#edit-birth          ").val();
		var mphone         =	$.trim($("#edit-mphone         ").val());
		var job            =	$.trim($("#edit-job            ").val());
		var description    =	$.trim($("#edit-describe    ").val());
		var contactSummary =	$.trim($("#edit-contactSummary ").val());
		var nextContactTime=	$.trim($("#edit-nextContactTime").val());
		var address        =	$.trim($("#edit-address2        ").val());
		var customerId   =	    $.trim($("#edit-customerName").val());
		var id             =    $("#contactsId").val();

			//表单验证
			var retExg1=/^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
			var retExg2=/^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
			//表单验证
			if (owner==""){
				alert("所有者不能为空");
				return;
			}else if (fullname==""){
				alert("姓名不能为空");
				return;
			}else if (!retExg1.test(mphone)){
				alert("输入的手机号码格式不正确");
				return;
			}else if (!retExg2.test(email)){
				alert("输入的邮箱格式不正确");
				return;
			}


			//发送请求
			 $.ajax({
				 url:'workbench/contacts/updateContactsById.do',
				 data:{
					  owner          :owner          ,
					  source         :source         ,
					  fullname       :fullname       ,
					  appellation    :appellation    ,
					  email          :email          ,
					  birth          :birth          ,
					  mphone         :mphone         ,
					  job            :job            ,
					  description       :description       ,
					  contactSummary :contactSummary ,
					  nextContactTime:nextContactTime,
					  address        :address        ,
					  customerId     :customerId   ,
					  id             :id
				 },
				 type:'post',
				 dataType:'json',
				 success:function (data){
					 if (data.code=="1"){
						 //更新成功，关闭模态窗口，
						 $("#editContactsModal").modal("hide");
						 //更新联系人列表，保持显示页数和每页显示条数不变
						 queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"))
					 }else {
						 alert(data.message);
						 $("#editContactsModal").modal("show");
					 }
				 }
			 });
		})


		//给“删除”按钮绑定单击事件
		$("#deleteContactsBtn").click(function (){
			//至少选一条联系人
			var checkedNum = $("#tBody input[type='checkbox']:checked");
			if (checkedNum.size()==0){
				alert("至少要选择一条联系人");
				return;
			}
			//弹出删除确认框
			if (window.confirm("确定删除吗？")){
				//收集参数
				var ids="";
				$.each(checkedNum,function (index,obj){
					ids+="id="+this.value+"&"
				})
				//去掉最后一个&
				ids=ids.substr(0,ids.length-1);

				//发送异步请求
				$.ajax({
					url:'workbench/contacts/deleteContactsByIds.do',
					data:ids,
					type:'post',
					dataType:'json',
					success:function (data){
						if (data.code=="1"){
							//刷新联系人列表，保持显示页数和每页显示条数不变
							queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
						}else {
							alert(data.message);
						}
					}
				});
			}
		})




	});






	//根据条件查询联系人列表
	function queryActivityByConditionForPage(pageNo,pageSize){
		//收集参数
		var owner      =$.trim($("#search-owner      ").val());
		var fullname   =$.trim($("#search-fullname   ").val());
		var customerName=$.trim($("#search-appellation").val());
		var source     =$.trim($("#search-source     ").val());
		var birth      =$.trim($("#search-birth      ").val());

		$.ajax({
			url: 'workbench/contacts/searchContactsByCondition.do',
			data: {
				owner      :owner      ,
				fullname   :fullname   ,
				customerName:customerName,
				source     :source     ,
				birth      :birth,
				pageNo:pageNo,
				pageSize,pageSize
			},
			type:'post',
			dataType: 'json',
			success:function (data){

				//显示市场活动列表，遍历retData，拼接所有行数据
				var tBodyHtml = "";
				$.each(data.contactsList,function (index,obj){
					tBodyHtml+="<tr>";
					tBodyHtml+="	<td><input type=\"checkbox\" value='"+obj.id+"'/></td>";
					tBodyHtml+="	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/toContactsDetail.do?contactsId="+obj.id+"';\">"+obj.fullname+"</a></td>";
					tBodyHtml+="	<td>"+obj.customerId+"</td>";
					tBodyHtml+="	<td>"+obj.owner+"</td>";
					tBodyHtml+="	<td>"+obj.source+"</td>";
					tBodyHtml+="	<td>"+obj.birth+"</td>";
					tBodyHtml+="</tr>";
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

	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createFrom">
					
						<div class="form-group">
							<label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-contactsOwner">
									<c:forEach items="${userList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-clueSource">
								  <option></option>
									<c:forEach items="${sourceList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--<option>广告</option>
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
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-surname">
							</div>
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-call">
								  <option></option>
									<c:forEach items="${appellationList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--<option>先生</option>
								  <option>夫人</option>
								  <option>女士</option>
								  <option>博士</option>
								  <option>教授</option>--%>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-birth" readonly>
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control customerName" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary1"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime1" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control mydate" id="create-nextContactTime1" readonly>
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address1"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveContactsBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
	    <input type="hidden" id="contactsId">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-contactsOwner">
									<c:forEach items="${userList}" var="u">
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								 <%-- <option selected>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-clueSource1" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueSource1">
								  <option></option>
									<c:forEach items="${sourceList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								 <%-- <option selected>广告</option>
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
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-surname" value="李四">
							</div>
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-call">
								  <option></option>
									<c:forEach items="${appellationList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--<option selected>先生</option>
								  <option>夫人</option>
								  <option>女士</option>
								  <option>博士</option>
								  <option>教授</option>--%>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-birth" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control customerName" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" value="动力节点">
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
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control mydate" id="edit-nextContactTime" readonly>
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address2" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address2">北京大兴区大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-appellation">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${sourceList}" var="obj">
							  <option value="${obj.value}">${obj.value}</option>
						  </c:forEach>
						  <%--<option>广告</option>
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
				    <div class="input-group">
				      <div class="input-group-addon">生日</div>
				      <input class="form-control mydate" type="text" id="search-birth">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createContactsBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updateContactsBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"  id="deleteContactsBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四</a></td>
							<td>动力节点</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>2000-10-10</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四</a></td>
                            <td>动力节点</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>2000-10-10</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 10px;">
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
					</nav>
				</div>--%>
			</div>
			
		</div>
		
	</div>
</body>
</html>