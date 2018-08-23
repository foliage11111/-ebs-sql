--16.���͹�ϵ ���Թ�Ӧ���Ƕ� ORGANIZATION_ID = 142 ��
SELECT aa.customer_relation_id     ���͹�ϵid
      ,aa.organization_id          ��֯id
      ,aa.cust_account_id          �ͻ�id
      ,cc.party_name               �ͻ�����
      ,aa.cust_acct_site_id        ���͵�id
      ,dd.location                 �ͻ��ص�
      ,dd.status                   a��Ч
      ,aa.delivery_by_so_flag      Դ��co
      ,aa.outbound_trx_type_id     ��������
      ,aa.outbound_ret_trx_type_id ����r����
      ,aa.outbound_cost_ccid       �����˻�id
      ,ee.concatenated_segments    �����˻�
      ,aa.cust_org_id              �ͻ������֯id
      ,aa.inbound_trx_type_id      �������
      ,aa.inbound_ret_trx_type_id  ���r����
      ,aa.inbound_confirm_flag     ���ȷ��
      ,aa.inbound_cost_ccid        ����˻�id
      ,ff.concatenated_segments    ����˻�
      ,aa.manage_charge            �Ӽ���
      ,aa.settle_mode              ����ģʽ
      ,aa.inbound_subin_code       �����Ӳֿ�
      ,aa.outbound_subin_code      �����ӿ��
      ,aa.attribute1               ֱ����������
      ,aa.creation_date            ��������
      ,aa.created_by               ������
      ,aa.last_updated_by          ������
      ,aa.last_update_date         ��������
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
   AND cc.party_name = ' ��̵������������Զ�����˾ ';

-- ���͵�ͷ
SELECT aa.dn_header_id         ���͵�id
      ,aa.dn_number            ���͵����
      ,aa.dn_status_code       ״̬
      ,aa.cust_account_id      �ͻ�id
      ,cc.party_name           �ͻ�����
      ,aa.cust_acct_site_id    ���͵�ַid
      ,dd.location             �ͻ��ص�
      ,aa.delivery_org_id      ���ͷ���֯id
      ,aa.cust_org_id          �ͻ���֯id
      ,aa.manage_charge        ����
      ,aa.inbound_confirm_flag ���ȷ�Ϸ�
      ,aa.so_header_id         ���۶���id
      ,ee.order_number         ���۶���
      ,ee.cust_po_number       �ͻ�po
      ,ee.attribute1
      ,ee.attribute2
      ,aa.process_flag
      ,aa.comments             ���͵�˵��
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
-- ���͵���ϸ
SELECT aa.dn_header_id
      ,aa.dn_line_id
      ,aa.so_line_id
      ,ll.line_number           so�к�
      ,aa.inventory_item_id     ����id
      ,cc.segment1              ���ϱ���
      ,cc.description           ����˵��
      ,aa.outbound_subin_code   ������
      ,aa.outbound_locator_id   ������λ
      ,aa.require_date          ��������
      ,aa.require_qty           ������
      ,aa.outbound_qty          �ѳ���
      ,aa.inbound_qty           �ѽ���
      ,aa.attribute1            ���ȷ�Ͻ�����
      ,aa.inbound_subin_code    ����
      ,aa.inbound_locator_id    ����λ
      ,aa.return_no_receive_qty �˻���
      ,aa.outing_qty
      ,aa.ining_qty
      ,aa.request_id            �����ӡ����id
  FROM cux_inv_dn_lines_all   aa
      ,cux_inv_dn_headers_all bb
      ,mtl_system_items       cc
      ,oe_order_lines_all     ll
 WHERE aa.dn_header_id = bb.dn_header_id
   AND aa.inventory_item_id = cc.inventory_item_id
   AND bb.delivery_org_id = cc.organization_id
   AND aa.so_line_id = ll.line_id
   AND bb.dn_number = '14780016022';
