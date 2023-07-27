package com.bjpowernode.crm.workbench.contacts.service;

import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;

import java.util.List;

public interface ContactsRemarkService {
    /**
     * 根据联系人id查询该联系人下的所有备注
     * @param contactsId
     * @return
     */
    List<ContactsRemark> queryContactsRemarkForDetailByContactsId(String contactsId);

    /**
     * 保存从联系人明细页面创建的备注
     * @param contactsRemark
     * @return
     */
    int saveCreateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark);

    /**
     * 根据id删除联系人备注信息
     * @param id
     * @return
     */
    int deleteContactsRemarkFromContactsDetail(String id);

    /**
     * 根据id修改联系人备注
     * @param contactsRemark
     * @return
     */
    int saveUpdateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark);
}
