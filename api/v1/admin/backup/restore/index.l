# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de restore-extract ()
  (sys "SSH_ORIGINAL_COMMAND" "backup")
  (if (call (pack *Admin_path "bin/wrapper.sh") "RESTORE")
      (and  (http-msg 200)
            (audit-log "web" "admin" "backup.restore" "backup-archive.tar.gz") )
      (http-msg 400 "Unable to extract backup archive") ]

[de restore-store (File)
  (call 'mv "-f" File (pack *Upload_path "backup-archive.tar.gz"))
  (restore-extract) ]

[de api-request-post ()
  (let (Data (get 'archive 'http)
        File (tmp Data) )
    (if (info File)
        (restore-store File)
        (http-msg 400) ]

(check-auth "POST")
