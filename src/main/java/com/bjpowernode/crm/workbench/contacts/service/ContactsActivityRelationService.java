package com.bjpowernode.crm.workbench.contacts.service;

import com.bjpowernode.crm.workbench.clue.pojo.ContactsActivityRelation;

import java.util.List;

public interface ContactsActivityRelationService {
    /**
     * 在联系人明细页面批量关联市场活动
     * @param contactsActivityRelationList
     * @return
     */
    int saveCreateCarFromContactsDetail(List<ContactsActivityRelation> contactsActivityRelationList);

    /**
     * 从联系人明细页面根据市场活动id和联系人id删除关联关系
     * @param car
     * @return
     */
    int deleteCarFromContactsDetailByActivityIdContactsId(ContactsActivityRelation car);
}
