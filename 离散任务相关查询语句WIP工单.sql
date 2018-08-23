--10. 作业任务 wip 说明： 查询作业任务头以及作业任务工序和 bom 情况
-- 作业任务头信息表
-- （以直流 OU_ID=117 ； ORGANIZATION_ID=1155; 及任务 WIP_ENTITY_NAME='XJ39562'; 装配件编码 SEGMENT1 = '07D9202.92742' 为例）
SELECT aa.wip_entity_id   任务令id
      ,aa.organization_id 组织id
      ,aa.wip_entity_name 任务名称
      ,aa.entity_type     任务类型
      ,aa.creation_date   创建日期
      ,aa.created_by      创建者id
      ,aa.description     说明
      ,aa.primary_item_id 装配件id
      ,bb.segment1        物料编码
      ,bb.description     物料说明
  FROM wip_entities     aa
      ,mtl_system_items bb
 WHERE aa.primary_item_id = bb.inventory_item_id
   AND aa.organization_id = bb.organization_id
   AND aa.organization_id = 1155
   AND aa.wip_entity_name = 'XJ39562';
--=> WIP_ENTITY_ID = 48825

-- 离散作业任务详细主信息表
-- 用途 1 ）作业任务下达及完成情况查询
-- 说明 1 ）此表包括 wip_entities 表大部分信息 2) 重复作业任务表为 wip_repetitive_items, wip_repetitive_schedules
SELECT aa.wip_entity_id             任务令id
      ,bb.wip_entity_name           任务名称
      ,aa.organization_id           组织id
      ,aa.source_line_id            行id
      ,aa.status_type               状态type
      ,aa.primary_item_id           装配件id
      ,cc.segment1                  物料编码
      ,cc.description               物料说明
      ,aa.firm_planned_flag
      ,aa.job_type                  作业类型
      ,aa.wip_supply_type           供应type
      ,aa.class_code                任务类别
      ,aa.scheduled_start_date      起始时间
      ,aa.date_released             下达时间
      ,aa.scheduled_completion_date 完工时间
      ,aa.date_completed            完工时间
      ,aa.date_closed               关门时间
      ,aa.start_quantity            计划数
      ,aa.quantity_completed        完工数
      ,aa.quantity_scrapped         报废数
      ,aa.net_quantity              mrp 净值
      ,aa.completion_subinventory   接收子库
      ,aa.completion_locator_id     货位
  FROM wip_discrete_jobs aa
      ,wip.wip_entities  bb
      ,mtl_system_items  cc
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND aa.primary_item_id = cc.inventory_item_id
   AND aa.organization_id = cc.organization_id
   AND aa.organization_id = 1155
   AND bb.wip_entity_name = 'XJ39562';
   
   
   --------------------工单中 供应类型
   SELECT * FROM FND_LOOKUP_VALUES A WHERE A.LOOKUP_TYPE = 'WIP_SUPPLY' AND A.LANGUAGE='ZHS';

--离散任务状态含义

SELECT *
  FROM mfg_lookups ml
 WHERE ml.lookup_type LIKE 'WIP_JOB%';
/*
1 ）任务状态 TYPE 值说明：

select * from mfg_lookups ml where ml.LOOKUP_TYPE like 'WIP_JOB%';

STATUS_TYPE =1 未发放的 - 收费不允许
STATUS_TYPE =3 发入 - 收费允许
STATUS_TYPE =4 完成 - 允许收费
STATUS_TYPE =5 完成 - 不允许收费
STATUS_TYPE =6 暂挂 - 不允许收费
STATUS_TYPE =7 已取消 - 不允许收费
STATUS_TYPE =8 等待物料单加载
STATUS_TYPE =9 失败的物料单加载
STATUS_TYPE =10 等待路线加载
STATUS_TYPE =11 失败的路线加载
STATUS_TYPE =12 关闭 - 不可收费
STATUS_TYPE =13 等待 - 成批加载
STATUS_TYPE =14 等待关闭
STATUS_TYPE =15 关闭失败
2 ）供应类型 TYPE 值说明：
WIP_SUPPLY_TYPE =1 推式
WIP_SUPPLY_TYPE =2 装配拉式
WIP_SUPPLY_TYPE =3 操作拉式
WIP_SUPPLY_TYPE =4 大量
WIP_SUPPLY_TYPE =5 供应商
WIP_SUPPLY_TYPE =6 虚拟
WIP_SUPPLY_TYPE =7 以帐单为基础
*/

-- 离散作业任务工序状况表
SELECT aa.organization_id            组织id
      ,aa.wip_entity_id              任务令id
      ,bb.wip_entity_name            任务名称
      ,aa.operation_seq_num          工序号
      ,aa.description                工序描述
      ,aa.department_id              部门id
      ,aa.scheduled_quantity         计划数量
      ,aa.quantity_in_queue          排队数量
      ,aa.quantity_running           运行数量
      ,aa.quantity_waiting_to_move   待移动数量
      ,aa.quantity_rejected          故障品数量
      ,aa.quantity_scrapped          报废品数量
      ,aa.quantity_completed         完工数量
      ,aa.first_unit_start_date      最早一个单位上线时间
      ,aa.first_unit_completion_date 最早一个单位完成时间
      ,aa.last_unit_start_date       最后一个单位上线时间
      ,aa.last_unit_completion_date  最后一个单位完工时间
      ,aa.previous_operation_seq_num 前一工序序号
      ,aa.next_operation_seq_num     下一工序序号
      ,aa.count_point_type           是否自动计费
      ,aa.backflush_flag             倒冲否
      ,aa.minimum_transfer_quantity  最小传送数量
      ,aa.date_last_moved            最后移动时间
  FROM wip_operations aa
      ,wip_entities   bb
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND bb.wip_entity_name = 'XJ39562';
-- 离散作业任务子查询 ——— 工单工序状况查询（不单独使用）
SELECT wdj.organization_id
      ,wdj.wip_entity_id
      ,COUNT(1) count_oper
      ,MAX(decode(wo.quantity_completed
                 ,1
                 ,wo.operation_seq_num
                 ,10)) oper
  FROM wip_discrete_jobs wdj
      ,wip_operations    wo
 WHERE 1 = 1
   AND wdj.wip_entity_id = wo.wip_entity_id
   AND wdj.wip_entity_id = '48825'
 GROUP BY wdj.organization_id
         ,wdj.wip_entity_id;

-- 离散作业任务 BOM ( 无材料费 )
SELECT wop.organization_id       组织id
      ,wop.wip_entity_id         任务令id
      ,bb.wip_entity_name        装配件名称
      ,bb.primary_item_id        装配件id
      ,cc.segment1               装配件物料编码
      ,cc.description            装配件说明
      ,wop.operation_seq_num     工序号
      ,wop.department_id         部门id
      ,wop.wip_supply_type       供应类型
      ,wop.date_required         要求日期
      ,wop.inventory_item_id     子物料id
      ,dd.segment1               子物料编码
      ,dd.description            子物料说明
      ,wop.quantity_per_assembly 单位需量
      ,wop.required_quantity     总需求量
      ,wop.quantity_issued       已发放量
      ,wop.comments              注释
      ,wop.supply_subinventory   供应子库
  FROM wip_requirement_operations wop
      ,wip_entities               bb
      ,mtl_system_items           cc
      ,mtl_system_items           dd
 WHERE wop.wip_entity_id = bb.wip_entity_id
   AND bb.primary_item_id = cc.inventory_item_id
   AND bb.organization_id = cc.organization_id
   AND wop.inventory_item_id = dd.inventory_item_id
   AND wop.organization_id = dd.organization_id
   AND wop.organization_id = 1155
   AND bb.wip_entity_name = 'XJ39562';

-- 作业任务已发放材料处理记录清单 0101 （最详细） （内码为 48825 为例）
-- 用途 1 ）查询工单发料详细明细，包括发料类型、时间、用户等
SELECT mtl.transaction_id 交易id
      ,mtl.inventory_item_id 项目id
      ,cc.segment1 物料编码
      ,cc.description 物料说明
      ,mtl.organization_id 组织id
      ,mtl.subinventory_code 子库名称
      ,mtl.transaction_type_id 交易类型id
      ,bb.transaction_type_name 交易类型名称
      ,mtl.transaction_quantity 交易数量
      ,mtl.transaction_uom 单位
      ,mtl.transaction_date 交易日期
      ,mtl.transaction_reference 交易参考
      ,mtl.transaction_source_id 参考源id
      ,ff.wip_entity_name 任务名称
      ,mtl.department_id 部门 id
      ,mtl.operation_seq_num 工序号
      ,round(mtl.prior_cost
            ,2) 原来成本
      ,round(mtl.new_cost
            ,2) 新成本
      ,mtl.transaction_quantity * round(mtl.prior_cost
                                       ,2) 交易金额
      ,dd.user_name 用户名称
      ,ee.full_name 用户姓名
  FROM mtl_material_transactions mtl
      ,mtl_transaction_types     bb
      ,mtl_system_items          cc
      ,fnd_user                  dd
      ,per_people_f              ee
      ,wip_entities              ff
 WHERE mtl.transaction_type_id = bb.transaction_type_id
   AND mtl.created_by = dd.user_id
   AND mtl.inventory_item_id = cc.inventory_item_id
   AND mtl.organization_id = cc.organization_id
   AND dd.employee_id = ee.person_id
   AND mtl.transaction_source_id = ff.wip_entity_id
   AND mtl.transaction_type_id IN (35
                                  ,38
                                  ,43
                                  ,48)
   AND mtl.organization_id = 1155
   AND mtl.transaction_source_id = 48825;
-- 按工单的材料费汇总（不单独使用）
SELECT mtl.organization_id
      ,mtl.transaction_source_id wip_entity_id
      ,abs(round(SUM(mtl.transaction_quantity * mtl.prior_cost)
                ,2)) amt
  FROM mtl_material_transactions mtl
 WHERE mtl.transaction_type_id IN (35
                                  ,38
                                  ,43
                                  ,48)
   AND mtl.organization_id = 1155
   AND mtl.transaction_source_id = 48825
 GROUP BY mtl.organization_id
         ,mtl.transaction_source_id;

-- 离散作业任务子查询 01——— 材料消耗状况及材料费综合查询
-- 用途 1 ）查询发料状况 2 ）查询材料费物料小计
SELECT wop.organization_id       组织id
      ,wop.wip_entity_id         任务令id
      ,bb.wip_entity_name        装配件名称
      ,bb.primary_item_id        装配件id
      ,cc.segment1               装配件物料编码
      ,cc.description            装配件说明
      ,wop.operation_seq_num     工序号
      ,wop.department_id         部门id
      ,wop.wip_supply_type       供应类型
      ,wop.date_required         要求日期
      ,wop.inventory_item_id     子物料id
      ,dd.segment1               子物料编码
      ,dd.description            子物料说明
      ,wop.quantity_per_assembly 单位需量
      ,wop.required_quantity     总需求量
      ,wop.quantity_issued       已发放量
      ,cst.amt                   已发生材料费
      ,wop.comments              注释
      ,wop.supply_subinventory   供应子库
  FROM wip_requirement_operations wop
      ,wip_entities bb
      ,mtl_system_items cc
      ,mtl_system_items dd
      ,(SELECT mtl.organization_id orgid
              ,mtl.transaction_source_id wipid
              ,mtl.operation_seq_num oprid
              ,mtl.inventory_item_id itemid
              ,SUM(mtl.transaction_quantity *
                   round(mtl.actual_cost
                        ,2)) amt
          FROM mtl_material_transactions mtl
         WHERE mtl.transaction_type_id IN (35
                                          ,38
                                          ,43
                                          ,48)
           AND mtl.organization_id = 1155
           AND mtl.transaction_source_id = 48825
         GROUP BY mtl.organization_id
                 ,mtl.transaction_source_id
                 ,mtl.operation_seq_num
                 ,mtl.inventory_item_id) cst
 WHERE wop.wip_entity_id = bb.wip_entity_id
   AND bb.primary_item_id = cc.inventory_item_id
   AND bb.organization_id = cc.organization_id
   AND wop.inventory_item_id = dd.inventory_item_id
   AND wop.organization_id = dd.organization_id
   AND wop.organization_id = cst.orgid
   AND wop.wip_entity_id = cst.wipid
   AND wop.operation_seq_num = cst.oprid
   AND wop.inventory_item_id = cst.itemid
   AND wop.organization_id = 1155
   AND bb.wip_entity_name = 'XJ39562';

-- 离散作业任务子查询 0201——— 作业资源报工明细表
SELECT wta.organization_id        组织代码
      ,wta.transaction_id         交易代码
      ,wta.reference_account      参考科目
      ,wta.transaction_date       报工日期
      ,wta.wip_entity_id          任务令内码
      ,wta.accounting_line_type   会计栏类型
      ,wta.base_transaction_value 费用额
      ,wta.contra_set_id          反方集代码
      ,wta.primary_quantity       基本数量
      ,wta.rate_or_amount         率或金额
      ,wta.basis_type             基本类型
      ,wta.resource_id            资源代码
      ,wta.cost_element_id        成本要素id
      ,wta.accounting_line_type   成本类型id
      ,wta.overhead_basis_factor  费用因子
      ,wta.basis_resource_id      基本资源id
      ,wta.created_by             录入人id
      ,dd.user_name               用户名称
      ,ee.full_name               用户姓名
  FROM wip_transaction_accounts wta
      ,fnd_user                 dd
      ,per_people_f             ee
 WHERE wta.created_by = dd.user_id
   AND dd.employee_id = ee.person_id
   AND wta.base_transaction_value <> 0
   AND wta.organization_id = 1155
   AND wta.wip_entity_id = 48839;
-- 成本类型 ID ACCOUNTING_LINE_TYPE
SELECT *
  FROM mfg_lookups ml
 WHERE ml.lookup_type LIKE 'CST_ACCOUNTING_LINE_TYPE'
 ORDER BY ml.lookup_code;
-- 成本要素 ID COST_ELEMENT_ID
--

-- 统计人工费与制造费 ( 不单独应用 )
SELECT organization_id
      ,wip_entity_id
      ,SUM(hr_fee) hr_fee
      ,SUM(md_fee) md_fee
  FROM (SELECT wta.organization_id
              ,wta.wip_entity_id
              ,decode(cost_element_id
                     ,3
                     ,wta.base_transaction_value
                     ,0) hr_fee
              ,decode(cost_element_id
                     ,5
                     ,wta.base_transaction_value
                     ,0) md_fee
          FROM wip_transaction_accounts wta
         WHERE wta.accounting_line_type = 7
           AND wta.base_transaction_value <> 0) wta_cost
 WHERE wta_cost.organization_id = 1155
   AND wta_cost.wip_entity_id = '48839'
 GROUP BY wta_cost.organization_id
         ,wta_cost.wip_entity_id;

-- 工单进度及费用信息综合查询 ( 未下达及下达零发料和报工的看不到 )
SELECT we.wip_entity_name            任务名称
      ,msi.segment1                  物料
      ,msi.description               物料描述
      ,msi.primary_unit_of_measure   单位
      ,wdj.scheduled_start_date      计划开始时间
      ,wdj.scheduled_completion_date 计划完成时间
      ,wdj.start_quantity            工单数量
      ,wdj.quantity_completed        完成数量
      ,wdj.date_released             实际开始时间
      ,wdj.date_completed            时间完成时间
      ,wdj.description               工单备注
      ,pp.segment1                   项目号
      ,pp.description                项目描述
      ,pt.task_number                任务号
      ,pt.description                任务描述
      ,wo.count_oper                 工序数
      ,wo1.operation_seq_num         当前工序
      ,wo1.description               当前工序描述
      ,mta.mt_fee                    材料费
      ,wct.hr_fee                    人工费
      ,wct.md_fee                    制造费
      ,we.wip_entity_id
      ,we.organization_id
      ,wdj.primary_item_id
      ,wdj.project_id
      ,wdj.task_id
  FROM wip_entities we
      ,wip_operations wo1
      ,wip_discrete_jobs wdj
      ,mtl_system_items_b msi
      ,pa_projects_all pp
      ,pa_tasks pt
      ,(SELECT wdj.organization_id
              ,wdj.wip_entity_id
              ,COUNT(1) count_oper
              ,MAX(decode(wo.quantity_completed
                         ,1
                         ,wo.operation_seq_num
                         ,10)) oper
          FROM wip_discrete_jobs wdj
              ,wip_operations    wo
         WHERE wdj.wip_entity_id = wo.wip_entity_id
         GROUP BY wdj.organization_id
                 ,wdj.wip_entity_id) wo
      , -- 工序进度
       (SELECT mtl.organization_id
              ,mtl.transaction_source_id wip_entity_id
              ,abs(SUM(mtl.transaction_quantity * mtl.actual_cost)) mt_fee
          FROM mtl_material_transactions mtl
         WHERE mtl.transaction_type_id IN (35
                                          ,38
                                          ,43
                                          ,48)
         GROUP BY mtl.organization_id
                 ,mtl.transaction_source_id) mta
      , -- 材料费
       (SELECT wta_cost.organization_id
              ,wta_cost.wip_entity_id
              ,SUM(wta_cost.hr_fee1) hr_fee
              ,SUM(wta_cost.md_fee1) md_fee
          FROM (SELECT wta.organization_id
                      ,wta.wip_entity_id
                      ,decode(cost_element_id
                             ,3
                             ,wta.base_transaction_value
                             ,0) hr_fee1
                      ,decode(cost_element_id
                             ,5
                             ,wta.base_transaction_value
                             ,0) md_fee1
                  FROM wip_transaction_accounts wta
                 WHERE wta.accounting_line_type = 7
                   AND wta.base_transaction_value <> 0) wta_cost
         GROUP BY wta_cost.organization_id
                 ,wta_cost.wip_entity_id) wct -- 人工与制造
 WHERE 1 = 1
   AND we.organization_id = wdj.organization_id
   AND we.wip_entity_id = wdj.wip_entity_id
   AND wdj.organization_id = msi.organization_id
   AND wdj.primary_item_id = msi.inventory_item_id
   AND we.wip_entity_id = wo.wip_entity_id
   AND wo1.wip_entity_id = wo.wip_entity_id
   AND wo.oper = wo1.operation_seq_num
   AND we.organization_id = mta.organization_id
   AND we.wip_entity_id = mta.wip_entity_id(+)
   AND we.organization_id = wct.organization_id
   AND we.wip_entity_id = wct.wip_entity_id(+)
   AND wdj.project_id = pp.project_id(+)
   AND wdj.task_id = pt.task_id(+)
   AND we.organization_id = 1155
   AND we.wip_entity_id = '48825';

-- 工单进度及费用信息综合查询 ( 不论是否下达和发料都能看到 )
SELECT wdj.wip_entity_id           任务令id
      ,we.wip_entity_name          任务名称
      ,wdj.organization_id         组织id
      ,wdj.status_type             状态
      ,wdj.primary_item_id         装配件id
      ,msi.segment1                物料编码
      ,msi.description             物料说明
      ,wdj.firm_planned_flag       任务类型
      ,wdj.job_type                作业类型
      ,wdj.wip_supply_type         供应类型
      ,wdj.class_code              任务类别
      ,wdj.scheduled_start_date    起始时间
      ,wdj.date_released           下达时间
      ,wdj.date_completed          完工时间
      ,wdj.date_closed             关闭时间
      ,wdj.start_quantity          计划数
      ,wdj.quantity_completed      完工数
      ,wdj.quantity_scrapped       报废数
      ,wdj.net_quantity            mrp 净值
      ,wdj.description             工单备注
      ,wdj.completion_subinventory 接收子库
      ,wdj.completion_locator_id   货位id
      ,wdj.project_id              项目id
      ,wdj.task_id                 项目任务id
      ,pp.segment1                 项目号
      ,pp.description              项目描述
      ,pt.task_number              任务号
      ,pt.description              任务描述
      ,wpf.count_oper              工序数
      ,wpf.cur_oper                当前工序
      ,wpf.cur_opername            工序名
      ,wpf.mt_fee                  材料费
      ,wpf.hr_fee                  人工费
      ,wpf.md_fee                  制造费
  FROM wip_discrete_jobs wdj
      ,wip.wip_entities we
      ,mtl_system_items msi
      ,pa_projects_all pp
      ,pa_tasks pt
      ,(SELECT wdj1.wip_entity_id
              ,wdj1.organization_id
              ,wo.count_oper
              ,wo1.operation_seq_num cur_oper
              ,wo1.description       cur_opername
              ,mta.mt_fee
              ,wct.hr_fee
              ,wct.md_fee
          FROM wip_operations wo1
              ,wip_discrete_jobs wdj1
              ,(SELECT wdj.organization_id
                      ,wdj.wip_entity_id
                      ,COUNT(1) count_oper
                      ,MAX(decode(wo.quantity_completed
                                 ,1
                                 ,wo.operation_seq_num
                                 ,10)) oper
                  FROM wip_discrete_jobs wdj
                      ,wip_operations    wo
                 WHERE wdj.wip_entity_id = wo.wip_entity_id
                 GROUP BY wdj.organization_id
                         ,wdj.wip_entity_id) wo -- 工序进度
              ,(SELECT mtl.organization_id
                      ,mtl.transaction_source_id wip_entity_id
                      ,abs(SUM(mtl.transaction_quantity * mtl.actual_cost)) mt_fee
                  FROM mtl_material_transactions mtl
                 WHERE mtl.transaction_type_id IN (35
                                                  ,38
                                                  ,43
                                                  ,48)
                 GROUP BY mtl.organization_id
                         ,mtl.transaction_source_id) mta -- 材料费
              ,(SELECT wta_cost.organization_id
                      ,wta_cost.wip_entity_id
                      ,SUM(wta_cost.hr_fee1) hr_fee
                      ,SUM(wta_cost.md_fee1) md_fee
                  FROM (SELECT wta.organization_id
                              ,wta.wip_entity_id
                              ,decode(cost_element_id
                                     ,3
                                     ,wta.base_transaction_value
                                     ,0) hr_fee1
                              ,decode(cost_element_id
                                     ,5
                                     ,wta.base_transaction_value
                                     ,0) md_fee1
                          FROM wip_transaction_accounts wta
                         WHERE wta.accounting_line_type = 7
                           AND wta.base_transaction_value <> 0) wta_cost
                 GROUP BY wta_cost.organization_id
                         ,wta_cost.wip_entity_id) wct -- 人工与制造
         WHERE 1 = 1
           AND wdj1.wip_entity_id = wo.wip_entity_id(+)
           AND wo1.wip_entity_id = wo.wip_entity_id
           AND wo.oper = wo1.operation_seq_num
           AND wdj1.organization_id = mta.organization_id
           AND wdj1.wip_entity_id = mta.wip_entity_id(+)
           AND wdj1.organization_id = wct.organization_id
           AND wdj1.wip_entity_id = wct.wip_entity_id(+)) wpf
 WHERE wdj.wip_entity_id = we.wip_entity_id
   AND wdj.organization_id = we.organization_id
   AND wdj.primary_item_id = msi.inventory_item_id
   AND wdj.organization_id = msi.organization_id
   AND wdj.project_id = pp.project_id(+)
   AND wdj.task_id = pt.task_id(+)
   AND wdj.organization_id = wpf.organization_id(+)
   AND wdj.wip_entity_id = wpf.wip_entity_id(+)
   AND wdj.organization_id = 85
   AND pp.segment1 = '07D9202';
