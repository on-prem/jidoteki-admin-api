# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de log-get ()
  (use Log Info Size Date Body
    (setq Log  (pack *Admin_path "log/update_backup.log"))
    (if (info Log)
        (json-file Log)
        (http-msg 404) )

    (response-generic 200 Size Date Body '(("Content-Type" . "text/plain") ]

(de log-request ()
  (check-auth-request "GET")
  (log-get) )

(log-request)
