package com.bjpowernode.crm.workbench.customer.service.CustomerServiceImpl;

import com.bjpowernode.crm.workbench.clue.mapper.ContactsMapper;
import com.bjpowernode.crm.workbench.clue.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.clue.mapper.CustomerRemarkMapper;
import com.bjpowernode.crm.workbench.clue.mapper.TranMapper;
import com.bjpowernode.crm.workbench.clue.pojo.Customer;
import com.bjpowernode.crm.workbench.customer.service.CustomerService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service
public class CustomerServiceImpl implements CustomerService {
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private CustomerRemarkMapper customerRemarkMapper;
    @Resource
    private ContactsMapper contactsMapper;
    @Resource
    private TranMapper tranMapper;

    /**
     * 根据名称模糊查询客户记录
     * @param name
     * @return
     */
    @Override
    public List<String> queryCustomerByName(String name) {
        return customerMapper.selectCustomerByName(name);
    }

    /**
     * 根据条件模糊查询客户记录
     * @param map
     * @return
     */
    @Override
    public List<Customer> queryCustomerByCondition(Map<String, Object> map) {

        return customerMapper.selectCustomerByCondition(map);
    }

    /**
     * 根据条件模糊查询客户记录条数
     * @param map
     * @return
     */
    @Override
    public int queryCustomerCountByCondition(Map<String, Object> map) {
        return customerMapper.selectCustomerCountByCondition(map);
    }

    @Override
    public int saveCreateCustomer(Customer customer) {
        return customerMapper.insertCustomer(customer);
    }

    /**
     * 根据id查询客户信息
     * @param id
     * @return
     */
    @Override
    public Customer queryCustomerById(String id) {
        return customerMapper.selectCustomerById(id);
    }



    /**
     * 根据id修改客户信息
     * @param customer
     * @return
     */
    @Override
    public int saveUpdateCustomer(Customer customer) {
        return customerMapper.updateCustomer(customer);
    }

    /**
     * 根据客户id数组批量删除客户，以及客户备注、联系人
     * @param ids
     */
    @Override
    public void deleteCustomerByIds(String[] ids) {
        customerRemarkMapper.deleteCustomerRemarkByCustomerIds(ids);
        tranMapper.deleteTranByCustomerIds(ids);
        contactsMapper.deleteContactsByCustomerIds(ids);
        customerMapper.deleteCustomerByIds(ids);
    }

    @Override
    public Customer queryCustomerForDetailById(String id) {

        return customerMapper.selectCustomerForDetailById(id);
    }
}
