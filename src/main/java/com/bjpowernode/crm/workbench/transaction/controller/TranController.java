package com.bjpowernode.crm.workbench.transaction.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.Funnel;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.pojo.ReturnObjectFunnel;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.dictionary.value.pojo.DicValue;
import com.bjpowernode.crm.settings.dictionary.value.service.DicValueService;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.activity.pojo.Activity;
import com.bjpowernode.crm.workbench.activity.service.ActicityService;
import com.bjpowernode.crm.workbench.clue.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.clue.pojo.Contacts;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import com.bjpowernode.crm.workbench.clue.pojo.TranHistory;
import com.bjpowernode.crm.workbench.clue.pojo.TranRemark;
import com.bjpowernode.crm.workbench.contacts.service.ContactsService;
import com.bjpowernode.crm.workbench.transaction.service.TranHistoryService;
import com.bjpowernode.crm.workbench.transaction.service.TranRemarkService;
import com.bjpowernode.crm.workbench.transaction.service.TranService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class TranController {

    @Resource
     private DicValueService dicValueService;
    @Resource
    private UserService userService;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private TranService tranService;
    @Resource
    private TranRemarkService tranRemarkService;
    @Resource
    private TranHistoryService tranHistoryService;
    @Resource
    private ActicityService acticityService;
    @Resource
    private ContactsService contactsService;




    @RequestMapping("/workbench/transaction/toIndex.do")
    public String toIndex(HttpServletRequest request){
        //调用dic_value表查询阶段、类型、来源
        List<DicValue> stageList = dicValueService.selectDicValueByTypeCode("stage");
        List<DicValue> tranTypeList = dicValueService.selectDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.selectDicValueByTypeCode("source");
        request.setAttribute("stageList",stageList);
        request.setAttribute("tranTypeList",tranTypeList);
        request.setAttribute("sourceList",sourceList);
        return "workbench/transaction/index";
    }

    @RequestMapping("/workbench/transaction/toSave.do")
    public String toSave(HttpServletRequest request,String customerName,String customerId,String contactsFullname,String contactsId){
        //调用User、dicValue层查询所有者、阶段、类型、来源
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.selectDicValueByTypeCode("stage");
        List<DicValue> tranTypeList = dicValueService.selectDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.selectDicValueByTypeCode("source");
        request.setAttribute("stageList",stageList);
        request.setAttribute("tranTypeList",tranTypeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("userList",userList);
        request.setAttribute("customerName",customerName);
        request.setAttribute("customerId",customerId);
        request.setAttribute("contactsFullname",contactsFullname);
        request.setAttribute("contactsId",contactsId);
        return "workbench/transaction/save";
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/tranPossibility.do")
    public Object tranPossibility(String stage){
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stage);
        return possibility;
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryCustomerByName.do")
    public Object queryCustomerByName(String name){
        //根据name模糊查询客户表信息
        List<String> nameList = customerMapper.selectCustomerByName(name);
        return nameList;
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/saveCreateTran.do")
    public Object saveCreateTran(@RequestParam Map<String,Object> map, HttpSession session){
        map.put(Contants.SESSION_USER,session.getAttribute(Contants.SESSION_USER));
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用tranService层，新建交易
            tranService.saveCreateTran(map);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/toTranDetail.do")
    public String toClueDetail(String tranId,HttpServletRequest request){
        //根据交易id查询交易明细
        Tran tran = tranService.queryTranForDetailById(tranId);
        //根据交易id查询交易下所有备注
        List<TranRemark> tranRemarkList = tranRemarkService.queryTranRemarkByTranId(tranId);
        //根据交易id查询交易下所有历史记录
        List<TranHistory> tranHistorieList = tranHistoryService.queryTranHistoryByTranId(tranId);
        //根据阶段id查询该线索的阶段value
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(tran.getStage());
        //查询交易有多少个阶段
        List<DicValue> stage = dicValueService.selectDicValueByTypeCode("stage");

        //将以上信息放入请求作用域中
        request.setAttribute("tran",tran);
        request.setAttribute("tranRemarkList",tranRemarkList);
        request.setAttribute("tranHistorieList",tranHistorieList);
        request.setAttribute("possibility",possibility);
        request.setAttribute("stage",stage);
        return "workbench/transaction/detail";

    }

    @RequestMapping("/workbench/transaction/toChartTran.do")
    public String toChartTran(){
        return "workbench/chart/transaction/index";
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryTranStage.do")
    public Object queryTranStage(){
        List<Funnel> funnelList = tranService.selectTranForFunnel();
        List<String> stringList= new ArrayList<String>();
        for (Funnel funnel:funnelList){
            stringList.add(funnel.getName());
        }
        ReturnObjectFunnel returnObjectFunnel = new ReturnObjectFunnel();
        returnObjectFunnel.setNameValue(funnelList);
        returnObjectFunnel.setName(stringList);

        return returnObjectFunnel;

    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryTranByCondition.do")
    public Object queryTranByCondition(@RequestParam Map<String,Object> map,Integer pageNo,Integer pageSize){
        map.put("pageNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //调tran的service层，根据条件模糊查询交易
        List<Tran> tranList = tranService.selectTranByCondition(map);
        //调tran的service层，根据条件模糊查询交易记录条数
        int totalRows = tranService.selectTranNumberByCondition(map);
        Map<String,Object> retMap=new HashMap<String, Object>();
        retMap.put("totalRows",totalRows);
        retMap.put("tranList",tranList);
        return retMap;

    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryActivityByName.do")
    public Object queryActivityByName(String name){
        //调用市场活动service层，根据名称模糊查询市场活动
        List<Activity> activityList = acticityService.queryActivityByName(name);
        return activityList;
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryContactsByFullname.do")
    public Object queryContactsByFullname(String fullname){
        //调用联系人service层根据名称模糊查询联系人
        List<Contacts> contactsList = contactsService.queryContactsByFullname(fullname);
        return contactsList;

    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/deleteTranByIds.do")
    public Object deleteTranByIds(String[] id){
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用交易service层，根据ids批量删除交易
            tranService.deleteTranByIds(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/queryTranById.do")
    public String queryTranById(String id,HttpServletRequest request){

            //调用交易service层，根据id查询交易详细信息
            Tran tran = tranService.queryTranForDetailById(id);
        //调用User、dicValue层查询所有者、阶段、类型、来源
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.selectDicValueByTypeCode("stage");
        List<DicValue> tranTypeList = dicValueService.selectDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.selectDicValueByTypeCode("source");
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String  possibility = bundle.getString(tran.getStage());
        tran.setPossibility(possibility);
        request.setAttribute("stageList",stageList);
        request.setAttribute("tranTypeList",tranTypeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("userList",userList);
            request.setAttribute("tran",tran);
              return "workbench/transaction/edit";

    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/saveUpdateTranById.do")
    public Object saveUpdateTranById(@RequestParam Map<String,Object> map,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
       map.put("user",user);
       map.put("editBy",user.getId());
       map.put("editTime",DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用交易service层，根据id修改交易
              tranService.saveUpdateTranById(map);
              returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }

        return returnObject;
    }
    @ResponseBody
    @RequestMapping("/workbench/transaction/createTranRemark.do")
    public Object createTranRemark(TranRemark tranRemark,HttpSession session){
        User user=(User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        tranRemark.setEditFlag("0");
        tranRemark.setCreateBy(user.getId());
        tranRemark.setId(UUIDUtils.getUUID());
        tranRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject=new ReturnObject();
        try{
            //调用交易备注service层，从交易明细页面创建交易备注
            int count = tranRemarkService.saveInsertTranRemark(tranRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(tranRemark);
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
    @RequestMapping("/workbench/transaction/deleteTranRemarkById.do")
    public Object deleteTranRemarkById(String id){
        ReturnObject returnObject=new ReturnObject();
        try{
            //调用交易备注层，根据id删除交易备注
            int count = tranRemarkService.deleteTranRemarkById(id);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.ACTIVITY_REMARK_EDIT_FLAG_NO_ENITED);
                returnObject.setMessage("系统忙，请稍后重试...");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.ACTIVITY_REMARK_EDIT_FLAG_NO_ENITED);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/updateTranRemarkById.do")
    public Object updateTranRemarkById(TranRemark tranRemark,HttpSession session){
        User user=(User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject=new ReturnObject();
        //封装参数
        tranRemark.setEditBy(user.getId());
        tranRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        tranRemark.setEditFlag("1");
        try {
            //调用交易备注service层，根据id修改交易备注
            int count = tranRemarkService.saveUpdateTranRemarkById(tranRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(tranRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }

        }catch(Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

}
