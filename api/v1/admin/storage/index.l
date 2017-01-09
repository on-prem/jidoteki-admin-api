# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de storage-update ()
  (unless (fork)
    (sys "SSH_ORIGINAL_COMMAND" (pack "storage"))
    (call (pack *Admin_path "bin/wrapper.sh")) )

  (use Size Date Body
    (json-string [encode (list (cons "Status" (pack 202 " " (http-code 202))) (cons "Location" "/api/v1/admin/storage")])
    (response-generic 202 Size Date Body '(("Location" . "/api/v1/admin/storage") ("Content-Type" . "application/json")) ]

[de storage-save (Settings)
  (out (pack *Upload_path "storage.json")
    (prinl (encode Settings)) )

  (out (pack *Upload_path "storage.conf")
    (mapcar '((N)
            (prinl (pack (car N) "=\"" (cdr N) "\"")))
            (cdr (assoc "storage" Settings)) ) )

  (storage-update) ]

[de storage-read (File)
  (if (decode File T)
      (storage-save @)
      (http-msg 400) ]

[de storage-post ()
  (let (Data (get 'settings 'http)
        File (tmp Data) )
    (if (info File)
        (storage-read File)
        (http-msg 400) ]

(de storage-get ()
  (response-json-nocache (pack *Admin_path "etc/storage.json") 200 T) ]

(de storage-request ()
  (if (validate-auth)
      (if *Post
          (storage-post)
          (storage-get) )
      (http-msg 403) ) )

(storage-request)
