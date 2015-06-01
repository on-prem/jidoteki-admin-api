# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

[de validate-token (Token)
  (let Path (pack *Admin_path "etc/api.token")
    (when (and Token (num? (car (info Path))))
      (= Token (in Path (line T) ]

[de update-token (Token)
  (when Token
    (out (pack *Upload_path "api.token") (prinl Token))
    (call 'sudo (pack *Admin_path "bin/update_token.sh") ]
