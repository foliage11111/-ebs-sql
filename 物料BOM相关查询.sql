--9. �����嵥 bom
--BOM ���� bom_bill_of_materials
  SELECT aa.bill_sequence_id �嵥���
        ,aa.assembly_item_id װ�������
        ,aa.organization_id  ��֯����
        ,bb.segment1         ���ϱ���
        ,bb.description      ����˵��
        ,aa.assembly_type    װ�����
    FROM bom_bill_of_materials aa �� mtl_system_items bb
   WHERE aa.assembly_item_id = bb.inventory_item_id
     AND aa.organization_id = bb.organization_id;

--BOM ��ϸ�� bom_inventory_components
SELECT bill_sequence_id      �嵥���
      ,component_sequence_id �������
      ,item_num              ��Ŀ����
      ,operation_seq_num     �������к�
      ,component_item_id     ����������
      ,component_quantity    ��������
      ,disable_date          ʧЧ����
      ,supply_subinventory   ��Ӧ�ӿ��
      ,bom_item_type
  FROM bom_inventory_components;

--BOM ��ϸ�ۺϲ�ѯ ( ��֯ �޶���Ӧ�� 142 װ��� = '5XJ061988')
SELECT vbom.bid                   �嵥���
      ,vbom.f_itemid              װ�������
      ,bb.segment1                ���ϱ���
      ,bb.description             ����˵��
      ,vbom.ogt_id                ��֯����
      ,vbom.cid                   ���� id
      ,vbom.item_num              �������
      ,vbom.opid                  ����
      ,vbom.c_itemid              ����������
      ,cc.segment1                ���ϱ���
      ,cc.description             ����˵��
      ,vbom.qty                   ��������
      ,cc.primary_uom_code        �Ӽ�����λ��
      ,cc.primary_unit_of_measure �Ӽ�����λ��
      ,vbom.whse                  ��Ӧ�Ӳֿ�
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

-- ���� BOM �ɱ���ѯ ( ��ϵͳ�ύ�������� )
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
--�����ǵ���bomչ����������չ��bom����ײ㣺
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
---�ر�˵����level connect_by_isleaf connect_by_root sys_connect_by_path(bbm.assembly_item_id, '/') ����start
--- WITH ���� CONNECT BY �����ú������ֶ� 
