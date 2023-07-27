package com.bjpowernode.crm.workbench.transaction.service.serviceImpl;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.Funnel;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.workbench.clue.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.clue.mapper.TranHistoryMapper;
import com.bjpowernode.crm.workbench.clue.mapper.TranMapper;
import com.bjpowernode.crm.workbench.clue.mapper.TranRemarkMapper;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.Customer;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import com.bjpowernode.crm.workbench.clue.pojo.TranHistory;
import com.bjpowernode.crm.workbench.transaction.service.TranService;
import org.apache.poi.ss.formula.functions.T;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {
    @Resource
    private TranMapper tranMapper;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private TranHistoryMapper tranHistoryMapper;
    @Resource
    private TranRemarkMapper tranRemarkMapper;
    @Override
    public void saveCreateTran(Map<String,Object> map) {
        User user = (User) map.get(Contants.SESSION_USER);
        //根据全名去查询客户信息
        Customer customer = customerMapper.selectCustomerByAllName((String) map.get("accountName"));
        if(customer==null){
            //调用国家接口，查询公司是否纯在
            //存在就新建客户
              customer = new Customer();
            customer.setCreateBy(user.getId());
            customer.setOwner(user.getId());
            customer.setName((String) map.get("accountName"));
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setId(UUIDUtils.getUUID());

            customerMapper.insertCustomerFromClueConvert(customer);
        }

        //创建交易
        Tran tran = new Tran();
        tran.setStage((String) map.get("stage"));
        tran.setSource((String) map.get("source"));
        tran.setOwner((String) map.get("owner"));
        tran.setCreateBy(user.getId());
        tran.setMoney((String) map.get("money"));
        tran.setName((String) map.get("name"));
        tran.setDescription((String) map.get("description"));
        tran.setExpectedDate((String) map.get("expectedDate"));
        tran.setCreateTime(DateUtils.formateDateTime(new Date()));
        tran.setId(UUIDUtils.getUUID());
        tran.setCustomerId(customer.getId());
        tran.setContactsId((String) map.get("contactsId"));
        tran.setNextContactTime((String) map.get("nextContactTime"));
        tran.setType((String) map.get("type"));
        tran.setContactSummary((String) map.get("contactSummary"));
        tran.setActivityId((String) map.get("activityId"));

        tranMapper.insertTranFromClueConvert(tran);
    }

    @Override
    public Tran queryTranForDetailById(String id) {
           Tran tran = tranMapper.selectTranForDetailById(id);
        return tran;
    }

    @Override
    public List<Funnel> selectTranForFunnel() {

        return tranMapper.selectTranStageForEcharts();
    }

    @Override
    public List<Tran> queryTranForCustomerDetailByCustomerId(String customerId) {

        return tranMapper.selectTranForCustomerDetailByCustomerId(customerId);
    }

    /**
     * 根据联系人id查询该联系人有关的交易
     * @param contactsId
     * @return
     */
    @Override
    public List<Tran> queryTranForContactsDetailByConstactsId(String contactsId) {

        return tranMapper.selectTranForContactsDetailByContactsId(contactsId);
    }

    /**
     * 从联系人明细页面删除交易、交易备注、交易阶段历史（该方法暂时被遗弃了）
     * @param id
     * @return
     */
    @Override
    public void deleteTranFromContactsDetailById(String id) {
        String[] ids={id};
        tranHistoryMapper.deleteTranHistoryByTranIds(ids);
        tranRemarkMapper.deleteTranRemarkByTranIds(ids);
         tranMapper.deleteTranFromContactsDetailById(id);
    }

    /**
     * 根据条件模糊查询交易
     * @param map
     * @return
     */
    @Override
    public List<Tran> selectTranByCondition(Map<String, Object> map) {

        return tranMapper.selectTranByCondition(map);
    }

    /**
     * 根据条件模糊查询交易记录条数
     * @param map
     * @return
     */
    @Override
    public int selectTranNumberByCondition(Map<String, Object> map) {
        return tranMapper.selectTranNumberByCondition(map);
    }

    /**
     * 根据id数组批量删除交易,以及交易备注、交易的阶段历史记录
     * @param ids
     * @return
     */
    @Override
    public void deleteTranByIds(String[] ids) {
        tranHistoryMapper.deleteTranHistoryByTranIds(ids);
        tranRemarkMapper.deleteTranRemarkByTranIds(ids);
        tranMapper.deleteTranByIds(ids);
    }

    /**
     * 根据id修改交易
     * @param map
     * @return
     */
    @Override
    public void saveUpdateTranById(Map<String,Object> map) {
        User user = (User) map.get("user");
        //根据全名去查询客户信息
        Customer customer = customerMapper.selectCustomerByAllName((String) map.get("customerId"));//customerId保存的是客户名称
        if(customer==null){
            //调用国家接口，查询公司是否纯在
            //不存在就新建客户
            customer = new Customer();
            customer.setCreateBy(user.getId());
            customer.setOwner(user.getId());
            customer.setName((String) map.get("customerId"));
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setId(UUIDUtils.getUUID());

            customerMapper.insertCustomerFromClueConvert(customer);
        }

        //根据交易id查询交易信息
        Tran tran = tranMapper.selectTranById((String) map.get("id"));
        String stage1=tran.getStage();
        String stage2=(String) map.get("stage");
        if (!stage1.equals(stage2)){
            //每修改一次交易阶段，就给交易的阶段历史表添加一条记录
            TranHistory tranHistory = new TranHistory();
            tranHistory.setCreateBy(tran.getCreateBy());
            tranHistory.setTranId(tran.getId());
            tranHistory.setId(UUIDUtils.getUUID());
            tranHistory.setCreateTime(tran.getCreateTime());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistoryMapper.insertTranHistory(tranHistory);
        }


        //修改交易
        tran.setStage((String) map.get("stage"));
        tran.setSource((String) map.get("source"));
        tran.setOwner((String) map.get("owner"));
        tran.setMoney((String) map.get("money"));
        tran.setName((String) map.get("name"));
        tran.setDescription((String) map.get("description"));
        tran.setExpectedDate((String) map.get("expectedDate"));
        tran.setCustomerId(customer.getId());
        tran.setContactsId((String) map.get("contactsId"));
        tran.setNextContactTime((String) map.get("nextContactTime"));
        tran.setType((String) map.get("type"));
        tran.setContactSummary((String) map.get("contactSummary"));
        tran.setActivityId((String) map.get("activityId"));
        tran.setEditTime((String) map.get("editTime"));
        tran.setEditBy((String) map.get("editBy"));
        tran.setId((String) map.get("id"));

        tranMapper.updateTranById(tran);





    }
}
