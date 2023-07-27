package com.bjpowernode.crm.workbench.customer.service.CustomerServiceImpl;

import com.bjpowernode.crm.workbench.clue.mapper.CustomerRemarkMapper;
import com.bjpowernode.crm.workbench.clue.pojo.CustomerRemark;
import com.bjpowernode.crm.workbench.customer.service.CustomerRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class CustomerRemarkServiceImpl implements CustomerRemarkService {
    @Resource
    private CustomerRemarkMapper customerRemarkMapper;
    @Override
    public List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId) {
        return customerRemarkMapper.queryCustomerRemarkByCustomerId(customerId);
    }

    @Override
    public int saveCreateCustomerRemark(CustomerRemark customerRemark) {

        return customerRemarkMapper.insertCustomerRemark(customerRemark);
    }

    @Override
    public int deleteCustomerRemarkById(String id) {
        return customerRemarkMapper.deleteCustomerRemarkById(id);
    }

    @Override
    public int saveUpdateCustomerRemark(CustomerRemark customerRemark) {
        return customerRemarkMapper.updateCustomerRemark(customerRemark);
    }
}
