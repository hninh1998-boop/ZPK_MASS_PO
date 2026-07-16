@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons.View - Manage File PO Sub.Comp.'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_M_PO_SUBCOM
  provider contract transactional_query
  as projection on ZI_M_PO_SUBCOM
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
      _DataFile : redirected to composition child ZC_D_PO_SUBCOM,
      _OverallStatus
}
