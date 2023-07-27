package com.bjpowernode.crm.settings.dictionary.value.service;

import com.bjpowernode.crm.settings.dictionary.value.pojo.DicValue;

import java.util.List;

public interface DicValueService {
    List<DicValue> selectDicValueByTypeCode(String typeCode);
    String selectDicValueById(String id);
}
