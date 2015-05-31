#!/usr/bin/env pil

(load (pack (car (file)) ".modules/picolisp-unit/HEAD/unit.l"))
(load (pack (car (file)) ".modules/picolisp-json/HEAD/json.l"))

(chdir "test/"
  (load "test_app.l" "test_core.l") )

(unit~report)