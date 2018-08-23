


    标签：
    OM DELIVERY

销售订单要经历登记、发放、挑库、交货四个主要环节，有些表在各个环节都有不同的特性，作者罗列了几个主要的常用的表，其它好象还有些货物路线、停靠之类的信息表则没有涉及。

下面是销售订单的四个主要环节和每个环节用到的常用表：

一、登记

1、oe_order_headers_all 　　--订单头信息表

 

2、oe_order_lines_all
--header_id=oe_order_headers_all.header_id
--订单行信息表

 

3、mtl_sales_orders
--segment1=oe_order_headers_all.order_number
--sales_order_id=mtl_material_transaction.transaction_source_id
--记录订单编号的信息表

 

4、wsh_delivery_details
--source_header_id=oe_order_headers_all.header_id
--source_line_id=oe_order_lines_all.line_id
--记录订单的物料的发运明细信息，该表的记录在此阶段状态（released_status）为R（Ready to release: 'R'means "ready to release"）

 

5、wsh_delivery_assignments
--delivery_detail_id=wsh_delivery_details.delivery_detail_id
--连接wsh_delivery_details和wsh_new_deliveries的信息表
--此阶段连接wsh_delivery_details

  

二、发放

1、wsh_delivery_details
--该表的记录在此阶段状态（released_status）为S（Released to Warehouse: 'S' means "submitted for release" ）

 

2、wsh_new_deliveries
--source_header_id=oe_order_headers_all.header_id
--记录订单的交货信息表，此阶段状态（status_code）为OP（Delivery is Open, has not been shipped）

 

3、wsh_delivery_assignments
--delivery_id=wsh_new_deliveries.delivery_id
--连接wsh_delivery_details和wsh_new_deliveries的信息表
--此阶段连接wsh_new_deliveries

 

4、wsh_picking_batches
--order_header_id=oe_order_headers_all.header_id
--记录订单的发放的信息表

 

三、挑库

1、wsh_delivery_details
--该表的记录在此阶段状态（released_status）为Y（Staged）。如果启用了序列号，记录会按单个序列号拆分

 

2、mtl_material_transactions
--transaction_source_id=mtl_sales_orders.sales_order_id
--trx_source_line_id=oe_order_lines_all.line_id
--记录“销售订单挑库”阶段物料的存放位置发生变化的信息

 

3、mtl_onhand_quantities
--记录物料的现有数量信息表

 

4、mtl_transaction_lot_numbers
--transaction_id=mtl_material_transactions.transaction_id
--lot_number=mtl_onhand_quantities.lot_number
--记录物料的存放位置发生变化的所产生的批次信息表

 

5、mtl_serial_numbers
--last_txn_source_id=mtl_material_transactions.transaction_source_id
--记录物料序列号的当前状态的信息表

  

四、交货

1、wsh_delivery_details
--该表的记录在此阶段状态（released_status）为C（Shipped）

 

2、wsh_new_deliveries
--该表的记录在此阶段状态（status_code）为CL（Delivery has arrived at the destination）

 

3、mtl_material_transactions
--记录“销售订单发放”阶段物料的存放位置发生变化的信息
--如果启用了序列号，记录会按单个序列号拆分

 

在后台完成workflow后，数据将导入RA的接口表
RA_INTERFACE_LINES_ALL
RA_INTERFACE_SALESCREDITS_ALL
当数据导入后，运行自动开票，数据将导入以下各表
RA_CUSTOMER_TRX
RA_CUSTOMER_TRX_LINES
AR_PAYMENT_SCHEDULES

 

(五)oracle OM在以下2层中支持开票进程
1.订单头层级的开票：即将整个订单数据倒入结果，或返还AR
2.订单行层级的开票：即将订单行中的数据倒入结果，或返还AR

 

(六)自动开票
Navigation: Interface-> Run Autoinvoice
Program : Autoinvoice Master Program

Interface Table: RA_INTERFACE_LINES_ALL
Error Table: RA_INTERFACE_ERRORS_ALL
Base Tables: RA_BATCHES_ALL
RA_CUSTOMER_TRX_ALL
RA_CUSTOMER_TRX_LINES_ALL

OE_ORDER_HEADERS_ALL.ORDER_NUMBER =RA_CUSTOMER_TRX_ALL.INTERFACE_HEADER_ATTRIBUTE1
下面所列举的是通过自动开票将OM中的相关引用传递到AR的字段

Number Name Column
1 Order Number INTERFACE_LINE_ATTRIBUTE1
2 Order Type INTERFACE_LINE_ATTRIBUTE2
3 Delivery INTERFACE_LINE_ATTRIBUTE3
4 Waybill INTERFACE_LINE_ATTRIBUTE4
5 Count INTERFACE_LINE_ATTRIBUTE5
6 Line ID INTERFACE_LINE_ATTRIBUTE6
7 Picking Line ID INTERFACE_LINE_ATTRIBUTE7
8 Bill of Lading INTERFACE_LINE_ATTRIBUTE8
9 Customer Item Part INTERFACE_LINE_ATTRIBUTE9
10 Warehouse INTERFACE_LINE_ATTRIBUTE10
11 Price Adjustment ID INTERFACE_LINE_ATTRIBUTE11
12 Shipment Number INTERFACE_LINE_ATTRIBUTE12
13 Option Number INTERFACE_LINE_ATTRIBUTE13
14 Service Number INTERFACE_LINE_ATTRIBUTE14

发票分组规则(Invoice Grouping Rules )
Menu: Navigation > Setup > Transactions > Autoinvoice > Grouping Rule
Autoinvoice uses grouping rules to group lines to create one transaction.

 

 

 

1 接口表：
a)OE_HEADERS_IFACE_ALL：此表为多组织表，用于将销售订单头插入开放接口。
该表存储来自于其他子系统需要导入OM模块的订单头信息，
该表导入时必须输入的字段/条件：
ORDER_SOURCE_ID : Order source id 可选
ORIG_SYS_DOCUMENT_REF: Original system document reference 必须
ORDER_SOURCE : Order source 可选
OPERATION_CODE : Operation code 必须
ORDER_TYPE_ID : Order type id 可选
ORDER_TYPE : Order type 可选
RETURN_REASON_CODE : Return reason code 仅用于订单退回
SALESREP_ID : Salesrep id
PRICE_LIST_ID : Price list id 用于已经booking的订单
PRICE_LIST : Price list 用于已经booking的订单
example:
insert into oe_headers_iface_all(
ORDER_SOURCE_ID
,orig_sys_document_ref
,ORG_ID
,order_type_id
,PRICE_LIST_ID
,TRANSACTIONAL_CURR_CODE
,SOLD_TO_ORG_ID
,SHIP_TO_ORG_ID
,created_by
,creation_date
,last_updated_by
,last_update_date
,operation_code
)select ooha.order_source_id
,ooha.orig_sys_document_ref
,ooha.org_id
,ooha.order_type_id
,ooha.price_list_id
,ooha.TRANSACTIONAL_CURR_CODE
,ooha.SOLD_TO_ORG_ID
,ooha.SHIP_TO_ORG_ID
,ooha.created_by
,ooha.creation_date
,fnd_global.user_id
,sysdate
,p_operation_code
from oe_order_headers_all ooha
where order_number=p_order_number;

 

b)OE_LINES_IFACE_ALL此表为多组织表，用于将销售订单行插入开放接口。
该表存储来自于其他子系统需要导入OM模块的订单行信息，
该表导入时必须输入的字段/条件：
ORDER_SOURCE_ID : Order source id 必须
ORIG_SYS_DOCUMENT_REF : Original system document reference 必须
ORIG_SYS_LINE_REF : Original system line reference 必须
ORIG_SYS_SHIPMENT_REF : Original system shipment reference 必须
INVENTORY_ITEM : Inventory Item 必须
INVENTORY_ITEM_ID : Inventory Item ID 可选
TOP_MODEL_LINE_REF : Top model line reference 可选
LINK_TO_LINE_REF : Link to line reference 可选
REQUEST_DATE : Request Date 必须
DELIVERY_LEAD_TIME : Delivery lead time 必须
DELIVERY_ID : Delivery id 必须
ORDERED_QUANTITY : Ordered quantity 必须
ORDER_QUANTITY_UOM : Order quantity uom 必须
SHIPPING_QUANTITY : Quantity which has been shipped by Shipping in Shipping UOM. 可选
SHIPPING_QUANTITY_UOM : The UOM for Shipping Quantity 可选
SHIPPED_QUANTITY : Shipped quantity 可选
CANCELLED_QUANTITY
FULFILLED_QUANTITY : The fulfilled quantity for the line可选
PRICING_QUANTITY : Pricing quantity 可选
PRICING_QUANTITY_UOM : Pricing quantity uom 可选
example：
insert into OE_LINES_IFACE_ALL
( ORDER_SOURCE_ID ,
ORIG_SYS_DOCUMENT_REF,
ORIG_SYS_LINE_REF ,
ORIG_SYS_SHIPMENT_REF ,
org_id ,
line_number
,line_type_id ,
item_type_code ,
INVENTORY_ITEM_ID ,
source_type_code ,
price_list_id ,
sold_to_org_id ,
sold_from_org_id ,
ship_to_org_id
,ship_from_org_id ,
operation_code ,
ORDERED_QUANTITY ,
ORDER_QUANTITY_UOM ,
CREATED_BY ,CREATION_DATE ,LAST_UPDATED_BY ,LAST_UPDATE_DATE ,LAST_UPDATE_LOGIN )
values
(l_line_tbl(j).order_source_id,
l_line_tbl(j).orig_sys_document_ref,
l_line_tbl(j).orig_sys_line_ref ,
l_line_tbl(j).orig_sys_shipment_ref
,l_line_tbl(j).org_id,
l_line_tbl(j).line_number,
l_line_tbl(j).line_type_id,
l_line_tbl(j).item_type_code,
p_new_item,
l_line_tbl(j).source_type_code ,
l_line_tbl(j).price_list_id,
l_line_tbl(j).sold_to_org_id,
l_line_tbl(j).sold_from_org_id,
l_line_tbl(j).ship_to_org_id,
l_line_tbl(j).ship_from_org_id ,
p_operation_code,
l_line_tbl(j).ordered_quantity ,
l_line_tbl(j).order_quantity_uom,
l_line_tbl(j).Created_By , l_line_tbl(j).creation_date ,fnd_global.USER_ID ,sysdate ,fnd_global.user_id
);

 

c)OE_PRICE_ADJS_IFACE_ALL
d)导入接口的API： OE_ORDER_PUB
常用过程：
(1)OE_ORDER_PUB.Process_Order:提供创建，修改，删除订单实体的操作，该方法通过记录集或者外部的请求，同样适用于对订单的其他操作，
(2)OE_ORDER_PUB.Get_Order :返回单个订单对象的所有记录
(3)OE_ORDER_PUB.Lock_Order :锁定订单对象.
可以使用get_order 来获取记录可以调用lock_order锁定该记录

 

e)记录error信息
OE_PROCESSING_MSGS
OE_PROCESSING_MSGS_TL
f)销售订单要经历登记、发放、挑库、交货四个主要环节，有些表在各个环节都有不同的特性，
几个主要的常用的表，其它好象还有些货物路线、停靠之类的信息表没有深究，就不列罗。
