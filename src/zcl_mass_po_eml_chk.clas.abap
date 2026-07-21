CLASS zcl_mass_po_eml_chk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MASS_PO_EML_CHK IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " ---- Bước 0: Check trạng thái trước update ----
    READ ENTITY I_POSubcontractingCompTP_2
      FIELDS ( StorageLocation ProductionSupplyArea QuantityInEntryUnit EntryUnit
               WithdrawnQuantity ReservationIsFinallyIssued )
      WITH VALUE #( ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '16' RecordType = '' )
                    ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '12' RecordType = '' ) )
      RESULT DATA(lt_before).

    out->write( '=== TRẠNG THÁI TRƯỚC UPDATE ===' ).
    LOOP AT lt_before INTO DATA(ls_before).
      out->write( |ResvItem: { ls_before-reservationitem } | &&
                  |SLoc: { ls_before-storagelocation } PSA: { ls_before-productionsupplyarea } | &&
                  |Qty: { ls_before-quantityinentryunit } Unit: { ls_before-entryunit }| ).
    ENDLOOP.

    " ---- Bước 1: Update ĐỒNG THỜI StorageLocation/PSA + QuantityInEntryUnit/EntryUnit ----
    MODIFY ENTITIES OF I_PurchaseOrderTP_2
      ENTITY POSubcontractingComponent
        UPDATE FIELDS ( StorageLocation ProductionSupplyArea QuantityInEntryUnit EntryUnit )
        WITH VALUE #(
          ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '16' RecordType = ''
            StorageLocation = '2000' ProductionSupplyArea = ''
            QuantityInEntryUnit = '888' EntryUnit = 'KG'
            %control = VALUE #( StorageLocation      = cl_abap_behv=>flag_changed
                                ProductionSupplyArea = cl_abap_behv=>flag_changed
                                QuantityInEntryUnit  = cl_abap_behv=>flag_changed
                                EntryUnit            = cl_abap_behv=>flag_changed ) )
          ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '12' RecordType = ''
            StorageLocation = '1000' ProductionSupplyArea = ''
            QuantityInEntryUnit = '888' EntryUnit = 'KG'
            %control = VALUE #( StorageLocation      = cl_abap_behv=>flag_changed
                                ProductionSupplyArea = cl_abap_behv=>flag_changed
                                QuantityInEntryUnit  = cl_abap_behv=>flag_changed
                                EntryUnit            = cl_abap_behv=>flag_changed ) ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed-posubcontractingcomponent IS NOT INITIAL.
      out->write( '=== MODIFY FAILED ===' ).
      LOOP AT ls_failed-posubcontractingcomponent INTO DATA(ls_fail_line).
        out->write( |ResvItem: { ls_fail_line-reservationitem }| ).
      ENDLOOP.
    ELSE.
      out->write( 'MODIFY OK cho cả 2 dòng, chưa commit.' ).
    ENDIF.

    IF ls_reported-posubcontractingcomponent IS NOT INITIAL.
      out->write( '=== REPORTED (Early) ===' ).
      LOOP AT ls_reported-posubcontractingcomponent INTO DATA(ls_rep_line).
        out->write( |ResvItem: { ls_rep_line-reservationitem } Msg: { ls_rep_line-%msg->if_message~get_text( ) }| ).
      ENDLOOP.
    ENDIF.

    COMMIT ENTITIES
      RESPONSES
        FAILED   DATA(ls_commit_failed)
        REPORTED DATA(ls_commit_reported).

    IF ls_commit_failed IS NOT INITIAL.
      out->write( 'COMMIT FAILED.' ).
    ELSE.
      out->write( 'COMMIT OK.' ).
    ENDIF.

    IF ls_commit_reported IS NOT INITIAL.
      out->write( '=== REPORTED (Commit) ===' ).
      LOOP AT ls_commit_reported INTO DATA(ls_crep_line).
*        out->write( |Msg: { ls_crep_line-%msg->if_message~get_text( ) }| ).
      ENDLOOP.
    ENDIF.

    " ---- Bước 2: Đọc lại để so sánh ----
    READ ENTITY I_POSubcontractingCompTP_2
      FIELDS ( StorageLocation ProductionSupplyArea QuantityInEntryUnit EntryUnit
               WithdrawnQuantity ReservationIsFinallyIssued )
      WITH VALUE #( ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '16' RecordType = '' )
                    ( PurchaseOrder = '3400000092' PurchaseOrderItem = '10' ScheduleLine = '1' ReservationItem = '12' RecordType = '' ) )
      RESULT DATA(lt_after).

    out->write( '=== TRẠNG THÁI SAU UPDATE ===' ).
    LOOP AT lt_after INTO DATA(ls_after).
      out->write( |ResvItem: { ls_after-reservationitem } | &&
                  |SLoc: { ls_after-storagelocation } PSA: { ls_after-productionsupplyarea } | &&
                  |Qty: { ls_after-quantityinentryunit } Unit: { ls_after-entryunit }| ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
