# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de backup-get ()
  (if (info (pack *Upload_path "backup.tar.gz"))
      (httpEcho (pack *Upload_path "backup.tar.gz") "application/octet-stream" 1 T)
      (http-msg 404) ]

[de backup-action (Action)
  (unless (fork)
    (sys "SSH_ORIGINAL_COMMAND" "backup")
    # use (exec) because we DONT want the result
    (exec 'nohup (pack *Admin_path "bin/wrapper.sh") Action) )

  (use Size Date Body
    (json-string [encode (list (cons "Status" (pack 202 " " (http-code 202))) (cons "Location" "/api/v1/admin/backup/status")])
    (response-generic 202 Size Date Body '(("Location" . "/api/v1/admin/backup/status") ("Content-Type" . "application/json")))
    (audit-log "web" "admin" "backup.action" Action) ]

[de backup-post-action (Action)
  (if (or (= 'START Action) (= 'STOP Action))
      (backup-action Action)
      (http-msg 400 "Missing or invalid option: action. Expected value 'START' or 'STOP'") ]

[de backup-post ()
  (let Action (uppc (get 'action 'http))
    (backup-post-action Action) ]

[de backup-request ()
  (check-auth-request)
  (if *Post
      (backup-post)
      (backup-get) ]

(backup-request)
