--5. ���� oe
--

---���۵ģ�


SELECT oe.order_number       ���۶������
      ,oe.ORDER_TYPE_ID      ��������id
      ,ott.name              ���۶�������
      ,oe.CREATION_DATE      ������������
      ,oe.ordered_date       ��������
      ,cust.account_number  �ͻ�����
      ,hp.party_name        �ͻ�����
      ,ol.line_number        �к�
      ,ol.ordered_item       ���ϱ���
      ,msi.description      ����˵��
      ,ol.order_quantity_uom ������λ
      ,ol.ordered_quantity   ��������
      ,ol.cancelled_quantity ȡ������
      ,ol.shipped_quantity   ��������
      ,ol.UNIT_LIST_PRICE    ��Ŀ��۸�
      ,ol.UNIT_SELLING_PRICE ���ۼ۸�
      ,ol.schedule_ship_date �ƻ���������
      ,ol.booked_flag        �ǼǱ��

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
   AND oe.ORG_ID = 8302--101��֯
   AND fu.USER_NAME = 'SIE_YZR' ---Ҷ����
  order by  oe.order_number desc
--��������

SELECT * FROM SO_ORDER_TYPES_ALL A WHERE A.org_id=363

----------------

  SELECT *
    FROM oe_order_headers_all ����ͷ;
SELECT *
  FROM oe_order_lines_all ������;
SELECT *
  FROM wsh_new_deliveries ����;
SELECT *
  FROM wsh_delivery_details;
SELECT *
  FROM wsh_delivery_assignments;
  
  
-- �ۺϲ�ѯ 1- δ�����۶���
BEGIN
  mo_global.set_policy_context('S'
                              ,363); --��֯��
END;



SELECT h.order_number       ���۶���
      ,h.cust_po_number     �ͻ�po
      ,cust.account_number  �ͻ�����
      ,hp.party_name        �ͻ�����
      ,ship_use.location    �ջ���
      ,bill_use.location    �յ���
      ,h.ordered_date       ��������
      ,h.attribute1         ��ͬ��
      ,h.attribute2         ����
      ,h.attribute3         ��Դ����
      ,l.line_number        �к�
      ,l.ordered_item       ����
      ,msi.description      ����˵��
      ,l.order_quantity_uom ������λ
      ,l.ordered_quantity   ��������
      ,l.cancelled_quantity ȡ������
      ,l.shipped_quantity   ��������
      ,l.schedule_ship_date �ƻ���������
      ,l.booked_flag        �ǼǱ��
      ,ol.meaning           ������״̬
      ,l.cancelled_flag     ȡ�����
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
         ,�ջ���
         ,���۶���;
