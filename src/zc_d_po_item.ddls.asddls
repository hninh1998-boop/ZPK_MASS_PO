@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons.View - Data PO Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_d_po_item
  as projection on zi_d_po_item
{
  key Uuid,
  key Uuidfile,
      @ObjectModel.text.element: ['OverallStatusText']
      Messagetype,

      Criticality,

      Message,

      Type,
      PurchaseOrder,
      PurchaseOrderItem,
      AccountAssignmentCategory,
      PurchaseOrderItemCategory,
      PurchaseRequisition,
      PurchaseRequisitionItem,
      Material,
      PurchaseOrderItemText,
      MaterialGroup,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      OrderQuantity,
      PurchaseOrderQuantityUnit,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      NetPriceAmount,
      DocumentCurrency,
      Plant,
      StorageLocation,
      GlAccount,
      OrderId,
      OrderInternalId,
      FunctionalArea,

      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */

      _ManageFile : redirected to parent ZC_M_PO_ITEM,
      _OverallStatus
}
