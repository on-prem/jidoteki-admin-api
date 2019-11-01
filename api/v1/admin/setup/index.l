# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2019 Alexander Williams, Unscramble <license@unscramble.jp>

(de setup-update ()
  (if (get 'newtoken 'http)
      (ifn (update-token @)
          (http-msg 400)
          (out (pack *Admin_path "etc/api.token.setup") (prin))
          (http-msg 200)
          (audit-log "web" "admin" "token.update.success" (get-http-url)) )
      (http-msg 400) ) )

[de setup-new ()
  (let Path (pack *Admin_path "etc/api.token")
    (ifn (num? (car (info Path)))
         (setup-update)
         (audit-log "web" "admin" "token.setup.failed" (get-http-url))
         (wait 2000)
         (http-msg 403) ]

[de setup-request ()
  (when *Post
    (if (validate-auth)
        (setup-update)
        (setup-new) ]

(setup-request)
