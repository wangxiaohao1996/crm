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
		//页面加载完成，刷新交易列表，显示第一页，每页显示条数10
		queryActivityByConditionForPage(1,10);
		//点击‘查询’按钮，根据条件模糊查询交易，显示第一页，每页显示条数维持不变
		$("#searchBtn").click(function (){
			queryActivityByConditionForPage(1,$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));
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
			var checkeds = $("#tBody input[type='checkbox']:checked");
			if (checkeds.size()==0){
				alert("请选择您要删除的交易");
				return;
			}
			if (window.confirm("确定要删除吗？")){
				var ids="";
				//收集参数
				$.each(checkeds,function (index,obj){
					ids+="id="+this.value+"&"
				})
				//去掉最后一个多余的&
				ids=ids.substr(0,ids.length-1);
				$.ajax({
					url: 'workbench/transaction/deleteTranByIds.do',
					data: ids,
					type:'post',
					dataType: 'json',
					success:function (data){
						if (data.code=="1"){
							//删除成功，刷新交易列表，保持当前页和每页显示条数不变
							queryActivityByConditionForPage($("#bs_paginationDiv").bs_pagination("getOption","currentPage"),$("#bs_paginationDiv").bs_pagination("getOption","rowsPerPage"));

						}else {
							alert(data.message);
						}
					}
				})
			}
		})


		//给”修改“按钮绑定单击事件
		$("#upateTranBtn").click(function (){
			var checkeds = $("#tBody input[type='checkbox']:checked");
			if (checkeds.size()==0){
				alert("请选择要修改的交易");
				return;
			}else if (checkeds.size()>1){
				alert("每次只能修改一条交易")
				return;
			}
			var id=checkeds.val();
			window.location.href='workbench/transaction/queryTranById.do?id='+id;

		})




	});


	//根据条件查询市场活动列表
	function queryActivityByConditionForPage(pageNo,pageSize){
		//收集参数
		 var owner       =$("#search-owner       ").val();
		 var name        =$("#search-name        ").val();
		var  customerName=$("#search-customerName").val();
		 var stage       =$("#search-stage       ").val();
		 var type        =$("#search-type        ").val();
		 var source      =$("#search-source      ").val();
		var  contactsName=$("#search-contactsName").val();



		$.ajax({
			url: 'workbench/transaction/queryTranByCondition.do',
			data: {
				owner       :owner       ,
				name        :name        ,
				customerName:customerName,
				stage       :stage       ,
				type        :type        ,
				source      :source      ,
				contactsName:contactsName,
				pageNo      :pageNo      ,
				pageSize    :pageSize
			},
			type:'post',
			dataType: 'json',
			success:function (data){
				//显示交易列表，遍历retData，拼接所有行数据
				var tBodyHtml = "";
				$.each(data.tranList,function (index,obj){


					tBodyHtml+="<tr>";
					tBodyHtml+="	<td><input type=\"checkbox\" value='"+obj.id+"'/></td>";
					tBodyHtml+="	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/transaction/toTranDetail.do?tranId="+obj.id+"';\">"+obj.customerId+"-"+obj.name+"</a></td>";
					tBodyHtml+="	<td>"+obj.customerId+"</td>";
					tBodyHtml+="	<td>"+obj.stage+"</td>";
					tBodyHtml+="	<td>"+obj.type+"</td>";
					tBodyHtml+="	<td>"+obj.owner+"</td>";
					tBodyHtml+="	<td>"+obj.source+"</td>";
					tBodyHtml+="	<td>"+obj.contactsId+"</td>";
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

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
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
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
						  <c:forEach items="${stageList}" var="obj">
							  <option value="${obj.value}">${obj.value}</option>
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
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						  <c:forEach items="${tranTypeList}" var="obj">
							  <option value="${obj.value}">${obj.value}</option>
						  </c:forEach>
					  <%--	<option>已有业务</option>
					  	<option>新业务</option>--%>
					  </select>
				    </div>
				  </div>
				  
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
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsName">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/toSave.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="upateTranBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/toClueDetail.do?tranId=ef45ecadbb664bda8a03539670bec49a';">动力节点-交易01</a></td>
							<td>动力节点</td>
							<td>谈判/复审</td>
							<td>新业务</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>李四</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点-交易01</a></td>
                            <td>动力节点</td>
                            <td>谈判/复审</td>
                            <td>新业务</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>李四</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;" >
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