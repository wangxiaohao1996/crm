package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.pojo.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.settings.pojo.User;
import com.bjpowernode.crm.settings.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {
    @Resource
    private UserService userService;

    @RequestMapping(value = "/settings/qx/user/toLogin.do")
    public String toLogin(){
        return "settings/qx/user/login";
    }

    @ResponseBody
    @RequestMapping("/settings/qx/user/login.do")
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpSession session, HttpServletResponse response){
//封装参数
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
//        调用service层方法，查询用户
        User user = userService.queryUserByLoginActAndPed(map);
        ReturnObject returnObject = new ReturnObject();
        if(user==null){
            //登录失败：输入的账号或者密码错误
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("输入的账号或者密码错误");
        }else{
            //获取账号到期时间
            String expireTime = user.getExpireTime();
            //获取当前时间
            String nowtime = DateUtils.formateDateTime(new Date());
            //验证账号是否过期
            if(nowtime.compareTo(expireTime)>0){
                //登录失败：账户已过期
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("账户已过期");
            }else if("0".equals(user.getLockState())){
                //登录失败：账号已被锁
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("输入的账户已被锁");
            }else if(!user.getAllowIps().contains(request.getRemoteAddr())){
                //登录失败：ip受限
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("ip受限");
            }else {
                //登录成功
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                session.setAttribute(Contants.SESSION_USER,user);
                if ("true".equals(isRemPwd)){
                    Cookie cookie1 = new Cookie("loginAct",user.getLoginAct());
                    Cookie cookie2 = new Cookie("loginPwd",user.getLoginPwd());
                    cookie1.setMaxAge(10*24*60*60);
                    cookie2.setMaxAge(10*24*60*60);
                    response.addCookie(cookie1);
                    response.addCookie(cookie2);
                }else {
                    Cookie cookie1 = new Cookie("loginAct","1");
                    Cookie cookie2 = new Cookie("loginPwd","2");
                    cookie1.setMaxAge(0);
                    cookie2.setMaxAge(0);
                    response.addCookie(cookie1);
                    response.addCookie(cookie2);
                }
            }
        }
        return returnObject;
    }

    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpSession session,HttpServletResponse response){
        //删除cookie
        Cookie cookie1 = new Cookie("loginAct","1");
        Cookie cookie2 = new Cookie("loginPwd","2");
        cookie1.setMaxAge(0);
        cookie2.setMaxAge(0);
        response.addCookie(cookie1);
        response.addCookie(cookie2);
        //销毁session
        session.invalidate();
        //重定向到登录页面
        return "redirect:/";
    }
}
