package com.bjpowernode.crm.workbench.customer.service;

import com.bjpowernode.crm.workbench.clue.pojo.CustomerRemark;

import java.util.List;

public interface CustomerRemarkService {
    List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId);
    int saveCreateCustomerRemark(CustomerRemark customerRemark);
    int deleteCustomerRemarkById(String id);

    int saveUpdateCustomerRemark(CustomerRemark customerRemark);
}
