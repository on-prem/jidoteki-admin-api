# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

(de *Http_codes
  (200 . "OK")
  (202 . "Accepted")
  (400 . "Bad Request")
  (403 . "Forbidden")
  (404 . "Not Found") )

(de http-code (Code)
  (cdr (assoc Code *Http_codes)) )

(de http-msg (Code)
  (response-json [json~encode (list (cons "Status" (pack Code " " (http-code Code)] Code) )

[de json-file (Json)
  (setq Info (info Json)
        Size (car Info)
        Date '(httpDate (cadr Info) (cddr Info))
        Body (in Json (echo) ]

[de json-string (Json)
  (setq Size (length Json)
        Date '(httpDate (date T) (time T))
        Body '(prin Json) ]

[de response-json (Json Code Flg)
  (default Code 200)
  (use Info Size Date Body
    (if Flg
        (json-file Json)
        (json-string Json) )
    (ifn  Size
          (http-msg 404)
          (response-generic Code Size Date Body '(("Content-Type" . "application/json") ]

[de response-generic (Code Size Date Body Headers)
  (prinl "HTTP/1.1 " Code " " (http-code Code) "^M")
  (prinl "Server: PicoLisp^M")
  (prin "Date: ")
  (httpDate (date T) (time T))
  (when Size
    (prinl "Content-Length: " Size "^M") )
  (mapc '((N) (prinl (car N) ": " (cdr N) "^M")) Headers)
  (when Date
    (prin "Last-Modified: ")
    (eval Date)
    (prinl "^M") )
  (eval Body) ]

# Extensions for @lib/http.l
(undef 'http404)

(de http404 ()
  (http-msg 404) )
