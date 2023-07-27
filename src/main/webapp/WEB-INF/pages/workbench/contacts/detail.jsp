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

		$("#div_contactsRemarks").on("mouseover",".remarkDiv",function (){
			$(this).children("div").children("div").show();
		})
		$("#div_contactsRemarks").on("mouseout",".remarkDiv",function (){
			$(this).children("div").children("div").hide();
		})
		$("#div_contactsRemarks").on("mouseover",".myHref",function (){
			$(this).children("span").css("color","red");
		})
		$("#div_contactsRemarks").on("mouseout",".myHref",function (){
			$(this).children("span").css("color","#E6E6E6");
		})


		//给客户备注“保存”按钮绑定点击事件
		$("#saveCreateContactsRemarkBtn").click(function (){
			//收集参数
			var noteContent=$("#remark").val();
			var contactsId = '${contacts.id}';
			$.ajax({
				url:'workbench/contacts/createContactsRemarkFromContactsDetail.do',
				data:{
					noteContent:noteContent,
					contactsId:contactsId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//手动在页面添加一条备注
						var Str="";
						Str+="<div class=\"remarkDiv\" style=\"height: 60px;\" id='div_"+data.retData.id+"'>";
						Str+="	<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						Str+="		<div style=\"position: relative; top: -40px; left: 40px;\" >";
						Str+="			<h5>"+data.retData.noteContent+"</h5>";
						Str+="			<font color=\"gray\">联系人</font> <font color=\"gray\">-</font> <b>${contacts.fullname}${contacts.appellation}-${contacts.customerId}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.sessionUser.name}创建</small>";
						Str+="			<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						Str+="				<a class=\"myHref\" href=\"javascript:void(0);\" name='editA' remarkId='"+data.retData.id+"'><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						Str+="				&nbsp;&nbsp;&nbsp;&nbsp;";
						Str+="				<a class=\"myHref\" href=\"javascript:void(0);\" name='deleteA' remarkId='"+data.retData.id+"'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						Str+="			</div>";
						Str+="		</div>";
						Str+="</div>";
						//
						$("#remarkDiv").before(Str);
						//重置标签内容
						$("#remark").val("")
					}else {
						alert(data.message);
					}
				}
			});
		})

		//给客户备注删除标签绑定单击事件
		$("#div_contactsRemarks").on("click","a[name='deleteA']",function (){
			//收集参数，获取该备注id
			var id = $(this).attr("remarkId");
			$.ajax({
				url: 'workbench/contacts/deleteContactsRemarkFromContactsDetail.do',
				data: {
					id:id
				},
				type: 'post',
				dataType: 'json',
				success:function (data){
					if (data.code=="1"){
						//手动删除页面该备注信息
						$("#div_"+id).remove();
					}else {
						alert(data.message);
					}
				}
			});
		})


		//给客户备注“修改”标签绑定单击事件
		$("#div_contactsRemarks").on("click","a[name='editA']",function (){
			//给修改客户备注模态窗口初始化
			var id = $(this).attr("remarkId");
			var noteContent = $("#div_"+id+" h5").text();
			$("#edit-noteContent").val(noteContent);

			$("#Hidden_contactsRemarkId").val(id);

			$("#editRemarkModal").modal("show");
		});


		//给客户备注模态窗口的更新按钮绑定单击事件
		$("#updateRemarkBtn").click(function (){
			//收集参数
			var id = $("#Hidden_contactsRemarkId").val();
			var noteContent = $.trim($("#edit-noteContent").val());

			//发送请求
			$.ajax({
				url:'workbench/contacts/updateContactsRemarkFromContactsDetail.do',
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
			});
		})



		//给“关联市场活动”按钮绑定单击事件
		$("#reletionBtn").click(function (){
			//初始化
			$("#searchActivityByName").val("");
			$("#activityTbody1").html("");
			//打开模态窗口
			$("#bundActivityModal").modal("show");
		})

          //给关联市场活动模态窗口的搜索框绑定键盘弹起事件
		$("#searchActivityByName").keyup(function (){
			//收集参数
			var name = $.trim(this.value);
			var contactsId = '${contacts.id}';

			//发送请求
			$.ajax({
				url:'workbench/activity/queryActivityForContactsActivityByName.do',
				data:{
					name:name,
					contactsId:contactsId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					var str ="";
					$.each(data,function (index,obj){
						str+="<tr>";
						str+="	<td><input type=\"checkbox\" value='"+obj.id+"'/></td>";
						str+="	<td>"+obj.name+"</td>";
						str+="	<td>"+obj.startDate+"</td>";
						str+="	<td>"+obj.endDate+"</td>";
						str+="	<td>"+obj.owner+"</td>";
						str+="</tr>";
					})
					$("#activityTbody1").html(str);

				}
			});
		})



		//关联市场活动模态窗口的复选框全选
		$("#checkAll").click(function (){
			var checked=this.checked;
			$("#activityTbody1 input[type='checkbox']").prop("checked",checked)
		})
		//给tbody的所有复选框绑定单击事件，取消全选
		$("#activityTbody1").on("click","input[type='checkbox']",function (){
			//获取所有的复选框和所有选中的复选框
			//获取tBody下所有的复选框和选中的复选框
			var checkboxs = $("#activityTbody1 input[type='checkbox']");
			var checkeds = $("#activityTbody1 input[type='checkbox']:checked");
			//判断是否相等，相等全选，不相等，取消全选
			$("#checkAll").prop("checked",checkboxs.size()==checkeds.size());
		})




		//给‘关联’按钮绑定单击事件
		$("#bundActivityBtn").click(function (){
			//获取tbody下复选框的选中个数
			var checkedNum = $("#activityTbody1 input[type='checkbox']:checked");
			//至少选中一个
			if (checkedNum.size()==0){
				alert("至少选择一条市场活动");
				return;
			}
			var activityIds="";
			$.each(checkedNum,function (index,obj){
				activityIds+="activityId="+this.value+"&"
			})
			//
			activityIds+="contactsId=${contacts.id}";


			$.ajax({
				url:'workbench/contacts/relationContactsActivity.do',
				data:activityIds,
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//关闭模态窗口
						$("#bundActivityModal").modal("hide");
						//在明细页面手动添加刚刚关联的市场活动
						var str="";
						$.each(data.retData,function (index,obj){
							str+="<tr id='tr_"+obj.id+"'>";
							str+="	<td><a href=\"workbench/activity/queryActivityRemarkForDetailByActivityId.do?id="+obj.id+"\" style=\"text-decoration: none;\">"+obj.name+"</a></td>";
							str+="	<td>"+obj.startDate+"</td>";
							str+="	<td>"+obj.endDate+"</td>";
							str+="	<td>"+obj.owner+"</td>";
							str+="	<td><a href=\"javascript:void(0);\" activityId='"+obj.id+"' name=\"deleteA\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>";
							str+="</tr>";
						})
						$("#activityTbody2").append(str);
					}else {
						alert(data.message);
						$("#bundActivityModal").modal("show");
					}
				}
			});

		})


		//给“解除关联”标签绑定单击事件
		$("#activityTbody2").on("click","a[name='deleteA']",function (){
			var activityId = $(this).attr("activityId");
			$("#activityId").val(activityId);
			//解除联系人和市场活动关联的模态窗口
			$("#unbundActivityModal").modal("show");
		})


		//给“解除”按钮绑定单击事件
		$("#deleteBundBtn").click(function (){
			//收集参数
			var activityId = $("#activityId").val();
			var contactsId = '${contacts.id}';
			$.ajax({
				url:'workbench/contacts/deleteContactsActivityRelationFromDetail.do',
				data:{
					activityId:activityId,
					contactsId:contactsId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=="1"){
						//删除成功，关闭模态窗口，
						$("#unbundActivityModal").modal("hide");
						//手动把页面上刚删除的市场活动去掉
						$("#tr_"+activityId).remove();
					}else {
						alert(data.message);
						$("#unbundActivityModal").modal("show");
					}
				}
			})
		})


		//给“删除”交易标签绑定单击事件
		$("#tranTbody").on("click","a[name='deleteA']",function (){
			//弹出删除确认框
			if (window.confirm("您确定要删除该交易吗?")){
				//收集参数
				var id = $(this).attr("tranId")

				$.ajax({
					url:'workbench/contacts/deleteTranFromContactsDetailById.do',
					data:{
						id:id
					},
					type:'post',
					dataType:'json',
					success:function (data){
						if (data.code=="1"){
							//把刚删除的交易标签从页面删掉
							$("#TranTr_"+id).remove();
						}else {
							alert(data.message);
						}
					}
				})
			}
		})


	});
	
</script>

</head>
<body>

	<!-- 解除联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="unbundActivityModal" role="dialog">
		<input type="hidden" id="activityId">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">解除关联</h4>
				</div>
				<div class="modal-body">
					<p>您确定要解除该关联关系吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" id="deleteBundBtn">解除</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="bundActivityModal" role="dialog">
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
						    <input type="text" class="form-control" id="searchActivityByName" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable2" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="checkAll"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activityTbody1">
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
					<button type="button" class="btn btn-primary" id="bundActivityBtn">关联</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-contactsOwner" >
									<c:forEach items="${userList}" var="obj">
										<option value="${obj.id}">${obj.name}</option>
									</c:forEach>
								  <%--<option selected>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueSource">
								  <option></option>
									<c:forEach items="${sourceList}" var="obj">
										<option value="${obj.id}">${obj.value}</option>
									</c:forEach>
								  <%--<option selected>广告</option>
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
								<input type="text" class="form-control" id="edit-surname" value="${contacts.fullname}">
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
								<input type="text" class="form-control" id="edit-job" value="${contacts.job}">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="${contacts.mphone}">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="${contacts.email}">
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-birth" value="${contacts.birth}">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" value="${contacts.customerId}">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe" >${contacts.description}</textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary" >${contacts.contactSummary}</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="create-nextContactTime" value="${contacts.nextContactTime}">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address1">${contacts.address}</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
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
			<h3>${contacts.fullname}${contacts.appellation} <small> - ${contacts.customerId}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<%--<button type="button" class="btn btn-default" ><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>--%>
		</div>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.fullname}${contacts.appellation}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.job}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">生日</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.birth}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${contacts.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${contacts.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${contacts.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${contacts.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${contacts.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${contacts.contactSummary}&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 90px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${contacts.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	<!-- 备注 -->
	<div style="position: relative; top: 20px; left: 40px;" id="div_contactsRemarks">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		<c:forEach items="${contactsRemarkList}" var="obj">
			<div class="remarkDiv" style="height: 60px;" id="div_${obj.id}">
			<img title="${obj.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>${obj.noteContent}</h5>
				<font color="gray">联系人</font> <font color="gray">-</font> <b>${contacts.fullname}${contacts.appellation}-${contacts.customerId}</b> <small style="color: gray;"> ${obj.editFlag=="0"?obj.createTime:obj.editTime} 由${obj.editFlag=="0"?obj.createBy:obj.editBy}${obj.editFlag=="0"?'创建':'修改'}</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);" name="editA" remarkId="${obj.id}"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);" name="deleteA" remarkId="${obj.id}"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		</c:forEach>
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
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
				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
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
					<button type="button" class="btn btn-primary" id="saveCreateContactsRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>


	<!-- 修改联系人备注的模态窗口 -->
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
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable3" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranTbody">
					<c:forEach items="${tranList}" var="obj">
						<tr id="TranTr_${obj.id}">
							<td><a href="workbench/transaction/toTranDetail.do?tranId=${obj.id}" style="text-decoration: none;">${obj.customerId}-${obj.name}</a></td>
							<td>${obj.money}</td>
							<td>${obj.stage}</td>
							<td>${obj.possibility}</td>
							<td>${obj.expectedDate}</td>
							<td>${obj.type}</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundModal" name="deleteA" style="text-decoration: none;" tranId="${obj.id}"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>
					</c:forEach>
						<%--<tr>
							<td><a href="../transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="workbench/transaction/toSave.do?contactsId=${contacts.id}&contactsFullname=${contacts.fullname}" style="text-decoration: none;"><span class="glyphicon glyphicon-plus" id="createTranA"></span>新建交易</a>
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
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityTbody2">
					<c:forEach items="${activityList}" var="obj">
						<tr id="tr_${obj.id}">
							<td><a href="workbench/activity/queryActivityRemarkForDetailByActivityId.do?id=${obj.id}" style="text-decoration: none;">${obj.name}</a></td>
							<td>${obj.startDate}</td>
							<td>${obj.endDate}</td>
							<td>${obj.owner}</td>
							<td><a href="javascript:void(0);" name="deleteA" style="text-decoration: none;" activityId="${obj.id}"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
					</c:forEach>
						<%--<tr>
							<td><a href="../activity/detail.jsp" style="text-decoration: none;">发传单</a></td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);"  id="reletionBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>