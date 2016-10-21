# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de update-log (Lines)
  (in (list 'tail "-n" Lines (pack *Admin_path "log/update.log")) (pack (replace (till (eof)) "^J" "\\n") ]

[de update-status ()
  (in (list 'cat (pack *Admin_path "etc/status_update.txt")) (pack (till "^J") ]

[de update-error-message ()
  (in (list 'cat (pack *Admin_path "etc/status_error_message.txt")) (pack (till "^J") ]

[de update-error-code ()
  (in (list 'cat (pack *Admin_path "etc/status_error_code.txt")) (pack (till "^J") ]

[de update-process ()
  (let (Log     (update-log 10)
        Status  (update-status)
        Message (when (info (pack *Admin_path "etc/status_error_message.txt")) (update-error-message))
        Code    (when (info (pack *Admin_path "etc/status_error_code.txt")) (update-error-code)) )

    (make (link (cons "status" Status)) (link (cons "log" Log)) (when Message (link (cons "error-message" Message))) (when Code (link (cons "error-code" Code) ]

(de update-get ()
  (response-json (encode (update-process))) )

[de update-vm ()
  (unless (fork)
    (sys "SSH_ORIGINAL_COMMAND" "update")
    # use (exec) because we DONT want the result
    (exec 'nohup (pack *Admin_path "bin/wrapper.sh")) )

  (use Size Date Body
    (json-string [encode (list (cons "Status" (pack 202 " " (http-code 202))) (cons "Location" "/api/v1/admin/update")])
    (response-generic 202 Size Date Body '(("Location" . "/api/v1/admin/update") ("Content-Type" . "application/json")) ]

(de update-store (File)
  (call 'mv "-f" File (pack *Upload_path "software_package-zzz.enc"))
  (update-vm) )

[de update-post ()
  (let (Data (get 'update 'http)
        File (tmp Data) )
    (if (info File)
        (update-store File)
        (http-msg 400) ]

(de update-request ()
  (if (validate-auth)
      (if *Post
          (update-post)
          (update-get) )
      (http-msg 403) ) )

(update-request)
