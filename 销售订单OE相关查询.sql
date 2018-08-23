--5. 订单 oe
--

---销售的：


SELECT oe.order_number       销售订单编号
      ,oe.ORDER_TYPE_ID      订单类型id
      ,ott.name              销售订单类型
      ,oe.CREATION_DATE      订单创建日期
      ,oe.ordered_date       订单日期
      ,cust.account_number  客户编码
      ,hp.party_name        客户名称
      ,ol.line_number        行号
      ,ol.ordered_item       物料编码
      ,msi.description      物料说明
      ,ol.order_quantity_uom 订购单位
      ,ol.ordered_quantity   订购数量
      ,ol.cancelled_quantity 取消数量
      ,ol.shipped_quantity   发运数量
      ,ol.UNIT_LIST_PRICE    价目表价格
      ,ol.UNIT_SELLING_PRICE 销售价格
      ,ol.schedule_ship_date 计划发运日期
      ,ol.booked_flag        登记标记

  FROM oe_order_headers_all  oe
      ,oe_order_lines_all    ol
      ,hz_cust_accounts      cust
      ,hz_parties            hp
      ,fnd_user         fu
      ,mtl_system_items_b    msi
      ,ont.oe_transaction_types_tl ott
      
 WHERE 1 = 1
   AND oe.header_id = ol.header_id
   AND oe.sold_to_org_id = cust.cust_account_id
   AND cust.party_id = hp.party_id
   AND ol.inventory_item_id = msi.inventory_item_id
   AND oe.created_by = fu.user_id
   and ol.SHIP_FROM_ORG_ID=msi.ORGANIZATION_ID
   AND oe.order_type_id = ott.transaction_type_id
   AND ott.LANGUAGE='ZHS'
   AND oe.ORG_ID = 8302--101组织
   AND fu.USER_NAME = 'SIE_YZR' ---叶子瑞
  order by  oe.order_number desc
--订单类型

SELECT * FROM SO_ORDER_TYPES_ALL A WHERE A.org_id=363

----------------

  SELECT *
    FROM oe_order_headers_all 销售头;
SELECT *
  FROM oe_order_lines_all 销售行;
SELECT *
  FROM wsh_new_deliveries 发送;
SELECT *
  FROM wsh_delivery_details;
SELECT *
  FROM wsh_delivery_assignments;
  
  
-- 综合查询 1- 未结销售订单
BEGIN
  mo_global.set_policy_context('S'
                              ,363); --组织化
END;



SELECT h.order_number       销售订单
      ,h.cust_po_number     客户po
      ,cust.account_number  客户编码
      ,hp.party_name        客户名称
      ,ship_use.location    收货地
      ,bill_use.location    收单地
      ,h.ordered_date       订单日期
      ,h.attribute1         合同号
      ,h.attribute2         屏号
      ,h.attribute3         来源编码
      ,l.line_number        行号
      ,l.ordered_item       物料
      ,msi.description      物料说明
      ,l.order_quantity_uom 订购单位
      ,l.ordered_quantity   订购数量
      ,l.cancelled_quantity 取消数量
      ,l.shipped_quantity   发运数量
      ,l.schedule_ship_date 计划发运日期
      ,l.booked_flag        登记标记
      ,ol.meaning           工作流状态
      ,l.cancelled_flag     取消标记
  FROM oe_order_headers_all  h
      ,oe_order_lines_all    l
      ,hz_cust_accounts      cust
      ,hz_parties            hp
      ,hz_cust_site_uses_all ship_use
      ,hz_cust_site_uses_all bill_use
      ,mtl_system_items_b    msi
      ,oe_lookups            ol
 WHERE 1 = 1
   AND h.header_id = l.header_id
   AND h.sold_to_org_id = cust.cust_account_id
   AND cust.party_id = hp.party_id
   AND h.ship_to_org_id = ship_use.site_use_id
   AND h.invoice_to_org_id = bill_use.site_use_id
   AND l.flow_status_code NOT IN ('CLOSED'
                                 ,'CANCELLED')
   AND l.inventory_item_id = msi.inventory_item_id
   AND msi.organization_id = 363
   AND l.flow_status_code = ol.lookup_code
   AND ol.lookup_type = 'LINE_FLOW_STATUS'
  /* AND cust.account_number IN ('91010072'
                              ,'91010067'
                              ,'91010036')*/
 ORDER BY party_name
         ,收货地
         ,销售订单;
