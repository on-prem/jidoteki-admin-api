# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2019 Alexander Williams, Unscramble <license@unscramble.jp>

(load "@lib/http.l")

(allowed
  # default endpoints
  `(mapcar '((N) (pack *API_PATH "/admin/" N))
    '("setup"
      "update"
      "logs"
      "debug"
      "reboot"
      "services"
      "version"
      "changelog"
      "build"
      "health"
      "endpoints" ) )

  # default actions
  "index.html" "v" "newtoken" "token" "hash" "update" "settings" )

(allow "docs" T)

(when (info "/usr/local/etc/jidoteki-admin-api.json")
      (setq *Api_config (decode "/usr/local/etc/jidoteki-admin-api.json" T)) )

# optional api endpoints
(mapcar '((N) (allow (pack *API_PATH "/admin/" N) T)) (cddr (assoc "endpoints" *Api_config)))

# optional api parameters
(mapcar allow (cddr (assoc "parameters" *Api_config)))
