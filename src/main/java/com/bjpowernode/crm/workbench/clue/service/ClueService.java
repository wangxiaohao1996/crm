package com.bjpowernode.crm.workbench.clue.service;

import com.bjpowernode.crm.workbench.clue.pojo.Clue;

import java.util.List;
import java.util.Map;

public interface ClueService {

    int saveCreateClue(Clue clue);
    Clue queryClueForDetailById(String id);
    void saveClueConvert(Map<String,Object> map);
    List<Clue> queryClueByCondition(Map<String,Object> map);
    int queryClueCountByCondition(Map<String,Object> map);

    /**
     * 根据id批量删除线索
     * @param ids
     * @return
     */
    void deleteClueByIds(String[] ids);

    /**
     * 根据id修改线索
     * @param clue
     * @return
     */
    int saveUpdateClueById(Clue clue);
}
