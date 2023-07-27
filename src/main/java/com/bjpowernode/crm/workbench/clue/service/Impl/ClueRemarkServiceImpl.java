package com.bjpowernode.crm.workbench.clue.service.Impl;

import com.bjpowernode.crm.workbench.clue.mapper.ClueMapper;
import com.bjpowernode.crm.workbench.clue.mapper.ClueRemarkMapper;
import com.bjpowernode.crm.workbench.clue.pojo.ClueRemark;
import com.bjpowernode.crm.workbench.clue.service.ClueRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
@Service("clueRemarkService")
public class ClueRemarkServiceImpl implements ClueRemarkService {
    @Resource
    private ClueRemarkMapper clueRemarkMapper;

    /**
     * 根据线索id查询线索备注
     * @param clueId
     * @return
     */
    @Override
    public List<ClueRemark> queryClueRemarkForDetailByClueId(String clueId) {
        return clueRemarkMapper.selectClueRemarkForDetailByClueId(clueId);
    }

    /**
     * 创建线索备注
     * @param clueRemark
     * @return
     */
    @Override
    public int saveCreateClueRemark(ClueRemark clueRemark) {

        return clueRemarkMapper.insertClueRemark(clueRemark);
    }

    @Override
    public int deleteClueRemarkByRemarkId(String remarkId) {
        return clueRemarkMapper.deleteClueRemarkByRemarkId(remarkId);
    }

    /**
     * 根据id修改线索备注
     * @param clueRemark
     * @return
     */
    @Override
    public int saveUpdateClueRemarkById(ClueRemark clueRemark) {

        return clueRemarkMapper.updateClueRemarkById(clueRemark);
    }
}
