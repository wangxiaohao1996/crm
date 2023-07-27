package com.bjpowernode.crm.workbench.clue.service;

import com.bjpowernode.crm.workbench.clue.pojo.ClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationService {

    int saveCreateClueActivityRelationByClueIdActivityId(List<ClueActivityRelation> clueActivityRelations);


    int deleteClueActivityRelationByClueIdActivityId(Map<String,Object> map);
}
