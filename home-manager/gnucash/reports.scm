;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options for saved report "Assets Over Time", based on template "e9cf815f79db44bcb637d0295093ae3d"
(let ()
  (define (options-gen)
    (let
         (
           (options (gnc:report-template-new-options/report-guid "e9cf815f79db44bcb637d0295093ae3d" "Assets Over Time"))
           (new-embedded-report-ids '()) ;; only used with Multicolumn View Reports
         )
; Section: Accounts

(let ((option (gnc:lookup-option options
                                 "Accounts"
                                 "Accounts")))
  ((lambda (o) (if o (gnc:option-set-value o '("a3838fcd56044eeeb33fd91d540d47c9" "b5d12e84aa6c4fb2bf221b90a87073fa" "acd7c6c25b0246b0bf29d0c856e0f9f8" "33153f67488c4c6ab857ca51a2443620" "43f2ba50ca254530aa6020e90f58e1fc" "175e236ffb0b4cc68d2aa1ee779eb074" "3c67a6b674bb49e6af44e7c732c90329" "a6c51fbb37e545f99ef74071f1d16f5c" "b2a46e36533946af9e5e4748c241368d" "d5ac94d96c42427b800026a3d6dfdb34" "89070953b8e2419faac6f59eb9078084" "c39079d942284d9e9c3b5c8e6ddd1c9c" "8226bfbf14284630994848c25c406dd8" "220b207a30d24c0bbb64c0ed16cbaff5" "014eb0abe46d42ba821046b9e6241b59" "7229149deb6a4c45a92a5afb79f52d93" "1bfe57c7e04b43529707b8df10e68c3a" "7e5868f9891e4de48dddd7559c4012ce" "4fa1cdc8a48b4e9ea20e34f7df35fb07" "6387825cb9054667a7c8c542306eae1d" "ef8e8dc50cf14d1faf01b86904b88238" "4e1c6e5fd8e64df492115223bc832f0a" "53859ae5d8d24145bb91c92da8e02763" "a42c1b965b80463a97684ffff181be16" "23481bec9b31448ca930cccf5ffa9c11" "8a640795d0cb478dbf86002b659b69a3" "8d3c142fb7814446a920215da38b5e80" "fc13f4380eb04c34a3b2531675ce1ea7" "4509743c2fb14ffb85b46f212b641aef" "09bf4d589d88402896f5b5a7c8614791" "54312853aede4634a8bd2309a3a10d98" "1f047056c88247818bdbe7d0a863c335" "d7cfde6043ad40b68f99d1c465178b27" "3a4e0570af3943e79669cff97789de3b" "29a14b1e26474b84b91196d33c81aec7" "a0dd16aaa8c44957bbd40dd849bc0973" "dd5776c118724863a7ce019fd4b08b3d")))) option))

(let ((option (gnc:lookup-option options
                                 "Accounts"
                                 "Levels of Subaccounts")))
  ((lambda (o) (if o (gnc:option-set-value o '3))) option))


; Section: Display

(let ((option (gnc:lookup-option options
                                 "Display"
                                 "Maximum Bars")))
  ((lambda (o) (if o (gnc:option-set-value o '10.0))) option))

(let ((option (gnc:lookup-option options
                                 "Display"
                                 "Show table")))
  ((lambda (o) (if o (gnc:option-set-value o #t))) option))


; Section: General

(let ((option (gnc:lookup-option options
                                 "General"
                                 "Start Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(absolute . 1567335540)))) option))

(let ((option (gnc:lookup-option options
                                 "General"
                                 "End Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(relative . end-prev-month)))) option))


      options
    )
  )
  (gnc:define-report 
    'version 1
    'name "Assets Over Time"
    'report-guid "90abc3427cd2498b9a197873dec58d11"
    'parent-type "e9cf815f79db44bcb637d0295093ae3d"
    'options-generator options-gen
    'menu-path (list gnc:menuname-custom)
    'renderer (gnc:report-template-renderer/report-guid "e9cf815f79db44bcb637d0295093ae3d" "Assets Over Time")
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options for saved report "last-month-expenses-pie-chart", based on template "9bf1892805cb4336be6320fe48ce5446"
(let ()
  (define (options-gen)
    (let
         (
           (options (gnc:report-template-new-options/report-guid "9bf1892805cb4336be6320fe48ce5446" "Expense Accounts"))
           (new-embedded-report-ids '()) ;; only used with Multicolumn View Reports
         )
; Section: Accounts

(let ((option (gnc:lookup-option options
                                 "Accounts"
                                 "Levels of Subaccounts")))
  ((lambda (o) (if o (gnc:option-set-value o 'all))) option))


; Section: Display

(let ((option (gnc:lookup-option options
                                 "Display"
                                 "Maximum Slices")))
  ((lambda (o) (if o (gnc:option-set-value o '15.0))) option))


; Section: General

(let ((option (gnc:lookup-option options
                                 "General"
                                 "Start Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(relative . start-prev-month)))) option))

(let ((option (gnc:lookup-option options
                                 "General"
                                 "End Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(relative . end-prev-month)))) option))


      options
    )
  )
  (gnc:define-report 
    'version 1
    'name "last-month-expenses-pie-chart"
    'report-guid "700193f08bb24dbb8994309e0f81dc2a"
    'parent-type "9bf1892805cb4336be6320fe48ce5446"
    'options-generator options-gen
    'menu-path (list gnc:menuname-custom)
    'renderer (gnc:report-template-renderer/report-guid "9bf1892805cb4336be6320fe48ce5446" "Expense Accounts")
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options for saved report "tmp-public-transport", based on template "2e22929e5c5b4b769f615a815ef0c20f"
(let ()
  (define (options-gen)
    (let
         (
           (options (gnc:report-template-new-options/report-guid "2e22929e5c5b4b769f615a815ef0c20f" "General Ledger"))
           (new-embedded-report-ids '()) ;; only used with Multicolumn View Reports
         )
; Section: Accounts

(let ((option (gnc:lookup-option options
                                 "Accounts"
                                 "Accounts")))
  ((lambda (o) (if o (gnc:option-set-value o '("b600a5d2cb1e4f9982bdaaf5aa68878c")))) option))


; Section: Currency


; Section: Display


; Section: Filter

(let ((option (gnc:lookup-option options
                                 "Filter"
                                 "Use regular expressions for transaction filter")))
  ((lambda (o) (if o (gnc:option-set-value o #t))) option))

(let ((option (gnc:lookup-option options
                                 "Filter"
                                 "Transaction Filter excludes matched strings")))
  ((lambda (o) (if o (gnc:option-set-value o #t))) option))


; Section: General

(let ((option (gnc:lookup-option options
                                 "General"
                                 "Start Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(relative . start-prev-year)))) option))

(let ((option (gnc:lookup-option options
                                 "General"
                                 "End Date")))
  ((lambda (o) (if o (gnc:option-set-value o '(relative . end-prev-year)))) option))

(let ((option (gnc:lookup-option options
                                 "General"
                                 "Add options summary")))
  ((lambda (o) (if o (gnc:option-set-value o 'always))) option))


; Section: Sorting


; Section: __trep


      options
    )
  )
  (gnc:define-report 
    'version 1
    'name "tmp-public-transport"
    'report-guid "ff4a2cece323447db70b0ef3179b35d3"
    'parent-type "2e22929e5c5b4b769f615a815ef0c20f"
    'options-generator options-gen
    'menu-path (list gnc:menuname-custom)
    'renderer (gnc:report-template-renderer/report-guid "2e22929e5c5b4b769f615a815ef0c20f" "General Ledger")
  )
)

