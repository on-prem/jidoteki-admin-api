# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de get-sha256 (String)
  # works around output diff between openssl 0.9.8 and 1.0.x
  (pipe (out '(openssl dgst -sha256) (prin String))
        (pack (last (split (chop (line T)) " ") ]

[de get-hmac256 (String Key)
  (pipe (out (list 'openssl "dgst" "-sha256" "-hmac" Key) (prin String))
        (pack (last (split (chop (line T)) " ") ]

[de get-http-method ()
  (if *Post
      "POST"
      "GET" ]

# Chop the end of the requested URL
[de get-http-url ()
  (glue "/" (head -1 (mapcar pack (split (chop *Url) "/") ]

[de validate-hash (Hash)
  (let (Path      (pack *Admin_path "etc/api.token")
        Token     (when (num? (car (info Path))) (in Path (line T)))
        Tokenhash (get-sha256 Token)
        Hmac      (get-hmac256 (pack (get-http-method) "/" (get-http-url)) Tokenhash) )

    (= Hash Hmac) ]

[de validate-token (Token)
  (let Path (pack *Admin_path "etc/api.token")
    (when (and Token (num? (car (info Path))))
      (= Token (in Path (line T) ]

[de validate-auth ()
  (let (Hash  (get 'hash 'http)
        Token (get 'token 'http) )
    (if Hash
        (validate-hash Hash)
        (validate-token Token) ]

[de update-token (Token)
  (when Token
    (out (pack *Upload_path "api.token") (prinl Token))
    (sys "SSH_ORIGINAL_COMMAND" "token")
    (call (pack *Admin_path "bin/wrapper.sh") ]
