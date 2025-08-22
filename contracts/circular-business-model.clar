;; Circular Business Model Contract
;; Manages service-based models, sharing economy, and sustainability rewards

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-MODEL-NOT-FOUND (err u501))
(define-constant ERR-SERVICE-NOT-FOUND (err u502))
(define-constant ERR-INVALID-INPUT (err u503))
(define-constant ERR-INSUFFICIENT-BALANCE (err u504))
(define-constant ERR-SERVICE-UNAVAILABLE (err u505))
(define-constant ERR-SUBSCRIPTION-EXPIRED (err u506))
(define-constant ERR-INVALID-PRICING-MODEL (err u507))
(define-constant ERR-REWARD-ALREADY-CLAIMED (err u508))

;; Business model types
(define-constant MODEL-PRODUCT-AS-SERVICE "product-as-service")
(define-constant MODEL-SHARING-ECONOMY "sharing-economy")
(define-constant MODEL-SUBSCRIPTION "subscription")
(define-constant MODEL-PERFORMANCE-BASED "performance-based")
(define-constant MODEL-CIRCULAR-LEASING "circular-leasing")

;; Service status constants
(define-constant SERVICE-ACTIVE "active")
(define-constant SERVICE-PAUSED "paused")
(define-constant SERVICE-MAINTENANCE "maintenance")
(define-constant SERVICE-RETIRED "retired")

;; Pricing model constants
(define-constant PRICING-FIXED "fixed")
(define-constant PRICING-USAGE-BASED "usage-based")
(define-constant PRICING-PERFORMANCE-BASED "performance-based")
(define-constant PRICING-TIERED "tiered")

;; Data Variables
(define-data-var next-model-id uint u1)
(define-data-var next-service-id uint u1)
(define-data-var next-subscription-id uint u1)
(define-data-var total-revenue-shared uint u0)
(define-data-var total-sustainability-rewards uint u0)

;; Data Maps
(define-map business-models
  { model-id: uint }
  {
    product-id: uint,
    model-type: (string-ascii 30),
    model-name: (string-ascii 100),
    description: (string-ascii 300),
    provider: principal,
    pricing-model: (string-ascii 30),
    base-price: uint,
    usage-rate: uint,
    performance-multiplier: uint,
    sustainability-bonus: uint,
    revenue-share-percentage: uint,
    min-contract-period: uint,
    max-contract-period: uint,
    service-level-agreement: (string-ascii 500),
    created-at: uint,
    status: (string-ascii 20)
  }
)

(define-map service-offerings
  { service-id: uint }
  {
    model-id: uint,
    service-name: (string-ascii 100),
    service-description: (string-ascii 300),
    availability: uint,
    current-utilization: uint,
    quality-score: uint,
    maintenance-schedule: (string-ascii 200),
    geographic-coverage: (list 10 (string-ascii 50)),
    target-customers: (string-ascii 200),
    sustainability-features: (list 10 (string-ascii 50)),
    last-updated: uint,
    status: (string-ascii 20)
  }
)

(define-map subscriptions
  { subscription-id: uint }
  {
    model-id: uint,
    subscriber: principal,
    start-date: uint,
    end-date: uint,
    payment-amount: uint,
    payment-frequency: uint,
    usage-allowance: uint,
    current-usage: uint,
    performance-targets: (list 5 uint),
    sustainability-goals: (list 5 uint),
    auto-renewal: bool,
    status: (string-ascii 20),
    last-payment: uint,
    next-payment: uint
  }
)

(define-map revenue-sharing
  { model-id: uint, period: uint }
  {
    total-revenue: uint,
    provider-share: uint,
    platform-share: uint,
    sustainability-bonus: uint,
    performance-bonus: uint,
    shared-date: uint,
    participants: (list 10 principal),
    distribution-complete: bool
  }
)

(define-map sustainability-rewards
  { model-id: uint, recipient: principal, period: uint }
  {
    carbon-reduction: uint,
    resource-efficiency: uint,
    waste-reduction: uint,
    circular-practices: uint,
    reward-amount: uint,
    reward-date: uint,
    verification-status: bool,
    claimed: bool
  }
)

(define-map sharing-sessions
  { model-id: uint, session-id: uint }
  {
    user: principal,
    start-time: uint,
    end-time: (optional uint),
    usage-type: (string-ascii 50),
    location: (optional (string-ascii 100)),
    cost: uint,
    performance-rating: (optional uint),
    sustainability-impact: uint,
    session-notes: (optional (string-ascii 200))
  }
)

(define-map performance-metrics
  { model-id: uint, period: uint }
  {
    uptime-percentage: uint,
    customer-satisfaction: uint,
    resource-efficiency: uint,
    cost-effectiveness: uint,
    sustainability-score: uint,
    circular-economy-impact: uint,
    revenue-per-unit: uint,
    market-penetration: uint,
    last-calculated: uint
  }
)

(define-map circular-kpis
  { model-id: uint }
  {
    material-circularity-rate: uint,
    product-lifetime-extension: uint,
    sharing-utilization-rate: uint,
    end-of-life-recovery-rate: uint,
    customer-retention-rate: uint,
    sustainability-improvement: uint,
    cost-reduction-achieved: uint,
    environmental-impact-reduction: uint,
    last-updated: uint
  }
)

;; Private Functions
(define-private (is-valid-model-type (model-type (string-ascii 30)))
  (or
    (is-eq model-type MODEL-PRODUCT-AS-SERVICE)
    (or
      (is-eq model-type MODEL-SHARING-ECONOMY)
      (or
        (is-eq model-type MODEL-SUBSCRIPTION)
        (or
          (is-eq model-type MODEL-PERFORMANCE-BASED)
          (is-eq model-type MODEL-CIRCULAR-LEASING)
        )
      )
    )
  )
)

(define-private (is-valid-pricing-model (pricing-model (string-ascii 30)))
  (or
    (is-eq pricing-model PRICING-FIXED)
    (or
      (is-eq pricing-model PRICING-USAGE-BASED)
      (or
        (is-eq pricing-model PRICING-PERFORMANCE-BASED)
        (is-eq pricing-model PRICING-TIERED)
      )
    )
  )
)

(define-private (increment-model-id)
  (let ((current-id (var-get next-model-id)))
    (var-set next-model-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-service-id)
  (let ((current-id (var-get next-service-id)))
    (var-set next-service-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-subscription-id)
  (let ((current-id (var-get next-subscription-id)))
    (var-set next-subscription-id (+ current-id u1))
    current-id
  )
)

(define-private (calculate-usage-cost
  (base-price uint)
  (usage-amount uint)
  (usage-rate uint)
  (performance-score uint)
)
  (let
    (
      (usage-cost (* usage-amount usage-rate))
      (performance-adjustment (/ (* usage-cost performance-score) u100))
    )
    (+ base-price performance-adjustment)
  )
)

(define-private (calculate-sustainability-bonus
  (base-amount uint)
  (carbon-reduction uint)
  (efficiency-gain uint)
  (circular-practices uint)
)
  (let
    (
      (carbon-bonus (/ (* base-amount carbon-reduction) u1000))
      (efficiency-bonus (/ (* base-amount efficiency-gain) u1000))
      (circular-bonus (/ (* base-amount circular-practices) u1000))
    )
    (+ carbon-bonus (+ efficiency-bonus circular-bonus))
  )
)

(define-private (update-circular-kpis (model-id uint))
  (let
    (
      (current-kpis (default-to
        {
          material-circularity-rate: u0,
          product-lifetime-extension: u0,
          sharing-utilization-rate: u0,
          end-of-life-recovery-rate: u0,
          customer-retention-rate: u0,
          sustainability-improvement: u0,
          cost-reduction-achieved: u0,
          environmental-impact-reduction: u0,
          last-updated: u0
        }
        (map-get? circular-kpis { model-id: model-id })
      ))
    )
    (map-set circular-kpis
      { model-id: model-id }
      (merge current-kpis {
        last-updated: block-height
      })
    )
  )
)

;; Public Functions

;; Create a new circular business model
(define-public (create-business-model
  (product-id uint)
  (model-type (string-ascii 30))
  (model-name (string-ascii 100))
  (description (string-ascii 300))
  (pricing-model (string-ascii 30))
  (base-price uint)
  (usage-rate uint)
  (performance-multiplier uint)
  (sustainability-bonus uint)
  (revenue-share-percentage uint)
  (min-contract-period uint)
  (max-contract-period uint)
  (service-level-agreement (string-ascii 500))
)
  (let
    (
      (model-id (increment-model-id))
      (current-time block-height)
    )
    (asserts! (is-valid-model-type model-type) ERR-INVALID-INPUT)
    (asserts! (is-valid-pricing-model pricing-model) ERR-INVALID-PRICING-MODEL)
    (asserts! (> (len model-name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (<= revenue-share-percentage u100) ERR-INVALID-INPUT)
    (asserts! (< min-contract-period max-contract-period) ERR-INVALID-INPUT)

    (map-set business-models
      { model-id: model-id }
      {
        product-id: product-id,
        model-type: model-type,
        model-name: model-name,
        description: description,
        provider: tx-sender,
        pricing-model: pricing-model,
        base-price: base-price,
        usage-rate: usage-rate,
        performance-multiplier: performance-multiplier,
        sustainability-bonus: sustainability-bonus,
        revenue-share-percentage: revenue-share-percentage,
        min-contract-period: min-contract-period,
        max-contract-period: max-contract-period,
        service-level-agreement: service-level-agreement,
        created-at: current-time,
        status: SERVICE-ACTIVE
      }
    )

    (ok model-id)
  )
)

;; Create a service offering
(define-public (create-service-offering
  (model-id uint)
  (service-name (string-ascii 100))
  (service-description (string-ascii 300))
  (availability uint)
  (maintenance-schedule (string-ascii 200))
  (geographic-coverage (list 10 (string-ascii 50)))
  (target-customers (string-ascii 200))
  (sustainability-features (list 10 (string-ascii 50)))
)
  (let
    (
      (service-id (increment-service-id))
      (current-time block-height)
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get provider model-data)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len service-name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len service-description) u0) ERR-INVALID-INPUT)
    (asserts! (> availability u0) ERR-INVALID-INPUT)

    (map-set service-offerings
      { service-id: service-id }
      {
        model-id: model-id,
        service-name: service-name,
        service-description: service-description,
        availability: availability,
        current-utilization: u0,
        quality-score: u100,
        maintenance-schedule: maintenance-schedule,
        geographic-coverage: geographic-coverage,
        target-customers: target-customers,
        sustainability-features: sustainability-features,
        last-updated: current-time,
        status: SERVICE-ACTIVE
      }
    )

    (ok service-id)
  )
)

;; Subscribe to a service
(define-public (subscribe-to-service
  (model-id uint)
  (contract-period uint)
  (usage-allowance uint)
  (performance-targets (list 5 uint))
  (sustainability-goals (list 5 uint))
  (auto-renewal bool)
)
  (let
    (
      (subscription-id (increment-subscription-id))
      (current-time block-height)
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
      (end-date (+ current-time contract-period))
      (payment-amount (get base-price model-data))
    )
    (asserts! (is-eq (get status model-data) SERVICE-ACTIVE) ERR-SERVICE-UNAVAILABLE)
    (asserts! (>= contract-period (get min-contract-period model-data)) ERR-INVALID-INPUT)
    (asserts! (<= contract-period (get max-contract-period model-data)) ERR-INVALID-INPUT)
    (asserts! (> usage-allowance u0) ERR-INVALID-INPUT)

    (map-set subscriptions
      { subscription-id: subscription-id }
      {
        model-id: model-id,
        subscriber: tx-sender,
        start-date: current-time,
        end-date: end-date,
        payment-amount: payment-amount,
        payment-frequency: u30, ;; 30 blocks (monthly)
        usage-allowance: usage-allowance,
        current-usage: u0,
        performance-targets: performance-targets,
        sustainability-goals: sustainability-goals,
        auto-renewal: auto-renewal,
        status: SERVICE-ACTIVE,
        last-payment: current-time,
        next-payment: (+ current-time u30)
      }
    )

    (ok subscription-id)
  )
)

;; Record usage session
(define-public (record-usage-session
  (model-id uint)
  (session-id uint)
  (usage-type (string-ascii 50))
  (location (optional (string-ascii 100)))
  (sustainability-impact uint)
  (session-notes (optional (string-ascii 200)))
)
  (let
    (
      (current-time block-height)
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
      (usage-cost (calculate-usage-cost (get base-price model-data) u1 (get usage-rate model-data) u100))
    )
    (asserts! (> (len usage-type) u0) ERR-INVALID-INPUT)
    (asserts! (<= sustainability-impact u100) ERR-INVALID-INPUT)

    (map-set sharing-sessions
      { model-id: model-id, session-id: session-id }
      {
        user: tx-sender,
        start-time: current-time,
        end-time: none,
        usage-type: usage-type,
        location: location,
        cost: usage-cost,
        performance-rating: none,
        sustainability-impact: sustainability-impact,
        session-notes: session-notes
      }
    )

    (ok true)
  )
)

;; End usage session
(define-public (end-usage-session
  (model-id uint)
  (session-id uint)
  (performance-rating uint)
)
  (let
    (
      (session-data (unwrap! (map-get? sharing-sessions { model-id: model-id, session-id: session-id }) ERR-SERVICE-NOT-FOUND))
      (current-time block-height)
    )
    (asserts! (is-eq tx-sender (get user session-data)) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (get end-time session-data)) ERR-INVALID-INPUT)
    (asserts! (<= performance-rating u100) ERR-INVALID-INPUT)

    (map-set sharing-sessions
      { model-id: model-id, session-id: session-id }
      (merge session-data {
        end-time: (some current-time),
        performance-rating: (some performance-rating)
      })
    )

    (ok true)
  )
)

;; Distribute revenue sharing
(define-public (distribute-revenue-sharing
  (model-id uint)
  (period uint)
  (total-revenue uint)
  (participants (list 10 principal))
)
  (let
    (
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
      (provider-percentage (get revenue-share-percentage model-data))
      (provider-share (/ (* total-revenue provider-percentage) u100))
      (platform-share (- total-revenue provider-share))
      (current-time block-height)
    )
    (asserts! (is-eq tx-sender (get provider model-data)) ERR-NOT-AUTHORIZED)
    (asserts! (> total-revenue u0) ERR-INVALID-INPUT)
    (asserts! (> (len participants) u0) ERR-INVALID-INPUT)

    (map-set revenue-sharing
      { model-id: model-id, period: period }
      {
        total-revenue: total-revenue,
        provider-share: provider-share,
        platform-share: platform-share,
        sustainability-bonus: u0,
        performance-bonus: u0,
        shared-date: current-time,
        participants: participants,
        distribution-complete: true
      }
    )

    (var-set total-revenue-shared (+ (var-get total-revenue-shared) total-revenue))

    (ok true)
  )
)

;; Award sustainability rewards
(define-public (award-sustainability-reward
  (model-id uint)
  (recipient principal)
  (period uint)
  (carbon-reduction uint)
  (resource-efficiency uint)
  (waste-reduction uint)
  (circular-practices uint)
)
  (let
    (
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
      (base-bonus (get sustainability-bonus model-data))
      (reward-amount (calculate-sustainability-bonus base-bonus carbon-reduction resource-efficiency circular-practices))
      (current-time block-height)
    )
    (asserts! (> reward-amount u0) ERR-INVALID-INPUT)
    (asserts! (<= carbon-reduction u100) ERR-INVALID-INPUT)
    (asserts! (<= resource-efficiency u100) ERR-INVALID-INPUT)
    (asserts! (<= waste-reduction u100) ERR-INVALID-INPUT)
    (asserts! (<= circular-practices u100) ERR-INVALID-INPUT)

    (map-set sustainability-rewards
      { model-id: model-id, recipient: recipient, period: period }
      {
        carbon-reduction: carbon-reduction,
        resource-efficiency: resource-efficiency,
        waste-reduction: waste-reduction,
        circular-practices: circular-practices,
        reward-amount: reward-amount,
        reward-date: current-time,
        verification-status: false,
        claimed: false
      }
    )

    (ok reward-amount)
  )
)

;; Claim sustainability reward
(define-public (claim-sustainability-reward (model-id uint) (period uint))
  (let
    (
      (reward-data (unwrap! (map-get? sustainability-rewards { model-id: model-id, recipient: tx-sender, period: period }) ERR-SERVICE-NOT-FOUND))
    )
    (asserts! (get verification-status reward-data) ERR-NOT-AUTHORIZED)
    (asserts! (not (get claimed reward-data)) ERR-REWARD-ALREADY-CLAIMED)

    (map-set sustainability-rewards
      { model-id: model-id, recipient: tx-sender, period: period }
      (merge reward-data { claimed: true })
    )

    (var-set total-sustainability-rewards (+ (var-get total-sustainability-rewards) (get reward-amount reward-data)))

    (ok (get reward-amount reward-data))
  )
)

;; Update performance metrics
(define-public (update-performance-metrics
  (model-id uint)
  (period uint)
  (uptime-percentage uint)
  (customer-satisfaction uint)
  (resource-efficiency uint)
  (cost-effectiveness uint)
  (sustainability-score uint)
)
  (let
    (
      (model-data (unwrap! (map-get? business-models { model-id: model-id }) ERR-MODEL-NOT-FOUND))
      (circular-impact (/ (+ sustainability-score resource-efficiency) u2))
      (revenue-per-unit (get base-price model-data))
    )
    (asserts! (is-eq tx-sender (get provider model-data)) ERR-NOT-AUTHORIZED)
    (asserts! (<= uptime-percentage u100) ERR-INVALID-INPUT)
    (asserts! (<= customer-satisfaction u100) ERR-INVALID-INPUT)
    (asserts! (<= resource-efficiency u100) ERR-INVALID-INPUT)
    (asserts! (<= sustainability-score u100) ERR-INVALID-INPUT)

    (map-set performance-metrics
      { model-id: model-id, period: period }
      {
        uptime-percentage: uptime-percentage,
        customer-satisfaction: customer-satisfaction,
        resource-efficiency: resource-efficiency,
        cost-effectiveness: cost-effectiveness,
        sustainability-score: sustainability-score,
        circular-economy-impact: circular-impact,
        revenue-per-unit: revenue-per-unit,
        market-penetration: u0,
        last-calculated: block-height
      }
    )

    (update-circular-kpis model-id)

    (ok true)
  )
)

;; Read-only Functions

;; Get business model details
(define-read-only (get-business-model (model-id uint))
  (map-get? business-models { model-id: model-id })
)

;; Get service offering details
(define-read-only (get-service-offering (service-id uint))
  (map-get? service-offerings { service-id: service-id })
)

;; Get subscription details
(define-read-only (get-subscription (subscription-id uint))
  (map-get? subscriptions { subscription-id: subscription-id })
)

;; Get revenue sharing information
(define-read-only (get-revenue-sharing (model-id uint) (period uint))
  (map-get? revenue-sharing { model-id: model-id, period: period })
)

;; Get sustainability reward details
(define-read-only (get-sustainability-reward (model-id uint) (recipient principal) (period uint))
  (map-get? sustainability-rewards { model-id: model-id, recipient: recipient, period: period })
)

;; Get sharing session details
(define-read-only (get-sharing-session (model-id uint) (session-id uint))
  (map-get? sharing-sessions { model-id: model-id, session-id: session-id })
)

;; Get performance metrics
(define-read-only (get-performance-metrics (model-id uint) (period uint))
  (map-get? performance-metrics { model-id: model-id, period: period })
)

;; Get circular KPIs
(define-read-only (get-circular-kpis (model-id uint))
  (map-get? circular-kpis { model-id: model-id })
)

;; Calculate service cost
(define-read-only (calculate-service-cost
  (model-id uint)
  (usage-amount uint)
  (performance-score uint)
)
  (match (map-get? business-models { model-id: model-id })
    model-data
    (some (calculate-usage-cost (get base-price model-data) usage-amount (get usage-rate model-data) performance-score))
    none
  )
)

;; Get total revenue shared
(define-read-only (get-total-revenue-shared)
  (var-get total-revenue-shared)
)

;; Get total sustainability rewards
(define-read-only (get-total-sustainability-rewards)
  (var-get total-sustainability-rewards)
)

;; Get next model ID
(define-read-only (get-next-model-id)
  (var-get next-model-id)
)

;; Get next service ID
(define-read-only (get-next-service-id)
  (var-get next-service-id)
)

;; Get next subscription ID
(define-read-only (get-next-subscription-id)
  (var-get next-subscription-id)
)

;; Check subscription validity
(define-read-only (is-subscription-valid (subscription-id uint))
  (match (map-get? subscriptions { subscription-id: subscription-id })
    sub-data
    (and
      (is-eq (get status sub-data) SERVICE-ACTIVE)
      (> (get end-date sub-data) block-height)
    )
    false
  )
)

;; Get contract owner
(define-read-only (get-contract-owner)
  CONTRACT-OWNER
)
