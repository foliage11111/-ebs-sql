-- 15. Ӧ�á�ֵ����������
--Ӧ��
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
  
  
select * from fnd_descr_flex_column_usages where FLEX_VALUE_SET_ID=1016471;---ֵ���Ƿ�����


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
   
   
   --��Ϣ
   select * from fnd_new_messages;

SELECT *
  FROM fnd_profile_options_vl;
SELECT *
  FROM fnd_concurrent_programs �����;
SELECT *
  FROM fnd_concurrent_requests �����;
SELECT *
  FROM fnd_concurrent_processes ���̱�;

---Ӧ�ó�����
---����� INV���ͻ�����һ����Ϊ CUX ���� CUXS��Ҫ���²�֪��
SELECT fa.application_id,
       fa.application_short_name,
       fpi.oracle_id,
       fa.basepath,
       fa.product_code,
       fpi.product_version,
       fpi.status,
       fpi.tablespace,
       fpi.index_tablespace,
       fpi.temporary_tablespace,
       fpi.db_status,
       fpi.patch_level
  FROM fnd_product_installations fpi,
       fnd_application           fa
 WHERE fpi.application_id = fa.application_id
 ORDER BY fa.application_short_name;