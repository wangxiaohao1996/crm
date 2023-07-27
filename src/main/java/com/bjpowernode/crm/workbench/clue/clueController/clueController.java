package com.bjpowernode.crm.workbench.clue.clueController;

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
import com.bjpowernode.crm.workbench.clue.pojo.Clue;
import com.bjpowernode.crm.workbench.clue.pojo.ClueActivityRelation;
import com.bjpowernode.crm.workbench.clue.pojo.ClueRemark;
import com.bjpowernode.crm.workbench.clue.service.ClueActivityRelationService;
import com.bjpowernode.crm.workbench.clue.service.ClueRemarkService;
import com.bjpowernode.crm.workbench.clue.service.ClueService;
import com.sun.org.apache.xpath.internal.operations.Neg;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class clueController {
    @Resource
    private UserService userService;
    @Resource
    private DicValueService dicValueService;
    @Resource
    private ClueService clueService;
    @Resource
    private ActicityService acticityService;
    @Resource
    private ClueRemarkService clueRemarkService;
    @Resource
    private ClueActivityRelationService clueActivityRelationService;
    @RequestMapping("/workbench/clue/toClueIndex.do")
    public String toClueIndex(HttpServletRequest request){
        //查询所有的user
      List<User> users = userService.queryAllUsers();
      //查询所有的称呼appellation
        List<DicValue> appellation = dicValueService.selectDicValueByTypeCode("appellation");
        //查询所有的线索状态clueState
        List<DicValue> clueState = dicValueService.selectDicValueByTypeCode("clueState");
        //查询所有的线索来源source
        List<DicValue> source = dicValueService.selectDicValueByTypeCode("source");
        request.setAttribute("usersList",users);
        request.setAttribute("appellationList",appellation);
        request.setAttribute("clueStateList",clueState);
        request.setAttribute("sourceList",source);
        return "workbench/clue/index";
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/saveCreateClue.do")
    public Object saveCreateClue(Clue clue, HttpSession session){
       User user = (User) session.getAttribute(Contants.SESSION_USER);
       //封装参数
       clue.setId(UUIDUtils.getUUID());
       clue.setCreateTime(DateUtils.formateDateTime(new Date()));
       clue.setCreateBy(user.getId());
        ReturnObject returnObject = new ReturnObject();
       try {
           //调用service层，创建线索
           int ret = clueService.saveCreateClue(clue);
           if (ret>0){
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
           }else {
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
               returnObject.setMessage("系统忙，稍后重试...");
           }

       }catch (Exception e){
           e.printStackTrace();
           returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
           returnObject.setMessage("系统忙，稍后重试...");
       }
       return returnObject;
    }

    @RequestMapping("/workbench/clue/toClueDetail.do")
    public String toClueDetail(String clueId,HttpServletRequest request){
        //调用线索service，查询线索信息
        Clue clue = clueService.queryClueForDetailById(clueId);
        //调用线索备注service,查询线索的所有备注
        List<ClueRemark> clueRemarkList = clueRemarkService.queryClueRemarkForDetailByClueId(clueId);
        //调用市场活动service,查询线索关联的所有市场活动
        List<Activity> activitieList = acticityService.queryActivityForClueDetailByClueId(clueId);
        //将线索明细信息放入请求作用域中
        request.setAttribute("clue",clue);
        request.setAttribute("clueRemarkList",clueRemarkList);
        request.setAttribute("activitieList",activitieList);
        //请求转发到线索明细页面
        return "workbench/clue/detail";
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/saveCreateClueActivityRelationByClueIdActivityId.do")
    public Object saveCreateClueActivityRelationByClueIdActivityId(String[] activityId,String clueId){
        List<ClueActivityRelation> clueActivityRelationList = new ArrayList<ClueActivityRelation>();
        //封装参数
        ClueActivityRelation clueActivityRelation=null;
        for (String id:activityId){
            clueActivityRelation= new ClueActivityRelation();
            clueActivityRelation.setId(UUIDUtils.getUUID());
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setActivityId(id);
            //每封装一个对象，就向集合中放一个对象
            clueActivityRelationList.add(clueActivityRelation);
        }
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用线索市场活动关联关系service层，根据线索id和市场活动id批量创建关联关系
            int ret = clueActivityRelationService.saveCreateClueActivityRelationByClueIdActivityId(clueActivityRelationList);
            if (ret>0){
                //关联成功，则查询刚刚关联成功的所有市场活动
                List<Activity> activities = acticityService.queryActivityByActivityIds(activityId);
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(activities);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，稍后重试...");
        }
        return returnObject;
    }


    @ResponseBody
    @RequestMapping("/workbench/clue/deleteClueActivityRelationByClueIdActivityId.do")
    public Object deleteClueActivityRelationByClueIdActivityId(String clueId,String activityId){
        //封装参数
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("clueId",clueId);
        map.put("activityId",activityId);
        ReturnObject returnObject= new ReturnObject();
       try {
           //调用线索和市场活动关联关系service层，根据线索id和市场活动id删除线索和市场活动关联关系
           int ret = clueActivityRelationService.deleteClueActivityRelationByClueIdActivityId(map);
           if (ret>0){
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
           }else {
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
               returnObject.setMessage("系统忙，稍后重试...");
           }
        }catch (Exception e){
           e.printStackTrace();
           returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
           returnObject.setMessage("系统忙，稍后重试...");
       }
       return returnObject;
    }


    @RequestMapping("/workbench/clue/toConvert.do")
    public String toConvert(String id,HttpServletRequest request){
        //根据线索id查询线索详细信息
        Clue clue = clueService.queryClueForDetailById(id);
        //根据
        List<DicValue> stageList = dicValueService.selectDicValueByTypeCode("stage");
        request.setAttribute("clue",clue);
        request.setAttribute("stageList",stageList);
        return "workbench/clue/convert";
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/queryActivityByNameClueId.do")
    public Object queryActivityByNameClueId(String clueId,String name){
        //封装参数
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("clueId",clueId);
        map.put("name",name);
        //调用市场活动service，根据市场活动名称和clueId模糊查询与该线索关联的市场活动
        List<Activity> activitieList = acticityService.queryActivityByNameClueId(map);
        return activitieList;
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/ClueConvert.do")
    public Object ClueConvert(String clueId,String createTransaction,String money,String name,String expectedDate,String stage,String acticityId,HttpSession session ){

        Map<String,Object> map = new HashMap<String, Object>();
        map.put("clueId",clueId);
        map.put("createTransaction",createTransaction);
        map.put("money",money);
        map.put("name",name);
        map.put("expectedDate",expectedDate);
        map.put("stage",stage);
        map.put("acticityId",acticityId);
        map.put(Contants.SESSION_USER, session.getAttribute(Contants.SESSION_USER));
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用线索service层，完成线索转换
            clueService.saveClueConvert(map);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;

    }

    @ResponseBody
    @RequestMapping("/workbench/clue/queryClueByCondition.do")
    public Object queryClueByCondition(String fullname,String company,String phone,String mphone,String owner,String source,String state,Integer pageNo,Integer pageSize){
       //封装参数
        pageNo=(pageNo-1)*pageSize;
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("fullname",fullname);
        map.put("company",company);
        map.put("phone",phone);
        map.put("mphone",mphone);
        map.put("owner",owner);
        map.put("source",source);
        map.put("state",state);
        map.put("pageNo",pageNo);
        map.put("pageSize",pageSize);
        //调用线索service层,根据条件查询线索
        List<Clue> clueList = clueService.queryClueByCondition(map);
        //调用线索service层，根据条件查询记录条数
        int totalRows = clueService.queryClueCountByCondition(map);
        Map<String,Object> retMap = new HashMap<String, Object>();
        retMap.put("clueList",clueList);
        retMap.put("totalRows",totalRows);
        return retMap;
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/saveClueRemark.do")
    public Object saveClueRemark(String noteContent,String clueId,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装参数
        ClueRemark clueRemark = new ClueRemark();
        clueRemark.setId(UUIDUtils.getUUID());
        clueRemark.setCreateBy(user.getId());
        clueRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        clueRemark.setEditFlag("0");
        clueRemark.setClueId(clueId);
        clueRemark.setNoteContent(noteContent);
        ReturnObject returnObject= new ReturnObject();
         try {
             int count = clueRemarkService.saveCreateClueRemark(clueRemark);
             if (count>0){
                 returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                 returnObject.setRetData(clueRemark);
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
    @RequestMapping("/workbench/clue/deleteClueRemark.do")
    public Object deleteClueRemark(String clueRemarkId){
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用线索备注service删除线索备注
            int count = clueRemarkService.deleteClueRemarkByRemarkId(clueRemarkId);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
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
    @RequestMapping("/workbench/clue/deleteCuleByIds.do")
    public Object deleteCuleByIds(String[] id){
        ReturnObject returnObject=new ReturnObject();
        try {
            //根据线索id数组批量删除线索、线索下的备注，线索和市场活动的关联关系
            clueService.deleteClueByIds(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/clue/queryClueById.do")
   public Object queryClueById(String id){
        //调用线索service层，根据id查询线索
        Clue clue = clueService.queryClueForDetailById(id);
        return clue;

    }



    @ResponseBody
    @RequestMapping("/workbench/clue/updateClueById.do")
    public Object updateClueById(Clue clue,HttpSession session){
        User user=(User)session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject=new ReturnObject();
        //封装参数
        clue.setEditBy(user.getId());
        clue.setEditTime(DateUtils.formateDateTime(new Date()));
        try {
            //根据线索Id修改线索
            int cunt = clueService.saveUpdateClueById(clue);
            if (cunt>0){
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
    @RequestMapping("/workbench/clue/updateClueRemakrById.do")
    public Object updateClueRemakrById(ClueRemark clueRemark,HttpSession session){
        User user=(User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject=new ReturnObject();
        //封装参数
        clueRemark.setEditBy(user.getId());
        clueRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        clueRemark.setEditFlag("1");
        try {
            //根据id删除线索备注
            int count = clueRemarkService.saveUpdateClueRemarkById(clueRemark);
            if (count>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(clueRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return returnObject;
    }
}
