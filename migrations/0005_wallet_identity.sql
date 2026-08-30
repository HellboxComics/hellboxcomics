-- Hellbox Comics
-- Gate 3 — Identity, Ownership & Archive
-- Migration 0005: durable wallet identity challenge/session boundary
--
-- Goal:
-- Move wallet-auth challenge/session authority out of temporary R2 objects and
-- into D1 so wallet identity can become durable, single-use, auditable, and
-- revocable before ownership indexing is introduced.
--
-- This migration does NOT:
-- - grant publication ownership
-- - index NFT ownership
-- - make SciVive public
-- - deploy or configure an NFT contract
-- - change Reader authorization yet
--
-- Wallet addresses are stored normalized/lowercase by application code.
-- Unix timestamps are INTEGER seconds to match the Worker auth/session model.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- WALLET AUTH CHALLENGES
-- One short-lived signing challenge proving control of an EVM address.
--
-- `consumed_at` provides the durable single-use boundary. The Worker will
-- verify the signature first, then atomically claim the challenge with a
-- conditional UPDATE ... RETURNING so concurrent/replayed verification cannot
-- mint multiple sessions from one challenge.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS wallet_auth_challenges (
    challenge_id TEXT PRIMARY KEY,

    wallet_address TEXT NOT NULL,
    chain_id INTEGER NOT NULL
        CHECK (chain_id > 0),

    nonce TEXT NOT NULL UNIQUE,
    message TEXT NOT NULL,

    issued_at INTEGER NOT NULL
        CHECK (issued_at > 0),

    expires_at INTEGER NOT NULL
        CHECK (expires_at > issued_at),

    consumed_at INTEGER
        CHECK (consumed_at IS NULL OR consumed_at >= issued_at),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_auth_challenges_wallet
    ON wallet_auth_challenges (wallet_address, issued_at DESC);

CREATE INDEX IF NOT EXISTS idx_wallet_auth_challenges_expiry
    ON wallet_auth_challenges (expires_at, consumed_at);


-- ---------------------------------------------------------------------------
-- WALLET SESSIONS
-- Short server-authoritative wallet identity sessions.
--
-- The browser may still carry a signed bearer token, but that token must name
-- a `session_id` that exists here, is unexpired, and has not been revoked.
-- This gives Hellbox a real server-side identity boundary and future revocation
-- capability without pretending that wallet identity equals publication
-- ownership.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS wallet_sessions (
    session_id TEXT PRIMARY KEY,

    wallet_address TEXT NOT NULL,
    chain_id INTEGER NOT NULL
        CHECK (chain_id > 0),

    scope TEXT NOT NULL DEFAULT 'wallet_identity'
        CHECK (scope = 'wallet_identity'),

    issued_at INTEGER NOT NULL
        CHECK (issued_at > 0),

    expires_at INTEGER NOT NULL
        CHECK (expires_at > issued_at),

    revoked_at INTEGER
        CHECK (revoked_at IS NULL OR revoked_at >= issued_at),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_sessions_wallet
    ON wallet_sessions (wallet_address, expires_at DESC);

CREATE INDEX IF NOT EXISTS idx_wallet_sessions_active
    ON wallet_sessions (expires_at, revoked_at);
