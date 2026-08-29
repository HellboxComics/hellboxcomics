-- HELLBOX COMICS
-- Gate 1 / Migration 0003
-- Seed SciVive as Hellbox's first durable publication record.
--
-- SciVive remains PRIVATE and its package remains DRAFT.
-- The publication manifest, PulseChain configuration, source integrity,
-- and public IPFS persistence are real; Gate 2 still owns the production
-- Reader manifest and Reader vertical slice.

PRAGMA foreign_keys = ON;

-- Publication identity.
INSERT INTO publications (
    publication_key, title, slug, kind, series_key, series_title, issue_number,
    lifecycle, public_visible, presentation_class, canonical_locale,
    external_url, cover_asset_key
) VALUES (
    'scivive', 'SciVive', 'scivive', 'standalone',
    NULL, NULL, NULL,
    'private', 0, 'book',
    'en', 'https://hellboxcomics.com', 'cover'
);

-- Publication-level product features.
INSERT INTO publication_features (
    publication_key, reader_enabled, reader_access_policy, sealed_enabled,
    vault_enabled, sin_enabled, evolution_enabled, easter_eggs_enabled,
    hellforge_enabled, token_bound_account_enabled
) VALUES (
    'scivive', 1, 'ownership',
    0, 0, 0,
    0, 0,
    0, 0
);

-- PulseChain publication configuration. Publishing stays disabled until
-- the real Hellbox ERC-721 master contract is deployed/configured.
INSERT INTO publication_chain_configs (
    publication_key, chain_key, chain_id, token_standard, contract_address,
    publication_id, publishing_enabled, max_supply, payment_type,
    payment_token_address, payment_token_symbol, price_base_units, price_display,
    max_primary_mints_per_wallet, max_per_transaction, royalty_bps, royalty_receiver
) VALUES (
    'scivive', 'pulsechain', 369, 'ERC721',
    NULL, NULL, 0,
    5555, 'free', NULL,
    NULL, '0',
    'Free', 1,
    1, 369, NULL
);

-- Package v1. It is structurally/source-integrity checked but intentionally
-- remains draft until Gate 2 creates the production Reader manifest.
INSERT INTO publication_packages (
    publication_key, package_version, status, schema_version, public_prefix,
    private_prefix, reader_manifest_key, package_manifest_key, source_sha256,
    package_sha256, provenance_json, license_json, validation_error_count,
    validation_warning_count
) VALUES (
    'scivive', 1, 'draft', '1.0.0',
    'comics/scivive/001/', NULL,
    NULL, NULL,
    NULL, NULL,
    '{"author":"Richard Heart","hellboxRole":"publisher_only","sourceNotes":"SciVive is being preserved as the existing source work. Hellbox will not rewrite, finish, sanitize, or claim authorship of the source text. Public source availability and Hellbox Reader access policy are intentionally separate. The PDF and EPUB currently pinned through Filebase were independently fetched through ipfs.io and verified byte-for-byte against the canonical source SHA-256 fingerprints recorded in this manifest.","sources":[{"sourceType":"internet_archive","locator":"https://archive.org/details/SciViveBookOutline_201802","publicRetrievable":true,"uploadedBy":"RichardHeart","observedAt":null,"notes":"Canonical public-source record currently tracked by Hellbox. Use as provenance/fallback; record content-addressed IPFS CIDs before the package advances from draft to validated."}]}',
    '{"status":"public_source_unverified","licenseName":null,"licenseUrl":null,"evidence":[{"locator":"https://archive.org/details/SciViveBookOutline_201802","description":"Publicly retrievable source record. This establishes public availability, not by itself a specific reuse license."}],"notes":"The project currently treats SciVive as a publicly available source work and the user identifies it as open-source. Hellbox will not encode a specific legal license as verified until explicit license evidence is captured."}',
    0, 2
);

-- Asset: cover
INSERT INTO publication_assets (
    package_id, role, logical_key, access_class, content_type,
    byte_size, sha256, sort_order, metadata_json
) VALUES (
    (SELECT package_id FROM publication_packages
     WHERE publication_key = 'scivive' AND package_version = 1),
    'cover', 'cover', 'public',
    'image/jpeg', NULL,
    NULL, 0,
    '{"sourceFileName":"cover.jpg"}'
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'cover'),
    'r2_public', 'delivery', 'comics/scivive/001/images/cover/cover.jpg',
    'https://cdn.hellboxcomics.com/comics/scivive/001/images/cover/cover.jpg', 1,
    1, 10
);

-- Asset: source-pdf
INSERT INTO publication_assets (
    package_id, role, logical_key, access_class, content_type,
    byte_size, sha256, sort_order, metadata_json
) VALUES (
    (SELECT package_id FROM publication_packages
     WHERE publication_key = 'scivive' AND package_version = 1),
    'reader_source', 'source-pdf', 'reader_gated',
    'application/pdf', 8433084,
    'd105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548', 10,
    '{"sourceFileName":"sciVive.pdf","pageCount":461,"verifiedIpfsCid":"QmWKTwYfhMDksDwz5eMwsw8YFJC8yYwPLFZxWAbUyDS2EH","ipfsPinProvider":"Filebase","ipfsBucket":"hellbox-publications","ipfsObjectPath":"scivive/source/sciVive.pdf","independentGatewayVerification":{"gateway":"https://ipfs.io/ipfs/","verifiedByteSize":8433084,"verifiedSha256":"d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548"}}'
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-pdf'),
    'ipfs', 'delivery', 'ipfs://QmWKTwYfhMDksDwz5eMwsw8YFJC8yYwPLFZxWAbUyDS2EH',
    NULL, 1,
    1, 10
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-pdf'),
    'https', 'source', 'https://archive.org/details/SciViveBookOutline_201802',
    NULL, 1,
    0, 50
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-pdf'),
    'r2_public', 'mirror', 'comics/scivive/001/book/sciVive.pdf',
    'https://cdn.hellboxcomics.com/comics/scivive/001/book/sciVive.pdf', 1,
    0, 100
);

-- Asset: source-epub
INSERT INTO publication_assets (
    package_id, role, logical_key, access_class, content_type,
    byte_size, sha256, sort_order, metadata_json
) VALUES (
    (SELECT package_id FROM publication_packages
     WHERE publication_key = 'scivive' AND package_version = 1),
    'reader_source', 'source-epub', 'reader_gated',
    'application/epub+zip', 187192050,
    'a6bbaadbb31eb8baecd0ba156fbeafbd9528d8cd93e38023fa144131bffa67d3', 20,
    '{"sourceFileName":"sciVive.epub","zipEntryCount":741,"verifiedIpfsCid":"Qmdaq6fSFu9fUwJ8okygjmAFtczmbTFxZicbSyFWRLEjxz","ipfsPinProvider":"Filebase","ipfsBucket":"hellbox-publications","ipfsObjectPath":"scivive/source/scivive.epub","independentGatewayVerification":{"gateway":"https://ipfs.io/ipfs/","verifiedByteSize":187192050,"verifiedSha256":"a6bbaadbb31eb8baecd0ba156fbeafbd9528d8cd93e38023fa144131bffa67d3"}}'
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-epub'),
    'ipfs', 'delivery', 'ipfs://Qmdaq6fSFu9fUwJ8okygjmAFtczmbTFxZicbSyFWRLEjxz',
    NULL, 1,
    1, 10
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-epub'),
    'https', 'source', 'https://archive.org/details/SciViveBookOutline_201802',
    NULL, 1,
    0, 50
);

INSERT INTO publication_asset_locations (
    asset_id, provider, location_role, locator, gateway_url,
    public_retrievable, is_primary, priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'source-epub'),
    'r2_public', 'mirror', 'comics/scivive/001/book/sciVive.epub',
    'https://cdn.hellboxcomics.com/comics/scivive/001/book/sciVive.epub', 1,
    0, 100
);

-- Initial lifecycle audit event.
INSERT INTO publication_lifecycle_events (
    publication_key, from_lifecycle, to_lifecycle, actor_address, reason, metadata_json
) VALUES (
    'scivive', NULL, 'private', NULL,
    'Initial Gate 1 durable publication import.',
    '{"import":"gate1-durable-publication-seed","packageVersion":1,"schemaVersion":"1.0.0","ipfsVerified":true}'
);

-- Gate 1 validation record: schema + pinned source integrity passed.
-- Warnings are deliberate and do not advance the package out of draft.
INSERT INTO publication_validation_runs (
    package_id, validator_version, passed, error_count, warning_count, report_json
) VALUES (
    (SELECT package_id FROM publication_packages
     WHERE publication_key = 'scivive' AND package_version = 1),
    'gate1-package-validator/1.0.0',
    1, 0, 2,
    '{"scope":"gate1-publication-seed","schemaVersion":"1.0.0","checks":{"publicationManifestSchema":"passed","ipfsPdfIntegrity":"passed","ipfsEpubIntegrity":"passed","readerManifest":"pending-gate2","specificReuseLicense":"not-verified"},"warnings":["Production Reader manifest is intentionally deferred to Gate 2.","Public source availability is verified; no specific reuse/open-license claim is encoded as verified."]}'
);
