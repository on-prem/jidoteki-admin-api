# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de services-process ()
  (sys "SSH_ORIGINAL_COMMAND" "services")
  (in (list (pack *Admin_path "bin/wrapper.sh")) (pack (till) ]

(de services-validate ()
  (if (services-process)
      (response-json @)
      (http-msg 404) ) )

(de services-request ()
  (if (validate-auth)
      (if *Post
          (http-msg 400)
          (services-validate) )
      (http-msg 403) ) )

(services-request)
