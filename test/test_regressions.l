# Regression tests

# Server cannot start when JIDO_API_PORT env var is set - https://github.com/unscramble/jidoteki-admin-api/issues/12
[de test-gh-issue-12 ()
  (unit~assert-equal  49888
                      *JIDO_API_PORT # PORT should be converted to an integer
                      "Regression test GH issue #12 - Server cannot start when JIDO_API_PORT env var is set" ]

#  HMAC auth bypassed when no token is set - https://github.com/unscramble/jidoteki-admin-api/issues/17
[de test-gh-issue-17 ()
  (use *Admin_path *Url
    (setq *Admin_path "/tmp"
          *Url        "api/v1/admin/version/index.l" )

    # This would theoretically be the hash of an empty token + the *Url above
    (unit~assert-nil    (validate-hash "99256a631b6a3ecae8c503dfffab1e1c8fe91100f3dddb24a1f24f30907618da")
                        "Regression test GH issue #17 - HMAC auth bypassed when no token is set" ]

[unit~execute
  '(test-gh-issue-12)
  '(test-gh-issue-17) ]
