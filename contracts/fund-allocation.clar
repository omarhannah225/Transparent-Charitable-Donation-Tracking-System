;; Fund Allocation Contract
;; Manages distribution of donations to specific projects

(define-map projects
  { project-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 256),
    allocated-funds: uint,
    status: (string-ascii 20)
  }
)

(define-map allocations
  { allocation-id: uint }
  {
    project-id: uint,
    amount: uint,
    allocation-date: uint
  }
)

(define-data-var project-nonce uint u0)
(define-data-var allocation-nonce uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-allocation (allocation-id uint))
  (map-get? allocations { allocation-id: allocation-id })
)

(define-public (create-project (name (string-ascii 50)) (description (string-ascii 256)))
  (let
    (
      (new-project-id (+ (var-get project-nonce) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set project-nonce new-project-id)
    (ok (map-set projects
      { project-id: new-project-id }
      {
        name: name,
        description: description,
        allocated-funds: u0,
        status: "active"
      }
    ))
  )
)

(define-public (allocate-funds (project-id uint) (amount uint))
  (let
    (
      (project (unwrap! (get-project project-id) (err u404)))
      (new-allocation-id (+ (var-get allocation-nonce) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set allocation-nonce new-allocation-id)
    (map-set projects
      { project-id: project-id }
      (merge project { allocated-funds: (+ (get allocated-funds project) amount) })
    )
    (ok (map-set allocations
      { allocation-id: new-allocation-id }
      {
        project-id: project-id,
        amount: amount,
        allocation-date: block-height
      }
    ))
  )
)

