# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

[de default-request ()
  (use Size Date Body
    (let (Pre (pack (in "docs/strapdown-prefix.html" (till (eof))))
          Suf (pack (in "docs/strapdown-suffix.html" (till (eof))))
          Doc (pack (in "docs/API.md" (till (eof)))) )

      (json-string (pack Pre "^J" Doc "^J" Suf))
      (response-generic 200 Size Date Body '(("Content-Type" . "text/html") ]
      # (response-generic 200 Size Date Body '(("Content-Type" . "text/plain; charset=UTF-8") ]
    # (prinl)

(default-request)
