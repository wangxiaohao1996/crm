package com.bjpowernode.crm.workbench.activity.service;

import com.bjpowernode.crm.workbench.activity.pojo.Activity;
import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;


public interface ActicityService {
    int saveCreateActivity(Activity activity);
    List<Activity> queryActivityByConditionForPage(Map<String,Object> map);
    int queryCountOfActivityByCondition(Map<String,Object> map);
    void deleteActivityByIds(String[] ids);
    Activity queryActivityById(String id);
    int editActivityById(Activity activity);

    List<Activity> queryAllActivitys();

    List<Activity> queryActivityByIds(String[] ids);

    int saveInsertActivityByFile(List<Activity> activities);
    Activity queryActivityForDetailById(String id);

    List<Activity> queryActivityForClueDetailByClueId(String clueId);

    List<Activity> queryActivityForClueDetailByNameClueId(Map<String,Object> map);

    List<Activity> queryActivityByActivityIds(String[] ids);

    List<Activity> queryActivityByNameClueId(Map<String,Object> map);

    /**
     * 根据联系人id查询跟该联系人有关的所有市场活动
     * @param contactsId
     * @return
     */
    List<Activity> queryActivityForContactsDetailByContactsId(String contactsId);

    /**
     * 根据名称模糊查询不包含该联系人关联过的市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivityForContactsActivityByName(Map<String,Object> map);

    /**
     * 为创建交易市场活动源根据名字模糊查询市场活动
     * @param name
     * @return
     */
    List<Activity> queryActivityByName(String name);

}
