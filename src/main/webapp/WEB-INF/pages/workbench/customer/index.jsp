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

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){

		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoclose:true,//设置选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true, //设置是否显示“今天”按钮，默认设计false
			clearBtn:true  //设置是否显示“清空”按钮，默认是false

		})


		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//客户主页面加载完毕，查询客户列表，显示第一页，每页显示10条
		queryActivityByConditionForPage(1,10);

		//给"查询"按钮绑定单击事件,点击查询，显示客户列表第一页，每页显示条数不变
		  $("#searchBtn").click(function (){
			  queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination('getOption','rowsPerPage'));

		  })

		      //给创建按钮绑定单击事件
		      $("#createCustomerBtn").click(function (){
				  //给创建客户的模态窗口初始化
				  $("#createFrom")[0].reset();
				  //弹出创建客户的模态窗口
				  $("#createCustomerModal").modal("show");
			  })

		//给“保存”按钮绑定单击事件
		$("#saveCreateCustomerBtn").click(function (){
			//收集参数
			var owner            =$("#create-customerOwner            ").val();
			var name             =$.trim($("#create-customerName             ").val());
			var website          =$.trim($("#create-website          ").val());
			var phone            =$.trim($("#create-phone            ").val());
			var contactSummary  =$.trim($("#create-contactSummary  ").val());
			var nextContactTime=$.trim($("#create-nextContactTime").val());
			var description      =$.trim($("#create-describe      ").val());
			var address          =$.trim($("#create-address1          ").val());

			var retExg1=/[a-zA-z]+:\/\/[^\s]*/;
			var retExg2=/\d{3}-\d{8}|\d{4}-\d{7}/;
			//表单验证
			if (name==""){
				alert("输入的名称不能为空");
				return;
			}else if (!retExg1.test(website)){
				alert("输入的网站格式不正确");
				return;
			}else if (!retExg2.test(phone)){
				alert("输入的公司座机格式不正确")
				return;
			}
			//发送请求
			$.ajax({
				url: 'workbench/customer/saveCreateCustomer.do',
				data: {
					owner            :owner            ,
					name             :name             ,
					website          :website          ,
					phone            :phone            ,
					contactSummary  :contactSummary  ,
					nextContactTime:nextContactTime,
					description      :description      ,
					address          :address
				},
				type: 'post',
				dataType: 'json',
				success:function (data){
					if (data.code=="1"){
						//关闭创建的模态窗口
						$("#createCustomerModal").modal("hide");
						// 创建成功之后,关闭模态窗口,刷新客户列，显示第一页数据，保持每页显示条数不变
						queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination('getOption','rowsPerPage'));
					}else {
						//提示信息
						alert(data.message);
						$("#createCustomerModal").modal("show");
					}
				}
			});
		})

		//给”修改“按钮绑定单击事件
		$("#editCustomerBtn").click(function (){
			//每次能且只能修改一条客户信息
			var checkeds = $("#tBody input[type='checkbox']:checked");
			if (checkeds.size()==0){
				alert("请选择您要修改的客户信息")
				return;
			}else if (checkeds.size()>1){
				alert("每次只能修改一条客户信息")
				return;
			}else {
				//收集参数
				var id=checkeds.val();

				$.ajax({
					url:'workbench/customer/queryCustomerById.do',
					data:{
						id:id
					},
					type:'post',
					dataType:'json',
					success:function (data){
						 $("#edit-customerOwner option").prop("selected",data.owner);
						//给修改客户的模态窗口初始化
						//给所有者设施默认值
						var selected1=$("#edit-customerOwner option")
						$.each(selected1,function (index,obj){
							if ($(this).html()==data.owner){
								$(this).prop("selected",true);
							}
						})
						  $("#edit-customerName").val(data.name);
						  $("#edit-website").val(data.website);
						  $("#edit-phone").val(data.phone);
						  $("#edit-describe").val(data.description);
						  $("#create-contactSummary1").val(data.contactSummary);
						  $("#create-nextContactTime2").val(data.nextContactTime);
						  $("#create-address").val(data.address);
						  $("#editCustomerId").val(data.id);

						  //弹出修改客户的模态窗口
						$("#editCustomerModal").modal("show");
					}
				});

			}
		})


		//给“更新”按钮绑定单击事件
          $("#updateCustomerBtn").click(function (){
			  //收集参数
			  var owner          =$.trim($("#edit-customerOwner").val());
			  var name           =$.trim($("#edit-customerName").val());
			  var website        =$.trim($("#edit-website").val());
			  var phone          =$.trim($("#edit-phone").val());
			  var description    =$.trim($("#edit-describe").val());
			  var contactSummary =$.trim($("#create-contactSummary1").val());
			  var nextContactTime   =$("#create-nextContactTime2").val();
			  var address        =$.trim($("#create-address").val());
			  var id             =$("#editCustomerId").val();

			  //表单验证
			  var retExg1=/[a-zA-z]+:\/\/[^\s]*/;
			  var retExg2=/\d{3}-\d{8}|\d{4}-\d{7}/;
			  //表单验证
			  if (owner==""){
				  alert("所有者不能为空");
				  return;
			  }else if (name==""){
				  alert("输入的名称不能为空");
				  return;
			  }else if (!retExg1.test(website)){
				  alert("输入的网站格式不正确");
				  return;
			  }else if (!retExg2.test(phone)){
				  alert("输入的公司座机格式不正确")
				  return;
			  }

			  $.ajax({
				  url:'workbench/customer/saveUpdateCustomer.do',
				  data:{
					   owner          :owner          ,
					   name           :name           ,
					   website        :website        ,
					   phone          :phone          ,
					   description    :description    ,
					   contactSummary :contactSummary ,
					   nextContactTime:nextContactTime,
					   address        :address        ,
					   id             :id
				  },
				  type:'post',
				  dataType:'json',
				  success:function (data){
					  if (data.code=="1"){
						  //修改成功之后,关闭模态窗口,刷新市场活动列表,保持页号和每页显示条数都不变
						  $("#editCustomerModal").modal("hide");
						  queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
					  }else {
						  //修改失败,提示信息,模态窗口不关闭,列表也不刷新
						  alert(data.message);
						  $("#editCustomerModal").modal("show");
					  }

				  }
			  });

		  })



		 //复选框全选
		 $("#checkAll").click(function (){
			 var checked=this.checked;
			 $("#tBody input[type='checkbox']").prop("checked",checked)
		 })
		//给tbody的所有复选框绑定单击事件，取消全选
		$("#tBody").on("click","input[type='checkbox']",function (){
			//获取所有的复选框和所有选中的复选框
			var checkboxs = $("#tBody input[type='checkbox']");
			var checkeds = $("#tBody input[type='checkbox']:checked");
			//判断是否相等，相等全选，不相等，取消全选
			$("#checkAll").prop("checked",checkboxs.size()==checkeds.size());
		})



		//给“删除”按钮绑定单击事件
		$("#deleteCustomerBtn").click(function (){
			//每次至少选中一条复选框
			var checkeds = $("#tBody input[type='checkbox']:checked");
			if (checkeds.size()==0){
				alert("至少选择一条客户信息");
				return;
			}
			//点击"删除"按钮,弹出确认窗口;
			if (window.confirm("确定要删除吗？")){
				//收集参数
				var ids="";
				$.each(checkeds,function (index,obj){
					ids+="id="+this.value+"&";
				})
				//去除最后一个&
				ids=ids.substr(0,ids.length-1);
				$.ajax({
					url:'workbench/customer/deleteCustomerByIds.do',
					data:ids,
					type:'post',
					dataType:'json',
					success:function (data){
						if (data.code=="1"){
							//删除成功之后,刷新市场活动列表,显示第一页数据,保持每页显示条数不变
							queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
						}else {
							//删除失败,提示信息,列表不刷新
							alert(data.message);
						}
					}
				});
			}

		})



	});






	//根据条件查询客户列表
	function queryActivityByConditionForPage(pageNo,pageSize){
		//收集参数
		 var owner  =$.trim($("#search-owner").val());
		 var name   =$.trim($("#search-name").val());
		 var website=$.trim($("#search-website").val());
		 var phone  =$.trim($("#search-phone").val());

		$.ajax({
			url: 'workbench/customer/queryCustomerByCondition.do',
			data: {
				owner  :owner  ,
				name   :name   ,
				website:website,
				phone  :phone,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType: 'json',
			success:function (data){

				//显示市场活动列表，遍历retData，拼接所有行数据
				var tBodyHtml = "";
				$.each(data.customerList,function (index,obj){
				tBodyHtml+="	<tr>";
				tBodyHtml+="		<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
				tBodyHtml+="		<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/toCustomerDetail.do?customerId="+obj.id+"';\">"+obj.name+"</a></td>";
				tBodyHtml+="		<td>"+obj.owner+"</td>";
				tBodyHtml+="		<td>"+obj.phone+"</td>";
				tBodyHtml+="		<td>"+obj.website+"</td>";
				tBodyHtml+="	</tr>";
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

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createFrom">
					
						<div class="form-group">
							<label for="create-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-customerOwner">
									<c:forEach items="${userList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="create-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
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
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control mydate" id="create-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address1"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateCustomerBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					<input type="hidden" id="editCustomerId">
						<div class="form-group">
							<label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-customerOwner">
									<c:forEach items="${userList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								 <%-- <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
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
                                <label for="create-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control mydate" id="create-nextContactTime2" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address">北京大兴大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateCustomerBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
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
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="search-website">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createCustomerBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editCustomerBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"id="deleteCustomerBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>
							<td>zhangsan</td>
							<td>010-84846003</td>
							<td>http://www.bjpowernode.com</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>
                            <td>zhangsan</td>
                            <td>010-84846003</td>
                            <td>http://www.bjpowernode.com</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
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