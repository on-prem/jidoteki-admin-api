#!/usr/bin/env pil

(load (pack (car (file)) ".modules/picolisp-unit/HEAD/unit.l"))
(if *CPU
  (and (load (pack (car (file)) ".modules/picolisp-json/HEAD/json.l")) (symbols 'json))
  (load "@lib/json.l") )

(chdir "test/"
  (load "test_app.l" "test_core.l") )

(when symbols (symbols 'unit))

(report)
