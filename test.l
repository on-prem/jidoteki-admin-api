#!/usr/bin/env pil

(when symbols (symbols 'unit 'pico))

(load (pack (car (file)) ".modules/picolisp-unit/HEAD/unit.l"))
(load (pack (car (file)) ".modules/picolisp-json/HEAD/json.l"))

(chdir "test/"
  (mapcar load (filter '((N) (sub? "test_" N)) (dir "."))) )

(report)