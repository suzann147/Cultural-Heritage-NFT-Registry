(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-INPUT (err u104))
(define-constant ERR-TRANSFER-FAILED (err u105))

(define-constant ERR-NOT-LISTED (err u200))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u201))
(define-constant ERR-LISTING-INACTIVE (err u202))
(define-constant ERR-SELF-PURCHASE (err u203))

(define-constant ERR-ALREADY-RATED (err u300))
(define-constant ERR-INVALID-RATING (err u301))
(define-constant ERR-NO-RATINGS (err u302))

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

(define-map marketplace-listings
  uint
  {
    seller: principal,
    price: uint,
    listed-at: uint,
    active: bool
  }
)

(define-read-only (get-listing (token-id uint))
  (map-get? marketplace-listings token-id)
)

(define-read-only (is-listed (token-id uint))
  (match (map-get? marketplace-listings token-id)
    listing (get active listing)
    false
  )
)

(define-public (list-for-sale (token-id uint) (price uint))
  (let ((owner (unwrap! (nft-get-owner? heritage-nft token-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (> price u0) ERR-INVALID-INPUT)
    (map-set marketplace-listings token-id {
      seller: tx-sender,
      price: price,
      listed-at: stacks-block-height,
      active: true
    })
    (ok true)
  )
)

(define-public (remove-listing (token-id uint))
  (let ((listing (unwrap! (map-get? marketplace-listings token-id) ERR-NOT-LISTED)))
    (asserts! (is-eq tx-sender (get seller listing)) ERR-NOT-AUTHORIZED)
    (map-set marketplace-listings token-id (merge listing {active: false}))
    (ok true)
  )
)

(define-public (purchase-heritage-nft (token-id uint))
  (let (
    (listing (unwrap! (map-get? marketplace-listings token-id) ERR-NOT-LISTED))
    (seller (get seller listing))
    (price (get price listing))
  )
    (asserts! (get active listing) ERR-LISTING-INACTIVE)
    (asserts! (not (is-eq tx-sender seller)) ERR-SELF-PURCHASE)
    (asserts! (>= (stx-get-balance tx-sender) price) ERR-INSUFFICIENT-PAYMENT)
    
    (match (stx-transfer? price tx-sender seller)
      success (begin
        (unwrap! (nft-transfer? heritage-nft token-id seller tx-sender) ERR-TRANSFER-FAILED)
        (update-provenance-history token-id tx-sender "purchase")
        (map-set marketplace-listings token-id (merge listing {active: false}))
        (ok token-id)
      )
      error (err u300)
    )
  )
)


(define-map heritage-ratings
  {token-id: uint, rater: principal}
  {rating: uint, review: (string-utf8 200), timestamp: uint}
)

(define-map heritage-rating-stats
  uint
  {total-ratings: uint, rating-sum: uint, average-rating: uint}
)

(define-read-only (get-heritage-rating-stats (token-id uint))
  (map-get? heritage-rating-stats token-id)
)

(define-read-only (get-user-rating (token-id uint) (rater principal))
  (map-get? heritage-ratings {token-id: token-id, rater: rater})
)

(define-read-only (get-average-rating (token-id uint))
  (match (map-get? heritage-rating-stats token-id)
    stats (some (get average-rating stats))
    none
  )
)

(define-public (rate-heritage-item 
  (token-id uint) 
  (rating uint) 
  (review (string-utf8 200))
)
  (let (
    (rating-key {token-id: token-id, rater: tx-sender})
    (current-stats (default-to {total-ratings: u0, rating-sum: u0, average-rating: u0} 
                               (map-get? heritage-rating-stats token-id)))
    (heritage-item (unwrap! (map-get? heritage-items token-id) ERR-NOT-FOUND))
  )
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)
    (asserts! (is-none (map-get? heritage-ratings rating-key)) ERR-ALREADY-RATED)
    
    (map-set heritage-ratings rating-key {
      rating: rating,
      review: review,
      timestamp: stacks-block-height
    })
    
    (let (
      (new-total (+ (get total-ratings current-stats) u1))
      (new-sum (+ (get rating-sum current-stats) rating))
      (new-average (/ new-sum new-total))
    )
      (map-set heritage-rating-stats token-id {
        total-ratings: new-total,
        rating-sum: new-sum,
        average-rating: new-average
      })
      (ok true)
    )
  )
)

(define-read-only (has-user-rated (token-id uint) (user principal))
  (is-some (map-get? heritage-ratings {token-id: token-id, rater: user}))
)

(define-read-only (get-rating-count (token-id uint))
  (match (map-get? heritage-rating-stats token-id)
    stats (some (get total-ratings stats))
    none
  )
)