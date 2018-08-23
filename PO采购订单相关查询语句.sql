--7. �ɹ�����po


---�ɹ��ģ�
SELECT pha.org_id               ou_id
      ,hou.NAME                 ҵ��ʵ������
      ,pha.po_header_id         �ɹ���ͷid
      ,pha.segment1            �ɹ�����
      ,pha.type_lookup_code     ����
      ,pha.vendor_id            ��Ӧ��id
      ,vendor.vendor_name       ��Ӧ����
      ,pha.vendor_site_id       ��Ӧ�̵�ַid
      ,assa.vendor_site_code    ��Ӧ�̵ص���
      ,pla.line_num              �����к�
      ,plla.shipment_num        �����к�
      ,plla.closed_code         ������״̬
      ,msi.inventory_item_id    ����id
      ,msi.description            ��������
      ,pha.currency_code        ����
      ,pla.unit_price           ����
      ,plla.quantity            ��������
      ,plla.quantity_received   ��������
      ,plla.quantity_accepted   ��������
      ,plla.quantity_rejected   �ܾ�����
      ,plla.quantity_billed     ��������
      ,plla.quantity_cancelled   ȡ������
      ,plla.need_by_date        ��Ҫ����
      ,plla.promised_date        ��ŵ����
      ,pha.creation_date        ��������
      ,pha.authorization_status ����״̬
      ,pha.approved_flag        ������ʶ
      ,pha.approved_date        ��������
      ,pha.comments             �ɹ���˵����ע
      ,fu.user_name             ���������˺�
  
  FROM po_headers_all   pha
      ,po_lines_all     pla
      ,fnd_user         fu
      ,ap_suppliers     vendor
      ,ap_supplier_sites_all assa
      ,po_distributions_all pda --���˱�
      ,po_line_locations_all plla
      ,mtl_system_items      msi
       ,hr_operating_units           hou --ou ��ͼ
 WHERE pha.created_by = fu.user_id
  AND pha.org_id=hou.ORGANIZATION_ID
  AND pha.vendor_site_id=assa.vendor_site_id
   AND pha.vendor_id = vendor.vendor_id
   AND pha.po_header_id = pda.po_header_id
   AND plla.line_location_id=pda.line_location_id
   AND plla.po_line_id=pla.po_line_id
   and pda.destination_organization_id=msi.organization_id
   AND pha.type_lookup_code = 'STANDARD'
   AND pla.item_id = msi.inventory_item_id
     and fu.USER_NAME = 'SIE_YZR' ---Ҷ����ĵ���
     and pha.org_id=8302---101��֯
     order by pha.po_header_id desc
  ;


SELECT poh.org_id               ou_id
      ,poh.po_header_id         �ɹ���ͷid
      ,poh.type_lookup_code     ����
      ,poh.authorization_status ״̬
      ,poh.vendor_id            ��Ӧ��id
      ,vendor.vendor_name       ��Ӧ����
      ,poh.vendor_site_id       ��Ӧ�̵�ַid
      ,poh.vendor_contact_id    ��Ӧ����ϵ��id
      ,poh.ship_to_location_id  �����ջ���id
      ,poh.bill_to_location_id  �����յ���id
      ,poh.creation_date        ��������
      ,poh.approved_flag        ����yn
      ,poh.approved_date        ��������
      ,poh.comments             �ɹ���˵��
      ,poh.terms_id             ����id
      ,poh.agent_id             �ɹ�Աid
      ,agt_pp.last_name         �ɹ�Ա
      ,poh.created_by           ������id
      ,fu.user_name             �����û�
      ,pp.full_name             �û�����
  FROM po_headers_all   poh
      ,fnd_user         fu
      ,per_people_f     pp
      ,per_all_people_f agt_pp
      ,ap_suppliers     vendor
 WHERE poh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND poh.agent_id = agt_pp.person_id
   AND poh.vendor_id = vendor.vendor_id
   AND poh.org_id = 119
   AND poh.type_lookup_code = 'STANDARD'
   AND poh.segment1 = '14730005436';
/*
FND_USER FU, per_people_f PP �û���ر�
po_agents_name_v �ɹ�Ա��ͼ ----> PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID �ɹ�Ա��ر�
ap_suppliers ��Ӧ������
*/



-- �ɹ�������Ϣ
SELECT pol.org_id                ou_id
      ,pol.po_header_id          �ɹ���ͷid
      ,pol.po_line_id            ��id
      ,pol.line_num              �к�
      ,pol.item_id               ����id
      ,item.segment1             ���ϱ���
      ,pol.item_description      ����˵��
      ,pol.unit_meas_lookup_code ��λ
      ,pol.unit_price            ����
      ,po_lct.quantity           ������
      ,po_lct.quantity_received  ������
      ,po_lct.quantity_accepted  ������
      ,po_lct.quantity_rejected  �ܾ���
      ,po_lct.quantity_cancelled ȡ����
      ,po_lct.quantity_billed    ��Ʊ��
      ,po_lct.promised_date      ��ŵ����
      ,po_lct.need_by_date       ��������
  FROM po_lines_all          pol
      ,po_line_locations_all po_lct --���˱�
      ,mtl_system_items      item
 WHERE pol.org_id = po_lct.org_id
   AND pol.po_line_id = po_lct.po_line_id
   AND pol.item_id = item.inventory_item_id
   AND item.organization_id = 142
   AND pol.org_id = 119
   AND pol.po_header_id = 10068;



-- �ۺϲ�ѯ 1 �����������Ӧ����֯�����ϣ����ڲɹ�Э�飬��ȱʧ�ɹ�Ա��ȱʧ�ֿ⣻
SELECT msif.segment1         ���ϱ���
      ,msif.description      ��������
      ,msif.long_description ������ϸ����
      ,--MSIF.primary_unit_of_measure ������λ ,
       prf.last_name �ɹ�Ա
      ,misd.subinventory_code Ĭ�Ͻ��տ��
      ,pla.unit_price δ˰��
      ,round(pla.unit_price * (1 + zrb.percentage_rate / 100)
            ,2) ��˰��
      ,pv.vendor_name ��Ӧ������
  FROM apps.po_headers_all        pha
      ,apps.po_lines_all          pla
      ,apps.mtl_system_items_fvl  msif
      ,apps.mtl_item_sub_defaults misd
      ,apps.per_people_f          prf
      ,apps.po_vendors            pv
      ,apps.po_vendor_sites_all   pvsa
      ,apps.zx_rates_b            zrb
 WHERE pha.type_lookup_code = 'BLANKET'
   AND pha.org_id = 119
   AND pha.po_header_id = pla.po_header_id
   AND pha.global_agreement_flag = 'Y'
   AND pha.approved_flag IN ('Y'
                            ,'R')
   AND nvl(pha.end_date
          ,SYSDATE) >= SYSDATE
   AND nvl(pla.expiration_date
          ,SYSDATE) >= SYSDATE
   AND pla.cancel_flag = 'N'
   AND pla.item_id = msif.inventory_item_id
   AND msif.organization_id = 142
   AND msif.inventory_item_id = misd.inventory_item_id(+)
   AND misd.organization_id(+) = 142
   AND misd.default_type(+) = 2
   AND msif.buyer_id = prf.person_id(+)
   AND prf.effective_end_date(+) =
       to_date('4712-12-31'
              ,'YYYY-MM-DD')
   AND pha.vendor_id = pv.vendor_id
   AND pha.vendor_site_id = pvsa.vendor_site_id
   AND pvsa.vat_code = zrb.tax_rate_code
   AND (misd.subinventory_code IS NULL OR prf.last_name IS NULL);

-- �ɹ�������ر�
  SELECT *
 FROM po_distributions_all ����;

SELECT *
  FROM po_releases_all;
SELECT *
  FROM rcv_shipment_headers �ɹ�����ͷ;
SELECT *
  FROM rcv_shipment_lines �ɹ�������;
SELECT *
  FROM rcv_transactions ����������;
SELECT *
  FROM po_agents; --�ɹ�Ա
SELECT *
  FROM po_vendors;
SELECT *
  FROM po_vendor_sites_all;


---�ɹ�������ɹ��������--��ͨ�� pr �� po �� distribution ��� id ֱ�ӹ���
select *
  from po_headers_all poh,
       
       po_distributions_all pod,
       
       po_req_distributions_all prod,
       
       po_line_locations_all poll,
       
       po_requisition_lines_all prl,
       
       po_requisition_headers_all prh

 WHERE prh.requisition_header_id = prl.requisition_header_id
      
   AND prod.requisition_line_id = prl.requisition_line_id
      
   AND prod.distribution_id = pod.req_distribution_id
      
   AND poll.line_location_id = pod.line_location_id
      
   AND poll.po_header_id = poh.po_header_id