*&---------------------------------------------------------------------*
*& Report  zdemos_qrfc_test
*&
*&---------------------------------------------------------------------*
*& This is a demo program for use qRFC to create a large number of
*& processing packages in background.
*&---------------------------------------------------------------------*
REPORT zdemos_qrfc_test NO STANDARD PAGE HEADING.


* ------------ interface
PARAMETERS: p_dat TYPE vtext    DEFAULT 'Daten'.
PARAMETERS: p_cnt TYPE sydbcnt  DEFAULT 10.
PARAMETERS: p_nam TYPE trfcqnam DEFAULT 'ZQRFCDEMO' OBLIGATORY.
PARAMETERS: p_inb AS CHECKBOX   DEFAULT 'X'.

START-OF-SELECTION.

* ---------- protocol
"  INCLUDE zsd_ut_protocol.

* ---------- local data
  DATA: lr_qrfc TYPE REF TO zcl_demos_qrfc_util.
  DATA: lv_txn  TYPE string.


* ---------- init helper
  lr_qrfc ?= zcl_demos_qrfc_util=>get_instance( ).



* ---------- create x packages
  DO p_cnt TIMES.

* ---------- open a queue
    IF p_inb EQ 'X'.
      lr_qrfc->set_qrfc_inbound( p_nam ).
      lv_txn = 'SMQ2'.
    ELSE.
      lr_qrfc->set_qrfc_outbound( p_nam ).
      lv_txn = 'SMQ1'.
    ENDIF.

*  ---------- call update module
    CALL FUNCTION 'Z_DEMOS_QRFC_MOD_PROCESS'
      IN BACKGROUND TASK AS SEPARATE UNIT
      EXPORTING
        iv_data = p_dat.

*   finish luw
    lr_qrfc->transaction_end( ).

  ENDDO.


* ----------- finish
  WRITE: / 'Packages created:', p_cnt.
  WRITE: / 'Please check your Queue with transaction', lv_txn, 'qname', p_nam.
