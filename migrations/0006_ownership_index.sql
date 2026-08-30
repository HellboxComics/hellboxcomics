-- Hellbox Comics
-- Gate 3 — Identity, Ownership & Archive
-- Migration 0006: durable on-chain ownership verification index
--
-- Goal:
-- Add the durable D1 ownership-evidence layer used by Archive and Reader.
--
-- IMPORTANT AUTHORITY RULE:
-- The blockchain remains the source of truth for NFT ownership.
-- D1 does NOT grant ownership. It stores the latest successful on-chain
-- observation plus a bounded validity window so Hellbox can make fast,
-- auditable access decisions without pretending cached state is permanent.
--
-- This migration does NOT:
-- - mint or transfer NFTs
-- - deploy or configure contracts
-- - make SciVive public
-- - grant ownership by database insertion
-- - change Reader authorization yet
--
-- Wallet and contract addresses are normalized/lowercase by application code.
-- Unix timestamps are INTEGER seconds to match the Worker session model.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- CURRENT VERIFIED PUBLICATION HOLDINGS
-- One current aggregate ownership observation per wallet/publication/chain.
--
-- For the current ERC-721 publication model, `balance > 0` means the wallet
-- owns at least one token from that publication's native deployment.
--
-- Only a successful on-chain verification may write/update this table.
-- Failed RPC checks belong in the immutable verification-event log below and
-- must never silently turn an existing owned row into not-owned.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS wallet_publication_holdings (
    wallet_address TEXT NOT NULL,

    publication_key TEXT NOT NULL
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    chain_id INTEGER NOT NULL
        CHECK (chain_id > 0),

    contract_address TEXT NOT NULL,

    token_standard TEXT NOT NULL DEFAULT 'ERC721'
        CHECK (token_standard = 'ERC721'),

    balance INTEGER NOT NULL
        CHECK (balance >= 0),

    ownership_status TEXT NOT NULL
        CHECK (ownership_status IN ('owned', 'not_owned')),

    observed_block_number INTEGER
        CHECK (observed_block_number IS NULL OR observed_block_number >= 0),

    observed_block_hash TEXT,

    verified_at INTEGER NOT NULL
        CHECK (verified_at > 0),

    valid_until INTEGER NOT NULL
        CHECK (valid_until > verified_at),

    verification_source TEXT NOT NULL
        CHECK (verification_source IN ('rpc_public', 'rpc_byte_fallback')),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (wallet_address, publication_key, chain_id),

    CHECK (
        (ownership_status = 'owned' AND balance > 0)
        OR
        (ownership_status = 'not_owned' AND balance = 0)
    )
);

CREATE INDEX IF NOT EXISTS idx_wallet_publication_holdings_wallet
    ON wallet_publication_holdings (
        wallet_address,
        ownership_status,
        valid_until DESC
    );

CREATE INDEX IF NOT EXISTS idx_wallet_publication_holdings_publication
    ON wallet_publication_holdings (
        publication_key,
        chain_id,
        ownership_status
    );

CREATE INDEX IF NOT EXISTS idx_wallet_publication_holdings_expiry
    ON wallet_publication_holdings (
        valid_until,
        ownership_status
    );


-- ---------------------------------------------------------------------------
-- OWNERSHIP VERIFICATION EVENTS
-- Immutable audit trail of on-chain ownership checks.
--
-- Successful checks may update `wallet_publication_holdings`.
-- Error events record that verification failed; an error does not prove
-- non-ownership and therefore must not revoke a previously verified holding.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ownership_verification_events (
    verification_id TEXT PRIMARY KEY,

    wallet_address TEXT NOT NULL,

    publication_key TEXT NOT NULL
        REFERENCES publications(publication_key)
        ON DELETE CASCADE,

    chain_id INTEGER NOT NULL
        CHECK (chain_id > 0),

    contract_address TEXT NOT NULL,

    token_standard TEXT NOT NULL DEFAULT 'ERC721'
        CHECK (token_standard = 'ERC721'),

    result TEXT NOT NULL
        CHECK (result IN ('owned', 'not_owned', 'error')),

    balance INTEGER
        CHECK (balance IS NULL OR balance >= 0),

    observed_block_number INTEGER
        CHECK (observed_block_number IS NULL OR observed_block_number >= 0),

    observed_block_hash TEXT,

    verified_at INTEGER NOT NULL
        CHECK (verified_at > 0),

    valid_until INTEGER
        CHECK (valid_until IS NULL OR valid_until > verified_at),

    verification_source TEXT NOT NULL
        CHECK (verification_source IN ('rpc_public', 'rpc_byte_fallback')),

    error_code TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (result = 'owned'
            AND balance IS NOT NULL
            AND balance > 0
            AND valid_until IS NOT NULL
            AND error_code IS NULL)
        OR
        (result = 'not_owned'
            AND balance = 0
            AND valid_until IS NOT NULL
            AND error_code IS NULL)
        OR
        (result = 'error'
            AND balance IS NULL
            AND valid_until IS NULL
            AND error_code IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_ownership_verification_events_wallet
    ON ownership_verification_events (
        wallet_address,
        verified_at DESC
    );

CREATE INDEX IF NOT EXISTS idx_ownership_verification_events_publication
    ON ownership_verification_events (
        publication_key,
        chain_id,
        verified_at DESC
    );


-- ---------------------------------------------------------------------------
-- ACTIVE OWNERSHIP VIEW
-- Convenience view for Archive / Reader authorization.
--
-- A row appears here only while a successful on-chain owned observation is
-- still inside its validity window. The Worker must refresh stale/missing rows
-- against chain RPC before granting ownership-dependent access.
-- ---------------------------------------------------------------------------

CREATE VIEW IF NOT EXISTS active_wallet_publication_ownerships AS
SELECT
    wallet_address,
    publication_key,
    chain_id,
    contract_address,
    token_standard,
    balance,
    observed_block_number,
    observed_block_hash,
    verified_at,
    valid_until,
    verification_source
FROM wallet_publication_holdings
WHERE ownership_status = 'owned'
  AND balance > 0
  AND valid_until > unixepoch();
