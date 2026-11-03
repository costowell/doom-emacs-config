;; Go Indents
(setq-hook! '(go-mode-hook go-ts-mode-hook)
  tab-width 4
  go-ts-mode-indent-offset 4
  evil-shift-width 4)
(setq-hook! '(c-mode-hook c-ts-mode-hook)
  tab-width 4
  c-ts-indent-offset 4
  evil-shift-width 4)

;; LSP Stuff
(setq read-process-output-max (* 1024 2024))
(setq lsp-idle-delay 0.025)

;; Indents
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq tab-stop-list (number-sequence 4 200 4))
