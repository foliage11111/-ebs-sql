--6. 采购申请 pr
-- 申请单头 
SELECT prh.requisition_header_id  申请单头id
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               申请单编号
      ,prh.creation_date          创建日期
      ,prh.created_by             编制人id
      ,fu.user_name               用户名称
      ,pp.full_name               用户姓名
      ,prh.approved_date          批准日期
      ,prh.description            说明
      ,prh.authorization_status   状态
      ,prh.type_lookup_code       类型
      ,prh.transferred_to_oe_flag 传递标示
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.org_id = 82
   AND prh.segment1 = '14140002781';
-->> 内部申请 =14140002781 申请单头 ID = 3379
-- 申请单行明细
SELECT prl.requisition_header_id       申请单id
      ,prl.requisition_line_id         行id
      ,prl.line_num                    行号
      ,prl.category_id                 分类id
      ,prl.item_id                     物料id
      ,item.segment1                   物料编码
      ,prl.item_description            物料说明
      ,prl.quantity                    需求数
      ,prl.quantity_delivered          送货数
      ,prl.quantity_cancelled          取消数
      ,prl.unit_meas_lookup_code       单位
      ,prl.unit_price                  参考价
      ,prl.need_by_date                需求日期
      ,prl.source_type_code            来源类型
      ,prl.org_id                      ou_id
      ,prl.source_organization_id      对方组织id
      ,prl.destination_organization_id 本方组织id
  FROM po_requisition_lines_all prl
      ,mtl_system_items         item
 WHERE prl.org_id = 82
   AND prl.item_id = item.inventory_item_id
   AND prl.destination_organization_id = item.organization_id
  /* AND prl.requisition_header_id = 3379*/;
-- 申请单头 ( 加对方订单编号 )
SELECT prh.requisition_header_id  申请单头id
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               申请单编号
      ,prh.creation_date          创建日期
      ,prh.created_by             编制人id
      ,fu.user_name               用户名称
      ,pp.full_name               用户姓名
      ,prh.approved_date          批准日期
      ,prh.description            说明
      ,prh.authorization_status   状态
      ,prh.type_lookup_code       类型
      ,prh.transferred_to_oe_flag 传递标示
      ,oeh.order_number           对方co编号
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
      ,oe_order_headers_all       oeh
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.requisition_header_id = oeh.source_document_id(+)
   AND prh.org_id = 82
   /*AND prh.segment1 = '14140002781'*/;
--( 销售订单记录有对方 OU_ID, 申请单关键字 SOURCE_DOCUMENT_ID 申请单号 SOURCE_DOCEMENT_REF)

** ** ** ** ** ** ** ** ** * 综合查询类 ** ** ** ** ** ** ** ** ** *
-- 申请单头综合查询 （进限制只能查询 -- 电网组织 ORG_ID=112)
  SELECT prh.requisition_header_id       申请单头id
        ,prh.org_id                      组织id
        ,prh.segment1                    申请单编号
        ,prh.creation_date               创建日期
        ,prh.created_by                  编制人id
        ,fu.user_name                    用户名称
        ,pp.full_name                    用户姓名
        ,prh.approved_date               批准日期
        ,prh.description                 说明
        ,prh.authorization_status        状态
        ,prh.type_lookup_code            类型
        ,prh.transferred_to_oe_flag      传递标示
        ,prl.requisition_line_id         行id
        ,prl.line_num                    行号
        ,prl.category_id                 分类id
        ,prl.item_id                     物料id
        ,item.segment1                   物料编码
        ,prl.item_description            物料说明
        ,prl.quantity                    需求数
        ,prl.quantity_delivered          送货数
        ,prl.quantity_cancelled          取消数
        ,prl.unit_meas_lookup_code       单位
        ,prl.unit_price                  参考价
        ,prl.need_by_date                需求日期
        ,prl.source_type_code            来源类型
        ,prl.source_organization_id      对方组织id
        ,prl.destination_organization_id 本方组织id
    FROM po_requisition_headers_all prh
        ,fnd_user                   fu
        ,per_people_f               pp
        ,po_requisition_lines_all   prl
        ,mtl_system_items           item
   WHERE prh.created_by = fu.user_id
     AND fu.employee_id = pp.person_id
     AND prh.requisition_header_id = prl.requisition_header_id
     AND prh.org_id = prl.org_id
     AND prl.item_id = item.inventory_item_id
     AND prl.destination_organization_id = item.organization_id
     AND prh.org_id = 82;
