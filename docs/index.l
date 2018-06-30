# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de default-request ()
  (use Info Size Date Body
    (json-file *API_DOC)
    (response-generic 200 Size Date Body '(("Content-Type" . "text/html") ]

(default-request)
