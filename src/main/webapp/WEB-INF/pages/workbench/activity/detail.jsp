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
		});*/

		$("#remarkDivList").on("mouseover",".remarkDiv",function (){
			$(this).children("div").children("div").show();
		})

		$("#remarkDivList").on("mouseout",".remarkDiv",function (){
			$(this).children("div").children("div").hide();
		})

		$("#remarkDivList").on("mouseover",".myHref",function (){
			$(this).children("span").css("color","red");
		})

		$("#remarkDivList").on("mouseout",".myHref",function (){
			$(this).children("span").css("color","#E6E6E6");
		})

		//给保存按钮添加单击事件
		$("#saveCreateActivityRemarkBtn").click(function (){
			//收集参数
			//从作用域中取市场活动id
			var activityId = '${activity.id}';
			//获取备注内容
			var noteContent = $.trim($("#remark").val());
			//表单验证
			if (noteContent==""){
				alert("请填写备注内容");
				return;
			}
			$.ajax({
				url:'workbench/activity/saveCreateActivityRemark.do',
				data:{
					activityId:activityId,
					noteContent:noteContent
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//添加成功之后,清空输入框
						$("#remark").val("");
						//动态添加一条备注信息
						var remarkHtml="";
						    remarkHtml+="<div id=\"div_"+data.retData.id+"\" class=\"remarkDiv\" style=\"height: 60px;\">"
							remarkHtml+="<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">"
						    remarkHtml+="	<div style=\"position: relative; top: -40px; left: 40px;\" >"
							remarkHtml+="	<h5>"+data.retData.noteContent+"</h5>"
							remarkHtml+="<font color=\"gray\">市场活动</font> <font color=\"gray\">-</font> <b>${activity.name}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.sessionUser.name}创建</small>"
							remarkHtml+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">"
							remarkHtml+="<a class=\"myHref\" name=\"editRemark\"remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span  class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>"
							remarkHtml+="	&nbsp;&nbsp;&nbsp;&nbsp;"
							remarkHtml+="<a class=\"myHref\" name=\"delectRemark\" remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>"
							remarkHtml+="	</div>"
							remarkHtml+="</div>"
							remarkHtml+="</div>"
						$("#remarkDiv").before(remarkHtml);
					}else {
						//添加失败,提示信息,输入框不清空,列表也不刷新
						alert(data.message);
					}
				}
			})
		})


		//给所有的”删除“按钮绑定单击事件
		$("#remarkDivList").on("click","a[name='delectRemark']",function (){
			//获取备注id
			var id = $(this).attr("remarkId");
			$.ajax({
				url: 'workbench/activity/deleteActivityRemarkById.do',
				data: {
					id:id
				},
				type: 'post',
				dataType: 'json',
				success:function (data){
					if (data.code==1){
						//删掉备注列表
						$("#div_"+id).remove();
					}else {
						alert(data.message);
					}
				}
			})
		})


		//给所有的“修改”按钮绑定单击事件
		$("#remarkDivList").on("click","a[name='editRemark']",function (){
			//收集参数
			var id = $(this).attr("remarkId");
			var noteContent = $("#div_"+id+" h5").html();
			//在修改市场活动备注的模态窗口弹出之前初始化
			$("#edit-noteContent").val(noteContent);
			//给隐藏标签的value赋值
			$("#Hidden_ActivityRemarkId").val(id);
			//弹出修改市场活动备注的模态窗口
			$("#editRemarkModal").modal("show");
		})


		//给“更新”按钮绑定单击事件
		$("#updateRemarkBtn").click(function (){
			//收集参数
			var id = $("#Hidden_ActivityRemarkId").val();
			var noteContent = $.trim($("#edit-noteContent").val());
			//表单验证
			if (noteContent==""){
				alert("备注内容不能为空");
				return;
			}
			//发送异步请求
			$.ajax({
				url:'workbench/activity/saveUpdataActivityRemarkById.do',
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
						//动态给刷新备注
						//给H5标签重新赋值
						$("#div_"+id+" h5").html(noteContent);
						//给small标签值覆盖
						$("#div_"+id+" small").html(" "+data.retData.editTime+" 由${sessionScope.sessionUser.name}修改")

					}else{
						alert(data.message);
						$("#editRemarkModal").modal("show");
					}
				}
			})
		})
	});

</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<input type="hidden" id="Hidden_ActivityRemarkId">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
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

    

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
	                    ${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkDivList" style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

<%--		遍历activityRemarkList，显示所有备注--%>
		<c:forEach  items="${activityRemarkList}" var="activityRemark" >
			<div id="div_${activityRemark.id}" class="remarkDiv" style="height: 60px;">
				<img title="${activityRemark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${activityRemark.noteContent}</h5>
					<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;"> ${activityRemark.editFlag=="0"?activityRemark.createTime:activityRemark.editTime} 由${activityRemark.editFlag=="0"?activityRemark.createBy:activityRemark.editBy}${activityRemark.editFlag=="0"?"创建":"修改"}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" name="editRemark" remarkId="${activityRemark.id}" href="javascript:void(0);"><span  class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" name="delectRemark" remarkId="${activityRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>

		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
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
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
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
					<button type="button" class="btn btn-primary" id="saveCreateActivityRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>