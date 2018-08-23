--6. �ɹ����� pr
-- ���뵥ͷ 
SELECT prh.requisition_header_id  ���뵥ͷid
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               ���뵥���
      ,prh.creation_date          ��������
      ,prh.created_by             ������id
      ,fu.user_name               �û�����
      ,pp.full_name               �û�����
      ,prh.approved_date          ��׼����
      ,prh.description            ˵��
      ,prh.authorization_status   ״̬
      ,prh.type_lookup_code       ����
      ,prh.transferred_to_oe_flag ���ݱ�ʾ
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.org_id = 82
   AND prh.segment1 = '14140002781';
-->> �ڲ����� =14140002781 ���뵥ͷ ID = 3379
-- ���뵥����ϸ
SELECT prl.requisition_header_id       ���뵥id
      ,prl.requisition_line_id         ��id
      ,prl.line_num                    �к�
      ,prl.category_id                 ����id
      ,prl.item_id                     ����id
      ,item.segment1                   ���ϱ���
      ,prl.item_description            ����˵��
      ,prl.quantity                    ������
      ,prl.quantity_delivered          �ͻ���
      ,prl.quantity_cancelled          ȡ����
      ,prl.unit_meas_lookup_code       ��λ
      ,prl.unit_price                  �ο���
      ,prl.need_by_date                ��������
      ,prl.source_type_code            ��Դ����
      ,prl.org_id                      ou_id
      ,prl.source_organization_id      �Է���֯id
      ,prl.destination_organization_id ������֯id
  FROM po_requisition_lines_all prl
      ,mtl_system_items         item
 WHERE prl.org_id = 82
   AND prl.item_id = item.inventory_item_id
   AND prl.destination_organization_id = item.organization_id
  /* AND prl.requisition_header_id = 3379*/;
-- ���뵥ͷ ( �ӶԷ�������� )
SELECT prh.requisition_header_id  ���뵥ͷid
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               ���뵥���
      ,prh.creation_date          ��������
      ,prh.created_by             ������id
      ,fu.user_name               �û�����
      ,pp.full_name               �û�����
      ,prh.approved_date          ��׼����
      ,prh.description            ˵��
      ,prh.authorization_status   ״̬
      ,prh.type_lookup_code       ����
      ,prh.transferred_to_oe_flag ���ݱ�ʾ
      ,oeh.order_number           �Է�co���
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
      ,oe_order_headers_all       oeh
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.requisition_header_id = oeh.source_document_id(+)
   AND prh.org_id = 82
   /*AND prh.segment1 = '14140002781'*/;
--( ���۶�����¼�жԷ� OU_ID, ���뵥�ؼ��� SOURCE_DOCUMENT_ID ���뵥�� SOURCE_DOCEMENT_REF)

** ** ** ** ** ** ** ** ** * �ۺϲ�ѯ�� ** ** ** ** ** ** ** ** ** *
-- ���뵥ͷ�ۺϲ�ѯ ��������ֻ�ܲ�ѯ -- ������֯ ORG_ID=112)
  SELECT prh.requisition_header_id       ���뵥ͷid
        ,prh.org_id                      ��֯id
        ,prh.segment1                    ���뵥���
        ,prh.creation_date               ��������
        ,prh.created_by                  ������id
        ,fu.user_name                    �û�����
        ,pp.full_name                    �û�����
        ,prh.approved_date               ��׼����
        ,prh.description                 ˵��
        ,prh.authorization_status        ״̬
        ,prh.type_lookup_code            ����
        ,prh.transferred_to_oe_flag      ���ݱ�ʾ
        ,prl.requisition_line_id         ��id
        ,prl.line_num                    �к�
        ,prl.category_id                 ����id
        ,prl.item_id                     ����id
        ,item.segment1                   ���ϱ���
        ,prl.item_description            ����˵��
        ,prl.quantity                    ������
        ,prl.quantity_delivered          �ͻ���
        ,prl.quantity_cancelled          ȡ����
        ,prl.unit_meas_lookup_code       ��λ
        ,prl.unit_price                  �ο���
        ,prl.need_by_date                ��������
        ,prl.source_type_code            ��Դ����
        ,prl.source_organization_id      �Է���֯id
        ,prl.destination_organization_id ������֯id
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
