package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.dictionary.value.pojo.DicValue;
import com.bjpowernode.crm.settings.dictionary.value.service.DicValueService;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.activity.pojo.Activity;
import com.bjpowernode.crm.workbench.activity.service.ActicityService;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsActivityRelation;
import com.bjpowernode.crm.workbench.clue.pojo.ContactsRemark;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import com.bjpowernode.crm.workbench.contacts.service.ContactsActivityRelationService;
import com.bjpowernode.crm.workbench.contacts.service.ContactsRemarkService;
import com.bjpowernode.crm.workbench.contacts.service.ContactsService;
import com.bjpowernode.crm.workbench.customer.service.CustomerService;
import com.bjpowernode.crm.workbench.transaction.service.TranService;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class ContactsController {
    @Resource
    private UserService userService;
    @Resource
    private DicValueService dicValueService;
    @Resource
    private ContactsService contactsService;
    @Resource
    private ContactsRemarkService contactsRemarkService;
    @Resource
    private TranService tranService;
    @Resource
    private ActicityService acticityService;
    @Resource
    private ContactsActivityRelationService contactsActivityRelationService;



    @RequestMapping("/workbench/contacts/toIndex.do")
    public String toIndex(HttpServletRequest request){
        //查询所有的user
        List<User> userList = userService.queryAllUsers();
        //查询所有的来源
        List<DicValue> sourceList = dicValueService.selectDicValueByTypeCode("source");
        //查询所有的称呼
        List<DicValue> appellationList = dicValueService.selectDicValueByTypeCode("appellation");
        //将查询结果放入作用域中
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);
        return "workbench/contacts/index";

    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/createContacts.do")
    public Object createContacts(@RequestParam Map<String,Object> map, HttpSession session){
        map.put("user",session.getAttribute(Contants.SESSION_USER));
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用联系人service层查询客户是否存在，不存在则创建，往联系人表中新插入一条联系人信息
            contactsService.saveCreateContactsFromCreate(map);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/searchContactsByCondition.do")
     public Object searchContactsByCondition(String owner,String fullname,String customerName,String source,String birth,Integer pageNo,Integer pageSize){
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("owner",owner);
        map.put("fullname",fullname);
        map.put("customerName",customerName);
        map.put("source",source);
        map.put("birth",birth);
        map.put("pageNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //调用联系人service层根据条件模糊查询联系人列表
        List<Contacts> contactsList = contactsService.queryContactsByCondition(map);
        //调用联系人service层根据条件模糊查询联系人记录条数
        int totalRows = contactsService.queryContactsCountByCondition(map);
        Map<String,Object> retMap = new HashMap<String, Object>();
        retMap.put("contactsList",contactsList);
        retMap.put("totalRows",totalRows);
       return retMap;
    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/searchContactsForUpdateById.do")
    public Object searchContactsForUpdateById(String id){
        //根据id给修改模态窗口查询联系人信息
        Contacts contacts = contactsService.queryContactsById(id);
        return contacts;

    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/updateContactsById.do")
    public Object updateContactsById(Contacts contacts,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用联系人service层，根据客户全名查询客户id,如果查询不到，则创建客户，创建联系人
            contactsService.saveUpdateContactsById(contacts,user);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }

        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/deleteContactsByIds.do")
    public Object deleteContactsByIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用联系人service层，根据id批量删除联系人
            contactsService.deleteContactsByIds(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }

        return returnObject;
    }

    @RequestMapping("/workbench/contacts/toContactsDetail.do")
    public String toContactsDetail(String contactsId,HttpServletRequest request){
        //调联系人service层根据id查询联系人详细信息
        Contacts contacts = contactsService.queryContactsForDetailById(contactsId);
        //调用联系人备注service层，根据联系人id查询该联系人下的所有备注
        List<ContactsRemark> contactsRemarkList = contactsRemarkService.queryContactsRemarkForDetailByContactsId(contactsId);
        //调用交易service层，根据联系人id查询该联系人有关的交易
        List<Tran> tranList = tranService.queryTranForContactsDetailByConstactsId(contactsId);
        //查询交易阶段可能性
        if (tranList!=null&&tranList.size()>0){
            ResourceBundle bundle = ResourceBundle.getBundle("possibility");
            String possibility=null;
            for (Tran tran:tranList){
                 possibility = bundle.getString(tran.getStage());
                 tran.setPossibility(possibility);
            }
        }
        //调用市场活动service层，根据联系人id查询该联系人有关的交易
        List<Activity> activityList = acticityService.queryActivityForContactsDetailByContactsId(contactsId);
        //查询所有的user
        List<User> userList = userService.queryAllUsers();
        //查询所有的来源
        List<DicValue> sourceList = dicValueService.selectDicValueByTypeCode("source");
        //查询所有的称呼
        List<DicValue> appellationList = dicValueService.selectDicValueByTypeCode("appellation");

        //将查询结果放入作用域中
        request.setAttribute("contacts",contacts);
        request.setAttribute("contactsRemarkList",contactsRemarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("activityList",activityList);
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);
        //转发到联系人明细页面
        return "workbench/contacts/detail";
    }

    @ResponseBody
    @RequestMapping("/workbench/contacts/createContactsRemarkFromContactsDetail.do")
    public Object createContactsRemarkFromContactsDetail(ContactsRemark contactsRemark,HttpSession session){
       User user =(User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        contactsRemark.setCreateBy(user.getId());
        contactsRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        contactsRemark.setEditFlag("0");
        contactsRemark.setId(UUIDUtils.getUUID());
        ReturnObject returnObject = new ReturnObject();

       try {
           //调用联系人备注service层，创建联系人备注
           int count = contactsRemarkService.saveCreateContactsRemarkFromContactsDetail(contactsRemark);
           if (count>0){
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
               returnObject.setRetData(contactsRemark);
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
    @RequestMapping("/workbench/contacts/deleteContactsRemarkFromContactsDetail.do")
    public Object deleteContactsRemarkFromContactsDetail(String id){
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用联系人备注service根据id删除联系人备注
            int count = contactsRemarkService.deleteContactsRemarkFromContactsDetail(id);
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
    @RequestMapping("/workbench/contacts/updateContactsRemarkFromContactsDetail.do")
    public Object updateContactsRemarkFromContactsDetail(ContactsRemark contactsRemark,HttpSession session){
        User user =(User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        contactsRemark.setEditBy(user.getId());
        contactsRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        contactsRemark.setEditFlag("1");
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用联系人备注service,根据id修改联系人备注
            int count = contactsRemarkService.saveUpdateContactsRemarkFromContactsDetail(contactsRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(contactsRemark);
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
    @RequestMapping("/workbench/contacts/relationContactsActivity.do")
    public Object relationContactsActivity(String[] activityId,String contactsId){
        List<ContactsActivityRelation> carList = new ArrayList<ContactsActivityRelation>();
        ContactsActivityRelation contactsActivityRelation=null;
        for (String id:activityId){
            contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setActivityId(id);
            contactsActivityRelation.setContactsId(contactsId);
            contactsActivityRelation.setId(UUIDUtils.getUUID());
            carList.add(contactsActivityRelation);
        }
        ReturnObject returnObject=new ReturnObject();
        //根据ids查询市场活动
        List<Activity> activityList = acticityService.queryActivityByActivityIds(activityId);
        try {
            //从联系人明细页面批量关联市场活动
            int count = contactsActivityRelationService.saveCreateCarFromContactsDetail(carList);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(activityList);
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
    @RequestMapping("/workbench/contacts/deleteContactsActivityRelationFromDetail.do")
    public Object deleteContactsActivityRelationFromDetail(ContactsActivityRelation contactsActivityRelation){
        ReturnObject returnObject=new ReturnObject();
        try {
            //从联系人明细页面根据市场活动id和联系人id删除关联关系
            int count = contactsActivityRelationService.deleteCarFromContactsDetailByActivityIdContactsId(contactsActivityRelation);
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
    @RequestMapping("/workbench/contacts/deleteTranFromContactsDetailById.do")
    public Object deleteTranFromContactsDetailById(String[] id){
        ReturnObject returnObject= new ReturnObject();
        try {
            //从联系人明细页面删除交易、交易备注、交易阶段历史记录
            tranService.deleteTranByIds(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }
}
