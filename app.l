# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

# Jidoteki Admin API

(load "module.l")

# Load dependencies
(if *CPU
  (and (load ".modules/picolisp-json/HEAD/json.l") (symbols 'json))
  (load "@lib/json.l") )

(setq
  *API_VERSION  (if (sys "JIDO_API_VERSION") @ 1)
  *API_PATH     (pack "api/v" *API_VERSION)
  *Admin_path   (if (sys "JIDO_ADMIN_PATH") @ "/opt/jidoteki/admin/")
  *Upload_path  (pack *Admin_path "home/sftp/uploads/") )

# Load core
(chdir (pack *API_PATH "/core")
  (load "allowed.l" "api.l" "auth.l" "helpers.l") )

(api-start)

(wait)
