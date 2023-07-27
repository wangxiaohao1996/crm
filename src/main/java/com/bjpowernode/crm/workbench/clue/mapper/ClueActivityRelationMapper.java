package com.bjpowernode.crm.workbench.clue.mapper;

import com.bjpowernode.crm.workbench.clue.pojo.ClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    int insert(ClueActivityRelation row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    int insertSelective(ClueActivityRelation row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    ClueActivityRelation selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    int updateByPrimaryKeySelective(ClueActivityRelation row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbg.generated Fri Jul 14 17:21:10 CST 2023
     */
    int updateByPrimaryKey(ClueActivityRelation row);

    /**
     * 根据线索id和市场活动id批量创建线索和市场活动关联关系
     * @param clueActivityRelations
     * @return
     */
    int insertClueActivityRelationByClueIdActivityId(List<ClueActivityRelation> clueActivityRelations);

    /**
     * 根据线索id和市场活动id删除线索和市场活动关联关系
     * @param map
     * @return
     */
    int deleteClueActivityRelationClueIdActivityId(Map<String,Object> map);

    /**
     * 根据线索ID查询该线索下所有关联的市场活动
     * @param clueId
     * @return
     */
    List<ClueActivityRelation> selectClueActivityRelationByClueId(String clueId);

    /**
     * 根据线索id删除线索市场活动关联关系
     * @param clueId
     * @return
     */
    int deleteClueActivityRelationByClueId(String clueId);

    /**
     * 根据线索id数组批量删除关联关系
     * @param clueIds
     * @return
     */
    int deleteCARByClueIds(String[] clueIds);
}