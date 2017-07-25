# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de changelog-get ()
  (let Changelog (pack *Admin_path "etc/changelog.txt")
    (response-json-generic Changelog 200 T '(("Content-Type" . "text/plain") ("Cache-Control" . "no-cache"))) ]

(de changelog-request ()
  (if (validate-auth)
      (unless *Post (changelog-get))
      (http-msg 403) ) )

(changelog-request)
