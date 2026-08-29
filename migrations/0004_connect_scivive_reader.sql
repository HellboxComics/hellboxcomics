-- HELLBOX COMICS
-- Gate 2 / Migration 0004
-- Connect SciVive package v1 to the verified protected Reader delivery.
--
-- This migration DOES NOT publish SciVive, activate minting, or mark the
-- package validated. Gate 2 remains in progress until the Worker and live
-- Reader vertical slice successfully consume this configuration.
--
-- Verified before this migration:
--   - Reader manifest: 461 pages
--   - Private R2 bucket: hellbox-private
--   - Remote objects verified byte-for-byte: 462
--   - Manifest key: comics/scivive/001/reader/manifest.json
--   - Page prefix: comics/scivive/001/reader/pages/

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- PACKAGE READER DELIVERY POINTERS
-- `private_prefix` is the protected Reader page prefix consumed by the Worker.
-- `reader_manifest_key` is the protected R2 object containing the manifest.
--
-- Keep status='draft'. The storage layer is verified, but the full Reader
-- vertical slice has not yet passed live application validation.
-- ---------------------------------------------------------------------------

UPDATE publication_packages
SET
    private_prefix = 'comics/scivive/001/reader/pages/',
    reader_manifest_key = 'comics/scivive/001/reader/manifest.json',
    validation_error_count = 0,
    validation_warning_count = 1
WHERE publication_key = 'scivive'
  AND package_version = 1;

-- ---------------------------------------------------------------------------
-- DURABLE READER MANIFEST ASSET
-- The manifest is Reader-gated product data and its primary delivery location
-- is protected R2. Individual page objects are enumerated by this manifest,
-- avoiding 461 redundant D1 rows for a deterministic page set.
-- ---------------------------------------------------------------------------

INSERT INTO publication_assets (
    package_id,
    role,
    logical_key,
    access_class,
    content_type,
    byte_size,
    sha256,
    sort_order,
    metadata_json
) VALUES (
    (SELECT package_id
       FROM publication_packages
      WHERE publication_key = 'scivive'
        AND package_version = 1),
    'reader_manifest',
    'reader-manifest',
    'reader_gated',
    'application/json',
    77269,
    '5d81ff3ca7747756a523ff5835518ab76584cbf0640f4376b3290cb6b8d9ec88',
    20,
    '{"schemaVersion":"1.0.0","manifestVersion":1,"presentationClass":"book","renderMode":"facsimile","layout":"paged","fit":"page","pageCount":461,"pageMediaType":"image/webp","pagePrefix":"comics/scivive/001/reader/pages/","remoteObjectCount":462,"remotePageCount":461,"remoteByteVerification":"passed","sourceBytesRemainPublic":true}'
);

INSERT INTO publication_asset_locations (
    asset_id,
    provider,
    location_role,
    locator,
    gateway_url,
    public_retrievable,
    is_primary,
    priority
) VALUES (
    (SELECT a.asset_id
       FROM publication_assets a
       JOIN publication_packages p
         ON p.package_id = a.package_id
      WHERE p.publication_key = 'scivive'
        AND p.package_version = 1
        AND a.logical_key = 'reader-manifest'),
    'r2_private',
    'delivery',
    'comics/scivive/001/reader/manifest.json',
    NULL,
    0,
    1,
    10
);

-- ---------------------------------------------------------------------------
-- GATE 2 STORAGE VALIDATION RECORD
-- The remaining warning is the same intentionally unresolved license-evidence
-- warning from Gate 1. The former Reader-manifest-pending warning is resolved.
-- ---------------------------------------------------------------------------

INSERT INTO publication_validation_runs (
    package_id,
    validator_version,
    passed,
    error_count,
    warning_count,
    report_json
) VALUES (
    (SELECT package_id
       FROM publication_packages
      WHERE publication_key = 'scivive'
        AND package_version = 1),
    'gate2-private-reader-delivery/1.0.0',
    1,
    0,
    1,
    '{"scope":"gate2-private-reader-delivery","schemaVersion":"1.0.0","checks":{"readerManifestContract":"passed","sourcePdfIntegrity":"passed","renderedPageCount":461,"privateR2RemoteObjectCount":462,"privateR2RemotePageCount":461,"privateR2ByteVerification":"passed","d1ReaderDeliveryBinding":"passed","liveReaderVerticalSlice":"pending"},"delivery":{"provider":"r2_private","bucket":"hellbox-private","manifestKey":"comics/scivive/001/reader/manifest.json","pagePrefix":"comics/scivive/001/reader/pages/","manifestByteSize":77269,"manifestSha256":"5d81ff3ca7747756a523ff5835518ab76584cbf0640f4376b3290cb6b8d9ec88"},"warnings":["Public source availability is verified; no specific reuse/open-license claim is encoded as verified."],"notes":"Protected Reader storage is verified and durably bound. Package remains draft until the Worker and live Reader vertical slice pass Gate 2 validation."}'
);
