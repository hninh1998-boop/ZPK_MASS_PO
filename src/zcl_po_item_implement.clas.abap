CLASS zcl_po_item_implement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS processing_api
      CHANGING
        ct_data TYPE zcl_po_item_top=>tt_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS insert
      CHANGING
        cs_data TYPE ztb_d_po_item.

    CLASS-METHODS insert_api_po_item
      CHANGING
        cs_data TYPE ztb_d_po_item.

    CLASS-METHODS insert_api_acct
      CHANGING
        cs_data TYPE ztb_d_po_item.

    CLASS-METHODS update
      CHANGING
        cs_data TYPE ztb_d_po_item.

    CLASS-METHODS delete
      CHANGING
        cs_data TYPE ztb_d_po_item.

ENDCLASS.



CLASS zcl_po_item_implement IMPLEMENTATION.
  METHOD processing_api.
    "Prepare data

    "Processing API
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CASE <lfs_data>-type.
        WHEN 'I'. "Insert
          insert( CHANGING cs_data = <lfs_data> ).
        WHEN 'M'. "Update
          update( CHANGING cs_data = <lfs_data> ).
        WHEN 'D'. "Delete
          delete( CHANGING cs_data = <lfs_data> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.



















  METHOD insert.
    "Call API tạo PO Item
    insert_api_po_item( CHANGING cs_data = cs_data ).

    "Call API gán account assignment
    IF cs_data-order_id IS NOT INITIAL OR cs_data-order_internal_id IS NOT INITIAL
       OR cs_data-gl_account IS NOT INITIAL OR cs_data-functional_area IS NOT INITIAL.
      insert_api_acct( CHANGING cs_data = cs_data ).
    ENDIF.
  ENDMETHOD.

























  METHOD insert_api_po_item.
    DATA: lv_endpoint TYPE string,
          lv_body     TYPE string.

    lv_endpoint =
        '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrder'
        && |/{ cs_data-purchase_order }|
        && |/_PurchaseOrderItem|.

    IF cs_data-purchase_requisition IS NOT INITIAL AND cs_data-purchase_requisition_item IS NOT INITIAL.
      lv_body =
          |\{|
          && |"PurchaseOrder": "{ cs_data-purchase_order }",|
          && |"PurchaseOrderItem": "{ cs_data-purchase_order_item }",|
          && |"PurchaseRequisition": "{ cs_data-purchase_requisition }",|
          && |"PurchaseRequisitionItem": "{ cs_data-purchase_requisition_item }"|
          && |\}|.
    ELSE.
      lv_body =
          |\{|
          && |"PurchaseOrder": "{ cs_data-purchase_order }",|
          && |"PurchaseOrderItem": "{ cs_data-purchase_order_item }",|
          && |"AccountAssignmentCategory": "{ cs_data-account_assignment_category }",|
          && |"PurchaseOrderItemCategory": "{ cs_data-purchase_order_item_category }",|
          && |"PurchaseRequisition": "{ cs_data-purchase_requisition }",|
          && |"PurchaseRequisitionItem": "{ cs_data-purchase_requisition_item }",|
          && |"Material": "{ cs_data-material }",|
          && |"PurchaseOrderItemText": "{ cs_data-purchase_order_item_text }",|
          && |"MaterialGroup": "{ cs_data-material_group }",|
          && |"OrderQuantity": "{ cs_data-order_quantity }",|
          && |"PurchaseOrderQuantityUnit": "{ cs_data-purchase_order_quantity_unit }",|
          && |"Plant": "{ cs_data-plant }",|
          && |"StorageLocation": "{ cs_data-storage_location }"|
          && |\}|.
    ENDIF.

    DATA(lv_result) = zcl_call_api_po_item=>main( iv_body     = lv_body
                                                     iv_endpoint = lv_endpoint
                                                     iv_method   = 'POST' ).
    IF zcl_call_api_po_item=>code = 200
        OR zcl_call_api_po_item=>code = 201
        OR zcl_call_api_po_item=>code = 202
        OR zcl_call_api_po_item=>code = 204.
      "Success
      cs_data-messagetype = 'S'.
      cs_data-message     = 'Success'.
    ELSE.
      "Error — parse message từ response JSON
      cs_data-messagetype = 'E'.

      " Thử parse error message từ response
      " Response format: {"error":{"message":{"value":"..."}}}
      DATA(lv_msg) = ||.
      FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
      IF sy-subrc = 0 AND lv_msg IS NOT INITIAL.
        cs_data-message = lv_msg.
      ELSE.
        cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.






















  METHOD insert_api_acct.
    DATA: lv_endpoint TYPE string,
          lv_body     TYPE string.

    lv_endpoint =
        '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrderItem'
        && |/{ cs_data-purchase_order }|
        && |/{ cs_data-purchase_order_item }|
        && |/_PurOrdAccountAssignment|.

    lv_body =
        |\{|
        && |"PurchaseOrder": "{ cs_data-purchase_order }",|
        && |"PurchaseOrderItem": "{ cs_data-purchase_order_item }",|
        && |"GLAccount": "{ cs_data-gl_account }",|
        && |"OrderID": "{ cs_data-order_id }",|
        && |"OrderInternalID": "{ cs_data-order_internal_id }",|
        && |"FunctionalArea": "{ cs_data-functional_area }"|
        && |\}|.

    DATA(lv_result) = zcl_call_api_po_item=>main( iv_body     = lv_body
                                                     iv_endpoint = lv_endpoint
                                                     iv_method   = 'POST' ).
    IF zcl_call_api_po_item=>code = 200
        OR zcl_call_api_po_item=>code = 201
        OR zcl_call_api_po_item=>code = 202
        OR zcl_call_api_po_item=>code = 204.
      "Success
      cs_data-messagetype = 'S'.
      cs_data-message     = 'Success'.
    ELSE.
      "Error — parse message từ response JSON
      cs_data-messagetype = 'E'.

      " Thử parse error message từ response
      " Response format: {"error":{"message":{"value":"..."}}}
      DATA(lv_msg) = ||.
      FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
      IF sy-subrc = 0 AND lv_msg IS NOT INITIAL.
        cs_data-message = lv_msg.
      ELSE.
        cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.





















  METHOD update.
    DATA: lv_endpoint TYPE string,
          lv_body     TYPE string.

    lv_endpoint =
        '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrderItem'
        && |/{ cs_data-purchase_order }|
        && |/{ cs_data-purchase_order_item }|.

    lv_body = |\{|.

    IF cs_data-purchase_order IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseOrder": "{ cs_data-purchase_order }",|.
    ENDIF.

    IF cs_data-purchase_order_item IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseOrderItem": "{ cs_data-purchase_order_item }",|.
    ENDIF.

    IF cs_data-account_assignment_category IS NOT INITIAL.
      lv_body = lv_body && |"AccountAssignmentCategory": "{ cs_data-account_assignment_category }",|.
    ENDIF.

    IF cs_data-purchase_order_item_category IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseOrderItemCategory": "{ cs_data-purchase_order_item_category }",|.
    ENDIF.

    IF cs_data-purchase_requisition IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseRequisition": "{ cs_data-purchase_requisition }",|.
    ENDIF.

    IF cs_data-purchase_requisition_item IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseRequisitionItem": "{ cs_data-purchase_requisition_item }",|.
    ENDIF.

    IF cs_data-material IS NOT INITIAL.
      lv_body = lv_body && |"Material": "{ cs_data-material }",|.
    ENDIF.

    IF cs_data-purchase_order_item_text IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseOrderItemText": "{ cs_data-purchase_order_item_text }",|.
    ENDIF.

    IF cs_data-material_group IS NOT INITIAL.
      lv_body = lv_body && |"MaterialGroup": "{ cs_data-material_group }",|.
    ENDIF.

    IF cs_data-order_quantity IS NOT INITIAL.
      lv_body = lv_body && |"OrderQuantity": "{ cs_data-order_quantity }",|.
    ENDIF.

    IF cs_data-purchase_order_quantity_unit IS NOT INITIAL.
      lv_body = lv_body && |"PurchaseOrderQuantityUnit": "{ cs_data-purchase_order_quantity_unit }",|.
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

    DATA(lv_result) = zcl_call_api_po_item=>main( iv_body     = lv_body
                                                     iv_endpoint = lv_endpoint
                                                     iv_method   = 'PATCH' ).
    IF zcl_call_api_po_item=>code = 200
        OR zcl_call_api_po_item=>code = 201
        OR zcl_call_api_po_item=>code = 202
        OR zcl_call_api_po_item=>code = 204.
      "Success
      cs_data-messagetype = 'S'.
      cs_data-message     = 'Success'.
    ELSE.
      "Error — parse message từ response JSON
      cs_data-messagetype = 'E'.

      " Thử parse error message từ response
      " Response format: {"error":{"message":{"value":"..."}}}
      DATA(lv_msg) = ||.
      FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
      IF sy-subrc = 0 AND lv_msg IS NOT INITIAL.
        cs_data-message = lv_msg.
      ELSE.
        cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.

































  METHOD delete.
    DATA: lv_endpoint TYPE string.

    lv_endpoint =
        '/sap/opu/odata4/sap/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrderItem'
        && |/{ cs_data-purchase_order }|
        && |/{ cs_data-purchase_order_item }|.

    DATA(lv_result) = zcl_call_api_po_item=>main( iv_endpoint = lv_endpoint
                                                  iv_method   = 'DELETE' ).
    IF zcl_call_api_po_item=>code = 200
        OR zcl_call_api_po_item=>code = 201
        OR zcl_call_api_po_item=>code = 202
        OR zcl_call_api_po_item=>code = 204.
      "Success
      cs_data-messagetype = 'S'.
      cs_data-message     = 'Success'.
    ELSE.
      "Error — parse message từ response JSON
      cs_data-messagetype = 'E'.

      " Thử parse error message từ response
      " Response format: {"error":{"message":{"value":"..."}}}
      DATA(lv_msg) = ||.
      FIND REGEX '"value"\s*:\s*"([^"]*)"' IN lv_result SUBMATCHES lv_msg.
      IF sy-subrc = 0 AND lv_msg IS NOT INITIAL.
        cs_data-message = lv_msg.
      ELSE.
        cs_data-message = |API Error HTTP { zcl_call_api_po_subcomp=>code }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
