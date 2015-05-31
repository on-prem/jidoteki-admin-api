(prinl "^J  Testing Core^J")

(de test-update-token ()
  (call 'rm "-f" (pack *Admin_path "etc/api.token"))
  (update-token "testtoken") )

# Only checks if the size of the file matches
(de test-json-file ()
  (use Info Size Date Body
    (json-file "settings.json")
    (when (= Size 276) T) ) )

# Only checks if the size of the string matches
(de test-json-string ()
  (use Size Date Body
    (json-string "{\"Status\":\"200 OK\"}")
    (when (= Size 19) T) ) )

[de test-response-json ()
  (pipe
    # (response-generic 200 19 NIL "{\"Status\":\"200 OK\"}" '(("Content-Type" . "application/json")))
    (response-json "{\"Status\":\"200 OK\"}")
    (when
      (and
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "0" " " "O" "K"))
        (= (line) '("S" "e" "r" "v" "e" "r" ":" " " "P" "i" "c" "o" "L" "i" "s" "p"))
        (line) # Skip the Date header
        (= (line) '("C" "o" "n" "t" "e" "n" "t" "-" "L" "e" "n" "g" "t" "h" ":" " " "1" "9"))
        (= (line) '("C" "o" "n" "t" "e" "n" "t" "-" "T" "y" "p" "e" ":" " " "a" "p" "p" "l" "i" "c" "a" "t" "i" "o" "n" "/" "j" "s" "o" "n")) )
      T ]

[unit~execute
  '(unit~assert-t      (validate-token "testtoken") "Ensure token gets validated")
  '(unit~assert-nil    (validate-token "badtoken") "Ensure invalid token doesn't get validated")
  '(unit~assert-t      (test-update-token) "Ensure token gets updated")
  '(unit~assert-equal  "OK" (http-code 200) "Ensure the HTTP message for 200 is 'OK'")
  '(unit~assert-equal  "{\"Status\":\"202 Accepted\"}" (http-msg 202) "Ensure the HTTP message for 202 is returned as JSON")
  '(unit~assert-t      (test-json-file) "Ensure JSON file is validated")
  '(unit~assert-t      (test-json-string) "Ensure JSON string is validated")
  '(unit~assert-t      (test-response-json) "Ensure a generic HTTP response is returned")
]
