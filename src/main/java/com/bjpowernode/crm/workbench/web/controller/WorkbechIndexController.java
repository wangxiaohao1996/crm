package com.bjpowernode.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WorkbechIndexController {
    @RequestMapping("/workbench/index.do")
    public String index(){
        //跳转到业务主页面
        return "forward:/WEB-INF/pages/workbench/index.jsp";
    }
}
