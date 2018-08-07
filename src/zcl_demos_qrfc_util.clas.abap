CLASS zcl_demos_qrfc_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS build_queue_name
      IMPORTING
        !iv_prefix     TYPE any OPTIONAL
        !iv_name       TYPE any
        !iv_postfix    TYPE any OPTIONAL
      RETURNING
        VALUE(ev_name) TYPE trfcqnam .
    METHODS destroy .
    METHODS get_qin_size
      IMPORTING
        !iv_queue      TYPE any
      RETURNING
        VALUE(ev_size) TYPE i .
    METHODS get_qin_status
      IMPORTING
        !iv_queue        TYPE any
      RETURNING
        VALUE(ev_status) TYPE qrfcstate .
    TYPE-POOLS abap .
    METHODS get_qout_size
      IMPORTING
        !iv_queue      TYPE any
        !iv_dest       TYPE any DEFAULT '*'
      RETURNING
        VALUE(ev_size) TYPE abap_bool .
    METHODS get_qout_status
      IMPORTING
        !iv_queue        TYPE any
        !iv_dest         TYPE any DEFAULT '*'
      RETURNING
        VALUE(ev_status) TYPE qrfcstate .
    METHODS get_transaction_id
      RETURNING
        VALUE(ev_id) TYPE string .
    METHODS is_qin_exists
      IMPORTING
        !iv_queue        TYPE any
      RETURNING
        VALUE(ev_exists) TYPE abap_bool .
    METHODS is_qout_exists
      IMPORTING
        !iv_queue        TYPE any
        !iv_dest         TYPE any DEFAULT '*'
      RETURNING
        VALUE(ev_exists) TYPE abap_bool .
    METHODS set_qrfc_inbound
      IMPORTING
        !iv_queue             TYPE any
        !iv_start_transaction TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ev_success)     TYPE abap_bool .
    METHODS set_qrfc_outbound
      IMPORTING
        !iv_queue             TYPE any
        !iv_start_transaction TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ev_success)     TYPE abap_bool .
    METHODS set_queue
      IMPORTING
        !iv_inbound       TYPE abap_bool DEFAULT abap_false
        !iv_queue         TYPE any
          PREFERRED PARAMETER iv_inbound
      RETURNING
        VALUE(ev_success) TYPE abap_bool .
    METHODS set_status_retry_later
      RETURNING
        VALUE(ev_success) TYPE abap_bool .
    METHODS transaction_begin .
    METHODS transaction_cancel .
    METHODS transaction_end
      IMPORTING
        !iv_wait TYPE abap_bool DEFAULT abap_false .
    CLASS-METHODS get_instance
      IMPORTING
        !iv_context        TYPE any OPTIONAL
          PREFERRED PARAMETER iv_context
      RETURNING
        VALUE(er_instance) TYPE REF TO zcl_demos_qrfc_util .
    CLASS-METHODS reset_instance .
  PROTECTED SECTION.
*"* protected components of class ZCL_SD_UTIL_QRFC
*"* do not include other source files here!!!

    CLASS-DATA instance TYPE REF TO zcl_demos_qrfc_util .

    METHODS initialize .


  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_demos_qrfc_util IMPLEMENTATION.

  METHOD build_queue_name.

* ------ local data
    DATA: lv_temp TYPE string.

    DEFINE add_string.
      if &1 is not initial.
        lv_temp = &1.
        condense lv_temp.

        if ev_name is initial.
          ev_name = lv_temp.
        else.
          concatenate ev_name lv_temp into ev_name.
        endif.
      endif.
    END-OF-DEFINITION.

* ------ init
    CLEAR ev_name.

* ------ append string
    add_string iv_prefix.
    add_string iv_name.
    add_string iv_postfix.

  ENDMETHOD.


  METHOD destroy.

* ------ check if reguistered instance is myself
    IF instance = me.
      reset_instance( ).
    ENDIF.

* ------ reset variables, locks, ....

  ENDMETHOD.


  METHOD get_instance.

* ------ local data
    DATA lv_class TYPE seoclsname VALUE 'ZCL_DEMOS_QRFC_UTIL'.


* ------ check existing class
    IF  instance IS NOT INITIAL.
      er_instance ?= instance.
    ELSE.
* ------ future use: get class depending on iv_context and set lv_class
      "TODO

* ------ create object instance
      CREATE OBJECT er_instance TYPE (lv_class).
      er_instance->initialize( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_qin_size.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_GET_QIN_INFO'
      EXPORTING
        qname  = lv_queue
        client = sy-mandt
      IMPORTING
        qdeep  = ev_size.

  ENDMETHOD.


  METHOD get_qin_status.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lt_err    TYPE TABLE OF trfcqview.
    DATA: lt_all    TYPE TABLE OF trfcqin.
    DATA: ls_all    LIKE LINE OF lt_all.
    DATA: lv_size   TYPE i.



* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_QIN_GET_HANGING_QUEUES'
      EXPORTING
        qname     = lv_queue
        client    = sy-mandt
      TABLES
        err_queue = lt_err
        qtable    = lt_all.

    DESCRIBE TABLE lt_all LINES lv_size.
    CHECK lv_size EQ 1.

    READ TABLE lt_all INTO ls_all INDEX 1.
    ev_status = ls_all-qstate.

  ENDMETHOD.


  METHOD get_qout_size.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.


* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.


    CALL FUNCTION 'TRFC_GET_QUEUE_INFO'
      EXPORTING
        qname  = lv_queue
        dest   = lv_dest
        client = sy-mandt
*       DIST_GET_QUEUE       = ' '
*       QDTABNAME            = ' '
      IMPORTING
        qdeep  = ev_size.


  ENDMETHOD.


  METHOD get_qout_status.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.
    DATA: lt_err    TYPE TABLE OF trfcqview.
    DATA: lt_all    TYPE TABLE OF trfcqin.
    DATA: ls_all    LIKE LINE OF lt_all.
    DATA: lv_size   TYPE i.



* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.

    CALL FUNCTION 'TRFC_QOUT_GET_HANGING_QUEUES'
      EXPORTING
        qname     = lv_queue
        dest      = lv_dest
        client    = sy-mandt
      TABLES
        err_queue = lt_err
        qtable    = lt_all.

    DESCRIBE TABLE lt_all LINES lv_size.
    CHECK lv_size EQ 1.

    READ TABLE lt_all INTO ls_all INDEX 1.
    ev_status = ls_all-qstate.



  ENDMETHOD.


  METHOD get_transaction_id.

* ------ local data
    DATA: ls_tid TYPE arfctid.

    CALL FUNCTION 'ARFC_GET_TID'
      IMPORTING
        tid = ls_tid.
    .

    ev_id = ls_tid.

  ENDMETHOD.


  METHOD initialize.
  ENDMETHOD.


  METHOD is_qin_exists.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_size   TYPE i.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_GET_QIN_INFO'
      EXPORTING
        qname  = lv_queue
        client = sy-mandt
      IMPORTING
        qdeep  = lv_size.


    IF lv_size GT 0.
      ev_exists = abap_true.
    ELSE.
      ev_exists = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD is_qout_exists.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.
    DATA: lv_size   TYPE i.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.


    CALL FUNCTION 'TRFC_GET_QUEUE_INFO'
      EXPORTING
        qname  = lv_queue
        dest   = lv_dest
        client = sy-mandt
*       DIST_GET_QUEUE       = ' '
*       QDTABNAME            = ' '
      IMPORTING
        qdeep  = lv_size.


    IF lv_size GT 0.
      ev_exists = abap_true.
    ELSE.
      ev_exists = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD reset_instance.
    CLEAR instance.
  ENDMETHOD.


  METHOD set_qrfc_inbound.

* ------ start a new transaction
    IF iv_start_transaction EQ abap_true.
      me->transaction_begin( ).
    ENDIF.

* ------ set queue name
    CALL METHOD me->set_queue
      EXPORTING
        iv_inbound = abap_true
        iv_queue   = iv_queue
      RECEIVING
        ev_success = ev_success.

* ------ rollback transaction
    IF ev_success EQ abap_false
      AND iv_start_transaction EQ abap_true.
      me->transaction_cancel( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_qrfc_outbound.

* ------ start a new transaction
    IF iv_start_transaction EQ abap_true.
      me->transaction_begin( ).
    ENDIF.

* ------ set queue name
    CALL METHOD me->set_queue
      EXPORTING
        iv_inbound = abap_false
        iv_queue   = iv_queue
      RECEIVING
        ev_success = ev_success.

* ------ rollback transaction
    IF ev_success EQ abap_false
      AND iv_start_transaction EQ abap_true.
      me->transaction_cancel( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_queue.

* -------- local data
    DATA: lv_queue TYPE trfcqnam.


* -------- init
    ev_success = abap_false.
    CHECK iv_queue IS NOT INITIAL.

* -------- get string
    lv_queue = iv_queue.
    CHECK lv_queue IS NOT INITIAL.


* -------- set queue name
    IF iv_inbound EQ abap_true.
      CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
        EXPORTING
*         QOUT_NAME          = ' '
          qin_name           = lv_queue
*         QIN_COUNT          =
*         CALL_EVENT         = ' '
*         NO_EXECUTE         = ' '
        EXCEPTIONS
          invalid_queue_name = 1
          OTHERS             = 2.
      IF sy-subrc EQ 0.
        ev_success = abap_true.
      ENDIF.
    ELSE.
      CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
        EXPORTING
          qname              = lv_queue
*         NOSEND             = ' '
*         TRFC_IF_SYSFAIL    = ' '
*         CALL_EVENT         = ' '
        EXCEPTIONS
          invalid_queue_name = 1
          OTHERS             = 2.
      IF sy-subrc EQ 0.
        ev_success = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD set_status_retry_later.

* ------ local data
    DATA: lt_return TYPE TABLE OF  bapiret2.

* ------ set success
    ev_success = abap_true.

* ------ call api
    CALL FUNCTION 'TRFC_SEND_BACK'
      EXPORTING
        astate                  = 'ARETRY'
*       IF_FNAME                =
      TABLES
        arstate                 = lt_return
*       ARDATA01                =
*       ARDATA02                =
*       ARDATA03                =
*       ARDATA04                =
*       ARDATA05                =
      EXCEPTIONS
        no_trfc_or_qrfc_mode    = 1
        unknown_state           = 2
        missing_interface_fname = 3
        OTHERS                  = 4.
    IF sy-subrc <> 0.
      ev_success = abap_false.
    ELSE.
      LOOP AT lt_return TRANSPORTING NO FIELDS
        WHERE type CA 'EAX'.
        ev_success = abap_false.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD transaction_begin.
    SET UPDATE TASK LOCAL.
  ENDMETHOD.


  METHOD transaction_cancel.

    ROLLBACK WORK.

  ENDMETHOD.


  METHOD transaction_end.
    IF iv_wait EQ abap_true.
      COMMIT WORK AND WAIT.
    ELSE.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
