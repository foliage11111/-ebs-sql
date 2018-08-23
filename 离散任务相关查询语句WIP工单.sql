--10. ��ҵ���� wip ˵���� ��ѯ��ҵ����ͷ�Լ���ҵ������� bom ���
-- ��ҵ����ͷ��Ϣ��
-- ����ֱ�� OU_ID=117 �� ORGANIZATION_ID=1155; ������ WIP_ENTITY_NAME='XJ39562'; װ������� SEGMENT1 = '07D9202.92742' Ϊ����
SELECT aa.wip_entity_id   ������id
      ,aa.organization_id ��֯id
      ,aa.wip_entity_name ��������
      ,aa.entity_type     ��������
      ,aa.creation_date   ��������
      ,aa.created_by      ������id
      ,aa.description     ˵��
      ,aa.primary_item_id װ���id
      ,bb.segment1        ���ϱ���
      ,bb.description     ����˵��
  FROM wip_entities     aa
      ,mtl_system_items bb
 WHERE aa.primary_item_id = bb.inventory_item_id
   AND aa.organization_id = bb.organization_id
   AND aa.organization_id = 1155
   AND aa.wip_entity_name = 'XJ39562';
--=> WIP_ENTITY_ID = 48825

-- ��ɢ��ҵ������ϸ����Ϣ��
-- ��; 1 ����ҵ�����´Ｐ��������ѯ
-- ˵�� 1 ���˱���� wip_entities ��󲿷���Ϣ 2) �ظ���ҵ�����Ϊ wip_repetitive_items, wip_repetitive_schedules
SELECT aa.wip_entity_id             ������id
      ,bb.wip_entity_name           ��������
      ,aa.organization_id           ��֯id
      ,aa.source_line_id            ��id
      ,aa.status_type               ״̬type
      ,aa.primary_item_id           װ���id
      ,cc.segment1                  ���ϱ���
      ,cc.description               ����˵��
      ,aa.firm_planned_flag
      ,aa.job_type                  ��ҵ����
      ,aa.wip_supply_type           ��Ӧtype
      ,aa.class_code                �������
      ,aa.scheduled_start_date      ��ʼʱ��
      ,aa.date_released             �´�ʱ��
      ,aa.scheduled_completion_date �깤ʱ��
      ,aa.date_completed            �깤ʱ��
      ,aa.date_closed               ����ʱ��
      ,aa.start_quantity            �ƻ���
      ,aa.quantity_completed        �깤��
      ,aa.quantity_scrapped         ������
      ,aa.net_quantity              mrp ��ֵ
      ,aa.completion_subinventory   �����ӿ�
      ,aa.completion_locator_id     ��λ
  FROM wip_discrete_jobs aa
      ,wip.wip_entities  bb
      ,mtl_system_items  cc
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND aa.primary_item_id = cc.inventory_item_id
   AND aa.organization_id = cc.organization_id
   AND aa.organization_id = 1155
   AND bb.wip_entity_name = 'XJ39562';
   
   
   --------------------������ ��Ӧ����
   SELECT * FROM FND_LOOKUP_VALUES A WHERE A.LOOKUP_TYPE = 'WIP_SUPPLY' AND A.LANGUAGE='ZHS';

--��ɢ����״̬����

SELECT *
  FROM mfg_lookups ml
 WHERE ml.lookup_type LIKE 'WIP_JOB%';
/*
1 ������״̬ TYPE ֵ˵����

select * from mfg_lookups ml where ml.LOOKUP_TYPE like 'WIP_JOB%';

STATUS_TYPE =1 δ���ŵ� - �շѲ�����
STATUS_TYPE =3 ���� - �շ�����
STATUS_TYPE =4 ��� - �����շ�
STATUS_TYPE =5 ��� - �������շ�
STATUS_TYPE =6 �ݹ� - �������շ�
STATUS_TYPE =7 ��ȡ�� - �������շ�
STATUS_TYPE =8 �ȴ����ϵ�����
STATUS_TYPE =9 ʧ�ܵ����ϵ�����
STATUS_TYPE =10 �ȴ�·�߼���
STATUS_TYPE =11 ʧ�ܵ�·�߼���
STATUS_TYPE =12 �ر� - �����շ�
STATUS_TYPE =13 �ȴ� - ��������
STATUS_TYPE =14 �ȴ��ر�
STATUS_TYPE =15 �ر�ʧ��
2 ����Ӧ���� TYPE ֵ˵����
WIP_SUPPLY_TYPE =1 ��ʽ
WIP_SUPPLY_TYPE =2 װ����ʽ
WIP_SUPPLY_TYPE =3 ������ʽ
WIP_SUPPLY_TYPE =4 ����
WIP_SUPPLY_TYPE =5 ��Ӧ��
WIP_SUPPLY_TYPE =6 ����
WIP_SUPPLY_TYPE =7 ���ʵ�Ϊ����
*/

-- ��ɢ��ҵ������״����
SELECT aa.organization_id            ��֯id
      ,aa.wip_entity_id              ������id
      ,bb.wip_entity_name            ��������
      ,aa.operation_seq_num          �����
      ,aa.description                ��������
      ,aa.department_id              ����id
      ,aa.scheduled_quantity         �ƻ�����
      ,aa.quantity_in_queue          �Ŷ�����
      ,aa.quantity_running           ��������
      ,aa.quantity_waiting_to_move   ���ƶ�����
      ,aa.quantity_rejected          ����Ʒ����
      ,aa.quantity_scrapped          ����Ʒ����
      ,aa.quantity_completed         �깤����
      ,aa.first_unit_start_date      ����һ����λ����ʱ��
      ,aa.first_unit_completion_date ����һ����λ���ʱ��
      ,aa.last_unit_start_date       ���һ����λ����ʱ��
      ,aa.last_unit_completion_date  ���һ����λ�깤ʱ��
      ,aa.previous_operation_seq_num ǰһ�������
      ,aa.next_operation_seq_num     ��һ�������
      ,aa.count_point_type           �Ƿ��Զ��Ʒ�
      ,aa.backflush_flag             �����
      ,aa.minimum_transfer_quantity  ��С��������
      ,aa.date_last_moved            ����ƶ�ʱ��
  FROM wip_operations aa
      ,wip_entities   bb
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND bb.wip_entity_name = 'XJ39562';
-- ��ɢ��ҵ�����Ӳ�ѯ ������ ��������״����ѯ��������ʹ�ã�
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

-- ��ɢ��ҵ���� BOM ( �޲��Ϸ� )
SELECT wop.organization_id       ��֯id
      ,wop.wip_entity_id         ������id
      ,bb.wip_entity_name        װ�������
      ,bb.primary_item_id        װ���id
      ,cc.segment1               װ������ϱ���
      ,cc.description            װ���˵��
      ,wop.operation_seq_num     �����
      ,wop.department_id         ����id
      ,wop.wip_supply_type       ��Ӧ����
      ,wop.date_required         Ҫ������
      ,wop.inventory_item_id     ������id
      ,dd.segment1               �����ϱ���
      ,dd.description            ������˵��
      ,wop.quantity_per_assembly ��λ����
      ,wop.required_quantity     ��������
      ,wop.quantity_issued       �ѷ�����
      ,wop.comments              ע��
      ,wop.supply_subinventory   ��Ӧ�ӿ�
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

-- ��ҵ�����ѷ��Ų��ϴ����¼�嵥 0101 ������ϸ�� ������Ϊ 48825 Ϊ����
-- ��; 1 ����ѯ����������ϸ��ϸ�������������͡�ʱ�䡢�û���
SELECT mtl.transaction_id ����id
      ,mtl.inventory_item_id ��Ŀid
      ,cc.segment1 ���ϱ���
      ,cc.description ����˵��
      ,mtl.organization_id ��֯id
      ,mtl.subinventory_code �ӿ�����
      ,mtl.transaction_type_id ��������id
      ,bb.transaction_type_name ������������
      ,mtl.transaction_quantity ��������
      ,mtl.transaction_uom ��λ
      ,mtl.transaction_date ��������
      ,mtl.transaction_reference ���ײο�
      ,mtl.transaction_source_id �ο�Դid
      ,ff.wip_entity_name ��������
      ,mtl.department_id ���� id
      ,mtl.operation_seq_num �����
      ,round(mtl.prior_cost
            ,2) ԭ���ɱ�
      ,round(mtl.new_cost
            ,2) �³ɱ�
      ,mtl.transaction_quantity * round(mtl.prior_cost
                                       ,2) ���׽��
      ,dd.user_name �û�����
      ,ee.full_name �û�����
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
-- �������Ĳ��Ϸѻ��ܣ�������ʹ�ã�
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

-- ��ɢ��ҵ�����Ӳ�ѯ 01������ ��������״�������Ϸ��ۺϲ�ѯ
-- ��; 1 ����ѯ����״�� 2 ����ѯ���Ϸ�����С��
SELECT wop.organization_id       ��֯id
      ,wop.wip_entity_id         ������id
      ,bb.wip_entity_name        װ�������
      ,bb.primary_item_id        װ���id
      ,cc.segment1               װ������ϱ���
      ,cc.description            װ���˵��
      ,wop.operation_seq_num     �����
      ,wop.department_id         ����id
      ,wop.wip_supply_type       ��Ӧ����
      ,wop.date_required         Ҫ������
      ,wop.inventory_item_id     ������id
      ,dd.segment1               �����ϱ���
      ,dd.description            ������˵��
      ,wop.quantity_per_assembly ��λ����
      ,wop.required_quantity     ��������
      ,wop.quantity_issued       �ѷ�����
      ,cst.amt                   �ѷ������Ϸ�
      ,wop.comments              ע��
      ,wop.supply_subinventory   ��Ӧ�ӿ�
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

-- ��ɢ��ҵ�����Ӳ�ѯ 0201������ ��ҵ��Դ������ϸ��
SELECT wta.organization_id        ��֯����
      ,wta.transaction_id         ���״���
      ,wta.reference_account      �ο���Ŀ
      ,wta.transaction_date       ��������
      ,wta.wip_entity_id          ����������
      ,wta.accounting_line_type   ���������
      ,wta.base_transaction_value ���ö�
      ,wta.contra_set_id          ����������
      ,wta.primary_quantity       ��������
      ,wta.rate_or_amount         �ʻ���
      ,wta.basis_type             ��������
      ,wta.resource_id            ��Դ����
      ,wta.cost_element_id        �ɱ�Ҫ��id
      ,wta.accounting_line_type   �ɱ�����id
      ,wta.overhead_basis_factor  ��������
      ,wta.basis_resource_id      ������Դid
      ,wta.created_by             ¼����id
      ,dd.user_name               �û�����
      ,ee.full_name               �û�����
  FROM wip_transaction_accounts wta
      ,fnd_user                 dd
      ,per_people_f             ee
 WHERE wta.created_by = dd.user_id
   AND dd.employee_id = ee.person_id
   AND wta.base_transaction_value <> 0
   AND wta.organization_id = 1155
   AND wta.wip_entity_id = 48839;
-- �ɱ����� ID ACCOUNTING_LINE_TYPE
SELECT *
  FROM mfg_lookups ml
 WHERE ml.lookup_type LIKE 'CST_ACCOUNTING_LINE_TYPE'
 ORDER BY ml.lookup_code;
-- �ɱ�Ҫ�� ID COST_ELEMENT_ID
--

-- ͳ���˹���������� ( ������Ӧ�� )
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

-- �������ȼ�������Ϣ�ۺϲ�ѯ ( δ�´Ｐ�´��㷢�Ϻͱ����Ŀ����� )
SELECT we.wip_entity_name            ��������
      ,msi.segment1                  ����
      ,msi.description               ��������
      ,msi.primary_unit_of_measure   ��λ
      ,wdj.scheduled_start_date      �ƻ���ʼʱ��
      ,wdj.scheduled_completion_date �ƻ����ʱ��
      ,wdj.start_quantity            ��������
      ,wdj.quantity_completed        �������
      ,wdj.date_released             ʵ�ʿ�ʼʱ��
      ,wdj.date_completed            ʱ�����ʱ��
      ,wdj.description               ������ע
      ,pp.segment1                   ��Ŀ��
      ,pp.description                ��Ŀ����
      ,pt.task_number                �����
      ,pt.description                ��������
      ,wo.count_oper                 ������
      ,wo1.operation_seq_num         ��ǰ����
      ,wo1.description               ��ǰ��������
      ,mta.mt_fee                    ���Ϸ�
      ,wct.hr_fee                    �˹���
      ,wct.md_fee                    �����
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
      , -- �������
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
      , -- ���Ϸ�
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
                 ,wta_cost.wip_entity_id) wct -- �˹�������
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

-- �������ȼ�������Ϣ�ۺϲ�ѯ ( �����Ƿ��´�ͷ��϶��ܿ��� )
SELECT wdj.wip_entity_id           ������id
      ,we.wip_entity_name          ��������
      ,wdj.organization_id         ��֯id
      ,wdj.status_type             ״̬
      ,wdj.primary_item_id         װ���id
      ,msi.segment1                ���ϱ���
      ,msi.description             ����˵��
      ,wdj.firm_planned_flag       ��������
      ,wdj.job_type                ��ҵ����
      ,wdj.wip_supply_type         ��Ӧ����
      ,wdj.class_code              �������
      ,wdj.scheduled_start_date    ��ʼʱ��
      ,wdj.date_released           �´�ʱ��
      ,wdj.date_completed          �깤ʱ��
      ,wdj.date_closed             �ر�ʱ��
      ,wdj.start_quantity          �ƻ���
      ,wdj.quantity_completed      �깤��
      ,wdj.quantity_scrapped       ������
      ,wdj.net_quantity            mrp ��ֵ
      ,wdj.description             ������ע
      ,wdj.completion_subinventory �����ӿ�
      ,wdj.completion_locator_id   ��λid
      ,wdj.project_id              ��Ŀid
      ,wdj.task_id                 ��Ŀ����id
      ,pp.segment1                 ��Ŀ��
      ,pp.description              ��Ŀ����
      ,pt.task_number              �����
      ,pt.description              ��������
      ,wpf.count_oper              ������
      ,wpf.cur_oper                ��ǰ����
      ,wpf.cur_opername            ������
      ,wpf.mt_fee                  ���Ϸ�
      ,wpf.hr_fee                  �˹���
      ,wpf.md_fee                  �����
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
                         ,wdj.wip_entity_id) wo -- �������
              ,(SELECT mtl.organization_id
                      ,mtl.transaction_source_id wip_entity_id
                      ,abs(SUM(mtl.transaction_quantity * mtl.actual_cost)) mt_fee
                  FROM mtl_material_transactions mtl
                 WHERE mtl.transaction_type_id IN (35
                                                  ,38
                                                  ,43
                                                  ,48)
                 GROUP BY mtl.organization_id
                         ,mtl.transaction_source_id) mta -- ���Ϸ�
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
                         ,wta_cost.wip_entity_id) wct -- �˹�������
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
