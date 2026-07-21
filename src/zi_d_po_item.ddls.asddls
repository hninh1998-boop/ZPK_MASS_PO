@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Int.View - Data Upload PO Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_d_po_item
  as select from ztb_d_po_item
  association [0..1] to zi_msg_sta_crud_poc_vh as _OverallStatus on $projection.Messagetype = _OverallStatus.Status
  association        to parent ZI_M_PO_ITEM    as _ManageFile    on $projection.Uuidfile = _ManageFile.Uuid
{
  key uuid                         as Uuid,
  key uuidfile                     as Uuidfile,

      messagetype                  as Messagetype,

      case messagetype
      when '' then 0
      when 'E' then 1
      when 'S' then 3
      else 0
      end                          as Criticality,

      message                      as Message,

      type                         as Type,
      purchase_order               as PurchaseOrder,
      purchase_order_item          as PurchaseOrderItem,
      account_assignment_category  as AccountAssignmentCategory,
      purchase_order_item_category as PurchaseOrderItemCategory,
      purchase_requisition         as PurchaseRequisition,
      purchase_requisition_item    as PurchaseRequisitionItem,
      material                     as Material,
      purchase_order_item_text     as PurchaseOrderItemText,
      material_group               as MaterialGroup,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      order_quantity               as OrderQuantity,
      purchase_order_quantity_unit as PurchaseOrderQuantityUnit,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      net_price_amount             as NetPriceAmount,
      document_currency            as DocumentCurrency,
      plant                        as Plant,
      storage_location             as StorageLocation,
      gl_account                   as GlAccount,
      order_id                     as OrderId,
      order_internal_id            as OrderInternalId,
      functional_area              as FunctionalArea,

      @Semantics.user.createdBy: true
      created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by              as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at        as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at              as LastChangedAt,

      //Association
      _OverallStatus,
      _ManageFile
}
