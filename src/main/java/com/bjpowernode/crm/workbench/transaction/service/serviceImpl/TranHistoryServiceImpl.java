package com.bjpowernode.crm.workbench.transaction.service.serviceImpl;

import com.bjpowernode.crm.workbench.clue.mapper.TranHistoryMapper;
import com.bjpowernode.crm.workbench.clue.pojo.TranHistory;
import com.bjpowernode.crm.workbench.transaction.service.TranHistoryService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class TranHistoryServiceImpl implements TranHistoryService {
    @Resource
    private TranHistoryMapper tranHistoryMapper;
    @Override
    public List<TranHistory> queryTranHistoryByTranId(String tranId) {
        return tranHistoryMapper.selectTranHistoryByTranId(tranId);
    }
}
