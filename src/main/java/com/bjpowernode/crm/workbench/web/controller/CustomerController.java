package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.Customer;
import com.bjpowernode.crm.workbench.clue.pojo.CustomerRemark;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import com.bjpowernode.crm.workbench.contacts.service.ContactsService;
import com.bjpowernode.crm.workbench.customer.service.CustomerRemarkService;
import com.bjpowernode.crm.workbench.customer.service.CustomerService;
import com.bjpowernode.crm.workbench.transaction.service.TranService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class CustomerController {
    @Resource
    private UserService userService;
    @Resource
    private CustomerService customerService;
    @Resource
    private CustomerRemarkService customerRemarkService;
    @Resource
    private TranService tranService;
    @Resource
    private ContactsService contactsService;
    @RequestMapping("/workbench/customer/toIndex.do")
    public String toIndex(HttpServletRequest request){
        //查询所有的所有者
        List<User> userList = userService.queryAllUsers();
        request.setAttribute("userList",userList);
        return "workbench/customer/index";
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/queryCustomerByCondition.do")
    public Object queryCustomerByCondition(String name,String owner,String phone,String website,Integer pageNo,Integer pageSize){
        //封装参数
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("pageNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //根据条件模糊查询客户信息
        List<Customer> customerList = customerService.queryCustomerByCondition(map);
        //根据条件模糊查询客户记录条数
        int totalRows = customerService.queryCustomerCountByCondition(map);
        Map<String,Object> retMap = new HashMap<String, Object>();
        retMap.put("customerList",customerList);
        retMap.put("totalRows",totalRows);
        return retMap;
    }


    @ResponseBody
    @RequestMapping("/workbench/customer/saveCreateCustomer.do")
    public Object saveCreateCustomer(Customer customer, HttpSession session){
        User user = (User)session.getAttribute(Contants.SESSION_USER);
        //封装参数
        customer.setId(UUIDUtils.getUUID());
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            //创建客户
            int count = customerService.saveCreateCustomer(customer);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
       return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/queryCustomerById.do")
    public Object queryCustomerById(String id){
        //根据id查询客户信息
        Customer customer = customerService.queryCustomerById(id);
        return customer;
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/saveUpdateCustomer.do")
    public Object saveUpdateCustomer(Customer customer,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        customer.setEditBy(user.getId());
        customer.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            //保存修改的客户信息
            int count = customerService.saveUpdateCustomer(customer);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;

    }

    @ResponseBody
    @RequestMapping("/workbench/customer/deleteCustomerByIds.do")
    public Object deleteCustomerByIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            //批量删除客户信息
            customerService.deleteCustomerByIds(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/toCustomerDetail.do")
    public String toCustomerDetail(String customerId,HttpServletRequest request){
        //查询客户信息
        Customer customer = customerService.queryCustomerForDetailById(customerId);
        //查询客户备注信息
        List<CustomerRemark> customerRemarkList = customerRemarkService.queryCustomerRemarkByCustomerId(customerId);
        //查询客户有关的交易
        List<Tran> tranList = tranService.queryTranForCustomerDetailByCustomerId(customerId);
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");

        if (tranList!=null&&tranList.size()>0){
            String possibility = null;
            for (Tran tran:tranList){
                //查询该交易阶段的可能性
                 possibility = bundle.getString(tran.getStage());
                 tran.setPossibility(possibility);
            }
        }

        //查询客户有关的联系人
        List<Contacts> contactsList = contactsService.queryContactsForCustomerDetailByCustomerId(customerId);


        //将以上查询信息放入作用域中
        request.setAttribute("customer",customer);
        request.setAttribute("customerRemarkList",customerRemarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("contactsList",contactsList);

        return "workbench/customer/detail";
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/createCustomerRemark.do")
     public Object createCustomerRemark(CustomerRemark customerRemark,HttpSession session){
       User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        customerRemark.setEditFlag("0");
        customerRemark.setId(UUIDUtils.getUUID());
        customerRemark.setCreateBy(user.getId());
        customerRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            //创建客户备注
            int count = customerRemarkService.saveCreateCustomerRemark(customerRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(customerRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/deleteCustomerRemarkById.do")
    public Object deleteCustomerRemarkById(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id删除客户备注
            int count = customerRemarkService.deleteCustomerRemarkById(id);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/customer/updateCustomerRemark.do")
    public Object updateCustomerRemark(CustomerRemark customerRemark,HttpSession session){
        User user =(User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        customerRemark.setEditFlag("1");
        customerRemark.setEditBy(user.getId());
        customerRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject= new ReturnObject();
        try {
            //修改客户备注
            int count = customerRemarkService.saveUpdateCustomerRemark(customerRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                //修改成功，手动更新页面那条备注信息，所有返回备注信息
                returnObject.setRetData(customerRemark);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }
    @ResponseBody
    @RequestMapping("/workbench/customer/deleteTranFromCustomerDetail.do")
    public Object deleteTranFromCustomerDetail(String[] tranId){
        ReturnObject returnObject=new ReturnObject();
        try {
            //根据交易id删除交易、交易备注、交易历史记录
            tranService.deleteTranByIds(tranId);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    };

}
