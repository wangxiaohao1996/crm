package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;
import com.bjpowernode.crm.workbench.activity.service.ActivityRemarkService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.Date;

@Controller
public class ActivityRemarkController {
    @Resource
    private ActivityRemarkService activityRemarkService;
    @ResponseBody
    @RequestMapping("/workbench/activity/saveCreateActivityRemark.do")
    public Object saveCreateActivityRemark(ActivityRemark activityRemark, HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        //封装参数
        activityRemark.setId(UUIDUtils.getUUID());
        activityRemark.setCreateBy(user.getId());
        activityRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        activityRemark.setEditFlag(Contants.ACTIVITY_REMARK_EDIT_FLAG_NO_ENITED);

        try {
            //调service层，创建市场活动的备注
            int count = activityRemarkService.saveCreateActivityRemark(activityRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(activityRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/deleteActivityRemarkById.do")
    public Object deleteActivityRemarkById(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            //调service层，删除市场活动备注信息
            int count = activityRemarkService.deleteActivityRemarkById(id);
            if (count>0){
                //删除成功
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/saveUpdataActivityRemarkById.do")
    public Object saveUpdataActivityRemarkById(ActivityRemark activityRemark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        activityRemark.setEditBy(user.getId());
        activityRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        activityRemark.setEditFlag(Contants.ACTIVITY_REMARK_EDIT_FLAG_YES_ENITED);
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service层，更新市场活动备注信息
            int count = activityRemarkService.saveUpdateActivityRemarkById(activityRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(activityRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，稍后重试...");
        }

        return returnObject;

    }


}
