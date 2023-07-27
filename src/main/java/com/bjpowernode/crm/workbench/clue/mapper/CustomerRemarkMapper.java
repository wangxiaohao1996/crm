package com.bjpowernode.crm.workbench.clue.mapper;

import com.bjpowernode.crm.workbench.clue.pojo.CustomerRemark;

import java.util.List;

public interface CustomerRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    int insert(CustomerRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    int insertSelective(CustomerRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    CustomerRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    int updateByPrimaryKeySelective(CustomerRemark row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbg.generated Mon Jul 17 16:15:02 CST 2023
     */
    int updateByPrimaryKey(CustomerRemark row);

    /**
     * 将线索备注的表转换成客户备注的表
     * @param customerRemarkList
     * @return
     */
    int insetCustomerRemarkFromClueRemarkByList(List<CustomerRemark> customerRemarkList);

    /**
     * 根据客户id查询该客户下的备注信息
     * @param customerId
     * @return
     */
    List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId);

    /**
     * 创建客户备注
     * @param customerRemark
     * @return
     */
    int insertCustomerRemark(CustomerRemark customerRemark);

    /**
     * 根据id删除客户备注
     * @param id
     * @return
     */
    int deleteCustomerRemarkById(String id);

    /**
     * 修改客户备注
     * @param customerRemark
     * @return
     */
    int updateCustomerRemark(CustomerRemark customerRemark);

    /**
     * 根据客户id数组，批量删除客户备注
     * @param customerIds
     * @return
     */
    int deleteCustomerRemarkByCustomerIds(String[] customerIds);
}