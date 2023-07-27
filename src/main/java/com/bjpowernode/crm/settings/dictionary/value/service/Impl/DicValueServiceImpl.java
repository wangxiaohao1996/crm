package com.bjpowernode.crm.settings.dictionary.value.service.Impl;

import com.bjpowernode.crm.settings.dictionary.value.mapper.DicValueMapper;
import com.bjpowernode.crm.settings.dictionary.value.pojo.DicValue;
import com.bjpowernode.crm.settings.dictionary.value.service.DicValueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("dicValueService")
public class DicValueServiceImpl implements DicValueService {
    @Resource
    private DicValueMapper dicValueMapper;
    @Override
    public List<DicValue> selectDicValueByTypeCode(String typeCode) {
        return dicValueMapper.selectDicValueByDicTypeCode(typeCode);

    }

    @Override
    public String selectDicValueById(String id) {

        return dicValueMapper.selectDicValueByDicTyId(id);
    }
}
