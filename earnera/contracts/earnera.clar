;; Automated Royalty Distribution Smart Contract

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-WORK (err u101))
(define-constant ERR-INVALID-STAKEHOLDER (err u102))
(define-constant ERR-INVALID-SHARE (err u103))
(define-constant ERR-SHARES-EXCEED-100 (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))
(define-constant ERR-TRANSFER-FAILED (err u106))

;; Data Maps
(define-map creative-projects uint 
  { 
    originator: principal,
    project-name: (string-ascii 100),
    commission-rate: uint,
    accumulated-revenue: uint,
    participant-count: uint
  }
)

(define-map project-participants 
  { project-id: uint, participant: principal } 
  { allocation: uint }
)

(define-map revenue-balances principal uint)

;; Contract Variables
(define-data-var project-counter uint u0)
(define-data-var contract-administrator principal tx-sender)

;; Read-only functions
(define-read-only (get-project-details (project-id uint))
  (map-get? creative-projects project-id)
)

(define-read-only (get-participant-allocation (project-id uint) (participant principal))
  (map-get? project-participants { project-id: project-id, participant: participant })
)

(define-read-only (get-revenue-balance (user-account principal))
  (default-to u0 (map-get? revenue-balances user-account))
)

;; Public functions
(define-public (register-project (project-name (string-ascii 100)) (commission-rate uint))
  (let 
    (
      (project-id (var-get project-counter))
    )
    (asserts! (< commission-rate u101) (err ERR-INVALID-SHARE))
    (map-set creative-projects project-id
      {
        originator: tx-sender,
        project-name: project-name,
        commission-rate: commission-rate,
        accumulated-revenue: u0,
        participant-count: u1
      }
    )
    ;; Set originator as initial participant
    (map-set project-participants 
      { project-id: project-id, participant: tx-sender }
      { allocation: u100 }
    )
    (var-set project-counter (+ project-id u1))
    (ok project-id)
  )
)

(define-public (add-participant (project-id uint) (participant principal) (allocation uint))
  (let
    (
      (current-project (unwrap! (map-get? creative-projects project-id) (err ERR-INVALID-WORK)))
      (originator-allocation (unwrap! (get-participant-allocation project-id (get originator current-project)) (err ERR-INVALID-WORK)))
    )
    (asserts! (is-eq (get originator current-project) tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (< allocation u101) (err ERR-INVALID-SHARE))
    (asserts! (>= (get allocation originator-allocation) allocation) (err ERR-SHARES-EXCEED-100))
    
    ;; Update originator's allocation
    (map-set project-participants 
      { project-id: project-id, participant: (get originator current-project) }
      { allocation: (- (get allocation originator-allocation) allocation) }
    )
    
    ;; Add new participant
    (map-set project-participants 
      { project-id: project-id, participant: participant }
      { allocation: allocation }
    )
    
    ;; Update project participant count
    (map-set creative-projects project-id
      (merge current-project { participant-count: (+ (get participant-count current-project) u1) })
    )
    
    (ok true)
  )
)

(define-public (distribute-commission (project-id uint) (total-amount uint))
  (let
    (
      (current-project (unwrap! (map-get? creative-projects project-id) (err ERR-INVALID-WORK)))
      (commission-amount (/ (* total-amount (get commission-rate current-project)) u100))
    )
    (asserts! (>= (stx-get-balance tx-sender) commission-amount) (err ERR-INSUFFICIENT-FUNDS))
    
    ;; Transfer commission to contract
    (match (stx-transfer? commission-amount tx-sender (as-contract tx-sender))
      transfer-success
        (begin
          ;; Update project accumulated revenue
          (map-set creative-projects project-id
            (merge current-project { accumulated-revenue: (+ (get accumulated-revenue current-project) commission-amount) })
          )
          
          ;; Distribute to participants
          (match (distribute-allocation project-id (get originator current-project) commission-amount)
            allocation-success (ok commission-amount)
            allocation-error (err ERR-TRANSFER-FAILED)
          )
        )
      transfer-error (err ERR-TRANSFER-FAILED)
    )
  )
)

(define-public (withdraw-revenue)
  (let
    (
      (user-revenue (get-revenue-balance tx-sender))
    )
    (asserts! (> user-revenue u0) (err ERR-INSUFFICIENT-FUNDS))
    (map-set revenue-balances tx-sender u0)
    (match (as-contract (stx-transfer? user-revenue (as-contract tx-sender) tx-sender))
      withdrawal-success (ok user-revenue)
      withdrawal-error (err ERR-TRANSFER-FAILED)
    )
  )
)

;; Private functions
(define-private (distribute-allocation (project-id uint) (participant principal) (total-amount uint))
  (let
    (
      (participant-stake (unwrap! (get-participant-allocation project-id participant) (err ERR-INVALID-STAKEHOLDER)))
      (allocation-amount (/ (* total-amount (get allocation participant-stake)) u100))
    )
    (map-set revenue-balances 
      participant
      (+ (get-revenue-balance participant) allocation-amount)
    )
    (ok true)
  )
)

;; Initialize contract
(begin
  (var-set project-counter u0)
  (var-set contract-administrator tx-sender)
)