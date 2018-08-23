  --- EBS复制用户职责
   
    DECLARE  
      l_old_userName VARCHAR2(100):='CHENXISHENG_BP';  
      l_userName VARCHAR2(100):='SHH';--用户名需要大写  
      l_passWord VARCHAR2(240):='hand123';--密码需要数字和字母的组合  
      l_description VARCHAR2(240):='宋欢欢';  
        
        
      CURSOR cur_resps IS   
        SELECT DISTINCT users.user_name,  
                        appl.application_short_name,  
                        resp.responsibility_key,  
                        users.description,  
                        users.start_date,  
                        --Security Group Key  
                        --users.Security_Group_Id,  
                        'STANDARD' security_group,  
                        users.end_date  
          FROM apps.fnd_user                    users,  
               apps.fnd_user_resp_groups_direct user_resp,  
               apps.fnd_responsibility_vl       resp,  
               apps.fnd_application_vl          appl  
         WHERE users.user_id = user_resp.user_id  
           AND user_resp.responsibility_application_id = resp.application_id  
           AND user_resp.responsibility_id = resp.responsibility_id  
           AND resp.application_id = appl.application_id  
           AND users.user_name = l_old_userName;  
      
    BEGIN  
      
      fnd_user_pkg.createuser(l_userName, 'SEED', l_passWord,x_description => l_description);  
      
      FOR dept_record IN cur_resps  
      LOOP  
        dbms_output.put_line(l_description);  
        fnd_user_pkg.addresp(l_userName,  
                             dept_record.application_short_name,  
                             dept_record.responsibility_key,  
                             dept_record.security_group,  
                             dept_record.description,  
                             dept_record.start_date,  
                             dept_record.end_date);  
        --COMMIT;  
        
      END LOOP;  
    END;  