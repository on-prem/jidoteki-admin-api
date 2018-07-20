# Regression tests

# Server cannot start when JIDO_API_PORT env var is set - https://github.com/unscramble/jidoteki-admin-api/issues/12
[de test-gh-issue-12 ()
  (assert-equal  49888
                      *JIDO_API_PORT # PORT should be converted to an integer
                      "Regression test GH issue #12 - Server cannot start when JIDO_API_PORT env var is set" ]

#  HMAC auth bypassed when no token is set - https://github.com/unscramble/jidoteki-admin-api/issues/17
[de test-gh-issue-17 ()
  (use *Admin_path *Url
    (setq *Admin_path "/tmp"
          *Url        "api/v1/admin/version/index.l" )

    # This would theoretically be the hash of an empty token + the *Url above
    (assert-nil    (validate-hash "99256a631b6a3ecae8c503dfffab1e1c8fe91100f3dddb24a1f24f30907618da")
                        "Regression test GH issue #17 - HMAC auth bypassed when no token is set" ]

# Authenticated API endpoints are not carefully validated - jidoteki/issues/416
[de test-jidoteki-issue-416 (Testname)
  (use *Url *Post
    (setq *Url "api/v1/admin/settings/index.l")
    (on *Post)
    (put 'token 'http "testtoken")
    (put 'settings 'http "settings")

    (Testname) ]

[de test-jidoteki-issue-416-invalid ()
  (pipe
      # file must be copied into child (pipe)
      (when
        (call 'cp "-f" "settings-invalid.json" (tmp 'settings))
        (chdir ".."
          (load "api/v1/admin/settings/index.l" ) ) )

      (when
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
        T ]

[de test-jidoteki-issue-416-valid ()
  (pipe
      # file must be copied into child (pipe)
      (when
        (call 'cp "-f" "settings.json" (tmp 'settings))
        (chdir ".."
          (load "api/v1/admin/settings/index.l" ) ) )

      (when
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "2" " " "A" "c" "c" "e" "p" "t" "e" "d"))
        T ]

# Authenticated API endpoints return invalid responses - https://github.com/on-prem/jidoteki-admin-api/issues/38
[de test-gh-issue-38 (Testname)
  (use *Url *Post
    (off *Post)
    (put 'token 'http "testtoken")
    (Testname) ]

[de test-gh-issue-38-certs ()
  (setq *Url "api/v1/admin/certs/index.l")
  (pipe
    (chdir ".." (load "api/v1/admin/certs/index.l"))
    (and
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "0" " " "O" "K"))
      (until (eof) (line))
      (= @ '("{" "\"" "s" "t" "a" "t" "u" "s" "\"" ":" "n" "u" "l" "l" "," "\"" "l" "o" "g" "\"" ":" "n" "u" "l" "l" "}")) ]

[de test-gh-issue-38-settings ()
  (setq *Url "api/v1/admin/settings/index.l")
  (pipe
    (chdir ".." (load "api/v1/admin/settings/index.l"))
    (and
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "4" " " "N" "o" "t" " " "F" "o" "u" "n" "d"))
      (until (eof) (line))
      (= @ '("{" "\"" "S" "t" "a" "t" "u" "s" "\"" ":" "\"" "4" "0" "4" " " "N" "o" "t" " " "F" "o" "u" "n" "d" "\"" "}")) ]

[de test-gh-issue-38-storage ()
  (setq *Url "api/v1/admin/storage/index.l")
  (pipe
    (chdir ".." (load "api/v1/admin/storage/index.l"))
    (and
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "4" " " "N" "o" "t" " " "F" "o" "u" "n" "d"))
      (until (eof) (line))
      (= @ '("{" "\"" "S" "t" "a" "t" "u" "s" "\"" ":" "\"" "4" "0" "4" " " "N" "o" "t" " " "F" "o" "u" "n" "d" "\"" "}")) ]

[de test-gh-issue-38-update ()
  (setq *Url "api/v1/admin/update/index.l")
  (pipe
    (chdir ".." (load "api/v1/admin/update/index.l"))
    (and
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "0" " " "O" "K"))
      (until (eof) (line))
      (= @ '("{" "\"" "s" "t" "a" "t" "u" "s" "\"" ":" "n" "u" "l" "l" "," "\"" "l" "o" "g" "\"" ":" "n" "u" "l" "l" "}")) ]

[execute
  '(test-gh-issue-12)
  '(test-gh-issue-17)
  '(assert-t (test-jidoteki-issue-416 'test-jidoteki-issue-416-invalid) "Regression test (a) Jidoteki issue #416 - Authenticated API endpoint validation")
  '(assert-t (test-jidoteki-issue-416 'test-jidoteki-issue-416-valid) "Regression test (b) Jidoteki issue #416 - Authenticated API endpoint validation")
  '(assert-t (test-gh-issue-38 'test-gh-issue-38-certs) "Regression test GH issue #38 - Invalid response from GET /certs")
  '(assert-t (test-gh-issue-38 'test-gh-issue-38-settings) "Regression test GH issue #38 - Invalid response from GET /settings")
  '(assert-t (test-gh-issue-38 'test-gh-issue-38-storage) "Regression test GH issue #38 - Invalid response from GET /storage")
  '(assert-t (test-gh-issue-38 'test-gh-issue-38-update) "Regression test GH issue #38 - Invalid response from GET /update")
  ]
