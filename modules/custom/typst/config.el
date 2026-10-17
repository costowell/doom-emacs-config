;; Typst
;; Doom's indent-var autodetection looks for `typst-indent-offset', so
;; `typst-ts-indent-offset' (and thus tab-width) has to be set by hand.
(setq-hook! 'typst-ts-mode-hook
  typst-ts-indent-offset 2
  tab-width 2
  evil-shift-width 2)

(use-package! typst-ts-mode
  ;; Autoloads are disabled for this package (see packages.el), so the entry
  ;; points have to be declared here.
  :mode "\\.typ\\'"
  :commands (typst-ts-mode typst-ts-watch-mode typst-ts-mc-install-grammar)
  :init
  ;; There's no non-tree-sitter typst mode to fall back to, so this only
  ;; registers the grammar recipe. Install it with `M-x
  ;; treesit-install-language-grammar RET typst'. The repo is the typst-ts-mode
  ;; maintainer's fork (what the package itself installs); bump :commit to pick
  ;; up grammar fixes.
  (set-tree-sitter! nil 'typst-ts-mode
    '((typst :url "https://github.com/Ziqi-Yang/tree-sitter-typst"
       :rev "master"
       :commit "46cf4ded12ee974a70bf8457263b67ad7ee0379d")))
  ;; Fontify ```lang ... ``` raw blocks with that language's own grammar.
  (setq typst-ts-enable-raw-blocks-highlight t)
  :config
  ;; tinymist; lsp-mode already maps typst-ts-mode -> "typst" and autoloads
  ;; `lsp-typst', so no manual require is needed (unlike lsp-sml above).
  (add-hook 'typst-ts-mode-local-vars-hook #'lsp! 'append)

  ;; HACK: `typst-ts-compile-options'/`typst-ts-common-options' are lists now,
  ;;   but `typst-ts-set-compile-command' still interpolates them with %s, so
  ;;   `compile-command' (what `SPC c c' runs) ends up as "typst compile x.typ
  ;;   nil". `typst-ts-compile' builds its own command, so it isn't affected.
  ;; REVIEW: Drop this once upstream fixes that format string.
  (defadvice! +typst-ts-fix-compile-command-a (&rest _)
    :after #'typst-ts-set-compile-command
    (when-let* ((target (typst-ts-compile-get-target-file-argument)))
      (setq-local compile-command
                  (string-join (append (list typst-ts-compile-executable-location
                                             "compile"
                                             (shell-quote-argument target))
                                       typst-ts-common-options
                                       typst-ts-compile-options)
                               " "))))

  (map! :localleader
        :map typst-ts-mode-map
        "c" #'typst-ts-compile
        "C" #'typst-ts-compile-and-preview
        "p" #'typst-ts-preview
        "w" #'typst-ts-watch-mode
        "m" #'typst-ts-main-file-ask
        "o" #'typst-ts-mc-open-at-point
        "l" #'typst-ts-mc-insert-link
        "'" #'typst-ts-edit-indirect))

(after! lsp-mode
  ;; tinymist embeds typstyle, so format-on-save goes through the LSP formatter
  ;; (apheleia falls back to the typstyle binary when tinymist isn't running).
  (setq lsp-typst-formatter-mode "typstyle"
        lsp-typst-formatter-indent-size 2
        lsp-typst-formatter-print-width 100
        lsp-typst-lint-enabled t))
