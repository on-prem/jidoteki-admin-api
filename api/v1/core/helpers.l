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

[de http-error (Code Error)
  (response-json-generic
    (encode (list (cons "Status" (pack Code " " (http-code Code))) (cons "Error-Message" Error)))
    Code
    NIL
    (list (cons "Content-Type" "application/json") (cons "Error-Message" Error)) ]

(de http-msg (Code Error)
  (if Error
      (http-error Code Error)
      (response-json [encode (list (cons "Status" (pack Code " " (http-code Code)] Code) ) )

[de json-file (Json)
  (setq Info (info Json)
        Size (car Info)
        Date '(httpDate (cadr Info) (cddr Info))
        Body (pack (in Json (till (eof) ]

[de json-string (Json)
  (setq Size (length Json)
        Date '(httpDate (date T) (time T))
        Body Json ]

[de response-json-generic (Json Code Flg Headers)
  (default Code 200)
  (use Info Size Date Body
    (if Flg
        (json-file Json)
        (json-string Json) )
    (ifn  Size
          (http-msg 404)
          (response-generic Code Size Date Body Headers) ]

[de response-json (Json Code Flg)
  (response-json-generic Json Code Flg '(("Content-Type" . "application/json") ]

[de response-json-nocache (Json Code Flg)
  (response-json-generic Json Code Flg '(("Content-Type" . "application/json") ("Cache-Control" . "no-cache") ]

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
  (prin Body) ]

# Extensions for @lib/http.l
(undef 'http404)

(de http404 ()
  (http-msg 404) )

# Extensions for json.l (32-bit only)
[unless *CPU
  (de encode (Value)
    (pipe (printJson Value) (line T)) )

  (de decode (Value Type)
    (let Json
      (if Type
          (in Value (till NIL T))
          Value )
      (parseJson Json T) ]

# API endpoint helpers
(de log-plaintext (Filename)
  (use Log Info Size Date Body
    (setq Log  (pack *Admin_path "log/" Filename))
    (if (info Log)
        (json-file Log)
        (http-msg 404) )

    (response-generic 200 Size Date Body '(("Content-Type" . "text/plain") ]
