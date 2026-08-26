// Hellbox Comics Cloudflare Worker
// Architecture: publication-key based, chain-aware, ERC-721 ready,
// public PulseChain RPC primary + HairyLabs Byte fallback,
// wallet-signature auth, protected reader, and contract-ready mint APIs.
//
// Required bindings:
//   R2: PUBLIC_BUCKET
//   R2: PRIVATE_BUCKET
//   Assets: ASSETS
//
// Required runtime secrets:
//   BYTE_RPC_URL
//   HELLBOX_SESSION_SECRET
//
// No contract is deployed yet. SciVive is intentionally PRIVATE by default.
// When the HellboxNFT contract is deployed later, only registry configuration
// and transaction encoding helpers need to be updated.

const API_VERSION = "hellbox-v2";

const LIFECYCLE = Object.freeze({
  PRIVATE: "private",
  ANNOUNCED: "announced",
  MINT_LIVE: "mint_live",
  CIRCULATING: "circulating",
});

const OWNERSHIP = Object.freeze({
  MISSING: "missing",
  OWNED: "owned",
  EVOLVED: "evolved",
  UNAVAILABLE: "unavailable",
});

const MINT_STATE = Object.freeze({
  UNAVAILABLE: "unavailable",
  UPCOMING: "upcoming",
  LIVE: "live",
  SOLD_OUT: "sold_out",
  ALREADY_OWNED: "already_owned",
  ELIGIBLE: "eligible",
  NOT_ELIGIBLE: "not_eligible",
});

const PAYMENT_TYPE = Object.freeze({
  FREE: "free",
  ERC20: "erc20",
  NATIVE: "native",
});

const PUBLICATION_KIND = Object.freeze({
  STANDALONE: "standalone",
  SERIAL: "serial",
});

const AUTH = Object.freeze({
  challengeLifetimeSeconds: 300,
  sessionLifetimeSeconds: 1800,
  challengePrefix: "auth/challenges/",
  sessionIssuer: "hellboxcomics",
  version: 2,
});

const ALLOWED_ORIGINS = new Set([
  "https://test-hellboxcomics.harrow-harrow.workers.dev",
  "https://hellboxcomics.harrow-harrow.workers.dev",
  "https://hellboxcomics.com",
  "https://www.hellboxcomics.com",
]);

const CHAINS = Object.freeze({
  pulsechain: {
    key: "pulsechain",
    name: "PulseChain",
    chainId: 369,
    chainIdHex: "0x171",
    nativeSymbol: "PLS",

    // Public PulseChain RPC is now PRIMARY.
    rpcPrimary: "https://rpc.pulsechain.com",

    // HairyLabs Byte is our private BACKUP.
    rpcFallbackEnv: "BYTE_RPC_URL",

    stablecoins: {
      dai: {
        symbol: "DAI",
        name: "DAI on PulseChain",
        address: "0xefD766cCb38EaF1dfd701853BFCe31359239F305",
        decimals: 18,
      },
    },
  },
});

// ============================================================
// PUBLICATION REGISTRY
// ============================================================
//
// SciVive is:
// - standalone
// - NOT an issue
// - hidden/private until intentionally launched
// - free
// - 5,555 supply
// - one primary mint per wallet
// - one per transaction
// - 3.69% royalty
// - no SIN, vault, seal, evolution, easter eggs, or Hellforge
//
// Contract fields remain null until HellboxNFT is deployed.

const PUBLICATION_REGISTRY = Object.freeze([
  {
    publicationKey: "scivive",

    title: "SciVive",

    kind: PUBLICATION_KIND.STANDALONE,

    seriesKey: null,
    seriesTitle: null,
    issueNumber: null,

    lifecycle: LIFECYCLE.PRIVATE,

    publicVisible: false,

    chainKey: "pulsechain",

    deployment: {
      contractAddress: null,
      publicationId: null,
      tokenStandard: "ERC721",
    },

    supply: {
      max: 5555,
    },

    mint: {
      enabled: false,

      paymentType: PAYMENT_TYPE.FREE,

      paymentToken: null,

      priceDisplay: "FREE",

      priceBaseUnits: "0",

      maxPrimaryMintsPerWallet: 1,

      maxPerTransaction: 1,

      mintFunction: null,
    },

    royalty: {
      bps: 369,
      percentDisplay: "3.69%",
      receiver: null,
    },

    features: {
      reader: true,

      sealed: false,

      vault: false,

      sin: false,

      evolution: false,

      easterEggs: false,

      hellforge: false,

      tokenBoundAccount: true,
    },

    metadata: {
      image: null,

      animationUrl: null,

      externalUrl: "https://hellboxcomics.com",
    },

    reader: {
      enabled: true,

      // For now this uses the existing private-reader architecture.
      //
      // Later SciVive may use public/IPFS reader assets after ownership
      // verification because the ebook itself is already public elsewhere.

      sourceMode: "private",

      manifestKey:
        "comics/scivive/private/reader/manifest.json",

      privatePrefix:
        "comics/scivive/private/",
    },

    press: {
      eyebrow: "FREE MINT",

      description:
        "Standalone SciVive digital collectible.",
    },
  },
]);

// ============================================================
// LEGACY ROUTE MAP
// ============================================================
//
// Current frontend may still use old slug + issue routes.
//
// We are phasing those out.
//
// SciVive is intentionally NOT mapped here because it is NOT an issue.

const LEGACY_SLUG_MAP = Object.freeze({});

// ============================================================
// WORKER ENTRY
// ============================================================

export default {
  async fetch(request, env, ctx) {
    try {
      const url = new URL(request.url);

      if (request.method === "OPTIONS") {
        return handleOptions(request);
      }

      if (url.pathname.startsWith("/api/")) {
        return await handleApi(
          request,
          env,
          ctx,
          url
        );
      }

      if (env.ASSETS) {
        return env.ASSETS.fetch(request);
      }

      return textResponse(
        "Hellbox Comics Worker",
        200,
        request
      );
    } catch (error) {
      console.error(
        "Unhandled Worker error:",
        error
      );

      return jsonResponse(
        {
          ok: false,

          error: "internal_error",

          message:
            safeErrorMessage(error),
        },
        500,
        request
      );
    }
  },
};

// ============================================================
// API ROUTER
// ============================================================

async function handleApi(
  request,
  env,
  ctx,
  url
) {
  const method =
    request.method.toUpperCase();

  const path =
    url.pathname;

  // ----------------------------------------------------------
  // HEALTH
  // ----------------------------------------------------------

  if (
    method === "GET" &&
    path === "/api/health"
  ) {
    return handleHealth(
      request,
      env
    );
  }

  if (
    method === "GET" &&
    path === "/api/runtime-bindings"
  ) {
    return handleRuntimeBindings(
      request,
      env
    );
  }

  if (
    method === "GET" &&
    path === "/api/node-health"
  ) {
    return handleNodeHealth(
      request,
      env
    );
  }

  if (
    method === "GET" &&
    path === "/api/chain-status"
  ) {
    return handleChainStatus(
      request,
      env
    );
  }

  // ----------------------------------------------------------
  // AUTH
  // ----------------------------------------------------------

  if (
    method === "GET" &&
    path === "/api/auth/status"
  ) {
    return handleAuthStatus(
      request,
      env
    );
  }

  if (
    method === "POST" &&
    path === "/api/auth/challenge"
  ) {
    return handleAuthChallenge(
      request,
      env
    );
  }

  if (
    method === "POST" &&
    path === "/api/auth/verify"
  ) {
    return handleAuthVerify(
      request,
      env
    );
  }

  if (
    method === "GET" &&
    path === "/api/auth/session"
  ) {
    return handleAuthSession(
      request,
      env
    );
  }

  // ----------------------------------------------------------
  // PUBLICATION ENGINE
  // ----------------------------------------------------------

  if (
    method === "GET" &&
    path === "/api/publication-status"
  ) {
    return handlePublicationStatus(
      request
    );
  }

  if (
    method === "GET" &&
    path === "/api/press"
  ) {
    return handlePress(
      request
    );
  }

  if (
    method === "GET" &&
    path === "/api/publications"
  ) {
    return handlePublications(
      request
    );
  }

  if (
    method === "GET" &&
    path === "/api/collection"
  ) {
    return handleCollection(
      request,
      env,
      url
    );
  }

  if (
    method === "GET" &&
    path === "/api/wallet-status"
  ) {
    return handleWalletStatus(
      request,
      env,
      url
    );
  }

  // ----------------------------------------------------------
  // NEW PUBLICATION KEY ROUTES
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/publications\/([a-z0-9-]+)$/i
      );

    if (
      match &&
      method === "GET"
    ) {
      return handlePublication(
        request,
        match[1]
      );
    }
  }

  // ----------------------------------------------------------
  // MINT STATUS
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/mint\/([a-z0-9-]+)\/status$/i
      );

    if (
      match &&
      method === "GET"
    ) {
      return handleMintStatus(
        request,
        env,
        url,
        match[1]
      );
    }
  }

  // ----------------------------------------------------------
  // MINT PREPARE
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/mint\/([a-z0-9-]+)\/prepare$/i
      );

    if (
      match &&
      method === "POST"
    ) {
      return handleMintPrepare(
        request,
        env,
        match[1]
      );
    }
  }

  // ----------------------------------------------------------
  // MINT CONFIRM
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/mint\/([a-z0-9-]+)\/confirm$/i
      );

    if (
      match &&
      method === "POST"
    ) {
      return handleMintConfirm(
        request,
        env,
        match[1]
      );
    }
  }

  // ----------------------------------------------------------
  // READER ASSET
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/reader\/([a-z0-9-]+)\/asset\/([a-zA-Z0-9._-]+)$/i
      );

    if (
      match &&
      method === "GET"
    ) {
      return handleReaderAsset(
        request,
        env,
        match[1],
        match[2]
      );
    }
  }

  // ----------------------------------------------------------
  // READER MANIFEST
  // ----------------------------------------------------------

  {
    const match =
      path.match(
        /^\/api\/reader\/([a-z0-9-]+)$/i
      );

    if (
      match &&
      method === "GET"
    ) {
      return handleReaderManifest(
        request,
        env,
        match[1]
      );
    }
  }

  // ----------------------------------------------------------
  // TEMPORARY LEGACY COMPATIBILITY
  // ----------------------------------------------------------

  const legacyResponse =
    await handleLegacyApi(
      request,
      env,
      url
    );

  if (legacyResponse) {
    return legacyResponse;
  }

  // ----------------------------------------------------------
  // NOT FOUND
  // ----------------------------------------------------------

  return jsonResponse(
    {
      ok: false,

      error: "not_found",

      message:
        "API route not found.",
    },
    404,
    request
  );
}

// ============================================================
// LEGACY API SUPPORT
// ============================================================

async function handleLegacyApi(
  request,
  env,
  url
) {
  const method =
    request.method.toUpperCase();

  const path =
    url.pathname;

  let match =
    path.match(
      /^\/api\/publication\/([a-z0-9-]+)\/(\d+)$/i
    );

  if (
    match &&
    method === "GET"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return jsonResponse(
      {
        ok: true,

        publication:
          serializePublication(
            publication
          ),
      },
      200,
      request
    );
  }

  match =
    path.match(
      /^\/api\/mint\/([a-z0-9-]+)\/(\d+)\/status$/i
    );

  if (
    match &&
    method === "GET"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleMintStatus(
      request,
      env,
      url,
      publication.publicationKey
    );
  }

  match =
    path.match(
      /^\/api\/mint\/([a-z0-9-]+)\/(\d+)\/prepare$/i
    );

  if (
    match &&
    method === "POST"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleMintPrepare(
      request,
      env,
      publication.publicationKey
    );
  }

  match =
    path.match(
      /^\/api\/mint\/([a-z0-9-]+)\/(\d+)\/confirm$/i
    );

  if (
    match &&
    method === "POST"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleMintConfirm(
      request,
      env,
      publication.publicationKey
    );
  }

  match =
    path.match(
      /^\/api\/reader\/([a-z0-9-]+)\/(\d+)\/asset\/([a-zA-Z0-9._-]+)$/i
    );

  if (
    match &&
    method === "GET"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleReaderAsset(
      request,
      env,
      publication.publicationKey,
      match[3]
    );
  }

  match =
    path.match(
      /^\/api\/reader\/([a-z0-9-]+)\/(\d+)$/i
    );

  if (
    match &&
    method === "GET"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleReaderManifest(
      request,
      env,
      publication.publicationKey
    );
  }

  match =
    path.match(
      /^\/api\/comics\/([a-z0-9-]+)\/(\d+)$/i
    );

  if (
    match &&
    method === "GET"
  ) {
    const publication =
      findLegacyPublication(
        match[1],
        Number(match[2])
      );

    if (!publication) {
      return publicationNotFound(
        request
      );
    }

    return handleReaderManifest(
      request,
      env,
      publication.publicationKey
    );
  }

  return null;
}

// ============================================================
// HEALTH
// ============================================================

function handleHealth(
  request,
  env
) {
  const publicPublications =
    PUBLICATION_REGISTRY.filter(
      (p) =>
        p.publicVisible &&
        p.lifecycle !==
          LIFECYCLE.PRIVATE
    );

  return jsonResponse(
    {
      ok: true,

      service:
        "Hellbox Comics",

      apiVersion:
        API_VERSION,

      networkArchitecture:
        "multi-chain-ready",

      defaultChain:
        "pulsechain",

      engines: {
        architecture:
          "token-gated-publishing",

        publicationEngine:
          "publication-key-v2",

        pressEngine:
          "release-bay-v2",

        mintEngine:
          "erc721-ready-verified-mint-v2",

        readerEngine:
          "protected-assets-v2",

        authentication:
          "wallet-signature-short-session",

        payments:
          "free-erc20-native",

        rpc:
          "public-primary-byte-fallback",
      },

      registry: {
        totalConfigured:
          PUBLICATION_REGISTRY.length,

        publicCount:
          publicPublications.length,

        privateCount:
          PUBLICATION_REGISTRY.filter(
            (p) =>
              p.lifecycle ===
              LIFECYCLE.PRIVATE
          ).length,
      },

      bindings: {
        publicBucket:
          Boolean(
            env.PUBLIC_BUCKET
          ),

        privateBucket:
          Boolean(
            env.PRIVATE_BUCKET
          ),

        assets:
          Boolean(
            env.ASSETS
          ),

        byteFallbackConfigured:
          Boolean(
            env.BYTE_RPC_URL
          ),

        sessionSecretConfigured:
          Boolean(
            env.HELLBOX_SESSION_SECRET
          ),
      },
    },
    200,
    request
  );
}

// ============================================================
// RUNTIME BINDINGS
// ============================================================

function handleRuntimeBindings(
  request,
  env
) {
  return jsonResponse(
    {
      ok: true,

      bindings: {
        PUBLIC_BUCKET:
          Boolean(
            env.PUBLIC_BUCKET
          ),

        PRIVATE_BUCKET:
          Boolean(
            env.PRIVATE_BUCKET
          ),

        ASSETS:
          Boolean(
            env.ASSETS
          ),
      },

      secrets: {
        BYTE_RPC_URL:
          Boolean(
            env.BYTE_RPC_URL
          ),

        HELLBOX_SESSION_SECRET:
          Boolean(
            env.HELLBOX_SESSION_SECRET
          ),
      },

      note:
        "Secret values are never returned.",
    },
    200,
    request
  );
}

// ============================================================
// BYTE NODE HEALTH
// ============================================================

async function handleNodeHealth(
  request,
  env
) {
  const chain =
    CHAINS.pulsechain;

  if (!env.BYTE_RPC_URL) {
    return jsonResponse(
      {
        ok: false,

        node: {
          configured: false,

          reachable: false,

          provider:
            "HairyLabs Byte",

          role:
            "fallback",

          network:
            chain.name,

          chainId:
            chain.chainId,

          chainIdHex:
            chain.chainIdHex,
        },

        diagnostic: {
          stage:
            "configuration",

          message:
            "BYTE_RPC_URL is not configured.",
        },
      },
      503,
      request
    );
  }

  try {
    const chainIdResult =
      await rawRpcRequest(
        env.BYTE_RPC_URL,
        "eth_chainId",
        [],
        8000
      );

    const blockResult =
      await rawRpcRequest(
        env.BYTE_RPC_URL,
        "eth_blockNumber",
        [],
        8000
      );

    const actualChainId =
      parseInt(
        chainIdResult,
        16
      );

    if (
      actualChainId !==
      chain.chainId
    ) {
      return jsonResponse(
        {
          ok: false,

          node: {
            configured: true,

            reachable: true,

            provider:
              "HairyLabs Byte",

            role:
              "fallback",

            network:
              chain.name,

            expectedChainId:
              chain.chainId,

            actualChainId,

            chainIdHex:
              chainIdResult,
          },

          diagnostic: {
            stage:
              "chain_validation",

            message:
              "Byte RPC responded, but on the wrong chain.",
          },
        },
        502,
        request
      );
    }

    return jsonResponse(
      {
        ok: true,

        node: {
          configured: true,

          reachable: true,

          provider:
            "HairyLabs Byte",

          role:
            "fallback",

          network:
            chain.name,

          chainId:
            actualChainId,

          chainIdHex:
            chainIdResult,

          currentBlock:
            parseInt(
              blockResult,
              16
            ),

          currentBlockHex:
            blockResult,
        },

        diagnostic: {
          stage:
            "complete",

          message:
            "Hellbox private PulseChain fallback node is online.",
        },
      },
      200,
      request
    );
  } catch (error) {
    return jsonResponse(
      {
        ok: false,

        node: {
          configured: true,

          reachable: false,

          provider:
            "HairyLabs Byte",

          role:
            "fallback",

          network:
            chain.name,
        },

        diagnostic: {
          stage:
            "rpc_request",

          message:
            safeErrorMessage(
              error
            ),
        },
      },
      503,
      request
    );
  }
}

// ============================================================
// CHAIN STATUS
// ============================================================

async function handleChainStatus(
  request,
  env
) {
  const chain =
    CHAINS.pulsechain;

  try {
    const result =
      await rpcRequestWithFallback(
        env,
        chain.key,
        "eth_blockNumber",
        []
      );

    return jsonResponse(
      {
        ok: true,

        chain: {
          key:
            chain.key,

          name:
            chain.name,

          chainId:
            chain.chainId,

          chainIdHex:
            chain.chainIdHex,

          nativeSymbol:
            chain.nativeSymbol,
        },

        rpc: {
          provider:
            result.provider,

          fallbackUsed:
            result.fallbackUsed,

          currentBlock:
            parseInt(
              result.result,
              16
            ),

          currentBlockHex:
            result.result,

          strategy:
            "public-primary-byte-fallback",
        },
      },
      200,
      request
    );
  } catch (error) {
    return jsonResponse(
      {
        ok: false,

        error:
          "rpc_unavailable",

        message:
          safeErrorMessage(
            error
          ),

        chain: {
          key:
            chain.key,

          name:
            chain.name,

          chainId:
            chain.chainId,
        },
      },
      503,
      request
    );
  }
}

// ============================================================
// AUTH STATUS
// ============================================================

function handleAuthStatus(
  request,
  env
) {
  return jsonResponse(
    {
      ok: true,

      auth: {
        version:
          AUTH.version,

        challengeLifetimeSeconds:
          AUTH.challengeLifetimeSeconds,

        sessionLifetimeSeconds:
          AUTH.sessionLifetimeSeconds,

        configured:
          Boolean(
            env.PRIVATE_BUCKET
          ) &&
          Boolean(
            env.HELLBOX_SESSION_SECRET
          ),

        method:
          "EIP-191 personal_sign",
      },
    },
    200,
    request
  );
}

// ============================================================
// AUTH CHALLENGE
// ============================================================

async function handleAuthChallenge(
  request,
  env
) {
  requirePrivateBucket(
    env
  );

  requireSessionSecret(
    env
  );

  const body =
    await readJson(
      request
    );

  const address =
    normalizeAddress(
      body?.address
    );

  if (!address) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_address",

        message:
          "A valid EVM address is required.",
      },
      400,
      request
    );
  }

  const chainKey =
    typeof body?.chainKey ===
      "string" &&
    CHAINS[
      body.chainKey
    ]
      ? body.chainKey
      : "pulsechain";

  const chain =
    CHAINS[
      chainKey
    ];

  const challengeId =
    crypto.randomUUID();

  const nonce =
    randomHex(16);

  const createdAt =
    Math.floor(
      Date.now() / 1000
    );

  const expiresAt =
    createdAt +
    AUTH.challengeLifetimeSeconds;

  const origin =
    request.headers.get(
      "Origin"
    ) ||
    "https://hellboxcomics.com";

  const message =
    [
      "Hellbox Comics",

      "",

      "Sign this message to prove wallet ownership.",

      "This does not create a blockchain transaction and does not cost gas.",

      "",

      `Address: ${address}`,

      `Chain: ${chain.name} (${chain.chainId})`,

      `Nonce: ${nonce}`,

      `Challenge: ${challengeId}`,

      `Issued At: ${new Date(
        createdAt * 1000
      ).toISOString()}`,

      `Expires At: ${new Date(
        expiresAt * 1000
      ).toISOString()}`,

      `Origin: ${origin}`,
    ].join("\n");

  const challengeRecord =
    {
      version:
        AUTH.version,

      challengeId,

      nonce,

      address,

      chainKey,

      chainId:
        chain.chainId,

      message,

      origin,

      createdAt,

      expiresAt,
    };

  await env.PRIVATE_BUCKET.put(
    `${AUTH.challengePrefix}${challengeId}.json`,

    JSON.stringify(
      challengeRecord
    ),

    {
      httpMetadata: {
        contentType:
          "application/json",
      },
    }
  );

  return jsonResponse(
    {
      ok: true,

      challengeId,

      address,

      chainKey,

      chainId:
        chain.chainId,

      message,

      expiresAt,
    },
    200,
    request
  );
}

// ============================================================
// AUTH VERIFY
// ============================================================

async function handleAuthVerify(
  request,
  env
) {
  requirePrivateBucket(
    env
  );

  requireSessionSecret(
    env
  );

  const body =
    await readJson(
      request
    );

  const challengeId =
    typeof body?.challengeId ===
    "string"
      ? body.challengeId
      : "";

  const signature =
    typeof body?.signature ===
    "string"
      ? body.signature
      : "";

  if (
    !/^[0-9a-fA-F-]{20,80}$/.test(
      challengeId
    )
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_challenge",

        message:
          "Invalid challenge identifier.",
      },
      400,
      request
    );
  }

  if (
    !/^0x[0-9a-fA-F]{130}$/.test(
      signature
    )
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_signature",

        message:
          "A 65-byte EVM signature is required.",
      },
      400,
      request
    );
  }

  const key =
    `${AUTH.challengePrefix}${challengeId}.json`;

  const object =
    await env.PRIVATE_BUCKET.get(
      key
    );

  if (!object) {
    return jsonResponse(
      {
        ok: false,

        error:
          "challenge_not_found",

        message:
          "Challenge is missing, expired, or already used.",
      },
      401,
      request
    );
  }

  let challenge;

  try {
    challenge =
      JSON.parse(
        await object.text()
      );
  } catch {
    await env.PRIVATE_BUCKET.delete(
      key
    );

    return jsonResponse(
      {
        ok: false,

        error:
          "challenge_invalid",

        message:
          "Stored challenge is invalid.",
      },
      401,
      request
    );
  }

  const now =
    Math.floor(
      Date.now() / 1000
    );

  if (
    !challenge.expiresAt ||
    now >
      challenge.expiresAt
  ) {
    await env.PRIVATE_BUCKET.delete(
      key
    );

    return jsonResponse(
      {
        ok: false,

        error:
          "challenge_expired",

        message:
          "Challenge expired. Request a new challenge.",
      },
      401,
      request
    );
  }

  const recovered =
    await recoverPersonalSignAddress(
      env,

      challenge.chainKey ||
        "pulsechain",

      challenge.message,

      signature
    );

  if (
    !recovered ||
    recovered !==
      normalizeAddress(
        challenge.address
      )
  ) {
    await env.PRIVATE_BUCKET.delete(
      key
    );

    return jsonResponse(
      {
        ok: false,

        error:
          "signature_mismatch",

        message:
          "Signature does not match the requested wallet.",
      },
      401,
      request
    );
  }

  // One-time challenge.
  await env.PRIVATE_BUCKET.delete(
    key
  );

  const issuedAt =
    now;

  const expiresAt =
    issuedAt +
    AUTH.sessionLifetimeSeconds;

  const payload =
    {
      v:
        AUTH.version,

      iss:
        AUTH.sessionIssuer,

      sub:
        recovered,

      chainKey:
        challenge.chainKey ||
        "pulsechain",

      iat:
        issuedAt,

      exp:
        expiresAt,

      jti:
        crypto.randomUUID(),
    };

  const token =
    await signSession(
      payload,

      env.HELLBOX_SESSION_SECRET
    );

  return jsonResponse(
    {
      ok: true,

      address:
        recovered,

      chainKey:
        payload.chainKey,

      token,

      expiresAt,
    },
    200,
    request
  );
}

// ============================================================
// AUTH SESSION
// ============================================================

async function handleAuthSession(
  request,
  env
) {
  try {
    const session =
      await requireSession(
        request,
        env
      );

    return jsonResponse(
      {
        ok: true,

        authenticated:
          true,

        session,
      },
      200,
      request
    );
  } catch (error) {
    return jsonResponse(
      {
        ok: false,

        authenticated:
          false,

        error:
          "invalid_session",

        message:
          safeErrorMessage(
            error
          ),
      },
      401,
      request
    );
  }
}

// ============================================================
// PUBLICATION STATUS
// ============================================================

function handlePublicationStatus(
  request
) {
  const publicPublications =
    PUBLICATION_REGISTRY.filter(
      isPublicPublication
    );

  const counts =
    {
      private:
        PUBLICATION_REGISTRY.filter(
          (p) =>
            p.lifecycle ===
            LIFECYCLE.PRIVATE
        ).length,

      announced:
        publicPublications.filter(
          (p) =>
            p.lifecycle ===
            LIFECYCLE.ANNOUNCED
        ).length,

      mintLive:
        publicPublications.filter(
          (p) =>
            p.lifecycle ===
            LIFECYCLE.MINT_LIVE
        ).length,

      circulating:
        publicPublications.filter(
          (p) =>
            p.lifecycle ===
            LIFECYCLE.CIRCULATING
        ).length,
    };

  return jsonResponse(
    {
      ok: true,

      lifecycle:
        LIFECYCLE,

      counts,
    },
    200,
    request
  );
}

// ============================================================
// PRESS
// ============================================================

function handlePress(
  request
) {
  const publications =
    PUBLICATION_REGISTRY.filter(
      (p) =>
        p.publicVisible &&
        [
          LIFECYCLE.ANNOUNCED,
          LIFECYCLE.MINT_LIVE,
        ].includes(
          p.lifecycle
        )
    ).map(
      serializePublication
    );

  return jsonResponse(
    {
      ok: true,

      publications,

      empty:
        publications.length ===
        0,

      emptyMessage:
        publications.length ===
        0
          ? "NOTHING ON THE PRESS YET."
          : null,
    },
    200,
    request
  );
}

// ============================================================
// PUBLICATIONS
// ============================================================

function handlePublications(
  request
) {
  const publications =
    PUBLICATION_REGISTRY.filter(
      isPublicPublication
    ).map(
      serializePublication
    );

  return jsonResponse(
    {
      ok: true,

      publications,
    },
    200,
    request
  );
}

// ============================================================
// SINGLE PUBLICATION
// ============================================================

function handlePublication(
  request,
  publicationKey
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  return jsonResponse(
    {
      ok: true,

      publication:
        serializePublication(
          publication
        ),
    },
    200,
    request
  );
}

// ============================================================
// COLLECTION
// ============================================================

async function handleCollection(
  request,
  env,
  url
) {
  const address =
    normalizeAddress(
      url.searchParams.get(
        "address"
      )
    );

  if (!address) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_address",

        message:
          "Query parameter ?address=0x... is required.",
      },
      400,
      request
    );
  }

  const circulating =
    PUBLICATION_REGISTRY.filter(
      (p) =>
        p.publicVisible &&
        p.lifecycle ===
          LIFECYCLE.CIRCULATING
    );

  const publications =
    [];

  for (
    const publication
    of circulating
  ) {
    const owned =
      await getOwnedTokenCopies(
        env,

        publication,

        address
      );

    if (
      owned.length >
      0
    ) {
      publications.push(
        {
          publication:
            serializePublication(
              publication
            ),

          tokens:
            owned,

          owned:
            true,
        }
      );
    }
  }

  return jsonResponse(
    {
      ok: true,

      address,

      publications,

      empty:
        publications.length ===
        0,

      emptyMessage:
        publications.length ===
        0
          ? "THE ARCHIVE IS EMPTY."
          : null,
    },
    200,
    request
  );
}

// ============================================================
// WALLET STATUS
// ============================================================

async function handleWalletStatus(
  request,
  env,
  url
) {
  const address =
    normalizeAddress(
      url.searchParams.get(
        "address"
      )
    );

  if (!address) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_address",

        message:
          "Query parameter ?address=0x... is required.",
      },
      400,
      request
    );
  }

  const statuses =
    [];

  for (
    const publication
    of PUBLICATION_REGISTRY.filter(
      isPublicPublication
    )
  ) {
    const tokens =
      await getOwnedTokenCopies(
        env,

        publication,

        address
      );

    statuses.push(
      {
        publicationKey:
          publication.publicationKey,

        lifecycle:
          publication.lifecycle,

        ownership:
          publication.deployment
            .contractAddress ==
          null
            ? OWNERSHIP.UNAVAILABLE
            : tokens.length >
              0
            ? OWNERSHIP.OWNED
            : OWNERSHIP.MISSING,

        tokenCount:
          tokens.length,

        tokens,
      }
    );
  }

  return jsonResponse(
    {
      ok: true,

      address,

      statuses,
    },
    200,
    request
  );
}

// ============================================================
// MINT STATUS
// ============================================================

async function handleMintStatus(
  request,
  env,
  url,
  publicationKey
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  const address =
    normalizeAddress(
      url.searchParams.get(
        "address"
      )
    );

  if (!address) {
    return jsonResponse(
      {
        ok: true,

        publication:
          serializePublication(
            publication
          ),

        mint: {
          state:
            deriveBaseMintState(
              publication
            ),

          walletRequired:
            true,
        },
      },
      200,
      request
    );
  }

  const status =
    await evaluateMintStatus(
      env,

      publication,

      address
    );

  return jsonResponse(
    {
      ok: true,

      publication:
        serializePublication(
          publication
        ),

      address,

      mint:
        status,
    },
    200,
    request
  );
}

// ============================================================
// MINT PREPARE
// ============================================================

async function handleMintPrepare(
  request,
  env,
  publicationKey
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  const body =
    await readJson(
      request
    );

  const address =
    normalizeAddress(
      body?.address
    );

  const quantity =
    normalizeQuantity(
      body?.quantity,
      1
    );

  if (!address) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_address",

        message:
          "A valid wallet address is required.",
      },
      400,
      request
    );
  }

  if (
    quantity < 1 ||
    quantity >
      publication.mint
        .maxPerTransaction ||
    quantity >
      publication.mint
        .maxPrimaryMintsPerWallet
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_quantity",

        message:
          `Quantity must be between 1 and ${publication.mint.maxPerTransaction}.`,
      },
      400,
      request
    );
  }

  const status =
    await evaluateMintStatus(
      env,

      publication,

      address,

      quantity
    );

  if (
    ![
      MINT_STATE.ELIGIBLE,
      MINT_STATE.LIVE,
    ].includes(
      status.state
    )
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "mint_not_available",

        message:
          status.message ||
          "Mint is not currently available.",

        mint:
          status,
      },
      409,
      request
    );
  }

  if (
    !publication.deployment
      .contractAddress
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "contract_not_deployed",

        message:
          "This publication is configured, but the HellboxNFT contract has not been deployed yet.",
      },
      409,
      request
    );
  }

  const transaction =
    await buildMintTransaction(
      env,

      publication,

      address,

      quantity
    );

  return jsonResponse(
    {
      ok: true,

      publicationKey:
        publication.publicationKey,

      quantity,

      transaction,
    },
    200,
    request
  );
}

// ============================================================
// MINT CONFIRM
// ============================================================

async function handleMintConfirm(
  request,
  env,
  publicationKey
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  const body =
    await readJson(
      request
    );

  const address =
    normalizeAddress(
      body?.address
    );

  const txHash =
    typeof body?.txHash ===
      "string" &&
    /^0x[0-9a-fA-F]{64}$/.test(
      body.txHash
    )
      ? body.txHash
      : null;

  if (
    !address ||
    !txHash
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "invalid_confirmation",

        message:
          "A valid address and transaction hash are required.",
      },
      400,
      request
    );
  }

  if (
    !publication.deployment
      .contractAddress
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "contract_not_deployed",

        message:
          "Publication contract is not deployed.",
      },
      409,
      request
    );
  }

  const chainKey =
    publication.chainKey;

  const receiptRpc =
    await rpcRequestWithFallback(
      env,

      chainKey,

      "eth_getTransactionReceipt",

      [
        txHash,
      ]
    );

  const receipt =
    receiptRpc.result;

  if (!receipt) {
    return jsonResponse(
      {
        ok: true,

        confirmed:
          false,

        pending:
          true,

        provider:
          receiptRpc.provider,
      },
      200,
      request
    );
  }

  if (
    receipt.status !==
    "0x1"
  ) {
    return jsonResponse(
      {
        ok: false,

        confirmed:
          false,

        error:
          "transaction_failed",

        message:
          "Mint transaction reverted.",
      },
      409,
      request
    );
  }

  const txRpc =
    await rpcRequestWithFallback(
      env,

      chainKey,

      "eth_getTransactionByHash",

      [
        txHash,
      ]
    );

  const tx =
    txRpc.result;

  const expectedTarget =
    normalizeAddress(
      publication.deployment
        .contractAddress
    );

  const actualTarget =
    normalizeAddress(
      tx?.to
    );

  if (
    !tx ||
    !expectedTarget ||
    actualTarget !==
      expectedTarget
  ) {
    return jsonResponse(
      {
        ok: false,

        confirmed:
          false,

        error:
          "wrong_contract",

        message:
          "Transaction did not target the configured Hellbox contract.",
      },
      409,
      request
    );
  }

  const owned =
    await getOwnedTokenCopies(
      env,

      publication,

      address
    );

  if (
    owned.length ===
    0
  ) {
    return jsonResponse(
      {
        ok: false,

        confirmed:
          false,

        error:
          "ownership_not_verified",

        message:
          "Transaction succeeded, but Hellbox could not independently verify ERC-721 ownership yet.",
      },
      409,
      request
    );
  }

  return jsonResponse(
    {
      ok: true,

      confirmed:
        true,

      address,

      transactionHash:
        txHash,

      publicationKey,

      tokens:
        owned,

      provider:
        receiptRpc.provider,
    },
    200,
    request
  );
}

// ============================================================
// READER MANIFEST
// ============================================================

async function handleReaderManifest(
  request,
  env,
  publicationKey
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  if (
    publication.lifecycle !==
      LIFECYCLE.CIRCULATING ||
    !publication.features.reader ||
    !publication.reader?.enabled
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "reader_unavailable",

        message:
          "Reader is not currently available for this publication.",
      },
      404,
      request
    );
  }

  const session =
    await requireSession(
      request,
      env
    );

  const tokens =
    await getOwnedTokenCopies(
      env,

      publication,

      session.sub
    );

  if (
    tokens.length ===
    0
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "ownership_required",

        message:
          "Wallet does not own this publication.",
      },
      403,
      request
    );
  }

  if (
    publication.reader
      .sourceMode ===
    "private"
  ) {
    requirePrivateBucket(
      env
    );

    const object =
      await env.PRIVATE_BUCKET.get(
        publication.reader
          .manifestKey
      );

    if (!object) {
      return jsonResponse(
        {
          ok: false,

          error:
            "manifest_missing",

          message:
            "Protected reader manifest was not found.",
        },
        404,
        request
      );
    }

    let manifest;

    try {
      manifest =
        JSON.parse(
          await object.text()
        );
    } catch {
      return jsonResponse(
        {
          ok: false,

          error:
            "manifest_invalid",

          message:
            "Protected reader manifest is invalid.",
        },
        500,
        request
      );
    }

    const safeManifest =
      sanitizeReaderManifest(
        manifest,

        publication.publicationKey
      );

    return jsonResponse(
      {
        ok: true,

        publication:
          serializePublication(
            publication
          ),

        ownedTokens:
          tokens,

        reader:
          safeManifest,
      },
      200,
      request,
      {
        "Cache-Control":
          "private, no-store",
      }
    );
  }

  if (
    publication.reader
      .sourceMode ===
      "public" ||
    publication.reader
      .sourceMode ===
      "ipfs"
  ) {
    const manifest =
      publication.reader
        .publicManifest ||
      null;

    if (!manifest) {
      return jsonResponse(
        {
          ok: false,

          error:
            "manifest_missing",

          message:
            "Public reader manifest is not configured.",
        },
        404,
        request
      );
    }

    return jsonResponse(
      {
        ok: true,

        publication:
          serializePublication(
            publication
          ),

        ownedTokens:
          tokens,

        reader:
          manifest,
      },
      200,
      request,
      {
        "Cache-Control":
          "private, no-store",
      }
    );
  }

  return jsonResponse(
    {
      ok: false,

      error:
        "reader_mode_invalid",

      message:
        "Reader source mode is not supported.",
    },
    500,
    request
  );
}

// ============================================================
// READER ASSET
// ============================================================

async function handleReaderAsset(
  request,
  env,
  publicationKey,
  assetId
) {
  const publication =
    findPublicPublication(
      publicationKey
    );

  if (!publication) {
    return publicationNotFound(
      request
    );
  }

  if (
    publication.lifecycle !==
      LIFECYCLE.CIRCULATING ||
    publication.reader
      ?.sourceMode !==
      "private"
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "asset_unavailable",

        message:
          "Protected asset route is unavailable.",
      },
      404,
      request
    );
  }

  const session =
    await requireSession(
      request,
      env
    );

  const tokens =
    await getOwnedTokenCopies(
      env,

      publication,

      session.sub
    );

  if (
    tokens.length ===
    0
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "ownership_required",

        message:
          "Wallet does not own this publication.",
      },
      403,
      request
    );
  }

  requirePrivateBucket(
    env
  );

  const manifestObject =
    await env.PRIVATE_BUCKET.get(
      publication.reader
        .manifestKey
    );

  if (!manifestObject) {
    return jsonResponse(
      {
        ok: false,

        error:
          "manifest_missing",

        message:
          "Reader manifest not found.",
      },
      404,
      request
    );
  }

  let manifest;

  try {
    manifest =
      JSON.parse(
        await manifestObject.text()
      );
  } catch {
    return jsonResponse(
      {
        ok: false,

        error:
          "manifest_invalid",

        message:
          "Reader manifest is invalid.",
      },
      500,
      request
    );
  }

  const asset =
    resolveManifestAsset(
      manifest,

      assetId
    );

  if (
    !asset ||
    !asset.objectKey
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "asset_not_found",

        message:
          "Reader asset not found.",
      },
      404,
      request
    );
  }

  const normalizedKey =
    normalizePrivateObjectKey(
      asset.objectKey
    );

  const requiredPrefix =
    normalizePrivateObjectKey(
      publication.reader
        .privatePrefix
    );

  if (
    !normalizedKey ||
    !requiredPrefix ||
    !normalizedKey.startsWith(
      requiredPrefix
    )
  ) {
    return jsonResponse(
      {
        ok: false,

        error:
          "unsafe_asset_path",

        message:
          "Reader asset path failed validation.",
      },
      403,
      request
    );
  }

  const object =
    await env.PRIVATE_BUCKET.get(
      normalizedKey
    );

  if (!object) {
    return jsonResponse(
      {
        ok: false,

        error:
          "asset_missing",

        message:
          "Reader asset is missing.",
      },
      404,
      request
    );
  }

  const headers =
    new Headers();

  object.writeHttpMetadata(
    headers
  );

  headers.set(
    "Cache-Control",
    "private, no-store"
  );

  headers.set(
    "X-Content-Type-Options",
    "nosniff"
  );

  addCorsHeaders(
    request,
    headers
  );

  return new Response(
    object.body,
    {
      status: 200,

      headers,
    }
  );
}

// ============================================================
// MINT EVALUATION
// ============================================================

async function evaluateMintStatus(
  env,
  publication,
  address,
  quantity = 1
) {
  const baseState =
    deriveBaseMintState(
      publication
    );

  if (
    baseState ===
      MINT_STATE.UNAVAILABLE ||
    baseState ===
      MINT_STATE.UPCOMING ||
    baseState ===
      MINT_STATE.SOLD_OUT
  ) {
    return {
      state:
        baseState,

      eligible:
        false,

      message:
        mintStateMessage(
          baseState
        ),

      maxPerWallet:
        publication.mint
          .maxPrimaryMintsPerWallet,

      maxPerTransaction:
        publication.mint
          .maxPerTransaction,
    };
  }

  if (
    !publication.deployment
      .contractAddress
  ) {
    return {
      state:
        MINT_STATE.UPCOMING,

      eligible:
        false,

      message:
        "Contract not deployed yet.",

      maxPerWallet:
        publication.mint
          .maxPrimaryMintsPerWallet,

      maxPerTransaction:
        publication.mint
          .maxPerTransaction,
    };
  }

  const claimInfo =
    await getPrimaryMintClaimInfo(
      env,

      publication,

      address
    );

  if (
    !claimInfo.available
  ) {
    return {
      state:
        MINT_STATE.UNAVAILABLE,

      eligible:
        false,

      message:
        "Mint claim information is unavailable.",
    };
  }

  const remainingWalletAllowance =
    Math.max(
      0,

      publication.mint
        .maxPrimaryMintsPerWallet -
        claimInfo.claimed
    );

  if (
    remainingWalletAllowance ===
    0
  ) {
    return {
      state:
        MINT_STATE.NOT_ELIGIBLE,

      eligible:
        false,

      message:
        "This wallet has reached its primary mint limit.",

      claimed:
        claimInfo.claimed,

      remainingWalletAllowance:
        0,
    };
  }

  if (
    quantity >
    remainingWalletAllowance
  ) {
    return {
      state:
        MINT_STATE.NOT_ELIGIBLE,

      eligible:
        false,

      message:
        `This wallet may mint at most ${remainingWalletAllowance} more.`,

      claimed:
        claimInfo.claimed,

      remainingWalletAllowance,
    };
  }

  return {
    state:
      MINT_STATE.ELIGIBLE,

    eligible:
      true,

    claimed:
      claimInfo.claimed,

    remainingWalletAllowance,

    maxPerWallet:
      publication.mint
        .maxPrimaryMintsPerWallet,

    maxPerTransaction:
      publication.mint
        .maxPerTransaction,

    quantityRequested:
      quantity,
  };
}

// ============================================================
// BASE MINT STATE
// ============================================================

function deriveBaseMintState(
  publication
) {
  if (
    !publication.publicVisible ||
    publication.lifecycle ===
      LIFECYCLE.PRIVATE
  ) {
    return MINT_STATE.UNAVAILABLE;
  }

  if (
    publication.lifecycle ===
    LIFECYCLE.ANNOUNCED
  ) {
    return MINT_STATE.UPCOMING;
  }

  if (
    publication.lifecycle !==
    LIFECYCLE.MINT_LIVE
  ) {
    return MINT_STATE.UNAVAILABLE;
  }

  if (
    !publication.mint.enabled
  ) {
    return MINT_STATE.UNAVAILABLE;
  }

  return MINT_STATE.LIVE;
}

// ============================================================
// MINT STATE MESSAGES
// ============================================================

function mintStateMessage(
  state
) {
  switch (state) {
    case MINT_STATE.UPCOMING:
      return "Mint is not live yet.";

    case MINT_STATE.SOLD_OUT:
      return "Mint is sold out.";

    case MINT_STATE.UNAVAILABLE:
    default:
      return "Mint is unavailable.";
  }
}

// ============================================================
// CLAIM INFO
// ============================================================
//
// This is intentionally NOT implemented until HellboxNFT.sol exists.
//
// We will not guess a selector or ABI.

async function getPrimaryMintClaimInfo(
  env,
  publication,
  address
) {
  if (
    !publication.deployment
      .contractAddress
  ) {
    return {
      available:
        false,

      claimed:
        0,
    };
  }

  throw new Error(
    "HellboxNFT claim-count ABI is not configured yet."
  );
}

// ============================================================
// BUILD MINT TRANSACTION
// ============================================================
//
// Also intentionally dormant until the verified HellboxNFT ABI exists.

async function buildMintTransaction(
  env,
  publication,
  address,
  quantity
) {
  throw new Error(
    "HellboxNFT mint ABI is not configured yet."
  );
}

// ============================================================
// OWNED ERC-721 COPIES
// ============================================================
//
// ERC-721 does not provide native enumeration.
//
// We intentionally avoid ERC721Enumerable.
//
// Later this will use:
// 1. Hellbox Transfer-event indexing
// 2. independent ownerOf() RPC verification
//
// Until the contract exists we claim no ownership.

async function getOwnedTokenCopies(
  env,
  publication,
  address
) {
  if (
    !publication.deployment
      .contractAddress
  ) {
    return [];
  }

  return [];
}

// ============================================================
// SERIALIZE PUBLICATION
// ============================================================

function serializePublication(
  publication
) {
  const chain =
    CHAINS[
      publication.chainKey
    ];

  return {
    publicationKey:
      publication.publicationKey,

    title:
      publication.title,

    kind:
      publication.kind,

    seriesKey:
      publication.seriesKey,

    seriesTitle:
      publication.seriesTitle,

    issueNumber:
      publication.issueNumber,

    lifecycle:
      publication.lifecycle,

    chain: {
      key:
        chain.key,

      name:
        chain.name,

      chainId:
        chain.chainId,

      chainIdHex:
        chain.chainIdHex,

      nativeSymbol:
        chain.nativeSymbol,
    },

    deployment: {
      contractAddress:
        publication.deployment
          .contractAddress,

      publicationId:
        publication.deployment
          .publicationId,

      tokenStandard:
        publication.deployment
          .tokenStandard,

      deployed:
        Boolean(
          publication.deployment
            .contractAddress
        ),
    },

    supply:
      publication.supply,

    mint: {
      enabled:
        publication.mint
          .enabled,

      paymentType:
        publication.mint
          .paymentType,

      paymentToken:
        serializePaymentToken(
          publication
        ),

      priceDisplay:
        publication.mint
          .priceDisplay,

      priceBaseUnits:
        publication.mint
          .priceBaseUnits,

      maxPrimaryMintsPerWallet:
        publication.mint
          .maxPrimaryMintsPerWallet,

      maxPerTransaction:
        publication.mint
          .maxPerTransaction,
    },

    royalty:
      publication.royalty,

    features:
      publication.features,

    metadata:
      publication.metadata,

    press:
      publication.press,
  };
}

// ============================================================
// SERIALIZE PAYMENT TOKEN
// ============================================================

function serializePaymentToken(
  publication
) {
  if (
    publication.mint
      .paymentType ===
    PAYMENT_TYPE.FREE
  ) {
    return null;
  }

  if (
    publication.mint
      .paymentType ===
    PAYMENT_TYPE.NATIVE
  ) {
    const chain =
      CHAINS[
        publication.chainKey
      ];

    return {
      type:
        PAYMENT_TYPE.NATIVE,

      symbol:
        chain.nativeSymbol,

      address:
        null,

      decimals:
        18,
    };
  }

  if (
    publication.mint
      .paymentType ===
    PAYMENT_TYPE.ERC20
  ) {
    const configured =
      publication.mint
        .paymentToken;

    if (!configured) {
      return null;
    }

    const chain =
      CHAINS[
        publication.chainKey
      ];

    for (
      const token
      of Object.values(
        chain.stablecoins ||
          {}
      )
    ) {
      if (
        normalizeAddress(
          token.address
        ) ===
        normalizeAddress(
          configured
        )
      ) {
        return {
          type:
            PAYMENT_TYPE.ERC20,

          symbol:
            token.symbol,

          name:
            token.name,

          address:
            token.address,

          decimals:
            token.decimals,
        };
      }
    }

    return {
      type:
        PAYMENT_TYPE.ERC20,

      symbol:
        "ERC20",

      address:
        configured,

      decimals:
        null,
    };
  }

  return null;
}

// ============================================================
// READER MANIFEST SANITIZER
// ============================================================

function sanitizeReaderManifest(
  manifest,
  publicationKey
) {
  const assets =
    Array.isArray(
      manifest.assets
    )
      ? manifest.assets
      : [];

  const pages =
    Array.isArray(
      manifest.pages
    )
      ? manifest.pages
      : [];

  const safeAssets =
    assets.map(
      (
        asset,
        index
      ) => {
        const assetId =
          typeof asset.id ===
            "string" &&
          /^[a-zA-Z0-9._-]+$/.test(
            asset.id
          )
            ? asset.id
            : `asset-${index + 1}`;

        return {
          id:
            assetId,

          type:
            asset.type ||
            null,

          label:
            asset.label ||
            null,

          endpoint:
            `/api/reader/${encodeURIComponent(
              publicationKey
            )}/asset/${encodeURIComponent(
              assetId
            )}`,
        };
      }
    );

  const safePages =
    pages.map(
      (
        page,
        index
      ) => {
        const assetId =
          typeof page.assetId ===
          "string"
            ? page.assetId

            : typeof page.asset ===
              "string"
            ? page.asset

            : safeAssets[
                index
              ]?.id ||
              null;

        return {
          index:
            index + 1,

          title:
            page.title ||
            null,

          assetId,

          endpoint:
            assetId
              ? `/api/reader/${encodeURIComponent(
                  publicationKey
                )}/asset/${encodeURIComponent(
                  assetId
                )}`
              : null,
        };
      }
    );

  return {
    title:
      manifest.title ||
      null,

    mode:
      manifest.mode ||
      "paged",

    pageCount:
      safePages.length ||
      safeAssets.length,

    assets:
      safeAssets,

    pages:
      safePages,
  };
}

// ============================================================
// MANIFEST ASSET RESOLUTION
// ============================================================

function resolveManifestAsset(
  manifest,
  assetId
) {
  const assets =
    Array.isArray(
      manifest.assets
    )
      ? manifest.assets
      : [];

  let asset =
    assets.find(
      (item) =>
        item?.id ===
        assetId
    );

  if (asset) {
    return asset;
  }

  const pages =
    Array.isArray(
      manifest.pages
    )
      ? manifest.pages
      : [];

  const page =
    pages.find(
      (item) =>
        item?.assetId ===
          assetId ||
        item?.asset ===
          assetId
    );

  if (
    page?.objectKey
  ) {
    return page;
  }

  return null;
}

// ============================================================
// PRIVATE OBJECT KEY SAFETY
// ============================================================

function normalizePrivateObjectKey(
  key
) {
  if (
    typeof key !==
    "string"
  ) {
    return null;
  }

  let decoded;

  try {
    decoded =
      decodeURIComponent(
        key
      );
  } catch {
    return null;
  }

  decoded =
    decoded.replace(
      /^\/+/,
      ""
    );

  if (
    decoded.includes(
      ".."
    ) ||
    decoded.includes(
      "\\"
    ) ||
    decoded.includes(
      "\0"
    ) ||
    decoded.startsWith(
      "/"
    )
  ) {
    return null;
  }

  return decoded;
}

// ============================================================
// PUBLICATION LOOKUP
// ============================================================

function findPublication(
  publicationKey
) {
  const normalized =
    typeof publicationKey ===
    "string"
      ? publicationKey
          .trim()
          .toLowerCase()
      : "";

  return (
    PUBLICATION_REGISTRY.find(
      (p) =>
        p.publicationKey
          .toLowerCase() ===
        normalized
    ) ||
    null
  );
}

// ============================================================
// PUBLIC PUBLICATION LOOKUP
// ============================================================

function findPublicPublication(
  publicationKey
) {
  const publication =
    findPublication(
      publicationKey
    );

  return publication &&
    isPublicPublication(
      publication
    )
    ? publication
    : null;
}

// ============================================================
// PUBLIC VISIBILITY CHECK
// ============================================================

function isPublicPublication(
  publication
) {
  return (
    publication.publicVisible ===
      true &&
    publication.lifecycle !==
      LIFECYCLE.PRIVATE
  );
}

// ============================================================
// LEGACY LOOKUP
// ============================================================

function findLegacyPublication(
  slug,
  issueNumber
) {
  const key =
    `${String(
      slug
    ).toLowerCase()}:${Number(
      issueNumber
    )}`;

  const publicationKey =
    LEGACY_SLUG_MAP[
      key
    ];

  if (!publicationKey) {
    return null;
  }

  return findPublicPublication(
    publicationKey
  );
}

// ============================================================
// PUBLICATION NOT FOUND
// ============================================================

function publicationNotFound(
  request
) {
  return jsonResponse(
    {
      ok: false,

      error:
        "publication_not_found",

      message:
        "Publication not found.",
    },
    404,
    request
  );
}

// ============================================================
// RPC WITH FALLBACK
// ============================================================
//
// NEW STRATEGY:
//
// 1. Public PulseChain RPC first
// 2. HairyLabs Byte only if public fails
//
// This reduces paid/limited Byte usage.

async function rpcRequestWithFallback(
  env,
  chainKey,
  method,
  params
) {
  const chain =
    CHAINS[
      chainKey
    ];

  if (!chain) {
    throw new Error(
      `Unsupported chain: ${chainKey}`
    );
  }

  let primaryError =
    null;

  try {
    const result =
      await rawRpcRequest(
        chain.rpcPrimary,

        method,

        params,

        8000
      );

    return {
      result,

      provider:
        `Public ${chain.name} RPC`,

      fallbackUsed:
        false,
    };
  } catch (error) {
    primaryError =
      error;
  }

  const fallbackUrl =
    env[
      chain.rpcFallbackEnv
    ];

  if (!fallbackUrl) {
    throw new Error(
      `Primary RPC failed and fallback is not configured: ${safeErrorMessage(
        primaryError
      )}`
    );
  }

  try {
    const result =
      await rawRpcRequest(
        fallbackUrl,

        method,

        params,

        8000
      );

    return {
      result,

      provider:
        "HairyLabs Byte",

      fallbackUsed:
        true,

      primaryError:
        safeErrorMessage(
          primaryError
        ),
    };
  } catch (
    fallbackError
  ) {
    throw new Error(
      `Both RPC providers failed. Public: ${safeErrorMessage(
        primaryError
      )}; Byte: ${safeErrorMessage(
        fallbackError
      )}`
    );
  }
}

// ============================================================
// RAW JSON-RPC REQUEST
// ============================================================

async function rawRpcRequest(
  url,
  method,
  params = [],
  timeoutMs = 8000
) {
  if (
    !url ||
    typeof url !==
      "string"
  ) {
    throw new Error(
      "RPC URL is not configured."
    );
  }

  const controller =
    new AbortController();

  const timer =
    setTimeout(
      () =>
        controller.abort(),
      timeoutMs
    );

  try {
    const response =
      await fetch(
        url,
        {
          method:
            "POST",

          headers: {
            "Content-Type":
              "application/json",

            Accept:
              "application/json",
          },

          body:
            JSON.stringify(
              {
                jsonrpc:
                  "2.0",

                id:
                  1,

                method,

                params,
              }
            ),

          signal:
            controller.signal,
        }
      );

    if (
      !response.ok
    ) {
      throw new Error(
        `RPC HTTP ${response.status}`
      );
    }

    const payload =
      await response.json();

    if (
      payload?.error
    ) {
      throw new Error(
        payload.error
          .message ||
          `RPC error ${payload.error.code || "unknown"}`
      );
    }

    if (
      !Object.prototype
        .hasOwnProperty.call(
          payload,
          "result"
        )
    ) {
      throw new Error(
        "RPC response did not include a result."
      );
    }

    return payload.result;
  } finally {
    clearTimeout(
      timer
    );
  }
}

// ============================================================
// EIP-191 SIGNATURE RECOVERY
// ============================================================

async function recoverPersonalSignAddress(
  env,
  chainKey,
  message,
  signature
) {
  const messageBytes =
    new TextEncoder().encode(
      message
    );

  const prefix =
    `\x19Ethereum Signed Message:\n${messageBytes.length}`;

  const prefixBytes =
    new TextEncoder().encode(
      prefix
    );

  const full =
    new Uint8Array(
      prefixBytes.length +
        messageBytes.length
    );

  full.set(
    prefixBytes,
    0
  );

  full.set(
    messageBytes,
    prefixBytes.length
  );

  const hashRpc =
    await rpcRequestWithFallback(
      env,

      chainKey,

      "web3_sha3",

      [
        bytesToHex(
          full
        ),
      ]
    );

  const hash =
    hashRpc.result;

  if (
    !/^0x[0-9a-fA-F]{64}$/.test(
      hash
    )
  ) {
    throw new Error(
      "Could not hash signed message."
    );
  }

  const sig =
    signature.slice(2);

  const r =
    sig.slice(
      0,
      64
    );

  const s =
    sig.slice(
      64,
      128
    );

  let v =
    parseInt(
      sig.slice(
        128,
        130
      ),
      16
    );

  if (
    v <
    27
  ) {
    v +=
      27;
  }

  if (
    v !== 27 &&
    v !== 28
  ) {
    throw new Error(
      "Invalid signature recovery value."
    );
  }

  const input =
    hash
      .slice(2)
      .padStart(
        64,
        "0"
      ) +

    v
      .toString(16)
      .padStart(
        64,
        "0"
      ) +

    r.padStart(
      64,
      "0"
    ) +

    s.padStart(
      64,
      "0"
    );

  const recoveredRpc =
    await rpcRequestWithFallback(
      env,

      chainKey,

      "eth_call",

      [
        {
          to:
            "0x0000000000000000000000000000000000000001",

          data:
            `0x${input}`,
        },

        "latest",
      ]
    );

  const returned =
    recoveredRpc.result;

  if (
    !/^0x[0-9a-fA-F]{64}$/.test(
      returned
    )
  ) {
    return null;
  }

  return normalizeAddress(
    `0x${returned.slice(
      -40
    )}`
  );
}

// ============================================================
// SIGN SESSION
// ============================================================

async function signSession(
  payload,
  secret
) {
  const header =
    {
      alg:
        "HS256",

      typ:
        "HBOX",
    };

  const encodedHeader =
    base64UrlEncode(
      new TextEncoder().encode(
        JSON.stringify(
          header
        )
      )
    );

  const encodedPayload =
    base64UrlEncode(
      new TextEncoder().encode(
        JSON.stringify(
          payload
        )
      )
    );

  const signingInput =
    `${encodedHeader}.${encodedPayload}`;

  const signature =
    await hmacSha256(
      secret,

      new TextEncoder().encode(
        signingInput
      )
    );

  return `${signingInput}.${base64UrlEncode(
    signature
  )}`;
}

// ============================================================
// VERIFY SESSION
// ============================================================

async function verifySessionToken(
  token,
  secret
) {
  if (
    typeof token !==
    "string"
  ) {
    throw new Error(
      "Session token missing."
    );
  }

  const parts =
    token.split(".");

  if (
    parts.length !==
    3
  ) {
    throw new Error(
      "Session token format is invalid."
    );
  }

  const [
    encodedHeader,
    encodedPayload,
    encodedSignature,
  ] = parts;

  const signingInput =
    `${encodedHeader}.${encodedPayload}`;

  const expected =
    await hmacSha256(
      secret,

      new TextEncoder().encode(
        signingInput
      )
    );

  const actual =
    base64UrlDecode(
      encodedSignature
    );

  if (
    !constantTimeEqual(
      expected,
      actual
    )
  ) {
    throw new Error(
      "Session signature is invalid."
    );
  }

  let payload;

  try {
    payload =
      JSON.parse(
        new TextDecoder().decode(
          base64UrlDecode(
            encodedPayload
          )
        )
      );
  } catch {
    throw new Error(
      "Session payload is invalid."
    );
  }

  const now =
    Math.floor(
      Date.now() / 1000
    );

  if (
    payload.iss !==
    AUTH.sessionIssuer
  ) {
    throw new Error(
      "Session issuer is invalid."
    );
  }

  if (
    !payload.exp ||
    now >=
      payload.exp
  ) {
    throw new Error(
      "Session expired."
    );
  }

  const address =
    normalizeAddress(
      payload.sub
    );

  if (!address) {
    throw new Error(
      "Session wallet is invalid."
    );
  }

  return {
    ...payload,

    sub:
      address,
  };
}

// ============================================================
// REQUIRE SESSION
// ============================================================

async function requireSession(
  request,
  env
) {
  requireSessionSecret(
    env
  );

  const authHeader =
    request.headers.get(
      "Authorization"
    ) ||
    "";

  const match =
    authHeader.match(
      /^Bearer\s+(.+)$/i
    );

  if (!match) {
    throw new Error(
      "Authorization session required."
    );
  }

  return verifySessionToken(
    match[1],

    env.HELLBOX_SESSION_SECRET
  );
}

// ============================================================
// HMAC
// ============================================================

async function hmacSha256(
  secret,
  data
) {
  const key =
    await crypto.subtle.importKey(
      "raw",

      new TextEncoder().encode(
        secret
      ),

      {
        name:
          "HMAC",

        hash:
          "SHA-256",
      },

      false,

      [
        "sign",
      ]
    );

  const signature =
    await crypto.subtle.sign(
      "HMAC",

      key,

      data
    );

  return new Uint8Array(
    signature
  );
}

// ============================================================
// CONSTANT TIME COMPARE
// ============================================================

function constantTimeEqual(
  a,
  b
) {
  if (
    !(a instanceof Uint8Array) ||
    !(b instanceof Uint8Array)
  ) {
    return false;
  }

  if (
    a.length !==
    b.length
  ) {
    return false;
  }

  let result =
    0;

  for (
    let i = 0;
    i < a.length;
    i++
  ) {
    result |=
      a[i] ^
      b[i];
  }

  return (
    result ===
    0
  );
}

// ============================================================
// BASE64 URL
// ============================================================

function base64UrlEncode(
  bytes
) {
  let binary =
    "";

  for (
    const byte
    of bytes
  ) {
    binary +=
      String.fromCharCode(
        byte
      );
  }

  return btoa(
    binary
  )
    .replace(
      /\+/g,
      "-"
    )
    .replace(
      /\//g,
      "_"
    )
    .replace(
      /=+$/g,
      ""
    );
}

function base64UrlDecode(
  value
) {
  const normalized =
    value
      .replace(
        /-/g,
        "+"
      )
      .replace(
        /_/g,
        "/"
      );

  const padded =
    normalized +
    "=".repeat(
      (
        4 -
        (
          normalized.length %
          4
        )
      ) %
        4
    );

  const binary =
    atob(
      padded
    );

  return Uint8Array.from(
    binary,

    (char) =>
      char.charCodeAt(
        0
      )
  );
}

// ============================================================
// BYTES TO HEX
// ============================================================

function bytesToHex(
  bytes
) {
  return (
    "0x" +
    Array.from(
      bytes
    )
      .map(
        (b) =>
          b
            .toString(16)
            .padStart(
              2,
              "0"
            )
      )
      .join("")
  );
}

// ============================================================
// RANDOM HEX
// ============================================================

function randomHex(
  byteLength
) {
  const bytes =
    new Uint8Array(
      byteLength
    );

  crypto.getRandomValues(
    bytes
  );

  return bytesToHex(
    bytes
  );
}

// ============================================================
// NORMALIZE ADDRESS
// ============================================================

function normalizeAddress(
  value
) {
  if (
    typeof value !==
    "string"
  ) {
    return null;
  }

  const trimmed =
    value.trim();

  if (
    !/^0x[0-9a-fA-F]{40}$/.test(
      trimmed
    )
  ) {
    return null;
  }

  return trimmed.toLowerCase();
}

// ============================================================
// NORMALIZE QUANTITY
// ============================================================

function normalizeQuantity(
  value,
  fallback = 1
) {
  if (
    value == null ||
    value ===
      ""
  ) {
    return fallback;
  }

  const number =
    Number(
      value
    );

  if (
    !Number.isSafeInteger(
      number
    )
  ) {
    return -1;
  }

  return number;
}

// ============================================================
// READ JSON
// ============================================================

async function readJson(
  request
) {
  const contentType =
    request.headers.get(
      "Content-Type"
    ) ||
    "";

  if (
    !contentType
      .toLowerCase()
      .includes(
        "application/json"
      )
  ) {
    throw new Error(
      "Content-Type must be application/json."
    );
  }

  try {
    return await request.json();
  } catch {
    throw new Error(
      "Request body must contain valid JSON."
    );
  }
}

// ============================================================
// REQUIRED BINDINGS
// ============================================================

function requirePrivateBucket(
  env
) {
  if (
    !env.PRIVATE_BUCKET
  ) {
    throw new Error(
      "PRIVATE_BUCKET binding is not configured."
    );
  }
}

function requireSessionSecret(
  env
) {
  if (
    !env.HELLBOX_SESSION_SECRET
  ) {
    throw new Error(
      "HELLBOX_SESSION_SECRET is not configured."
    );
  }
}

// ============================================================
// SAFE ERROR MESSAGE
// ============================================================

function safeErrorMessage(
  error
) {
  if (!error) {
    return "Unknown error.";
  }

  if (
    error.name ===
    "AbortError"
  ) {
    return "Request timed out.";
  }

  return String(
    error.message ||
    error
  ).slice(
    0,
    500
  );
}

// ============================================================
// OPTIONS / CORS
// ============================================================

function handleOptions(
  request
) {
  const headers =
    new Headers();

  addCorsHeaders(
    request,
    headers
  );

  headers.set(
    "Access-Control-Max-Age",
    "86400"
  );

  return new Response(
    null,
    {
      status: 204,

      headers,
    }
  );
}

// ============================================================
// CORS HEADERS
// ============================================================

function addCorsHeaders(
  request,
  headers
) {
  const origin =
    request.headers.get(
      "Origin"
    );

  if (
    origin &&
    ALLOWED_ORIGINS.has(
      origin
    )
  ) {
    headers.set(
      "Access-Control-Allow-Origin",
      origin
    );

    headers.set(
      "Vary",
      "Origin"
    );
  }

  headers.set(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization"
  );

  headers.set(
    "Access-Control-Allow-Methods",
    "GET, POST, OPTIONS"
  );
}

// ============================================================
// JSON RESPONSE
// ============================================================

function jsonResponse(
  data,
  status = 200,
  request = null,
  extraHeaders = {}
) {
  const headers =
    new Headers({
      "Content-Type":
        "application/json; charset=utf-8",

      "X-Content-Type-Options":
        "nosniff",

      ...extraHeaders,
    });

  if (request) {
    addCorsHeaders(
      request,
      headers
    );
  }

  return new Response(
    JSON.stringify(
      data,
      null,
      2
    ),
    {
      status,

      headers,
    }
  );
}

// ============================================================
// TEXT RESPONSE
// ============================================================

function textResponse(
  text,
  status = 200,
  request = null,
  extraHeaders = {}
) {
  const headers =
    new Headers({
      "Content-Type":
        "text/plain; charset=utf-8",

      "X-Content-Type-Options":
        "nosniff",

      ...extraHeaders,
    });

  if (request) {
    addCorsHeaders(
      request,
      headers
    );
  }

  return new Response(
    text,
    {
      status,

      headers,
    }
  );
}
