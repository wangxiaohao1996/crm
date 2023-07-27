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

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		/*$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

*/
		$("#fatherRemarkDiv").on("mouseover",".remarkDiv",function (){
			$(this).children("div").children("div").show();
		})
		$("#fatherRemarkDiv").on("mouseout",".remarkDiv",function (){
			$(this).children("div").children("div").hide();
		})
		$("#fatherRemarkDiv").on("mouseover",".myHref",function (){
			$(this).children("span").css("color","red");
		})
		$("#fatherRemarkDiv").on("mouseout",".myHref",function (){
			$(this).children("span").css("color","#E6E6E6");
		})



		//给”关联市场活动“超链接绑定单击事件
		$("#bundClueActivityA").click(function (){
			//在关联市场活动的模态窗口弹出之前初始化
			//重置搜索框
			$("#queryActivityByNameClueId").val("");
			//重置tbody
			$("#ActivityTbody").html("");
			//弹出关联市场活动的模态窗口
			$("#bundModal").modal("show");
		})

		//给市场活动搜索框绑定键盘弹起事件
		$("#queryActivityByNameClueId").keyup(function (){
			//收集参数
			var name = $.trim($(this).val());
			var clueId='${clue.id}';
			//发送异步请求
			$.ajax({
				url:'workbench/activity/queryActivityForClueDetailByNameClueId.do',
				data:{
					name:name,
					clueId:clueId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					var tBodyHtml="";
					$.each(data,function (index,obj){
						tBodyHtml+="<tr>"
						tBodyHtml+="<td><input value=\""+obj.id+"\" type=\"checkbox\"/></td>"
						tBodyHtml+="<td>"+obj.name+"</td>"
						tBodyHtml+="<td>"+obj.startDate+"</td>"
						tBodyHtml+="<td>"+obj.endDate+"</td>"
						tBodyHtml+="<td>"+obj.owner+"</td>"
						tBodyHtml+="</tr>"
					})
					//覆盖显示查询出来的市场活动
					$("#ActivityTbody").html(tBodyHtml);
				}
			});
		})

          //给”关联“按钮绑定单击事件
		$("#bundClueActivityBtn").click(function (){
			//收集参数
			var clueId='${clue.id}';
			//获取所有选中的复选框的value
			var checkeds = $("#ActivityTbody input[type='checkbox']:checked");
			if (checkeds.size()==0){
				alert("请选择要关联的市场活动");
				return;
			}
			var Str="";
			$.each(checkeds,function (index,obj){
				Str+="activityId="+this.value+"&"
			});
			Str +="clueId="+clueId;
			//发送异步请求
			$.ajax({
				url: 'workbench/clue/saveCreateClueActivityRelationByClueIdActivityId.do',
				data: Str,
				type: 'post',
				dataType: 'json',
				success:function (data){
					if (data.code=="1"){
						//关联成功之后,关闭模态窗口
						$("#bundModal").modal("hide");
						//刷新已经关联过的市场活动列表,关联几条，追加几条
						htmlStr="";
						$.each(data.retData,function (index,obj){
							htmlStr+="<tr id=\"tr_"+obj.id+"\">"
							htmlStr+="	<td>"+obj.name+"</td>"
							htmlStr+="	<td>"+obj.startDate+"</td>"
							htmlStr+="	<td>"+obj.endDate+"</td>"
							htmlStr+="	<td>"+obj.owner+"</td>"
							htmlStr+="	<td><a href=\"javascript:void(0);\"  style=\"text-decoration: none;\" activityId=\""+obj.id+"\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>"
							htmlStr+="</tr>"
						});
						$("#clueActivityTbody").append(htmlStr);
					}else {
						//关联失败,提示信息,模态窗口不关闭,已经关联过的市场活动列表也不刷新
						alert(data.message);
						$("#bundModal").modal("show");
					}
				}
			})
		})

		//给所有的市场活动“解除关联”按钮绑定单击事件
		$("#clueActivityTbody").on("click","a",function (){
			//获取超链接的activityId属性值
			var activityId = $(this).attr("activityId");
			//获取线索id
			var clueId = '${clue.id}';
			//发送异步请求
			if (window.confirm("确定要解除吗？")){
				$.ajax({
					url:'workbench/clue/deleteClueActivityRelationByClueIdActivityId.do',
					data:{
						activityId:activityId,
						clueId:clueId
					},
					type:'post',
					dataType:'json',
					success:function (data){
						if (data.code=="1"){
							//解除成功之后,刷新已经关联的市场活动列表，删哪条，remove哪条
							$("#tr_"+activityId).remove();

						}else {
							//解除失败,提示信息,列表也不刷新
							alert(data.message);
						}
					}
				});
			}
		})


		//给“转换”按钮添加单击事件
		$("#convertClueBtn").click(function (){
			window.location.href='workbench/clue/toConvert.do?id=${clue.id}';
		})


		//给线索备注的“保存”按钮添加单击事件
		$("#saveRemarkBtn").click(function (){
			//收集参数
			var noteContent = $.trim($("#remark").val());
			var clueId = '${clue.id}';
			if (noteContent==""){
				alert("请填写备注信息");
				return;
			}
			//发送异步请求
			$.ajax({
				url:'workbench/clue/saveClueRemark.do',
				data:{
					noteContent:noteContent,
					clueId:clueId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					//添加成功，页面新增一条记录
					if (data.code=="1"){
						var Str="";
						Str+="<div class=\"remarkDiv\" style=\"height: 60px;\" id=\"div_"+data.retData.id+"\">";
						Str+="	<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						Str+="		<div style=\"position: relative; top: -40px; left: 40px;\" >";
						Str+="			<h5>"+data.retData.noteContent+"</h5>";
						Str+="			<font color=\"gray\">线索</font> <font color=\"gray\">-</font> <b>${clue.fullname}${clue.appellation}-${clue.company}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.sessionUser.name}创建</small>";
						Str+="			<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						Str+="				<a class=\"myHref\" href=\"javascript:void(0);\" name=\"editA\" remarkId=\""+data.retData.id+"\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						Str+="				&nbsp;&nbsp;&nbsp;&nbsp;";
						Str+="				<a class=\"myHref\" href=\"javascript:void(0);\" name=\"deleteA\" remarkId=\""+data.retData.id+"\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						Str+="			</div>";
						Str+="		</div>";
						Str+="</div>";
						$("#remarkDiv").before(Str);
						//重置输入框
						$("#remark").val("");
					} else{
						alert(data.message);
					}
				}
			});
		})


		//给删除线索备注按钮绑定单击事件
		$("#fatherRemarkDiv").on("click","a[name='deleteA']",function (){
			var clueRemarkId = $(this).attr("remarkId");
			$.ajax({
				url:'workbench/clue/deleteClueRemark.do',
				data:{
					clueRemarkId:clueRemarkId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//删除该备注
						$("#div_"+clueRemarkId).remove();
					} else{
						alert(data.message);
					}
				}
			});
		})


		//给线索备注的“修改”A标签绑定单击事件
		$("#fatherRemarkDiv").on("click","a[name='editA']",function (){
			var id=$(this).attr("remarkId");
			//收集参数
			var noteContent=$("#div_"+id+" h5").html();

			//弹出修改线索备注的模态窗口
			$("#editRemarkModal").modal("show");
			//给模态窗口默认赋值
			$("#Hidden_contactsRemarkId").val(id);
			$("#edit-noteContent").val(noteContent);

		})


		//给修改线索备注的“更新”按钮绑定单击事件
		$("#updateRemarkBtn").click(function (){
			//收集参数
			var id=$("#Hidden_contactsRemarkId").val();
			var noteContent=$.trim($("#edit-noteContent").val());

			$.ajax({
				url:'workbench/clue/updateClueRemakrById.do',
				data:{
					id:id,
					noteContent:noteContent
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");
						//更新成功，更新页面该条备注
						$("#div_"+id+" h5").html(noteContent);
						$("#div_"+id+" small").html(" "+data.retData.editTime+" 由${sessionScope.sessionUser.name}修改");

					}else {
						//更新失败，提示信息
						alert(data.message);
						//模态窗口不关闭
						$("#editRemarkModal").modal("show");
					}
				}
			})
		})


	});
	
</script>

</head>
<body>

	<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
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
								<td><input type="checkbox"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="ActivityTbody">
							<%--<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="bundClueActivityBtn">关联</button>
				</div>
			</div>
		</div>
	</div>


	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${clue.fullname}${clue.appellation} <small>${clue.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="convertClueBtn" ><span class="glyphicon glyphicon-retweet"></span> 转换</button>
			
		</div>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.fullname}${clue.appellation}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.owner}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.job}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clue.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clue.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">详细地址</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clue.address}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 40px; left: 40px;" id="fatherRemarkDiv">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		<c:forEach items="${clueRemarkList}" var="obj">
			<div class="remarkDiv" style="height: 60px;" id="div_${obj.id}">
				<img title="${obj.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${obj.noteContent}</h5>
					<font color="gray">线索</font> <font color="gray">-</font> <b>${clue.fullname}${clue.appellation}-${clue.company}</b> <small style="color: gray;"> ${obj.editFlag=="0"?obj.createTime:obj.editTime} 由${obj.editFlag=="0"?obj.createBy:obj.editBy}${obj.editFlag=="0"?"创建":"修改"}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" href="javascript:void(0);" name="editA" remarkId="${obj.id}"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" href="javascript:void(0);" name="deleteA" remarkId="${obj.id}"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>
		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>

	<!-- 修改线索备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<input type="hidden" id="Hidden_contactsRemarkId">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelH4">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="edit-noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="clueActivityTbody">
					<c:forEach items="${activitieList}" var="obj">
						<tr id="tr_${obj.id}">
							<td>${obj.name}</td>
							<td>${obj.startDate}</td>
							<td>${obj.endDate}</td>
							<td>${obj.owner}</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;" activityId="${obj.id}"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
					</c:forEach>
						<%--<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
						<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="bundClueActivityA" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>