--7. 采购订单po


---采购的：
SELECT pha.org_id               ou_id
      ,hou.NAME                 业务实体名称
      ,pha.po_header_id         采购单头id
      ,pha.segment1            采购单号
      ,pha.type_lookup_code     类型
      ,pha.vendor_id            供应商id
      ,vendor.vendor_name       供应商名
      ,pha.vendor_site_id       供应商地址id
      ,assa.vendor_site_code    供应商地点简称
      ,pla.line_num              订单行号
      ,plla.shipment_num        发运行号
      ,plla.closed_code         发运行状态
      ,msi.inventory_item_id    物料id
      ,msi.description            物料名称
      ,pha.currency_code        币种
      ,pla.unit_price           单价
      ,plla.quantity            订单数量
      ,plla.quantity_received   接收数量
      ,plla.quantity_accepted   接受数量
      ,plla.quantity_rejected   拒绝数量
      ,plla.quantity_billed     开单数量
      ,plla.quantity_cancelled   取消数量
      ,plla.need_by_date        需要日期
      ,plla.promised_date        承诺日期
      ,pha.creation_date        创建日期
      ,pha.authorization_status 订单状态
      ,pha.approved_flag        审批标识
      ,pha.approved_date        审批日期
      ,pha.comments             采购单说明备注
      ,fu.user_name             创建订单账号
  
  FROM po_headers_all   pha
      ,po_lines_all     pla
      ,fnd_user         fu
      ,ap_suppliers     vendor
      ,ap_supplier_sites_all assa
      ,po_distributions_all pda --发运表
      ,po_line_locations_all plla
      ,mtl_system_items      msi
       ,hr_operating_units           hou --ou 视图
 WHERE pha.created_by = fu.user_id
  AND pha.org_id=hou.ORGANIZATION_ID
  AND pha.vendor_site_id=assa.vendor_site_id
   AND pha.vendor_id = vendor.vendor_id
   AND pha.po_header_id = pda.po_header_id
   AND plla.line_location_id=pda.line_location_id
   AND plla.po_line_id=pla.po_line_id
   and pda.destination_organization_id=msi.organization_id
   AND pha.type_lookup_code = 'STANDARD'
   AND pla.item_id = msi.inventory_item_id
     and fu.USER_NAME = 'SIE_YZR' ---叶子瑞的单子
     and pha.org_id=8302---101组织
     order by pha.po_header_id desc
  ;


SELECT poh.org_id               ou_id
      ,poh.po_header_id         采购单头id
      ,poh.type_lookup_code     类型
      ,poh.authorization_status 状态
      ,poh.vendor_id            供应商id
      ,vendor.vendor_name       供应商名
      ,poh.vendor_site_id       供应商地址id
      ,poh.vendor_contact_id    供应商联系人id
      ,poh.ship_to_location_id  本方收货地id
      ,poh.bill_to_location_id  本方收单地id
      ,poh.creation_date        创建日期
      ,poh.approved_flag        审批yn
      ,poh.approved_date        审批日期
      ,poh.comments             采购单说明
      ,poh.terms_id             条款id
      ,poh.agent_id             采购员id
      ,agt_pp.last_name         采购员
      ,poh.created_by           创建者id
      ,fu.user_name             创建用户
      ,pp.full_name             用户姓名
  FROM po_headers_all   poh
      ,fnd_user         fu
      ,per_people_f     pp
      ,per_all_people_f agt_pp
      ,ap_suppliers     vendor
 WHERE poh.created_by = fu.user_id
   AND fu.employee_id = pp.person_id
   AND poh.agent_id = agt_pp.person_id
   AND poh.vendor_id = vendor.vendor_id
   AND poh.org_id = 119
   AND poh.type_lookup_code = 'STANDARD'
   AND poh.segment1 = '14730005436';
/*
FND_USER FU, per_people_f PP 用户相关表
po_agents_name_v 采购员视图 ----> PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID 采购员相关表
ap_suppliers 供应商主表
*/



-- 采购单行信息
SELECT pol.org_id                ou_id
      ,pol.po_header_id          采购单头id
      ,pol.po_line_id            行id
      ,pol.line_num              行号
      ,pol.item_id               物料id
      ,item.segment1             物料编码
      ,pol.item_description      物料说明
      ,pol.unit_meas_lookup_code 单位
      ,pol.unit_price            单价
      ,po_lct.quantity           订购数
      ,po_lct.quantity_received  验收数
      ,po_lct.quantity_accepted  接收数
      ,po_lct.quantity_rejected  拒绝数
      ,po_lct.quantity_cancelled 取消数
      ,po_lct.quantity_billed    到票数
      ,po_lct.promised_date      承诺日期
      ,po_lct.need_by_date       需求日期
  FROM po_lines_all          pol
      ,po_line_locations_all po_lct --发运表
      ,mtl_system_items      item
 WHERE pol.org_id = po_lct.org_id
   AND pol.po_line_id = po_lct.po_line_id
   AND pol.item_id = item.inventory_item_id
   AND item.organization_id = 142
   AND pol.org_id = 119
   AND pol.po_header_id = 10068;



-- 综合查询 1 ，所分配给供应处组织的物料，存在采购协议，但缺失采购员或缺失仓库；
SELECT msif.segment1         物料编码
      ,msif.description      物料描述
      ,msif.long_description 物料详细描述
      ,--MSIF.primary_unit_of_measure 计量单位 ,
       prf.last_name 采购员
      ,misd.subinventory_code 默认接收库存
      ,pla.unit_price 未税价
      ,round(pla.unit_price * (1 + zrb.percentage_rate / 100)
            ,2) 含税价
      ,pv.vendor_name 供应商名称
  FROM apps.po_headers_all        pha
      ,apps.po_lines_all          pla
      ,apps.mtl_system_items_fvl  msif
      ,apps.mtl_item_sub_defaults misd
      ,apps.per_people_f          prf
      ,apps.po_vendors            pv
      ,apps.po_vendor_sites_all   pvsa
      ,apps.zx_rates_b            zrb
 WHERE pha.type_lookup_code = 'BLANKET'
   AND pha.org_id = 119
   AND pha.po_header_id = pla.po_header_id
   AND pha.global_agreement_flag = 'Y'
   AND pha.approved_flag IN ('Y'
                            ,'R')
   AND nvl(pha.end_date
          ,SYSDATE) >= SYSDATE
   AND nvl(pla.expiration_date
          ,SYSDATE) >= SYSDATE
   AND pla.cancel_flag = 'N'
   AND pla.item_id = msif.inventory_item_id
   AND msif.organization_id = 142
   AND msif.inventory_item_id = misd.inventory_item_id(+)
   AND misd.organization_id(+) = 142
   AND misd.default_type(+) = 2
   AND msif.buyer_id = prf.person_id(+)
   AND prf.effective_end_date(+) =
       to_date('4712-12-31'
              ,'YYYY-MM-DD')
   AND pha.vendor_id = pv.vendor_id
   AND pha.vendor_site_id = pvsa.vendor_site_id
   AND pvsa.vat_code = zrb.tax_rate_code
   AND (misd.subinventory_code IS NULL OR prf.last_name IS NULL);

-- 采购其他相关表
  SELECT *
 FROM po_distributions_all 分配;

SELECT *
  FROM po_releases_all;
SELECT *
  FROM rcv_shipment_headers 采购接收头;
SELECT *
  FROM rcv_shipment_lines 采购接收行;
SELECT *
  FROM rcv_transactions 接收事务处理;
SELECT *
  FROM po_agents; --采购员
SELECT *
  FROM po_vendors;
SELECT *
  FROM po_vendor_sites_all;


---采购订单与采购申请关联--》通过 pr 和 po 的 distribution 表的 id 直接关联
select *
  from po_headers_all poh,
       
       po_distributions_all pod,
       
       po_req_distributions_all prod,
       
       po_line_locations_all poll,
       
       po_requisition_lines_all prl,
       
       po_requisition_headers_all prh

 WHERE prh.requisition_header_id = prl.requisition_header_id
      
   AND prod.requisition_line_id = prl.requisition_line_id
      
   AND prod.distribution_id = pod.req_distribution_id
      
   AND poll.line_location_id = pod.line_location_id
      
   AND poll.po_header_id = poh.po_header_id