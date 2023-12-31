package com.bjpowernode.crm.workbench.clue.mapper;

import com.bjpowernode.crm.commons.pojo.Funnel;
import com.bjpowernode.crm.workbench.clue.pojo.Tran;
import org.apache.poi.ss.formula.functions.T;

import java.util.List;
import java.util.Map;

public interface TranMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    int insert(Tran row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    int insertSelective(Tran row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    Tran selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    int updateByPrimaryKeySelective(Tran row);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_tran
     *
     * @mbg.generated Mon Jul 17 17:37:16 CST 2023
     */
    int updateByPrimaryKey(Tran row);

    /**
     * 从线索转换页面创建交易
     * @param tran
     * @return
     */
    int insertTranFromClueConvert(Tran tran);

    /**
     * 根据id查询交易信息
     * @param id
     * @return
     */
    Tran selectTranForDetailById(String id);

    /**
     * 给漏斗图查询交易各个阶段的数量数据
     * @return
     */
    List<Funnel> selectTranStageForEcharts();

    /**
     * 根据客户id查询该客户有关的交易
     * @param customerId
     * @return
     */
    List<Tran> selectTranForCustomerDetailByCustomerId(String customerId);

    /**
     * 根据联系人id查询该联系人有关的所有交易
     * @param contactsId
     * @return
     */
    List<Tran> selectTranForContactsDetailByContactsId(String contactsId);

    /**
     * 从联系人明细页面根据id删除交易
     * @param id
     * @return
     */
    int deleteTranFromContactsDetailById(String id);

    /**
     * 根据条件模糊查询交易
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
     * 根据id数组批量删除交易
     * @param ids
     * @return
     */
    int deleteTranByIds(String[] ids);

    /**
     * 根据id修改交易
     * @param tran
     * @return
     */
    int updateTranById(Tran tran);

    /**
     * 根据id查询交易，为创建该交易阶段历史进行查询
     * @param id
     * @return
     */
    Tran selectTranById(String id);

    /**
     * 根据客户id数组批量删除交易
     * @param ids
     * @return
     */
    int deleteTranByCustomerIds(String[] ids);
}