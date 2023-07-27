package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.settings.mapper.UserMapper;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.pojo.User;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;
@Service("userServiceImpl")
public class UserServiceImpl implements UserService {
    @Resource
    private UserMapper userMapper;
    @Override
    public User queryUserByLoginActAndPed(Map<String, Object> map) {

        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> queryAllUsers() {

        return userMapper.selectAllUsers();
    }
}
