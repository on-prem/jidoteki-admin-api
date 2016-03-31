# Load the app files which will be tested

(sys "JIDO_API_PORT" "49888") # set the PORT as a string

(chdir "../api/v1/core"
  (load "allowed.l" "api.l" "auth.l" "helpers.l") )

(setq
  *Admin_path   (pack (pwd) "/admin/")
  *Upload_path  (pack *Admin_path "home/sftp/uploads/") )
