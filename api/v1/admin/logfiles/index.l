# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de logfiles-response (Json)
  (encode
    (list
      (cons
        "logfiles"
        T
        (mapcar '((N)
                  (list
                    (cons "name"        (; N 1))
                    (cons "modified"    (; N 2))
                    (cons "size"        (; N 3)) ) )
                  Json ) )
      (cons "num" (length Json)) ]

# returns the list of all logfiles and their filesize and modified date
[de logfiles-list ()
  (make
    (let Dir (pack *Admin_path "log/")
      (when (=T (car (info Dir)))
        (chdir Dir
          (mapc '[(S)
                  (when (sub? ".log" S)
                    (let
                      (X      (chop S)
                       Info   (info S)
                       Size   (car Info)
                       Ts     (pack (datStr (cadr Info)) "T" (tim$ (cddr Info) T) "Z") )

                      (link (list S Ts Size)) ]
                (sort (dir)) ]

[de api-request-get ()
  (response-json (logfiles-response (logfiles-list))) ]

(check-auth "GET")
