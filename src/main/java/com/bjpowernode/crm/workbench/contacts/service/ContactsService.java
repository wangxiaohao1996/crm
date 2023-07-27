package com.bjpowernode.crm.workbench.contacts.service;

import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    List<Contacts> queryContactsForCustomerDetailByCustomerId(String customerId);
    int saveCreateContacts(Contacts contacts);

    void saveCreateContactsFromCreate(Map<String,Object> map);

    /**
     * 根据条件模糊查询联系人列表
     * @param map
     * @return
     */
    List<Contacts> queryContactsByCondition(Map<String,Object> map);

    /**
     * 根据条件模糊查询联系人记录条数
     * @param map
     * @return
     */
    int queryContactsCountByCondition(Map<String,Object> map);

    /**
     * 根据id给修改模态窗口查询联系人信息
     * @param id
     * @return
     */
    Contacts queryContactsById(String id);

    /**
     * 从修改联系人模态窗口更新联系人信息
     * @param contacts
     * @param user
     */
    void saveUpdateContactsById(Contacts contacts, User user);

    /**
     * 根据id数组批量删除联系人
     * @param ids
     * @return
     */
    void deleteContactsByIds(String[] ids);

    /**
     * 根据id查询联系人详细信息
     * @param id
     * @return
     */
    Contacts queryContactsForDetailById(String id);

    /**
     * 根据名称模糊查询联系人
     * @param fullname
     * @return
     */
    List<Contacts> queryContactsByFullname(String fullname);


}
