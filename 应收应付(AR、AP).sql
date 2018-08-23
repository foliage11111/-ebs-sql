--13. 应收 ar
SELECT *
  FROM ar_batches_all 事务处理批;
SELECT *
  FROM ra_customer_trx_all 发票头;
SELECT *
  FROM ra_customer_trx_lines_all 发票行;
SELECT *
  FROM ra_cust_trx_line_gl_dist_all 发票分配;
SELECT *
  FROM ar_cash_receipts_all 收款;
SELECT *
  FROM ar_receivable_applications_all 核销;
SELECT *
  FROM ar_payment_schedules_all 发票调整;
SELECT *
  FROM ar_adjustments_all 会计分录;
SELECT *
  FROM ar_distributions_all 付款计划;
-- 14. 应付 ap
SELECT *
  FROM ap_invoices_all 发票头;
SELECT *
  FROM ap_invoice_distributions_all 发票行;
SELECT *
  FROM ap_payment_schedules_all 付款计划;
SELECT *
  FROM ap_check_stocks_all 单据;
SELECT *
  FROM ap_checks_all 付款;
SELECT *
  FROM ap_bank_branches 银行;
SELECT *
  FROM ap_bank_accounts_all 银行帐号;
SELECT *
  FROM ap_invoice_payments_all 核销;
