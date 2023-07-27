package com.bjpowernode.crm.workbench.contacts.service.Impl;

import com.bjpowernode.crm.workbench.clue.mapper.ContactsRemarkMapper;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;
import com.bjpowernode.crm.workbench.contacts.service.ContactsRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ContactsRemarkServiceImpl implements ContactsRemarkService {
    @Resource
    private ContactsRemarkMapper contactsRemarkMapper;
    @Override
    public List<ContactsRemark> queryContactsRemarkForDetailByContactsId(String contactsId) {
        return contactsRemarkMapper.selectContactsRemarkForDetailByContactsId(contactsId);
    }

    /**
     * 保存从联系人明细页面创建的备注
     * @param contactsRemark
     * @return
     */
    @Override
    public int saveCreateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark) {

        return contactsRemarkMapper.insertContactsRemarkFromContactsDetail(contactsRemark);
    }

    /**
     * 根据id删除联系人备注
     * @param id
     * @return
     */
    @Override
    public int deleteContactsRemarkFromContactsDetail(String id) {
        return contactsRemarkMapper.deleteContactsRemarkFromContactsDetail(id);
    }

    /**
     * 根据id修改联系人备注
     * @param contactsRemark
     * @return
     */
    @Override
    public int saveUpdateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark) {
        return contactsRemarkMapper.updateContactsRemarkFromContactsDetail(contactsRemark);
    }
}
