# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de download-get ()
  (if (info (pack *Upload_path "backup.tar.gz"))
      (httpEcho (pack *Upload_path "backup.tar.gz") "application/gzip" 1 T)
      (http-msg 404) ]

(de download-request ()
  (check-auth-request "GET")
  (download-get) )

(download-request)
