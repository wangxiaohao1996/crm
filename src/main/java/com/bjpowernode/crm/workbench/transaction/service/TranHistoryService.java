package com.bjpowernode.crm.workbench.transaction.service;

import com.bjpowernode.crm.workbench.clue.pojo.TranHistory;

import java.util.List;

public interface TranHistoryService {

    List<TranHistory> queryTranHistoryByTranId(String tranId);
}
