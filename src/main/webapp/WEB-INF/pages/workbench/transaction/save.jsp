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
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript" >
	$(function (){

		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoclose:true,//设置选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true, //设置是否显示“今天”按钮，默认设计false
			clearBtn:true  //设置是否显示“清空”按钮，默认是false

		})




		$("#create-transactionStage").change(function (){
			//收集参数
			//$(this).find("option:selected").text()
			var stage = $("#create-transactionStage option:selected").html();
			if (stage==""){
				$("#create-possibility").val("");
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/transaction/tranPossibility.do',
				data:{
					stage:stage
				},
				type:'post',
				dataType:'json',
				success:function (data){
					$("#create-possibility").val(data);
				}
			});
		})


		//获取“客户名称”标签容器，对容器调用bs_typeahead工具函数
		$("#create-accountName").typeahead({
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

		//给”保存“按钮添加单击事件
		$("#saveCreateTranBtn").click(function (){
			//收集参数
		var	owner            =$("#create-transactionOwner").val();
		var	money            =$.trim($("#create-amountOfMoney").val());
		var	name             =$.trim($("#create-transactionName").val());
		var	expectedDate    =$("#create-expectedClosingDate").val();
		var	accountName      =$.trim($("#create-accountName").val());
		var	stage            =$("#create-transactionStage").val();
		var	type             =$("#create-transactionType").val();
		var	source           =$("#create-clueSource").val();
		var	activityId      =$("#create-activitySrc").attr("activityId");
		var	contactsId      =$("#create-contactsName").attr("contactsId");
		var	description      =$.trim($("#create-describe").val());
		var	contactSummary  =$.trim($("#create-contactSummary").val());
		var	nextContactTime =$("#create-nextContactTime") .val();
		var possibility     =$("#create-possibility").val();

		//表单验证
			var retExg=/^(([1-9]\d*)|0)$/;
			if (owner==''){
				alert("所有者不能为空");
				return;
			}else if (!retExg.test(money)){
				alert("金额只能是非负整数")
				return;;
			}else if (expectedDate==''){
				alert("期望日期不能为空");
				return;
			}else if (name==''){
				alert("名称不能为空");
				return;
			}else if (accountName==''){
				alert("客户名称不能为空");
				return;
			}else if (stage==""){
				alert("阶段不能为空");
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/transaction/saveCreateTran.do',
				data:{
					 owner          :owner          ,
					 money          :money          ,
					 name           :name           ,
					 expectedDate   :expectedDate   ,
					accountName     :accountName     ,
					 stage          :stage          ,
					 type           :type           ,
					 source         :source         ,
					 activityId     :activityId     ,
					 contactsId     :contactsId     ,
					 description    :description    ,
					 contactSummary :contactSummary ,
					nextContactTime :nextContactTime,
					 possibility    :possibility
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						if ('${contactsId}'!=''){
							//跳转到联系人明细页面
							window.location.href='workbench/contacts/toContactsDetail.do?contactsId=${contactsId}';
							return;
						}else if ('${customerId}'!=''){
							//跳转到客户明细页面
							window.location.href='workbench/customer/toCustomerDetail.do?customerId=${customerId}';
							return;
						}
						//保存成功之后，跳转到交易主页面
						window.location.href='workbench/transaction/toIndex.do'
					}else{
						//保存失败，提示信息，页面不跳转
						alert(data.message);
					}
				}

			});
		})


		//给“市场活动源a标签”绑定单击事件
		$("#searchActivityA").click(function (){
			//市场活动源模态窗口初始化
			$("#searchActivityByName").val("");
			$("#activityTbody").html("");
			//弹出模态窗口
			$("#findMarketActivity").modal("show");
		})

		//给根据名称模糊查询市场活动标签绑定键盘弹起事件
		$("#searchActivityByName").keyup(function (){
			//收集参数
			var name = $.trim(this.value);

			$.ajax({
				url:'workbench/transaction/queryActivityByName.do',
				data:{
					name:name
				},
				type:'post',
				dataType:'json',
				success:function (data){
					var str="";
					$.each(data,function (index,obj){
						str+="<tr>";
						str+="	<td><input type=\"radio\" name=\"activity\" value='"+obj.id+"' activityName='"+obj.name+"'/></td>";
						str+="	<td>"+obj.name+"</td>";
						str+="	<td>"+obj.startDate+"</td>";
						str+="	<td>"+obj.endDate+"</td>";
						str+="	<td>"+obj.owner+"</td>";
						str+="</tr>";
					})
					$("#activityTbody").html(str);

				}
			})
		})


		//给查找市场活动模态窗口的单选框标签绑定单击事件
		$("#activityTbody").on("click","input[type='radio']",function (){
			//关闭模态窗口
			$("#findMarketActivity").modal("hide");
			//给市场活动源标签赋值
			$("#create-activitySrc").val($(this).attr("activityName"));
			$("#create-activitySrc").attr("activityId",this.value);

		})

		//给联系人名称a标签绑定单击事件
		$("#searchContactsA").click(function (){
			//查找联系人模态窗口初始化
			$("#searchContactsText").val("");
			$("#contactsTbody").html("");
			//查找联系人模态窗口弹起
			$("#findContacts").modal("show");
		})


		//给查找联系人模态窗口的搜索标签绑定键盘弹起事件
		$("#searchContactsText").keyup(function (){
			//收集参数
			var fullname = $.trim($(this).val());

			$.ajax({
				url:'workbench/transaction/queryContactsByFullname.do',
				data:{
					fullname:fullname
				},
				type:'post',
				dataType:'json',
				success:function (data){
					var str="";
					$.each(data,function (index,obj){
						str+="<tr>";
						str+="	<td><input type=\"radio\" name=\"activity\" value='"+obj.fullname+"' contactsId='"+obj.id+"'/></td>";
						str+="	<td>"+obj.fullname+"</td>";
						str+="	<td>"+obj.email+"</td>";
						str+="	<td>"+obj.mphone+"</td>";
						str+="</tr>";
					})
					$("#contactsTbody").html(str);
			}
			})
		})

		//给查找联系人模态窗口的单选框绑定单击事件
		$("#contactsTbody").on("click","input[type='radio']",function (){
			//关闭模态窗口
			$("#findContacts").modal("hide");
			//将联系人id赋值给create-contactsName标签的contactsId属性
			$("#create-contactsName").attr("contactsId",$(this).attr("contactsId"));
			//将联系人fullname赋值给create-contactsName标签的value属性
			$("#create-contactsName").val(this.value);
		})






	})
</script>
</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchActivityByName" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="activityTbody" >
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchContactsText" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsTbody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveCreateTranBtn">保存</button>
			<button type="button" class="btn btn-default" onclick="window.history.back()">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner">
					<c:forEach items="${userList}" var="obj">
						<option value="${obj.id}">${obj.name}</option>
					</c:forEach>
					<%-- <option>zhangsan</option>
                     <option>lisi</option>
                     <option>wangwu</option>--%>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label ">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control mydate" id="create-expectedClosingDate" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-accountName" placeholder="${customerName!=""&&customerName!=null?customerName:'支持自动补全，输入客户不存在则新建'}">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage">
			  	<option></option>
				  <c:forEach items="${stageList}" var="obj">
					  <option value="${obj.id}">${obj.value}</option>
				  </c:forEach>
			  	<%--<option>资质审查</option>
			  	<option>需求分析</option>
			  	<option>价值建议</option>
			  	<option>确定决策者</option>
			  	<option>提案/报价</option>
			  	<option>谈判/复审</option>
			  	<option>成交</option>
			  	<option>丢失的线索</option>
			  	<option>因竞争丢失关闭</option>--%>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType">
				  <option></option>
					<c:forEach items="${tranTypeList}" var="obj">
						<option value="${obj.id}">${obj.value}</option>
					</c:forEach>
				  <%--<option>已有业务</option>
				  <option>新业务</option>--%>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility">
			</div>
		</div>
		
		<div class="form-group">
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
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="searchActivityA"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc" activityId="" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="searchContactsA"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName" contactsId="${contactsId!=null?contactsId:''}" value="${contactsFullname!=null?contactsFullname:''}" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label ">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control mydate" id="create-nextContactTime" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>