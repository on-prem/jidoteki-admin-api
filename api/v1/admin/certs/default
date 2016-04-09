# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de certs-log (Lines)
  (in (list 'tail "-n" Lines (pack *Admin_path "log/update_certs.log")) (pack (replace (till (eof)) "^J" "\\n") ]

[de certs-process ()
  (let (Log     (certs-log 10))
    (list (append '("log") Log) ]

(de certs-get ()
  (response-json (encode (certs-process))) )

[de certs-update ()
  (unless (fork)
    (sys "SSH_ORIGINAL_COMMAND" "certs")
    # use (exec) because we DONT want the result
    (exec 'nohup (pack *Admin_path "bin/wrapper.sh")) )

  (use Size Date Body
    (json-string [encode (list (cons "Status" (pack 202 " " (http-code 202))) (cons "Location" "/api/v1/admin/certs")])
    (response-generic 202 Size Date Body '(("Location" . "/api/v1/admin/certs") ("Content-Type" . "application/json")) ]

(de certs-store (File Type)
  (let Filename
    (case Type
      ("public_key"   "appliance.pem")
      ("private_key"  "appliance.key")
      ("ca_key"       "ca.pem") )

    (if (info File)
        (call 'mv "-f" File (pack *Upload_path Filename))
        (http-msg 400) ]

[de certs-post ()
  (let (Public  (get 'public 'http)
        Private (get 'private 'http)
        Ca      (get 'ca 'http) )

    (if Public
        (certs-store (tmp Public) "public_key")
        (http-msg 400) )
    (if Private
        (certs-store (tmp Private) "private_key")
        (http-msg 400) )
    (when Ca (certs-store (tmp Ca) "ca_key"))

    (certs-update) ]

(de certs-request ()
  (if (validate-auth)
      (if *Post
          (certs-post)
          (certs-get) )
      (http-msg 403) ) )

(certs-request)
