--1. OU�������֯ 
SELECT hou.organization_id          ou_org_id
      ,hou.name                     ou_name
      ,ood.organization_id          org_org_id
      ,ood.organization_code        org_org_code
      ,msi.secondary_inventory_name --�ӿ�����
      ,msi.description
  FROM hr_organization_information  hoi -- ��֯�����
      ,hr_operating_units           hou --ou ��ͼ
      ,org_organization_definitions ood -- �����֯������ͼ
      ,mtl_secondary_inventories    msi -- �ӿ����Ϣ��
 WHERE hoi.org_information1 = 'OPERATING_UNIT'
   AND hoi.organization_id = hou.organization_id
   AND ood.operating_unit = hoi.organization_id
   AND ood.organization_id = msi.organization_id;
-- ��ȡϵͳ ID
CALL fnd_global.apps_initialize(user_id
                               ,resp_id
                               ,resp_appl_id);
SELECT fnd_profile.value('ORG_ID')
  FROM dual;
  
SELECT *
  FROM hr_operating_units hou
 WHERE hou.organization_id = 85;

--2. �û������μ� hr
-- ϵͳ���ζ��� VIEW(FROM FND_RESPONSIBILITY_TL, FND_RESPONSIBILITY)
SELECT application_id
      ,responsibility_id
      ,responsibility_key
      ,end_date
      ,responsibility_name
      ,description
  FROM fnd_responsibility_vl;

-- �û����ι�ϵ
SELECT user_id
      ,responsibility_id
  FROM fnd_user_resp_groups;
-- �û���
SELECT user_id
      ,user_name
      ,employee_id
      ,person_party_id
      ,end_date
  FROM fnd_user;
-- ��Ա�� VIEW
SELECT person_id
      ,start_date
      ,date_of_birth
      ,employee_number
      ,national_identifier
      ,sex
      ,full_name
  FROM per_people_f;
-- �ۺϲ�ѯ
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
   AND responsibility_name LIKE '% ��Ӧ�� %'
 ORDER BY user_name;
-- �ۺϲ�ѯ
-- ��Ա״��������Ϣ��
SELECT paf.person_id ϵͳid
      ,paf.full_name ����
      ,paf.date_of_birth ��������
      ,paf.region_of_birth ��������
      ,paf.national_identifier ���֤��
      ,paf.attribute1 �й���Դ
      ,paf.attribute3 Ա������
      ,paf.attribute11 ���ź�ͬ��
      ,paf.original_date_of_hire �μӹ�������
      ,paf.per_information17 ʡ��
      ,decode(paf.sex
             ,'M'
             ,' �� '
             ,'F'
             ,' Ů '
             ,'NULL') �Ա� --decode �ʺϺ�ͬһֵ���Ƚ��ж��ֽ�������ʺϺͶ���ֵ�Ƚ��ж��ֽ��
      ,CASE paf.sex
         WHEN 'M' THEN
          ' �� '
         WHEN 'F' THEN
          ' Ů '
         ELSE
          'NULL'
       END �Ա� 1 --case �÷�һ
      ,CASE
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1960' THEN
          '50 ��� '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1970' THEN
          '60 ��� '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1980' THEN
          '70 ��� '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '1990' THEN
          '80 ��� '
         WHEN to_char(paf.date_of_birth
                     ,'YYYY') < '2000' THEN
          '90 ��� '
         ELSE
          '21 ���� ' --case �÷���
       END �������
  FROM per_all_people_f paf;

--3. ��Ӧ�� vendor
-- ��Ӧ���������ݣ�
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
-- ��Ӧ��������Ϣ
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


-- ��Ӧ�̿����е�ַ��Ϣ
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
-- ��Ӧ����ϵ����Ϣ
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

-- ��Ӧ�̵�ַ����Ϣ
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
-- ��Ӧ�̵�ַ��ϵ����Ϣ�� phone �� fax �� Email
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
-- ��Ӧ�̵�ַ�ռ�����Ϣ
SELECT assa.party_site_id
  FROM ap_supplier_sites_all assa
       -- ���� party_site_id �õ���Ӧ�̵�ַ���ռ�������
         SELECT hps.addressee
           FROM hz_party_sites hps;


-- ��Ӧ�������ʻ������ι�ϵ
SELECT *
  FROM iby_pmt_instr_uses_all;
-- ��Ӧ�������ʻ������ι�ϵ��ϸ ( ��������Ӧ�̲�ķ�����Ϣ ):
SELECT *
  FROM iby_external_payees_all;

--4. �ͻ� customer
--SQL ��ѯ
-- �ͻ��˻��� ����� 1063 �����ͻ�Ϊ�� -->>PARTY_ID = 21302
SELECT *
  FROM hz_cust_accounts aa
 WHERE aa.cust_account_id = 1063;

-- �ͻ����Ƽ���ַȫ����Ϣ�� -->> PARTY_NUMBER = 19316
SELECT *
  FROM hz_parties aa
 WHERE aa.party_id = 21302;

-- �ͻ��ص��˻����ļ�
SELECT *
  FROM hz_cust_acct_sites_all
 WHERE cust_account_id = 1063;

-- �ͻ��ص� ( ���� hz_cust_acct_sites_all)
SELECT *
  FROM hz_party_sites
 WHERE party_id = 21302;

-- �ص��ַ���� ( ���� hz_cust_acct_sites_all)
SELECT aa.address1
      ,aa.address_key
  FROM hz_locations   aa
      ,hz_party_sites bb
 WHERE aa.location_id = bb.location_id
   AND bb.party_id = 21302;

-- �ͻ��ص�ҵ��Ŀ�� ( ���� hz_cust_acct_sites_all �� CUST_ACCT_SITE_ID)
SELECT *
  FROM hz_cust_site_uses_all;

-- �ͻ��ص���ϸ��Ϣ���Թ�Ӧ�� OU ����� ORG_ID = 119
SELECT aa.party_site_id            �ͻ���֯�ص�id
      ,aa.party_id                 �ͻ���֯id
      ,aa.location_id              �ص�id
      ,aa.party_site_number        �ص���
      ,aa.identifying_address_flag ��ַ��ʾ
      ,aa.status                   ��Ч��
      ,aa.party_site_name
      ,bb.org_id                   ҵ��ʵ��
      ,bb.bill_to_flag             �յ���ʾ
      ,bb.ship_to_flag             �ջ���ʾ
      ,cc.address1                 �ص�����
      ,dd.site_use_id
      ,dd.site_use_code
      ,dd.primary_flag
      ,dd.status
      ,dd.location                 ҵ��Ŀ��
      ,dd.bill_to_site_use_id      �յ���id
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

--************* �ۺϲ�ѯ ************--
-- �ͻ�������
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

-- �ͻ��տ�� SQL
  SELECT arm.name receipt_method_name
          FROM hz_cust_accounts        hca
        ,ra_cust_receipt_methods rcrm
        ,ar_receipt_methods      arm
         WHERE hca.cust_account_id = rcrm.customer_id
           AND rcrm.receipt_method_id = arm.receipt_method_id
         ORDER BY rcrm.creation_date;


-- �ͻ��˻��������˻���Ϣ SQL
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
-- �ͻ������е�ַ��Ϣ SQL
SELECT hl.country || '-' || hl.province || '-' || hl.city || '-' ||
       hl.address1 || '-' || hl.address2 || '-' || hl.address3 || '-' ||
       hl.address4 bank_address
  FROM hz_party_sites hps
      ,hz_locations   hl
 WHERE hps.location_id = hl.location_id
 ORDER BY hps.creation_date;
-- �ͻ��˻�����ϵ����Ϣ����ϵ�ˡ��绰���ֻ��� Email SQL
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
-- �ͻ���ַ
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

-- �ͻ��˻����ַ contact person ��Ϣ :phone,mobile,email
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

-- �ͻ��˻��ص��ַ
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
-- �ͻ��������ļ�
SELECT *
  FROM hz_cust_profile_classes;

SELECT *
  FROM hz_customer_profiles;
SELECT *
  FROM hz_cust_prof_class_amts;
SELECT *
  FROM hz_cust_profile_amts;

--5. ���� oe
--
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
   AND msi.organization_id = 141
   AND l.flow_status_code = ol.lookup_code
   AND ol.lookup_type = 'LINE_FLOW_STATUS'
   AND cust.account_number IN ('91010072'
                              ,'91010067'
                              ,'91010036')
 ORDER BY party_name
         ,�ջ���
         ,���۶���;

--6. �ɹ����� pr
-- ���뵥ͷ ���Ե�����֯ ORG_ID=112 �ڲ����� =14140002781 Ϊ��
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
   AND prh.org_id = 112
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
 WHERE prl.org_id = 112
   AND prl.item_id = item.inventory_item_id
   AND prl.destination_organization_id = item.organization_id
   AND prl.requisition_header_id = 3379;
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
   AND prh.org_id = 112
   AND prh.segment1 = '14140002781';
--( ���۶�����¼�жԷ� OU_ID, ���뵥�ؼ��� SOURCE_DOCUMENT_ID ���뵥�� SOURCE_DOCEMENT_REF)

** ** ** ** ** ** ** ** ** * �ۺϲ�ѯ�� ** ** ** ** ** ** ** ** ** *
-- ���뵥ͷ�ۺϲ�ѯ ��������ֻ�ܲ�ѯ -- ������֯ ORG_ID=112)
  SELECT prh.requisition_header_id       ���뵥ͷ id
        ,prh.org_id                      ��֯ id
        ,prh.segment1                    ���뵥���
        ,prh.creation_date               ��������
        ,prh.created_by                  ������ id
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
     AND prh.org_id = 112;

-- ���贴����ͼֻ���� SELECT ���ǰ����
CREATE OR REPLACE view cux_inv_pr112 AS 7. �ɹ�����po
-- �ɹ���ͷ��Ϣ TYPE_LOOKUP_CODE='STANDARD' ���Թ�Ӧ�� OU ORG_ID=119 �ɹ��� ='' Ϊ����
-- ����˵�� TYPE_LOOKUP_CODE='STANDARD' Ϊ�ɹ��� TYPE_LOOKUP_CODE='BLANKET' Ϊ�ɹ�Э��
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

-->> POH.SEGMENT1 = '14730005436' PO_HEADER_ID = 10068
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
      ,po_line_locations_all po_lct
      ,mtl_system_items      item
 WHERE pol.org_id = po_lct.org_id
   AND pol.po_line_id = po_lct.po_line_id
   AND pol.item_id = item.inventory_item_id
   AND item.organization_id = 142
   AND pol.org_id = 119
   AND pol.po_header_id = 10068;
-- ˵���� Po_Line_Locations_all ϵ �� ���˱� ��

-- �ۺϲ�ѯ 1 �����������Ӧ����֯�����ϣ����ڲɹ�Э�飬��ȱʧ�ɹ�Ա��ȱʧ�ֿ⣻
SELECT msif.segment1         ���ϱ���
      ,msif.description      ��������
      ,msif.long_description ������ϸ����
      ,
       --MSIF.primary_unit_of_measure ������λ ,
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
   AND (misd.subinventory_code IS NULL OR prf.last_name IS NULL)

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
   AND msi.organization_id = 1155
   AND msi.segment1 = '18020200012';
-- ���Ͽ������
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
   AND cst.inventory_item_id = 12781
   AND cst.organization_id = 1155;

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
---�ر�˵����level connect_by_isleaf connect_by_root sys_connect_by_path(bbm.assembly_item_id, '/') ����start
--- WITH ���� CONNECT BY �����ú������ֶ� 

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
      ,aa.wip_supply_type           ��Ӧ TYPE
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
/*
1 ������״̬ TYPE ֵ˵����
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
--( ������ --------------------------------------------------------------------------?)

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
   AND wdj.organization_id = 1155
   AND pp.segment1 = '07D9202';

--11. ���� gl
SELECT *
  FROM gl_sets_of_books ����;
SELECT *
  FROM gl_code_combinations gcc
 WHERE gcc.summary_flag = 'Y' ��Ŀ���;
SELECT *
  FROM gl_balances ��Ŀ���;
SELECT *
  FROM gl_je_batches ƾ֤��;
SELECT *
  FROM gl_je_headers ƾ֤ͷ;
SELECT *
  FROM gl_je_lines ƾ֤��;
SELECT *
  FROM gl_je_categories ƾ֤����;
SELECT *
  FROM gl_je_sources ƾ֤��Դ;
SELECT *
  FROM gl_summary_templates ��Ŀ����ģ��;
SELECT *
  FROM gl_account_hierarchies ��Ŀ����ģ����;
--13. Ӧ�� ar
SELECT *
  FROM ar_batches_all ��������;
SELECT *
  FROM ra_customer_trx_all ��Ʊͷ;
SELECT *
  FROM ra_customer_trx_lines_all ��Ʊ��;
SELECT *
  FROM ra_cust_trx_line_gl_dist_all ��Ʊ����;
SELECT *
  FROM ar_cash_receipts_all �տ�;
SELECT *
  FROM ar_receivable_applications_all ����;
SELECT *
  FROM ar_payment_schedules_all ��Ʊ����;
SELECT *
  FROM ar_adjustments_all ��Ʒ�¼;
SELECT *
  FROM ar_distributions_all ����ƻ�;
-- 14. Ӧ�� ap
SELECT *
  FROM ap_invoices_all ��Ʊͷ;
SELECT *
  FROM ap_invoice_distributions_all ��Ʊ��;
SELECT *
  FROM ap_payment_schedules_all ����ƻ�;
SELECT *
  FROM ap_check_stocks_all ����;
SELECT *
  FROM ap_checks_all ����;
SELECT *
  FROM ap_bank_branches ����;
SELECT *
  FROM ap_bank_accounts_all �����ʺ�;
SELECT *
  FROM ap_invoice_payments_all ����;

-- 15. Ӧ�á�ֵ����������
--fnd
SELECT *
  FROM fnd_application;
SELECT *
  FROM fnd_application_tl
 WHERE application_id = 101;
SELECT *
  FROM fnd_application_vl
 WHERE application_id = 101;
-- ֵ��
SELECT *
  FROM fnd_flex_value_sets;
SELECT *
  FROM fnd_flex_values;
SELECT *
  FROM fnd_flex_values_vl;
-- ������
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
  FROM fnd_concurrent_programs �����;
SELECT *
  FROM fnd_concurrent_requests �����;
SELECT *
  FROM fnd_concurrent_processes ���̱�;
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

-- 1����ѯ��ƿ�Ŀ�ֶ���Ϣ
SELECT *
  FROM gl_code_combinations;
-- ��ѯ��ƿ�Ŀ�����Ϣ
SELECT *
  FROM gl_code_combinations_kfv;
--2) ��ѯ�Զ���Ŀͻ�����ر����ͼ
SELECT *
  FROM user_tables
 WHERE table_name LIKE 'CUX%';
-- ��ѯ���û�ӵ����Щ��ͼ
SELECT *
  FROM user_views
 WHERE view_name LIKE 'CUX%';
-- ��ѯ���û�ӵ����Щ����
SELECT *
  FROM user_indexes;
--3) ��ѯ���ϴ����¼ ˵���� mtl_material_transactions ������¼�������漰�ֿ��շ������Ͻ��׼�¼���������ɹ��� wip ������������ȶ��ִ���ģʽ�����ݡ�
-- ������ ��ѯĳ�û��ڵ������˻����������嵥
SELECT aa.transaction_id ���״���
      ,aa.inventory_item_id ��Ŀ����
      ,cc.segment1 ���ϱ���
      ,cc.description ����˵��
      ,aa.organization_id ��֯����
      ,aa.subinventory_code �ӿ�����
      ,aa.transaction_type_id ����id
      ,bb.transaction_type_name ��������
      ,aa.transaction_quantity ����
      ,aa.transaction_uom ��λ
      ,aa.transaction_date ��������
      ,aa.transaction_reference ���ײο�
      ,aa.transaction_source_id �ο�Դid
      ,aa.department_id ����id
      ,aa.operation_seq_num �����
      ,round(aa.actual_cost
            ,2) ʵ�ʳɱ�
      ,round(aa.transaction_cost
            ,2) ����ɱ�
      ,round(aa.prior_cost
            ,2) �ɳɱ�
      ,round(aa.new_cost
            ,2) �³ɱ�
      ,round(aa.variance_amount
            ,2) ������
      ,aa.transaction_quantity * round(aa.prior_cost
                                      ,2) ���׽��
      ,dd.user_name �û�����
      ,ee.full_name �û�����
      ,aa.attribute1 ����������
      ,aa.attribute15 ������ע
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
/* ���ϴ����¼ mtl_material_transactions ��������ɱ�˵����
-- ������ TRANSACTION_TYPE_ID = 41 ¼��۸����ȣ� =Actual_Cost ���ƶ�ƽ�� TRANSACTION_QUANTITY > 0 , ��������
ע�� 1 ������ٽ��ս���¼���˼۸���¼��۸���� Actual_Cost �������ƶ�ƽ��
2 �����û��¼��۸��ֶ� NULL ����ϵͳ���Ե�ǰ�ɱ����գ����� Actual_Cost
-- ��� TRANSACTION_TYPE_ID = 31 �Գ� =Actual_Cost �� TRANSACTION_QUANTITY < 0 , ��������
-- �ɹ��� TRANSACTION_TYPE_ID = 18 �� �� =Actual_Cost ���ƶ�ƽ�� TRANSACTION_QUANTITY > 0
-- �ɹ��� TRANSACTION_TYPE_ID = 36 �� �� =Actual_Cost �� TRANSACTION_QUANTITY < 0
ע�� 1) ϵͳ���ɹ��ɱ��˻��Ϳ۳�����������������״����
2) ��������۳�����۳������¼����һ���³ɱ���
3 ������������۳�����۳�ȫ�����ͻ�����п��������λ�ɱ� =0 �����ʣ������۵Ĳ��ּ����ֶ� VARIANCE_AMOUNT ��
-- ��ҵ�� TRANSACTION_TYPE_ID = 35 �Ե�ǰ�ɱ����� =Actual_Cost �� TRANSACTION_QUANTITY < 0 ���ض������������
-- ��ҵ�� TRANSACTION_TYPE_ID = 43 �Ե�ǰ�ɱ��룬 =Actual_Cost �����ƶ�ƽ�� TRANSACTION_QUANTITY > 0
-- ���ͳ� TRANSACTION_TYPE_ID = 100 �Ե�ǰ�ɱ����� =Actual_Cost �� TRANSACTION_QUANTITY < 0
-- ������ TRANSACTION_TYPE_ID = 101 �����ͼ��� �� =Actual_Cost ���ƶ�ƽ�� TRANSACTION_QUANTITY > 0
-- ���۷� TRANSACTION_TYPE_ID = 33 �Ե�ǰ�ɱ����� =Actual_Cost �� TRANSACTION_QUANTITY < 0
-- ������ TRANSACTION_TYPE_ID = 15 �Ե�ǰ�ɱ��룬 =Actual_Cost �� TRANSACTION_QUANTITY > 0
*/
-- ���ϴ����¼�����б�
SELECT bb.transaction_type_id   ����id
      ,bb.transaction_type_name ����
      ,bb.description           ˵��
  FROM mtl_transaction_types bb
 ORDER BY bb.transaction_type_id;
-- ������Դ�����б�
SELECT *
  FROM mtl_txn_source_types;
-- ����ԭ������
SELECT reason_id   ԭ�����
      ,reason_name ����
      ,description ����
  FROM inv.mtl_transaction_reasons;

--����·��

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
