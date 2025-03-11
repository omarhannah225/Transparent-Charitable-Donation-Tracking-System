;; Donation Receipt Contract
;; Records incoming contributions

(define-map donations
  { donation-id: uint }
  {
    donor: principal,
    amount: uint,
    donation-date: uint,
    earmark: (optional (string-ascii 50))
  }
)

(define-data-var donation-nonce uint u0)
(define-data-var total-donations uint u0)

(define-read-only (get-donation (donation-id uint))
  (map-get? donations { donation-id: donation-id })
)

(define-public (make-donation (amount uint) (earmark (optional (string-ascii 50))))
  (let
    (
      (new-donation-id (+ (var-get donation-nonce) u1))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set donation-nonce new-donation-id)
    (var-set total-donations (+ (var-get total-donations) amount))
    (ok (map-set donations
      { donation-id: new-donation-id }
      {
        donor: tx-sender,
        amount: amount,
        donation-date: block-height,
        earmark: earmark
      }
    ))
  )
)

(define-read-only (get-total-donations)
  (var-get total-donations)
)

