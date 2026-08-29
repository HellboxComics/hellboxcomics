-- HELLBOX COMICS
-- Gate 1 / Migration 0002
-- Refine publication asset location identity.
--
-- Why this exists:
-- Migration 0001 made (provider, locator) globally unique. That is too strict.
-- One public source URL may legitimately describe multiple logical assets in the
-- same publication package (for example, one Internet Archive item containing
-- both the SciVive PDF and EPUB).
--
-- Correct rule:
-- A location must be unique only for a specific logical asset:
--     UNIQUE (asset_id, provider, locator)
--
-- This migration preserves any existing rows and location_id values.

ALTER TABLE publication_asset_locations
RENAME TO publication_asset_locations_legacy;

DROP INDEX IF EXISTS idx_asset_locations_asset;
DROP INDEX IF EXISTS idx_asset_locations_provider;

CREATE TABLE publication_asset_locations (
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

    UNIQUE (asset_id, provider, locator),

    CHECK (
        provider != 'r2_private'
        OR public_retrievable = 0
    ),

    CHECK (
        provider NOT IN ('ipfs', 'r2_public')
        OR public_retrievable = 1
    )
);

INSERT INTO publication_asset_locations (
    location_id,
    asset_id,
    provider,
    location_role,
    locator,
    gateway_url,
    public_retrievable,
    is_primary,
    priority,
    created_at
)
SELECT
    location_id,
    asset_id,
    provider,
    location_role,
    locator,
    gateway_url,
    public_retrievable,
    is_primary,
    priority,
    created_at
FROM publication_asset_locations_legacy;

DROP TABLE publication_asset_locations_legacy;

CREATE INDEX idx_asset_locations_asset
    ON publication_asset_locations (asset_id, is_primary DESC, priority ASC);

CREATE INDEX idx_asset_locations_provider
    ON publication_asset_locations (provider, public_retrievable);
