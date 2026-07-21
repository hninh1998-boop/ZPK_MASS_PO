CLASS lsc_ZI_M_PO_SUBCOM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_M_PO_SUBCOM IMPLEMENTATION.

  METHOD save_modified.
    " Kiểm tra có DataFile nào được update messagetype = 'J' không
    IF update-datafileposubcomp IS NOT INITIAL.

      " Tìm records có messagetype = 'J'
      LOOP AT update-datafileposubcomp ASSIGNING FIELD-SYMBOL(<upd>)
        WHERE messagetype = 'J'.

        DATA(lv_found) = abap_true.
        DATA(lv_uuidfile) = <upd>-uuidfile.
        EXIT.
      ENDLOOP.

      IF lv_found = abap_true.
        " ── Schedule Job ở đây — ngoài RAP LUW ──
        DATA(lv_job_text) = CONV cl_apj_rt_api=>ty_job_text( update-datafileposubcomp[ 1 ]-Message ).
        GET TIME STAMP FIELD DATA(ls_ts).

        TRY.
            cl_apj_rt_api=>schedule_job(
              EXPORTING
                iv_job_template_name   = 'ZJT_PO_SUBCOMP'
                iv_job_text            = lv_job_text
                is_start_info          = VALUE #(
                    timestamp = cl_abap_tstmp=>add( tstmp = ls_ts secs = 1 )
                )
                is_end_info            = VALUE #( type = 'NUM' max_iterations = 3 )
                is_scheduling_info     = VALUE #(
                  periodic_value = 1
                  test_mode      = abap_false
                  timezone       = 'CET'
                )
                it_job_parameter_value = VALUE #( (
                  name    = 'HDR_ID'
                  t_value = VALUE #( (
                    sign = 'I'  option = 'EQ'  low = lv_uuidfile
                  ) )
                ) )
              IMPORTING
                ev_jobname = DATA(lv_jobname)
            ).

          CATCH cx_apj_rt INTO DATA(lx_apj).
            APPEND VALUE #(
              uuid = <upd>-uuid
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = lx_apj->get_longtext( )
                     )
            ) TO reported-datafileposubcomp.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.









  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.




















CLASS lhc_ManageFilePOSubComp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
        inprocess TYPE c LENGTH 1 VALUE 'P', "In process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', "Success
      END OF file_status.

    TYPES: BEGIN OF ty_file_upload,
             Type                     TYPE string,
             PurchaseOrder            TYPE string,
             PurchaseOrderItem        TYPE string,
             ScheduleLine             TYPE string,
             BillOfMaterialItemNumber TYPE string,
             Material                 TYPE string,
             QuantityInEntryUnit      TYPE string,
             EntryUnit                TYPE string,
             Plant                    TYPE string,
             StorageLocation          TYPE string,
           END OF ty_file_upload.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ManageFilePOSubComp RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ManageFilePOSubComp.

    METHODS downloadFileSubComp FOR MODIFY
      IMPORTING keys FOR ACTION ManageFilePOSubComp~downloadFileSubComp RESULT result.

    METHODS downloadTemplateSubComp FOR MODIFY
      IMPORTING keys FOR ACTION ManageFilePOSubComp~downloadTemplateSubComp.

    METHODS uploadExcelSubComp FOR MODIFY
      IMPORTING keys FOR ACTION ManageFilePOSubComp~uploadExcelSubComp.

    METHODS setStatusToOpenSubComp FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ManageFilePOSubComp~setStatusToOpenSubComp.

    METHODS getExcelDataSubComp FOR DETERMINE ON SAVE
      IMPORTING keys FOR ManageFilePOSubComp~getExcelDataSubComp.

ENDCLASS.

CLASS lhc_ManageFilePOSubComp IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
               ASSIGNING FIELD-SYMBOL(<f_entities>)
               WHERE uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-managefileposubcomp.

    ENDLOOP.

    DATA(lt_file) = entities.

    DELETE lt_file WHERE uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft
          )
                 TO reported-managefileposubcomp.

          APPEND VALUE #( %cid      = <f_entities>-%cid
                          %key      = <f_entities>-%key
                          %is_draft = <f_entities>-%is_draft )
                 TO failed-managefileposubcomp.

          EXIT.
      ENDTRY.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
       TO mapped-managefileposubcomp.
    ENDLOOP.
  ENDMETHOD.













  METHOD downloadFileSubComp.
  ENDMETHOD.














  METHOD downloadTemplateSubComp.
  ENDMETHOD.









  METHOD uploadExcelSubComp.
    DATA lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_mn_file TYPE TABLE FOR CREATE zi_m_po_subcom,
          ls_mn_file LIKE LINE OF lt_mn_file,

          lt_file_c  TYPE TABLE FOR CREATE zi_m_po_subcom\_datafile,
          ls_file_c  LIKE LINE OF lt_file_c.

    DATA: lt_keys TYPE TABLE FOR READ IMPORT zi_m_po_subcom.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<k>) INDEX 1.

    CHECK sy-subrc = 0.

    IF <k>-%param-filecontent IS INITIAL.
      RETURN.
    ENDIF.

    ls_mn_file-attachment = <k>-%param-filecontent.
    ls_mn_file-filename   = <k>-%param-filename.
    ls_mn_file-mimetype   = <k>-%param-mimetype.

    FINAL(lv_filecontent) = <k>-%param-filecontent.
    "XCOライブラリを使用したExcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1. "Delete Line 1
      DELETE lt_file INDEX 1. "Delete Line 2
    ENDIF.

    DATA: lv_error TYPE abap_boolean VALUE IS INITIAL.

    "Validate...
    IF NOT lv_error = abap_true.
      ls_mn_file-Countline = lines( lt_file ).
      APPEND ls_mn_file TO lt_mn_file.
    ENDIF.

    IF lt_mn_file IS NOT INITIAL.
      MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
        ENTITY ManageFilePOSubComp
        CREATE AUTO FILL CID FIELDS (
                          status
                          attachment
                          mimetype
                          filename
                          countline
                          createdbyuser
                          createddate
                          changedbyuser
                          changeddate
                        ) WITH lt_mn_file
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
        FAILED DATA(lt_failed_create).
    ENDIF.
  ENDMETHOD.















  METHOD setStatusToOpenSubComp.
    READ ENTITIES OF zi_m_po_subcom IN LOCAL MODE
     ENTITY ManageFilePOSubComp
       FIELDS ( status )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_file).

    "If Status is already set, do nothing
    DELETE lt_file WHERE status IS NOT INITIAL.
    DELETE lt_file WHERE status = 'X'.

    CHECK lt_file IS NOT INITIAL.

    DATA lv_cnt1 TYPE i.
    DATA lv_cnt2 TYPE i.
    DATA lv_next TYPE i.

    " lấy max không cộng sẵn
    SELECT SINGLE MAX( zcount )
      FROM ztb_m_po_subcom
      WHERE createdbyuser = @sy-uname
      INTO @lv_cnt1.

    SELECT SINGLE MAX( zcount )
      FROM ztb_m_po_subcomd
      WHERE createdbyuser = @sy-uname
      INTO @lv_cnt2.

    lv_next = COND i( WHEN lv_cnt1 >= lv_cnt2 THEN lv_cnt1 + 1 ELSE lv_cnt2 + 1 ).

    MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY ManageFilePOSubComp
        UPDATE FIELDS ( status zcount )
        WITH VALUE #( FOR ls_file IN lt_file ( %tky   = ls_file-%tky
                                               status = file_status-open
                                               zcount = lv_next ) ).
  ENDMETHOD.















  METHOD getExcelDataSubComp.
    DATA: lt_file TYPE STANDARD TABLE OF ty_file_upload.

    DATA: lt_file_c TYPE TABLE FOR CREATE zi_m_po_subcom\\ManageFilePOSubComp\_datafile,
          ls_file_c LIKE LINE OF lt_file_c.

    " ── 1. Read parent instance ───────────────────────────────────
    READ ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY ManageFilePOSubComp
      ALL FIELDS WITH
      CORRESPONDING #( keys )
      RESULT FINAL(lt_record).

    IF lt_record IS INITIAL.
      RETURN.
    ENDIF.

    FINAL(lv_filecontent) = lt_record[ 1 ]-attachment.

    CHECK sy-subrc = 0.

    " ── 2. Parse Excel ────────────────────────────────────────────
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content(
                       iv_file_content = lv_filecontent
                     )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).
    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation(
      xco_cp_xlsx_read_access=>value_transformation->string_value
    )->if_xco_xlsx_ra_operation~execute( ).

    " Bỏ header row
    IF lt_file IS NOT INITIAL.
      DELETE lt_file INDEX 1.
      DELETE lt_file INDEX 1.
    ENDIF.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE lt_record ASSIGNING FIELD-SYMBOL(<f_file>) INDEX 1.

    " ── 3. Process data Raw ───────────────────────────────────────
    DATA: lt_data_file TYPE TABLE OF zi_d_po_subcom.

    LOOP AT lt_file INTO DATA(ls_file).
      APPEND INITIAL LINE TO lt_data_file ASSIGNING FIELD-SYMBOL(<lfs_data_file>).
      <lfs_data_file>-Type                     = ls_file-type.
      <lfs_data_file>-PurchaseOrder            = |{ ls_file-PurchaseOrder ALPHA = IN }|.
      <lfs_data_file>-PurchaseOrderItem        = |{ ls_file-PurchaseOrderItem ALPHA = IN }|.
      <lfs_data_file>-ScheduleLine             = |{ ls_file-ScheduleLine ALPHA = IN }|.
      <lfs_data_file>-BillOfMaterialItemNumber = |{ ls_file-BillOfMaterialItemNumber ALPHA = IN }|.
      IF ls_file-material IS NOT INITIAL.
        <lfs_data_file>-Material                 = COND #(
                                                      WHEN ls_file-material CO '0123456789'
                                                      THEN |{ ls_file-Material WIDTH = 18 ALIGN = RIGHT PAD = '0' }|
                                                      ELSE ls_file-material ).
      ENDIF.
      <lfs_data_file>-QuantityInEntryUnit      = ls_file-QuantityInEntryUnit.
      DATA(lv_uom_e) = CONV I_UnitOfMeasure-UnitOfMeasure_E( ls_file-EntryUnit ).

      SELECT SINGLE FROM I_UnitOfMeasure
      FIELDS UnitOfMeasure
      WHERE UnitOfMeasure_E = @lv_uom_e
      INTO @<lfs_data_file>-EntryUnit.

      <lfs_data_file>-Plant                    = |{ ls_file-Plant ALPHA = IN }|.
      <lfs_data_file>-StorageLocation          = |{ ls_file-storagelocation ALPHA = IN }|.
    ENDLOOP.

    " ── 4. Xóa duplicate trong file ──────────────────────────────
    DATA lt_seen TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    LOOP AT lt_data_file INTO DATA(ls_seen_dup).
      DATA(lv_key) =
        ls_seen_dup-type
        && ls_seen_dup-PurchaseOrder
        && ls_seen_dup-PurchaseOrderItem
        && ls_seen_dup-ScheduleLine
        && ls_seen_dup-BillOfMaterialItemNumber
        && ls_seen_dup-Material
        && ls_seen_dup-QuantityInEntryUnit
        && ls_seen_dup-EntryUnit
        && ls_seen_dup-Plant
        && ls_seen_dup-StorageLocation.

      INSERT lv_key INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        " Trùng → xóa khỏi table
        DELETE lt_data_file.
      ENDIF.
    ENDLOOP.

    IF lt_data_file IS INITIAL.
      RETURN.
    ENDIF.

    " ── 5. Build lt_file_c để create DataFile ────────────────────
    DATA lv_index TYPE i.

    LOOP AT lt_data_file INTO DATA(ls_data_file).
      lv_index = lv_index + 1.

      TRY.
          ls_file_c = VALUE #(
              %tky    = <f_file>-%tky
              %target = VALUE #( (
              %cid    = |CID_D_{ lv_index }|

              Type                     = ls_data_file-Type
              PurchaseOrder            = ls_data_file-PurchaseOrder
              PurchaseOrderItem        = ls_data_file-PurchaseOrderItem
              ScheduleLine             = ls_data_file-ScheduleLine
              BillOfMaterialItemNumber = ls_data_file-BillOfMaterialItemNumber
              Material                 = ls_data_file-Material
              QuantityInEntryUnit      = ls_data_file-QuantityInEntryUnit
              EntryUnit                = ls_data_file-EntryUnit
              Plant                    = ls_data_file-Plant
              StorageLocation          = ls_data_file-StorageLocation

              message     = ls_data_file-message
              messagetype = ls_data_file-messagetype
            ) )
          ).
        CATCH cx_abap_context_info_error.
          CONTINUE.
      ENDTRY.

      APPEND ls_file_c TO lt_file_c.
      CLEAR ls_file_c.
    ENDLOOP.

    IF lt_file_c IS INITIAL.
      RETURN.
    ENDIF.

    " ── 6. Create DataFile records ────────────────────────────────
    MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY ManageFilePOSubComp
      CREATE BY \_datafile
      FIELDS (
        Type
        PurchaseOrder
        PurchaseOrderItem
        ScheduleLine
        BillOfMaterialItemNumber
        Material
        QuantityInEntryUnit
        EntryUnit
        Plant
        StorageLocation

        message
        messagetype
      )
      WITH lt_file_c
      MAPPED   DATA(lt_mapped_create)
      REPORTED DATA(lt_mapped_reported)
      FAILED   DATA(lt_failed_create).
  ENDMETHOD.

ENDCLASS.


































CLASS lhc_DataFilePOSubComp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF file_status,
        open      TYPE c LENGTH 1 VALUE 'M', "Not process
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected  TYPE c LENGTH 1 VALUE 'X', "Rejected
        completed TYPE c LENGTH 1 VALUE 'D', "Done
        inprocess TYPE c LENGTH 1 VALUE 'P', "In Process
        error     TYPE c LENGTH 1 VALUE 'E', "Error
        success   TYPE c LENGTH 1 VALUE 'S', "Success
      END OF file_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR DataFilePOSubComp RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR DataFilePOSubComp RESULT result.

    METHODS PostConfirm FOR MODIFY
      IMPORTING keys FOR ACTION DataFilePOSubComp~PostConfirm RESULT result.

    METHODS setJob FOR MODIFY
      IMPORTING keys FOR ACTION DataFilePOSubComp~setJob RESULT result.

    METHODS setStatusToUpdate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DataFilePOSubComp~setStatusToUpdate.

ENDCLASS.

CLASS lhc_DataFilePOSubComp IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.











  METHOD get_global_authorizations.
  ENDMETHOD.








  METHOD PostConfirm.
    " ── 1. SELECT ────────────────────────────────────────────────
    SELECT * FROM ztb_d_po_subcom
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @keys
      WHERE uuid = @keys-uuid
        AND messagetype NE 'S'
      INTO TABLE @DATA(lt_data).

    IF lt_data IS INITIAL.
      RETURN.
    ENDIF.

    "── 2. Process API ─────────────────────────────────────────────────
    zcl_po_subcomp_implement=>processing_api( CHANGING ct_data = lt_data ).

    " ── 3. Update status ─────────────────────────────────────
    MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY DataFilePOSubComp
      UPDATE FIELDS ( messagetype message )
      WITH VALUE #( FOR ls_data IN lt_data (
        %tky-uuid     = ls_data-uuid
        %tky-uuidfile = ls_data-uuidfile
        messagetype   = ls_data-messagetype
        message       = ls_data-message
      ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    " ── 4. Update parent status ─────────────────────────────────────
    " Lấy UUIDFILE từ record đầu tiên (tất cả cùng 1 parent)
    DATA(lv_all_success) = abap_true.

    LOOP AT lt_data INTO DATA(ls_child).
      IF ls_child-messagetype <> 'S'.
        lv_all_success = abap_false.
      ENDIF.
    ENDLOOP.

    DATA(lv_new_status) = COND #(
      WHEN lv_all_success = abap_true
      THEN file_status-completed    " D = Done
      ELSE file_status-inprocess    " P = In process
    ).

    MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY ManageFilePOSubComp
      UPDATE FIELDS ( status )
      WITH VALUE #( (
        %tky-uuid = lt_data[ 1 ]-uuidfile
        %is_draft = if_abap_behv=>mk-off
        status    = lv_new_status
      ) )
      FAILED   DATA(lt_hdr_failed)
      REPORTED DATA(lt_hdr_reported).
  ENDMETHOD.











  METHOD setJob.
    GET TIME STAMP FIELD DATA(ls_ts).
    " Chỉ đánh dấu status = 'J' (Job pending)
    MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY DataFilePOSubComp
      UPDATE FIELDS ( messagetype message )
      WITH VALUE #( FOR key IN keys
        ( %tky        = key-%tky
          messagetype = 'J'
          message     = |PO SubComp Upload Mass { ls_ts }|
        )
      )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    " Update parent status
    READ ENTITIES OF zi_m_po_subcom IN LOCAL MODE
      ENTITY DataFilePOSubComp
      FIELDS ( Uuidfile )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    IF lt_data IS NOT INITIAL.
      MODIFY ENTITIES OF zi_m_po_subcom IN LOCAL MODE
        ENTITY ManageFilePOSubComp
        UPDATE FIELDS ( status )
        WITH VALUE #( (
          %tky-uuid = lt_data[ 1 ]-Uuidfile
          %is_draft = if_abap_behv=>mk-off
          status    = file_status-inprocess
        ) )
        FAILED   DATA(lt_hdr_failed)
        REPORTED DATA(lt_hdr_reported).
    ENDIF.
  ENDMETHOD.










  METHOD setStatusToUpdate.
  ENDMETHOD.

ENDCLASS.
