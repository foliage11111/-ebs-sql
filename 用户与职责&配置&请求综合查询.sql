  ---4. 菜单、请求组与职责关联查询：

 SELECT frv.responsibility_name 职责名,
                frv.responsibility_key  职责代码,
                fa.application_name     应用产品,
                fm.MENU_NAME            菜单名,
                frg.REQUEST_GROUP_NAME  请求组名
           FROM FND_RESPONSIBILITY_VL frv,
                fnd_application_vl    fa,
                fnd_menus             fm,
                FND_REQUEST_GROUPS    frg
                
          WHERE 1 = 1
            AND frg.REQUEST_GROUP_ID(+) = frv.REQUEST_GROUP_ID
            AND fm.MENU_ID = frv.MENU_ID
            AND fa.application_id = frv.application_id
            and frv.responsibility_name like '%松本%'
            ;


-- 6. 职责

SELECT distinct fst.responsibility_name     职责名
  FROM fnd_responsibility_tl fst
 WHERE 1 = 1
   AND fst.language = 'ZHS'
   AND fst.RESPONSIBILITY_NAME like '%%';

--  7. 用户与职责


SELECT distinct wur.user_name 用户名,fst.responsibility_name     职责名
  FROM fnd_responsibility_tl fst,wf_all_user_roles wur
 WHERE 1 = 1
   AND fst.language = 'ZHS'
   -- AND fst.RESPONSIBILITY_NAME like '%%'
   --职责名字范围
   AND fst.RESPONSIBILITY_ID = wur.role_orig_system_id
  -- AND wur.user_name in ('','') 
  --用户名范围
   order by wur.user_name;
   

--  1. 菜单查询： 

--菜单查询
SELECT fm.MENU_NAME            菜单名,
       fm.TYPE                 菜单类型,
       fmev.ENTRY_SEQUENCE     序号,
       fmev.PROMPT             显示名称,
       fmev.DESCRIPTION        描述,
       fffv.function_name      功能名,
       fffv.USER_FUNCTION_NAME 用户功能名
  FROM fnd_menu_entries_vl     fmev, 
       fnd_form_functions_vl   fffv, 
       fnd_menus               fm
 WHERE 1 = 1
   AND fmev.menu_id = fm.menu_id
   AND fffv.function_id(+) = fmev.function_id
   --AND fm.MENU_NAME like '%松本%';
;
--  2. 请求组查询：

select fcp.CONCURRENT_PROGRAM_ID,fcp.CONCURRENT_PROGRAM_NAME,fcp.APPLICATION_ID
,fcp.output_file_type,fcp.USER_CONCURRENT_PROGRAM_NAME,fcp.DESCRIPTION,fcp.CREATION_DATE
from fnd_concurrent_programs_vl fcp  
where fcp.user_concurrent_program_name like 'CUX%';

--请求组查询
SELECT
    frg.request_group_name 请求组名字,
    frg.request_group_code 请求组代码,
    fa1.application_name 请求组应用产品,
    frg.description 请求组描述,
    frgu.request_unit_type 请求类型,
          --此代码必然为P（请求），没有写查请求集的方法，后续补充
    fcp.user_concurrent_program_name 请求名字,
    fa2.application_name 请求应用产品
FROM
    fnd_request_groups frg,
    fnd_request_group_units frgu,
    fnd_application_vl fa1,
    fnd_application_vl fa2,
    fnd_concurrent_programs_vl fcp
WHERE 
        frgu.request_group_id = frg.request_group_id
    AND
        fa1.application_id = frg.application_id
    AND
        fa2.application_id = frgu.application_id
    AND
        frgu.request_unit_id = fcp.concurrent_program_id
    AND
        fcp.user_concurrent_program_name LIKE 'CUX%';

--  3. 配置文件查询：

--查询系统中配置文件的创建情况
SELECT PROFILE_OPTION_NAME            配置文件名,
       USER_PROFILE_OPTION_NAME       用户配置文件名,
       DESCRIPTION                    说明,
       hierarchy_type                 层次结构类型,
       SITE_ENABLED_FLAG              地点可见,
       SITE_UPDATE_ALLOWED_FLAG       地点可更新,
       app_enabled_flag               应用产品可见,
       app_update_allowed_flag        应用产品可更新,
       RESP_ENABLED_FLAG              责任可见,
       RESP_UPDATE_ALLOWED_FLAG       责任可更新,
       SERVER_ENABLED_FLAG            服务器可见,
       SERVER_UPDATE_ALLOWED_FLAG     服务器可更新,
       SERVERRESP_ENABLED_FLAG        服务器职责可见,
       SERVERRESP_UPDATE_ALLOWED_FLAG 服务器职责可更新,
       ORG_ENABLED_FLAG               组织可见,
       ORG_UPDATE_ALLOWED_FLAG        组织可更新,
       USER_ENABLED_FLAG              用户可见,
       USER_UPDATE_ALLOWED_FLAG       用户可更新,
       start_date_active              有效起始日期,
       END_DATE_ACTIVE                有效截止日期,
       USER_VISIBLE_FLAG              用户访问可查看,
       USER_CHANGEABLE_FLAG           用户访问可更新,
       READ_ALLOWED_FLAG              可读,
       WRITE_ALLOWED_FLAG             可写,
       SQL_VALIDATION                 SQL验证,
       PROFILE_OPTION_ID              配置文件配置情况ID
  FROM FND_PROFILE_OPTIONS_VL
 WHERE PROFILE_OPTION_NAME LIKE '%%'

  
  ;

   
    


----12、评估业务组、ou、inv、法人的sql，法人一块有点问题，后续需要改进
SELECT          
                HOU.BUSINESS_GROUP_ID,
                HOU.BUSINESS_GROUP_NAME,
                HOU.OPERATING_UNITS_ID ORG_ID,
                HOU.OPERATING_UNIT_NAME,
                HOU.DATE_FROM,
                HOU.DATE_TO,
                HOU. LEGAL_ENTITY_ID,
                HOU.LEGAL_ENTITY_NAME,
                HOU.LOCATION_NAME,
                OOD.ORGANIZATION_CODE,
                OOD.ORGANIZATION_ID,
                OOD.ORGANIZATION_NAME,
                OOD.USER_DEFINITION_ENABLE_DATE,
                OOD.DISABLE_DATE,
                OOD.SET_OF_BOOKS_ID,
                OOD.INVENTORY_ENABLED_FLAG
  FROM APPS.HRFV_OPERATING_UNITS         HOU, --HR_OPERATING_UNITS;
       apps.Org_organization_definitions OOD
WHERE HOU.OPERATING_UNITS_ID = OOD.OPERATING_UNIT
  ORDER BY HOU.OPERATING_UNITS_ID, --ORG_ID
          OOD.ORGANIZATION_CODE
          ;
          
          
---13、查配置文件和设置的值，后面的mo看一下，
--但是由于值一块有的设置是设置库存组织或者啥的，没法各个都关联一下显示，其实应该是可以的，每个配置文件的value_set_id和对应的值。
   
   SELECT OP.PROFILE_OPTION_ID,
       TL.PROFILE_OPTION_NAME,
       TL.USER_PROFILE_OPTION_NAME,
       LV.LEVEL_ID,
       LV.文件安全性,
       VA.LEVEL_VALUE,
       CASE
       WHEN VA.LEVEL_ID = 10001 THEN '地点'
       WHEN VA.LEVEL_ID = 10002 THEN (SELECT FAV.APPLICATION_NAME
                                             FROM FND_APPLICATION_VL FAV
                                            WHERE FAV.APPLICATION_ID = VA.LEVEL_VALUE)
        WHEN VA.LEVEL_ID = 10003 THEN (SELECT /* $HEADER$ */
                                              T.RESPONSIBILITY_NAME
                                         FROM FND_RESPONSIBILITY_TL T,
                                              FND_RESPONSIBILITY B
                                        WHERE T.RESPONSIBILITY_ID = VA.LEVEL_VALUE
                                          AND T.RESPONSIBILITY_ID = B.RESPONSIBILITY_ID
                                          AND B.APPLICATION_ID = T.APPLICATION_ID
                                          AND NVL(B.END_DATE, SYSDATE + 1) > SYSDATE
                                          AND NVL(B.START_DATE, SYSDATE - 1) < SYSDATE
                                          AND T.LANGUAGE = 'ZHS')                                                       
        WHEN VA.LEVEL_ID = 10004 THEN (SELECT USER_NAME
                                        FROM FND_USER
                                       WHERE USER_NAME NOT IN
                                            ('*ANONYMOS*',
                                             'CONVERSION',
                                             'INITIAL SETUP',
                                             'FEEDER SYSTEM',
                                             'CONCURRENT MANAGER',
                                             'STANDALONE BATCH PROCESS')
                                        AND USER_ID = VA.LEVEL_VALUE
                                        AND NVL(END_DATE, SYSDATE + 1) > SYSDATE
                                        AND NVL(START_DATE, SYSDATE - 1) < SYSDATE)
       WHEN VA.LEVEL_ID = 10005 THEN(SELECT NODE_NAME FROM FND_NODES WHERE NODE_ID = VA.LEVEL_VALUE)
       WHEN VA.LEVEL_ID = 10006 THEN (SELECT NAME
                                        FROM HR_OPERATING_UNITS
                                       WHERE ORGANIZATION_ID = VA.LEVEL_VALUE)
       ELSE
         ''
       END AS PROFILE_LEVEL_VALUE,
       VA.PROFILE_OPTION_VALUE
  FROM FND_PROFILE_OPTIONS_TL TL,
       FND_PROFILE_OPTIONS OP,
       FND_PROFILE_OPTION_VALUES VA,
       (SELECT 10001 LEVEL_ID, '地点' 文件安全性
          FROM DUAL
        UNION
        SELECT 10002 LEVEL_ID, '应用产品' 文件安全性
          FROM DUAL
        UNION
        SELECT 10003 LEVEL_ID, '责任' 文件安全性
          FROM DUAL
        UNION
        SELECT 10004 LEVEL_ID, '用户' 文件安全性
          FROM DUAL
        UNION
        SELECT 10005 LEVEL_ID, '服务器' 文件安全性
          FROM DUAL
        UNION
        SELECT 10006 LEVEL_ID, '组织' 文件安全性
          FROM DUAL) LV
 WHERE TL.LANGUAGE = 'ZHS'
   AND TL.PROFILE_OPTION_NAME = OP.PROFILE_OPTION_NAME
   AND VA.PROFILE_OPTION_ID = OP.PROFILE_OPTION_ID
   AND VA.LEVEL_ID = LV.LEVEL_ID
   -- AND TL.PROFILE_OPTION_NAME like 'MO%'
    AND TL.USER_PROFILE_OPTION_NAME like 'MO%'
    ;
    
    
    --职责与请求组
    SELECT frv.responsibility_name 职责名,
                frv.responsibility_key  职责代码,
                fa.application_name     应用产品,
                fm.MENU_NAME            菜单名,
                frg.REQUEST_GROUP_NAME  请求组名,
                fa2.application_name      请求组应用,
                FCP.CONCURRENT_PROGRAM_NAME,
                FCP.user_concurrent_program_name
           FROM FND_RESPONSIBILITY_VL frv,
                fnd_application_vl    fa,
                fnd_application_vl    fa2,
                fnd_menus             fm,
                FND_REQUEST_GROUPS    frg,
                fnd_request_group_units FRGU,
                fnd_concurrent_programs_vl FCP
                
          WHERE 1 = 1
            AND frg.REQUEST_GROUP_ID(+) = frv.REQUEST_GROUP_ID
            AND fm.MENU_ID = frv.MENU_ID
            and fa2.APPLICATION_ID=frg.APPLICATION_ID 
            AND frg.REQUEST_GROUP_ID=FRGU.REQUEST_GROUP_ID
            AND fa.application_id = frv.application_id
            AND FRGU.REQUEST_UNIT_ID=FCP.CONCURRENT_PROGRAM_ID
            AND fcp.user_concurrent_program_name like 'CUX%';
            
     