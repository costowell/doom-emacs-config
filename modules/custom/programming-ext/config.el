;; Go Indents
(setq-hook! '(go-mode-hook go-ts-mode-hook)
  tab-width 4
  go-ts-mode-indent-offset 4
  evil-shift-width 4)
(setq-hook! '(c-mode-hook c-ts-mode-hook)
  tab-width 4
  c-ts-indent-offset 4
  evil-shift-width 4)
;; Protobuf Indents
(setq-hook! 'protobuf-mode-hook
  c-basic-offset 2
  tab-width 2
  evil-shift-width 2)

;; LSP Stuff
(setq read-process-output-max (* 1024 2024))
(setq lsp-idle-delay 0.025)

;; Protobuf LSP (buf)
(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(protobuf-mode . "protobuf"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("buf" "lsp" "serve"))
    :activation-fn (lsp-activate-on "protobuf")
    :server-id 'buf-lsp)))
(add-hook 'protobuf-mode-hook #'lsp-deferred)

;; Indents
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq tab-stop-list (number-sequence 4 200 4))
