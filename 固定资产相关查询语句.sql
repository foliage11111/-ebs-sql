-----------�ɱ����Ķ�
select v.flex_value, v.description
  from fnd_id_flex_segments_vl f,--------�������----------------������
       fnd_flex_values_vl      v,-----������ֵ����ֵ---------������ֵ
       gl_code_combinations    gcc----------�ʻ���϶���
 where f.id_flex_code = 'GL#'-------GL# �Ӹ�#�ţ���ʾ������
   and f.application_column_name='SEGMENT2'
   and v.flex_value_set_id = f.flex_value_set_id
   and gcc.code_combination_id = 97968
   and gcc.segment2 = v.flex_value   
   -----------------------------------------�ص��ѯ
SELECT V1.FLEX_VALUE,
       V1.DESCRIPTION,
       V2.FLEX_VALUE,
       V2.DESCRIPTION,
       V3.FLEX_VALUE,
       V3.DESCRIPTION
  FROM FND_ID_FLEXS      FIF,--------������
       FND_ID_FLEX_SEGMENTS_VL f1,------�������--------
       FND_ID_FLEX_SEGMENTS_VL f2,------�������--------
       FND_ID_FLEX_SEGMENTS_VL f3,------�������--------
       FND_FLEX_VALUES_VL      V1,-----������ֵ����ֵ------
       FND_FLEX_VALUES_VL      V2,-----������ֵ����ֵ------
       FND_FLEX_VALUES_VL      V3,-----������ֵ����ֵ------
       FA_LOCATIONS            L-----�ص�
 where FIF.ID_FLEX_CODE = 'LOC#'----------------�Ӹ�# �ţ���ʾ������-----�ص㵯����
   AND FIF.ID_FLEX_CODE=F1.ID_FLEX_CODE
   and F1.APPLICATION_COLUMN_NAME = 'SEGMENT1'
   AND F1.FLEX_VALUE_SET_ID = V1.FLEX_VALUE_SET_ID
   AND FIF.ID_FLEX_CODE=F2.ID_FLEX_CODE
   AND F2.APPLICATION_COLUMN_NAME = 'SEGMENT2'
   AND F2.FLEX_VALUE_SET_ID = V2.FLEX_VALUE_SET_ID
   AND FIF.ID_FLEX_CODE=F3.ID_FLEX_CODE
   AND F3.APPLICATION_COLUMN_NAME = 'SEGMENT3'
   AND F3.FLEX_VALUE_SET_ID = V3.FLEX_VALUE_SET_ID
   AND L.LOCATION_ID = 6115
   AND L.SEGMENT1 = V1.FLEX_VALUE
   AND L.SEGMENT2 = V2.FLEX_VALUE
   AND L.SEGMENT3 = V3.FLEX_VALUE
   AND V2.PARENT_FLEX_VALUE_LOW = V1.FLEX_VALUE  
   
-----------------------------------����ѯ
SELECT V1.FLEX_VALUE,
       V1.DESCRIPTION,
       V2.FLEX_VALUE,
       V2.DESCRIPTION,
       V3.FLEX_VALUE,
       V3.DESCRIPTION
  FROM FND_ID_FLEXS      FIF,-----------------------������
       FND_ID_FLEX_SEGMENTS_VL f1,-----------------------------�������
       FND_ID_FLEX_SEGMENTS_VL f2,-----------------------------�������
       FND_ID_FLEX_SEGMENTS_VL f3,-----------------------------�������
       FND_FLEX_VALUES_VL      V1,-----------------------------������ֵ��
       FND_FLEX_VALUES_VL      V2,-----------------------------������ֵ��
       FND_FLEX_VALUES_VL      V3,-----------------------------������ֵ��
       fa_categories            c----------------------------�ʲ����
 where FIF.ID_FLEX_CODE = 'CAT#'
   AND FIF.ID_FLEX_CODE=F1.ID_FLEX_CODE
   and F1.APPLICATION_COLUMN_NAME = 'SEGMENT1'
   AND F1.FLEX_VALUE_SET_ID = V1.FLEX_VALUE_SET_ID
   AND FIF.ID_FLEX_CODE=F2.ID_FLEX_CODE
   AND F2.APPLICATION_COLUMN_NAME = 'SEGMENT2'
   AND F2.FLEX_VALUE_SET_ID = V2.FLEX_VALUE_SET_ID
   AND FIF.ID_FLEX_CODE=F3.ID_FLEX_CODE
   AND F3.APPLICATION_COLUMN_NAME = 'SEGMENT3'
   AND F3.FLEX_VALUE_SET_ID = V3.FLEX_VALUE_SET_ID
   AND c.CATEGORY_ID = 579
   AND c.SEGMENT1 = V1.FLEX_VALUE
   AND c.SEGMENT2 = V2.FLEX_VALUE
   AND c.SEGMENT3 = V3.FLEX_VALUE
   AND v3.PARENT_FLEX_VALUE_LOW=v2.FLEX_VALUE
   ---------------------------����ѯ
select fa.asset_id, --�ʲ����
       fa.creation_date, --�ʲ�����ʱ��
       fdp.period_name, --�ڼ�
       fa.asset_number, --�ʲ�����
       fa.tag_number, --�ʲ���ǩ
       fa.manufacturer_name, --������
       fdh.book_type_code, --�ʲ��ʲ�
       fa.model_number, --�ͺ�
       fa.current_units, --����
       fav.description, --�ʲ�����
       FDH.CODE_COMBINATION_ID CODE_COMBINATION_ID,
       FDH.location_id, --�ʲ��ص�ID
       FA.ASSET_CATEGORY_ID category_id, --�ʲ����ID
       nvl(papf.last_name, '��') last_name, --�ʲ�����Ա
       nvl(papf.employee_number, '��') employee_number, --Ա������
       fb.life_in_months / 12 life_year, --------ʹ������---new
       fa.current_units units, ---����---new
       fb.unit_of_measure uom, -----------������λ----new
       fb.date_placed_in_service ----��������------new
  from fa_deprn_periods        fdp,-------------------------�ʲ��۾�����
       asset_id           fa,---------------------------�ʲ���ϸ����
       fa_additions_tl         fav,---------------------------�ʲ���������
       fa_distribution_history fdh,----------------------------�ʲ�������ϸ
       per_all_people_f        papf,
       fa_books                fb ----new
 where fdh.book_type_code = 'HLMC_FA_4425' -------------�������'SHMC_FA_6810'
   and fa.asset_id = fdh.asset_id
   and fa.asset_id = fb.asset_id ---------new
   and fb.book_type_code = fdh.book_type_code ---new
   and fdp.period_close_date between fb.date_effective --new
       and nvl(fb.date_ineffective, sysdate) --new
   and fdh.distribution_id =
       (SELECT MAX(DH2.DISTRIBUTION_ID)
          FROM FA_DISTRIBUTION_HISTORY DH2
         WHERE DH2.ASSET_ID = FA.ASSET_ID
           and dh2.book_type_code = fdh.book_type_code
           AND DH2.DATE_EFFECTIVE <= NVL(FDP.PERIOD_CLOSE_DATE, SYSDATE))
   and fdh.book_type_code = fdp.book_type_code
   and fa.asset_id = fav.asset_id
   and fav.language = 'ZHS'
   and fdp.period_name = 'MAY-08' ----------------�������'MAY-08'
   and fdh.assigned_to = papf.person_id(+)
   and nvl(papf.effective_end_date, sysdate + 1) > sysdate
   and fa.creation_date between fdp.period_open_date and
       fdp.period_close_date;
-----------------------------------------------------------�ʲ���ϸ��Ϣ�Ĳ�ѯ
   ---------------------------����ѯ
select fa.asset_id, --�ʲ����
       fa.creation_date, --�ʲ�����ʱ��
       fdp.period_name, --�ڼ�
       fa.asset_number, --�ʲ�����
       fa.tag_number, --�ʲ���ǩ
       fa.manufacturer_name, --������
       fdh.book_type_code, --�ʲ��ʲ�
       fa.model_number, --�ͺ�
       fa.current_units, --����
       fav.description, --�ʲ�����
       FDH.CODE_COMBINATION_ID CODE_COMBINATION_ID,
       FDH.location_id, --�ʲ��ص�ID
       FA.ASSET_CATEGORY_ID category_id, --�ʲ����ID
       nvl(papf.last_name, '��') last_name, --�ʲ�����Ա
       nvl(papf.employee_number, '��') employee_number, --Ա������
       fb.life_in_months / 12 life_year, --------ʹ������---new
       fa.current_units units, ---����---new
       fb.unit_of_measure uom, -----------������λ----new
       fb.date_placed_in_service ----��������------new
  from fa_deprn_periods        fdp,-------------------------�ʲ��۾�����
       fa_additions_b          fa,---------------------------�ʲ���ϸ����
       fa_additions_tl         fav,---------------------------�ʲ���������
       fa_distribution_history fdh,----------------------------�ʲ�������ϸ
       per_all_people_f        papf,
       fa_books                fb ----new
 where fdh.book_type_code = 'HLMC_FA_4425' -------------�������'SHMC_FA_6810'
   and fa.asset_id = fdh.asset_id
   and fa.asset_id = fb.asset_id ---------new
   and fb.book_type_code = fdh.book_type_code ---new
   and fdp.period_close_date between fb.date_effective --new
       and nvl(fb.date_ineffective, sysdate) --new
   and fdh.distribution_id =
       (SELECT MAX(DH2.DISTRIBUTION_ID)
          FROM FA_DISTRIBUTION_HISTORY DH2
         WHERE DH2.ASSET_ID = FA.ASSET_ID
           and dh2.book_type_code = fdh.book_type_code
           AND DH2.DATE_EFFECTIVE <= NVL(FDP.PERIOD_CLOSE_DATE, SYSDATE))
   and fdh.book_type_code = fdp.book_type_code
   and fa.asset_id = fav.asset_id
   and fav.language = 'ZHS'
   and fdp.period_name = 'MAY-08' ----------------�������'MAY-08'
   and fdh.assigned_to = papf.person_id(+)
   and nvl(papf.effective_end_date, sysdate + 1) > sysdate
-----------------------begin �ɱ����ĶΡ��ɱ������������ʲ��ص��1���ʲ��ص��2���ʲ��ص��3���ʲ��ص�����1���ʲ��ص�����2���ʲ��ص�����3��������������---transaction_out_In
select * from fa_distribution_history where asset_id=10337487;
select fdh.transaction_header_id_in,fdh.transaction_header_id_out ,fdh.* from fa_distribution_history fdh where asset_id=10337487;
-----fa_books  ��������,ʹ������
select fa.life_in_months/12,fa.date_placed_in_service,fa.* from fa_books fa where fa.asset_id=10337487---transaction_in_out
-----------fa_asset_history ���ʲ����ID���ʲ�������ơ�����
select * from fa_asset_history fah where fah.asset_id=10337487---transaction_in_OUY
