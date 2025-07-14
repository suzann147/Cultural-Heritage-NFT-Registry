(define-non-fungible-token heritage-nft uint)

(define-data-var contract-owner principal tx-sender)
(define-data-var token-id-nonce uint u0)

(define-map heritage-items
  uint 
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    origin: (string-ascii 100),
    cultural-significance: (string-utf8 300),
    date-created: uint,
    heritage-type: (string-ascii 50),
    creator: principal,
    verified: bool
  }
)

(define-map provenance-history
  uint
  (list 50 {owner: principal, timestamp: uint, transaction-type: (string-ascii 20)})
)

(define-map authorized-verifiers principal bool)

(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-INPUT (err u104))
(define-constant ERR-TRANSFER-FAILED (err u105))

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

(define-read-only (get-last-token-id)
  (var-get token-id-nonce)
)

(define-read-only (get-heritage-item (token-id uint))
  (map-get? heritage-items token-id)
)

(define-read-only (get-provenance-history (token-id uint))
  (map-get? provenance-history token-id)
)

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? heritage-nft token-id)
)

(define-read-only (is-authorized-verifier (verifier principal))
  (default-to false (map-get? authorized-verifiers verifier))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (match (nft-transfer? heritage-nft token-id sender recipient)
      success (begin
        (update-provenance-history token-id recipient "transfer")
        (ok success)
      )
      error ERR-TRANSFER-FAILED
    )
  )
)

(define-public (mint-heritage-nft 
  (name (string-ascii 100))
  (description (string-utf8 500))
  (origin (string-ascii 100))
  (cultural-significance (string-utf8 300))
  (heritage-type (string-ascii 50))
  (recipient principal)
)
  (let 
    (
      (token-id (+ (var-get token-id-nonce) u1))
      (current-block stacks-block-height)
    )
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> (len origin) u0) ERR-INVALID-INPUT)
    
    (match (nft-mint? heritage-nft token-id recipient)
      success (begin
        (map-set heritage-items token-id {
          name: name,
          description: description,
          origin: origin,
          cultural-significance: cultural-significance,
          date-created: current-block,
          heritage-type: heritage-type,
          creator: tx-sender,
          verified: false
        })
        (map-set provenance-history token-id (list {
          owner: recipient,
          timestamp: current-block,
          transaction-type: "mint"
        }))
        (var-set token-id-nonce token-id)
        (ok token-id)
      )
      error (err error)
    )
  )
)

(define-public (verify-heritage-item (token-id uint))
  (let ((heritage-item (unwrap! (map-get? heritage-items token-id) ERR-NOT-FOUND)))
    (asserts! (is-authorized-verifier tx-sender) ERR-NOT-AUTHORIZED)
    (map-set heritage-items token-id (merge heritage-item {verified: true}))
    (ok true)
  )
)

(define-public (add-authorized-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
    (map-set authorized-verifiers verifier true)
    (ok true)
  )
)

(define-public (remove-authorized-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
    (map-delete authorized-verifiers verifier)
    (ok true)
  )
)

(define-public (update-heritage-metadata
  (token-id uint)
  (name (string-ascii 100))
  (description (string-utf8 500))
  (cultural-significance (string-utf8 300))
)
  (let ((heritage-item (unwrap! (map-get? heritage-items token-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get creator heritage-item)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    
    (map-set heritage-items token-id (merge heritage-item {
      name: name,
      description: description,
      cultural-significance: cultural-significance
    }))
    (ok true)
  )
)

(define-private (update-provenance-history (token-id uint) (new-owner principal) (tx-type (string-ascii 20)))
  (let 
    (
      (current-history (default-to (list) (map-get? provenance-history token-id)))
      (new-entry {owner: new-owner, timestamp: stacks-block-height, transaction-type: tx-type})
    )
    (map-set provenance-history token-id (unwrap! (as-max-len? (append current-history new-entry) u50) false))
    true
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

(define-read-only (get-heritage-items-by-creator (creator principal))
  (ok creator)
)

(define-read-only (get-heritage-items-by-type (heritage-type (string-ascii 50)))
  (ok heritage-type)
)
