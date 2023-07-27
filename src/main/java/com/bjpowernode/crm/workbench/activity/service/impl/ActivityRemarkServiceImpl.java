package com.bjpowernode.crm.workbench.activity.service.impl;

import com.bjpowernode.crm.workbench.activity.mapper.ActivityRemarkMapper;
import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;
import com.bjpowernode.crm.workbench.activity.service.ActivityRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("activityRemarkService")
public class ActivityRemarkServiceImpl implements ActivityRemarkService {
    @Resource
    private ActivityRemarkMapper activityRemarkMapper;

    /**
     * 根据市场活动id查询市场活动备注表
     * @param activityId
     * @return
     */
    @Override
    public List<ActivityRemark> queryActivityRemarkForDetailByActivityId(String activityId) {
        return activityRemarkMapper.selectActivityRemarkByActivityId(activityId);
    }

    /**
     * 保存创建的市场活动的备注
     * @param activityRemark
     * @return
     */
    @Override
    public int saveCreateActivityRemark(ActivityRemark activityRemark) {

        return activityRemarkMapper.insertActivityRemark(activityRemark);
    }

    /**
     * 通过id删除市场活动备注
     * @param id
     * @return
     */
    @Override
    public int deleteActivityRemarkById(String id) {
        return activityRemarkMapper.deleteActivityRemarkById(id);
    }

    /**
     * 根据id修改市场活动备注信息
     * @param activityRemark
     * @return
     */
    @Override
    public int saveUpdateActivityRemarkById(ActivityRemark activityRemark) {
        return activityRemarkMapper.updateActivityRemarkById(activityRemark);
    }
}
