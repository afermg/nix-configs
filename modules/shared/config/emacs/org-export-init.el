(use-package org-contrib
:config
(require 'ox-extra)
(ox-extras-activate '(ignore-headlines)))

(use-package ox-pandoc
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

(use-package ox-hugo
  :ensure t   ;Auto-install the package from Melpa
  :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
  :after org
  )

(defun org/parse-headings (backend)
  (if (member backend '(latex))
      (org-map-entries
       (lambda ()
         (progn
           (insert-string "#+LATEX: \\newpage")))

       "+newpage")))

(add-hook 'org-export-before-parsing-hook 'org/parse-headings)

(setq org-latex-default-class "extarticle")

(setq org-latex-prefer-user-labels t
         org-latex-caption-above nil
         ;; org-latex-listings 'minted
         org-latex-listings nil
         )


   ;;Colours
(add-to-list 'org-latex-packages-alist '("" "minted" nil))
(setq org-latex-minted-options nil)
      ;; '(
      ;; 				 ("frame" "leftline")
      ;; 				 ("lineos" "true")
      ;; 				 ))
(setq org-latex-src-block-backend 'minted)
 ;; (add-to-list 'org-latex-packages-alist '("" "minted"))
 ;(add-to-list 'org-latex-packages-alist '("" "tabularx"))
 ;(plist-put org-format-latex-options :scale 1.75        )
 ;(add-to-list 'org-latex-packages-alist '("" "unicode-math")))
  (add-to-list 'org-latex-classes
        '("beamerposter"
          "\\documentclass[final]{beamer}
          \\usepackage[T1]{fontenc}
          \\usepackage{lmodern}
          \\usepackage[size=custom,width=84.1,height=118.9,scale=1.0]{beamerposter}
          \\usepackage{graphicx}
          \\usepackage{booktabs}
          \\usepackage{tikz}
          \\usepackage{pgfplots}
          \\pgfplotsset{compat=1.18}
          \\usepackage{anyfontsize}
          [NO-DEFAULT-PACKAGES]"))
(add-to-list 'org-latex-classes
        '("extarticle"
                "\\documentclass{extarticle}"
                ("\\section{%s}" . "\\section*{%s}")
                ("\\subsection{%s}" . "\\subsection*{%s}")
                ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
(add-to-list 'org-latex-classes
        '("article-minimal"
                "\\documentclass{article}
                 [NO-DEFAULT-PACKAGES]"
                ("\\section{%s}" . "\\subsection*{%s}")
                ("\\subsection{%s}" . "\\subsubsection*{%s}")
                ("\\subsubsection{%s}" . "\\subsubsubsection*{%s}")))

(setq org-latex-compiler "xelatex")

;; Custom latex->PDF conversion
  ;; (setq org-latex-pdf-process
  ;;       '("latexmk -pdflatex='pdflatex -interaction nonstopmode' -shell-escape -pdf -bibtex --synctex=1 -f %f"))
  ;; (setq org-latex-pdf-process
  ;;       '("latexmk -pdflatex='lualatex -interaction nonstopmode' -shell-escape -pdf -bibtex --synctex=1 -f %f"))
  (setq latex-run-command "xelatex")
  (setq org-latex-pdf-process
        '("latexmk -pdflatex='xelatex -shell-escape -interaction nonstopmode ' -shell-escape -pdf -f %f "
          ;; "makeglossaries %
          ;; "biber %b"
          ;; "makeindex %b"
          "latexmk -pdflatex='xelatex -interaction -shell-escape nonstopmode ' -shell-escape -pdf -f %f "
          "latexmk -pdflatex='xelatex -shell-escape -interaction nonstopmode ' -shell-escape -pdf -f %f "))
