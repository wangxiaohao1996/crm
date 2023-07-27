package com.bjpowernode.crm.workbench.transaction.service;

import com.bjpowernode.crm.workbench.clue.pojo.TranRemark;

import java.util.List;

public interface TranRemarkService {
    List<TranRemark> queryTranRemarkByTranId(String tranId);

    /**
     * 从交易明细页面创建交易备注
     * @param tranRemark
     * @return
     */
    int saveInsertTranRemark(TranRemark tranRemark);

    /**
     * 根据id删除交易备注
     * @param id
     * @return
     */
    int deleteTranRemarkById(String id);

    /**
     * 根据id修改交易备注
     * @param tranRemark
     * @return
     */
    int saveUpdateTranRemarkById(TranRemark tranRemark);
}
