;; Environmental Impact Contract
;; Manages carbon footprint, resource consumption, and sustainability metrics

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-PRODUCT-NOT-FOUND (err u301))
(define-constant ERR-IMPACT-RECORD-NOT-FOUND (err u302))
(define-constant ERR-INVALID-INPUT (err u303))
(define-constant ERR-INVALID-CERTIFICATION (err u304))
(define-constant ERR-CERTIFICATION-EXPIRED (err u305))
(define-constant ERR-INVALID-METRIC-VALUE (err u306))

;; Environmental certification types
(define-constant CERT-ISO14001 "ISO14001")
(define-constant CERT-ENERGY-STAR "ENERGY-STAR")
(define-constant CERT-CRADLE-TO-CRADLE "CRADLE-TO-CRADLE")
(define-constant CERT-CARBON-NEUTRAL "CARBON-NEUTRAL")
(define-constant CERT-RECYCLABLE "RECYCLABLE")
(define-constant CERT-BIODEGRADABLE "BIODEGRADABLE")

;; Impact categories
(define-constant IMPACT-MANUFACTURING "manufacturing")
(define-constant IMPACT-TRANSPORTATION "transportation")
(define-constant IMPACT-USAGE "usage")
(define-constant IMPACT-MAINTENANCE "maintenance")
(define-constant IMPACT-END-OF-LIFE "end-of-life")

;; Data Variables
(define-data-var next-impact-id uint u1)
(define-data-var next-certification-id uint u1)
(define-data-var total-impact-records uint u0)
(define-data-var global-carbon-offset uint u0)

;; Data Maps
(define-map environmental-impact
  { product-id: uint }
  {
    total-carbon-footprint: uint,
    manufacturing-emissions: uint,
    transportation-emissions: uint,
    usage-emissions: uint,
    end-of-life-emissions: uint,
    water-consumption: uint,
    energy-consumption: uint,
    waste-generated: uint,
    recyclable-content: uint,
    renewable-energy-used: uint,
    sustainability-score: uint,
    last-updated: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

(define-map impact-history
  { impact-id: uint }
  {
    product-id: uint,
    impact-category: (string-ascii 30),
    carbon-emissions: uint,
    water-usage: uint,
    energy-usage: uint,
    waste-amount: uint,
    measurement-period: uint,
    timestamp: uint,
    reporter: principal,
    methodology: (string-ascii 100),
    verified: bool
  }
)

(define-map environmental-certifications
  { certification-id: uint }
  {
    product-id: uint,
    certification-type: (string-ascii 50),
    issuing-authority: (string-ascii 100),
    issue-date: uint,
    expiry-date: uint,
    certification-number: (string-ascii 100),
    scope: (string-ascii 200),
    status: (string-ascii 20),
    verifier: principal
  }
)

(define-map sustainability-targets
  { product-id: uint }
  {
    carbon-reduction-target: uint,
    water-reduction-target: uint,
    energy-efficiency-target: uint,
    waste-reduction-target: uint,
    renewable-energy-target: uint,
    target-deadline: uint,
    baseline-year: uint,
    progress-percentage: uint,
    last-assessment: uint
  }
)

(define-map carbon-offsets
  { product-id: uint, offset-id: uint }
  {
    offset-amount: uint,
    offset-type: (string-ascii 50),
    provider: (string-ascii 100),
    verification-standard: (string-ascii 50),
    purchase-date: uint,
    retirement-date: (optional uint),
    cost: uint,
    status: (string-ascii 20)
  }
)

(define-map resource-consumption
  { product-id: uint, period: uint }
  {
    electricity-kwh: uint,
    water-liters: uint,
    gas-cubic-meters: uint,
    fuel-liters: uint,
    raw-materials-kg: uint,
    packaging-materials-kg: uint,
    renewable-percentage: uint,
    efficiency-rating: uint
  }
)

(define-map environmental-compliance
  { product-id: uint, regulation: (string-ascii 100) }
  {
    compliance-status: (string-ascii 20),
    last-audit-date: uint,
    next-audit-date: uint,
    auditor: (string-ascii 100),
    compliance-score: uint,
    violations: uint,
    corrective-actions: (string-ascii 300)
  }
)

;; Private Functions
(define-private (is-valid-certification-type (cert-type (string-ascii 50)))
  (or
    (is-eq cert-type CERT-ISO14001)
    (or
      (is-eq cert-type CERT-ENERGY-STAR)
      (or
        (is-eq cert-type CERT-CRADLE-TO-CRADLE)
        (or
          (is-eq cert-type CERT-CARBON-NEUTRAL)
          (or
            (is-eq cert-type CERT-RECYCLABLE)
            (is-eq cert-type CERT-BIODEGRADABLE)
          )
        )
      )
    )
  )
)

(define-private (is-valid-impact-category (category (string-ascii 30)))
  (or
    (is-eq category IMPACT-MANUFACTURING)
    (or
      (is-eq category IMPACT-TRANSPORTATION)
      (or
        (is-eq category IMPACT-USAGE)
        (or
          (is-eq category IMPACT-MAINTENANCE)
          (is-eq category IMPACT-END-OF-LIFE)
        )
      )
    )
  )
)

(define-private (increment-impact-id)
  (let ((current-id (var-get next-impact-id)))
    (var-set next-impact-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-certification-id)
  (let ((current-id (var-get next-certification-id)))
    (var-set next-certification-id (+ current-id u1))
    current-id
  )
)

(define-private (calculate-sustainability-score
  (carbon-footprint uint)
  (water-usage uint)
  (energy-usage uint)
  (waste-generated uint)
  (renewable-percentage uint)
)
  (let
    (
      (carbon-score (if (< carbon-footprint u1000) u25 (if (< carbon-footprint u5000) u15 u5)))
      (water-score (if (< water-usage u100) u25 (if (< water-usage u500) u15 u5)))
      (energy-score (if (< energy-usage u1000) u25 (if (< energy-usage u5000) u15 u5)))
      (waste-score (if (< waste-generated u10) u15 (if (< waste-generated u50) u10 u5)))
      (renewable-score (/ renewable-percentage u10))
    )
    (+ carbon-score (+ water-score (+ energy-score (+ waste-score renewable-score))))
  )
)

(define-private (update-total-impact (product-id uint))
  (let
    (
      (current-impact (map-get? environmental-impact { product-id: product-id }))
    )
    (match current-impact
      impact-data
      (let
        (
          (total-carbon (+ (+ (+ (get manufacturing-emissions impact-data) (get transportation-emissions impact-data)) (get usage-emissions impact-data)) (get end-of-life-emissions impact-data)))
          (sustainability (calculate-sustainability-score
            total-carbon
            (get water-consumption impact-data)
            (get energy-consumption impact-data)
            (get waste-generated impact-data)
            (get renewable-energy-used impact-data)
          ))
        )
        (map-set environmental-impact
          { product-id: product-id }
          (merge impact-data {
            total-carbon-footprint: total-carbon,
            sustainability-score: sustainability,
            last-updated: block-height
          })
        )
      )
      false
    )
  )
)

;; Public Functions

;; Initialize environmental impact tracking for a product
(define-public (initialize-impact-tracking (product-id uint))
  (let
    (
      (current-time block-height)
    )
    (asserts! (is-none (map-get? environmental-impact { product-id: product-id })) ERR-INVALID-INPUT)

    (map-set environmental-impact
      { product-id: product-id }
      {
        total-carbon-footprint: u0,
        manufacturing-emissions: u0,
        transportation-emissions: u0,
        usage-emissions: u0,
        end-of-life-emissions: u0,
        water-consumption: u0,
        energy-consumption: u0,
        waste-generated: u0,
        recyclable-content: u0,
        renewable-energy-used: u0,
        sustainability-score: u100,
        last-updated: current-time,
        verified: false,
        verifier: none
      }
    )

    (ok true)
  )
)

;; Record impact data for a specific category
(define-public (record-impact-data
  (product-id uint)
  (impact-category (string-ascii 30))
  (carbon-emissions uint)
  (water-usage uint)
  (energy-usage uint)
  (waste-amount uint)
  (measurement-period uint)
  (methodology (string-ascii 100))
)
  (let
    (
      (impact-id (increment-impact-id))
      (current-time block-height)
      (current-impact (unwrap! (map-get? environmental-impact { product-id: product-id }) ERR-PRODUCT-NOT-FOUND))
    )
    (asserts! (is-valid-impact-category impact-category) ERR-INVALID-INPUT)
    (asserts! (> measurement-period u0) ERR-INVALID-INPUT)
    (asserts! (> (len methodology) u0) ERR-INVALID-INPUT)

    ;; Record the impact history
    (map-set impact-history
      { impact-id: impact-id }
      {
        product-id: product-id,
        impact-category: impact-category,
        carbon-emissions: carbon-emissions,
        water-usage: water-usage,
        energy-usage: energy-usage,
        waste-amount: waste-amount,
        measurement-period: measurement-period,
        timestamp: current-time,
        reporter: tx-sender,
        methodology: methodology,
        verified: false
      }
    )

    ;; Update cumulative impact based on category
    (if (is-eq impact-category IMPACT-MANUFACTURING)
      (map-set environmental-impact
        { product-id: product-id }
        (merge current-impact {
          manufacturing-emissions: (+ (get manufacturing-emissions current-impact) carbon-emissions),
          water-consumption: (+ (get water-consumption current-impact) water-usage),
          energy-consumption: (+ (get energy-consumption current-impact) energy-usage),
          waste-generated: (+ (get waste-generated current-impact) waste-amount)
        })
      )
      (if (is-eq impact-category IMPACT-TRANSPORTATION)
        (map-set environmental-impact
          { product-id: product-id }
          (merge current-impact {
            transportation-emissions: (+ (get transportation-emissions current-impact) carbon-emissions)
          })
        )
        (if (is-eq impact-category IMPACT-USAGE)
          (map-set environmental-impact
            { product-id: product-id }
            (merge current-impact {
              usage-emissions: (+ (get usage-emissions current-impact) carbon-emissions)
            })
          )
          (if (is-eq impact-category IMPACT-END-OF-LIFE)
            (map-set environmental-impact
              { product-id: product-id }
              (merge current-impact {
                end-of-life-emissions: (+ (get end-of-life-emissions current-impact) carbon-emissions)
              })
            )
            true
          )
        )
      )
    )

    ;; Update total impact calculations
    (update-total-impact product-id)
    (var-set total-impact-records (+ (var-get total-impact-records) u1))

    (ok impact-id)
  )
)

;; Add environmental certification
(define-public (add-certification
  (product-id uint)
  (certification-type (string-ascii 50))
  (issuing-authority (string-ascii 100))
  (expiry-date uint)
  (certification-number (string-ascii 100))
  (scope (string-ascii 200))
)
  (let
    (
      (certification-id (increment-certification-id))
      (current-time block-height)
    )
    (asserts! (is-valid-certification-type certification-type) ERR-INVALID-CERTIFICATION)
    (asserts! (> expiry-date current-time) ERR-INVALID-INPUT)
    (asserts! (> (len issuing-authority) u0) ERR-INVALID-INPUT)
    (asserts! (> (len certification-number) u0) ERR-INVALID-INPUT)

    (map-set environmental-certifications
      { certification-id: certification-id }
      {
        product-id: product-id,
        certification-type: certification-type,
        issuing-authority: issuing-authority,
        issue-date: current-time,
        expiry-date: expiry-date,
        certification-number: certification-number,
        scope: scope,
        status: "active",
        verifier: tx-sender
      }
    )

    (ok certification-id)
  )
)

;; Set sustainability targets
(define-public (set-sustainability-targets
  (product-id uint)
  (carbon-reduction-target uint)
  (water-reduction-target uint)
  (energy-efficiency-target uint)
  (waste-reduction-target uint)
  (renewable-energy-target uint)
  (target-deadline uint)
  (baseline-year uint)
)
  (let
    (
      (current-time block-height)
    )
    (asserts! (> target-deadline current-time) ERR-INVALID-INPUT)
    (asserts! (< baseline-year current-time) ERR-INVALID-INPUT)
    (asserts! (<= carbon-reduction-target u100) ERR-INVALID-METRIC-VALUE)
    (asserts! (<= renewable-energy-target u100) ERR-INVALID-METRIC-VALUE)

    (map-set sustainability-targets
      { product-id: product-id }
      {
        carbon-reduction-target: carbon-reduction-target,
        water-reduction-target: water-reduction-target,
        energy-efficiency-target: energy-efficiency-target,
        waste-reduction-target: waste-reduction-target,
        renewable-energy-target: renewable-energy-target,
        target-deadline: target-deadline,
        baseline-year: baseline-year,
        progress-percentage: u0,
        last-assessment: current-time
      }
    )

    (ok true)
  )
)

;; Purchase carbon offsets
(define-public (purchase-carbon-offset
  (product-id uint)
  (offset-id uint)
  (offset-amount uint)
  (offset-type (string-ascii 50))
  (provider (string-ascii 100))
  (verification-standard (string-ascii 50))
  (cost uint)
)
  (let
    (
      (current-time block-height)
    )
    (asserts! (> offset-amount u0) ERR-INVALID-INPUT)
    (asserts! (> (len offset-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len provider) u0) ERR-INVALID-INPUT)

    (map-set carbon-offsets
      { product-id: product-id, offset-id: offset-id }
      {
        offset-amount: offset-amount,
        offset-type: offset-type,
        provider: provider,
        verification-standard: verification-standard,
        purchase-date: current-time,
        retirement-date: none,
        cost: cost,
        status: "purchased"
      }
    )

    (var-set global-carbon-offset (+ (var-get global-carbon-offset) offset-amount))

    (ok true)
  )
)

;; Verify environmental impact data
(define-public (verify-impact-data (product-id uint) (impact-id uint))
  (let
    (
      (impact-record (unwrap! (map-get? impact-history { impact-id: impact-id }) ERR-IMPACT-RECORD-NOT-FOUND))
      (product-impact (unwrap! (map-get? environmental-impact { product-id: product-id }) ERR-PRODUCT-NOT-FOUND))
    )
    (asserts! (is-eq (get product-id impact-record) product-id) ERR-INVALID-INPUT)

    ;; Update impact record as verified
    (map-set impact-history
      { impact-id: impact-id }
      (merge impact-record { verified: true })
    )

    ;; Update product impact as verified
    (map-set environmental-impact
      { product-id: product-id }
      (merge product-impact {
        verified: true,
        verifier: (some tx-sender)
      })
    )

    (ok true)
  )
)

;; Record resource consumption for a period
(define-public (record-resource-consumption
  (product-id uint)
  (period uint)
  (electricity-kwh uint)
  (water-liters uint)
  (gas-cubic-meters uint)
  (fuel-liters uint)
  (raw-materials-kg uint)
  (packaging-materials-kg uint)
  (renewable-percentage uint)
)
  (let
    (
      (efficiency-rating (if (> electricity-kwh u0) (/ u10000 electricity-kwh) u100))
    )
    (asserts! (> period u0) ERR-INVALID-INPUT)
    (asserts! (<= renewable-percentage u100) ERR-INVALID-METRIC-VALUE)

    (map-set resource-consumption
      { product-id: product-id, period: period }
      {
        electricity-kwh: electricity-kwh,
        water-liters: water-liters,
        gas-cubic-meters: gas-cubic-meters,
        fuel-liters: fuel-liters,
        raw-materials-kg: raw-materials-kg,
        packaging-materials-kg: packaging-materials-kg,
        renewable-percentage: renewable-percentage,
        efficiency-rating: efficiency-rating
      }
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get environmental impact data
(define-read-only (get-environmental-impact (product-id uint))
  (map-get? environmental-impact { product-id: product-id })
)

;; Get impact history record
(define-read-only (get-impact-history (impact-id uint))
  (map-get? impact-history { impact-id: impact-id })
)

;; Get certification details
(define-read-only (get-certification (certification-id uint))
  (map-get? environmental-certifications { certification-id: certification-id })
)

;; Get sustainability targets
(define-read-only (get-sustainability-targets (product-id uint))
  (map-get? sustainability-targets { product-id: product-id })
)

;; Get carbon offset information
(define-read-only (get-carbon-offset (product-id uint) (offset-id uint))
  (map-get? carbon-offsets { product-id: product-id, offset-id: offset-id })
)

;; Get resource consumption data
(define-read-only (get-resource-consumption (product-id uint) (period uint))
  (map-get? resource-consumption { product-id: product-id, period: period })
)

;; Get environmental compliance status
(define-read-only (get-compliance-status (product-id uint) (regulation (string-ascii 100)))
  (map-get? environmental-compliance { product-id: product-id, regulation: regulation })
)

;; Calculate carbon footprint per unit
(define-read-only (calculate-carbon-per-unit (product-id uint) (units-produced uint))
  (match (map-get? environmental-impact { product-id: product-id })
    impact-data
    (if (> units-produced u0)
      (some (/ (get total-carbon-footprint impact-data) units-produced))
      none
    )
    none
  )
)

;; Get total impact records count
(define-read-only (get-total-impact-records)
  (var-get total-impact-records)
)

;; Get global carbon offset amount
(define-read-only (get-global-carbon-offset)
  (var-get global-carbon-offset)
)

;; Get next impact ID
(define-read-only (get-next-impact-id)
  (var-get next-impact-id)
)

;; Get next certification ID
(define-read-only (get-next-certification-id)
  (var-get next-certification-id)
)

;; Check if certification is valid
(define-read-only (is-certification-valid (certification-id uint))
  (match (map-get? environmental-certifications { certification-id: certification-id })
    cert-data
    (and
      (is-eq (get status cert-data) "active")
      (> (get expiry-date cert-data) block-height)
    )
    false
  )
)

;; Get contract owner
(define-read-only (get-contract-owner)
  CONTRACT-OWNER
)
