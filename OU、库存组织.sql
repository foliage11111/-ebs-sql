--1. OU、库存组织 
SELECT hou.organization_id          ou_org_id
      ,hou.name                     ou_name
      ,ood.organization_id          org_org_id
      ,ood.organization_code        org_org_code
      ,msi.secondary_inventory_name
      ,msi.description
  FROM hr_organization_information  hoi -- 组织分类表
      ,hr_operating_units           hou --ou 视图
      ,org_organization_definitions ood -- 库存组织定义视图
      ,mtl_secondary_inventories    msi -- 子库存信息表
 WHERE hoi.org_information1 = 'OPERATING_UNIT'
   AND hoi.organization_id = hou.organization_id
   AND ood.operating_unit = hoi.organization_id
   AND ood.organization_id = msi.organization_id;
   
   
   
-- 获取系统 ID
CALL fnd_global.apps_initialize(user_id, resp_id, resp_appl_id)
  SELECT fnd_profile.value('ORG_ID')
    FROM dual
          SELECT *
            FROM hr_operating_units hou
           WHERE hou.organization_id = 85;
