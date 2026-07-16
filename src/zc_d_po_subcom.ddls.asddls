@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons.View - Data PO Sub.Comp.'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_D_PO_SUBCOM
  as projection on zi_d_po_subcom
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
      ScheduleLine,
      BillOfMaterialItemNumber,
      Material,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      Plant,
      StorageLocation,

      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */

      _ManageFile : redirected to parent ZC_M_PO_SUBCOM,
      _OverallStatus
}
