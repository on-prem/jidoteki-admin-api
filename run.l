#!/usr/bin/env pil

(catch 'InternalError
  (chdir (car (file))
    (load "app.l") ) )
