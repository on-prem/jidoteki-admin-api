# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de log-get ()
  (use Log Info Size Date Body
    (setq Log  (pack *Admin_path "log/update.log"))
    (json-file Log)

    (response-generic 200 Size Date Body '(("Content-Type" . "text/plain") ]

(de log-request ()
  (if (validate-auth)
      (unless *Post (log-get))
      (http-msg 403) ) )

(log-request)
