# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de logfiles-log (Filename)
  (in (pack *Admin_path "log/" Filename) (till NIL T) ]

# ensure the file is allowed
[de logfiles-log-validate (Filename Files)
  (member Filename Files) ]

[de logfiles-log-list ()
  (in *Log_paths (until (eof)
    (let Dir (line T)
      (when (=T (car (info Dir)))
        (dir Dir) ]

[de api-request-get ()
  (let Filename  (get 'filename 'http)
    (if (and Filename (logfiles-log-validate Filename (logfiles-log-list)))
        (response-json-generic (logfiles-log Filename) 200 NIL (list (cons "Content-Type" "text/plain") (cons "Content-Disposition" (pack "attachment; filename=" Filename)) (cons "Cache-Control" "no-cache")))
        (http-error 404 "Invalid or missing logfile") ]

(check-auth "GET")
