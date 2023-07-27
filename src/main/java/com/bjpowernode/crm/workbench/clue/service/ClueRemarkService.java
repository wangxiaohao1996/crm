package com.bjpowernode.crm.workbench.clue.service;

import com.bjpowernode.crm.workbench.clue.pojo.ClueRemark;

import java.util.List;

public interface ClueRemarkService {
    List<ClueRemark> queryClueRemarkForDetailByClueId(String clueId);
    int saveCreateClueRemark(ClueRemark clueRemark);
    int deleteClueRemarkByRemarkId(String remarkId);

    /**
     * 根据id修改线索备注
     * @return
     */
    int saveUpdateClueRemarkById(ClueRemark clueRemark);
}
