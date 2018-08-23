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
