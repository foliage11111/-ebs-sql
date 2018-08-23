--16.配送关系 （以供应处角度 ORGANIZATION_ID = 142 ）
SELECT aa.customer_relation_id     配送关系id
      ,aa.organization_id          组织id
      ,aa.cust_account_id          客户id
      ,cc.party_name               客户名称
      ,aa.cust_acct_site_id        配送地id
      ,dd.location                 客户地点
      ,dd.status                   a有效
      ,aa.delivery_by_so_flag      源于co
      ,aa.outbound_trx_type_id     出库类型
      ,aa.outbound_ret_trx_type_id 出库r类型
      ,aa.outbound_cost_ccid       出库账户id
      ,ee.concatenated_segments    出库账户
      ,aa.cust_org_id              客户库存组织id
      ,aa.inbound_trx_type_id      入库类型
      ,aa.inbound_ret_trx_type_id  入库r类型
      ,aa.inbound_confirm_flag     入库确认
      ,aa.inbound_cost_ccid        入库账户id
      ,ff.concatenated_segments    入库账户
      ,aa.manage_charge            加价率
      ,aa.settle_mode              结算模式
      ,aa.inbound_subin_code       接收子仓库
      ,aa.outbound_subin_code      配送子库存
      ,aa.attribute1               直接生产发料
      ,aa.creation_date            创建日期
      ,aa.created_by               创建者
      ,aa.last_updated_by          更新者
      ,aa.last_update_date         更新日期
  FROM cux_inv_customer_relation_all aa
      ,hz_cust_accounts              bb
      ,hz_parties                    cc
      ,hz_cust_site_uses_all         dd
      ,gl_code_combinations_kfv      ee
      ,gl_code_combinations_kfv      ff
 WHERE aa.organization_id = 142
   AND aa.cust_account_id = bb.cust_account_id
   AND bb.party_id = cc.party_id
   AND aa.cust_acct_site_id = dd.site_use_id
   AND dd.status = 'A'
   AND aa.outbound_cost_ccid = ee.code_combination_id
   AND aa.inbound_cost_ccid = ff.code_combination_id
   AND cc.party_name = ' 许继电气电网保护自动化公司 ';

-- 配送单头
SELECT aa.dn_header_id         配送单id
      ,aa.dn_number            配送单编号
      ,aa.dn_status_code       状态
      ,aa.cust_account_id      客户id
      ,cc.party_name           客户名称
      ,aa.cust_acct_site_id    配送地址id
      ,dd.location             客户地点
      ,aa.delivery_org_id      配送方组织id
      ,aa.cust_org_id          客户组织id
      ,aa.manage_charge        费率
      ,aa.inbound_confirm_flag 入库确认否
      ,aa.so_header_id         销售订单id
      ,ee.order_number         销售订单
      ,ee.cust_po_number       客户po
      ,ee.attribute1
      ,ee.attribute2
      ,aa.process_flag
      ,aa.comments             配送单说明
  FROM cux_inv_dn_headers_all aa
      ,hz_cust_accounts       bb
      ,hz_parties             cc
      ,hz_cust_site_uses_all  dd
      ,oe_order_headers_all   ee
 WHERE aa.delivery_org_id = 142
   AND aa.cust_account_id = bb.cust_account_id
   AND bb.party_id = cc.party_id
   AND aa.cust_acct_site_id = dd.site_use_id
   AND dd.status = 'A'
   AND aa.so_header_id = ee.header_id
   AND aa.dn_number = '14780016022';
-- 配送单明细
SELECT aa.dn_header_id
      ,aa.dn_line_id
      ,aa.so_line_id
      ,ll.line_number           so行号
      ,aa.inventory_item_id     物料id
      ,cc.segment1              物料编码
      ,cc.description           物料说明
      ,aa.outbound_subin_code   发出仓
      ,aa.outbound_locator_id   发出货位
      ,aa.require_date          需求日期
      ,aa.require_qty           需求数
      ,aa.outbound_qty          已出库
      ,aa.inbound_qty           已接收
      ,aa.attribute1            最近确认接收数
      ,aa.inbound_subin_code    入库仓
      ,aa.inbound_locator_id    入库货位
      ,aa.return_no_receive_qty 退回数
      ,aa.outing_qty
      ,aa.ining_qty
      ,aa.request_id            最近打印请求id
  FROM cux_inv_dn_lines_all   aa
      ,cux_inv_dn_headers_all bb
      ,mtl_system_items       cc
      ,oe_order_lines_all     ll
 WHERE aa.dn_header_id = bb.dn_header_id
   AND aa.inventory_item_id = cc.inventory_item_id
   AND bb.delivery_org_id = cc.organization_id
   AND aa.so_line_id = ll.line_id
   AND bb.dn_number = '14780016022';
