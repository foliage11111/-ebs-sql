--. �û������μ� hr
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
      ,fnd_user_resp_groups_all  bb
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
       END �Ա�  --case �÷�һ
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
          '21 ���� ' 
       END ������� --case �÷���
  FROM per_all_people_f paf; 
