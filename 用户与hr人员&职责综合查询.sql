--. 用户、责任及 hr
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
      ,fnd_user_resp_groups_all  bb
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
       END 性别  --case 用法一
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
          '21 世纪 ' 
       END 出生年代 --case 用法二
  FROM per_all_people_f paf; 
