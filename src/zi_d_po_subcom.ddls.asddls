@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Int.View - Data Upload PO Sub.Comp.'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_d_po_subcom
  as select from ztb_d_po_subcom
  association [0..1] to zi_msg_sta_mass_po_vh as _OverallStatus on $projection.Messagetype = _OverallStatus.Status
  association        to parent ZI_M_PO_SUBCOM as _ManageFile    on $projection.Uuidfile = _ManageFile.Uuid

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
      schedule_line                as ScheduleLine,
      bill_of_material_item_number as BillOfMaterialItemNumber,
      material                     as Material,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      quantity_in_entry_unit       as QuantityInEntryUnit,
      entry_unit                   as EntryUnit,
      plant                        as Plant,
      storage_location             as StorageLocation,

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
