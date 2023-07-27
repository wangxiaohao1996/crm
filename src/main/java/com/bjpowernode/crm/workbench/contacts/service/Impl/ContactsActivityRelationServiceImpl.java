package com.bjpowernode.crm.workbench.contacts.service.Impl;

import com.bjpowernode.crm.workbench.clue.mapper.ContactsActivityRelationMapper;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsActivityRelation;
import com.bjpowernode.crm.workbench.contacts.service.ContactsActivityRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("contactsActivityRelationService")
public class ContactsActivityRelationServiceImpl implements ContactsActivityRelationService {
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    /**
     * 从联系人明细页面批量关联市场活动
     * @param contactsActivityRelationList
     * @return
     */
    @Override
    public int saveCreateCarFromContactsDetail(List<ContactsActivityRelation> contactsActivityRelationList) {
        return contactsActivityRelationMapper.insertcarFromContactsDetail(contactsActivityRelationList);
    }

    /**
     * 从联系人明细页面根据市场活动id和联系人id删除关联关系
     * @param car
     * @return
     */
    @Override
    public int deleteCarFromContactsDetailByActivityIdContactsId(ContactsActivityRelation car) {
        return contactsActivityRelationMapper.deleteCarFromContactsDetailByActivityContactsId(car);
    }
}
