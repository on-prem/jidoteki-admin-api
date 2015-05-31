# Load the app files which will be tested

(chdir "../api/v1/core"
  (load "allowed.l" "api.l" "auth.l" "helpers.l") )

(setq
  *Admin_path   (pack (pwd) "/admin/")
  *Upload_path  (pack *Admin_path "home/sftp/uploads/") )
