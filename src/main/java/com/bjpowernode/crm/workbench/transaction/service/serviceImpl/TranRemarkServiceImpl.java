package com.bjpowernode.crm.workbench.transaction.service.serviceImpl;

import com.bjpowernode.crm.workbench.clue.mapper.TranRemarkMapper;
import com.bjpowernode.crm.workbench.clue.pojo.TranRemark;
import com.bjpowernode.crm.workbench.transaction.service.TranRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class TranRemarkServiceImpl implements TranRemarkService {
    @Resource
    private TranRemarkMapper tranRemarkMapper;
    @Override
    public List<TranRemark> queryTranRemarkByTranId(String tranId) {
        return tranRemarkMapper.selectTranRemarkByTranId(tranId);
    }

    /**
     * 从交易明细页面创建交易备注
     * @param tranRemark
     * @return
     */
    @Override
    public int saveInsertTranRemark(TranRemark tranRemark) {

        return tranRemarkMapper.insertTranRemark(tranRemark);
    }

    /**
     * 根据id删除交易备注
     * @param id
     * @return
     */
    @Override
    public int deleteTranRemarkById(String id) {
        return tranRemarkMapper.deleteTranRemarkById(id);
    }

    /**
     * 根据id修改交易备注
     * @param tranRemark
     * @return
     */
    @Override
    public int saveUpdateTranRemarkById(TranRemark tranRemark) {
        return tranRemarkMapper.updateTranRemarkById(tranRemark);
    }
}
