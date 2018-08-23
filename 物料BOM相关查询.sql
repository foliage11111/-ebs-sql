--9. 物料清单 bom
--BOM 主表 bom_bill_of_materials
  SELECT aa.bill_sequence_id 清单序号
        ,aa.assembly_item_id 装配件内码
        ,aa.organization_id  组织代码
        ,bb.segment1         物料编码
        ,bb.description      物料说明
        ,aa.assembly_type    装配类别
    FROM bom_bill_of_materials aa ， mtl_system_items bb
   WHERE aa.assembly_item_id = bb.inventory_item_id
     AND aa.organization_id = bb.organization_id;

--BOM 明细表 bom_inventory_components
SELECT bill_sequence_id      清单序号
      ,component_sequence_id 构件序号
      ,item_num              项目序列
      ,operation_seq_num     操作序列号
      ,component_item_id     子物料内码
      ,component_quantity    构件数量
      ,disable_date          失效日期
      ,supply_subinventory   供应子库存
      ,bom_item_type
  FROM bom_inventory_components;

--BOM 明细综合查询 ( 组织 限定供应处 142 装配件 = '5XJ061988')
SELECT vbom.bid                   清单序号
      ,vbom.f_itemid              装配件内码
      ,bb.segment1                物料编码
      ,bb.description             物料说明
      ,vbom.ogt_id                组织内码
      ,vbom.cid                   操作 id
      ,vbom.item_num              物料序号
      ,vbom.opid                  工序
      ,vbom.c_itemid              子物料内码
      ,cc.segment1                物料编码
      ,cc.description             物料说明
      ,vbom.qty                   构件数量
      ,cc.primary_uom_code        子计量单位码
      ,cc.primary_unit_of_measure 子计量单位名
      ,vbom.whse                  供应子仓库
  FROM (SELECT aa.bill_sequence_id      bid
              ,bb.assembly_item_id      f_itemid
              ,bb.organization_id       ogt_id
              ,aa.component_sequence_id cid
              ,aa.item_num              item_num
              ,aa.operation_seq_num     opid
              ,aa.component_item_id     c_itemid
              ,aa.component_quantity    qty
              ,aa.supply_subinventory   whse
          FROM bom_inventory_components aa
              ,bom_bill_of_materials    bb
         WHERE aa.bill_sequence_id = bb.bill_sequence_id) vbom
      ,mtl_system_items bb
      ,mtl_system_items cc
 WHERE vbom.f_itemid = bb.inventory_item_id
   AND vbom.ogt_id = bb.organization_id
   AND vbom.c_itemid = cc.inventory_item_id
   AND vbom.ogt_id = cc.organization_id
   AND vbom.ogt_id = 142
   AND bb.segment1 = '5XJ061988'
 ORDER BY vbom.item_num;

-- 单层 BOM 成本查询 ( 需系统提交请求计算后 )
SELECT inventory_item_id
      ,organization_id
      ,item_cost
      ,program_update_date
  FROM bom.cst_item_costs
 WHERE inventory_item_id = 23760
   AND organization_id = 142;

SELECT inventory_item_id
      ,organization_id
      ,item_cost
      ,program_update_date
  FROM cst_item_cost_details
 WHERE inventory_item_id = 23760
   AND organization_id = 142;
--以上是单层bom展开，下面是展开bom到最底层：
SELECT rownum seq_num
      ,LEVEL bom_level
      ,bbm.assembly_item_id
      ,bbm.common_assembly_item_id
      ,bic.item_num
      ,bbm.common_bill_sequence_id
      ,bbm.bill_sequence_id
      ,bic.component_item_id
      ,bic.component_quantity
      ,connect_by_isleaf isleaf
      ,connect_by_root bbm.assembly_item_id root_item
      ,sys_connect_by_path(bbm.assembly_item_id
                          ,'/') bom_tree
  FROM bom_bill_of_materials    bbm
      ,bom_inventory_components bic
 WHERE bbm.bill_sequence_id = bic.bill_sequence_id
   AND (bic.disable_date IS NULL OR bic.disable_date >= SYSDATE)
   AND bic.effectivity_date <= SYSDATE
   AND bbm.organization_id = 85
/* connect by bbm.ASSEMBLY_ITEM_ID = prior bic.COMPONENT_ITEM_ID*/
 START WITH bbm.assembly_item_id = 49918
CONNECT BY bic.bill_sequence_id IN PRIOR
           (SELECT DISTINCT bill_sequence_id
              FROM bom_bill_of_materials bo
             WHERE bo.assembly_item_id = bic.component_item_id
               AND bo.organization_id = p_org_id
               AND bo.alternate_bom_designator IS NULL
               AND disable_date IS NULL)
/*  ) WHERE isleaf=0 AND COMPONENT_QUANTITY>1*/
;
---特别说明：level connect_by_isleaf connect_by_root sys_connect_by_path(bbm.assembly_item_id, '/') 均是start
--- WITH …… CONNECT BY 的内置函数或字段 
