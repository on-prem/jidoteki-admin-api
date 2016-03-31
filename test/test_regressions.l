# Regression tests

# Server cannot start when JIDO_API_PORT env var is set - https://github.com/unscramble/jidoteki-admin-api/issues/12
[de test-gh-issue-12 ()
  (unit~assert-equal  49888
                      *JIDO_API_PORT # PORT should be converted to an integer
                      "Regression test GH issue #12 - Server cannot start when JIDO_API_PORT env var is set" ]

[unit~execute
  '(test-gh-issue-12)
  '(unit~assert-equal 1
                      *JIDO_API_VERSION
                      "Ensure JIDO_API_VERSION is an integer. Identical fix as #12")
]
