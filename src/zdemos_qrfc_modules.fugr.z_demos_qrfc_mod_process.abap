FUNCTION Z_DEMOS_QRFC_MOD_PROCESS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DATA) TYPE  VTEXT OPTIONAL
*"  EXCEPTIONS
*"      ERROR_1
*"      ERROR_2
*"----------------------------------------------------------------------
* ----------- local data
  DATA: lv_rc TYPE i VALUE 0.
  DATA: lr_qrfc TYPE REF TO ZCL_DEMOS_QRFC_UTIL.


* ----------- init
  lr_qrfc ?= ZCL_DEMOS_QRFC_UTIL=>get_instance( ).


* ----------- process
  WAIT UP TO 1 SECONDS.


* ---------- error handling
  CASE lv_rc.
    WHEN 0.
      " OK
    WHEN 1.
      RAISE error_1.
    WHEN 2.
      RAISE error_2.
    WHEN OTHERS.
      lr_qrfc->set_status_retry_later( ).
  ENDCASE.


ENDFUNCTION.
