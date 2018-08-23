/*
organization 两个含义:
  1. 经营单位，a/b/c分公司，a下面有a1，a2等工厂，主题目标是为了独立核算此组织
org，org_id;
2. 库存组织，例如制造商的仓库，例如a1，a2等工厂
 organization_id;
 hr_organization_units －
 org_organization_definitions 
 mtl_subinventory_ 库存组织单位
 mtl_parameters -库存组织参数（没有用id，直接用name）
 mtl_system_items_b -物料信息（同上，应用了库存组织name）
 mtl_secondary_inventories -子库存组织 - 
 mtl_item_locattions -货位 - subinventroy_code
 mtl_material_transactions - (库存)物料事物表
成本 mtl_transaction_accounts
transaction_cost是事物成本；
actual_cost是通过成本算法计算出来的实际成本，主计量单位
现有量
汇总历史记录（正负合计）
mtl_material_transactions
mtl_onhand_quantities现有量表，组织/子库存/货位/物品 summary可能按照挑库先进先出统计，如果设置了"不允许负库存"，这样就不可能出现负数


*/

--8. 库存 inv
-- 物料主表
SELECT msi.organization_id            组织id
      ,msi.inventory_item_id          物料id
      ,msi.segment1                   物料编码
      ,msi.description                物料说明
      ,msi.item_type                  项目类型
      ,msi.planning_make_buy_code     制造或购买
      ,msi.primary_unit_of_measure    基本度量单位
      ,msi.bom_enabled_flag           bom标志
      ,msi.inventory_asset_flag       库存资产否
      ,msi.buyer_id                   采购员id
      ,msi.purchasing_enabled_flag    可采购否
      ,msi.purchasing_item_flag       采购项目
      ,msi.unit_of_issue              单位
      ,msi.inventory_item_flag        是否为库存
      ,msi.lot_control_code           是否批量
      ,msi.reservable_type            是否要预留
      ,msi.stock_enabled_flag         能否库存
      ,msi.fixed_days_supply          固定提前期
      ,msi.fixed_lot_multiplier       固定批量大小
      ,msi.inventory_planning_code    库存计划方法
      ,msi.maximum_order_quantity     最大定单数
      ,msi.minimum_order_quantity     最小定单数
      ,msi.full_lead_time             固定提前期
      ,msi.planner_code               计划员码
      ,misd.subinventory_code         接收子仓库
      ,msi.source_subinventory        来源子仓库
      ,msi.wip_supply_subinventory    供应子仓库
      ,msi.attribute12                老编码
      ,msi.inventory_item_status_code 物料状态
      ,mss.safety_stock_quantity      安全库存量
  FROM mtl_system_items      msi
      ,mtl_item_sub_defaults misd
      ,mtl_safety_stocks     mss
 WHERE msi.organization_id = misd.organization_id(+)
   AND msi.inventory_item_id = misd.inventory_item_id(+)
   AND msi.organization_id = mss.organization_id(+)
   AND msi.inventory_item_id = mss.inventory_item_id(+)
   AND msi.organization_id = 85
/* AND msi.segment1 = '18020200012'*/
;



-- 物料库存数量
SELECT moq.organization_id
      ,moq.inventory_item_id
      ,moq.subinventory_code
      ,SUM(moq.transaction_quantity) qty
  FROM mtl_onhand_quantities moq
 WHERE /*moq.inventory_item_id = 12781
   AND*/
 moq.organization_id = 85
 GROUP BY moq.organization_id
         ,moq.inventory_item_id
         ,moq.subinventory_code;
         
         

-- 移动平均成本
SELECT cst.inventory_item_id       item_id
      ,cst.organization_id         org_id
      ,cst.cost_type_id            成本类型
      ,cst.item_cost               单位成本
      ,cst.material_cost           材料成本
      ,cst.material_overhead_cost  间接费
      ,cst.resource_cost           人工费
      ,cst.outside_processing_cost 外协费
      ,cst.overhead_cost           制造费
  FROM cst_item_costs cst
 WHERE cst.cost_type_id = 2
      /*AND cst.inventory_item_id = 12781*/
   AND cst.organization_id = 85;



-- 综合查询 - 库存数量及成本
SELECT msi.organization_id         组织id
      ,msi.inventory_item_id       物料id
      ,msi.segment1                物料编码
      ,msi.description             物料说明
      ,msi.planning_make_buy_code  m1p2
      ,moqv.subinventory_code      子库存
      ,moqv.qty                    当前库存量
      ,cst.item_cost               单位成本
      ,cst.material_cost           材料成本
      ,cst.material_overhead_cost  间接费
      ,cst.resource_cost           人工费
      ,cst.outside_processing_cost 外协费
      ,cst.overhead_cost           制造费
  FROM mtl_system_items msi
      ,cst_item_costs cst
      ,(SELECT moq.organization_id
              ,moq.inventory_item_id
              ,moq.subinventory_code
              ,SUM(moq.transaction_quantity) qty
          FROM mtl_onhand_quantities moq
         WHERE moq.organization_id = 85
         GROUP BY moq.organization_id
                 ,moq.inventory_item_id
                 ,moq.subinventory_code) moqv
 WHERE msi.organization_id = cst.organization_id(+)
   AND msi.inventory_item_id = cst.inventory_item_id(+)
   AND msi.organization_id = moqv.organization_id(+)
   AND msi.inventory_item_id = moqv.inventory_item_id(+)
   AND cst.cost_type_id = 2
   AND msi.organization_id = 85;
--AND msi.segment1 = '18020200012'


-- 子库存列表
SELECT *
  FROM mtl_secondary_inventories;



-- 货位列表
SELECT organization_id       组织代码
      ,inventory_location_id 货位内码
      ,subinventory_code     子库名称
      ,segment1              货位编码
  FROM mtl_item_locations;
  
  
  
-- 计划员表
SELECT planner_code    计划员代码
      ,organization_id 组织代码
      ,description     计划员描述
      ,mp.employee_id  员工 id
      ,disable_date    失效日期
  FROM mtl_planners mp;
  
  
-- 科目设置等参数
SELECT *
  FROM mtl_parameters mp;
