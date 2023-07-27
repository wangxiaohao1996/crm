package com.bjpowernode.crm.workbench.activity.service.impl;

import com.bjpowernode.crm.workbench.activity.mapper.ActivityMapper;
import com.bjpowernode.crm.workbench.activity.mapper.ActivityRemarkMapper;
import com.bjpowernode.crm.workbench.activity.pojo.Activity;
import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;
import com.bjpowernode.crm.workbench.activity.service.ActicityService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service("acticityService")
public class ActicityServiceImpl implements ActicityService {
    @Resource
   private ActivityMapper activityMapper;
    @Resource
    private ActivityRemarkMapper activityRemarkMapper;

    /**
     * 保存新创建的市场活动信息
     * @param activity
     * @return
     */
    @Override
    public int saveCreateActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    /**
     * 根据条件查询市场活动信息列表
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByConditionForPage(Map<String, Object> map) {
        List<Activity> activities = activityMapper.selectActivityByConditionForPage(map);
        return activities;
    }

    /**
     * 根据条件查询市场活动总记录条数
     * @param map
     * @return
     */
    @Override
    public int queryCountOfActivityByCondition(Map<String, Object> map) {
        return activityMapper.selectCountOfActivityByCondition(map);
    }

    /**
     * 根据id批量删除市场活动信息列表，以及市场活动的备注
     * @param ids
     * @return
     */
    @Override
    public void deleteActivityByIds(String[] ids) {

        //根据市场活动id数组批量删除市场活动备注
        activityRemarkMapper.deleteActivityRemarkByActivityIds(ids);
        //根据id批量删除市场活动信息列表
        activityMapper.deleteActivityByIds(ids);
    }

    /**
     * 根据id查询市场活动表
     * @param id
     * @return
     */
    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    /**
     * 根据id修改市场活动信息表
     * @param activity
     * @return
     */
    @Override
    public int editActivityById(Activity activity) {
        return activityMapper.updateActivityById(activity);
    }


    /**
     * 查询所有的市场活动
     * @return
     */
    @Override
    public List<Activity> queryAllActivitys() {
        return activityMapper.selectAllActivitys();
    }

    /**
     * 根据id数组查询市场信息列表
     * @param ids
     * @return
     */
    @Override
    public List<Activity> queryActivityByIds(String[] ids) {
        return activityMapper.selectActivityByIds(ids);
    }

    @Override
    public int saveInsertActivityByFile(List<Activity> activities) {

        return activityMapper.insertActivityByFile(activities);
    }

    /**
     * 根据市场活动id为明细页面查询市场活动表
     * @param id
     * @return
     */
    @Override
    public Activity queryActivityForDetailById(String id) {

        return activityMapper.selectActivityForDetailById(id);
    }

    /**
     * 根据线索id查询该线索关联的所有市场活动
     * @param clueId
     * @return
     */
    @Override
    public List<Activity> queryActivityForClueDetailByClueId(String clueId) {

        return activityMapper.selectActivityForClueDetailByClueId(clueId);
    }

    /**
     * 根据市场活动名称和线索id模糊查询市场活动，为线索关联市场活动做准备
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityForClueDetailByNameClueId(Map<String, Object> map) {

        return activityMapper.selectActivityForClueDetailByNameClueId(map);
    }

    /**
     * 每成功关联一条市场活动就在线索明细页面显示一条记录
     * @param ids
     * @return
     */
    @Override
    public List<Activity> queryActivityByActivityIds(String[] ids) {
        return activityMapper.selectActivityByActivityIds(ids);
    }

    /**
     * 根据市场活动名称和clueId模糊查询与该线索关联的市场活动
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByNameClueId(Map<String, Object> map) {
        return activityMapper.selectActivityByNameClueId(map);
    }

    /**
     * 根据联系人id查询跟该联系人有关的所有市场活动
     * @param contactsId
     * @return
     */
    @Override
    public List<Activity> queryActivityForContactsDetailByContactsId(String contactsId) {

        return activityMapper.selectActivityForContactsDetailByContactsId(contactsId);
    }

    /**
     * 根据名称模糊查询不包含该联系人关联过的市场活动
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityForContactsActivityByName(Map<String, Object> map) {

        return activityMapper.selectActivityForContactsActivityByName(map);
    }

    /**
     * 根据名字模糊查询市场活动
     * @param name
     * @return
     */
    @Override
    public List<Activity> queryActivityByName(String name) {

        return activityMapper.selectActivityByName(name);
    }


}
