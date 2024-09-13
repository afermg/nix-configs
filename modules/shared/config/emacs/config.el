(setq user-full-name "Alán F. Muñoz"
  user-mail-address "afer.mg@gmail.com")

(setq config-files-by-priority (list org-config-file default-config-file default-config-url))

  (defun find-config-dir (config-files) (car (seq-remove (lambda (x) (not (or (file-exists-p x) (url-file-exists-p x)))) config-files)))
(setq config-dir (file-name-directory (find-config-dir config-files-by-priority)))

;; Turn off the splash screenu
(setq inhibit-startup-screen t)
;; Turn off the splash screen
(setq initial-scratch-message nil)

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))
(unless (assoc-default "nongnu" package-archives)
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t))

(use-package transient)
(use-package magit :after (transient))

(defun system-is-mac ()
  "Return true if system is darwin-based (Mac OS X)"
  (string-equal system-type "darwin"))

(defun system-is-linux ()
  "Return true if system is GNU/Linux-based"
  (string-equal system-type "gnu/linux"))

;; Set path for darwin
(when (system-is-mac)
  (setenv "PATH" (concat (getenv "PATH") ":~/.nix-profile/bin:/usr/bin"))
  (setq exec-path (append '("~/bin" "~/.nix-profile/bin" "/nix/var/nix/profiles/default/bin" "/usr/local/bin" "/usr/bin") exec-path)))

(defun dl/org-mode-visual-fill ()
  (setq visual-fill-column-width 110
      visual-fill-column-center-text t))

(use-package visual-fill-column
  :defer t
  :hook (org-mode . dl/org-mode-visual-fill))

(add-hook 'server-switch-hook #'raise-frame)

(defalias 'yes-or-no-p 'y-or-n-p) ;; Use Y or N in prompts, instead of full Yes or No

(global-visual-line-mode t) ;; Wraps lines everywhere
(global-auto-revert-mode t) ;; Auto refresh buffers from disk
(line-number-mode t) ;; Line numbers in the gutter
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(electric-pair-mode 1)
(show-paren-mode t) ;; Highlights parens

;; The built-in `recentf-mode' keeps track of recently visited files.
;; You can then access those through the `consult-buffer' interface or
;; with `recentf-open'/`recentf-open-files'.
;;
;; I do not use this facility, because the files I care about are
;; either in projects or are bookmarked.
(recentf-mode 1)

(setq warning-minimum-level :error)

;; ESC will also cancel/quit/etc.
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Rotates windows and layouts
 (use-package rotate
)

(defun kill-current-buffer ()
  (interactive)
  ;; kill-buffer does not always work
  (kill-buffer (current-buffer))
  )

(global-set-key (kbd "<C-tab>") 'next-buffer)
(global-set-key (kbd "C-x k") 'kill-current-buffer)
(global-set-key (kbd "C-x K") 'kill-buffer)

(unless window-system
    (xterm-mouse-mode 1))

; TODO Check if this is actually working
  (use-package clipetty
    :config
    (clipetty-mode))

(use-package meow
  :config
  (defun meow-setup ()
   ;; -------------------- ;;
   ;;         UTILS        ;;
   ;; -------------------- ;;
   (defun meow-word ()
     "Expand word/symbol under cursor."
     (interactive)
     (if (and (use-region-p)
              (equal (car (region-bounds))
                     (bounds-of-thing-at-point 'word)))
         (meow-mark-symbol 1)
       (progn
         (when (and (mark)
                    (equal (car (region-bounds))
                           (bounds-of-thing-at-point 'symbol)))
           (meow-pop-selection))
         (meow-mark-word 1))))

   (defun meow-kill-line ()
     "Kill till the end of line."
     (interactive)
     (let ((select-enable-clipboard meow-use-clipboard))
       (kill-line)))

   (defun meow-change-line ()
     "Kill till end of line and switch to INSERT state."
     (interactive)
     (meow--cancel-selection)
     (meow-end-of-thing
      (car (rassoc 'line meow-char-thing-table)))
     (meow-change))

   (defun meow-save-clipboard ()
     "Copy in clipboard."
     (interactive)
     (let ((meow-use-clipboard t))
       (meow-save)))

   (defvar meow--trim-yank nil)

   (defun meow-insert-for-yank-advice (orig-fn str)
     "Advice for `insert-for-yank' function to correctly insert lines."
     (when meow--trim-yank
       (set 'str (string-trim-right str "\n")))
     (if (and (not (eq (point) (+ 1 (line-end-position 0))))
              (string-match-p "^.+\n$" str))
         (save-excursion
           (beginning-of-line)
           (funcall orig-fn str))
       (funcall orig-fn str)))

   (defun meow-yank-dwim ()
     "Smart yank."
     (interactive)
     (advice-add 'insert-for-yank :around 'meow-insert-for-yank-advice)
     (if (use-region-p)
         (let ((meow--trim-yank t))
           (delete-region (region-beginning) (region-end))
           (meow-yank))
       (meow-yank))
     (advice-remove 'insert-for-yank 'meow-insert-for-yank-advice))

   (defun meow-yank-pop-dwim ()
     "Smart yank pop."
     (interactive)
     (advice-add 'insert-for-yank :around 'meow-insert-for-yank-advice)
     (if (use-region-p)
         (let ((meow--trim-yank t))
           (delete-region (region-beginning) (region-end))
           (meow-yank-pop))
       (meow-yank-pop))
     (advice-remove 'insert-for-yank 'meow-insert-for-yank-advice))

   (defun meow-smart-reverse ()
     "Reverse selection or begin negative argument."
     (interactive)
     (if (use-region-p)
         (meow-reverse)
       (negative-argument nil)))

   (defun meow-kmacro ()
     "Toggle recording of kmacro."
     (interactive)
     (if defining-kbd-macro
         (meow-end-kmacro)
       (meow-start-kmacro)))

   (defun meow-eldoc ()
     "Toggle the display of the eldoc window."
     (interactive)
     (if (get-buffer-window eldoc--doc-buffer)
         (delete-window (get-buffer-window eldoc--doc-buffer))
       (eldoc-doc-buffer t)))

   ;; -------------------- ;;
   ;;       VARIABLES      ;;
   ;; -------------------- ;;
   (meow-thing-register 'angle
                        '(pair ("<") (">"))
                        '(pair ("<") (">")))

   (setq meow-char-thing-table
         '((?f . round)
           (?d . square)
           (?s . curly)
           (?a . angle)
           (?r . string)
           (?v . paragraph)
           (?c . line)
           (?x . buffer)))

   (setq meow-selection-command-fallback
         '((meow-change . meow-change-char)
           (meow-kill . meow-delete)
           (meow-cancel-selection . keyboard-quit)
           (meow-pop-selection . meow-pop-grab)
           (meow-beacon-change . meow-beacon-change-char)))

   ;; -------------------- ;;
   ;;       MAPPINGS       ;;
   ;; -------------------- ;;
   (meow-define-keys 'normal
    ; expansion
    '("0" . meow-expand-0)
    '("1" . meow-expand-1)
    '("2" . meow-expand-2)
    '("3" . meow-expand-3)
    '("4" . meow-expand-4)
    '("5" . meow-expand-5)
    '("6" . meow-expand-6)
    '("7" . meow-expand-7)
    '("8" . meow-expand-8)
    '("9" . meow-expand-9)
    '("'" . meow-smart-reverse)

    ; movement
    '("i" . meow-prev)
    '("k" . meow-next)
    '("j" . meow-left)
    '("l" . meow-right)

    '("y" . meow-search)
    ;; '("/" . meow-visit)
    '("/" . consult-line)

    ; expansion
    '("I" . meow-prev-expand)
    '("K" . meow-next-expand)
    '("J" . meow-left-expand)
    '("L" . meow-right-expand)

    '("u" . meow-back-word)
    '("U" . meow-back-symbol)
    '("o" . meow-next-word)
    '("O" . meow-next-symbol)

    '("a" . meow-word)
    '("s" . meow-line)
    '("w" . meow-block)
    '("q" . meow-join)
    '("g" . meow-grab)
    '("G" . meow-pop-grab)
    '("p" . meow-cancel-selection)
    '("P" . meow-pop-selection)

    '("x" . meow-till)
    '("X" . meow-find)

    '("," . meow-beginning-of-thing)
    '("." . meow-end-of-thing)
    '("<" . meow-inner-of-thing)
    '(">" . meow-bounds-of-thing)

    '("[" . indent-rigidly-left-to-tab-stop)
    '("]" . indent-rigidly-right-to-tab-stop)

    ; editing
    '("b" . open-line)
    '("B" . split-line)
    '("d" . meow-kill)
    '("D" . meow-kill-line)
    '("f" . meow-change)
    '("F" . meow-change-line)
    '("c" . meow-save)
    '("C" . meow-save-clipboard)
    '("v" . meow-yank-dwim)
    '("V" . meow-yank-pop-dwim)

    '("e" . meow-insert)
    '("E" . meow-open-above)
    '("r" . meow-append)
    '("R" . meow-open-below)

    '("z" . query-replace-regexp)

    '("h" . undo-only)
    '("H" . undo-redo)

    '("m"  . meow-kmacro)
    '("M"  . kmacro-call-macro)
    '("nm" . kmacro-edit-macro) ;; 'n' prefix is for editing commands

    '("nf" . meow-comment)

    '("N"  . upcase-dwim)
    '("nn" . downcase-dwim)
    '("nN" . capitalize-dwim)

    '("ns" . meow-swap-grab)
    
    ; eldoc
    '("t" . eldoc-box-help-at-point)
    '("T" . meow-eldoc)

    ; general
    '(";F" . save-some-buffers)
    '(";g" . goto-last-change)
    '("Q" . meow-quit)
    '(";c" . duplicate-dwim)
    '(";C" . copy-and-comment-region)
    '(";fr" . recentf)
    '(";hq" . restart-emacs)
    '(";hr" . dl/reload-emacs)
    '(";hn" . dl/load-buffer-with-nix-config)
    '(";hp" . dl/load-buffer-with-emacs-config)
    '(";ot" . projectile-run-vterm-other-window)
    '(";oT" . +vterm/here)
    '(";ox" . toggle-scratch-buffer)
    '(";lf" . dl/lsp-find-references-other-window)
    '(";lc" . dl/lsp-find-implementation-other-window)
    '(";ls" . lsp-treemacs-symbols)
    '(";le" . list-flycheck-errors)
    '(";lh" . lsp-treemacs-call-hierarchy)
    '(";lF" . lsp-format-buffer)
    '(";li" . lsp-organize-imports)
    '(";ll" . lsp)
    '(";lr" . lsp-rename)
    '(";ld" . dl/lsp-find-definition-other-window)
    '(";lt" . org-toggle-link-display)
    '(";," . dl/insert-header)
    '(";<" . dl/insert-current-time)
    '(";>" . dl/insert-current-date-prompt)
    '(";b" . bufler-switch-buffer)
    '(";B" . bufler-list)

    ; Rotation
    '(";rw" . rotate-window)
    '(";rl" . rotate-layout)

    ;; Version control
    '(";tg" . git-timemachine-toggle)
    
    ; Python
    '(";sr" . python-shell-send-region-or-line)
    '(";sb" . python-shell-send-buffer)
    '(";sd" . python-shell-send-defun)
    '(";se" . code-cells-eval)
    '(";y" . realgud:pdb)
    '(";a"  . realgud:attach-source-buffer)
    
   '("<escape>" . ignore)) ; ignore escape
   )
  (setq meow-use-cursor-position-hack t
	meow-use-enhanced-selection-effect t) 
  
    (meow-setup)
    (meow-global-mode 1)
    )

(use-package meow-vterm
  :after vterm
  :straight (:host github :repo "accelbread/meow-vterm"
		   :branch "master"
		   :files (:defaults "meow-vterm.el"))
  :config
  (meow-vterm-enable)
  )

(use-package re-builder
  :defer t)

(use-package casual-re-builder
  :straight (:host github :repo "kickingvegas/casual-re-builder")
  :bind (:map
         reb-mode-map ("C-o" . casual-re-builder-tmenu)
         :map
         reb-lisp-mode-map ("C-o" . casual-re-builder-tmenu))
  :after (re-builder))

(defun copy-and-comment-region (beg end &optional arg)
  "Duplicate the region and comment-out the copied text.
See `comment-region' for behavior of a prefix arg."
  (interactive "r\nP")
  (copy-region-as-kill beg end)
  (goto-char end)
  (yank)
  (comment-region beg end arg))

(use-package goto-chg)

(use-package keyword-search
  :config
  (setq keyword-search-alist
  	(append keyword-search-alist
  		'(
  		  (kagi . "https://kagi.com/search?q=%s")
  		  (kagi-news . "https://kagi.com/news?q=%s")
              (kagi-videos . "https://kagi.com/videos?q=%s")
              (kagi-maps . "https://kagi.com/maps?q=%s")
              (kagi-images . "https://kagi.com/images?q=%s")
              (kagi-podcasts . "https://kagi.com/podcasts?q=%s")
              (kagi-discussion . "https://kagi.com/discussdoc?url=%s")
              (kagi-fastgpt . "https://kagi.com/fastgpt?query=%s")
              (kagi-quick answer . "https://kagi.com/search?q=%s&qa=true")
              (kagi-calc . "https://kagi.com/search?q=calc+%s")
              (kagi-timer . "https://kagi.com/search?q=timer+%s")
              (pdfs . "https://kagi.com/search?q=%s+filetype:pdf")
              (kagi-universal summarizer . "https://kagi.com/summarizer?url=%s")
              (kagi-universal summarizer (key moments)  ."https://kagi.com/summarizer?url=%s&summary=takeaway")
              (kagi-universal summarizer (summary) . "https://kagi.com/summarizer?url=%s&summary=summary")
              (kagi-knowledgebase . "https://help.kagi.com/kagi?search=%s")
              (orion-knowledgebase . "https://help.kagi.com/orion?search=%s"))))
  (setq keyword-search-default 'kagi))

;; The `vertico' package applies a vertical layout to the minibuffer.
;; It also pops up the minibuffer eagerly so we can see the available
;; options without further interactions.  This package is very fast
;; and "just works", though it also is highly customisable in case we
;; need to modify its behaviour.
(use-package vertico
  :ensure t
  :init

  ;; Show more candidates
  (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  (vertico-mode 1)
  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :bind (:map vertico-map
             ("RET" . vertico-directory-enter)
             ("DEL" . vertico-directory-delete-char)
             ("M-DEL" . vertico-directory-delete-word)))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :ensure t
  :custom
  (marginalia-max-relative-age 0)
  ;; (marginalia-align 'right)
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  ;; The :init section is always executed.
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Support opening new minibuffers from inside existing minibuffers.
  (setq enable-recursive-minibuffers t)

  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode.  Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

    ;; Ensure evil keybindings work
  ;;   (eval-after-load 'vertico
  ;;      '(general-define-key :keymaps '(vertico-map)
  ;;         ;; "C-J"      #'vertico-next-group
  ;;         ;; "C-K"      #'vertico-previous-group
  ;;         "C-j"      #'vertico-next
  ;;         "C-k"      #'vertico-previous))

  (use-package all-the-icons
    :if (display-graphic-p))
  (use-package all-the-icons-completion
    :after (marginalia all-the-icons)
    :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
    :init
    (all-the-icons-completion-mode))

    ;; The `orderless' package lets the minibuffer use an out-of-order
    ;; pattern matching algorithm.  It matches space-separated words or
    ;; regular expressions in any order.  In its simplest form, something
    ;; like "ins pac" matches `package-menu-mark-install' as well as
    ;; `package-install'.  This is a powerful tool because we no longer
    ;; need to remember exactly how something is named.
    (use-package orderless
      :config
      (setq completion-styles '(orderless basic)))

      ;; Optionally use the `orderless' completion style.
      (use-package orderless
      :ensure t
        :init
        ;; Configure a custom style dispatcher (see the Consult wiki)
        ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
        ;;       orderless-component-separator #'orderless-escapable-split-on-space)
        (setq completion-styles '(orderless basic)
              completion-category-defaults nil
             completion-category-overrides '((file (styles partial-completion)))))

    ;; The `consult' package provides lots of commands that are enhanced
    ;; variants of basic, built-in functionality.  One of the headline
    ;; features of `consult' is its preview facility, where it shows in
    ;; another Emacs window the context of what is currently matched in
    ;; the minibuffer.  Here I define key bindings for some commands you
    ;; may find useful.  The mnemonic for their prefix is "alternative
    ;; search" (as opposed to the basic C-s or C-r keys).
    ;;
    ;; Further reading: https://protesilaos.com/emacs/dotemacs#h:22e97b4c-d88d-4deb-9ab3-f80631f9ff1d
    ;; Example configuration for Consult
    (use-package consult
      ;; Replace bindings. Lazily loaded due by `use-package'.
      :bind (;; C-c bindings in `mode-specific-map'
             ("C-c M-x" . consult-mode-command)
             ("C-c h" . consult-history)
             ("C-c k" . consult-kmacro)
             ("C-c m" . consult-man)
             ("C-c i" . consult-info)
             ([remap Info-search] . consult-info)
             ;; C-x bindings in `ctl-x-map'
             ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
             ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
             ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
             ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
             ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
             ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
             ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
             ;; Custom M-# bindings for fast register access
             ("M-#" . consult-register-load)
             ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
             ("C-M-#" . consult-register)
             ;; Other custom bindings
             ("M-y" . consult-yank-orig)                ;; yank. pop-pop
             ;; M-g bindings in `goto-map'
             ("M-s w" . consult-compile-error)
             ("M-s y" . consult-flymake)               ;; Alternative: consult-flycheck
             ("M-s o" . consult-outline)               ;; Alternative: consult-org-heading
             ("M-s m" . consult-mark)
             ("M-s K" . consult-global-mark) ;
             ("M-s i" . consult-imenu)
             ("M-s I" . consult-imenu-multi)
             ;; M-s bindings in `search-map'
             ("M-s d" . consult-find)                  ;; Alternative: consult-fd
             ("M-s c" . consult-locate)
             ("M-s g" . consult-grep)
             ("M-s G" . consult-git-grep)
             ("M-s r" . consult-ripgrep)
             ("s-r" . consult-recent-file)
             ("M-s l" . consult-line)
             ("M-s L" . consult-line-multi)
             ("M-s k" . consult-keep-lines)
             ("M-s u" . consult-focus-lines)
             ;; Isearch integration
             ("M-s e" . consult-isearch-history)
             :map isearch-mode-map
             ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
             ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
             ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
             ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
             ;; Minibuffer history
             :map minibuffer-local-map
             ("M-s" . consult-history)                 ;; orig. next-matching-history-element
             ("M-r" . consult-history))                ;; orig. previous-matching-history-element

      ;; Enable automatic preview at point in the *Completions* buffer. This is
      ;; relevant when you use the default completion UI.
      :hook (completion-list-mode . consult-preview-at-point-mode)

      ;; The :init configuration is always executed (Not lazy)
      :init

      ;; Optionally configure the register formatting. This improves the register
      ;; preview for `consult-register', `consult-register-load',
      ;; `consult-register-store' and the Emacs built-ins.
      (setq register-preview-delay 0.5
            register-preview-function #'consult-register-format)

      ;; Optionally tweak the register preview window.
      ;; This adds thin lines, sorting and hides the mode line of the window.
      (advice-add #'register-preview :override #'consult-register-window)

      ;; Use Consult to select xref locations with preview
      (setq xref-show-xrefs-function #'consult-xref
            xref-show-definitions-function #'consult-xref)

      ;; Configure other variables and modes in the :config section,
      ;; after lazily loading the package.
      :config

      ;; Optionally configure preview. The default value
      ;; is 'any, such that any key triggers the preview.
      ;; (setq consult-preview-key 'any)
      ;; (setq consult-preview-key "M-.")
      ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
      ;; For some commands and buffer sources it is useful to configure the
      ;; :preview-key on a per-command basis using the `consult-customize' macro.
      (consult-customize
       consult-theme :preview-key '(:debounce 0.2 any)
       consult-ripgrep consult-git-grep consult-grep
       consult-bookmark consult-recent-file consult-xref
       consult--source-bookmark consult--source-file-register
       consult--source-recent-file consult--source-project-recent-file
       ;; :preview-key "M-."
       :preview-key '(:debounce 0.4 any))

      ;; Optionally configure the narrowing key.
      ;; Both < and C-+ work reasonably well.
      (setq consult-narrow-key "<") ;; "C-+"

      ;; Optionally make narrowing help available in the minibuffer.
      ;; You may want to use `embark-prefix-help-command' or which-key instead.
      ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

      ;; By default `consult-project-function' uses `project-root' from project.el.
      ;; Optionally configure a different project root function.
      ;;;; 1. project.el (the default)
      ;; (setq consult-project-function #'consult--default-project--function)
      ;;;; 2. vc.el (vc-root-dir)
      (setq consult-project-function (lambda (_) (vc-root-dir)))
      ;;;; 3. locate-dominating-file
      ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
      ;;;; 4. projectile.el (projectile-project-root)
      ;; (autoload 'projectile-project-root "projectile")
      ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
      ;;;; 5. No project support
      ;; (setq consult-project-function nil)
    )

    ;; The `embark' package lets you target the thing or context at point
    ;; and select an action to perform on it.  Use the `embark-act'
    ;; command while over something to find relevant commands.
    ;;
    ;; When inside the minibuffer, `embark' can collect/export the
    ;; contents to a fully fledged Emacs buffer.  The `embark-collect'
    ;; command retains the original behaviour of the minibuffer, meaning
    ;; that if you navigate over the candidate at hit RET, it will do what
    ;; the minibuffer would have done.  In contrast, the `embark-export'
    ;; command reads the metadata to figure out what category this is and
    ;; places them in a buffer whose major mode is specialised for that
    ;; type of content.  For example, when we are completing against
    ;; files, the export will take us to a `dired-mode' buffer; when we
    ;; preview the results of a grep, the export will put us in a
    ;; `grep-mode' buffer.
    ;;
    ;; Further reading: https://protesilaos.com/emacs/dotemacs#h:61863da4-8739-42ae-a30f-6e9d686e1995
    (use-package embark
      :ensure t
      :bind (("C-." . embark-act)
             :map minibuffer-local-map
             ("C-c C-c" . embark-collect)
             ("C-c C-e" . embark-export)))

    ;; The `embark-consult' package is glue code to tie together `embark'
    ;; and `consult'.
    (use-package embark-consult
      :ensure t)

    ;; The `wgrep' packages lets us edit the results of a grep search
    ;; while inside a `grep-mode' buffer.  All we need is to toggle the
    ;; editable mode, make the changes, and then type C-c C-c to confirm
    ;; or C-c C-k to abort.
    ;;
    ;; Further reading: https://protesilaos.com/emacs/dotemacs#h:9a3581df-ab18-4266-815e-2edd7f7e4852
    (use-package wgrep
      :ensure t
      :bind ( :map grep-mode-map
              ("e" . wgrep-change-to-wgrep-mode)
              ("C-x C-q" . wgrep-change-to-wgrep-mode)
              ("C-c C-c" . wgrep-finish-edit)))

    ;; The built-in `savehist-mode' saves minibuffer histories.  Vertico
    ;; can then use that information to put recently selected options at
    ;; the top.
    ;;
    ;; Further reading: https://protesilaos.com/emacs/dotemacs#h:25765797-27a5-431e-8aa4-cc890a6a913a
    (savehist-mode 1)

(use-package doom-themes
  :ensure t
  :config
   (setq doom-themes-enable-bold t
         doom-themes-enable-italic t)
    (load-theme 'modus-vivendi)
    (doom-themes-visual-bell-config)
    (doom-themes-org-config))

(defun bram85-show-time-for-fullscreen (frame)
  "Show the time in the modeline when the FRAME becomes full screen."
  (let ((fullscreen (frame-parameter frame 'fullscreen)))
    (if (memq fullscreen '(fullscreen fullboth))
        (display-time-mode 1)
      (display-time-mode -1))))

(add-hook 'window-size-change-functions #'bram85-show-time-for-fullscreen)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(setq setup-font-filename "setup-font-check.el")
(defun modi/font-check ()
  "Do font check, then remove self from `focus-in-hook'; need to run this just once."
  (require 'setup-font-check (concat config-dir "setup-font-check.el"))
  (remove-hook 'focus-in-hook #'modi/font-check))
;; For non-daemon, regular emacs launches, the frame/fonts are loaded *before*
;; the emacs config is read. But when emacs is launched as a daemon (using
;; emacsclient, the fonts are not actually loaded until the point when the
;; `after-make-frame-functions' hook is run. But even at that point, the frame
;; is not yet selected (for the daemon case). Without a selected frame, the
;; `find-font' will not work correctly. So we do the font check in
;; `focus-in-hook' instead by which all the below are true:
;;  - Fonts are loaded (in both daemon and non-daemon cases).
;;  - The frame is selected and so `find-font' calls work correctly.
(add-hook 'focus-in-hook #'modi/font-check)
(with-eval-after-load 'setup-font-check
  (when font-iosevka-p
    (set-frame-font "Iosevka 20" ) ; default
    ;;  Set the fixed pitch face
    (set-face-attribute 'fixed-pitch nil :font "Iosevka Nerd Font Mono" :weight 'normal :height 120)
    ;;     Set the variable pitch face
    (set-face-attribute 'variable-pitch nil :font "Iosevka" :weight 'normal :height 200)
    ))

(setq org-directory "~/Documents/sync/org/")

(setq org-agenda-files "~/.emacs.d/agenda.txt" )

(defun my-org-insert-subheading (heading-type)
"Inserts a new org heading with unique ID and creation date.
The type of heading (TODO, PROJECT, etc.) is specified by HEADING-TYPE."
  (let ((uuid (org-id-uuid))
        (date (format-time-string "[%Y-%m-%d %a %H:%M]")))
    (org-end-of-line) ;; Make sure we are at the end of the line
    (unless (looking-at-p "\n") (insert "\n")) ;; Insert newline if next character is not a newline
    (org-insert-subheading t) ;; Insert a subheading instead of a heading
    (insert (concat heading-type " "))
    (save-excursion
      (org-set-property "ID" uuid)
      (org-set-property "CREATED" date))))

(defun my-org-insert-todo ()
  "Inserts a new TODO heading with unique ID and creation date."
  (interactive)
  (my-org-insert-subheading "TODO"))

(defun my-org-insert-project ()
  "Inserts a new PROJECT heading with unique ID and creation date."
  (interactive)
  (my-org-insert-subheading "PROJECT"))

(defun my-org-copy-link-from-id ()
  "Copies a link to the current Org mode item by its ID to clipboard"
  (interactive)
  (when (org-at-heading-p)
    (let* ((element (org-element-at-point))
           (title (org-element-property :title element))
           (id (org-entry-get nil "ID"))
           (link (format "[[id:%s][%s]]" id title)))
      (when id
        (kill-new link)
        (message "Link saved to clipboard")))))

(define-prefix-command 'my-org-todo-prefix)

(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c t") 'my-org-todo-prefix)

(define-key 'my-org-todo-prefix (kbd "t") 'my-org-insert-todo)
(define-key 'my-org-todo-prefix (kbd "p") 'my-org-insert-project)

(define-key org-mode-map (kbd "C-c l") 'my-org-copy-link-from-id)

;; Fast access to tag common contexts I use
(setq org-todo-keywords
 '((sequence "TODO(t)" "STARTED(s)" "WAITING(w@/!)"
             "DELEGATED(g@/!)" "DEFERRED(r)" "SOMEDAY(y)"
             "|" "DONE(d@)" "CANCELED(x@)")
   (sequence "PROJECT(p)" "|" "DONE(d@)" "CANCELED(x@)")
   (sequence "APPT(a)" "|" "DONE(d@)" "CANCELED(x@)")))

(defface my-org-agenda-face-1-2
  '((t (:inherit default :height 1.2)))
  "Face for org-agenda mode.")

(defun my-set-org-agenda-font ()
  "Set the font for `org-agenda-mode'."
  (buffer-face-set 'my-org-agenda-face-1-2))

(add-hook 'org-agenda-mode-hook 'my-set-org-agenda-font)

(setq display-buffer-alist
    `((".*Org Agenda.*"
       (display-buffer-below-selected)
       (inhibit-same-window . t)
       (window-height . 0.5))))

(defun dl/buffer-prop-get (name)
  "Get a buffer property called NAME as a string."
  (org-with-point-at 1
    (when (re-search-forward (concat "^#\\+" name ": \\(.*\\)")
                            (point-max) t)
      (buffer-substring-no-properties
      (match-beginning 1)
      (match-end 1)))))

(defun dl/agenda-category (&optional len)
  "Get category of item at point for agenda."
  (let* ((file-name (when buffer-file-name
                      (file-name-sans-extension
                      (file-name-nondirectory buffer-file-name))))
        (title (dl/buffer-prop-get "title"))
        (category (org-get-category))
        (result (or (if (and title (string-equal category file-name))
                        title
                      category))))
    (if (numberp len)
        (s-truncate len (s-pad-right len " " result))
      result)))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "j") 'org-agenda-next-line)
  (define-key org-agenda-mode-map (kbd "k") 'org-agenda-previous-line))

(setq org-agenda-todo-ignore-keywords '("PROJECT"))

(use-package org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-dim-blocked-tasks nil))

;; Define custom faces for group highlighting
(defface org-super-agenda-header
  '((t (:inherit org-agenda-structure :height 1.1 :foreground "#7cc3f3" :background "#282c34")))
  "Face for highlighting org-super-agenda groups.")

(defface org-super-agenda-subheader
  '((t (:inherit org-agenda-structure :height 1.0 :foreground "light slate gray" :background "black")))
  "Face for highlighting org-super-agenda subgroups.")

;; Apply the custom faces to org-super-agenda
(custom-set-faces
 '(org-super-agenda-header ((t (:inherit org-agenda-structure :height 1.1 :foreground "#7cc3f3" :background "#282c34"))))
 '(org-super-agenda-subheader ((t (:inherit org-agenda-structure :height 1.0 :foreground "light slate gray" :background "black")))))

(setq org-super-agenda-groups
  '((:name "Priority A"
     :priority "A")
    (:name "Priority B"
     :priority "B")
    (:name "Priority C"
     :priority "C")
    (:name "Started"
     :todo "STARTED")
    (:name "Waiting"
     :todo "WAITING")
    (:name "Tasks"
     :todo "TODO")
    (:name "Someday"
     :todo "SOMEDAY")
  (:name "Projects"
   :tag "PROJECT")))

(org-super-agenda-mode)

(use-package org-sticky-header
  :after org
  :config
  (setq org-sticky-header-full-path 'full)
  :hook (org-mode . org-sticky-header-mode))

(use-package topsy
  :hook
  (prog-mode . topsy-mode)
  (magit-section-mode . topsy-mode))

(use-package org-transclusion
  :after org
  :hook (org-mode . org-transclusion-mode))

(defun org-global-props (&optional property buffer)
  "Helper function to grab org properties"
  (unless property (setq property "PROPERTY"))
  (with-current-buffer (or buffer (current-buffer))
    (org-element-map (org-element-parse-buffer) 'keyword
    (lambda (el) (when (string-match property (org-element-property :key el)) el)))))

(defvar current-time-format "%H:%M:%S"
  "Format of date to insert with `insert-current-time' func.
                Note the weekly scope of the command's precision.")

(defun dl/find-file (path)
  "Helper function to open a file in a buffer"
  (interactive)
  (find-file path))

(defun dl/load-buffer-with-emacs-config ()
  "Open the emacs configuration"
  (interactive)
  (find-file (if (boundp 'org-config-file) org-config-file "~/.local/share/src/nixos-config/modules/shared/config/emacs/config.org" )))

(defun dl/load-buffer-with-nix-config ()
  "Open the emacs configuration"
  (interactive)
  (find-file "~/.local/share/src/nixos-config/modules/shared/home-manager.nix"))

(defun dl/reload-emacs ()
  "Reload the emacs configuration"
  (interactive)
  (load "~/.emacs.d/init.el"))

(defun dl/insert-header ()
  "Insert a header indented one level from the current header, unless the current header is a timestamp."
  (interactive)
  (let* ((level (org-current-level))
         (headline (org-get-heading t t t t))
         (next-level (if (string-match "^\\([0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}\\)" headline)
                         (1+ level)
                       level)))
    (end-of-line)
    (newline)
    (insert (make-string next-level ?*))
    (insert " ")))

(defun dl/insert-current-time ()
  "Insert the current time into the current buffer, at a level one deeper than the current heading."
  (interactive)
  (let* ((level (org-current-level))
         (next-level (1+ level)))
    (end-of-line)
    (newline)
    (insert (make-string next-level ?*))
    (insert " " (format-time-string "%H:%M:%S" (current-time)) "\n")))

(defun dl/insert-current-date-prompt ()
  "Prompt a calendar and insert the current date into the current buffer, at a level one deeper than the current heading."
  (interactive)
  (let* ((level (org-current-level))
         (next-level (1+ level)))
    (end-of-line)
    (newline)
    (insert (make-string next-level ?*))
    (insert " ")
    (org-time-stamp nil)))

(defun open-in-root-window-below (buffer-name fn-create-buffer)
  (let ((buffer-window (get-buffer-window buffer-name)))
    (if buffer-window
      	(select-window buffer-window)
      (progn
      	;; (split-window (let ((tree (car (window-tree)))) (if (listp tree) (car (reverse tree)) tree)) '(nil 100) 'below 'nil)
      	(split-window (car (window-tree)) '(nill 100) 'below nil)
      	(select-window (get-lru-window))
      	(switch-to-buffer (funcall fn-create-buffer))))))

(defun open-scratch-below ()
  (open-in-root-window-below "*scratch*" 'get-scratch-buffer-create))

(defun toggle-window-bottom (buffer-name fn-create-buffer)
  (let ((buffer-window (get-buffer-window buffer-name)))
    (if buffer-window
        (delete-window buffer-window)
      (open-in-root-window-below buffer-name fn-create-buffer))))

(defun toggle-scratch-buffer ()
  (interactive)
  (toggle-window-bottom "*scratch*" 'get-scratch-buffer-create))

(setq org-roam-capture-templates
 '(("d" "default" plain
    "%?"
    :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n\n")
    :unnarrowed t)))

(defun unpackaged/org-forward-to-entry-content (&optional unsafe)
  "Skip headline, planning line, and all drawers in current entry.
If UNSAFE is non-nil, assume point is on headline."
  (unless unsafe
    ;; To improve performance in loops (e.g. with `org-map-entries')
    (org-back-to-heading))
  (cl-loop for element = (org-element-at-point)
           for pos = (pcase element
                       (`(headline . ,_) (org-element-property :contents-begin element))
                       (`(,(or 'planning 'property-drawer 'drawer) . ,_) (org-element-property :end element)))
           while pos
           do (goto-char pos)))

(defun my-org-files-list ()
  (delq nil
    (mapcar (lambda (buffer)
      (buffer-file-name buffer))
      (org-buffer-list 'files t))))

(setq org-refile-targets '((my-org-files-list :maxlevel . 4)))

(use-package websocket
    :after org-roam)

(use-package org-roam-ui
:after org-roam 
:config
(setq org-roam-ui-sync-theme t
org-roam-ui-follow t
org-roam-ui-update-on-save t
org-roam-ui-open-on-start t))

(use-package ox-pandoc
   :ensure t   ;Auto-install the package from Melpa
   :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
   :after org)

 (use-package ox-hugo
   :ensure t   ;Auto-install the package from Melpa
   :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
   :after org)

 ; Git-flavoured markdown
 (use-package ox-gfm
   :ensure t
   :after org
   :config
   (add-to-list 'org-export-backends 'md )
   (add-to-list 'org-export-backends 'gfm )
)

(use-package ob-mermaid
  :after org
  :config
  (setq ob-mermaid-cli-path (if (eq system-type 'darwin) "/opt/homebrew/bin/mmdc" "mmdc" ))

  (setq org-babel-default-header-args:mermaid
        '(
          (:results . "file")
          (:width . "1080")
          (:height . "768")
          (:background-color . "transparent")
          (:theme . "dark")))
  )

(with-eval-after-load 'org
  (setq org-confirm-babel-evaluate nil)
  ;; (add-to-list 'org-src-lang-modes '("jupyter-python" . python))
  ;; (add-to-list 'org-babel-tangle-lang-exts '("jupyter-python" . "py"))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     ;; (python . t)
     ;; (jupyter . t)
     (mermaid . t)))
  ;; (setq ob-async-no-async-languages-alist '("python" "jupyter"))
  )

(defun dl/babel-ansi ()
  (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
    (save-excursion
      (goto-char beg)
      (when (looking-at org-babel-result-regexp)
        (let ((end (org-babel-result-end))
              (ansi-color-context-region nil))
          (ansi-color-apply-on-region beg end))))))
(add-hook 'org-babel-after-execute-hook 'dl/babel-ansi)

(use-package org-contrib
  :after org)

(defun +org/dwim-at-point (&optional arg)
  "Do-what-I-mean at point.

If on a:
- checkbox list item or todo heading: toggle it.
- citation: follow it
- headline: cycle ARCHIVE subtrees, toggle latex fragments and inline images in
  subtree; update statistics cookies/checkboxes and ToCs.
- clock: update its time.
- footnote reference: jump to the footnote's definition
- footnote definition: jump to the first reference of this footnote
- timestamp: open an agenda view for the time-stamp date/range at point.
- table-row or a TBLFM: recalculate the table's formulas
- table-cell: clear it and go into insert mode. If this is a formula cell,
  recaluclate it instead.
- babel-call: execute the source block
- statistics-cookie: update it.
- src block: execute it
- latex fragment: toggle it.
- link: follow it
- otherwise, refresh all inline images in current tree."
  (interactive "P")
  (if (button-at (point))
      (call-interactively #'push-button)
    (let* ((context (org-element-context))
           (type (org-element-type context)))
      ;; skip over unimportant contexts
      (while (and context (memq type '(verbatim code bold italic underline strike-through subscript superscript)))
        (setq context (org-element-property :parent context)
              type (org-element-type context)))
      (pcase type
        ((or `citation `citation-reference)
         (org-cite-follow context arg))

        (`headline
         (cond ((memq (bound-and-true-p org-goto-map)
                      (current-active-maps))
                (org-goto-ret))
               ((and (fboundp 'toc-org-insert-toc)
                     (member "TOC" (org-get-tags)))
                (toc-org-insert-toc)
                (message "Updating table of contents"))
               ((string= "ARCHIVE" (car-safe (org-get-tags)))
                (org-force-cycle-archived))
               ((or (org-element-property :todo-type context)
                    (org-element-property :scheduled context))
                (org-todo
                 (if (eq (org-element-property :todo-type context) 'done)
                     (or (car (+org-get-todo-keywords-for (org-element-property :todo-keyword context)))
                         'todo)
                   'done))))
         ;; Update any metadata or inline previews in this subtree
         (org-update-checkbox-count)
         (org-update-parent-todo-statistics)
         (when (and (fboundp 'toc-org-insert-toc)
                    (member "TOC" (org-get-tags)))
           (toc-org-insert-toc)
           (message "Updating table of contents"))
         (let* ((beg (if (org-before-first-heading-p)
                         (line-beginning-position)
                       (save-excursion (org-back-to-heading) (point))))
                (end (if (org-before-first-heading-p)
                         (line-end-position)
                       (save-excursion (org-end-of-subtree) (point))))
                (overlays (ignore-errors (overlays-in beg end)))
                (latex-overlays
                 (cl-find-if (lambda (o) (eq (overlay-get o 'org-overlay-type) 'org-latex-overlay))
                             overlays))
                (image-overlays
                 (cl-find-if (lambda (o) (overlay-get o 'org-image-overlay))
                             overlays)))
           (+org--toggle-inline-images-in-subtree beg end)
           (if (or image-overlays latex-overlays)
               (org-clear-latex-preview beg end)
             (org--latex-preview-region beg end))))

        (`clock (org-clock-update-time-maybe))

        (`footnote-reference
         (org-footnote-goto-definition (org-element-property :label context)))

        (`footnote-definition
         (org-footnote-goto-previous-reference (org-element-property :label context)))

        ((or `planning `timestamp)
         (org-follow-timestamp-link))

        ((or `table `table-row)
         (if (org-at-TBLFM-p)
             (org-table-calc-current-TBLFM)
           (ignore-errors
             (save-excursion
               (goto-char (org-element-property :contents-begin context))
               (org-call-with-arg 'org-table-recalculate (or arg t))))))

        (`table-cell
         (org-table-blank-field)
         (org-table-recalculate arg)
         (when (and (string-empty-p (string-trim (org-table-get-field)))
                    (bound-and-true-p evil-local-mode))
           (evil-change-state 'insert)))

        (`babel-call
         (org-babel-lob-execute-maybe))

        (`statistics-cookie
         (save-excursion (org-update-statistics-cookies arg)))

        ((or `src-block `inline-src-block)
         (org-babel-execute-src-block arg))

        ((or `latex-fragment `latex-environment)
         (org-latex-preview arg))

        (`link
         (let* ((lineage (org-element-lineage context '(link) t))
                (path (org-element-property :path lineage)))
           (if (or (equal (org-element-property :type lineage) "img")
                   (and path (image-type-from-file-name path)))
               (+org--toggle-inline-images-in-subtree
                (org-element-property :begin lineage)
                (org-element-property :end lineage))
             (org-open-at-point arg))))

        ((guard (org-element-property :checkbox (org-element-lineage context '(item) t)))
         (org-toggle-checkbox))

        (`paragraph
         (+org--toggle-inline-images-in-subtree))

        (_
         (if (or (org-in-regexp org-ts-regexp-both nil t)
                 (org-in-regexp org-tsr-regexp-both nil  t)
                 (org-in-regexp org-link-any-re nil t))
             (call-interactively #'org-open-at-point)
           (+org--toggle-inline-images-in-subtree
            (org-element-property :begin context)
            (org-element-property :end context))))))))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package treesit-fold
  :straight (treesit-fold :type git :host github :repo "emacs-tree-sitter/treesit-fold")
  :config (global-treesit-fold-mode))

(use-package treesit-fold-indicators
:straight (treesit-fold-indicators :type git :host github :repo "emacs-tree-sitter/treesit-fold")
:config (global-treesit-fold-indicators-mode))

(use-package nix-mode
    :mode "\\.nix\\'")

  (use-package yaml-mode
    :mode "\\.yml\\'")

(use-package csv-mode
  :mode (".tsv" ".csv" ".tabular" ".vcf")
  :hook
  (csv-mode . (lambda ()
                (progn
                  (setq-local csv-comment-start "##")
                  (csv-align-mode t)
                  (toggle-truncate-lines 1)
                  (csv-header-line t))
            )))

(use-package all-the-icons-dired)

(use-package dirvish
  :init
  (dirvish-override-dired-mode 1)
  :custom
  (dirvish-quick-access-entries ; It's a custom option, `setq' won't work
   '(("h" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ("m" "/mnt/"                       "Drives")
     ("t" "~/.local/share/Trash/files/" "TrashCan")))
  :config
                                        ; (dirvish-peek-mode) ; Preview files in minibuffer
  (setq dired-dwim-target t)
  (dirvish-side-follow-mode) ; similar to `treemacs-follow-mode'
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (setq delete-by-moving-to-trash t)
  (setq dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first --no-group")

  (setq dirvish-subtree-state-style 'nerd)
  '(add-to-list 'dired-compress-file-suffixes
    '("\\.zip\\'" ".zip" "unzip"))

  :bind ; Bind `dirvish|dirvish-side|dirvish-dwim' as you see fit
  (("C-c f" . dirvish-fd)
   :map dirvish-mode-map ; Dirvish inherits `dired-mode-map'
     ("j" . dired-up-directory)
     ("l" . dired-find-file)
     ("i" . dired-previous-line)
     ("k" . dired-next-line)
   ;; ("a"   . dirvish-quick-access)
   ;; ("f"   . dirvish-file-info-menu)
   ;; ("y"   . dirvish-yank-menu)
   ;; ("N"   . dirvish-narrow)
   ;; ("j"   . dirvish-history-last)
   ;; ("h"   . dirvish-history-jump) ; remapped `describe-mode'
   ;; ("s"   . dirvish-quicksort)    ; remapped `dired-sort-toggle-or-edit'
   ;; ("v"   . dirvish-vc-menu)      ; remapped `dired-view-file'
   ;; ("TAB" . dirvish-subtree-toggle)
   ;; ("M-f" . dirvish-history-go-forward)
   ;; ("M-b" . dirvish-history-go-backward)
   ;; ("M-l" . dirvish-ls-switches-menu)
   ;; ("M-m" . dirvish-mark-menu)
   ;; ("M-t" . dirvish-layout-toggle)
   ("q" . dirvish-quit)
   ;; ; ("M-s" . dirvish-setup-menu)
   ;; ("M-e" . dirvish-emerge-menu)
   ;; ("M-j" . dirvish-fd-jump)
   )
  :hook (dired-mode . auto-revert-mode))

;; (use-package nerd-icons-dired
;;   :hook
;;   (dired-mode . nerd-icons-dired-mode))
;;       ;; Darwin needs ls from coreutils for dired to work                 ;;
;;       (when (system-is-mac)
;;      (setq insert-directory-program
;;        (expand-file-name ".nix-profile/bin/ls" (getenv "HOME"))))

(defun my-org-archive-done-tasks ()
  "Archive all DONE tasks in the current buffer."
  (interactive)
  (org-map-entries
  (lambda ()
    (org-archive-subtree)
    (setq org-map-continue-from (outline-previous-heading)))
  "/DONE" 'tree))

(defun er-delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (yes-or-no-p (concat "Do you really want to delete file: " filename "? ")) ; Ask for confirmation
          (if (vc-backend filename)
              (vc-delete-file filename)
            (progn
              (delete-file filename)
              (message "Deleted file %s" filename)
              (kill-buffer)))
        (message "Aborted"))))) ; Abort message

(define-key org-mode-map (kbd "C-c D") 'my-org-archive-done-tasks)
(define-key org-mode-map (kbd "C-c d") 'org-archive-subtree)
(global-set-key (kbd "C-c x")  #'er-delete-file-and-buffer)

(setq dired-rsync-options "-az --progress")

(use-package org-download)
;; Drag-and-drop to `dired`
(add-hook 'dired-mode-hook 'org-download-enable)

(setq backup-directory-alist
      `((".*" . "~/.local/state/emacs/backup"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t) ; Automatically delete excess backups

(setq auto-save-file-name-transforms
      `((".*" "~/.local/state/emacs/" t)))
(setq lock-file-name-transforms
      `((".*" "~/.local/state/emacs/lock-files/" t)))

(use-package ripgrep)
(use-package projectile
:diminish projectile-mode
:config (projectile-mode)
:bind-keymap
  ("C-c p" . projectile-command-map)
;; @       :bind (:map projectile-command-map ("m" . project-vterm))
:init
  (setq projectile-enable-caching t)
  (setq projectile-sort-order 'recently-active)
  (setq projectile-switch-project-action #'projectile-dired)
:config
  (setq projectile-project-root-files-bottom-up '("package.json" ".projectile" ".project" ".git"))
  (setq projectile-ignored-projects '("~/.emacs.d/"))
  (setq projectile-globally-ignored-directories '("dist" "node_modules" ".log" ".git"))

  (define-key projectile-mode-map [?\s-d] 'projectile-find-dir)
  (define-key projectile-mode-map [?\s-p] 'projectile-switch-project)
  (define-key projectile-mode-map [?\s-f] 'projectile-find-file)
  (define-key projectile-mode-map [?\s-g] 'projectile-grep))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'ascii
        dashboard-center-content t
        dashboard-items '((projects . 5)
                          (recents  . 5)
  			  (bookmarks . 5)))
  (setq dashboard-set-footer nil))
(setq dashboard-banner-logo-title "Here be dragons")
(setq dashboard-set-file-icons t)
(setq dashboard-projects-backend 'projectile)

(setq initial-buffer-choice (lambda ()
                              (get-buffer-create "*dashboard*")
                              (dashboard-refresh-buffer)))

(defun dashboard-insert-custom (list-size)
  (insert (shell-command-to-string "curl -s \"wttr.in/Boston?m&format=3\"")))
(add-to-list 'dashboard-item-generators  '(custom . dashboard-insert-custom))
(add-to-list 'dashboard-items '(custom) t)

(use-package bufler
   :config
  (bufler-mode 1))

(use-package vterm
  :ensure t
  :init
  (defun toggle-vterm-window ()
    (interactive)
    (toggle-window-bottom
     "*vterm*"
     (lambda ()
       (progn (get-buffer-create "*vterm*") (vterm) ))))
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-shell "fish")
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 10000))
  (defun +vterm/here (arg)
    "Open a terminal buffer in the current window at project root.

If prefix ARG is non-nil, cd into `default-directory' instead of project root.

Returns the vterm buffer."
    (interactive "P")
    (+vterm--configure-project-root-and-display
     arg
     (lambda()
       (require 'vterm)
       ;; HACK forces vterm to redraw, fixing strange artefacting in the tty.
       (save-window-excursion
	 (pop-to-buffer "*scratch*"))
       (let (display-buffer-alist)
	 (vterm vterm-buffer-name)))))

  (defun +vterm--configure-project-root-and-display (arg display-fn)
    "Sets the environment variable PROOT and displays a terminal using `display-fn`.

If prefix ARG is non-nil, cd into `default-directory' instead of project root.

Returns the vterm buffer."
    (unless (fboundp 'module-load)
      (user-error "Your build of Emacs lacks dynamic modules support and cannot load vterm"))
    (let* ((project-root (or (projectile-project-root) default-directory))
           (default-directory
            (if arg
		default-directory
              project-root)))
      (setenv "PROOT" project-root)
      (funcall display-fn)))

;; :bind (:map vterm-mode-map ("C-q") #'vterm-send-next-key)
;; Add different font
;; (add-hook 'vterm-mode-hook
;;           (lambda ()
;;                (set (make-local-variable 'buffer-face-mode-face) '(:family "IosevkaTerm Nerd Font"))
;;                (buffer-face-mode t)))

;; (defun project-vterm ()
;;   "Start Eshell in the current project's root directory.
;; If a buffer already exists for running Eshell in the project's root,
;; switch to it.  Otherwise, create a new Eshell buffer.
;; With \\[universal-argument] prefix arg, create a new Eshell buffer even
;; if one already exists."
;;   (interactive)
;;   (defvar eshell-buffer-name)
;;   (let* ((default-directory (project-root (project-current t)))
;;          (eshell-buffer-name (project-prefixed-buffer-name "eshell"))
;;          (eshell-buffer (get-buffer eshell-buffer-name)))
;;     (if (and eshell-buffer (not current-prefix-arg))
;;         (pop-to-buffer eshell-buffer (bound-and-true-p display-comint-buffer-action))
;;       (vterm))))
;; (global-set-key (kbd "C-x C-t") 'vterm)

(straight-use-package
 '(eat :type git
       :host codeberg
       :repo "akib/emacs-eat"
       :files ("*.el" ("term" "term/*.el") "*.texi"
               "*.ti" ("terminfo/e" "terminfo/e/*")
               ("terminfo/65" "terminfo/65/*")
               ("integration" "integration/*")
               (:exclude ".dir-locals.el" "*-tests.el"))))

(when (system-is-mac)
  (with-eval-after-load "ispell"
    (setq ispell-program-name
      (expand-file-name ".nix-profile/bin/aspell" (getenv "HOME")))
    (setq ispell-dictionary "en")))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

(add-hook 'git-commit-mode-hook 'turn-on-flyspell)
(add-hook 'text-mode-hook 'flyspell-mode)
;; Disable this for now, doesn't play well with long literate configuration
;; (add-hook 'org-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

(defun spell() (interactive) (flyspell-mode 1))

(setq synosaurus-choose-method 'popup)
(setq org-M-RET-may-split-line t)
(setf org-blank-before-new-entry '((heading . auto) (plain-list-item . nil)))

(use-package powerthesaurus)

(use-package impatient-mode
  :config
  (setq markdown-max-image-size (cons (/ 1920 2) (/ 1080 2)))

  (defun markdown-html (buffer)
    (princ (with-current-buffer buffer
             (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://ndossougbe.github.io/strapdown/dist/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
	   (current-buffer)))

  (defun serve-buffer-as-html ()
    (interactive)
    (httpd-start)
    (unless (bound-and-true-p impatient-mode) (impatient-mode))
    (imp-set-user-filter 'markdown-html))

  (defun stop-impatient-service ()
    (interactive)
    (when (bound-and-true-p impatient-mode) (impatient-mode))
    (httpd-stop)))

(use-package citar
   :no-require
   :custom
   (org-cite-global-bibliography '("~/Documents/sync/bibliography/bibliography.bib" "~/Documents/sync/bibliography/mac_bibliography.bib"))
   (org-cite-insert-processor 'citar)
   (org-cite-follow-processor 'citar)
   (org-cite-activate-processor 'citar)
   (citar-bibliography org-cite-global-bibliography)
   (org-cite-csl-styles-dir
    (expand-file-name "~/Zotero/styles/")))
(use-package citeproc-org)
  (use-package citeproc-org
    :config
    (citeproc-org-setup)
    (require 'oc-csl))

(defun org/parse-headings (backend)
  (if (member backend '(latex))
      (org-map-entries
       (lambda ()
         (progn
           (insert-string "#+LATEX: \\newpage")))

       "+newpage")))


(add-hook 'org-export-before-parsing-hook 'org/parse-headings)

(setq org-latex-default-class "extarticle")

;;  (add-hook 'org-mode #'(cdlatex-mode))


  (setq org-latex-prefer-user-labels t
        org-latex-caption-above nil
        org-latex-listings 'minted
        )


;(after! org
  ;;Colours
;(add-to-list 'org-latex-packages-alist '("" "minted"))
;(add-to-list 'org-latex-packages-alist '("" "tabularx"))
;(plist-put org-format-latex-options :scale 1.75        )
;(add-to-list 'org-latex-packages-alist '("" "unicode-math")))
  ;; Temporarily increase margins
  ;; (add-to-list 'org-latex-packages-alist '("margin=2cm" "geometry"))

(setq org-latex-compiler "xelatex")

;; Auto scroll the buffer as we compile
(setq compilation-scroll-output t)

;; By default, eshell doesn't support ANSI colors. Enable them for compilation.
(use-package ansi-color)
(defun colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(use-package lsp-mode
    :commands lsp lsp-deferred
    :init
      (setq lsp-keymap-prefix "C-c l")
      ;;(setq lsp-keep-workspace-alive nil)
      ;;(setq lsp-restart 'ignore)
      (setq lsp-headerline-breadcrumb-enable nil)
      (setq lsp-auto-guess-root t)
      (setq lsp-enable-which-key-integration t)
      (setq lsp-warn-no-matched-clients nil) ; remove warnings
      :hook
  	(envrc-mode . lsp)
	)


  (use-package lsp-ui
    :hook (lsp-mode . lsp-ui-mode)
    :custom
      (lsp-ui-doc-position 'bottom))

  (use-package lsp-treemacs
    :after lsp)

  (use-package company
    :after lsp-mode
    :hook (lsp-mode . company-mode)
    :bind (:map company-active-map
          ("<tab>" . company-complete-selection))
          (:map lsp-mode-map
          ("<tab>" . company-indent-or-complete-common))
     :custom
       (company-minimum-prefix-length 1)
       (company-idle-delay 0.0))

  (use-package company-box
    :hook (company-mode . company-box-mode))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred
  ;; (add-hook 'lsp-mode-hook #'lsp-headerline-breadcrumb-mode)

(defun dl/lsp-find-references-other-window ()
  (interactive)
  (switch-to-buffer-other-window (current-buffer))
  (lsp-find-references))

(defun dl/lsp-find-implementation-other-window ()
  (interactive)
  (switch-to-buffer-other-window (current-buffer))
  (lsp-find-implementation))

(defun dl/lsp-find-definition-other-window ()
  (interactive)
  (switch-to-buffer-other-window (current-buffer))
  (lsp-find-definition))

;; (setq python-shell-completion-native-disabled-interpreters '("python"))
;; (add-to-list 'python-shell-completion-native-disabled-interpreters
;;              "jupyter")
;;              "python"))
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (stq-local python-shell-buffer-name
;;                         (format "Python %s"
;;                             (cadr (reverse (file-name-split (doom-modeline--project-root))))))))

					; Semi-automatic numpy documentation
(use-package numpydoc
  :ensure t
  :after python)

(defun python-shell-send-current-statement ()
  "Send current statement to Python shell.
   Taken from elpy-shell-send-current-statement"
  (interactive)
  (let ((beg (python-nav-beginning-of-statement))
        (end (python-nav-end-of-statement)))
    (python-shell-send-string (buffer-substring beg end)))
  (python-nav-forward-statement))

(defun python-shell-send-region-or-line nil
  "Sends from python-mode buffer to a python shell, intelligently."
  (interactive)
  (cond ((region-active-p)
         (setq deactivate-mark t)
         (python-shell-send-region (region-beginning) (region-end)))
        (t (python-shell-send-current-statement))))

;; (evil-define-key '(normal visual) python-mode-map
;;   ",sr" #'python-shell-send-region-or-line
;;   ",sb" #'python-shell-send-buffer
;;   ",sd" #'python-shell-send-defun
;;   ",se" #'code-cells-eval)
;; (defun add-lsp-before-save-hooks ()
;;   (add-hook 'before-save-hook #'lsp-format-buffer nil 'local)
;;   (add-hook 'before-save-hook #'lsp-organize-imports nil 'local)
;;   )
;; (evil-define-key '(normal visual) python-ts-mode-map
;;   ",sr" #'python-shell-send-region-or-line
;;   ",sb" #'python-shell-send-buffer
;;   ",sd" #'python-shell-send-defun
;;   ",se" #'code-cells-eval)

(defun
    add-lsp-before-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer nil 'local)
  (add-hook 'before-save-hook #'lsp-organize-imports nil 'local)
  )
(add-hook 'lsp-mode-hook #'add-lsp-before-save-hooks)

(defun select-python-interpreter ()
  (if (executable-find "jupyter")
      (setq
    	      python-shell-interpreter "jupyter"
    	      python-shell-interpreter-args "console --simple-prompt")
    (setq
            python-shell-interpreter "python"
            python-shell-interpreter-args "")))
;; Add a hook to adjust the python interpreter. Prefer jupyter if possible.
(add-hook 'lsp-mode-hook #'select-python-interpreter)

(add-to-list 'auto-mode-alist '("\\.env" . shell-script-mode))

(use-package yaml-mode
  :commands (markdown-mode gfm-mode)
  :mode (("\\.yml\\'" . yaml-mode)))

;; This uses Github Flavored Markdown for README files
(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
    ("\\.md\\'" . markdown-mode)
    ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc"))

(use-package rainbow-mode)

(use-package json-mode)
(use-package jq-mode)

(use-package quarto-mode
  :mode (("\\.Rmd" . poly-quarto-mode))
  )

(use-package magit
  :commands (magit-status magit-get-current-branch)
  ;; :config
  ;; (define-key magit-hunk-section-map (kbd "RET") 'magit-diff-visit-file-other-window)
  ;; (delete 'git-commit-mode evil-emacs-state-modes)
  ;; :bind
  ;; (:map evil-normal-state-map
  ;;       (", g g" . 'magit-status))
  :config
  (dir-locals-set-class-variables
   'huge-git-repository
   '((nil
      . ((magit-refresh-buffer . nil)
	 (magit-revision-insert-related-refs . nil)))
     (magit-status-mode
      . ((eval . (magit-disable-section-inserter 'magit-insert-tags-header))
         (eval . (magit-disable-section-inserter 'magit-insert-recent-commits))
         (eval . (magit-disable-section-inserter 'magit-insert-unpushed-to-pushremote))
         (eval . (magit-disable-section-inserter 'magit-insert-unpushed-to-upstream-or-recent))
         (eval . (magit-disable-section-inserter 'magit-insert-unpulled-from-pushremote))
         (eval . (magit-disable-section-inserter 'magit-insert-unpulled-from-pushremote))
         (eval . (magit-disable-section-inserter 'magit-insert-unpulled-from-upstream))
         ))
     ))

  (dir-locals-set-directory-class
   "~/reference-repos/nixpkgs/" 'huge-git-repository))

(defun +magit-display-buffer-fn (buffer)
  "Same as `magit-display-buffer-traditional', except...

      - If opened from a commit window, it will open below it.
      - Magit process windows are always opened in small windows below the current.
      - Everything else will reuse the same window."
  (let ((buffer-mode (buffer-local-value 'major-mode buffer)))
    (display-buffer
     buffer (cond
             ((and (eq buffer-mode 'magit-status-mode)
                   (get-buffer-window buffer))
              '(display-buffer-reuse-window))
             ;; Any magit buffers opened from a commit window should open below
             ;; it. Also open magit process windows below.
             ((or (bound-and-true-p git-commit-mode)
                  (eq buffer-mode 'magit-process-mode))
              (let ((size (if (eq buffer-mode 'magit-process-mode)
                              0.35
                            0.7)))
                `(display-buffer-below-selected
                  . ((window-height . ,(truncate (* (window-height) size)))))))

             ;; Everything else should reuse the current window.
             ((or (not (derived-mode-p 'magit-mode))
                  (not (memq (with-current-buffer buffer major-mode)
                             '(magit-process-mode
                               magit-revision-mode
                               magit-diff-mode
                               magit-stash-mode
                               magit-status-mode))))
              '(display-buffer-same-window))

             ('(+magit--display-buffer-in-direction))))))

(defun +magit--display-buffer-in-direction (buffer alist)
  "`display-buffer-alist' handler that opens BUFFER in a direction.

      This differs from `display-buffer-in-direction' in one way: it will try to use a
      window that already exists in that direction. It will split otherwise."
  (let ((direction (or (alist-get 'direction alist)
                       'right))
        (origin-window (selected-window)))
    (if-let (window (window-in-direction direction))
        (unless magit-display-buffer-noselect
          (select-window window))
      (if-let (window (and (not (one-window-p))
                           (window-in-direction
                            (pcase direction
                              (`right 'left)
                              (`left 'right)
                              ((or `up `above) 'down)
                              ((or `down `below) 'up)))))
          (unless magit-display-buffer-noselect
            (select-window window))
        (let ((window (split-window nil nil direction)))
          (when (and (not magit-display-buffer-noselect)
                     (memq direction '(right down below)))
            (select-window window))
          (display-buffer-record-window 'reuse window buffer)
          (set-window-buffer window buffer)
          (set-window-parameter window 'quit-restore (list 'window 'window origin-window buffer))
          (set-window-prev-buffers window nil))))
    (unless magit-display-buffer-noselect
      (switch-to-buffer buffer t t)
      (selected-window))))

(setq transient-display-buffer-action '(display-buffer-below-selected)
      magit-display-buffer-function #'+magit-display-buffer-fn
      magit-bury-buffer-function #'magit-mode-quit-window)

(use-package git-timemachine
  )

;Track =mv= with git
(setq dired-vc-rename-file t)

(use-package browse-at-remote
  :config
(defun +vc--remote-homepage ()
  (require 'browse-at-remote)
  (or (let ((url (browse-at-remote--remote-ref)))
        (plist-get (browse-at-remote--get-url-from-remote (car url)) :url))
      (user-error "Can't find homepage for current project")))

(defun browse-at-remote--format-region-url-as-codeberg (repo-url location filename &optional linestart lineend)
  "URL formatted for codeberg."
  (cond
   ((and linestart lineend)
    (format "%s/src/%s/%s#L%d-L%d" repo-url location filename linestart lineend))
   (linestart (format "%s/src/%s/%s#L%d" repo-url location filename linestart))
   (t (format "%s/src/%s/%s" repo-url location filename))))

(defun browse-at-remote--format-commit-url-as-codeberg (repo-url commithash)
  "Commit URL formatted for codeberg"
  (format "%s/src/commit/%s" repo-url commithash))


(defvar browse-at-remote-prefer-symbolic)
(defun +vc/browse-at-remote (&optional arg)
  "Open URL to current file (and line if selection is active) in browser.
If prefix ARG, negate the default value of `browse-at-remote-prefer-symbolic'."
  (interactive "P")
  (require 'browse-at-remote)
  (let ((vc-ignore-dir-regexp locate-dominating-stop-dir-regexp)
        (browse-at-remote-prefer-symbolic
         (if arg
             (not browse-at-remote-prefer-symbolic)
           browse-at-remote-prefer-symbolic)))
    (browse-at-remote)))

(defun +vc/browse-at-remote-kill (&optional arg interactive?)
  "Copy URL to current file (and line if selection is active) to clipboard.
If prefix ARG, negate the default value of `browse-at-remote-prefer-symbolic'."
  (interactive (list current-prefix-arg 'interactive))
  (require 'browse-at-remote)
  (let ((vc-ignore-dir-regexp locate-dominating-stop-dir-regexp)
        (browse-at-remote-prefer-symbolic
         (if arg
             (not browse-at-remote-prefer-symbolic)
           browse-at-remote-prefer-symbolic)))
    (browse-at-remote-kill)
    (if interactive? (message "Copied to clipboard"))))

(defun +vc/browse-at-remote-homepage ()
  "Open homepage for current project in browser."
  (interactive)
  (browse-url (+vc--remote-homepage)))

(defun +vc/browse-at-remote-kill-homepage ()
  "Copy homepage URL of current project to clipboard."
  (interactive)
  (let ((url (+vc--remote-homepage)))
    (kill-new url)
    (message "Copied to clipboard: %S" url))))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package dap-mode
  :config
  (setq dap-python-debugger 'debugpy))

(use-package realgud
  :config
  (setq realgud:pdb-command-name "python -m ipdb")
  ;; (setq realgud:pdb-command-name "python -m pdb")
  ;; (setq realgud:pdb-command-name "pytest -s --trace")
  (defun realgud-pdb-pytest nil
    (interactive)
    (realgud:pdb (concat "pytest --trace --color=yes " buffer-file-name)))
  (defun describe-at-cursor()
    "Describe variable at cursor when using debugger"
    (interactive)
    (realgud:cmd-info-value (concat (thing-at-point 'word) "\n")))
  :bind (:map realgud:shortkey-mode-map
    	       ("_" . #'describe-at-cursor)
    	       ("a" . #'realgud:attach-source-buffer))) 


;; (evil-define-key '(normal visual) python-mode-map
;;   ",z"  #'run-python
;;   ",ty" #'realgud:pdb
;;   ",tf" #'realgud-pdb-pytest)
;; (evil-define-key '(normal visual) python-ts-mode-map
;;   ",z"  #'run-python
;;   ",ty" #'realgud:pdb
;;   ",tf" #'realgud-pdb-pytest)

(use-package code-cells
  :config
  (add-hook 'prog-mode-hook 'code-cells-mode-maybe))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package aggressive-indent
  :hook (emacs-lisp-mode-hook . aggressive-indent-mode)
  :config
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode)
  :init
  (global-aggressive-indent-mode 1)
  (add-to-list 'aggressive-indent-excluded-modes 'python-ts-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'nix-mode)
  )

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package elfeed)

(use-package elfeed-org
    :after elfeed
    :init
    (elfeed-org)
    :config
    (setq rmh-elfeed-org-files (list (concat org-directory "personal/rss/elfeed.org"))))

    

    ;; (after! elfeed
    ;;   (setq elfeed-search-filter "@2-weeks-ago +unread")
    ;;   (add-hook 'elfeed-search-mode-hook #'elfeed-update)
(defun elfeed-entry-other-window ()
  "In elfeed-search mode, open elfeed entry in the other window
if other window is present, else sensibly splits the frame if
there is only a single window and opens the elfeed entry in the
other window."

  (interactive)
  (if (get-buffer "*elfeed-search*")
      (progn
	(split-window-sensibly (selected-window))
	(switch-to-buffer-other-window "*elfeed-search*")
	(call-interactively #'elfeed-search-show-entry)
	(other-window 1)
	(forward-line))
    (message "Start elfeed first!")))

    (defun find-in-elfeed-org-file ()
      "Find elfeed-show-entry in the first elfeed-org file"
          (interactive)
          (let* ((elfeed-show-entry-id (car (elfeed-entry-id elfeed-show-entry)))
                (elfeed-default-org-file (car rmh-elfeed-org-files))
                (elfeed-window (get-buffer-window (file-name-nondirectory elfeed-default-org-file))))

           (if (not elfeed-window) ; Open elfeed org file if not visible
             (progn
               (select-window (get-buffer-window "*elfeed-search*"))
               (let ((w (split-window-below)))
                 (select-window w)
                 (find-file elfeed-default-org-file)))
             (select-window elfeed-window))

           (or ;; Search pattern forward and backward
            (or (search-forward elfeed-show-entry-id nil t)
                   (search-backward elfeed-show-entry-id nil t))
              (message
               (concat elfeed-show-entry-id " not found in elfeed-org file " elfeed-default-org-file)))))

    (defun elfeed-eww-about ()
      "Open about page of elfeed entry in eww."
      (interactive)
      (eww-browse-url (concat "https://" (car (elfeed-entry-id elfeed-show-entry)) "/about")))

      (setq elfeed-goodies/entry-pane-size 0.6)
      (setq elfeed-goodies/log-window-size 0.4)

    ;; (after! elfeed
    ;;  (setq elfeed-score-serde-score-file (substitute-in-file-name "$HOME/.doom.d/elfeed.score")))

(use-package elfeed-web)

(use-package notmuch
            :ensure t
            :config
    	(setq sendmail-program "gmi")
          (setq message-sendmail-extra-arguments '("send" "--quiet" "-t" "-C" "~/.mail/broad.email"))
  ;; Optional: Don't save outgoing mail locally.
  (setq notmuch-fcc-dirs nil))
          ;; (setq message-sendmail-extra-arguments '("send" "--quiet" "-t" "-C" "~/.mail/broad.email"))
;; (add-hook 'message-send-hook (lambda ()
;; 				 (let (from (message-fetch-field "from"))
;; 				   (if (string= from "\"Alán F. Muñoz\" <afer.mg@gmail.com>")
;; 				       (setq message-sendmail-extra-arguments '("send" "--quiet" "-t" "-C" "~/.mail/afer.mail"))
;; 				     (setq message-sendmail-extra-arguments '("send" "--quiet" "-t" "-C" "~/.mail/broad.email"))))))

(use-package blimp
  :hook (image-mode-hook . blimp-mode))

(use-package empv
  :bind-keymap ("C-x m" . empv-map))

;; Gives me a fancy list of commands I run
(use-package command-log-mode)
(setq global-command-log-mode t)

;; Gives me a fancy list of commands I run
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package helpful
;    :custom
      ;; Remap Counsel help functions
;      (counsel-describe-function-function #'helpful-callable)
;      (counsel-describe-variable-function #'helpful-variable)
    :bind
      ;; Remap default help functions
      ([remap describe-function] . helpful-function)
      ([remap describe-symbol] . helpful-symbol)
      ([remap describe-variable] . helpful-variable)
      ([remap describe-command] . helpful-command)
      ([remap describe-key] . helpful-key))

;; Configure Tempel
(use-package tempel
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")

  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert))

  :init
  (setq tempel-path (concat config-dir "templates"))

  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
(use-package tempel-collection)

(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode)
  :config
  ;; Enable auto completion and configure quitting
  (setq corfu-auto t
  corfu-quit-no-match 'separator)) ;; or t

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  ;; (setq completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  (setq text-mode-ispell-word-completion nil)

  ;; Emacs 28 and newer: Hide commands in M-x which do not apply to the current
  ;; mode.  Corfu commands are hidden, since they are not used via M-x. This
  ;; setting is useful beyond Corfu.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

(defun arrayify (start end quote)
  "Turn strings on newlines into a QUOTEd, comma-separated one-liner."
  (interactive "r\nMQuote: ")
  (let ((insertion
         (mapconcat
          (lambda (x) (format "%s%s%s" quote x quote))
          (split-string (buffer-substring start end)) ", ")))
    (delete-region start end)
    (insert insertion)))

(use-package ellama
  :init
  ;; setup key bindings
  (setopt ellama-keymap-prefix "C-c e")
  ;; language you want ellama to translate to
  (setopt ellama-language "english")
  ;; could be llm-openai for example
  (setopt ellama-auto-scroll t)
  (require 'llm-ollama)
  ;; Predefined llm providers for interactive switching.
  ;; You shouldn't add ollama providers here - it can be selected interactively
  ;; without it. It is just example.
  (setopt ellama-providers
	  '(("zephyr7b" . (make-llm-ollama
			 :chat-model "zephyr:7b-beta-q6_K"
			 :embedding-model "zephyr:7b-beta-q6_K"))
	    ("llama8b" . (make-llm-ollama
			  :chat-model "llama3:8b-instruct-q8_0"
			  :embedding-model "nomic-embed-text"))
	    ("llama70b_remote" . (make-llm-ollama
			 :port 11435
			 :chat-model "llama3.1:70b"
			 :embedding-model "llama3:70b"))
	    ("llama70b" . (make-llm-ollama
			 :chat-model "llama3.1:70b"
			 :embedding-model "llama3:70b"))
	    ("mistral" . (make-llm-ollama
			  :chat-model "mistral:7b-instruct-v0.2-q6_K"
			  :embedding-model "mistral:7b-instruct-v0.2-q6_K"))
	    ("mixtral" . (make-llm-ollama
			  :chat-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k"
			  :embedding-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k"))))
  ;; Default provider
  (setopt ellama-provider
	  (apply #'funcall (cdr (assoc (if (system-is-linux) "llama70b" "llama70b_remote") ellama-providers))))
  ;; Translation llm provider
  (setopt ellama-translation-provider (make-llm-ollama
				       :chat-model "phi3:14b-medium-128k-instruct-q6_K"
				       :embedding-model "nomic-embed-text")))
(setopt ellama-naming-scheme 'ellama-generate-name-by-llm)

(use-package whisper
    :ensure t
    :straight (:host github :repo "natrys/whisper.el"
                     :branch "master")
    :config
(setq 
 
     ;; whisper-model "base"
     whisper-use-threads (/ (num-processors) 2)
     whisper-install-whispercpp nil)

    (defun get-model-path (model-type)
      (let* (
  	   (url (format "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-%s.bin?download=true" model-type))
  	   (models-dir (concat whisper-install-directory "whisper.cpp/models/"))
  	   (model-path (concat models-dir (format "gmml_%s.bin" model-type))))
        (unless (file-exists-p models-dir) (mkdir models-dir t))
        (unless (file-exists-p model-path)
  	(url-copy-file url model-path t))
        model-path)))

  (defun whisper-command (input-file)
    "Produces whisper.cpp command to be run on the INPUT-FILE."
    `("whisper-cpp"
      ,@(when whisper-use-threads (list "--threads" (number-to-string whisper-use-threads)))
      ;; ,@(when whisper-enable-speed-up '("--speed-up"))
      ,@(when whisper-translate '("--translate"))
      ,@(when whisper-show-progress-in-mode-line '("--print-progress"))
      "--language" ,whisper-language
      "--model" ,(get-model-path "large-v3-q5_0")
      "--no-timestamps"
      "--file" ,input-file))

(defun rk/get-ffmpeg-device ()
  "Gets the list of devices available to ffmpeg.
The output of the ffmpeg command is pretty messy, e.g.
  [AVFoundation indev @ 0x7f867f004580] AVFoundation video devices:
  [AVFoundation indev @ 0x7f867f004580] [0] FaceTime HD Camera (Built-in)
  [AVFoundation indev @ 0x7f867f004580] AVFoundation audio devices:
  [AVFoundation indev @ 0x7f867f004580] [0] Cam Link 4K
  [AVFoundation indev @ 0x7f867f004580] [1] MacBook Pro Microphone
so we need to parse it to get the list of devices.
The return value contains two lists, one for video devices and one for audio devices.
Each list contains a list of cons cells, where the car is the device number and the cdr is the device name."
  (unless (string-equal system-type "darwin")
    (error "This function is currently only supported on macOS"))

  (let ((lines (string-split (shell-command-to-string "ffmpeg -list_devices true -f avfoundation -i dummy || true") "\n")))
    (cl-loop with at-video-devices = nil
             with at-audio-devices = nil
             with video-devices = nil
             with audio-devices = nil
             for line in lines
             when (string-match "AVFoundation video devices:" line)
             do (setq at-video-devices t
                      at-audio-devices nil)
             when (string-match "AVFoundation audio devices:" line)
             do (setq at-audio-devices t
                      at-video-devices nil)
             when (and at-video-devices
                       (string-match "\\[\\([0-9]+\\)\\] \\(.+\\)" line))
             do (push (cons (string-to-number (match-string 1 line)) (match-string 2 line)) video-devices)
             when (and at-audio-devices
                       (string-match "\\[\\([0-9]+\\)\\] \\(.+\\)" line))
             do (push (cons (string-to-number (match-string 1 line)) (match-string 2 line)) audio-devices)
             finally return (list (nreverse video-devices) (nreverse audio-devices)))))

(defun rk/find-device-matching (string type)
  "Get the devices from `rk/get-ffmpeg-device' and look for a device
matching `STRING'. `TYPE' can be :video or :audio."
  (let* ((devices (rk/get-ffmpeg-device))
         (device-list (if (eq type :video)
                          (car devices)
                        (cadr devices))))
    (cl-loop for device in device-list
             when (string-match-p string (cdr device))
             return (car device))))

(defcustom rk/default-audio-device nil
  "The default audio device to use for whisper.el and outher audio processes."
  :type 'string)

(defun rk/select-default-audio-device (&optional device-name)
  "Interactively select an audio device to use for whisper.el and other audio processes.
If `DEVICE-NAME' is provided, it will be used instead of prompting the user."
  (interactive)
  (let* ((audio-devices (cadr (rk/get-ffmpeg-device)))
         (indexes (mapcar #'car audio-devices))
         (names (mapcar #'cdr audio-devices))
         (name (or device-name (completing-read "Select audio device: " names nil t))))
    (setq rk/default-audio-device (rk/find-device-matching name :audio))
    (when (boundp 'whisper--ffmpeg-input-device)
      (setq whisper--ffmpeg-input-device (format ":%s" rk/default-audio-device)))))

(defun build-piper-model-url (model-name model-file-p)
  "Generates the url from which to download models. Covers only high-quality models"
  (let ((english-type (if (string-equal model-name "cori") "GB" "US")))
    (format "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_%s/%s/high/en_%s-%s-high.onnx%s?download=true"
	    english-type model-name english-type model-name (if model-file-p "" ".json"))))

(defun get-piper-model-path (new-model-name)
  "Returns the location of the piper model. Downloads both model and parameters if missing. The location is determined by =piper-cache-dir=.
Models tested: cori, lessac, libritts, ljspeech and ryan models."
  (unless (file-exists-p piper-cache-dir)
    (mkdir piper-cache-dir t))

  (let ((new-model-path (concat piper-cache-dir new-model-name ".onnx")))
    (if (and (file-exists-p new-model-path) (file-exists-p (concat new-model-path ".json")))
	new-model-path
      (dolist (model-file-p '(nil t) result) ; returns the new-model-path of the last element
  	(setq result (let ((new-model-path (concat new-model-path (unless model-file-p ".json"))))
    		       (url-copy-file (build-piper-model-url new-model-name model-file-p) new-model-path t)
    		       new-model-path))))))

(defvar piper-binary-path "piper")
(defvar piper-default-model-name "cori")
(defvar piper-cache-dir "~/.piper_models/")

(setq tts-playback-command (if (system-is-mac) "play" "aplay"))
(setq tts-playback-parameters (if (system-is-mac) "-q -t wav -" "-r 22050 -f S16_LE -t raw -"))
(defun tts-piper (&optional arg)

  "Send the text after point or the given TEXT to piper for tts.
                  If a region is active, send the marked text. If TEXT is provided, that text is used.
                  If a non-numeric prefix argument is provided, prompt for text input.
                  If a numeric prefix argument is provided, send the number of lines.
                  Also filter the special chars that break the tts."
  (interactive "P")
  (let* ((text (cond
                ((region-active-p) (buffer-substring-no-properties (region-beginning) (region-end)))
                ((consp arg) (read-string "Enter text: "))
                (arg (buffer-substring-no-properties (point) (save-excursion (forward-line arg) (point))))
                (t (buffer-substring-no-properties (point) (point-max))))))
    (run-piper text)))

(defun run-piper (text &optional piper-model-name)
  (let ((piper-model-name (unless piper-model-name piper-default-model-name)))
    (start-process "piper" "*piper*" "sh" "-c"
                   (format "echo '%s' | %s --model %s -f - | %s %s " ; escape text
    			   (replace-regexp-in-string  "\n" " " (replace-regexp-in-string "\\([a-z]\\)'\\([a-z]\\)" "\\1 \\2" text)) 
    			   piper-binary-path
    			   (get-piper-model-path piper-model-name)
    			   tts-playback-command
                           tts-playback-parameters))))

(defun kill-piper ()
  "Silence the voice quickly."
  (interactive)
  (kill-buffer "*piper*"))

(if (system-is-linux)
    (straight-use-package '(el-patch :type git :host github :repo "tecosaur/screenshot"))
(use-package org-download
  :after org
  :defer nil
  :custom
  (org-download-method 'directory)
  (org-download-image-dir "images")
  (org-download-heading-lvl nil)
  (org-download-timestamp "%Y%m%d-%H%M%S_")
  (org-image-actual-width 300)
  (org-download-screenshot-method "/opt/homebrew/bin/pngpaste %s")
  :bind
  ("C-M-y" . org-download-screenshot)
  :config
  (require 'org-download)) )

(use-package hyperbole
  :ensure t
  :config
  (hyperbole-mode)
;;   :bind (:map evil-normal-state-map 
;; ("M-RET" . 'action-key))
  )
