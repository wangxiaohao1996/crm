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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">

	$(function(){
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});




		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoclose:true,//设置选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true, //设置是否显示“今天”按钮，默认设计false
			clearBtn:true  //设置是否显示“清空”按钮，默认是false

		})


		//给搜索市场活动超链接绑定单击事件
		$("#queryActivityA").click(function (){
			//给搜索市场活动的模态窗口初始化
			//模糊查询框初始化
			$("#queryActivityByNameClueId").val("");
			//市场活动记录初始化
			$("#activityTbody").html("");
			//弹出搜索市场活动的模态窗口
			$("#searchActivityModal").modal("show");
		})


		//给模糊查询的input标签绑定键盘弹起事件
		$("#queryActivityByNameClueId").keyup(function (){
			//收集参数
			var clueId = '${clue.id}';
			var name = $.trim($(this).val());
			//发送异步请求
			$.ajax({
				url:'workbench/clue/queryActivityByNameClueId.do',
				data:{
					clueId:clueId,
					name:name
				},
				type:'post',
				dataType:'json',
				success:function (data){
					var Str="";
					$.each(data,function (index,obj){
						Str+="<tr>"
						Str+="<td><input type=\"radio\" name=\"activity\" value=\""+obj.id+"\" activityName=\""+obj.name+"\"/></td>"
						Str+="<td>"+obj.name+"</td>"
						Str+="<td>"+obj.startDate+"</td>"
						Str+="<td>"+obj.endDate+"</td>"
						Str+="<td>"+obj.owner+"</td>"
						Str+="</tr>"
					})
					//给tbody的html赋值，覆盖显示查询出来的市场活动记录
					$("#activityTbody").html(Str);
				}
			});
		})


		//给市场活动所有的单选框绑定单击事件
		$("#activityTbody").on("click","input[type='radio']",function (){
			//把被选中的单选框的value和activityName赋值给id="activity"的input标签
			//获取被选中的单选框的value
			var activityId=this.value;
			var activityName=$(this).attr("activityName");
			$("#activity").val(activityName);
			$("#acticityId").val(activityId);
			//关闭搜索市场活动的模态窗口
			$("#searchActivityModal").modal("hide")
		});


		//给“转换”按钮绑定点击事件
		$("#convertId").click(function (){
			//收集参数
			var clueId='${clue.id}';
			var createTransaction=$("#isCreateTransaction").prop("checked");
			var money=$.trim($("#amountOfMoney").val());
			var name =$.trim($("#tradeName").val());
			var expectedDate=$("#expectedClosingDate").val();
			var stage=$("#stage option:selected").val();
			var acticityId=$("#acticityId").val();
			name=name.substr('${clue.company}'.length+1);
			if (createTransaction){
				//表单验证
				var retExg1=/^(([1-9]\d*)|0)$/;
				if (!retExg1.test(money)){
					alert("金额为非负整数");
					return;
				}
				if (name==''){
					alert("交易名称不能为空");
					return;
				}
				if (stage==''){
					alert("阶段不能为空");
					return;
				}
			}
			//发送异步请求
			$.ajax({
				url: 'workbench/clue/ClueConvert.do',
				data: {
					clueId:clueId,
					createTransaction:createTransaction,
					money:money,
					name:name,
					expectedDate:expectedDate,
					stage:stage,
					acticityId:acticityId
				},
				type: 'post',
				dataType: 'json',
				success:function (data){
					//转换成功之后,跳转到线索主页面
					if (data.code=="1"){
						window.location.href='workbench/clue/toClueIndex.do';
					}else {
						//转换失败,提示信息,页面不跳转
						alert(data.message);
					}
				}
			});
		})
	});
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" id="queryActivityByNameClueId" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activityTbody">
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

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${clue.fullname}${clue.appellation}-${clue.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${clue.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${clue.fullname}${clue.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form>
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" value="${clue.company}-">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control mydate" id="expectedClosingDate" readonly>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control">
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
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="queryActivityA" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
			  <input type="hidden" id="acticityId"/>
		    <input type="text" class="form-control"  id="activity" placeholder="点击上面搜索" readonly>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${clue.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" id="convertId" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消" onclick="window.history.back()">
	</div>
</body>
</html>