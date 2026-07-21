CLASS zcl_po_subcomp_implement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_data TYPE STANDARD TABLE OF ztb_d_po_subcom WITH EMPTY KEY.

    TYPES: BEGIN OF ty_item,
             PurchaseOrder            TYPE I_POSubcontractingCompTP_2-PurchaseOrder,
             PurchaseOrderItem        TYPE I_POSubcontractingCompTP_2-PurchaseOrderItem,
             ScheduleLine             TYPE I_POSubcontractingCompTP_2-ScheduleLine,
             RecordType               TYPE I_POSubcontractingCompTP_2-RecordType,
             BillOfMaterialItemNumber TYPE I_POSubcontractingCompTP_2-BillOfMaterialItemNumber,
           END OF ty_item,
           tt_item TYPE STANDARD TABLE OF ty_item.

    TYPES: BEGIN OF ty_max_item,
             purchaseorder     TYPE ty_item-purchaseorder,
             purchaseorderitem TYPE ty_item-purchaseorderitem,
             scheduleline      TYPE ty_item-scheduleline,
             max_item          TYPE ty_item-billofmaterialitemnumber,
           END OF ty_max_item.
    TYPES: tt_max_item TYPE STANDARD TABLE OF ty_max_item.

    TYPES: BEGIN OF ty_item_udt,
             PurchaseOrder            TYPE I_POSubcontractingCompTP_2-PurchaseOrder,
             PurchaseOrderItem        TYPE I_POSubcontractingCompTP_2-PurchaseOrderItem,
             ScheduleLine             TYPE I_POSubcontractingCompTP_2-ScheduleLine,
             RecordType               TYPE I_POSubcontractingCompTP_2-RecordType,
             BillOfMaterialItemNumber TYPE I_POSubcontractingCompTP_2-BillOfMaterialItemNumber,
             ReservationItem          TYPE I_POSubcontractingCompTP_2-ReservationItem,

             Material                 TYPE I_POSubcontractingCompTP_2-Material,
             QuantityInEntryUnit      TYPE I_POSubcontractingCompTP_2-QuantityInEntryUnit,
             EntryUnit                TYPE I_POSubcontractingCompTP_2-EntryUnit,
             Plant                    TYPE I_POSubcontractingCompTP_2-Plant,
             StorageLocation          TYPE I_POSubcontractingCompTP_2-StorageLocation,
           END OF ty_item_udt,
           tt_item_udt TYPE STANDARD TABLE OF ty_item_udt.

    TYPES: BEGIN OF ty_item_del,
             PurchaseOrder            TYPE I_POSubcontractingCompTP_2-PurchaseOrder,
             PurchaseOrderItem        TYPE I_POSubcontractingCompTP_2-PurchaseOrderItem,
             ScheduleLine             TYPE I_POSubcontractingCompTP_2-ScheduleLine,
             RecordType               TYPE I_POSubcontractingCompTP_2-RecordType,
             BillOfMaterialItemNumber TYPE I_POSubcontractingCompTP_2-BillOfMaterialItemNumber,
             ReservationItem          TYPE I_POSubcontractingCompTP_2-ReservationItem,
           END OF ty_item_del,
           tt_item_del TYPE STANDARD TABLE OF ty_item_del.

    CLASS-METHODS processing_api
      CHANGING
        ct_data TYPE tt_data.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS insert
      CHANGING
        cs_data     TYPE ztb_d_po_subcom
        ct_item     TYPE tt_item
        ct_max_item TYPE tt_max_item.

    CLASS-METHODS get_item
      IMPORTING
        it_data TYPE tt_data
      EXPORTING
        et_item TYPE tt_item.

    CLASS-METHODS get_max_item
      IMPORTING
        it_item     TYPE tt_item
      EXPORTING
        et_max_item TYPE tt_max_item.

    CLASS-METHODS update
      IMPORTING
        it_item_udt TYPE tt_item_udt
      CHANGING
        cs_data     TYPE ztb_d_po_subcom.

    CLASS-METHODS get_item_udt
      IMPORTING
        ct_data     TYPE tt_data
      EXPORTING
        et_item_udt TYPE tt_item_udt.

    CLASS-METHODS get_item_api_insert
      IMPORTING
        it_item     TYPE tt_item
        it_max_item TYPE tt_max_item
        is_data     TYPE ztb_d_po_subcom
      EXPORTING
        ev_bomitem  TYPE I_POSubcontractingCompTP_2-billofmaterialitemnumber.

    CLASS-METHODS call_api_insert
      IMPORTING
        iv_bomitem TYPE I_POSubcontractingCompTP_2-billofmaterialitemnumber
      EXPORTING
        ev_result  TYPE string
      CHANGING
        cs_data    TYPE ztb_d_po_subcom.

    CLASS-METHODS modify_itab_insert
      IMPORTING
        is_data     TYPE ztb_d_po_subcom
        iv_bomitem  TYPE I_POSubcontractingCompTP_2-billofmaterialitemnumber
        iv_result   TYPE string
      CHANGING
        ct_item     TYPE tt_item
        ct_max_item TYPE tt_max_item.

    CLASS-METHODS get_item_api_udt
      IMPORTING
        it_item_udt      TYPE tt_item_udt
        is_data          TYPE ztb_d_po_subcom
      EXPORTING
        et_item_udt_temp TYPE tt_item_udt.

    CLASS-METHODS call_api_udt
      IMPORTING
        it_item_udt_temp TYPE tt_item_udt
      CHANGING
        cs_data          TYPE ztb_d_po_subcom.

    CLASS-METHODS get_item_del
      IMPORTING
        it_data     TYPE tt_data
      EXPORTING
        et_item_del TYPE tt_item_del.

    CLASS-METHODS delete
      IMPORTING
        it_item_del TYPE tt_item_del
      CHANGING
        cs_data     TYPE ztb_d_po_subcom.
ENDCLASS.



CLASS zcl_po_subcomp_implement IMPLEMENTATION.


  METHOD processing_api.
    "Get bom item
    get_item( EXPORTING it_data = ct_data
              IMPORTING et_item = DATA(lt_item) ).

    "Get max bom item
    get_max_item( EXPORTING it_item     = lt_item
                  IMPORTING et_max_item = DATA(lt_max_item) ).

    "Get item update
    get_item_udt( EXPORTING ct_data     = ct_data
                  IMPORTING et_item_udt = DATA(lt_item_udt) ).

    "Get item delete
    get_item_del( EXPORTING it_data     = ct_data
                  IMPORTING et_item_del = DATA(lt_item_del) ).

    "Processing API
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CASE <lfs_data>-type.
        WHEN 'I'.
          insert( CHANGING cs_data     = <lfs_data>
                           ct_item     = lt_item
                           ct_max_item = lt_max_item ).
        WHEN 'M'.
          update( EXPORTING it_item_udt = lt_item_udt
                  CHANGING  cs_data     = <lfs_data> ).
        WHEN 'D'.
          delete( EXPORTING it_item_del = lt_item_del
                   CHANGING cs_data     = <lfs_data> ).
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.


  METHOD insert.
    "Get item api post
    get_item_api_insert( EXPORTING it_item     = ct_item
                                   it_max_item = ct_max_item
                                   is_data     = cs_data
                         IMPORTING ev_bomitem  = DATA(lv_bomitem) ).

    "call API
    call_api_insert( EXPORTING iv_bomitem = lv_bomitem
                     IMPORTING ev_result  = DATA(lv_result)
                      CHANGING cs_data    = cs_data ).

    "Chạy xong thì add data mới vào ct_item + ct_max_item
    modify_itab_insert( EXPORTING is_data     = cs_data
                                  iv_bomitem  = lv_bomitem
                                  iv_result   = lv_result
                         CHANGING ct_item     = ct_item
                                  ct_max_item = ct_max_item ).
  ENDMETHOD.


  METHOD get_item.
    CHECK it_data IS NOT INITIAL.

    SELECT FROM I_POSubcontractingCompTP_2 AS a
    FIELDS
        a~PurchaseOrder,
        a~PurchaseOrderItem,
        a~ScheduleLine,
        a~RecordType,
        a~BillOfMaterialItemNumber
    FOR ALL ENTRIES IN @it_data
    WHERE
        a~BillOfMaterialItemNumber <> '9999'
        AND a~PurchaseOrder = @it_data-purchase_order
        AND a~PurchaseOrderItem = @it_data-purchase_order_item
        AND a~ScheduleLine = @it_data-schedule_line
    INTO TABLE @et_item.
  ENDMETHOD.


  METHOD get_max_item.
    LOOP AT it_item INTO DATA(ls_item).
      READ TABLE et_max_item ASSIGNING FIELD-SYMBOL(<lfs_max_item>) WITH KEY purchaseorder     = ls_item-purchaseorder
                                                                             purchaseorderitem = ls_item-purchaseorderitem
                                                                             scheduleline      = ls_item-scheduleline.
      IF sy-subrc = 0.
        IF ls_item-billofmaterialitemnumber > <lfs_max_item>-max_item.
          <lfs_max_item>-max_item = ls_item-billofmaterialitemnumber.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO et_max_item ASSIGNING FIELD-SYMBOL(<lfs_new_item>).
        <lfs_new_item>-purchaseorder     = ls_item-purchaseorder.
        <lfs_new_item>-purchaseorderitem = ls_item-purchaseorderitem.
        <lfs_new_item>-scheduleline      = ls_item-scheduleline.
        <lfs_new_item>-max_item          = ls_item-billofmaterialitemnumber.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD update.
    "Prepare
    get_item_api_udt( EXPORTING it_item_udt      = it_item_udt
                                is_data          = cs_data
                      IMPORTING et_item_udt_temp = DATA(lt_item_udt_temp) ).

    "Call API
    call_api_udt( EXPORTING it_item_udt_temp = lt_item_udt_temp
                   CHANGING cs_data          = cs_data ).
  ENDMETHOD.


  METHOD get_item_udt.
    SELECT FROM I_POSubcontractingCompTP_2
    FIELDS
        PurchaseOrder,
        PurchaseOrderItem,
        ScheduleLine,
        RecordType,
        BillOfMaterialItemNumber,
        ReservationItem,
        material,
        QuantityInEntryUnit,
        EntryUnit,
        Plant,
        StorageLocation
    FOR ALL ENTRIES IN @ct_data
    WHERE
        PurchaseOrder = @ct_data-purchase_order
        AND PurchaseOrderItem = @ct_data-purchase_order_item
        AND ScheduleLine = @ct_data-schedule_line
        AND BillOfMaterialItemNumber = @ct_data-bill_of_material_item_number
    INTO TABLE @et_item_udt.
  ENDMETHOD.


  METHOD get_item_api_insert.
    READ TABLE it_item TRANSPORTING NO FIELDS WITH KEY PurchaseOrder            = is_data-purchase_order
                                                       purchaseorderitem        = is_data-purchase_order_item
                                                       scheduleline             = is_data-schedule_line
                                                       billofmaterialitemnumber = is_data-bill_of_material_item_number.
    IF sy-subrc = 0.
      READ TABLE it_max_item INTO DATA(ls_max_item) WITH KEY PurchaseOrder     = is_data-purchase_order
                                                             purchaseorderitem = is_data-purchase_order_item
                                                             scheduleline      = is_data-schedule_line.
      ev_bomitem = COND #( WHEN sy-subrc = 0 THEN ls_max_item-max_item + 10 ELSE 10 ).
    ELSE.
      ev_bomitem = is_data-bill_of_material_item_number.
    ENDIF.

    ev_bomitem = |{ ev_bomitem ALPHA = IN }|.
  ENDMETHOD.


  METHOD call_api_insert.
    DATA: lv_endpoint TYPE string,
          lv_body     TYPE string.

    DATA(lv_uom) = cs_data-entry_unit.

    SELECT SINGLE FROM I_UnitOfMeasure
    FIELDS UnitOfMeasure_E
    WHERE UnitOfMeasure = @lv_uom
    INTO @DATA(lv_uom_e).

    lv_endpoint =
       '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrderScheduleLine'
       && |/{ cs_data-purchase_order }|
       && |/{ cs_data-purchase_order_item }|
       && |/{ cs_data-schedule_line }|
       && |/_SubcontractingComponent|.
    lv_body =
        |\{|
        && |"PurchaseOrder": "{ cs_data-purchase_order }",|
        && |"PurchaseOrderItem": "{ cs_data-purchase_order_item }",|
        && |"ScheduleLine": "{ cs_data-schedule_line }",|
        && |"BillOfMaterialItemNumber": "{ iv_bomitem }",|
        && |"Material": "{ cs_data-material }",|
        && |"QuantityInEntryUnit": { cs_data-quantity_in_entry_unit },|
        && |"EntryUnit": "{ lv_uom_e }",|
        && |"Plant": "{ cs_data-plant }",|
        && |"StorageLocation": "{ cs_data-storage_location }"|
        && |\}|.
    DATA(lv_result) = zcl_call_api_po_subcomp=>main( iv_body     = lv_body
                                                     iv_endpoint = lv_endpoint
                                                     iv_method   = 'POST' ).
    IF zcl_call_api_po_subcomp=>code = 200
        OR zcl_call_api_po_subcomp=>code = 201
        OR zcl_call_api_po_subcomp=>code = 202
        OR zcl_call_api_po_subcomp=>code = 204.
      "Success
      cs_data-messagetype = 'S'.
      cs_data-message     = 'Success'.
    ELSE.
      cs_data-messagetype = 'E'.

      DATA: lv_msg  TYPE string,
            lv_code TYPE string.

      CLEAR: lv_msg, lv_code.

      " 1. Thử parse dạng "message":"..." (string trực tiếp)
      FIND REGEX '"message"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.

      " 2. Nếu không match, thử dạng "message":{"value":"..."}
      IF sy-subrc <> 0 OR lv_msg IS INITIAL.
        FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
      ENDIF.

      " 3. Lấy thêm error code nếu cần hiển thị
      FIND REGEX '"code"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_code.

      IF lv_msg IS NOT INITIAL.
        IF lv_code IS NOT INITIAL.
          cs_data-message = |[{ lv_code }] { lv_msg }|.
        ELSE.
          cs_data-message = lv_msg.
        ENDIF.
      ELSE.
        cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD modify_itab_insert.
    IF is_data-messagetype = 'S'.
      FIND REGEX '"RecordType"\s*:\s*"([^"]*)"' IN iv_result SUBMATCHES DATA(lv_recordtype).

      "Udt ct_item
      APPEND INITIAL LINE TO ct_item ASSIGNING FIELD-SYMBOL(<lfs_item_new>).
      <lfs_item_new>-purchaseorder            = is_data-purchase_order.
      <lfs_item_new>-purchaseorderitem        = is_data-purchase_order_item.
      <lfs_item_new>-scheduleline             = is_data-schedule_line.
      <lfs_item_new>-recordtype               = lv_recordtype.
      <lfs_item_new>-billofmaterialitemnumber = iv_bomitem.

      "Udt ct_max_item
      READ TABLE ct_max_item ASSIGNING FIELD-SYMBOL(<lfs_max_item>) WITH KEY PurchaseOrder     = is_data-purchase_order
                                                                             purchaseorderitem = is_data-purchase_order_item
                                                                             scheduleline      = is_data-schedule_line.
      IF sy-subrc = 0.
        <lfs_max_item>-max_item = iv_bomitem.
      ELSE.
        APPEND INITIAL LINE TO ct_max_item ASSIGNING FIELD-SYMBOL(<lfs_max_item_new>).
        <lfs_max_item_new>-purchaseorder     = is_data-purchase_order.
        <lfs_max_item_new>-purchaseorderitem = is_data-purchase_order_item.
        <lfs_max_item_new>-scheduleline      = is_data-schedule_line.
        <lfs_max_item_new>-max_item          = iv_bomitem.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_item_api_udt.
    et_item_udt_temp = it_item_udt.
    DELETE et_item_udt_temp WHERE purchaseorder               <> is_data-purchase_order
                                  OR purchaseorderitem        <> is_data-purchase_order_item
                                  OR scheduleline             <> is_data-schedule_line
                                  OR billofmaterialitemnumber <> is_data-bill_of_material_item_number.
  ENDMETHOD.


  METHOD call_api_udt.
    DATA: lv_endpoint TYPE string,
          lv_body     TYPE string.

    DATA(lv_uom) = cs_data-entry_unit.

    SELECT SINGLE FROM I_UnitOfMeasure
    FIELDS UnitOfMeasure_E
    WHERE UnitOfMeasure = @lv_uom
    INTO @DATA(lv_uom_e).


    LOOP AT it_item_udt_temp INTO DATA(ls_item_udt_temp).
      lv_endpoint =
         '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/POSubcontractingComponent'
         && |(PurchaseOrder='{ ls_item_udt_temp-purchaseorder }',|
         && |PurchaseOrderItem='{ ls_item_udt_temp-purchaseorderitem }',|
         && |ScheduleLine='{ ls_item_udt_temp-scheduleline }',|
         && |ReservationItem='{ ls_item_udt_temp-reservationitem }',|
         && |RecordType='')|.

      lv_body = |\{|.
      IF cs_data-material IS NOT INITIAL.
        lv_body = lv_body && |"Material": "{ cs_data-material }",|.
      ENDIF.
      IF cs_data-quantity_in_entry_unit IS NOT INITIAL.
        lv_body = lv_body && |"QuantityInEntryUnit": { cs_data-quantity_in_entry_unit },|.
      ENDIF.
      IF cs_data-entry_unit IS NOT INITIAL.
        lv_body = lv_body && |"EntryUnit": "{ lv_uom_e }",|.
      ENDIF.
      IF cs_data-plant IS NOT INITIAL.
        lv_body = lv_body && |"Plant": "{ cs_data-plant }",|.
      ENDIF.
      IF cs_data-storage_location IS NOT INITIAL.
        lv_body = lv_body && |"StorageLocation": "{ cs_data-storage_location }",|.
      ENDIF.
      IF lv_body CS ','.
        lv_body = substring( val = lv_body len = strlen( lv_body ) - 1 ).
      ENDIF.
      lv_body = lv_body && |\}|.

      DATA(lv_result) = zcl_call_api_po_subcomp=>main( iv_body     = lv_body
                                                       iv_endpoint = lv_endpoint
                                                       iv_method   = 'PATCH' ).
      IF zcl_call_api_po_subcomp=>code = 200
          OR zcl_call_api_po_subcomp=>code = 201
          OR zcl_call_api_po_subcomp=>code = 202
          OR zcl_call_api_po_subcomp=>code = 204.
        "Success
        cs_data-messagetype = 'S'.
        cs_data-message     = 'Success'.
      ELSE.
        cs_data-messagetype = 'E'.

        DATA: lv_msg  TYPE string,
              lv_code TYPE string.

        CLEAR: lv_msg, lv_code.

        " 1. Thử parse dạng "message":"..." (string trực tiếp)
        FIND REGEX '"message"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.

        " 2. Nếu không match, thử dạng "message":{"value":"..."}
        IF sy-subrc <> 0 OR lv_msg IS INITIAL.
          FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
        ENDIF.

        " 3. Lấy thêm error code nếu cần hiển thị
        FIND REGEX '"code"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_code.

        IF lv_msg IS NOT INITIAL.
          IF lv_code IS NOT INITIAL.
            cs_data-message = |[{ lv_code }] { lv_msg }|.
          ELSE.
            cs_data-message = lv_msg.
          ENDIF.
        ELSE.
          cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_item_del.
    SELECT FROM I_POSubcontractingCompTP_2
    FIELDS
        PurchaseOrder,
        PurchaseOrderItem,
        ScheduleLine,
        RecordType,
        BillOfMaterialItemNumber,
        ReservationItem
    FOR ALL ENTRIES IN @it_data
    WHERE
        PurchaseOrder = @it_data-purchase_order
        AND PurchaseOrderItem = @it_data-purchase_order_item
        AND ScheduleLine = @it_data-schedule_line
        AND BillOfMaterialItemNumber = @it_data-bill_of_material_item_number
    INTO TABLE @et_item_del.
  ENDMETHOD.


  METHOD delete.
    "Prepare
    DATA(lt_item_del_temp) = it_item_del.
    DELETE lt_item_del_temp WHERE purchaseorder               <> cs_data-purchase_order
                                  OR purchaseorderitem        <> cs_data-purchase_order_item
                                  OR scheduleline             <> cs_data-schedule_line
                                  OR billofmaterialitemnumber <> cs_data-bill_of_material_item_number.

    DATA: lv_endpoint TYPE string.

    LOOP AT lt_item_del_temp INTO DATA(ls_item_del_temp).
      lv_endpoint =
         '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/POSubcontractingComponent'
         && |(PurchaseOrder='{ ls_item_del_temp-purchaseorder }',|
         && |PurchaseOrderItem='{ ls_item_del_temp-purchaseorderitem }',|
         && |ScheduleLine='{ ls_item_del_temp-scheduleline }',|
         && |ReservationItem='{ ls_item_del_temp-reservationitem }',|
         && |RecordType='')|.

      DATA(lv_result) = zcl_call_api_po_subcomp=>main( iv_endpoint = lv_endpoint
                                                       iv_method   = 'DELETE' ).
      IF zcl_call_api_po_subcomp=>code = 200
          OR zcl_call_api_po_subcomp=>code = 201
          OR zcl_call_api_po_subcomp=>code = 202
          OR zcl_call_api_po_subcomp=>code = 204.
        "Success
        cs_data-messagetype = 'S'.
        cs_data-message     = 'Success'.
      ELSE.
        cs_data-messagetype = 'E'.

        DATA: lv_msg  TYPE string,
              lv_code TYPE string.

        CLEAR: lv_msg, lv_code.

        " 1. Thử parse dạng "message":"..." (string trực tiếp)
        FIND REGEX '"message"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.

        " 2. Nếu không match, thử dạng "message":{"value":"..."}
        IF sy-subrc <> 0 OR lv_msg IS INITIAL.
          FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
        ENDIF.

        " 3. Lấy thêm error code nếu cần hiển thị
        FIND REGEX '"code"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_code.

        IF lv_msg IS NOT INITIAL.
          IF lv_code IS NOT INITIAL.
            cs_data-message = |[{ lv_code }] { lv_msg }|.
          ELSE.
            cs_data-message = lv_msg.
          ENDIF.
        ELSE.
          cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
