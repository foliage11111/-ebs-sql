--11. 总账 gl
SELECT *
  FROM gl_sets_of_books 总帐;
SELECT *
  FROM gl_code_combinations gcc
 WHERE gcc.summary_flag = 'Y' 科目组合;
SELECT *
  FROM gl_balances 科目余额;
SELECT *
  FROM gl_je_batches 凭证批;
SELECT *
  FROM gl_je_headers 凭证头;
SELECT *
  FROM gl_je_lines 凭证行;
SELECT *
  FROM gl_je_categories 凭证分类;
SELECT *
  FROM gl_je_sources 凭证来源;
SELECT *
  FROM gl_summary_templates 科目汇总模板;
SELECT *
  FROM gl_account_hierarchies 科目汇总模板层次;
