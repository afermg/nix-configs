;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
                                        ;(unpin! pinned-package)
;; ...or multiple packages
                                        ;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
                                        ;(unpin! t)


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
                                        ;(package! some-package)

;; To install a package directly from a particular repo, you'll need to specify
;; a `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
                                        ;(package! another-package
                                        ;  :recipe (:host github :repo "username/repo"))
;;; (package! minimap)
;;; (package! column-marker)
(package! affe) ; fzf-like https://github.com/minad/affe
(package! beacon)

;; ox-hugo related
(package! ox-hugo)
;; for org-cite
(package! citar)
(package! citeproc-org)
(package! conventional-commit
  :recipe
  (:host github
   :repo "akirak/conventional-commit.el"))


;; (package! edraw :recipe ; draw in emacs
                                        ;   (:host github
                                        ;    :repo "misohena/el-easydraw"))
(package! pdf-tools :built-in 'prefer)
;; (package! pdf-tools :recipe             ; Necessary for image-roll
;;   (:host github
;;    :repo "dalanicolai/pdf-tools"
;;    :branch "pdf-roll"
;;    :files ("lisp/*.el"
;;            "README"
;;            ("build" "Makefile")
;;            ("build" "server")
;;            (:exclude "lisp/tablist.el" "lisp/tablist-filter.el"))))
;; (package! image-roll :recipe            ; Continuous scrolling in pdf-view
;;   (:host github
;;    :repo "dalanicolai/image-roll.el"))
(package! blimp)                ; Imagemagick wrapper
(package! code-cells)                ; Support cells-based navigation and REPL
(package! dired-du)                  ; Show real recursive sizes in dired
(package! elfeed-tube) ; elfeed for youtube

;; (package! hnreader)
(package! elfeed-web); Web server
;; (package! evil-owl)                     ; see registers in popup window (Phasing out in favour of SPC i r)
(package! fzf) ; fuzzy finder
;; (package! elfeed-score)
;; (package! highlight)
;; (package! hnreader)
(package! gnuplot)
(package! gnuplot-mode)
(package! impatient-mode) ; render markdown as html
(package! kkp)

(package! langtool)                     ; Grammar correction
(package! ob-mermaid)
(package! mpv)                          ; video player
(package! numpydoc)
;; (package! org-chef)
(package! org-contrib)
(package! org-roam-ui)
(package! orgtbl-aggregate)
(package! ox-gfm)
(package! exec-path-from-shell)
;; (package! phscroll
;;   :recipe
;;   (:host github
;;    :repo "misohena/phscroll"))
(package! quarto-mode)
(package! realgud)
;; (package! org-present)
;; (package! s3ed)                         ; primitive exploration of s3 buckets
;; (package! scad-mode)                    ; proper linting for .scad files
;; (package! sly-quicklisp)
;; (package! synosaurus)                   ;synonyms
(package! transpose-frame)              ; Toggle vertical and horizontal splits
(package! unfill)
;; (package! zotra)                        ; experimental

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;;(package! this-package
                                        ;  :recipe (:host github :repo "username/repo"
                                        ;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, for whatever reason,
;; you can do so here with the `:disable' property:
;;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;;(package! builtin-package :recipe (:nonrecursive t))
;;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;;(package! builtin-package :recipe (:branch "develop"))
