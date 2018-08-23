--1. OU、库存组织 
SELECT hou.organization_id          ou_org_id
      ,hou.name                     ou_name
      ,ood.organization_id          org_org_id
      ,ood.organization_code        org_org_code
      ,msi.secondary_inventory_name --子库名称
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
CALL fnd_global.apps_initialize(user_id
                               ,resp_id
                               ,resp_appl_id);
SELECT fnd_profile.value('ORG_ID')
  FROM dual;
  
SELECT *
  FROM hr_operating_units hou
 WHERE hou.organization_id = 85;

--2. 用户、责任及 hr
-- 系统责任定义 VIEW(FROM FND_RESPONSIBILITY_TL, FND_RESPONSIBILITY)
SELECT application_id
      ,responsibility_id
      ,responsibility_key
      ,end_date
      ,responsibility_name
      ,description
  FROM fnd_responsibility_vl;

-- 用户责任关系
SELECT user_id
      ,responsibility_id
  FROM fnd_user_resp_groups;
-- 用户表
SELECT user_id
      ,user_name
      ,employee_id
      ,person_party_id
      ,end_date
  FROM fnd_user;
-- 人员表 VIEW
SELECT person_id
      ,start_date
      ,date_of_birth
      ,employee_number
      ,national_identifier
      ,sex
      ,full_name
  FROM per_people_f;
-- 综合查询
SELECT user_name
      ,full_name
      ,responsibility_name
      ,cc.description
  FROM fnd_user              aa
      ,fnd_user_resp_groups  bb
      ,fnd_responsibility_vl cc
      ,per_people_f          dd
 WHERE aa.user_id = bb.user_id
   AND bb.responsibility_id = cc.responsibility_id
   AND aa.employee_id = dd.person_id
   AND responsibility_name LIKE '% 供应处 %'
 ORDER BY user_name;
-- 综合查询
-- 人员状况基本信息表
SELECT paf.person_id 系统id
      ,paf.full_name 姓名
      ,paf.date_of_birth 出生日期
      ,paf.region_of_birth 出生地区
      ,paf.national_identifier 身份证号
      ,paf.attribute1 招工来源
      ,paf.attribute3 员工类型
      ,paf.attribute11 集团合同号
      ,paf.original_date_of_hire 参加工作日期
      ,paf.per_information17 省份
      ,decode(paf.sex
             ,'M'
             ,' 男 '
             ,'F'
             ,' 女 '
             ,'NULL') 性别 --decode 适合和同一值做比较有多种结果，不适合和多种值比较有多种结果
      ,CASE paf.sex
         WHEN 'M' THEN
          ' 男 '
         WHEN 'F' THEN
          ' 女 '
         ELSE
          'NULL'
       END 性别 1 --case 用法一
      ,CASE
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1960' THEN
          '50 年代 '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1970' THEN
          '60 年代 '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1980' THEN
          '70 年代 '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1990' THEN
          '80 年代 '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '2000' THEN
          '90 年代 '
         ELSE
          '21 世纪 ' --case 用法二
       END 出生年代
  FROM per_all_people_f paf;

--3. 供应商 vendor
-- 供应商主表数据：
SELECT ass.vendor_id                  vendor_id
      ,ass.party_id                   party_id
      ,ass.segment1                   vendor_code
      ,ass.vendor_name                vendor_name
      ,ass.vendor_name                vendor_short_name
      ,ass.vendor_type_lookup_code    vendor_type
      ,flv.meaning                    vendor_type_meaning
      ,hp.tax_reference               tax_registered_name
      ,ass.payment_method_lookup_code payment_method
      ,att.name                       term_name
      ,att.enabled_flag               enabled_flag
      ,att.end_date_active            end_date_active
      ,ass.creation_date              creation_date
      ,ass.created_by                 created_by
      ,ass.last_update_date           last_update_date
      ,ass.last_updated_by            last_updated_by
      ,ass.last_update_login          last_update_login
  FROM ap_suppliers      ass
      ,fnd_lookup_values flv
      ,hz_parties        hp
      ,ap_terms_tl       att
 WHERE ass.vendor_type_lookup_code = flv.lookup_code(+)
   AND flv.lookup_type(+) = 'VENDOR TYPE'
   AND flv.language(+) = userenv('LANG')
   AND ass.party_id = hp.party_id
   AND att.language = userenv('LANG')
   AND ass.terms_id = att.term_id(+)
-- 供应商银行信息
  SELECT ass.vendor_id         vendor_id
        ,ass.party_id          party_id
        ,bank.party_id         bank_id
        ,bank.party_name       bank_name
        ,branch.party_id       branch_id
        ,branch.party_name     bank_branch_name
        ,ieba.bank_account_num bank_account_num
          FROM ap_suppliers          ass
        ,hz_parties            hp
        ,iby_account_owners    iao
        ,iby_ext_bank_accounts ieba
        ,hz_parties            bank
        ,hz_parties            branch
         WHERE ass.party_id = hp.party_id
           AND hp.party_id = iao.account_owner_party_id(+)
           AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
           AND ieba.bank_id = bank.party_id(+)
           AND ieba.branch_id = branch.party_id(+)
         ORDER BY ieba.creation_date;


-- 供应商开户行地址信息
SELECT hps.party_id      party_id
      ,hps.party_site_id party_site_id
      ,hl.location_id    location_id
      ,hl.country        country
      ,hl.province       province
      ,hl.city           city
      ,hl.address1       address1
      ,hl.address2       address2
      ,hl.address3       address3
      ,hl.address4       address4
  FROM hz_party_sites hps
      ,hz_locations   hl
 WHERE hps.location_id = hl.location_id
 ORDER BY hps.creation_date;
-- 供应商联系人信息
SELECT hr.subject_id subject_id
      ,hr.object_id object_id
      ,hr.party_id party_id
      ,hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
       hp.person_first_name contact_person
      ,hcpp.phone_area_code phone_area_code
      ,hcpp.phone_number phone_number
      ,hcpp.phone_extension phone_extension
      ,hcpf.phone_area_code fax_phone_area_code
      ,hcpf.phone_number fax_phone_number
      ,hcpe.email_address email_address
  FROM hz_relationships  hr
      ,hz_contact_points hcpp
      ,hz_contact_points hcpf
      ,hz_contact_points hcpe
      ,hz_parties        hp
 WHERE hr.object_id = hp.party_id
   AND hcpp.owner_table_id(+) = hr.party_id
   AND hcpf.owner_table_id(+) = hr.party_id
   AND hcpe.owner_table_id(+) = hr.party_id
   AND hr.object_type = 'PERSON'
   AND hr.relationship_code(+) = 'CONTACT'
   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpf.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpp.contact_point_type(+) = 'PHONE'
   AND hcpp.phone_line_type(+) = 'GEN'
   AND hcpf.contact_point_type(+) = 'PHONE'
   AND hcpf.phone_line_type(+) = 'FAX'
   AND hcpe.contact_point_type(+) = 'EMAIL'
   AND hcpe.phone_line_type IS NULL
 ORDER BY hr.creation_date;

-- 供应商地址主信息
SELECT assa.vendor_site_id       vendor_site_id
      ,assa.vendor_id            vendor_id
      ,assa.vendor_site_code     vendor_code
      ,assa.vendor_site_code     address_short_name
      ,assa.address_line1        address_line1
      ,assa.address_line2        address_line2
      ,assa.address_line3        address_line3
      ,assa.address_line4        address_line4
      ,assa.org_id               org_id
      ,assa.country              country
      ,assa.province             province
      ,assa.city                 city
      ,assa.county               county
      ,assa.zip                  zip
      ,assa.pay_site_flag        pay_site_flag
      ,assa.purchasing_site_flag purchasing_site_flag
      ,assa.inactive_date        inactive_date
      ,assa.creation_date        creation_date
      ,assa.created_by           created_by
      ,assa.last_update_date     last_update_date
      ,assa.last_updated_by      last_updated_by
      ,assa.last_update_login    last_update_login
  FROM ap_suppliers          ass
      ,ap_supplier_sites_all assa
 WHERE assa.vendor_id = ass.vendor_id;
-- 供应商地址联系人信息： phone 、 fax 和 Email
SELECT hcpp.phone_area_code phone_area_code
      ,hcpp.phone_number    phone_number
      ,hcpp.phone_extension phone_extension
      ,hcpf.phone_area_code fax_phone_area_code
      ,hcpf.phone_number    fax_phone_number
      ,hcpe.email_address   email_address
  FROM ap_supplier_sites_all assa
      ,hz_contact_points     hcpp
      ,hz_contact_points     hcpf
      ,hz_contact_points     hcpe
      ,hz_party_sites        hps
 WHERE assa.party_site_id = hps.party_site_id
   AND hcpp.owner_table_id(+) = assa.party_site_id
   AND hcpf.owner_table_id(+) = assa.party_site_id
   AND hcpe.owner_table_id(+) = assa.party_site_id
   AND hcpp.owner_table_name(+) = 'HZ_PARTY_SITES'
   AND hcpf.owner_table_name(+) = 'HZ_PARTY_SITES'
   AND hcpe.owner_table_name(+) = 'HZ_PARTY_SITES'
   AND hcpp.contact_point_type(+) = 'PHONE'
   AND hcpp.phone_line_type(+) = 'GEN'
   AND hcpf.contact_point_type(+) = 'PHONE'
   AND hcpf.phone_line_type(+) = 'FAX'
   AND hcpe.contact_point_type(+) = 'EMAIL'
   AND hcpe.phone_line_type IS NULL;
-- 供应商地址收件人信息
SELECT assa.party_site_id
  FROM ap_supplier_sites_all assa
       -- 根据 party_site_id 得到供应商地址的收件人名称
         SELECT hps.addressee
           FROM hz_party_sites hps;


-- 供应商银行帐户分配层次关系
SELECT *
  FROM iby_pmt_instr_uses_all;
-- 供应商银行帐户分配层次关系明细 ( 不包括供应商层的分配信息 ):
SELECT *
  FROM iby_external_payees_all;

--4. 客户 customer
--SQL 查询
-- 客户账户表 以许继 1063 电网客户为例 -->>PARTY_ID = 21302
SELECT *
  FROM hz_cust_accounts aa
 WHERE aa.cust_account_id = 1063;

-- 客户名称及地址全局信息表 -->> PARTY_NUMBER = 19316
SELECT *
  FROM hz_parties aa
 WHERE aa.party_id = 21302;

-- 客户地点账户主文件
SELECT *
  FROM hz_cust_acct_sites_all
 WHERE cust_account_id = 1063;

-- 客户地点 ( 关联 hz_cust_acct_sites_all)
SELECT *
  FROM hz_party_sites
 WHERE party_id = 21302;

-- 地点地址名称 ( 关联 hz_cust_acct_sites_all)
SELECT aa.address1
      ,aa.address_key
  FROM hz_locations   aa
      ,hz_party_sites bb
 WHERE aa.location_id = bb.location_id
   AND bb.party_id = 21302;

-- 客户地点业务目的 ( 关联 hz_cust_acct_sites_all 用 CUST_ACCT_SITE_ID)
SELECT *
  FROM hz_cust_site_uses_all;

-- 客户地点详细信息表，以供应处 OU 的身份 ORG_ID = 119
SELECT aa.party_site_id            客户组织地点id
      ,aa.party_id                 客户组织id
      ,aa.location_id              地点id
      ,aa.party_site_number        地点编号
      ,aa.identifying_address_flag 地址标示
      ,aa.status                   有效否
      ,aa.party_site_name
      ,bb.org_id                   业务实体
      ,bb.bill_to_flag             收单标示
      ,bb.ship_to_flag             收货标示
      ,cc.address1                 地点名称
      ,dd.site_use_id
      ,dd.site_use_code
      ,dd.primary_flag
      ,dd.status
      ,dd.location                 业务目的
      ,dd.bill_to_site_use_id      收单地id
      ,dd.tax_code
  FROM hz_party_sites         aa
      ,hz_cust_acct_sites_all bb
      ,hz_locations           cc
      ,hz_cust_site_uses_all  dd
 WHERE aa.party_site_id = bb.party_site_id
   AND bb.cust_account_id = 1063
   AND bb.org_id = 119
   AND aa.status = 'A'
   AND aa.location_id = cc.location_id
   AND bb.cust_acct_site_id(+) = dd.cust_acct_site_id
   AND dd.status <> 'I';

--************* 综合查询 ************--
-- 客户主数据
SELECT hca.cust_account_id     customer_id
      ,hp.party_number         customer_number
      ,hp.party_name           customer_name
      ,hp.party_name           customer_short_name
      ,hca.customer_type       customer_type
      ,alt.meaning             customer_type_meaning
      ,hca.customer_class_code customer_class
      ,alc.meaning             customer_class_meaning
      ,hp.tax_reference        tax_registered_name
      ,rt.name                 term_name
      ,hca.creation_date       creation_date
      ,hca.created_by          created_by
      ,hca.last_update_date    last_update_date
      ,hca.last_updated_by     last_updated_by
      ,hca.last_update_login   last_update_login
  FROM hz_parties           hp
      ,hz_cust_accounts     hca
      ,ar_lookups           alt
      ,ar_lookups           alc
      ,hz_customer_profiles hcp
      ,ra_terms             rt
 WHERE hp.party_id = hca.party_id
   AND hca.customer_type = alt.lookup_code(+)
   AND alt.lookup_type = 'CUSTOMER_TYPE'
   AND hca.customer_class_code = alc.lookup_code(+)
   AND alc.lookup_type(+) = 'CUSTOMER CLASS'
   AND hca.cust_account_id = hcp.cust_account_id(+)
   AND hcp.standard_terms = rt.term_id(+)

-- 客户收款方法 SQL
  SELECT arm.name receipt_method_name
          FROM hz_cust_accounts        hca
        ,ra_cust_receipt_methods rcrm
        ,ar_receipt_methods      arm
         WHERE hca.cust_account_id = rcrm.customer_id
           AND rcrm.receipt_method_id = arm.receipt_method_id
         ORDER BY rcrm.creation_date;


-- 客户账户层银行账户信息 SQL
SELECT hca.cust_account_id   cust_account_id
      ,hp.party_id           party_id
      ,bank.party_id         bank_id
      ,bank.party_name       bank_name
      ,branch.party_id       branch_id
      ,branch.party_name     bank_branch_name
      ,ieba.bank_account_num bank_account_num
  FROM hz_cust_accounts      hca
      ,hz_parties            hp
      ,iby_account_owners    iao
      ,iby_ext_bank_accounts ieba
      ,hz_parties            bank
      ,hz_parties            branch
 WHERE hca.party_id = hp.party_id
   AND hp.party_id = iao.account_owner_party_id(+)
   AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
   AND ieba.bank_id = bank.party_id(+)
   AND ieba.branch_id = branch.party_id(+)
 ORDER BY ieba.creation_date;
-- 客户开户行地址信息 SQL
SELECT hl.country || '-' || hl.province || '-' || hl.city || '-' ||
       hl.address1 || '-' || hl.address2 || '-' || hl.address3 || '-' ||
       hl.address4 bank_address
  FROM hz_party_sites hps
      ,hz_locations   hl
 WHERE hps.location_id = hl.location_id
 ORDER BY hps.creation_date;
-- 客户账户层联系人信息：联系人、电话、手机和 Email SQL
SELECT hr.party_id party_id
      ,hcar.cust_account_id cust_account_id
      ,hcar.cust_acct_site_id cust_acct_site_id
      ,hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
       hp.person_first_name contact_person
      ,hcpp.phone_area_code phone_area_code
      ,hcpp.phone_number phone_number
      ,hcpp.phone_extension phone_extension
      ,hcpm.phone_area_code mobile_phone_area_code
      ,hcpm.phone_number mobile_phone_number
      ,hcpe.email_address email_address
  FROM hz_relationships      hr
      ,hz_cust_account_roles hcar
      ,hz_org_contacts       hoc
      ,hz_contact_points     hcpp
      ,hz_contact_points     hcpm
      ,hz_contact_points     hcpe
      ,hz_parties            hp
      ,hz_cust_accounts      hca
 WHERE hr.object_id = hp.party_id
   AND hr.party_id = hcar.party_id
   AND hr.relationship_id = hoc.party_relationship_id(+)
   AND hcpp.owner_table_id(+) = hr.party_id
   AND hcpm.owner_table_id(+) = hr.party_id
   AND hcpe.owner_table_id(+) = hr.party_id
   AND hr.object_type = 'PERSON'
   AND hr.relationship_code(+) = 'CONTACT'
   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpp.contact_point_type(+) = 'PHONE'
   AND hcpp.phone_line_type(+) = 'GEN'
   AND hcpm.contact_point_type(+) = 'PHONE'
   AND hcpm.phone_line_type(+) = 'MOBILE'
   AND hcpe.contact_point_type(+) = 'EMAIL'
   AND hcpe.phone_line_type IS NULL
   AND hr.subject_id = hca.party_id
   AND hcar.cust_acct_site_id IS NULL
 ORDER BY hr.creation_date;
-- 客户地址
SELECT hcasa.cust_acct_site_id customer_site_id
      ,hcasa.cust_account_id   customer_id
      ,hps.party_site_number   customer_site_code
      ,hps.party_site_name     customer_site_name
      ,hl.address1             address_line1
      ,hl.address2             address_line2
      ,hl.address3             address_line3
      ,hl.address4             address_line4
      ,hcasa.org_id            org_id
      ,hl.country              country
      ,hl.province             province
      ,hl.city                 city
      ,hl.county               county
      ,hl.postal_code          zip
      ,hcasa.bill_to_flag      bill_to_flag
      ,hcasa.ship_to_flag      ship_to_flag
      ,hca.creation_date       creation_date
      ,hca.created_by          created_by
      ,hca.last_update_date    last_update_date
      ,hca.last_updated_by     last_updated_by
      ,hca.last_update_login   last_update_login
  FROM hz_cust_accounts       hca
      ,hz_cust_acct_sites_all hcasa
      ,hz_party_sites         hps
      ,hz_locations           hl
 WHERE hca.cust_account_id = hcasa.cust_account_id
   AND hcasa.party_site_id = hps.party_site_id
   AND hps.location_id = hl.location_id;

-- 客户账户层地址 contact person 信息 :phone,mobile,email
SELECT hr.party_id party_id
      ,hcar.cust_account_id cust_account_id
      ,hcar.cust_acct_site_id cust_acct_site_id
      ,hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
       hp.person_first_name contact_person
      ,hcpp.phone_area_code phone_area_code
      ,hcpp.phone_number phone_number
      ,hcpp.phone_extension phone_extension
      ,hcpm.phone_area_code mobile_phone_area_code
      ,hcpm.phone_number mobile_phone_number
      ,hcpe.email_address email_address
  FROM hz_relationships      hr
      ,hz_cust_account_roles hcar
      ,hz_org_contacts       hoc
      ,hz_contact_points     hcpp
      ,hz_contact_points     hcpm
      ,hz_contact_points     hcpe
      ,hz_parties            hp
      ,hz_cust_accounts      hca
 WHERE hr.object_id = hp.party_id
   AND hr.party_id = hcar.party_id
   AND hr.relationship_id = hoc.party_relationship_id(+)
   AND hcpp.owner_table_id(+) = hr.party_id
   AND hcpm.owner_table_id(+) = hr.party_id
   AND hcpe.owner_table_id(+) = hr.party_id
   AND hr.object_type = 'PERSON'
   AND hr.relationship_code(+) = 'CONTACT'
   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
   AND hcpp.contact_point_type(+) = 'PHONE'
   AND hcpp.phone_line_type(+) = 'GEN'
   AND hcpm.contact_point_type(+) = 'PHONE'
   AND hcpm.phone_line_type(+) = 'MOBILE'
   AND hcpe.contact_point_type(+) = 'EMAIL'
   AND hcpe.phone_line_type IS NULL
   AND hr.subject_id = hca.party_id
   AND hca.cust_account_id = hcar.cust_account_id
 ORDER BY hr.creation_date;

-- 客户账户地点地址
SELECT hp.party_id
      ,hca.cust_account_id
      ,hcasa.cust_acct_site_id
      ,hcasa.bill_to_flag
      ,hcasa.ship_to_flag
      ,hcsua.site_use_id
      ,hcasa.party_site_id
      ,hcsua.site_use_code
      ,hcsua.primary_flag
      ,hcsua.location
      ,hcsua.org_id
  FROM hz_parties             hp
      ,hz_cust_accounts       hca
      ,hz_party_sites         hps
      ,hz_cust_acct_sites_all hcasa
      ,hz_cust_site_uses_all  hcsua
 WHERE hp.party_id = hca.party_id
   AND hca.cust_account_id = hcasa.cust_account_id
   AND hcasa.party_site_id = hps.party_site_id
   AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id;
-- 客户主配置文件
SELECT *
  FROM hz_cust_profile_classes;

SELECT *
  FROM hz_customer_profiles;
SELECT *
  FROM hz_cust_prof_class_amts;
SELECT *
  FROM hz_cust_profile_amts;

--5. 订单 oe
--
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
   AND msi.organization_id = 141
   AND l.flow_status_code = ol.lookup_code
   AND ol.lookup_type = 'LINE_FLOW_STATUS'
   AND cust.account_number IN ('91010072'
                              ,'91010067'
                              ,'91010036')
 ORDER BY party_name
         ,收货地
         ,销售订单;

--6. 采购申请 pr
-- 申请单头 （以电网组织 ORG_ID=112 内部申请 =14140002781 为例
SELECT prh.requisition_header_id  申请单头id
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               申请单编号
      ,prh.creation_date          创建日期
      ,prh.created_by             编制人id
      ,fu.user_name               用户名称
      ,pp.full_name               用户姓名
      ,prh.approved_date          批准日期
      ,prh.description            说明
      ,prh.authorization_status   状态
      ,prh.type_lookup_code       类型
      ,prh.transferred_to_oe_flag 传递标示
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.org_id = 112
   AND prh.segment1 = '14140002781';
-->> 内部申请 =14140002781 申请单头 ID = 3379
-- 申请单行明细
SELECT prl.requisition_header_id       申请单id
      ,prl.requisition_line_id         行id
      ,prl.line_num                    行号
      ,prl.category_id                 分类id
      ,prl.item_id                     物料id
      ,item.segment1                   物料编码
      ,prl.item_description            物料说明
      ,prl.quantity                    需求数
      ,prl.quantity_delivered          送货数
      ,prl.quantity_cancelled          取消数
      ,prl.unit_meas_lookup_code       单位
      ,prl.unit_price                  参考价
      ,prl.need_by_date                需求日期
      ,prl.source_type_code            来源类型
      ,prl.org_id                      ou_id
      ,prl.source_organization_id      对方组织id
      ,prl.destination_organization_id 本方组织id
  FROM po_requisition_lines_all prl
      ,mtl_system_items         item
 WHERE prl.org_id = 112
   AND prl.item_id = item.inventory_item_id
   AND prl.destination_organization_id = item.organization_id
   AND prl.requisition_header_id = 3379;
-- 申请单头 ( 加对方订单编号 )
SELECT prh.requisition_header_id  申请单头id
      ,prh.preparer_id
      ,prh.org_id                 ou_id
      ,prh.segment1               申请单编号
      ,prh.creation_date          创建日期
      ,prh.created_by             编制人id
      ,fu.user_name               用户名称
      ,pp.full_name               用户姓名
      ,prh.approved_date          批准日期
      ,prh.description            说明
      ,prh.authorization_status   状态
      ,prh.type_lookup_code       类型
      ,prh.transferred_to_oe_flag 传递标示
      ,oeh.order_number           对方co编号
  FROM po_requisition_headers_all prh
      ,fnd_user                   fu
      ,per_people_f               pp
      ,oe_order_headers_all       oeh
 WHERE prh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND prh.requisition_header_id = oeh.source_document_id(+)
   AND prh.org_id = 112
   AND prh.segment1 = '14140002781';
--( 销售订单记录有对方 OU_ID, 申请单关键字 SOURCE_DOCUMENT_ID 申请单号 SOURCE_DOCEMENT_REF)

** ** ** ** ** ** ** ** ** * 综合查询类 ** ** ** ** ** ** ** ** ** *
-- 申请单头综合查询 （进限制只能查询 -- 电网组织 ORG_ID=112)
  SELECT prh.requisition_header_id       申请单头 id
        ,prh.org_id                      组织 id
        ,prh.segment1                    申请单编号
        ,prh.creation_date               创建日期
        ,prh.created_by                  编制人 id
        ,fu.user_name                    用户名称
        ,pp.full_name                    用户姓名
        ,prh.approved_date               批准日期
        ,prh.description                 说明
        ,prh.authorization_status        状态
        ,prh.type_lookup_code            类型
        ,prh.transferred_to_oe_flag      传递标示
        ,prl.requisition_line_id         行id
        ,prl.line_num                    行号
        ,prl.category_id                 分类id
        ,prl.item_id                     物料id
        ,item.segment1                   物料编码
        ,prl.item_description            物料说明
        ,prl.quantity                    需求数
        ,prl.quantity_delivered          送货数
        ,prl.quantity_cancelled          取消数
        ,prl.unit_meas_lookup_code       单位
        ,prl.unit_price                  参考价
        ,prl.need_by_date                需求日期
        ,prl.source_type_code            来源类型
        ,prl.source_organization_id      对方组织id
        ,prl.destination_organization_id 本方组织id
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
     AND prh.org_id = 112;

-- 若需创建视图只需在 SELECT 语句前加上
CREATE OR REPLACE view cux_inv_pr112 AS 7. 采购订单po
-- 采购单头信息 TYPE_LOOKUP_CODE='STANDARD' （以供应处 OU ORG_ID=119 采购单 ='' 为例）
-- 类型说明 TYPE_LOOKUP_CODE='STANDARD' 为采购单 TYPE_LOOKUP_CODE='BLANKET' 为采购协议
  SELECT poh.org_id               ou_id
        ,poh.po_header_id         采购单头id
        ,poh.type_lookup_code     类型
        ,poh.authorization_status 状态
        ,poh.vendor_id            供应商id
        ,vendor.vendor_name       供应商名
        ,poh.vendor_site_id       供应商地址id
        ,poh.vendor_contact_id    供应商联系人id
        ,poh.ship_to_location_id  本方收货地id
        ,poh.bill_to_location_id  本方收单地id
        ,poh.creation_date        创建日期
        ,poh.approved_flag        审批yn
        ,poh.approved_date        审批日期
        ,poh.comments             采购单说明
        ,poh.terms_id             条款id
        ,poh.agent_id             采购员id
        ,agt_pp.last_name         采购员
        ,poh.created_by           创建者id
        ,fu.user_name             创建用户
        ,pp.full_name             用户姓名
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
FND_USER FU, per_people_f PP 用户相关表
po_agents_name_v 采购员视图 ----> PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID 采购员相关表
ap_suppliers 供应商主表
*/

-->> POH.SEGMENT1 = '14730005436' PO_HEADER_ID = 10068
-- 采购单行信息
SELECT pol.org_id                ou_id
      ,pol.po_header_id          采购单头id
      ,pol.po_line_id            行id
      ,pol.line_num              行号
      ,pol.item_id               物料id
      ,item.segment1             物料编码
      ,pol.item_description      物料说明
      ,pol.unit_meas_lookup_code 单位
      ,pol.unit_price            单价
      ,po_lct.quantity           订购数
      ,po_lct.quantity_received  验收数
      ,po_lct.quantity_accepted  接收数
      ,po_lct.quantity_rejected  拒绝数
      ,po_lct.quantity_cancelled 取消数
      ,po_lct.quantity_billed    到票数
      ,po_lct.promised_date      承诺日期
      ,po_lct.need_by_date       需求日期
  FROM po_lines_all          pol
      ,po_line_locations_all po_lct
      ,mtl_system_items      item
 WHERE pol.org_id = po_lct.org_id
   AND pol.po_line_id = po_lct.po_line_id
   AND pol.item_id = item.inventory_item_id
   AND item.organization_id = 142
   AND pol.org_id = 119
   AND pol.po_header_id = 10068;
-- 说明： Po_Line_Locations_all 系 “ 发运表 ”

-- 综合查询 1 ，所分配给供应处组织的物料，存在采购协议，但缺失采购员或缺失仓库；
SELECT msif.segment1         物料编码
      ,msif.description      物料描述
      ,msif.long_description 物料详细描述
      ,
       --MSIF.primary_unit_of_measure 计量单位 ,
       prf.last_name 采购员
      ,misd.subinventory_code 默认接收库存
      ,pla.unit_price 未税价
      ,round(pla.unit_price * (1 + zrb.percentage_rate / 100)
            ,2) 含税价
      ,pv.vendor_name 供应商名称
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
   AND (misd.subinventory_code IS NULL OR prf.last_name IS NULL)

-- 采购其他相关表
  SELECT *
          FROM po_distributions_all 分配;


SELECT *
  FROM po_releases_all;
SELECT *
  FROM rcv_shipment_headers 采购接收头;
SELECT *
  FROM rcv_shipment_lines 采购接收行;
SELECT *
  FROM rcv_transactions 接收事务处理;
SELECT *
  FROM po_agents; --采购员
SELECT *
  FROM po_vendors;
SELECT *
  FROM po_vendor_sites_all;

--8. 库存 inv
-- 物料主表
SELECT msi.organization_id            组织id
      ,msi.inventory_item_id          物料id
      ,msi.segment1                   物料编码
      ,msi.description                物料说明
      ,msi.item_type                  项目类型
      ,msi.planning_make_buy_code     制造或购买
      ,msi.primary_unit_of_measure    基本度量单位
      ,msi.bom_enabled_flag           bom标志
      ,msi.inventory_asset_flag       库存资产否
      ,msi.buyer_id                   采购员id
      ,msi.purchasing_enabled_flag    可采购否
      ,msi.purchasing_item_flag       采购项目
      ,msi.unit_of_issue              单位
      ,msi.inventory_item_flag        是否为库存
      ,msi.lot_control_code           是否批量
      ,msi.reservable_type            是否要预留
      ,msi.stock_enabled_flag         能否库存
      ,msi.fixed_days_supply          固定提前期
      ,msi.fixed_lot_multiplier       固定批量大小
      ,msi.inventory_planning_code    库存计划方法
      ,msi.maximum_order_quantity     最大定单数
      ,msi.minimum_order_quantity     最小定单数
      ,msi.full_lead_time             固定提前期
      ,msi.planner_code               计划员码
      ,misd.subinventory_code         接收子仓库
      ,msi.source_subinventory        来源子仓库
      ,msi.wip_supply_subinventory    供应子仓库
      ,msi.attribute12                老编码
      ,msi.inventory_item_status_code 物料状态
      ,mss.safety_stock_quantity      安全库存量
  FROM mtl_system_items      msi
      ,mtl_item_sub_defaults misd
      ,mtl_safety_stocks     mss
 WHERE msi.organization_id = misd.organization_id(+)
   AND msi.inventory_item_id = misd.inventory_item_id(+)
   AND msi.organization_id = mss.organization_id(+)
   AND msi.inventory_item_id = mss.inventory_item_id(+)
   AND msi.organization_id = 1155
   AND msi.segment1 = '18020200012';
-- 物料库存数量
SELECT moq.organization_id
      ,moq.inventory_item_id
      ,moq.subinventory_code
      ,SUM(moq.transaction_quantity) qty
  FROM mtl_onhand_quantities moq
 WHERE moq.inventory_item_id = 12781
   AND moq.organization_id = 1155
 GROUP BY moq.organization_id
         ,moq.inventory_item_id
         ,moq.subinventory_code;

-- 移动平均成本
SELECT cst.inventory_item_id       item_id
      ,cst.organization_id         org_id
      ,cst.cost_type_id            成本类型
      ,cst.item_cost               单位成本
      ,cst.material_cost           材料成本
      ,cst.material_overhead_cost  间接费
      ,cst.resource_cost           人工费
      ,cst.outside_processing_cost 外协费
      ,cst.overhead_cost           制造费
  FROM cst_item_costs cst
 WHERE cst.cost_type_id = 2
   AND cst.inventory_item_id = 12781
   AND cst.organization_id = 1155;

-- 综合查询 - 库存数量及成本
SELECT msi.organization_id         组织id
      ,msi.inventory_item_id       物料id
      ,msi.segment1                物料编码
      ,msi.description             物料说明
      ,msi.planning_make_buy_code  m1p2
      ,moqv.subinventory_code      子库存
      ,moqv.qty                    当前库存量
      ,cst.item_cost               单位成本
      ,cst.material_cost           材料成本
      ,cst.material_overhead_cost  间接费
      ,cst.resource_cost           人工费
      ,cst.outside_processing_cost 外协费
      ,cst.overhead_cost           制造费
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
-- 子库存列表
SELECT *
  FROM mtl_secondary_inventories;

-- 货位列表
SELECT organization_id       组织代码
      ,inventory_location_id 货位内码
      ,subinventory_code     子库名称
      ,segment1              货位编码
  FROM mtl_item_locations;
-- 计划员表
SELECT planner_code    计划员代码
      ,organization_id 组织代码
      ,description     计划员描述
      ,mp.employee_id  员工 id
      ,disable_date    失效日期
  FROM mtl_planners mp;
-- 科目设置等参数
SELECT *
  FROM mtl_parameters mp;

--9. 物料清单 bom
--BOM 主表 bom_bill_of_materials
SELECT aa.bill_sequence_id 清单序号
      ,aa.assembly_item_id 装配件内码
      ,aa.organization_id  组织代码
      ,bb.segment1         物料编码
      ,bb.description      物料说明
      ,aa.assembly_type    装配类别
  FROM bom_bill_of_materials aa ， mtl_system_items bb
 WHERE aa.assembly_item_id = bb.inventory_item_id
   AND aa.organization_id = bb.organization_id;

--BOM 明细表 bom_inventory_components
SELECT bill_sequence_id      清单序号
      ,component_sequence_id 构件序号
      ,item_num              项目序列
      ,operation_seq_num     操作序列号
      ,component_item_id     子物料内码
      ,component_quantity    构件数量
      ,disable_date          失效日期
      ,supply_subinventory   供应子库存
      ,bom_item_type
  FROM bom_inventory_components;

--BOM 明细综合查询 ( 组织 限定供应处 142 装配件 = '5XJ061988')
SELECT vbom.bid                   清单序号
      ,vbom.f_itemid              装配件内码
      ,bb.segment1                物料编码
      ,bb.description             物料说明
      ,vbom.ogt_id                组织内码
      ,vbom.cid                   操作 id
      ,vbom.item_num              物料序号
      ,vbom.opid                  工序
      ,vbom.c_itemid              子物料内码
      ,cc.segment1                物料编码
      ,cc.description             物料说明
      ,vbom.qty                   构件数量
      ,cc.primary_uom_code        子计量单位码
      ,cc.primary_unit_of_measure 子计量单位名
      ,vbom.whse                  供应子仓库
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

-- 单层 BOM 成本查询 ( 需系统提交请求计算后 )
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
--以上是单层bom展开，下面是展开bom到最底层：
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
   AND bbm.organization_id = p_org_id
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
---特别说明：level connect_by_isleaf connect_by_root sys_connect_by_path(bbm.assembly_item_id, '/') 均是start
--- WITH …… CONNECT BY 的内置函数或字段 

--10. 作业任务 wip 说明： 查询作业任务头以及作业任务工序和 bom 情况
-- 作业任务头信息表
-- （以直流 OU_ID=117 ； ORGANIZATION_ID=1155; 及任务 WIP_ENTITY_NAME='XJ39562'; 装配件编码 SEGMENT1 = '07D9202.92742' 为例）
SELECT aa.wip_entity_id   任务令id
      ,aa.organization_id 组织id
      ,aa.wip_entity_name 任务名称
      ,aa.entity_type     任务类型
      ,aa.creation_date   创建日期
      ,aa.created_by      创建者id
      ,aa.description     说明
      ,aa.primary_item_id 装配件id
      ,bb.segment1        物料编码
      ,bb.description     物料说明
  FROM wip_entities     aa
      ,mtl_system_items bb
 WHERE aa.primary_item_id = bb.inventory_item_id
   AND aa.organization_id = bb.organization_id
   AND aa.organization_id = 1155
   AND aa.wip_entity_name = 'XJ39562';
--=> WIP_ENTITY_ID = 48825

-- 离散作业任务详细主信息表
-- 用途 1 ）作业任务下达及完成情况查询
-- 说明 1 ）此表包括 wip_entities 表大部分信息 2) 重复作业任务表为 wip_repetitive_items, wip_repetitive_schedules
SELECT aa.wip_entity_id             任务令id
      ,bb.wip_entity_name           任务名称
      ,aa.organization_id           组织id
      ,aa.source_line_id            行id
      ,aa.status_type               状态type
      ,aa.primary_item_id           装配件id
      ,cc.segment1                  物料编码
      ,cc.description               物料说明
      ,aa.firm_planned_flag
      ,aa.job_type                  作业类型
      ,aa.wip_supply_type           供应 TYPE
      ,aa.class_code                任务类别
      ,aa.scheduled_start_date      起始时间
      ,aa.date_released             下达时间
      ,aa.scheduled_completion_date 完工时间
      ,aa.date_completed            完工时间
      ,aa.date_closed               关门时间
      ,aa.start_quantity            计划数
      ,aa.quantity_completed        完工数
      ,aa.quantity_scrapped         报废数
      ,aa.net_quantity              mrp 净值
      ,aa.completion_subinventory   接收子库
      ,aa.completion_locator_id     货位
  FROM wip_discrete_jobs aa
      ,wip.wip_entities  bb
      ,mtl_system_items  cc
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND aa.primary_item_id = cc.inventory_item_id
   AND aa.organization_id = cc.organization_id
   AND aa.organization_id = 1155
   AND bb.wip_entity_name = 'XJ39562';
/*
1 ）任务状态 TYPE 值说明：
STATUS_TYPE =1 未发放的 - 收费不允许
STATUS_TYPE =3 发入 - 收费允许
STATUS_TYPE =4 完成 - 允许收费
STATUS_TYPE =5 完成 - 不允许收费
STATUS_TYPE =6 暂挂 - 不允许收费
STATUS_TYPE =7 已取消 - 不允许收费
STATUS_TYPE =8 等待物料单加载
STATUS_TYPE =9 失败的物料单加载
STATUS_TYPE =10 等待路线加载
STATUS_TYPE =11 失败的路线加载
STATUS_TYPE =12 关闭 - 不可收费
STATUS_TYPE =13 等待 - 成批加载
STATUS_TYPE =14 等待关闭
STATUS_TYPE =15 关闭失败
2 ）供应类型 TYPE 值说明：
WIP_SUPPLY_TYPE =1 推式
WIP_SUPPLY_TYPE =2 装配拉式
WIP_SUPPLY_TYPE =3 操作拉式
WIP_SUPPLY_TYPE =4 大量
WIP_SUPPLY_TYPE =5 供应商
WIP_SUPPLY_TYPE =6 虚拟
WIP_SUPPLY_TYPE =7 以帐单为基础
*/

-- 离散作业任务工序状况表
SELECT aa.organization_id            组织id
      ,aa.wip_entity_id              任务令id
      ,bb.wip_entity_name            任务名称
      ,aa.operation_seq_num          工序号
      ,aa.description                工序描述
      ,aa.department_id              部门id
      ,aa.scheduled_quantity         计划数量
      ,aa.quantity_in_queue          排队数量
      ,aa.quantity_running           运行数量
      ,aa.quantity_waiting_to_move   待移动数量
      ,aa.quantity_rejected          故障品数量
      ,aa.quantity_scrapped          报废品数量
      ,aa.quantity_completed         完工数量
      ,aa.first_unit_start_date      最早一个单位上线时间
      ,aa.first_unit_completion_date 最早一个单位完成时间
      ,aa.last_unit_start_date       最后一个单位上线时间
      ,aa.last_unit_completion_date  最后一个单位完工时间
      ,aa.previous_operation_seq_num 前一工序序号
      ,aa.next_operation_seq_num     下一工序序号
      ,aa.count_point_type           是否自动计费
      ,aa.backflush_flag             倒冲否
      ,aa.minimum_transfer_quantity  最小传送数量
      ,aa.date_last_moved            最后移动时间
  FROM wip_operations aa
      ,wip_entities   bb
 WHERE aa.wip_entity_id = bb.wip_entity_id
   AND bb.wip_entity_name = 'XJ39562';
-- 离散作业任务子查询 ——— 工单工序状况查询（不单独使用）
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

-- 离散作业任务 BOM ( 无材料费 )
SELECT wop.organization_id       组织id
      ,wop.wip_entity_id         任务令id
      ,bb.wip_entity_name        装配件名称
      ,bb.primary_item_id        装配件id
      ,cc.segment1               装配件物料编码
      ,cc.description            装配件说明
      ,wop.operation_seq_num     工序号
      ,wop.department_id         部门id
      ,wop.wip_supply_type       供应类型
      ,wop.date_required         要求日期
      ,wop.inventory_item_id     子物料id
      ,dd.segment1               子物料编码
      ,dd.description            子物料说明
      ,wop.quantity_per_assembly 单位需量
      ,wop.required_quantity     总需求量
      ,wop.quantity_issued       已发放量
      ,wop.comments              注释
      ,wop.supply_subinventory   供应子库
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

-- 作业任务已发放材料处理记录清单 0101 （最详细） （内码为 48825 为例）
-- 用途 1 ）查询工单发料详细明细，包括发料类型、时间、用户等
SELECT mtl.transaction_id 交易id
      ,mtl.inventory_item_id 项目id
      ,cc.segment1 物料编码
      ,cc.description 物料说明
      ,mtl.organization_id 组织id
      ,mtl.subinventory_code 子库名称
      ,mtl.transaction_type_id 交易类型id
      ,bb.transaction_type_name 交易类型名称
      ,mtl.transaction_quantity 交易数量
      ,mtl.transaction_uom 单位
      ,mtl.transaction_date 交易日期
      ,mtl.transaction_reference 交易参考
      ,mtl.transaction_source_id 参考源id
      ,ff.wip_entity_name 任务名称
      ,mtl.department_id 部门 id
      ,mtl.operation_seq_num 工序号
      ,round(mtl.prior_cost
            ,2) 原来成本
      ,round(mtl.new_cost
            ,2) 新成本
      ,mtl.transaction_quantity * round(mtl.prior_cost
                                       ,2) 交易金额
      ,dd.user_name 用户名称
      ,ee.full_name 用户姓名
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
-- 按工单的材料费汇总（不单独使用）
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

-- 离散作业任务子查询 01——— 材料消耗状况及材料费综合查询
-- 用途 1 ）查询发料状况 2 ）查询材料费物料小计
SELECT wop.organization_id       组织id
      ,wop.wip_entity_id         任务令id
      ,bb.wip_entity_name        装配件名称
      ,bb.primary_item_id        装配件id
      ,cc.segment1               装配件物料编码
      ,cc.description            装配件说明
      ,wop.operation_seq_num     工序号
      ,wop.department_id         部门id
      ,wop.wip_supply_type       供应类型
      ,wop.date_required         要求日期
      ,wop.inventory_item_id     子物料id
      ,dd.segment1               子物料编码
      ,dd.description            子物料说明
      ,wop.quantity_per_assembly 单位需量
      ,wop.required_quantity     总需求量
      ,wop.quantity_issued       已发放量
      ,cst.amt                   已发生材料费
      ,wop.comments              注释
      ,wop.supply_subinventory   供应子库
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

-- 离散作业任务子查询 0201——— 作业资源报工明细表
SELECT wta.organization_id        组织代码
      ,wta.transaction_id         交易代码
      ,wta.reference_account      参考科目
      ,wta.transaction_date       报工日期
      ,wta.wip_entity_id          任务令内码
      ,wta.accounting_line_type   会计栏类型
      ,wta.base_transaction_value 费用额
      ,wta.contra_set_id          反方集代码
      ,wta.primary_quantity       基本数量
      ,wta.rate_or_amount         率或金额
      ,wta.basis_type             基本类型
      ,wta.resource_id            资源代码
      ,wta.cost_element_id        成本要素id
      ,wta.accounting_line_type   成本类型id
      ,wta.overhead_basis_factor  费用因子
      ,wta.basis_resource_id      基本资源id
      ,wta.created_by             录入人id
      ,dd.user_name               用户名称
      ,ee.full_name               用户姓名
  FROM wip_transaction_accounts wta
      ,fnd_user                 dd
      ,per_people_f             ee
 WHERE wta.created_by = dd.user_id
   AND dd.employee_id = ee.person_id
   AND wta.base_transaction_value <> 0
   AND wta.organization_id = 1155
   AND wta.wip_entity_id = 48839;
-- 成本类型 ID ACCOUNTING_LINE_TYPE
SELECT *
  FROM mfg_lookups ml
 WHERE ml.lookup_type LIKE 'CST_ACCOUNTING_LINE_TYPE'
 ORDER BY ml.lookup_code;
-- 成本要素 ID COST_ELEMENT_ID
--( 待补充 --------------------------------------------------------------------------?)

-- 统计人工费与制造费 ( 不单独应用 )
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

-- 工单进度及费用信息综合查询 ( 未下达及下达零发料和报工的看不到 )
SELECT we.wip_entity_name            任务名称
      ,msi.segment1                  物料
      ,msi.description               物料描述
      ,msi.primary_unit_of_measure   单位
      ,wdj.scheduled_start_date      计划开始时间
      ,wdj.scheduled_completion_date 计划完成时间
      ,wdj.start_quantity            工单数量
      ,wdj.quantity_completed        完成数量
      ,wdj.date_released             实际开始时间
      ,wdj.date_completed            时间完成时间
      ,wdj.description               工单备注
      ,pp.segment1                   项目号
      ,pp.description                项目描述
      ,pt.task_number                任务号
      ,pt.description                任务描述
      ,wo.count_oper                 工序数
      ,wo1.operation_seq_num         当前工序
      ,wo1.description               当前工序描述
      ,mta.mt_fee                    材料费
      ,wct.hr_fee                    人工费
      ,wct.md_fee                    制造费
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
      , -- 工序进度
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
      , -- 材料费
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
                 ,wta_cost.wip_entity_id) wct -- 人工与制造
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

-- 工单进度及费用信息综合查询 ( 不论是否下达和发料都能看到 )
SELECT wdj.wip_entity_id           任务令id
      ,we.wip_entity_name          任务名称
      ,wdj.organization_id         组织id
      ,wdj.status_type             状态
      ,wdj.primary_item_id         装配件id
      ,msi.segment1                物料编码
      ,msi.description             物料说明
      ,wdj.firm_planned_flag       任务类型
      ,wdj.job_type                作业类型
      ,wdj.wip_supply_type         供应类型
      ,wdj.class_code              任务类别
      ,wdj.scheduled_start_date    起始时间
      ,wdj.date_released           下达时间
      ,wdj.date_completed          完工时间
      ,wdj.date_closed             关闭时间
      ,wdj.start_quantity          计划数
      ,wdj.quantity_completed      完工数
      ,wdj.quantity_scrapped       报废数
      ,wdj.net_quantity            mrp 净值
      ,wdj.description             工单备注
      ,wdj.completion_subinventory 接收子库
      ,wdj.completion_locator_id   货位id
      ,wdj.project_id              项目id
      ,wdj.task_id                 项目任务id
      ,pp.segment1                 项目号
      ,pp.description              项目描述
      ,pt.task_number              任务号
      ,pt.description              任务描述
      ,wpf.count_oper              工序数
      ,wpf.cur_oper                当前工序
      ,wpf.cur_opername            工序名
      ,wpf.mt_fee                  材料费
      ,wpf.hr_fee                  人工费
      ,wpf.md_fee                  制造费
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
                         ,wdj.wip_entity_id) wo -- 工序进度
              ,(SELECT mtl.organization_id
                      ,mtl.transaction_source_id wip_entity_id
                      ,abs(SUM(mtl.transaction_quantity * mtl.actual_cost)) mt_fee
                  FROM mtl_material_transactions mtl
                 WHERE mtl.transaction_type_id IN (35
                                                  ,38
                                                  ,43
                                                  ,48)
                 GROUP BY mtl.organization_id
                         ,mtl.transaction_source_id) mta -- 材料费
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
                         ,wta_cost.wip_entity_id) wct -- 人工与制造
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
   AND wdj.organization_id = 1155
   AND pp.segment1 = '07D9202';

--11. 总账 gl
SELECT *
  FROM gl_sets_of_books 总帐;
SELECT *
  FROM gl_code_combinations gcc
 WHERE gcc.summary_flag = 'Y' 科目组合;
SELECT *
  FROM gl_balances 科目余额;
SELECT *
  FROM gl_je_batches 凭证批;
SELECT *
  FROM gl_je_headers 凭证头;
SELECT *
  FROM gl_je_lines 凭证行;
SELECT *
  FROM gl_je_categories 凭证分类;
SELECT *
  FROM gl_je_sources 凭证来源;
SELECT *
  FROM gl_summary_templates 科目汇总模板;
SELECT *
  FROM gl_account_hierarchies 科目汇总模板层次;
--13. 应收 ar
SELECT *
  FROM ar_batches_all 事务处理批;
SELECT *
  FROM ra_customer_trx_all 发票头;
SELECT *
  FROM ra_customer_trx_lines_all 发票行;
SELECT *
  FROM ra_cust_trx_line_gl_dist_all 发票分配;
SELECT *
  FROM ar_cash_receipts_all 收款;
SELECT *
  FROM ar_receivable_applications_all 核销;
SELECT *
  FROM ar_payment_schedules_all 发票调整;
SELECT *
  FROM ar_adjustments_all 会计分录;
SELECT *
  FROM ar_distributions_all 付款计划;
-- 14. 应付 ap
SELECT *
  FROM ap_invoices_all 发票头;
SELECT *
  FROM ap_invoice_distributions_all 发票行;
SELECT *
  FROM ap_payment_schedules_all 付款计划;
SELECT *
  FROM ap_check_stocks_all 单据;
SELECT *
  FROM ap_checks_all 付款;
SELECT *
  FROM ap_bank_branches 银行;
SELECT *
  FROM ap_bank_accounts_all 银行帐号;
SELECT *
  FROM ap_invoice_payments_all 核销;

-- 15. 应用、值集、弹性域
--fnd
SELECT *
  FROM fnd_application;
SELECT *
  FROM fnd_application_tl
 WHERE application_id = 101;
SELECT *
  FROM fnd_application_vl
 WHERE application_id = 101;
-- 值集
SELECT *
  FROM fnd_flex_value_sets;
SELECT *
  FROM fnd_flex_values;
SELECT *
  FROM fnd_flex_values_vl;
-- 弹性域
SELECT *
  FROM fnd_id_flexs;
SELECT *
  FROM fnd_id_flex_structures
 WHERE id_flex_code = 'GL#';
SELECT *
  FROM fnd_id_flex_segments
 WHERE id_flex_code = 'GL#'
   AND id_flex_num = 50671;

SELECT *
  FROM fnd_profile_options_vl;
SELECT *
  FROM fnd_concurrent_programs 程序表;
SELECT *
  FROM fnd_concurrent_requests 请求表;
SELECT *
  FROM fnd_concurrent_processes 进程表;
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

-- 1）查询会计科目分段信息
SELECT *
  FROM gl_code_combinations;
-- 查询会计科目组合信息
SELECT *
  FROM gl_code_combinations_kfv;
--2) 查询自定义的客户化相关表和视图
SELECT *
  FROM user_tables
 WHERE table_name LIKE 'CUX%';
-- 查询该用户拥有哪些视图
SELECT *
  FROM user_views
 WHERE view_name LIKE 'CUX%';
-- 查询该用户拥有哪些索引
SELECT *
  FROM user_indexes;
--3) 查询物料处理记录 说明： mtl_material_transactions 这个表记录了所有涉及仓库收发的物料交易记录，包括：采购、 wip 、订单、杂项等多种处理模式的内容。
-- 举例： 查询某用户在电网的账户别名发放清单
SELECT aa.transaction_id 交易代码
      ,aa.inventory_item_id 项目内码
      ,cc.segment1 物料编码
      ,cc.description 物料说明
      ,aa.organization_id 组织代码
      ,aa.subinventory_code 子库名称
      ,aa.transaction_type_id 类型id
      ,bb.transaction_type_name 类型名称
      ,aa.transaction_quantity 数量
      ,aa.transaction_uom 单位
      ,aa.transaction_date 交易日期
      ,aa.transaction_reference 交易参考
      ,aa.transaction_source_id 参考源id
      ,aa.department_id 部门id
      ,aa.operation_seq_num 工序号
      ,round(aa.actual_cost
            ,2) 实际成本
      ,round(aa.transaction_cost
            ,2) 处理成本
      ,round(aa.prior_cost
            ,2) 旧成本
      ,round(aa.new_cost
            ,2) 新成本
      ,round(aa.variance_amount
            ,2) 差异金额
      ,aa.transaction_quantity * round(aa.prior_cost
                                      ,2) 交易金额
      ,dd.user_name 用户名称
      ,ee.full_name 用户姓名
      ,aa.attribute1 弹性域人名
      ,aa.attribute15 弹性域备注
  FROM mtl_material_transactions aa
      ,mtl_transaction_types     bb
      ,mtl_system_items          cc
      ,fnd_user                  dd
      ,per_people_f              ee
 WHERE aa.transaction_type_id = bb.transaction_type_id
   AND aa.created_by = dd.user_id
   AND aa.inventory_item_id = cc.inventory_item_id
   AND aa.organization_id = cc.organization_id
   AND dd.employee_id = ee.person_id
   AND aa.organization_id = 1155
   AND cc.segment1 = '07D9202.92742'
   AND aa.transaction_date >=
       to_date('2011-01-29 00:00:00'
              ,'YYYY-MM-DD HH24:MI:SS')
 ORDER BY aa.transaction_id;
/* 物料处理记录 mtl_material_transactions 表，类型与成本说明：
-- 杂项收 TRANSACTION_TYPE_ID = 41 录入价格优先， =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0 , 调整类似
注： 1 ）如果再接收界面录入了价格，以录入价格计入 Actual_Cost ，进行移动平均
2 ）如果没有录入价格，字段 NULL ，则系统会以当前成本接收，计入 Actual_Cost
-- 杂项发 TRANSACTION_TYPE_ID = 31 以出 =Actual_Cost ， TRANSACTION_QUANTITY < 0 , 调整类似
-- 采购收 TRANSACTION_TYPE_ID = 18 以 入 =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0
-- 采购退 TRANSACTION_TYPE_ID = 36 以 出 =Actual_Cost ， TRANSACTION_QUANTITY < 0
注： 1) 系统按采购成本退货和扣除库存金额，不考虑已消耗状况；
2) 如果库存金额够扣除，则扣除后重新计算出一个新成本；
3 ）如果库存金额不够扣除，则扣除全部金额，就会出现有库存量而单位成本 =0 的物资，不够扣的部分计入字段 VARIANCE_AMOUNT 。
-- 作业发 TRANSACTION_TYPE_ID = 35 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0 ，特定组件发料类似
-- 作业退 TRANSACTION_TYPE_ID = 43 以当前成本入， =Actual_Cost ，不移动平均 TRANSACTION_QUANTITY > 0
-- 配送出 TRANSACTION_TYPE_ID = 100 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0
-- 配送退 TRANSACTION_TYPE_ID = 101 以配送价入 ， =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0
-- 销售发 TRANSACTION_TYPE_ID = 33 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0
-- 销售退 TRANSACTION_TYPE_ID = 15 以当前成本入， =Actual_Cost ， TRANSACTION_QUANTITY > 0
*/
-- 物料处理记录类型列表
SELECT bb.transaction_type_id   类型id
      ,bb.transaction_type_name 别名
      ,bb.description           说明
  FROM mtl_transaction_types bb
 ORDER BY bb.transaction_type_id;
-- 交易来源类型列表
SELECT *
  FROM mtl_txn_source_types;
-- 交易原因代码表
SELECT reason_id   原因代码
      ,reason_name 名称
      ,description 描述
  FROM inv.mtl_transaction_reasons;

--工艺路线

SELECT msib.segment1
      ,msib.description
      ,borv.resource_code
      ,br.description
  FROM bom_operational_routings_v bor
      ,bom_operation_sequences_v  bos
      ,bom_operation_resources_v  borv
      ,bom_resources              br
      ,mtl_system_items_b         msib
 WHERE bor.organization_id = 86
   AND br.organization_id = 86
   AND bor.assembly_item_id = msib.inventory_item_id
   AND msib.organization_id = 86
   AND bor.routing_sequence_id = bos.routing_sequence_id
   AND bos.operation_sequence_id = borv.operation_sequence_id
   AND br.resource_id = borv.resource_id
   AND bos.operation_seq_num =
       (SELECT MAX(bos1.operation_seq_num)
          FROM bom_operation_sequences_v  bos1
              ,bom_operational_routings_v bor1
         WHERE bos1.routing_sequence_id = bor1.routing_sequence_id
           AND bor1.routing_sequence_id = bor.routing_sequence_id
           AND bor1.alternate_routing_designator IS NULL)
   AND bor.alternate_routing_designator IS NULL
   AND nvl(br.attribute15
          ,'N') = 'Y';
