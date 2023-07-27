package com.bjpowernode.crm.workbench.activity.service;

import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;

import java.util.List;

public interface ActivityRemarkService {
    List<ActivityRemark> queryActivityRemarkForDetailByActivityId(String activityId);

    int saveCreateActivityRemark(ActivityRemark activityRemark);
    int deleteActivityRemarkById(String id);
    int saveUpdateActivityRemarkById(ActivityRemark activityRemark);
}
