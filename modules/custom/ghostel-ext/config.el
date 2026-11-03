(after! ghostel
  (setq ghostel-shell "fish")
  (setq ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer))
  ;; Disable Alt+number keys to prevent workspace switching conflicts
  (dolist (num (number-sequence 0 9))
    (let ((key (kbd (format "M-%d" num))))
      (define-key ghostel-semi-char-mode-map key nil)
      (define-key ghostel-char-mode-map key nil)
      (define-key ghostel-line-mode-map key nil))))
