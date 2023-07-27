package com.bjpowernode.crm.workbench.clue.mapper;

import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;

import java.util.List;

public interface ContactsRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    int insert(ContactsRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    int insertSelective(ContactsRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    ContactsRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    int updateByPrimaryKeySelective(ContactsRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbg.generated Mon Jul 17 16:31:45 CST 2023
     */
    int updateByPrimaryKey(ContactsRemark row);

    /**
     * 将线索备注转换成联系人备注
     * @param contactsRemarkList
     * @return
     */
    int insertContactsRemarkFromClueRemarkByList(List<ContactsRemark> contactsRemarkList);

    /**
     * 根据联系人id查询该联系人下的所有备注
     * @param contactsId
     * @return
     */
    List<ContactsRemark> selectContactsRemarkForDetailByContactsId(String contactsId);

    /**
     * 从联系人页面创建联系人备注
     * @param contactsRemark
     * @return
     */
    int insertContactsRemarkFromContactsDetail(ContactsRemark contactsRemark);

    /**
     * 根据id删除联系人备注
     * @param id
     * @return
     */
    int deleteContactsRemarkFromContactsDetail(String id);

    /**
     * 根据id修改联系人备注
     * @param contactsRemark
     * @return
     */
    int updateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark);

    /**
     * 根据联系人id数组批量删除联系人备注
     * @param ids
     * @return
     */
    int deleteCRbyContactsIds(String[] ids);
}