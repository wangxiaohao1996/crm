package com.bjpowernode.crm.workbench.clue.service.Impl;

import com.bjpowernode.crm.workbench.clue.mapper.ClueActivityRelationMapper;
import com.bjpowernode.crm.workbench.clue.pojo.ClueActivityRelation;
import com.bjpowernode.crm.workbench.clue.service.ClueActivityRelationService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service("clueActivityRelationService")
public class ClueActivityRelationServiceImpl implements ClueActivityRelationService {
    @Resource
    private ClueActivityRelationMapper clueActivityRelationMapper;

    /**
     * 根据线索id和市场活动id批量创建关联关系
     * @param clueActivityRelations
     * @return
     */
    @Override
    public int saveCreateClueActivityRelationByClueIdActivityId(List<ClueActivityRelation> clueActivityRelations) {
        return clueActivityRelationMapper.insertClueActivityRelationByClueIdActivityId(clueActivityRelations);
    }
    /**
     * 根据线索id和市场活动id删除线索和市场活动关联关系
     * @param map
     * @return
     */
    @Override
    public int deleteClueActivityRelationByClueIdActivityId(Map<String, Object> map) {
        return clueActivityRelationMapper.deleteClueActivityRelationClueIdActivityId(map);
    }
}
