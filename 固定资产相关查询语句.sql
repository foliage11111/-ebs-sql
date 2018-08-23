-----------成本中心段
select v.flex_value, v.description
  from fnd_id_flex_segments_vl f,--------弹性域段----------------弹性域
       fnd_flex_values_vl      v,-----弹性域值集的值---------弹性域值
       gl_code_combinations    gcc----------帐户组合定义
 where f.id_flex_code = 'GL#'-------GL# 加个#号，表示弹性域
   and f.application_column_name='SEGMENT2'
   and v.flex_value_set_id = f.flex_value_set_id
   and gcc.code_combination_id = 97968
   and gcc.segment2 = v.flex_value   
   -----------------------------------------地点查询
SELECT V1.FLEX_VALUE,
       V1.DESCRIPTION,
       V2.FLEX_VALUE,
       V2.DESCRIPTION,
       V3.FLEX_VALUE,
       V3.DESCRIPTION
  FROM FND_ID_FLEXS      FIF,--------弹性域
       FND_ID_FLEX_SEGMENTS_VL f1,------弹性域段--------
       FND_ID_FLEX_SEGMENTS_VL f2,------弹性域段--------
       FND_ID_FLEX_SEGMENTS_VL f3,------弹性域段--------
       FND_FLEX_VALUES_VL      V1,-----弹性域值集的值------
       FND_FLEX_VALUES_VL      V2,-----弹性域值集的值------
       FND_FLEX_VALUES_VL      V3,-----弹性域值集的值------
       FA_LOCATIONS            L-----地点
 where FIF.ID_FLEX_CODE = 'LOC#'----------------加个# 号，表示弹性域-----地点弹性域
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
   
-----------------------------------类别查询
SELECT V1.FLEX_VALUE,
       V1.DESCRIPTION,
       V2.FLEX_VALUE,
       V2.DESCRIPTION,
       V3.FLEX_VALUE,
       V3.DESCRIPTION
  FROM FND_ID_FLEXS      FIF,-----------------------弹性域
       FND_ID_FLEX_SEGMENTS_VL f1,-----------------------------弹性域段
       FND_ID_FLEX_SEGMENTS_VL f2,-----------------------------弹性域段
       FND_ID_FLEX_SEGMENTS_VL f3,-----------------------------弹性域段
       FND_FLEX_VALUES_VL      V1,-----------------------------弹性域值集
       FND_FLEX_VALUES_VL      V2,-----------------------------弹性域值集
       FND_FLEX_VALUES_VL      V3,-----------------------------弹性域值集
       fa_categories            c----------------------------资产类别
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
   ---------------------------主查询
select fa.asset_id, --资产编号
       fa.creation_date, --资产创建时间
       fdp.period_name, --期间
       fa.asset_number, --资产编码
       fa.tag_number, --资产标签
       fa.manufacturer_name, --制造商
       fdh.book_type_code, --资产帐簿
       fa.model_number, --型号
       fa.current_units, --数量
       fav.description, --资产描述
       FDH.CODE_COMBINATION_ID CODE_COMBINATION_ID,
       FDH.location_id, --资产地点ID
       FA.ASSET_CATEGORY_ID category_id, --资产类别ID
       nvl(papf.last_name, '无') last_name, --资产保管员
       nvl(papf.employee_number, '无') employee_number, --员工编码
       fb.life_in_months / 12 life_year, --------使用年限---new
       fa.current_units units, ---数量---new
       fb.unit_of_measure uom, -----------计量单位----new
       fb.date_placed_in_service ----启用日期------new
  from fa_deprn_periods        fdp,-------------------------资产折旧周期
       asset_id           fa,---------------------------资产详细资料
       fa_additions_tl         fav,---------------------------资产语言种类
       fa_distribution_history fdh,----------------------------资产分配明细
       per_all_people_f        papf,
       fa_books                fb ----new
 where fdh.book_type_code = 'HLMC_FA_4425' -------------传入参数'SHMC_FA_6810'
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
   and fdp.period_name = 'MAY-08' ----------------传入参数'MAY-08'
   and fdh.assigned_to = papf.person_id(+)
   and nvl(papf.effective_end_date, sysdate + 1) > sysdate
   and fa.creation_date between fdp.period_open_date and
       fdp.period_close_date;
-----------------------------------------------------------资产明细信息的查询
   ---------------------------主查询
select fa.asset_id, --资产编号
       fa.creation_date, --资产创建时间
       fdp.period_name, --期间
       fa.asset_number, --资产编码
       fa.tag_number, --资产标签
       fa.manufacturer_name, --制造商
       fdh.book_type_code, --资产帐簿
       fa.model_number, --型号
       fa.current_units, --数量
       fav.description, --资产描述
       FDH.CODE_COMBINATION_ID CODE_COMBINATION_ID,
       FDH.location_id, --资产地点ID
       FA.ASSET_CATEGORY_ID category_id, --资产类别ID
       nvl(papf.last_name, '无') last_name, --资产保管员
       nvl(papf.employee_number, '无') employee_number, --员工编码
       fb.life_in_months / 12 life_year, --------使用年限---new
       fa.current_units units, ---数量---new
       fb.unit_of_measure uom, -----------计量单位----new
       fb.date_placed_in_service ----启用日期------new
  from fa_deprn_periods        fdp,-------------------------资产折旧周期
       fa_additions_b          fa,---------------------------资产详细资料
       fa_additions_tl         fav,---------------------------资产语言种类
       fa_distribution_history fdh,----------------------------资产分配明细
       per_all_people_f        papf,
       fa_books                fb ----new
 where fdh.book_type_code = 'HLMC_FA_4425' -------------传入参数'SHMC_FA_6810'
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
   and fdp.period_name = 'MAY-08' ----------------传入参数'MAY-08'
   and fdh.assigned_to = papf.person_id(+)
   and nvl(papf.effective_end_date, sysdate + 1) > sysdate
-----------------------begin 成本中心段、成本中心描述、资产地点段1、资产地点段2、资产地点段3、资产地点描述1、资产地点描述2、资产地点描述3、保管人姓名、---transaction_out_In
select * from fa_distribution_history where asset_id=10337487;
select fdh.transaction_header_id_in,fdh.transaction_header_id_out ,fdh.* from fa_distribution_history fdh where asset_id=10337487;
-----fa_books  启用日期,使用年限
select fa.life_in_months/12,fa.date_placed_in_service,fa.* from fa_books fa where fa.asset_id=10337487---transaction_in_out
-----------fa_asset_history 、资产类别ID、资产类别名称、数量
select * from fa_asset_history fah where fah.asset_id=10337487---transaction_in_OUY
