DECLARE
  l_last_scheduled_close_date DATE;
  l_le_sysdate                DATE;
  l_max_open_date DATE;
  l_prior_period_open     BOOLEAN;
  l_new_acct_period_id    NUMBER;
  l_duplicate_open_period BOOLEAN;
  l_commit_completed      BOOLEAN;
  l_return_status         VARCHAR2(1);
  
 
 
 
BEGIN
  
 fnd_global.apps_initialize(user_id      => 0, ---syadmin
                             resp_id      => 53387,--实际职责
                             resp_appl_id => 401);--库存
  mo_global.init('M');

 l_max_open_date:=null;
-- l_max_open_date:=to_Date('2018-3-1','yyyy-mm-dd');--最多开到哪一天的月分之前的那个月,为空则开所有


  -- operation units
   FOR ou IN (SELECT organization_id org_id,name
               FROM hr_operating_units
              WHERE set_of_books_id = fnd_profile.VALUE('GL_SET_OF_BKS_ID')---按账簿来取ou
              and date_to is null -- 基本取得所有ou了
              ) LOOP
    l_le_sysdate := inv_le_timezone_pub.get_le_sysdate_for_ou(ou.org_id); --当前法人实体的有效日期,一般为当前日期*/
    
   -- inventory organization
    FOR org IN (SELECT organization_id
                  FROM org_organization_definitions
                 WHERE 
								  operating_unit = ou.org_id
									and disable_date is null
                  --  organization_id = 2393 ---times group
                 ORDER BY organization_id) LOOP   --取得ou下所有inv
                 
      SELECT nvl(MAX(schedule_close_date), l_le_sysdate-30)
        INTO l_last_scheduled_close_date
        FROM org_acct_periods
       WHERE organization_id = org.organization_id;
       
      FOR ps IN (SELECT sob.period_set_name,
                        sob.accounted_period_type,
                        ps.period_name,
                        ps.period_year,
                        ps.period_num period_number,
                        ps.end_date
                   FROM gl_sets_of_books sob, gl_period_statuses ps
                  WHERE sob.set_of_books_id = fnd_profile.VALUE('GL_SET_OF_BKS_ID') -- 62
                    AND sob.set_of_books_id = ps.set_of_books_id
                    AND ps.application_id = 401---only inv
                    AND ps.adjustment_period_flag = 'N'
                    AND (ps.period_name, ps.period_year) NOT IN
                        (SELECT period_name, period_year
                           FROM org_acct_periods
                          WHERE organization_id = org.organization_id)
										and ps.end_date<=nvl(l_max_open_date,ps.end_date)
                    AND ps.start_date>l_last_scheduled_close_date
                  ORDER BY ps.period_year, ps.effective_period_num) LOOP
        -- open the period
				-- dbms_output.put_line(ou.org_id||'-'||org.organization_id||' Period: (' || ps.period_name || ') in');
        cst_accountingperiod_pub.open_period(p_api_version               => 1.0,
                                             p_org_id                    => org.organization_id,
                                             p_user_id                   => fnd_global.user_id,
                                             p_login_id                  => fnd_global.login_id,
                                             p_acct_period_type          => ps.accounted_period_type,
                                             p_org_period_set_name       => ps.period_set_name,
                                             p_open_period_name          => ps.period_name,
                                             p_open_period_year          => ps.period_year,
                                             p_open_period_num           => ps.period_number,
                                             x_last_scheduled_close_date => l_last_scheduled_close_date,
                                             p_period_end_date           => ps.end_date,
                                             x_prior_period_open         => l_prior_period_open,
                                             x_new_acct_period_id        => l_new_acct_period_id,
                                             x_duplicate_open_period     => l_duplicate_open_period,
                                             x_commit_complete           => l_commit_completed,
                                             x_return_status             => l_return_status);
        IF l_commit_completed THEN
					null;
         -- dbms_output.put_line(ou.name||'-'||org.organization_id||' Period: (' || ps.period_name || ') is success');
        ELSE
          dbms_output.put_line(ou.name||'-'||org.organization_id||'Period: (' || ps.period_name || ') is failed :'||l_return_status);
          GOTO stop_open;
        END IF;
      END LOOP;
			<<stop_open>>---换下一个org
			 NULL;
    END LOOP;
		 
		
  END LOOP;
  
END;