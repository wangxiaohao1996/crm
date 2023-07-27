package com.bjpowernode.crm.workbench.clue.service.Impl;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.workbench.clue.mapper.*;
import com.bjpowernode.crm.workbench.clue.pojo.*;
import com.bjpowernode.crm.workbench.clue.service.ClueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("clueService")
public class ClueServiceImpl implements ClueService {
    @Resource
    private ClueMapper clueMapper;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private ContactsMapper contactsMapper;
    @Resource
    private ClueRemarkMapper clueRemarkMapper;
    @Resource
    private CustomerRemarkMapper customerRemarkMapper;
    @Resource
    private ContactsRemarkMapper contactsRemarkMapper;
    @Resource
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Resource
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Resource
    private TranMapper tranMapper;
    @Resource
    private TranRemarkMapper tranRemarkMapper;

    /**
     * 创建线索
     * @param clue
     * @return
     */
    @Override
    public int saveCreateClue(Clue clue) {
        return clueMapper.insertClue(clue);
    }

    /**
     * 根据线索id查询线索明细
     * @param id
     * @return
     */
    @Override
    public Clue queryClueForDetailById(String id) {
        return clueMapper.selectClueForDetailById(id);
    }

    /**
     * 为线索转换，根据线索id查询线索信息
     * @param map
     * @return
     */
    @Override
    public void saveClueConvert(Map<String,Object> map) {
        User user=(User)map.get(Contants.SESSION_USER);
        String clueId = (String)map.get("clueId");
        //根据线索id查询线索的信息
        Clue clue = clueMapper.selectClueForConvertById(clueId);
        //封装客户信息
        Customer customer = new Customer();
        customer.setAddress(clue.getAddress());
        customer.setId(UUIDUtils.getUUID());
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtils.formateDateTime(new Date()));
        customer.setDescription(clue.getDescription());
        customer.setContactSummary(clue.getContactSummary());
        customer.setName(clue.getCompany());
        customer.setNextContactTime(clue.getNextContactTime());
        customer.setOwner(user.getId());
        customer.setPhone(clue.getPhone());
        customer.setWebsite(clue.getWebsite());
        //调用客户表mapper,将该线索表客户信息转成客户表信息
          customerMapper.insertCustomerFromClueConvert(customer);
          //封装联系人信息
        Contacts contacts= new Contacts();
        contacts.setId(UUIDUtils.getUUID());
        contacts.setAddress(clue.getAddress());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setDescription(clue.getDescription());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateUtils.formateDateTime(new Date()));
        contacts.setOwner(user.getId());
        contacts.setAppellation(clue.getAppellation());
        contacts.setCustomerId(customer.getId());
        contacts.setEmail(clue.getEmail());
        contacts.setFullname(clue.getFullname());
        contacts.setJob(clue.getJob());
        contacts.setMphone(clue.getMphone());
        contacts.setNextContactTime(contacts.getNextContactTime());
        contacts.setSource(clue.getSource());
        contacts.setBirth("");
        //调用联系人service，将该线索中的个人信息转成联系人信息
        contactsMapper.insertContactsFromClueConvert(contacts);
        //查询该线索的所有备注
        List<ClueRemark> clueRemarkList = clueRemarkMapper.selectClueRemarkForConvertByClueId(clueId);
        if (clueRemarkList!=null&& clueRemarkList.size()>0){
            //把线索的备注信息转换到客户备注表中一份
            List<CustomerRemark> customerRemarkList = new ArrayList<CustomerRemark>();
            List<ContactsRemark> contactsRemarkList = new ArrayList<ContactsRemark>();
            CustomerRemark customerRemark=null;
            ContactsRemark contactsRemark=null;
            for (ClueRemark c:clueRemarkList){
                customerRemark = new CustomerRemark();
                customerRemark.setCreateBy(c.getCreateBy());
                customerRemark.setCustomerId(customer.getId());
                customerRemark.setId(UUIDUtils.getUUID());
                customerRemark.setCreateTime(c.getCreateTime());
                customerRemark.setEditBy(c.getEditBy());
                customerRemark.setEditTime(c.getEditTime());
                customerRemark.setEditFlag(c.getEditFlag());
                customerRemark.setNoteContent(c.getNoteContent());
                customerRemarkList.add(customerRemark);

                contactsRemark = new ContactsRemark();
                contactsRemark.setContactsId(contacts.getId());
                contactsRemark.setCreateBy(c.getCreateBy());
                contactsRemark.setId(UUIDUtils.getUUID());
                contactsRemark.setCreateTime(c.getCreateTime());
                contactsRemark.setEditBy(c.getEditBy());
                contactsRemark.setEditFlag(c.getEditFlag());
                contactsRemark.setEditTime(c.getEditTime());
                contactsRemark.setNoteContent(c.getNoteContent());
                contactsRemarkList.add(contactsRemark);
            }
            //调用客户备注mapper完成备注转换
            customerRemarkMapper.insetCustomerRemarkFromClueRemarkByList(customerRemarkList);
            //调用联系人备注mapper完成备注转换
            contactsRemarkMapper.insertContactsRemarkFromClueRemarkByList(contactsRemarkList);
        }

        //查询该线索关联的所有市场活动
        List<ClueActivityRelation> clueActivityRelations = clueActivityRelationMapper.selectClueActivityRelationByClueId(clueId);
        if (clueActivityRelations!=null&&clueActivityRelations.size()>0){
            List<ContactsActivityRelation> contactsActivityRelationList = new ArrayList<ContactsActivityRelation>();
            ContactsActivityRelation contactsActivityRelation=null;
            for (ClueActivityRelation a:clueActivityRelations){
                contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtils.getUUID());
                contactsActivityRelation.setContactsId(contacts.getId());
                contactsActivityRelation.setActivityId(a.getActivityId());
                contactsActivityRelationList.add(contactsActivityRelation);
            }
            //调用联系人市场活动mapper，将线索市场活动关联关系转成联系人市场活动关联关系
            contactsActivityRelationMapper.insertContactsActivityRelationFromClueActivityRelationByList(contactsActivityRelationList);
        }
        //如果需要创建交易，则往交易表中添加一条记录
        if ("true".equals((String) map.get("createTransaction"))){
            //往交易表中添加一条记录
            Tran tran = new Tran();
            tran.setActivityId((String)map.get("acticityId"));
            tran.setContactsId(contacts.getId());
            tran.setId(UUIDUtils.getUUID());
            tran.setCustomerId(customer.getId());
            tran.setName((String)map.get("name"));
            tran.setCreateBy(user.getId());
            tran.setCreateTime(DateUtils.formateDateTime(new Date()));
            tran.setExpectedDate((String)map.get("expectedDate"));
            tran.setMoney((String)map.get("money"));
            tran.setOwner(user.getId());
            tran.setStage((String)map.get("stage"));
            tran.setType("");
            tran.setSource("");

            //调用交易mapper，添加一条交易记录
            tranMapper.insertTranFromClueConvert(tran);

            //把线索备注表转到交易备注表一份
            if (clueRemarkList!=null&& clueRemarkList.size()>0){
                List<TranRemark> tranRemarkList = new ArrayList<TranRemark>();
                TranRemark tranRemark =null;
                for (ClueRemark c:clueRemarkList) {
                    tranRemark = new TranRemark();
                    tranRemark.setCreateBy(c.getCreateBy());
                    tranRemark.setId(UUIDUtils.getUUID());
                    tranRemark.setCreateTime(c.getCreateTime());
                    tranRemark.setEditBy(c.getEditBy());
                    tranRemark.setEditTime(c.getEditTime());
                    tranRemark.setNoteContent(c.getNoteContent());
                    tranRemark.setTranId(tran.getId());
                    tranRemark.setEditFlag(c.getEditFlag());
                    tranRemarkList.add(tranRemark);
                }
                //调用交易备注mapper，把线索备注表转到交易备注表一份
                tranRemarkMapper.insertTranRemarkFromClueRemark(tranRemarkList);
            }
        }

        //删除线索的备注
            clueRemarkMapper.deleteClueRemarkByClueId(clueId);
        //删除线索和市场活动的关联关系
        clueActivityRelationMapper.deleteClueActivityRelationByClueId(clueId);
        //删除线索
        clueMapper.deleteClueById(clueId);
    }

    @Override
    public List<Clue> queryClueByCondition(Map<String, Object> map) {

        return clueMapper.selectClueByCondition(map);
    }

    @Override
    public int queryClueCountByCondition(Map<String, Object> map) {
        return clueMapper.selectClueCountByCondition(map);
    }

    /**
     * 根据id批量删除线索，以及线索下的备注、市场活动关联关系
     * @param ids
     * @return
     */
    @Override
    public void deleteClueByIds(String[] ids) {
        //根据线索id批量删除线索下的备注
        clueRemarkMapper.deleteClueRemarkByClueIds(ids);
        //根据线索id批量删除线索下的市场活动关联关系
        clueActivityRelationMapper.deleteCARByClueIds(ids);
        //根据线索id数组，批量删除线索
        clueMapper.deleteClueByIds(ids);

    }

    /**
     * 根据id修改线索
     * @param clue
     * @return
     */
    @Override
    public int saveUpdateClueById(Clue clue) {
        return clueMapper.updateClueById(clue);
    }
}
