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
 
 --��ѯPARTY TYPE�ֶε�ֵ

SELECT *
  FROM fnd_lookup_values a
 WHERE a.lookup_type = 'PARTY_TYPE'
   AND a.language = 'ZHS'
   AND a.tag = 'Y';
--��ѯ�ͻ����ࡣ�ͻ����
SELECT *
  FROM fnd_lookup_values_vl t
 WHERE t.lookup_type = 'CUSTOMER_CATEGORY'; --�ͻ����

SELECT *
  FROM fnd_lookup_values_vl t
 WHERE t.lookup_type = 'CUSTOMER CLASS'; --�ͻ�����

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
   AND bb.org_id = 363
   AND aa.status = 'A'
   AND aa.location_id = cc.location_id
   AND bb.cust_acct_site_id(+) = dd.cust_acct_site_id
   AND dd.status <> 'I';
  ----------------------�ͻ����-------------------------------
  SELECT flv.LOOKUP_TYPE, flv.LOOKUP_CODE, flv.MEANING
  FROM fnd_lookup_values_vl flv
 WHERE flv.lookup_type = 'CUSTOMER_CATEGORY'
   AND nvl(flv.enabled_flag, 'N') = 'Y';

  
  ---------�ͻ���ز�ѯ---------------------------------------------
  BEGIN
    mo_global.init('AR');
  END;
  
  SELECT hp.party_number --�ͻ�ע���ʶ
, hp.party_name --��֯��/�ͻ�
, hp.known_as --����
, hp.organization_name_phonetic --����ƴ��
, acc.account_number --�ʺ�
, flv_sale.meaning sales_channel_code --��������
, acc.account_name --�˼�˵��
, flv_customer.meaning customer_class_code --����
, acc.orig_system_reference --�ο�
, flv_status.meaning status --״̬
, flv_type.meaning customer_type --�˻�����
, acc.attribute_category --������
, acc.attribute1 --ע��
, acc.attribute2 --��Ա�ƹ�
, acc.attribute3 --����Ҫ��
, acc.Attribute4 --�������Ƿ��ӡ�۸�
, acc.Attribute5 --��������
FROM hz_parties hp
, hz_cust_accounts acc
, fnd_lookup_values flv_sale --��������
, fnd_lookup_values flv_customer --����
, fnd_lookup_values flv_status --״̬
, fnd_lookup_values flv_type --�˻�����
WHERE hp.party_id = acc.party_id
AND acc.sales_channel_code = flv_sale.lookup_code
AND flv_sale.lookup_type = 'SALES_CHANNEL'
AND flv_sale.LANGUAGE = userenv('LANG')
AND acc.customer_class_code = flv_customer.lookup_code
AND flv_customer.lookup_type = 'CUSTOMER CLASS'
AND flv_customer.LANGUAGE = userenv('LANG')
AND acc.status = flv_status.lookup_code
AND flv_status.lookup_type = 'HZ_CPUI_REGISTRY_STATUS'
AND flv_status.LANGUAGE = userenv('LANG')
AND acc.customer_type = flv_type.lookup_code
AND flv_type.lookup_type = 'CUSTOMER_TYPE'
AND flv_type.LANGUAGE = userenv('LANG');
-----------------------------------------------------------------
--------------------------------------------------------------------- 

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
   AND hcp.standard_terms = rt.term_id(+);

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
