/*
organization ��������:
  1. ��Ӫ��λ��a/b/c�ֹ�˾��a������a1��a2�ȹ���������Ŀ����Ϊ�˶����������֯
org��org_id;
2. �����֯�����������̵Ĳֿ⣬����a1��a2�ȹ���
 organization_id;
 hr_organization_units ��
 org_organization_definitions 
 mtl_subinventory_ �����֯��λ
 mtl_parameters -�����֯������û����id��ֱ����name��
 mtl_system_items_b -������Ϣ��ͬ�ϣ�Ӧ���˿����֯name��
 mtl_secondary_inventories -�ӿ����֯ - 
 mtl_item_locattions -��λ - subinventroy_code
 mtl_material_transactions - (���)���������
�ɱ� mtl_transaction_accounts
transaction_cost������ɱ���
actual_cost��ͨ���ɱ��㷨���������ʵ�ʳɱ�����������λ
������
������ʷ��¼�������ϼƣ�
mtl_material_transactions
mtl_onhand_quantities����������֯/�ӿ��/��λ/��Ʒ summary���ܰ��������Ƚ��ȳ�ͳ�ƣ����������"���������"�������Ͳ����ܳ��ָ���


*/

--8. ��� inv
-- ��������
SELECT msi.organization_id            ��֯id
      ,msi.inventory_item_id          ����id
      ,msi.segment1                   ���ϱ���
      ,msi.description                ����˵��
      ,msi.item_type                  ��Ŀ����
      ,msi.planning_make_buy_code     �������
      ,msi.primary_unit_of_measure    ����������λ
      ,msi.bom_enabled_flag           bom��־
      ,msi.inventory_asset_flag       ����ʲ���
      ,msi.buyer_id                   �ɹ�Աid
      ,msi.purchasing_enabled_flag    �ɲɹ���
      ,msi.purchasing_item_flag       �ɹ���Ŀ
      ,msi.unit_of_issue              ��λ
      ,msi.inventory_item_flag        �Ƿ�Ϊ���
      ,msi.lot_control_code           �Ƿ�����
      ,msi.reservable_type            �Ƿ�ҪԤ��
      ,msi.stock_enabled_flag         �ܷ���
      ,msi.fixed_days_supply          �̶���ǰ��
      ,msi.fixed_lot_multiplier       �̶�������С
      ,msi.inventory_planning_code    ���ƻ�����
      ,msi.maximum_order_quantity     ��󶨵���
      ,msi.minimum_order_quantity     ��С������
      ,msi.full_lead_time             �̶���ǰ��
      ,msi.planner_code               �ƻ�Ա��
      ,misd.subinventory_code         �����Ӳֿ�
      ,msi.source_subinventory        ��Դ�Ӳֿ�
      ,msi.wip_supply_subinventory    ��Ӧ�Ӳֿ�
      ,msi.attribute12                �ϱ���
      ,msi.inventory_item_status_code ����״̬
      ,mss.safety_stock_quantity      ��ȫ�����
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



-- ���Ͽ������
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
         
         

-- �ƶ�ƽ���ɱ�
SELECT cst.inventory_item_id       item_id
      ,cst.organization_id         org_id
      ,cst.cost_type_id            �ɱ�����
      ,cst.item_cost               ��λ�ɱ�
      ,cst.material_cost           ���ϳɱ�
      ,cst.material_overhead_cost  ��ӷ�
      ,cst.resource_cost           �˹���
      ,cst.outside_processing_cost ��Э��
      ,cst.overhead_cost           �����
  FROM cst_item_costs cst
 WHERE cst.cost_type_id = 2
      /*AND cst.inventory_item_id = 12781*/
   AND cst.organization_id = 85;



-- �ۺϲ�ѯ - ����������ɱ�
SELECT msi.organization_id         ��֯id
      ,msi.inventory_item_id       ����id
      ,msi.segment1                ���ϱ���
      ,msi.description             ����˵��
      ,msi.planning_make_buy_code  m1p2
      ,moqv.subinventory_code      �ӿ��
      ,moqv.qty                    ��ǰ�����
      ,cst.item_cost               ��λ�ɱ�
      ,cst.material_cost           ���ϳɱ�
      ,cst.material_overhead_cost  ��ӷ�
      ,cst.resource_cost           �˹���
      ,cst.outside_processing_cost ��Э��
      ,cst.overhead_cost           �����
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


-- �ӿ���б�
SELECT *
  FROM mtl_secondary_inventories;



-- ��λ�б�
SELECT organization_id       ��֯����
      ,inventory_location_id ��λ����
      ,subinventory_code     �ӿ�����
      ,segment1              ��λ����
  FROM mtl_item_locations;
  
  
  
-- �ƻ�Ա��
SELECT planner_code    �ƻ�Ա����
      ,organization_id ��֯����
      ,description     �ƻ�Ա����
      ,mp.employee_id  Ա�� id
      ,disable_date    ʧЧ����
  FROM mtl_planners mp;
  
  
-- ��Ŀ���õȲ���
SELECT *
  FROM mtl_parameters mp;
