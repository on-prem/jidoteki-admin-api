# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

(de build-exists ()
  (info "/usr/local/etc/build.json") )

[de build-get ()
  (if (build-exists)
      (response-json-nocache "/usr/local/etc/build.json" 200 T)
      (http-msg 404) ]

(de build-request ()
  (if (validate-auth)
      (if *Post
          (http-msg 400)
          (build-get) )
      (http-msg 403 "Authentication error") ) )

(build-request)
