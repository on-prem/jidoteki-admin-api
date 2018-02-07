#!/usr/bin/env pil

(unless *Tc_functions_loaded
  (chdir (pack (if (sys "JIDO_ADMIN_PATH") @ "/opt/jidoteki/tinyadmin") "/lib")
    (load "tc-functions.l" ".modules/picolisp-unit/HEAD/unit.l") ) )

(sys "JIDO_API_PORT" "49888") # set the PORT as a string
(sys "JIDO_API_VERSION" "1") # set the API VERSION as a string

(chdir "api/v1/core"
  (load "api.l" "auth.l" "helpers.l") )

(load "api/v1/core/allowed.l")

(chdir "test/"
  (load "test_app.l" "test_core.l" "test_regressions.l") )

(report)
