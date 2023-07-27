package com.bjpowernode.crm.workbench.customer.service;

import com.bjpowernode.crm.workbench.clue.pojo.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    List<String> queryCustomerByName(String name);

    List<Customer> queryCustomerByCondition(Map<String,Object> map);
    int queryCustomerCountByCondition(Map<String,Object> map);

    int saveCreateCustomer(Customer customer);

    Customer queryCustomerById(String id);

    int saveUpdateCustomer(Customer customer);

    void deleteCustomerByIds(String[] ids);

    Customer queryCustomerForDetailById(String id);
}
