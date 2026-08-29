const API_VERSION = "hellbox-v2";
const SESSION_TTL_SECONDS = 15 * 60;
const CHALLENGE_TTL_SECONDS = 5 * 60;

const ALLOWED_ORIGINS = new Set([
  "https://hellboxcomics.com",
  "https://www.hellboxcomics.com",
  "https://hellboxcomics.harrow-harrow.workers.dev",
  "https://test-hellboxcomics.harrow-harrow.workers.dev",
]);

const DEFAULT_CHAIN_KEY = "pulsechain";
const DEVELOPMENT_CHAIN_KEY = "pulsechainTestnetV4";

const CHAIN_POLICY = {
  nativeDeploymentsOnly: true,
  bridgeHellboxNfts: false,
  conceptualPublicationIdentity:
    "publicationKey",
  onchainAssetIdentity: [
    "chainId",
    "contractAddress",
    "tokenId",
  ],
};

const CHAIN_REGISTRY = {
  pulsechain: {
    key: "pulsechain",
    chainId: 369,
    chainIdHex: "0x171",
    name: "PulseChain",
    shortName: "PulseChain",
    networkType: "mainnet",

    nativeCurrency: {
      name: "Pulse",
      symbol: "PLS",
      decimals: 18,
    },

    explorerUrl:
      "https://scan.pulsechain.com",

    primaryRpcUrl:
      "https://rpc.pulsechain.com",

    fallbackRpcEnvKey:
      "BYTE_RPC_URL",

    faucetUrl: null,

    root: true,
    enabled: true,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {
      dai: {
        symbol: "DAI",
        address:
          "0xefD766cCb38EaF1dfd701853BFCe31359239F305",
        decimals: 18,
      },
    },
  },

  pulsechainTestnetV4: {
    key: "pulsechainTestnetV4",
    chainId: 943,
    chainIdHex: "0x3af",
    name: "PulseChain Testnet V4",
    shortName: "PulseChain V4",
    networkType: "testnet",

    nativeCurrency: {
      name: "Test Pulse",
      symbol: "tPLS",
      decimals: 18,
    },

    explorerUrl:
      "https://scan.v4.testnet.pulsechain.com",

    primaryRpcUrl:
      "https://rpc.v4.testnet.pulsechain.com",

    fallbackRpcEnvKey: null,

    faucetUrl:
      "https://faucet.v4.testnet.pulsechain.com",

    root: false,
    enabled: false,
    testingEnabled: true,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },

  ethereum: {
    key: "ethereum",
    chainId: 1,
    chainIdHex: "0x1",
    name: "Ethereum",
    shortName: "Ethereum",
    networkType: "mainnet",

    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },

    explorerUrl:
      "https://etherscan.io",

    primaryRpcUrl: null,
    fallbackRpcEnvKey: null,
    faucetUrl: null,

    root: false,
    enabled: false,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },

  base: {
    key: "base",
    chainId: 8453,
    chainIdHex: "0x2105",
    name: "Base Mainnet",
    shortName: "Base",
    networkType: "mainnet",

    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },

    explorerUrl:
      "https://base.blockscout.com",

    primaryRpcUrl:
      "https://mainnet.base.org",

    fallbackRpcEnvKey: null,
    faucetUrl: null,

    root: false,
    enabled: false,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },

  baseSepolia: {
    key: "baseSepolia",
    chainId: 84532,
    chainIdHex: "0x14a34",
    name: "Base Sepolia",
    shortName: "Base Sepolia",
    networkType: "testnet",

    nativeCurrency: {
      name: "Sepolia Ether",
      symbol: "ETH",
      decimals: 18,
    },

    explorerUrl:
      "https://sepolia-explorer.base.org",

    primaryRpcUrl:
      "https://sepolia.base.org",

    fallbackRpcEnvKey: null,
    faucetUrl: null,

    root: false,
    enabled: false,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },

  robinhoodChain: {
    key: "robinhoodChain",
    chainId: 4663,
    chainIdHex: "0x1237",
    name: "Robinhood Chain",
    shortName: "Robinhood Chain",
    networkType: "mainnet",

    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },

    explorerUrl:
      "https://robinhoodchain.blockscout.com",

    primaryRpcUrl:
      "https://rpc.mainnet.chain.robinhood.com",

    fallbackRpcEnvKey: null,
    faucetUrl: null,

    root: false,
    enabled: false,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },

  robinhoodChainTestnet: {
    key: "robinhoodChainTestnet",
    chainId: 46630,
    chainIdHex: "0xb626",
    name: "Robinhood Chain Testnet",
    shortName: "Robinhood Chain Testnet",
    networkType: "testnet",

    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },

    explorerUrl:
      "https://explorer.testnet.chain.robinhood.com",

    primaryRpcUrl:
      "https://rpc.testnet.chain.robinhood.com",

    fallbackRpcEnvKey: null,
    faucetUrl: null,

    root: false,
    enabled: false,
    testingEnabled: false,
    publishingEnabled: false,

    deployment: null,

    stablecoins: {},
  },
};

const LEGACY_SLUG_MAP = {};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    const origin = request.headers.get("Origin");

    if (request.method === "OPTIONS") {
      return corsPreflight(origin);
    }

    try {
      if (url.pathname.startsWith("/api/")) {
        const response = await handleApi(
          request,
          env,
          url
        );

        return withCors(
          response,
          origin
        );
      }

      if (
        env.ASSETS &&
        typeof env.ASSETS.fetch === "function"
      ) {
        return env.ASSETS.fetch(request);
      }

      return json(
        {
          ok: false,
          error: "Static asset binding unavailable.",
        },
        503
      );
    } catch (error) {
      console.error(
        "HELLBOX WORKER ERROR",
        error
      );

      return withCors(
        json(
          {
            ok: false,

            error:
              "Hellbox backend failure.",

            detail:
              error instanceof Error
                ? error.message
                : String(error),
          },
          500
        ),
        origin
      );
    }
  },
};

async function handleApi(
  request,
  env,
  url
) {
  const {
    pathname,
  } = url;

  // ============================================================
  // HEALTH
  // ============================================================

  if (
    pathname === "/api/health" &&
    request.method === "GET"
  ) {
    return handleHealth(env);
  }

  // ============================================================
  // PUBLIC CHAIN REGISTRY
  // ============================================================

  if (
    pathname === "/api/chains" &&
    request.method === "GET"
  ) {
    return handleChains();
  }

  // ============================================================
  // CHAIN STATUS
  // ============================================================

  if (
    pathname === "/api/chain-status" &&
    request.method === "GET"
  ) {
    return handleChainStatus(
      env,
      url
    );
  }

  // ============================================================
  // BYTE FALLBACK HEALTH
  // ============================================================

  if (
    pathname === "/api/node-health" &&
    request.method === "GET"
  ) {
    return handleNodeHealth(env);
  }

  // ============================================================
  // PUBLICATION INDEX
  // ============================================================

  if (
    pathname === "/api/publications" &&
    request.method === "GET"
  ) {
    return handlePublications(env);
  }

  // ============================================================
  // INDIVIDUAL PUBLICATION
  // ============================================================

  const publicationMatch =
    pathname.match(
      /^\/api\/publications\/([a-z0-9-]+)$/
    );

  if (
    publicationMatch &&
    request.method === "GET"
  ) {
    return handlePublication(
      env,
      publicationMatch[1]
    );
  }

  // ============================================================
  // PRESS
  // ============================================================

  if (
    pathname === "/api/press" &&
    request.method === "GET"
  ) {
    return handlePress(env);
  }

  // ============================================================
  // WALLET STATUS
  // ============================================================

  if (
    pathname === "/api/wallet-status" &&
    request.method === "GET"
  ) {
    return handleWalletStatus(
      env,
      url
    );
  }

  // ============================================================
  // AUTH CHALLENGE
  // ============================================================

  if (
    pathname === "/api/auth/challenge" &&
    request.method === "POST"
  ) {
    return handleAuthChallenge(
      request,
      env
    );
  }

  // ============================================================
  // AUTH VERIFY
  // ============================================================

  if (
    pathname === "/api/auth/verify" &&
    request.method === "POST"
  ) {
    return handleAuthVerify(
      request,
      env
    );
  }

  // ============================================================
  // AUTH SESSION CHECK
  // ============================================================

  if (
    pathname === "/api/auth/session" &&
    request.method === "GET"
  ) {
    return handleAuthSession(
      request,
      env
    );
  }

  // ============================================================
  // MINT STATUS
  // ============================================================

  const mintStatusMatch =
    pathname.match(
      /^\/api\/mint\/([a-z0-9-]+)\/status$/
    );

  if (
    mintStatusMatch &&
    request.method === "GET"
  ) {
    return handleMintStatus(
      env,
      url,
      mintStatusMatch[1]
    );
  }

  // ============================================================
  // PREPARE MINT
  // ============================================================

  const mintPrepareMatch =
    pathname.match(
      /^\/api\/mint\/([a-z0-9-]+)\/prepare$/
    );

  if (
    mintPrepareMatch &&
    request.method === "POST"
  ) {
    return handleMintPrepare(
      request,
      env,
      mintPrepareMatch[1]
    );
  }

  // ============================================================
  // CONFIRM MINT
  // ============================================================

  const mintConfirmMatch =
    pathname.match(
      /^\/api\/mint\/([a-z0-9-]+)\/confirm$/
    );

  if (
    mintConfirmMatch &&
    request.method === "POST"
  ) {
    return handleMintConfirm(
      request,
      env,
      mintConfirmMatch[1]
    );
  }

  // ============================================================
  // READER MANIFEST
  // ============================================================

  const readerManifestMatch =
    pathname.match(
      /^\/api\/reader\/([a-z0-9-]+)$/
    );

  if (
    readerManifestMatch &&
    request.method === "GET"
  ) {
    return handleReaderManifest(
      request,
      env,
      readerManifestMatch[1]
    );
  }

  // ============================================================
  // READER ASSET
  // ============================================================

  const readerAssetMatch =
    pathname.match(
      /^\/api\/reader\/([a-z0-9-]+)\/asset\/([^/]+)$/
    );

  if (
    readerAssetMatch &&
    request.method === "GET"
  ) {
    return handleReaderAsset(
      request,
      env,
      readerAssetMatch[1],
      decodeURIComponent(
        readerAssetMatch[2]
      )
    );
  }

  // ============================================================
  // LEGACY ROUTES
  // ============================================================

  const legacyPublication =
    resolveLegacyPublication(
      pathname
    );

  if (legacyPublication) {
    return json(
      {
        ok: false,

        error:
          "Legacy issue routes are retired. Use publicationKey routes.",

        publicationKey:
          legacyPublication.publicationKey,
      },
      410
    );
  }

  return json(
    {
      ok: false,

      error:
        "API route not found.",

      path:
        pathname,
    },
    404
  );
}

// ============================================================
// HEALTH
// ============================================================

async function handleHealth(env) {
  const registry =
    await getPublicationRegistrySummary(
      env
    );

  return json({
    ok: true,

    service:
      "Hellbox Comics",

    apiVersion:
      API_VERSION,

    networkArchitecture:
      "multi-chain-ready",

    defaultChain:
      DEFAULT_CHAIN_KEY,

    developmentChain:
      DEVELOPMENT_CHAIN_KEY,

    chainPolicy:
      CHAIN_POLICY,

    engines: {
      architecture:
        "token-gated-publishing",

      publicationEngine:
        "publication-key-d1-v1",

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

    chains: {
      totalConfigured:
        Object.keys(
          CHAIN_REGISTRY
        ).length,

      enabled:
        Object.values(
          CHAIN_REGISTRY
        ).filter(
          chain =>
            chain.enabled
        ).length,

      testingEnabled:
        Object.values(
          CHAIN_REGISTRY
        ).filter(
          chain =>
            chain.testingEnabled
        ).length,

      publishingEnabled:
        Object.values(
          CHAIN_REGISTRY
        ).filter(
          chain =>
            chain.publishingEnabled &&
            Boolean(
              chain.deployment &&
              chain.deployment
                .contractAddress
            )
        ).length,
    },

    registry,

    bindings: {
      database:
        Boolean(
          env.DB
        ),

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
  });
}

// ============================================================
// PUBLIC CHAIN REGISTRY
// ============================================================

function handleChains() {
  const chains =
    Object.values(
      CHAIN_REGISTRY
    ).map(
      publicChainView
    );

  return json({
    ok: true,

    version:
      "0.2.0-recovery.2",

    defaultChainKey:
      DEFAULT_CHAIN_KEY,

    developmentChainKey:
      DEVELOPMENT_CHAIN_KEY,

    policy:
      CHAIN_POLICY,

    chains,

    count:
      chains.length,
  });
}

function publicChainView(
  chain
) {
  return {
    key:
      chain.key,

    chainId:
      chain.chainId,

    chainIdHex:
      chain.chainIdHex,

    name:
      chain.name,

    shortName:
      chain.shortName,

    networkType:
      chain.networkType,

    nativeCurrency:
      chain.nativeCurrency,

    explorerUrl:
      chain.explorerUrl,

    rpcUrls:
      chain.primaryRpcUrl
        ? [
            chain.primaryRpcUrl,
          ]
        : [],

    faucetUrl:
      chain.faucetUrl,

    root:
      chain.root,

    enabled:
      chain.enabled,

    testingEnabled:
      chain.testingEnabled,

    publishingEnabled:
      Boolean(
        chain.publishingEnabled &&
        chain.deployment &&
        chain.deployment
          .contractAddress
      ),

    deployment:
      chain.deployment
        ? {
            contractAddress:
              chain.deployment
                .contractAddress ||
              null,
          }
        : null,
  };
}

// ============================================================
// CHAIN STATUS
// ============================================================

async function handleChainStatus(
  env,
  url
) {
  const chainKey =
    url.searchParams.get(
      "chain"
    ) ||
    DEFAULT_CHAIN_KEY;

  const chain =
    CHAIN_REGISTRY[
      chainKey
    ];

  if (!chain) {
    return json(
      {
        ok: false,

        error:
          "Unknown chain.",

        chainKey,
      },
      404
    );
  }

  if (
    !chain.enabled &&
    !chain.testingEnabled
  ) {
    return json(
      {
        ok: false,

        error:
          "Chain is configured but not active in Hellbox.",

        chain:
          publicChainView(
            chain
          ),
      },
      409
    );
  }

  if (!chain.primaryRpcUrl) {
    return json(
      {
        ok: false,

        error:
          "No public RPC is configured for this chain.",

        chain:
          publicChainView(
            chain
          ),
      },
      503
    );
  }

  const rpcResult =
    await rpcWithFallback(
      env,
      chain,
      "eth_blockNumber",
      []
    );

  const blockHex =
    rpcResult.result;

  const blockNumber =
    parseInt(
      blockHex,
      16
    );

  return json({
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
    },

    provider:
      rpcResult.provider,

    fallbackUsed:
      rpcResult.fallbackUsed,

    currentBlock:
      Number.isFinite(
        blockNumber
      )
        ? blockNumber
        : null,

    currentBlockHex:
      blockHex,

    strategy:
      "public-primary-byte-fallback",
  });
}

// ============================================================
// BYTE FALLBACK HEALTH
// ============================================================

async function handleNodeHealth(
  env
) {
  const chain =
    CHAIN_REGISTRY.pulsechain;

  if (!env.BYTE_RPC_URL) {
    return json(
      {
        ok: false,

        provider:
          "HairyLabs Byte",

        role:
          "fallback",

        error:
          "BYTE_RPC_URL is not configured.",
      },
      503
    );
  }

  const [
    chainIdHex,
    blockHex,
  ] =
    await Promise.all([
      rpcCall(
        env.BYTE_RPC_URL,
        "eth_chainId",
        []
      ),

      rpcCall(
        env.BYTE_RPC_URL,
        "eth_blockNumber",
        []
      ),
    ]);

  const chainId =
    parseInt(
      chainIdHex,
      16
    );

  const blockNumber =
    parseInt(
      blockHex,
      16
    );

  const ok =
    chainId ===
    chain.chainId;

  return json(
    {
      ok,

      provider:
        "HairyLabs Byte",

      role:
        "fallback",

      chainId,

      chainIdHex,

      expectedChainId:
        chain.chainId,

      currentBlock:
        Number.isFinite(
          blockNumber
        )
          ? blockNumber
          : null,

      currentBlockHex:
        blockHex,
    },
    ok
      ? 200
      : 502
  );
}

// ============================================================
// PUBLICATIONS
// ============================================================

async function handlePublications(
  env
) {
  const publications =
    (
      await getPublicPublications(
        env
      )
    ).map(
      publicPublicationView
    );

  return json({
    ok: true,

    apiVersion:
      API_VERSION,

    source:
      "d1",

    publications,

    count:
      publications.length,
  });
}

// ============================================================
// INDIVIDUAL PUBLICATION
// ============================================================

async function handlePublication(
  env,
  publicationKey
) {
  const publication =
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
    );
  }

  return json({
    ok: true,

    source:
      "d1",

    publication:
      publicPublicationView(
        publication
      ),
  });
}

// ============================================================
// PRESS
// ============================================================

async function handlePress(
  env
) {
  const publications =
    (
      await getPublicPublications(
        env
      )
    )
      .filter(
        publication =>
          [
            "announced",
            "mint_live",
          ].includes(
            publication.lifecycle
          )
      )
      .map(
        publicPublicationView
      );

  return json({
    ok: true,

    engine:
      "release-bay-v2",

    source:
      "d1",

    publications,

    count:
      publications.length,
  });
}

// ============================================================
// WALLET STATUS
// ============================================================

async function handleWalletStatus(
  env,
  url
) {
  const address =
    normalizeAddress(
      url.searchParams.get(
        "address"
      )
    );

  const requestedChainId =
    Number(
      url.searchParams.get(
        "chainId"
      ) ||
      369
    );

  if (!address) {
    return json(
      {
        ok: false,

        error:
          "Valid wallet address required.",
      },
      400
    );
  }

  const chain =
    Object.values(
      CHAIN_REGISTRY
    ).find(
      candidate =>
        candidate.chainId ===
          requestedChainId &&
        candidate.enabled ===
          true
    );

  if (!chain) {
    return json(
      {
        ok: false,

        error:
          "Unsupported chain.",

        chainId:
          requestedChainId,
      },
      400
    );
  }

  const publicPublications =
    (
      await getPublicPublications(
        env
      )
    )
      .filter(
        publication =>
          publication.chainId ===
          requestedChainId
      );

  const editions = [];

  for (
    const publication
    of publicPublications
  ) {
    const copies =
      await getOwnedTokenCopies(
        env,
        publication,
        address
      );

    if (
      copies.length >
      0
    ) {
      for (
        const copy
        of copies
      ) {
        editions.push({
          ...publicPublicationView(
            publication
          ),

          ownership:
            copy.evolved
              ? "evolved"
              : "owned",

          tokenId:
            copy.tokenId,

          copyNumber:
            copy.copyNumber ??
            null,

          tokenState:
            copy.tokenState ||
            null,
        });
      }
    } else {
      editions.push({
        ...publicPublicationView(
          publication
        ),

        ownership:
          publication
            .token
            .contractAddress
            ? "missing"
            : "unavailable",

        tokenId:
          null,

        copyNumber:
          null,

        tokenState:
          null,
      });
    }
  }

  const ownedCount =
    editions.filter(
      edition =>
        edition.ownership ===
        "owned"
    ).length;

  const evolvedCount =
    editions.filter(
      edition =>
        edition.ownership ===
        "evolved"
    ).length;

  const missingCount =
    editions.filter(
      edition =>
        edition.ownership ===
        "missing"
    ).length;

  return json({
    ok: true,

    wallet: {
      address,

      chainId:
        requestedChainId,

      chainKey:
        chain.key,
    },

    summary: {
      known:
        editions.length,

      owned:
        ownedCount,

      missing:
        missingCount,

      evolved:
        evolvedCount,

      unavailable:
        editions.filter(
          edition =>
            edition.ownership ===
            "unavailable"
        ).length,
    },

    editions,
  });
}

// ============================================================
// MINT STATUS
// ============================================================

async function handleMintStatus(
  env,
  url,
  publicationKey
) {
  const publication =
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
    );
  }

  const address =
    normalizeAddress(
      url.searchParams.get(
        "address"
      )
    );

  if (!address) {
    return json(
      {
        ok: false,

        error:
          "Valid wallet address required.",
      },
      400
    );
  }

  const claimInfo =
    await getPrimaryMintClaimInfo(
      env,
      publication,
      address
    );

  return json({
    ok: true,

    publication:
      publicPublicationView(
        publication
      ),

    wallet:
      claimInfo,
  });
}

// ============================================================
// PREPARE MINT
// ============================================================

async function handleMintPrepare(
  request,
  env,
  publicationKey
) {
  const publication =
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
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
    sanitizeQuantity(
      body?.quantity ??
      1
    );

  if (!address) {
    return json(
      {
        ok: false,

        error:
          "Valid wallet address required.",
      },
      400
    );
  }

  if (
    !publication
      .mint
      .enabled ||
    publication.lifecycle !==
      "mint_live"
  ) {
    return json(
      {
        ok: false,

        mintReady:
          false,

        error:
          "Mint is not live.",
      },
      409
    );
  }

  if (
    !publication
      .token
      .contractAddress ||
    publication
      .token
      .publicationId ==
      null
  ) {
    return json(
      {
        ok: false,

        mintReady:
          false,

        error:
          "Publication contract has not been deployed yet.",
      },
      409
    );
  }

  if (
    quantity >
    publication
      .mint
      .maxPerTransaction
  ) {
    return json(
      {
        ok: false,

        mintReady:
          false,

        error:
          `Maximum ${publication.mint.maxPerTransaction} per transaction.`,
      },
      400
    );
  }

  const eligibility =
    await getPrimaryMintClaimInfo(
      env,
      publication,
      address,
      quantity
    );

  if (
    !eligibility.eligible
  ) {
    return json(
      {
        ok: false,

        mintReady:
          false,

        eligibility,

        error:
          eligibility.reason,
      },
      409
    );
  }

  try {
    const transaction =
      await buildMintTransaction(
        publication,
        address,
        quantity
      );

    return json({
      ok: true,

      mintReady:
        true,

      publication:
        publicPublicationView(
          publication
        ),

      eligibility,

      transaction,
    });
  } catch (error) {
    return json(
      {
        ok: false,

        mintReady:
          false,

        error:
          error instanceof Error
            ? error.message
            : String(error),
      },
      501
    );
  }
}

// ============================================================
// CONFIRM MINT
// ============================================================

async function handleMintConfirm(
  request,
  env,
  publicationKey
) {
  const publication =
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
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
    normalizeTxHash(
      body?.txHash
    );

  if (
    !address ||
    !txHash
  ) {
    return json(
      {
        ok: false,

        error:
          "Valid address and transaction hash required.",
      },
      400
    );
  }

  const chain =
    CHAIN_REGISTRY[
      publication.chainKey
    ];

  const receipt =
    await rpcWithFallback(
      env,
      chain,
      "eth_getTransactionReceipt",
      [
        txHash,
      ]
    );

  if (
    !receipt.result
  ) {
    return json(
      {
        ok: true,

        pending:
          true,

        transactionHash:
          txHash,

        transactionSucceeded:
          null,

        ownershipVerified:
          false,
      },
      202
    );
  }

  const succeeded =
    receipt.result.status ===
    "0x1";

  if (!succeeded) {
    return json({
      ok: true,

      pending:
        false,

      transactionHash:
        txHash,

      transactionSucceeded:
        false,

      ownershipVerified:
        false,
    });
  }

  const copies =
    await getOwnedTokenCopies(
      env,
      publication,
      address
    );

  return json({
    ok: true,

    pending:
      false,

    transactionHash:
      txHash,

    transactionSucceeded:
      true,

    ownershipVerified:
      copies.length >
      0,

    copies,
  });
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

  const body =
    await readJson(
      request
    );

  const address =
    normalizeAddress(
      body?.address
    );

  if (!address) {
    return json(
      {
        ok: false,

        error:
          "Valid wallet address required.",
      },
      400
    );
  }

  const now =
    unixNow();

  const id =
    crypto.randomUUID();

  const expiresAt =
    now +
    CHALLENGE_TTL_SECONDS;

  const nonce =
    randomHex(
      16
    );

  const message =
    [
      "Hellbox Comics Reader Authentication",

      "",

      `Wallet: ${address}`,

      `Nonce: ${nonce}`,

      `Issued At: ${new Date(
        now * 1000
      ).toISOString()}`,

      `Expires At: ${new Date(
        expiresAt * 1000
      ).toISOString()}`,

      "",

      "Signing proves wallet control. This is not a transaction and costs no gas.",
    ].join(
      "\n"
    );

  const record = {
    id,

    address,

    message,

    nonce,

    issuedAt:
      now,

    expiresAt,
  };

  await env
    .PRIVATE_BUCKET
    .put(
      `auth/challenges/${id}.json`,
      JSON.stringify(
        record
      ),
      {
        httpMetadata: {
          contentType:
            "application/json",
        },
      }
    );

  return json({
    ok: true,

    challenge: {
      id,

      message,

      expiresAt,
    },
  });
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

  const address =
    normalizeAddress(
      body?.address
    );

  const challengeId =
    String(
      body?.challengeId ||
      ""
    ).trim();

  const signature =
    normalizeSignature(
      body?.signature
    );

  if (
    !address ||
    !challengeId ||
    !signature
  ) {
    return json(
      {
        ok: false,

        error:
          "Address, challengeId and signature are required.",
      },
      400
    );
  }

  const key =
    `auth/challenges/${challengeId}.json`;

  const object =
    await env
      .PRIVATE_BUCKET
      .get(
        key
      );

  if (!object) {
    return json(
      {
        ok: false,

        error:
          "Challenge not found or already used.",
      },
      404
    );
  }

  const challenge =
    await object.json();

  if (
    challenge.address !==
      address ||
    challenge.expiresAt <=
      unixNow() ||
    typeof challenge.message !==
      "string"
  ) {
    await env
      .PRIVATE_BUCKET
      .delete(
        key
      );

    return json(
      {
        ok: false,

        error:
          "Challenge is invalid or expired.",
      },
      401
    );
  }

  let recoveredAddress;

  try {
    recoveredAddress =
      await recoverPersonalSignAddress(
        env,
        challenge.message,
        signature
      );
  } catch (error) {
    return json(
      {
        ok: false,

        error:
          "Signature verification service unavailable.",

        detail:
          error instanceof Error
            ? error.message
            : String(error),
      },
      502
    );
  }

  if (
    recoveredAddress !==
    address
  ) {
    return json(
      {
        ok: false,

        error:
          "Signature does not match wallet.",
      },
      401
    );
  }

  await env
    .PRIVATE_BUCKET
    .delete(
      key
    );

  const issuedAt =
    unixNow();

  const expiresAt =
    issuedAt +
    SESSION_TTL_SECONDS;

  const token =
    await signSessionToken(
      env,
      {
        wallet:
          address,

        chainId:
          369,

        issuedAt,

        expiresAt,

        nonce:
          randomHex(
            12
          ),
      }
    );

  return json({
    ok: true,

    verified:
      true,

    session: {
      token,

      expiresAt,
    },
  });
}

// ============================================================
// AUTH SESSION
// ============================================================

async function handleAuthSession(
  request,
  env
) {
  const session =
    await requireSession(
      request,
      env
    );

  if (!session.ok) {
    return json(
      {
        ok: false,

        authenticated:
          false,

        error:
          session.error,
      },
      session.status
    );
  }

  return json({
    ok: true,

    authenticated:
      true,

    wallet: {
      address:
        session
          .payload
          .wallet,

      chainId:
        session
          .payload
          .chainId,
    },

    expiresAt:
      session
        .payload
        .expiresAt,
  });
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
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
    );
  }

  if (
    publication.lifecycle !==
      "circulating" ||
    !publication
      .reader
      .enabled
  ) {
    return json(
      {
        ok: false,

        error:
          "Reader is not available for this publication.",
      },
      409
    );
  }

  const session =
    await requireSession(
      request,
      env
    );

  if (!session.ok) {
    return json(
      {
        ok: false,

        error:
          session.error,
      },
      session.status
    );
  }

  const ownership =
    await verifyPublicationOwnership(
      env,
      publication,
      session
        .payload
        .wallet
    );

  if (
    !ownership.owned
  ) {
    return json(
      {
        ok: false,

        access:
          "denied",

        error:
          "Edition ownership required.",
      },
      403
    );
  }

  const manifest =
    await loadReaderManifest(
      env,
      publication
    );

  return json({
    ok: true,

    access:
      "granted",

    publication:
      publicPublicationView(
        publication
      ),

    ownership,

    reader: {
      manifest,
    },
  });
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
    await getPublicPublication(
      env,
      publicationKey
    );

  if (!publication) {
    return json(
      {
        ok: false,

        error:
          "Publication not found.",
      },
      404
    );
  }

  if (
    publication.lifecycle !==
      "circulating" ||
    !publication
      .reader
      .enabled
  ) {
    return json(
      {
        ok: false,

        error:
          "Reader is not available for this publication.",
      },
      409
    );
  }

  const session =
    await requireSession(
      request,
      env
    );

  if (!session.ok) {
    return json(
      {
        ok: false,

        error:
          session.error,
      },
      session.status
    );
  }

  const ownership =
    await verifyPublicationOwnership(
      env,
      publication,
      session
        .payload
        .wallet
    );

  if (
    !ownership.owned
  ) {
    return json(
      {
        ok: false,

        error:
          "Edition ownership required.",
      },
      403
    );
  }

  const manifest =
    await loadReaderManifest(
      env,
      publication
    );

  const page =
    manifest.pages.find(
      candidate =>
        String(
          candidate.id
        ) ===
        String(
          assetId
        )
    );

  if (
    !page ||
    !page.storageKey
  ) {
    return json(
      {
        ok: false,

        error:
          "Reader asset not found.",
      },
      404
    );
  }

  const normalizedKey =
    normalizePrivateReaderKey(
      publication,
      page.storageKey
    );

  if (
    !normalizedKey
  ) {
    return json(
      {
        ok: false,

        error:
          "Reader asset key rejected.",
      },
      400
    );
  }

  const object =
    await env
      .PRIVATE_BUCKET
      .get(
        normalizedKey
      );

  if (!object) {
    return json(
      {
        ok: false,

        error:
          "Protected reader asset unavailable.",
      },
      404
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

  return new Response(
    object.body,
    {
      status:
        200,

      headers,
    }
  );
}

// ============================================================
// PUBLICATION HELPERS
// ============================================================

function requireDatabase(
  env
) {
  if (
    !env ||
    !env.DB
  ) {
    throw new Error(
      "Publication database binding unavailable."
    );
  }

  return env.DB;
}

async function getPublicationRegistrySummary(
  env
) {
  const row =
    await requireDatabase(
      env
    )
      .prepare(
        `
          SELECT
            COUNT(*) AS total_configured,
            SUM(CASE WHEN p.public_visible = 1 THEN 1 ELSE 0 END) AS public_count,
            SUM(CASE WHEN p.public_visible = 0 THEN 1 ELSE 0 END) AS private_count,
            SUM(
              CASE
                WHEN
                  f.reader_enabled = 1
                  AND EXISTS (
                    SELECT 1
                    FROM publication_packages pkg
                    WHERE pkg.publication_key = p.publication_key
                      AND pkg.reader_manifest_key IS NOT NULL
                      AND TRIM(pkg.reader_manifest_key) != ''
                      AND pkg.private_prefix IS NOT NULL
                      AND TRIM(pkg.private_prefix) != ''
                  )
                THEN 1
                ELSE 0
              END
            ) AS reader_configured_count
          FROM publications p
          LEFT JOIN publication_features f
            ON f.publication_key = p.publication_key
        `
      )
      .first();

  return {
    source:
      "d1",

    totalConfigured:
      Number(
        row?.total_configured ||
        0
      ),

    publicCount:
      Number(
        row?.public_count ||
        0
      ),

    privateCount:
      Number(
        row?.private_count ||
        0
      ),

    readerConfiguredCount:
      Number(
        row?.reader_configured_count ||
        0
      ),
  };
}

async function getPublicPublications(
  env
) {
  return getPublications(
    env,
    true
  );
}

async function getPublication(
  env,
  publicationKey
) {
  const normalizedKey =
    normalizePublicationKey(
      publicationKey
    );

  if (!normalizedKey) {
    return null;
  }

  const publications =
    await queryPublications(
      env,
      {
        publicationKey:
          normalizedKey,

        publicOnly:
          false,
      }
    );

  return publications[0] ||
    null;
}

async function getPublicPublication(
  env,
  publicationKey
) {
  const normalizedKey =
    normalizePublicationKey(
      publicationKey
    );

  if (!normalizedKey) {
    return null;
  }

  const publications =
    await queryPublications(
      env,
      {
        publicationKey:
          normalizedKey,

        publicOnly:
          true,
      }
    );

  return publications[0] ||
    null;
}

async function getPublications(
  env,
  publicOnly = false
) {
  return queryPublications(
    env,
    {
      publicOnly,
    }
  );
}

async function queryPublications(
  env,
  {
    publicationKey = null,
    publicOnly = false,
  } = {}
) {
  const db =
    requireDatabase(
      env
    );

  const filters =
    [];

  const bindings =
    [];

  if (publicationKey) {
    filters.push(
      "p.publication_key = ?"
    );

    bindings.push(
      publicationKey
    );
  }

  if (publicOnly) {
    filters.push(
      "p.public_visible = 1"
    );
  }

  const whereClause =
    filters.length > 0
      ? `WHERE ${filters.join(" AND ")}`
      : "";

  let statement =
    db.prepare(
      `
        SELECT
          p.publication_key,
          p.title,
          p.slug,
          p.kind,
          p.series_key,
          p.series_title,
          p.issue_number,
          p.lifecycle,
          p.public_visible,
          p.presentation_class,
          p.canonical_locale,
          p.external_url,

          f.reader_enabled,
          f.reader_access_policy,
          f.sealed_enabled,
          f.vault_enabled,
          f.sin_enabled,
          f.evolution_enabled,
          f.easter_eggs_enabled,
          f.hellforge_enabled,
          f.token_bound_account_enabled,

          c.chain_key,
          c.chain_id,
          c.token_standard,
          c.contract_address,
          c.publication_id,
          c.publishing_enabled,
          c.max_supply,
          c.payment_type,
          c.payment_token_address,
          c.payment_token_symbol,
          c.price_base_units,
          c.price_display,
          c.max_primary_mints_per_wallet,
          c.max_per_transaction,
          c.royalty_bps,
          c.royalty_receiver,

          pkg.package_version,
          pkg.status AS package_status,
          pkg.private_prefix,
          pkg.reader_manifest_key

        FROM publications p

        LEFT JOIN publication_features f
          ON f.publication_key =
            p.publication_key

        LEFT JOIN publication_chain_configs c
          ON c.publication_key =
            p.publication_key

        LEFT JOIN publication_packages pkg
          ON pkg.package_id = (
            SELECT pkg2.package_id
            FROM publication_packages pkg2
            WHERE pkg2.publication_key =
              p.publication_key
            ORDER BY
              CASE pkg2.status
                WHEN 'active' THEN 0
                WHEN 'validated' THEN 1
                WHEN 'draft' THEN 2
                WHEN 'retired' THEN 3
                ELSE 4
              END,
              pkg2.package_version DESC
            LIMIT 1
          )

        ${whereClause}

        ORDER BY
          CASE p.lifecycle
            WHEN 'mint_live' THEN 0
            WHEN 'announced' THEN 1
            WHEN 'circulating' THEN 2
            ELSE 3
          END,
          p.publication_key ASC,
          CASE
            WHEN c.chain_key = '${DEFAULT_CHAIN_KEY}'
            THEN 0
            ELSE 1
          END,
          c.chain_id ASC,
          c.chain_key ASC
      `
    );

  if (bindings.length > 0) {
    statement =
      statement.bind(
        ...bindings
      );
  }

  const result =
    await statement.all();

  return hydratePublicationRows(
    Array.isArray(
      result?.results
    )
      ? result.results
      : []
  );
}

function hydratePublicationRows(
  rows
) {
  const publications =
    new Map();

  for (
    const row
    of rows
  ) {
    let publication =
      publications.get(
        row.publication_key
      );

    if (!publication) {
      publication =
        publicationFromD1Row(
          row
        );

      publications.set(
        row.publication_key,
        publication
      );
    }

    if (row.chain_key) {
      publication.chains.push(
        chainFromD1Row(
          row,
          publication
        )
      );
    }
  }

  for (
    const publication
    of publications.values()
  ) {
    const primaryChain =
      publication.chains[0] ||
      null;

    publication.chainKey =
      primaryChain?.chainKey ||
      null;

    publication.chainId =
      primaryChain?.chainId ||
      null;

    publication.token =
      primaryChain?.token ||
      emptyPublicationToken();

    publication.mint =
      primaryChain?.mint ||
      emptyPublicationMint();
  }

  return Array.from(
    publications.values()
  );
}

function publicationFromD1Row(
  row
) {
  return {
    publicationKey:
      row.publication_key,

    title:
      row.title,

    subtitle:
      null,

    publicationType:
      row.kind,

    contentType:
      row.presentation_class ===
      "book"
        ? "ebook"
        : row.presentation_class,

    series:
      row.kind ===
      "serial"
        ? {
            key:
              row.series_key,

            title:
              row.series_title,
          }
        : null,

    issue:
      row.issue_number,

    lifecycle:
      row.lifecycle,

    publicVisible:
      d1Boolean(
        row.public_visible
      ),

    canonicalLocale:
      row.canonical_locale,

    externalUrl:
      row.external_url,

    chainKey:
      null,

    chainId:
      null,

    token:
      emptyPublicationToken(),

    mint:
      emptyPublicationMint(),

    chains:
      [],

    reader: readerFromD1Row(
      row
    ),

    features: {
      sealed:
        d1Boolean(
          row.sealed_enabled
        ),

      vaulting:
        d1Boolean(
          row.vault_enabled
        ),

      evolution:
        d1Boolean(
          row.evolution_enabled
        ),

      hellforge:
        d1Boolean(
          row.hellforge_enabled
        ),

      sin:
        d1Boolean(
          row.sin_enabled
        ),

      easterEggs:
        d1Boolean(
          row.easter_eggs_enabled
        ),

      tokenBoundAccount:
        d1Boolean(
          row.token_bound_account_enabled
        ),
    },

    media: {
      cover:
        null,

      press:
        null,
    },
  };
}

function readerFromD1Row(
  row
) {
  const manifestKey =
    normalizeReaderStoragePointer(
      row.reader_manifest_key,
      false
    );

  const assetPrefix =
    normalizeReaderStoragePointer(
      row.private_prefix,
      true
    );

  const configured =
    Boolean(
      manifestKey &&
      assetPrefix
    );

  return {
    enabled:
      d1Boolean(
        row.reader_enabled
      ),

    accessPolicy:
      row.reader_access_policy ||
      "ownership",

    source:
      configured
        ? "private"
        : "unconfigured",

    manifestKey:
      configured
        ? manifestKey
        : null,

    assetPrefix:
      configured
        ? assetPrefix
        : null,

    packageVersion:
      row.package_version == null
        ? null
        : Number(
            row.package_version
          ),

    packageStatus:
      row.package_status ||
      null,
  };
}

function normalizeReaderStoragePointer(
  value,
  ensureTrailingSlash
) {
  const normalized =
    String(
      value ||
      ""
    )
      .trim()
      .replace(
        /^\/+/,
        ""
      );

  if (
    !normalized ||
    normalized.includes(
      ".."
    )
  ) {
    return null;
  }

  if (
    ensureTrailingSlash &&
    !normalized.endsWith(
      "/"
    )
  ) {
    return `${normalized}/`;
  }

  return normalized;
}

function chainFromD1Row(
  row,
  publication
) {
  const paymentType =
    String(
      row.payment_type ||
      ""
    ).toUpperCase();

  return {
    chainKey:
      row.chain_key,

    chainId:
      Number(
        row.chain_id
      ),

    token: {
      standard:
        row.token_standard,

      contractAddress:
        row.contract_address,

      publicationId:
        row.publication_id,

      tokenBoundAccountCompatible:
        publication
          .features
          .tokenBoundAccount,
    },

    mint: {
      enabled:
        d1Boolean(
          row.publishing_enabled
        ),

      paymentType,

      paymentToken:
        row.payment_type ===
        "erc20"
          ? {
              address:
                row.payment_token_address,

              symbol:
                row.payment_token_symbol,
            }
          : null,

      price:
        row.payment_type ===
          "free"
          ? null
          : {
              baseUnits:
                String(
                  row.price_base_units ||
                  "0"
                ),

              display:
                row.price_display ||
                null,
            },

      maxSupply:
        Number(
          row.max_supply
        ),

      maxPrimaryMintsPerWallet:
        Number(
          row.max_primary_mints_per_wallet
        ),

      maxPerTransaction:
        Number(
          row.max_per_transaction
        ),

      royaltyBps:
        Number(
          row.royalty_bps
        ),

      royaltyReceiver:
        row.royalty_receiver ||
        null,
    },
  };
}

function normalizePublicationKey(
  publicationKey
) {
  const normalized =
    String(
      publicationKey ||
      ""
    )
      .trim()
      .toLowerCase();

  return /^[a-z0-9-]+$/.test(
    normalized
  )
    ? normalized
    : null;
}

function d1Boolean(
  value
) {
  return Number(
    value ||
    0
  ) === 1;
}

function emptyPublicationToken() {
  return {
    standard:
      "ERC721",

    contractAddress:
      null,

    publicationId:
      null,

    tokenBoundAccountCompatible:
      false,
  };
}

function emptyPublicationMint() {
  return {
    enabled:
      false,

    paymentType:
      null,

    paymentToken:
      null,

    price:
      null,

    maxSupply:
      null,

    maxPrimaryMintsPerWallet:
      null,

    maxPerTransaction:
      null,

    royaltyBps:
      null,

    royaltyReceiver:
      null,
  };
}

function publicPublicationView(
  publication
) {
  return {
    publicationKey:
      publication
        .publicationKey,

    title:
      publication.title,

    subtitle:
      publication.subtitle,

    publicationType:
      publication
        .publicationType,

    contentType:
      publication
        .contentType,

    series:
      publication.series,

    issue:
      publication.issue,

    lifecycle:
      publication.lifecycle,

    canonicalLocale:
      publication
        .canonicalLocale,

    externalUrl:
      publication
        .externalUrl,

    chainKey:
      publication.chainKey,

    chainId:
      publication.chainId,

    token: {
      ...publication.token,
    },

    mint: {
      ...publication.mint,
    },

    chains:
      publication.chains.map(
        chain => ({
          chainKey:
            chain.chainKey,

          chainId:
            chain.chainId,

          token: {
            ...chain.token,
          },

          mint: {
            ...chain.mint,
          },
        })
      ),

    reader: {
      enabled:
        publication
          .reader
          .enabled,

      accessPolicy:
        publication
          .reader
          .accessPolicy,
    },

    features: {
      ...publication.features,
    },

    media: {
      ...publication.media,
    },
  };
}

// ============================================================
// LEGACY ROUTE DETECTION
// ============================================================

function resolveLegacyPublication(
  pathname
) {
  const match =
    pathname.match(
      /^\/api\/(?:comics|reader|mint)\/([a-z0-9-]+)\/(\d+)(?:\/.*)?$/
    );

  if (!match) {
    return null;
  }

  const legacyKey =
    `${match[1]}:${Number(
      match[2]
    )}`;

  const publicationKey =
    LEGACY_SLUG_MAP[
      legacyKey
    ];

  return publicationKey
    ? {
        publicationKey,
      }
    : {
        publicationKey:
          null,
      };
}

// ============================================================
// OWNERSHIP
// ============================================================

async function getOwnedTokenCopies(
  env,
  publication,
  address
) {
  if (
    !publication
      .token
      .contractAddress ||
    publication
      .token
      .publicationId ==
      null
  ) {
    return [];
  }

  /*
   * INTENTIONALLY NOT GUESSED.
   *
   * The Hellbox ERC-721 contract has not been deployed yet.
   *
   * Once deployed, this function will use:
   *
   * 1. indexed Transfer-event ownership cache
   * 2. final ownerOf verification
   *
   * We will NOT use ERC721Enumerable.
   * We will NOT repeatedly scan the entire chain per request.
   */

  return [];
}

async function verifyPublicationOwnership(
  env,
  publication,
  address
) {
  const copies =
    await getOwnedTokenCopies(
      env,
      publication,
      address
    );

  return {
    owned:
      copies.length >
      0,

    copies,
  };
}

// ============================================================
// PRIMARY MINT CLAIM STATUS
// ============================================================

async function getPrimaryMintClaimInfo(
  env,
  publication,
  address,
  requestedQuantity = 1
) {
  if (
    !publication
      .mint
      .enabled ||
    publication.lifecycle !==
      "mint_live"
  ) {
    return {
      address,

      state:
        "mint_closed",

      eligible:
        false,

      reason:
        "Mint is not live.",

      lifetimePrimaryMinted:
        0,

      remainingPrimaryAllowance:
        publication
          .mint
          .maxPrimaryMintsPerWallet,
    };
  }

  if (
    !publication
      .token
      .contractAddress ||
    publication
      .token
      .publicationId ==
      null
  ) {
    return {
      address,

      state:
        "contract_pending",

      eligible:
        false,

      reason:
        "Publication contract has not been deployed yet.",

      lifetimePrimaryMinted:
        0,

      remainingPrimaryAllowance:
        publication
          .mint
          .maxPrimaryMintsPerWallet,
    };
  }

  throw new Error(
    "Primary mint claim lookup is intentionally disabled until the deployed HellboxNFT ABI and addresses are configured."
  );
}

// ============================================================
// MINT TRANSACTION BUILDER
// ============================================================

async function buildMintTransaction(
  publication,
  address,
  quantity
) {
  throw new Error(
    "Mint transaction encoding is intentionally disabled until the deployed HellboxNFT ABI is configured."
  );
}

// ============================================================
// READER MANIFEST
// ============================================================

async function loadReaderManifest(
  env,
  publication
) {
  requirePrivateBucket(
    env
  );

  if (
    publication
      .reader
      .source !==
    "private" ||
    !publication
      .reader
      .manifestKey ||
    !publication
      .reader
      .assetPrefix
  ) {
    throw new Error(
      "Reader delivery is not configured in D1."
    );
  }

  const object =
    await env
      .PRIVATE_BUCKET
      .get(
        publication
          .reader
          .manifestKey
      );

  if (!object) {
    throw new Error(
      "Protected reader manifest unavailable."
    );
  }

  const rawManifest =
    await object.json();

  if (
    String(
      rawManifest?.publicationKey ||
      ""
    ) !==
      publication.publicationKey
  ) {
    throw new Error(
      "Protected reader manifest publication mismatch."
    );
  }

  const manifestPrefix =
    normalizeReaderStoragePointer(
      rawManifest?.delivery
        ?.assetPrefix,
      true
    );

  if (
    !manifestPrefix ||
    manifestPrefix !==
      publication
        .reader
        .assetPrefix
  ) {
    throw new Error(
      "Protected reader manifest prefix does not match D1."
    );
  }

  const rawPages =
    Array.isArray(
      rawManifest.pages
    )
      ? rawManifest.pages
      : [];

  const declaredPageCount =
    Number(
      rawManifest.pageCount ??
      rawPages.length
    );

  if (
    !Number.isInteger(
      declaredPageCount
    ) ||
    declaredPageCount <= 0 ||
    declaredPageCount !==
      rawPages.length
  ) {
    throw new Error(
      "Protected reader manifest page count is invalid."
    );
  }

  const pages =
    rawPages.map(
      (
        page,
        index
      ) => {
        const id =
          String(
            page.id ??
            page.assetId ??
            index +
              1
          );

        const storageKey =
          String(
            page.storageKey ??
            page.key ??
            page.path ??
            ""
          );

        if (
          !storageKey
        ) {
          throw new Error(
            `Reader manifest page ${index + 1} has no storage key.`
          );
        }

        return {
          id,

          pageNumber:
            Number(
              page.pageNumber ??
              index +
                1
            ),

          mediaType:
            page.mediaType ||
            page.contentType ||
            "image/*",

          endpoint:
            `/api/reader/${encodeURIComponent(
              publication.publicationKey
            )}/asset/${encodeURIComponent(
              id
            )}`,

          storageKey,
        };
      }
    );

  return {
    ...rawManifest,

    publicationKey:
      publication
        .publicationKey,

    title:
      rawManifest.title ||
      publication.title,

    layout:
      rawManifest.layout ===
      "continuous"
        ? "continuous"
        : "paged",

    pages,
  };
}

// ============================================================
// PRIVATE READER PATH SAFETY
// ============================================================

function normalizePrivateReaderKey(
  publication,
  inputKey
) {
  const prefix =
    publication
      .reader
      .assetPrefix;

  const raw =
    String(
      inputKey ||
      ""
    ).replace(
      /^\/+/,
      ""
    );

  const key =
    raw.startsWith(
      prefix
    )
      ? raw
      : `${prefix}${raw}`;

  if (
    key.includes(
      ".."
    ) ||
    !key.startsWith(
      prefix
    )
  ) {
    return null;
  }

  return key;
}

// ============================================================
// RPC PRIMARY + FALLBACK
// ============================================================

async function rpcWithFallback(
  env,
  chain,
  method,
  params
) {
  try {
    const result =
      await rpcCall(
        chain.primaryRpcUrl,
        method,
        params
      );

    return {
      result,

      provider:
        `Public ${chain.shortName || chain.name} RPC`,

      fallbackUsed:
        false,
    };
  } catch (
    primaryError
  ) {
    if (
      !chain
        .fallbackRpcEnvKey ||
      !env[
        chain
          .fallbackRpcEnvKey
      ]
    ) {
      throw primaryError;
    }

    const result =
      await rpcCall(
        env[
          chain
            .fallbackRpcEnvKey
        ],
        method,
        params
      );

    return {
      result,

      provider:
        "HairyLabs Byte",

      fallbackUsed:
        true,
    };
  }
}

// ============================================================
// RAW RPC
// ============================================================

async function rpcCall(
  rpcUrl,
  method,
  params
) {
  if (!rpcUrl) {
    throw new Error(
      `RPC URL unavailable for ${method}.`
    );
  }

  const controller =
    new AbortController();

  const timeout =
    setTimeout(
      () =>
        controller.abort(),
      8000
    );

  try {
    const response =
      await fetch(
        rpcUrl,
        {
          method:
            "POST",

          headers: {
            "Content-Type":
              "application/json",
          },

          body:
            JSON.stringify({
              jsonrpc:
                "2.0",

              id:
                1,

              method,

              params,
            }),

          signal:
            controller.signal,
        }
      );

    if (
      !response.ok
    ) {
      throw new Error(
        `RPC HTTP ${response.status}.`
      );
    }

    const payload =
      await response.json();

    if (
      payload.error
    ) {
      throw new Error(
        payload
          .error
          .message ||
        `RPC ${method} failed.`
      );
    }

    if (
      payload.result ===
      undefined
    ) {
      throw new Error(
        `RPC ${method} returned no result.`
      );
    }

    return payload.result;
  } finally {
    clearTimeout(
      timeout
    );
  }
}

// ============================================================
// PERSONAL_SIGN RECOVERY
// ============================================================

async function recoverPersonalSignAddress(
  env,
  message,
  signature
) {
  const chain =
    CHAIN_REGISTRY
      .pulsechain;

  const messageBytes =
    new TextEncoder()
      .encode(
        message
      );

  const prefixBytes =
    new TextEncoder()
      .encode(
        `\x19Ethereum Signed Message:\n${messageBytes.length}`
      );

  const signedBytes =
    concatBytes(
      prefixBytes,
      messageBytes
    );

  const digest =
    await rpcWithFallback(
      env,
      chain,
      "web3_sha3",
      [
        bytesToHex(
          signedBytes
        ),
      ]
    );

  const signatureBytes =
    hexToBytes(
      signature
    );

  if (
    signatureBytes.length !==
    65
  ) {
    throw new Error(
      "Signature must be 65 bytes."
    );
  }

  const r =
    signatureBytes.slice(
      0,
      32
    );

  const s =
    signatureBytes.slice(
      32,
      64
    );

  let v =
    signatureBytes[
      64
    ];

  if (
    v <
    27
  ) {
    v +=
      27;
  }

  const input =
    concatBytes(
      hexToBytes(
        digest.result
      ),

      leftPadBytes(
        new Uint8Array(
          [
            v,
          ]
        ),
        32
      ),

      r,

      s
    );

  const recovered =
    await rpcWithFallback(
      env,
      chain,
      "eth_call",
      [
        {
          to:
            "0x0000000000000000000000000000000000000001",

          data:
            bytesToHex(
              input
            ),
        },

        "latest",
      ]
    );

  const output =
    String(
      recovered.result ||
      ""
    ).replace(
      /^0x/,
      ""
    );

  if (
    output.length <
    40
  ) {
    throw new Error(
      "ecrecover returned no address."
    );
  }

  return normalizeAddress(
    `0x${output.slice(
      -40
    )}`
  );
}

// ============================================================
// SESSION SIGNING
// ============================================================

async function signSessionToken(
  env,
  payload
) {
  requireSessionSecret(
    env
  );

  const encodedPayload =
    base64UrlEncodeString(
      JSON.stringify(
        payload
      )
    );

  const signature =
    await hmacSha256(
      env
        .HELLBOX_SESSION_SECRET,
      encodedPayload
    );

  return `${encodedPayload}.${base64UrlEncodeBytes(
    signature
  )}`;
}

// ============================================================
// SESSION VERIFICATION
// ============================================================

async function verifySessionToken(
  env,
  token
) {
  requireSessionSecret(
    env
  );

  const parts =
    String(
      token ||
      ""
    ).split(
      "."
    );

  if (
    parts.length !==
    2
  ) {
    return null;
  }

  const [
    encodedPayload,
    encodedSignature,
  ] = parts;

  const expected =
    await hmacSha256(
      env
        .HELLBOX_SESSION_SECRET,
      encodedPayload
    );

  const actual =
    base64UrlDecodeBytes(
      encodedSignature
    );

  if (
    !timingSafeEqual(
      expected,
      actual
    )
  ) {
    return null;
  }

  let payload;

  try {
    payload =
      JSON.parse(
        base64UrlDecodeString(
          encodedPayload
        )
      );
  } catch {
    return null;
  }

  if (
    !normalizeAddress(
      payload.wallet
    ) ||
    Number(
      payload.chainId
    ) !==
      369 ||
    Number(
      payload.expiresAt
    ) <=
      unixNow()
  ) {
    return null;
  }

  payload.wallet =
    normalizeAddress(
      payload.wallet
    );

  return payload;
}

// ============================================================
// REQUIRE SESSION
// ============================================================

async function requireSession(
  request,
  env
) {
  const authorization =
    request.headers.get(
      "Authorization"
    ) ||
    "";

  const match =
    authorization.match(
      /^Bearer\s+(.+)$/i
    );

  if (!match) {
    return {
      ok:
        false,

      status:
        401,

      error:
        "Reader session required.",
    };
  }

  const payload =
    await verifySessionToken(
      env,
      match[1]
    );

  if (!payload) {
    return {
      ok:
        false,

      status:
        401,

      error:
        "Reader session is invalid or expired.",
    };
  }

  return {
    ok:
      true,

    payload,
  };
}

// ============================================================
// HMAC
// ============================================================

async function hmacSha256(
  secret,
  message
) {
  const key =
    await crypto
      .subtle
      .importKey(
        "raw",

        new TextEncoder()
          .encode(
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
    await crypto
      .subtle
      .sign(
        "HMAC",

        key,

        new TextEncoder()
          .encode(
            message
          )
      );

  return new Uint8Array(
    signature
  );
}

// ============================================================
// TIMING SAFE COMPARISON
// ============================================================

function timingSafeEqual(
  a,
  b
) {
  if (
    !(a instanceof Uint8Array) ||
    !(b instanceof Uint8Array) ||
    a.length !==
      b.length
  ) {
    return false;
  }

  let diff =
    0;

  for (
    let i =
      0;
    i <
    a.length;
    i++
  ) {
    diff |=
      a[i] ^
      b[i];
  }

  return (
    diff ===
    0
  );
}

// ============================================================
// BASE64 URL
// ============================================================

function base64UrlEncodeString(
  value
) {
  return base64UrlEncodeBytes(
    new TextEncoder()
      .encode(
        value
      )
  );
}

function base64UrlDecodeString(
  value
) {
  return new TextDecoder()
    .decode(
      base64UrlDecodeBytes(
        value
      )
    );
}

function base64UrlEncodeBytes(
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

function base64UrlDecodeBytes(
  value
) {
  const normalized =
    String(
      value
    )
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

  const bytes =
    new Uint8Array(
      binary.length
    );

  for (
    let i =
      0;
    i <
    binary.length;
    i++
  ) {
    bytes[i] =
      binary.charCodeAt(
        i
      );
  }

  return bytes;
}

// ============================================================
// RANDOM
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
  ).slice(
    2
  );
}

// ============================================================
// HEX
// ============================================================

function bytesToHex(
  bytes
) {
  return `0x${Array.from(
    bytes,
    byte =>
      byte
        .toString(
          16
        )
        .padStart(
          2,
          "0"
        )
  ).join(
    ""
  )}`;
}

function hexToBytes(
  value
) {
  const hex =
    String(
      value ||
      ""
    ).replace(
      /^0x/,
      ""
    );

  if (
    hex.length %
      2 !==
      0 ||
    !/^[0-9a-f]*$/i.test(
      hex
    )
  ) {
    throw new Error(
      "Invalid hex value."
    );
  }

  const bytes =
    new Uint8Array(
      hex.length /
      2
    );

  for (
    let i =
      0;
    i <
    bytes.length;
    i++
  ) {
    bytes[i] =
      parseInt(
        hex.slice(
          i *
            2,
          i *
            2 +
            2
        ),
        16
      );
  }

  return bytes;
}

// ============================================================
// BYTE HELPERS
// ============================================================

function concatBytes(
  ...arrays
) {
  const totalLength =
    arrays.reduce(
      (
        sum,
        array
      ) =>
        sum +
        array.length,
      0
    );

  const result =
    new Uint8Array(
      totalLength
    );

  let offset =
    0;

  for (
    const array
    of arrays
  ) {
    result.set(
      array,
      offset
    );

    offset +=
      array.length;
  }

  return result;
}

function leftPadBytes(
  bytes,
  targetLength
) {
  if (
    bytes.length >
    targetLength
  ) {
    throw new Error(
      "Value exceeds target length."
    );
  }

  const result =
    new Uint8Array(
      targetLength
    );

  result.set(
    bytes,
    targetLength -
      bytes.length
  );

  return result;
}

// ============================================================
// NORMALIZATION
// ============================================================

function normalizeAddress(
  value
) {
  const address =
    String(
      value ||
      ""
    )
      .trim()
      .toLowerCase();

  return /^0x[0-9a-f]{40}$/.test(
    address
  )
    ? address
    : null;
}

function normalizeTxHash(
  value
) {
  const hash =
    String(
      value ||
      ""
    )
      .trim()
      .toLowerCase();

  return /^0x[0-9a-f]{64}$/.test(
    hash
  )
    ? hash
    : null;
}

function normalizeSignature(
  value
) {
  const signature =
    String(
      value ||
      ""
    )
      .trim()
      .toLowerCase();

  return /^0x[0-9a-f]{130}$/.test(
    signature
  )
    ? signature
    : null;
}

function sanitizeQuantity(
  value
) {
  const quantity =
    Number(
      value
    );

  if (
    !Number.isInteger(
      quantity
    ) ||
    quantity <
      1 ||
    quantity >
      100
  ) {
    return 1;
  }

  return quantity;
}

// ============================================================
// TIME
// ============================================================

function unixNow() {
  return Math.floor(
    Date.now() /
    1000
  );
}

// ============================================================
// JSON BODY
// ============================================================

async function readJson(
  request
) {
  try {
    return await request.json();
  } catch {
    return null;
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
      "PRIVATE_BUCKET binding is unavailable."
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
      "HELLBOX_SESSION_SECRET is unavailable."
    );
  }
}

// ============================================================
// CORS PREFLIGHT
// ============================================================

function corsPreflight(
  origin
) {
  const headers =
    new Headers({
      "Access-Control-Allow-Methods":
        "GET, POST, OPTIONS",

      "Access-Control-Allow-Headers":
        "Content-Type, Authorization",

      "Access-Control-Max-Age":
        "86400",
    });

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

  return new Response(
    null,
    {
      status:
        204,

      headers,
    }
  );
}

// ============================================================
// CORS
// ============================================================

function withCors(
  response,
  origin
) {
  if (
    !origin ||
    !ALLOWED_ORIGINS.has(
      origin
    )
  ) {
    return response;
  }

  const headers =
    new Headers(
      response.headers
    );

  headers.set(
    "Access-Control-Allow-Origin",
    origin
  );

  headers.set(
    "Vary",
    "Origin"
  );

  return new Response(
    response.body,
    {
      status:
        response.status,

      statusText:
        response.statusText,

      headers,
    }
  );
}

// ============================================================
// JSON RESPONSE
// ============================================================

function json(
  data,
  status = 200
) {
  return new Response(
    JSON.stringify(
      data,
      null,
      2
    ),
    {
      status,

      headers: {
        "Content-Type":
          "application/json; charset=utf-8",

        "Cache-Control":
          "no-store",

        "X-Content-Type-Options":
          "nosniff",
      },
    }
  );
}
