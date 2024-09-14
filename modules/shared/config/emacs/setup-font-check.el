;; Font Check -- setup-font-check.el   
(defvar font-iosevka-p nil
  "If non-nil, Iosevka font is available on the system. This font is required
for emoji and other Unicode 6+ display.")    

(when (find-font (font-spec :name "Iosevka"))
  ;; Manually choose a fallback font for Unicode
  ;; http://endlessparentheses.com/manually-choose-a-fallback-font-for-unicode.html
  (set-fontset-font "fontset-default" nil (font-spec :size 20 :name "Iosevka"))
  (setq font-iosevka-p t))

(provide 'setup-font-check)
