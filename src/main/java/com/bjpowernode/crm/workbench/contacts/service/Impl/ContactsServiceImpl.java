package com.bjpowernode.crm.workbench.contacts.service.Impl;

import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.workbench.clue.mapper.*;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;
import com.bjpowernode.crm.workbench.clue.pojo.Customer;
import com.bjpowernode.crm.workbench.contacts.service.ContactsService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class ContactsServiceImpl implements ContactsService {
    @Resource
    private ContactsMapper contactsMapper;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private ContactsRemarkMapper contactsRemarkMapper;
    @Resource
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Override
    public List<Contacts> queryContactsForCustomerDetailByCustomerId(String customerId) {

        return contactsMapper.selectContactsForCustomerDetailByCustomerId(customerId);
    }

    @Override
    public int saveCreateContacts(Contacts contacts) {

        return contactsMapper.insertContactsFromClueConvert(contacts);
    }

    @Override
    public void saveCreateContactsFromCreate(Map<String,Object> map) {
        User user = (User) map.get("user");
        //根据客户全名查询客户id
        Customer customer = customerMapper.selectCustomerByAllName((String) map.get("customerName"));
        //客户表中没有则创建客户
        if (customer==null){
            customer=new Customer();
            //新建客户
            customer.setCreateBy(user.getId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setName((String) map.get("customerName"));
            customer.setOwner(user.getId());
            customer.setPhone("");
            customer.setWebsite("");
            customerMapper.insertCustomer(customer);
        }
        //封装参数
        Contacts contacts = new Contacts();
        contacts.setCreateTime(DateUtils.formateDateTime(new Date()));
        contacts.setNextContactTime((String) map.get("nextContactTime"));
        contacts.setCreateBy(user.getId());
        contacts.setSource((String) map.get("source"));
        contacts.setJob((String) map.get("job"));
        contacts.setMphone((String) map.get("mphone"));
        contacts.setFullname((String) map.get("fullname"));
        contacts.setEmail((String) map.get("email"));
        contacts.setCustomerId(customer.getId());
        contacts.setAppellation((String) map.get("appellation"));
        contacts.setDescription((String) map.get("description"));
        contacts.setAddress((String) map.get("address"));
        contacts.setContactSummary((String) map.get("contactSummary"));
        contacts.setId(UUIDUtils.getUUID());
        contacts.setOwner((String) map.get("owner"));
        contacts.setBirth((String) map.get("birth"));
        //调用联系人mapper层插入联系人信息
        contactsMapper.insertContactsFromClueConvert(contacts);
    }

    /**
     * 根据条件模糊查询联系人列表
     * @param map
     * @return
     */
    @Override
    public List<Contacts> queryContactsByCondition(Map<String, Object> map) {
        return contactsMapper.selectContactsByCondition(map);
    }

    @Override
    public int queryContactsCountByCondition(Map<String, Object> map) {
        return contactsMapper.selectContactsCountByCondition(map);
    }

    /**
     * 根据id给修改模态窗口查询联系人信息
     * @param id
     * @return
     */
    @Override
    public Contacts queryContactsById(String id) {

        return contactsMapper.selectContactsById(id);
    }

    /**
     * 从修改联系人模态窗口更新联系人信息
     * @param contacts
     * @param user
     */
    @Override
    public void saveUpdateContactsById(Contacts contacts,User user) {
        //根据客户全名查询客户id,customerId：保存的客户全名
        Customer customer = customerMapper.selectCustomerByAllName(contacts.getCustomerId());
        if (customer==null){
            customer=new Customer();
            customer.setOwner(user.getId());
            customer.setName(contacts.getCustomerId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setCreateBy(user.getId());
            customer.setWebsite("");
            customer.setPhone("");

            customerMapper.insertCustomer(customer);
        }


        //封装参数
        //将客户id赋值给customerId
        contacts.setCustomerId(customer.getId());
        contacts.setEditBy(user.getId());
        contacts.setEditTime(DateUtils.formateDateTime(new Date()));
        //根据id修改联系人信息
        contactsMapper.updateContactsById(contacts);
    }

    /**
     * 根据id数组批量删除联系人以及联系人备注、联系人关联关系
     * @param ids
     * @return
     */
    @Override
    public void deleteContactsByIds(String[] ids) {
        //根据id数组批量删除联系人以及联系人备注、联系人市场活动关联关系
        contactsRemarkMapper.deleteCRbyContactsIds(ids);
        contactsActivityRelationMapper.deleteCARbyContactsIds(ids);
        contactsMapper.deleteContactsByIds(ids);
    }

    /**
     * 根据id查询联系人详细信息
     * @param id
     * @return
     */
    @Override
    public Contacts queryContactsForDetailById(String id) {
        return contactsMapper.selectContactsForDetailById(id);
    }

    /**
     * 根据名称模糊查询联系人列表
     * @param fullname
     * @return
     */
    @Override
    public List<Contacts> queryContactsByFullname(String fullname) {

        return contactsMapper.selectContactsByName(fullname);
    }


}
