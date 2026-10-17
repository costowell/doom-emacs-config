(after! vterm
  ;; Default shell (emacs gets weird if my actual user's shell is non-bash)
  (setq shell-file-name "fish")
  ;; Disable Alt+number keys to prevent workspace switching conflicts
  (dolist (num (number-sequence 0 9))
    (let ((key (format "M-%d" num)))
      (define-key vterm-mode-map (kbd key) nil))))
