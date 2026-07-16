@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons.View - Manage File PO Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_M_PO_ITEM
  provider contract transactional_query
  as projection on ZI_M_PO_ITEM
{
  key Uuid,
      Zcount,

      @ObjectModel.text.element: ['OverallStatusText']
      Status,

      Criticality,

      @EndUserText.label: 'Status'
      @Semantics.text: true
      _OverallStatus.description as OverallStatusText,

      @Semantics.largeObject: {
        mimeType: 'Mimetype',
        fileName: 'Filename',
        contentDispositionPreference: #ATTACHMENT
      }
      Attachment,
      @Semantics.mimeType: true
      Mimetype,
      Filename,
      Countline,
      Createdbyuser,
      Createddate,
      Changedbyuser,
      Changeddate,

      /* Associations */
      _DataFile : redirected to composition child zc_d_po_item,
      _OverallStatus
}
