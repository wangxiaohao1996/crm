package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.HSSFUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.activity.pojo.Activity;
import com.bjpowernode.crm.workbench.activity.pojo.ActivityRemark;
import com.bjpowernode.crm.workbench.activity.service.ActicityService;
import com.bjpowernode.crm.workbench.activity.service.ActivityRemarkService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;

@Controller
public class ActivityController {
    @Resource
    private ActicityService acticityService;
    @Resource
    private UserService userService;
     @Resource
    private ActivityRemarkService activityRemarkService;
    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request){
        //调用service层，查询并返回符合条件的用户
        List<User> userList = userService.queryAllUsers();
        request.setAttribute("userList",userList);
        return "workbench/activity/index";
    }
    @ResponseBody
    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    public Object saveCreateActivity(Activity activity, HttpSession session){
        //1.获取uuid，并存入activity
        activity.setId(UUIDUtils.getUUID());
        //2.获取创建时间，并存入activity
        activity.setCreateTime(DateUtils.formateDateTime(new Date()));
        //3.获取创建人id，并存入activity
        User user= (User) session.getAttribute(Contants.SESSION_USER);
        activity.setCreateBy(user.getId());
        //创建ReturnObject，存数据并以json格式响应给浏览器
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service层，向数据库市场活动表中插入数据
            int i = acticityService.saveCreateActivity(activity);
            if (i==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统忙，请稍后重试....");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统忙，请稍后重试....");
        }

        return returnObject;
    }
    @ResponseBody
    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    public Object queryActivityByConditionForPage(String name,String owner,String startDate,String endDate,int pageNo,int pageSize){
        //封装参数
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("pageNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //调用service层方法，生成响应信息
        List<Activity> activities = acticityService.queryActivityByConditionForPage(map);
        int totalRows = acticityService.queryCountOfActivityByCondition(map);
        //根据查询结果，生成响应信息
        Map<String,Object> retMap = new HashMap<String,Object>();
        retMap.put("activityList",activities);
        retMap.put("totalRows",totalRows);
        System.out.println(retMap);
        return retMap;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/delectActivityByIds.do")
    public Object delectActivityByIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service层方法，根据id删除市场活动信息
                acticityService.deleteActivityByIds(id);
                //没有报错，就算是删除成功
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请稍后再试...");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/queryActivityById.do")
    public Object queryActivityById(String id){
        //调用service层，根据id查询市场活动信息
        Activity activity = acticityService.queryActivityById(id);
        return activity;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/editActivityById.do")
    public Object editActivityById(Activity activity,HttpSession session){
        //封装参数
        //从session里边获取正在登录的用户，其就是操作修改信息的人
       User user = (User) session.getAttribute(Contants.SESSION_USER);
       activity.setEditBy(user.getId());
       //获取当前时间，并封装参数
        activity.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
       try {
           //调用service层，根据id修改市场活动表
           int editCount = acticityService.editActivityById(activity);
           if (editCount==1){
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
           }else {
               returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
               returnObject.setMessage("系统繁忙，请稍后重试...");
           }
       }catch (Exception e){
           e.printStackTrace();
           returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
           returnObject.setMessage("系统繁忙，请稍后重试...");
       }
       return returnObject;
    }

    @RequestMapping("/workbench/activity/queryAllActivitys.do")
    public void queryAllActivitys(HttpServletResponse response)throws Exception{
        //调用service层，查询所有的市场活动
        List<Activity> activities = acticityService.queryAllActivitys();
        //创建excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        //创建页
        HSSFSheet sheet = wb.createSheet("市场活动表");
        //创建第一行
        HSSFRow row = sheet.createRow(0);
        //创建第一行的第一列
        HSSFCell cell = row.createCell(0);
        //给第一行的第一列赋值
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        if (activities!=null || activities.size()>0){
            Activity activity = null;
            for (int i=0;i<activities.size();i++){
                activity=activities.get(i);
                //创建第i+1行
                row = sheet.createRow(i+1);
                //创建第i+1行的第一列
                cell = row.createCell(0);
                //给第i+1行的第一列赋值
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }

        //设置响应类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //浏览器接收到响应信息之后，默认情况下，直接在显示窗口打开响应信息：即使打不开，也会调用应用程序打开，只有实在打不开，才会激活文件下载窗口
        //可以设置响应头信息，使浏览器接收到响应信息之后，直接激活文件下载窗口，即使能打开也不打开。
        response.addHeader("Content-Disposition","attachment;filename=acitvityList.xls");
       OutputStream os = response.getOutputStream();
       wb.write(os);
       wb.close();
       os.flush();

    }


    @RequestMapping("/workbench/activity/queryActivityByIds.do")
    public void queryActivityByIds(String[] id,HttpServletResponse response) throws Exception{
        //调用service层，根据ids数组查询市场活动
        List<Activity> activities = acticityService.queryActivityByIds(id);
        //创建excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        //创建页
        HSSFSheet sheet = wb.createSheet("市场活动表");
        //创建第一行
        HSSFRow row = sheet.createRow(0);
        //创建第一行的第一列
        HSSFCell cell = row.createCell(0);
        //给第一行的第一列赋值
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        if (activities!=null || activities.size()>0){
            Activity activity = null;
            for (int i=0;i<activities.size();i++){
                activity=activities.get(i);
                //创建第i+1行
                row = sheet.createRow(i+1);
                //创建第i+1行的第一列
                cell = row.createCell(0);
                //给第i+1行的第一列赋值
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }

        //设置响应类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //浏览器接收到响应信息之后，默认情况下，直接在显示窗口打开响应信息：即使打不开，也会调用应用程序打开，只有实在打不开，才会激活文件下载窗口
        //可以设置响应头信息，使浏览器接收到响应信息之后，直接激活文件下载窗口，即使能打开也不打开。
        response.addHeader("Content-Disposition","attachment;filename=acitvityListById.xls");
        OutputStream os = response.getOutputStream();
        wb.write(os);
        wb.close();
        os.flush();
    }


    @ResponseBody
    @RequestMapping("/workbench/activity/saveInsertActivityByFile.do")
    public Object saveInsertActivityByFile(MultipartFile multipartFile,HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        try {
            InputStream inputStream = multipartFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(inputStream);
            //根据excel文件获取第一页
            HSSFSheet sheet = wb.getSheetAt(0);
            HSSFRow row=null;
            HSSFCell cell=null;
            Activity activity=null;
            String cellValue = "";
            List<Activity> activitieList = new ArrayList<Activity>();
            //获取页的每一行
            for (int i=1;i<=sheet.getLastRowNum();i++){//getLastRowNum()最后一行的下标
                row = sheet.getRow(i);
                //每一行创建一个市场活动对象
                activity = new Activity();
                //封装参数
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateBy(user.getId());
                activity.setCreateTime(DateUtils.formateDateTime(new Date()));
                //获取行的每一列
                for (int j=0;j<row.getLastCellNum();j++){//最后一列的下标+1
                    cell=row.getCell(j);
                    //获取列中的值
                    cellValue= HSSFUtils.getCellValue(cell);
                    //给实体类封装参数
                    if (j==0){
                        activity.setName(cellValue);
                    }else if (j==1){
                        activity.setStartDate(cellValue);
                    }else if (j==2){
                        activity.setEndDate(cellValue);
                    }else if (j==3){
                        activity.setCost(cellValue);
                    }else if (j==4){
                        activity.setDescription(cellValue);
                    }
                }
                //把封装好的实体类对象放入List集合中
                activitieList.add(activity);
            }

            //调用service层，根据List批量创建Activitys
            int count = acticityService.saveInsertActivityByFile(activitieList);
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(count);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;

    }


    @RequestMapping("/workbench/activity/queryActivityRemarkForDetailByActivityId.do")
    public String queryActivityRemarkForDetailByActivityId(String id,HttpServletRequest request){
        //根据市场活动id查询市场活动信息
        Activity activity = acticityService.queryActivityForDetailById(id);
        //根据市场活动id查询市场活动备注表
        List<ActivityRemark> activityRemarkList = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);
        //将查询结果放入请求作用域中
        request.setAttribute("activity",activity);
        request.setAttribute("activityRemarkList",activityRemarkList);
        return "workbench/activity/detail";
    }


    @ResponseBody
    @RequestMapping("/workbench/activity/queryActivityForClueDetailByNameClueId.do")
    public Object queryActivityForClueDetailByNameClueId(String name,String clueId){
        Map<String,Object> map = new HashMap<String, Object>();
                    map.put("name",name);
                    map.put("clueId",clueId);
        //调用市场活动service层，根据市场活动名称和线索id模糊查询市场活动，为线索关联市场活动做准备
        List<Activity> activitieList = acticityService.queryActivityForClueDetailByNameClueId(map);
        return activitieList;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/queryActivityForContactsActivityByName.do")
    public Object queryActivityForContactsActivityByName(String name,String contactsId){
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("name",name);
        map.put("contactsId",contactsId);
        //调用市场活动service层，根据名称模糊查询该联系人关联过的市场活动
        List<Activity> activityList = acticityService.queryActivityForContactsActivityByName(map);
        return activityList;
    }

}
