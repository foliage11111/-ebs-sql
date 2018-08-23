-- 15. 应用、值集、弹性域
--应用
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
  
  
select * from fnd_descr_flex_column_usages where FLEX_VALUE_SET_ID=1016471;---值集是否在用


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
   
   
   --消息
   select * from fnd_new_messages;

SELECT *
  FROM fnd_profile_options_vl;
SELECT *
  FROM fnd_concurrent_programs 程序表;
SELECT *
  FROM fnd_concurrent_requests 请求表;
SELECT *
  FROM fnd_concurrent_processes 进程表;

---应用程序简称
---库存简称 INV，客户化的一般简称为 CUX 或者 CUXS，要看下才知道
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