# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

[de license-process ()
  (in (list (pack *Admin_path "bin/license.sh")) (pack (till T) ]

(de license-validate ()
  (if (license-process)
      (response-json @)
      (http-msg 404) ) )

(de license-update (File)
  (call 'mv "-f" File (pack *Upload_path "license.asc"))
  (sys "SSH_ORIGINAL_COMMAND" "license")
  (if (call (pack *Admin_path "bin/wrapper.sh"))
      (license-validate)
      (http-msg 400) ]

[de license-post ()
  (let (Data  (get 'license 'http)
        File  (tmp Data) )
    (if (and Data (info File))
        (license-update File)
        (http-msg 400) ]

(de license-get ()
  (license-validate) )

(de license-request ()
  (if (validate-auth)
      (if *Post
          (license-post)
          (license-get) )
      (http-msg 403) ) )

(license-request)
