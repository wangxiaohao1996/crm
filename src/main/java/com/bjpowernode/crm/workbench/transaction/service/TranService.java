package com.bjpowernode.crm.workbench.transaction.service;

import com.bjpowernode.crm.commons.pojo.Funnel;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import com.bjpowernode.crm.workbench.clue.pojo.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    void saveCreateTran(Map<String,Object> map);
    Tran queryTranForDetailById(String id);
    List<Funnel> selectTranForFunnel();

    List<Tran> queryTranForCustomerDetailByCustomerId(String customerId);

    /**
     * 根据联系人id查询该联系人有关的交易
     * @param contactsId
     * @return
     */
    List<Tran> queryTranForContactsDetailByConstactsId(String contactsId);

    /**
     * 从联系人明细页面根据id删除交易、交易备注、交易阶段历史记录
     * @param id
     * @return
     */
    void deleteTranFromContactsDetailById(String id);

    /**
     * 根据条件模糊查询交易
     * @param map
     * @return
     */
    List<Tran> selectTranByCondition(Map<String,Object> map);

    /**
     * 根据条件模糊查询交易记录条数
     * @param map
     * @return
     */
    int selectTranNumberByCondition(Map<String,Object> map);

    /**
     * 根据id数组批量删除交易、交易备注、交易阶段历史记录
     * @param ids
     * @return
     */
    void deleteTranByIds(String[] ids);

    /**
     * 根据交易id修改交易
     * @param map
     * @return
     */
    void saveUpdateTranById(Map<String,Object> map);

}
