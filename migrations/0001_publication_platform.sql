-- Hellbox Comics
-- Gate 1 — Publication Platform & Data Model
-- Migration 0001: durable publication platform schema
--
-- This migration deliberately creates the durable data model only.
-- It does NOT seed SciVive yet. SciVive becomes migration/seed 0002 after
-- its actual package paths, provenance, license, and Reader manifest are
-- inspected and normalized.
--
-- SQLite / Cloudflare D1
--
-- STORAGE / DISTRIBUTION RULE — LOCKED:
-- `hellbox-assets` is permanently outside this project's architecture.
-- Hellbox-controlled R2 uses only `hellbox-public` and `hellbox-private`.
--
-- Public/open-source works may reference and deliver as much content as practical
-- from public IPFS/external public sources instead of duplicating protected bytes
-- behind Hellbox. SciVive is the first example: the ownership-gated Reader is the
-- Hellbox experience/key, not a dishonest claim that the public-domain/open source
-- book bytes are secret.
--
-- Original in-house Hellbox artwork/pages may remain private and must support
-- protected delivery. Asset access policy and physical storage location are
-- intentionally separate concepts in this schema.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- PUBLICATIONS
-- One conceptual Hellbox publication, independent of blockchain deployment.
-- `publication_key` is the canonical cross-chain identity.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publications (
    publication_key TEXT PRIMARY KEY,

    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,

    kind TEXT NOT NULL
        CHECK (kind IN ('standalone', 'serial')),

    series_key TEXT,
    series_title TEXT,
    issue_number INTEGER
        CHECK (issue_number IS NULL OR issue_number > 0),

    lifecycle TEXT NOT NULL DEFAULT 'private'
        CHECK (lifecycle IN ('private', 'announced', 'mint_live', 'circulating')),

    public_visible INTEGER NOT NULL DEFAULT 0
        CHECK (public_visible IN (0, 1)),

    presentation_class TEXT NOT NULL DEFAULT 'comic'
        CHECK (presentation_class IN ('book', 'comic', 'enhanced')),

    canonical_locale TEXT NOT NULL DEFAULT 'en',

    external_url TEXT,
    cover_asset_key TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    announced_at TEXT,
    mint_live_at TEXT,
    circulating_at TEXT,

    CHECK (
        (kind = 'standalone'
            AND series_key IS NULL
            AND issue_number IS NULL)
        OR
        (kind = 'serial'
            AND series_key IS NOT NULL
            AND issue_number IS NOT NULL)
    ),

    CHECK (
        lifecycle != 'private'
        OR public_visible = 0
    )
);

CREATE INDEX IF NOT EXISTS idx_publications_lifecycle
    ON publications (lifecycle);

CREATE INDEX IF NOT EXISTS idx_publications_public_visible
    ON publications (public_visible, lifecycle);

CREATE INDEX IF NOT EXISTS idx_publications_series
    ON publications (series_key, issue_number);


-- ---------------------------------------------------------------------------
-- PUBLICATION FEATURES
-- Publication-level capabilities. These describe the work itself and remain
-- independent of a particular chain deployment.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_features (
    publication_key TEXT PRIMARY KEY
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    reader_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (reader_enabled IN (0, 1)),

    reader_access_policy TEXT NOT NULL DEFAULT 'ownership'
        CHECK (reader_access_policy IN ('public', 'ownership')),

    sealed_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (sealed_enabled IN (0, 1)),

    vault_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (vault_enabled IN (0, 1)),

    sin_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (sin_enabled IN (0, 1)),

    evolution_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (evolution_enabled IN (0, 1)),

    easter_eggs_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (easter_eggs_enabled IN (0, 1)),

    hellforge_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (hellforge_enabled IN (0, 1)),

    token_bound_account_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (token_bound_account_enabled IN (0, 1)),

    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ---------------------------------------------------------------------------
-- CHAIN DEPLOYMENTS / PRIMARY SALE CONFIG
-- A publication may exist natively on multiple chains later.
-- No bridging. Each row is one native chain configuration.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_chain_configs (
    publication_key TEXT NOT NULL
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    chain_key TEXT NOT NULL,
    chain_id INTEGER NOT NULL
        CHECK (chain_id > 0),

    token_standard TEXT NOT NULL DEFAULT 'ERC721'
        CHECK (token_standard IN ('ERC721')),

    contract_address TEXT,
    publication_id TEXT,

    publishing_enabled INTEGER NOT NULL DEFAULT 0
        CHECK (publishing_enabled IN (0, 1)),

    max_supply INTEGER NOT NULL
        CHECK (max_supply > 0),

    payment_type TEXT NOT NULL
        CHECK (payment_type IN ('free', 'erc20', 'native')),

    payment_token_address TEXT,
    payment_token_symbol TEXT,

    price_base_units TEXT NOT NULL DEFAULT '0',
    price_display TEXT,

    max_primary_mints_per_wallet INTEGER NOT NULL
        CHECK (max_primary_mints_per_wallet > 0),

    max_per_transaction INTEGER NOT NULL
        CHECK (max_per_transaction > 0),

    royalty_bps INTEGER NOT NULL DEFAULT 0
        CHECK (royalty_bps >= 0 AND royalty_bps <= 10000),

    royalty_receiver TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (publication_key, chain_key),

    UNIQUE (chain_id, contract_address, publication_id),

    CHECK (
        payment_type != 'erc20'
        OR payment_token_address IS NOT NULL
    ),

    CHECK (
        payment_type = 'erc20'
        OR payment_token_address IS NULL
    ),

    CHECK (
        publishing_enabled = 0
        OR contract_address IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_publication_chain_configs_chain
    ON publication_chain_configs (chain_key, publishing_enabled);

CREATE INDEX IF NOT EXISTS idx_publication_chain_configs_contract
    ON publication_chain_configs (chain_id, contract_address);


-- ---------------------------------------------------------------------------
-- PUBLICATION PACKAGES
-- One normalized upload/build package for a publication.
-- Only one package should normally be active at a time.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_packages (
    package_id INTEGER PRIMARY KEY AUTOINCREMENT,

    publication_key TEXT NOT NULL
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    package_version INTEGER NOT NULL DEFAULT 1
        CHECK (package_version > 0),

    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'validated', 'active', 'retired', 'invalid')),

    schema_version TEXT NOT NULL,

    public_prefix TEXT,
    private_prefix TEXT,

    reader_manifest_key TEXT,

    package_manifest_key TEXT,

    source_sha256 TEXT,
    package_sha256 TEXT,

    provenance_json TEXT,
    license_json TEXT,

    validation_error_count INTEGER NOT NULL DEFAULT 0
        CHECK (validation_error_count >= 0),

    validation_warning_count INTEGER NOT NULL DEFAULT 0
        CHECK (validation_warning_count >= 0),

    validated_at TEXT,
    activated_at TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (publication_key, package_version)
);

CREATE INDEX IF NOT EXISTS idx_publication_packages_status
    ON publication_packages (publication_key, status);


-- ---------------------------------------------------------------------------
-- PACKAGE ASSETS
-- Logical asset inventory for a normalized publication package.
--
-- IMPORTANT:
-- `access_class` describes Hellbox product/access semantics.
-- It does NOT claim the underlying bytes are private.
--
-- Examples:
-- - SciVive reader page: access_class='reader_gated', location may be public IPFS.
-- - Hellbox original comic page: access_class='reader_gated', primary location may
--   be private R2 and served only through an authorized Reader session.
-- - cover/metadata: access_class='public', locations may include IPFS + public R2.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_assets (
    asset_id INTEGER PRIMARY KEY AUTOINCREMENT,

    package_id INTEGER NOT NULL
        REFERENCES publication_packages(package_id)
        ON DELETE CASCADE,

    role TEXT NOT NULL,
    logical_key TEXT NOT NULL,

    access_class TEXT NOT NULL
        CHECK (access_class IN ('public', 'reader_gated', 'private')),

    content_type TEXT,

    byte_size INTEGER
        CHECK (byte_size IS NULL OR byte_size >= 0),

    sha256 TEXT,

    sort_order INTEGER,

    metadata_json TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (package_id, logical_key)
);

CREATE INDEX IF NOT EXISTS idx_publication_assets_package_role
    ON publication_assets (package_id, role, sort_order);

CREATE INDEX IF NOT EXISTS idx_publication_assets_access
    ON publication_assets (access_class);


-- ---------------------------------------------------------------------------
-- ASSET LOCATIONS
-- One logical publication asset may have multiple physical/public locations.
--
-- This lets Hellbox:
-- - use existing/public IPFS for open-source material such as SciVive
-- - optionally keep a public R2 delivery/cache copy
-- - keep original in-house Reader assets in private R2
-- - preserve provenance without pretending a gated UI makes public source bytes
--   private
--
-- `locator` examples:
-- - R2:   scivive/v1/cover.jpg
-- - IPFS: ipfs://bafy.../page-001.jpg
-- - HTTPS: https://example.org/source/file.pdf
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_asset_locations (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,

    asset_id INTEGER NOT NULL
        REFERENCES publication_assets(asset_id)
        ON DELETE CASCADE,

    provider TEXT NOT NULL
        CHECK (provider IN ('r2_public', 'r2_private', 'ipfs', 'https')),

    location_role TEXT NOT NULL DEFAULT 'delivery'
        CHECK (location_role IN ('source', 'delivery', 'mirror', 'cache')),

    locator TEXT NOT NULL,

    gateway_url TEXT,

    public_retrievable INTEGER NOT NULL DEFAULT 0
        CHECK (public_retrievable IN (0, 1)),

    is_primary INTEGER NOT NULL DEFAULT 0
        CHECK (is_primary IN (0, 1)),

    priority INTEGER NOT NULL DEFAULT 100,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (provider, locator),

    CHECK (
        provider != 'r2_private'
        OR public_retrievable = 0
    ),

    CHECK (
        provider NOT IN ('ipfs', 'r2_public')
        OR public_retrievable = 1
    )
);

CREATE INDEX IF NOT EXISTS idx_asset_locations_asset
    ON publication_asset_locations (asset_id, is_primary DESC, priority ASC);

CREATE INDEX IF NOT EXISTS idx_asset_locations_provider
    ON publication_asset_locations (provider, public_retrievable);


-- ---------------------------------------------------------------------------
-- LIFECYCLE HISTORY
-- Append-only history of meaningful publication lifecycle transitions.
-- Actor address remains nullable because some transitions are system/import
-- actions rather than wallet-authorized actions.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_lifecycle_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,

    publication_key TEXT NOT NULL
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    from_lifecycle TEXT
        CHECK (
            from_lifecycle IS NULL
            OR from_lifecycle IN ('private', 'announced', 'mint_live', 'circulating')
        ),

    to_lifecycle TEXT NOT NULL
        CHECK (to_lifecycle IN ('private', 'announced', 'mint_live', 'circulating')),

    actor_address TEXT,
    reason TEXT,
    metadata_json TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_publication_lifecycle_events_publication
    ON publication_lifecycle_events (publication_key, event_id);


-- ---------------------------------------------------------------------------
-- VALIDATION RUNS
-- Keeps package validation observable and auditable without stuffing result
-- details into the publication row.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS publication_validation_runs (
    validation_id INTEGER PRIMARY KEY AUTOINCREMENT,

    package_id INTEGER NOT NULL
        REFERENCES publication_packages(package_id)
        ON DELETE CASCADE,

    validator_version TEXT NOT NULL,

    passed INTEGER NOT NULL
        CHECK (passed IN (0, 1)),

    error_count INTEGER NOT NULL DEFAULT 0
        CHECK (error_count >= 0),

    warning_count INTEGER NOT NULL DEFAULT 0
        CHECK (warning_count >= 0),

    report_json TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_publication_validation_runs_package
    ON publication_validation_runs (package_id, validation_id);


-- ---------------------------------------------------------------------------
-- UPDATE TIMESTAMP TRIGGERS
-- D1/SQLite has no automatic ON UPDATE timestamp behavior.
-- ---------------------------------------------------------------------------

CREATE TRIGGER IF NOT EXISTS trg_publications_updated_at
AFTER UPDATE ON publications
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
    UPDATE publications
    SET updated_at = CURRENT_TIMESTAMP
    WHERE publication_key = NEW.publication_key;
END;

CREATE TRIGGER IF NOT EXISTS trg_publication_features_updated_at
AFTER UPDATE ON publication_features
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
    UPDATE publication_features
    SET updated_at = CURRENT_TIMESTAMP
    WHERE publication_key = NEW.publication_key;
END;

CREATE TRIGGER IF NOT EXISTS trg_publication_chain_configs_updated_at
AFTER UPDATE ON publication_chain_configs
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
    UPDATE publication_chain_configs
    SET updated_at = CURRENT_TIMESTAMP
    WHERE publication_key = NEW.publication_key
      AND chain_key = NEW.chain_key;
END;

CREATE TRIGGER IF NOT EXISTS trg_publication_packages_updated_at
AFTER UPDATE ON publication_packages
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
    UPDATE publication_packages
    SET updated_at = CURRENT_TIMESTAMP
    WHERE package_id = NEW.package_id;
END;
