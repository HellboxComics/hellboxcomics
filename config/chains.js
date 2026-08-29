/**
 * HELLBOX COMICS — PUBLIC EVM CHAIN REGISTRY
 * Gate 0.2 recovery — dormant foundation
 *
 * IMPORTANT:
 * - This file is intentionally safe to deploy before it is loaded by index.html.
 * - PulseChain is Hellbox's root/origin network, not its permanent boundary.
 * - Every supported chain receives its own native Hellbox deployment.
 * - Hellbox comic NFTs are never bridged between chains.
 * - A conceptual publication is identified by publicationKey.
 * - A specific onchain asset is identified by (chainId, contractAddress, tokenId).
 * - No contract is considered publishable until a real deployment is recorded.
 * - This registry contains public network metadata only. Never place secrets,
 *   private RPC credentials, signing keys, or wallet identity data here.
 */
(() => {
    "use strict";

    const REGISTRY_VERSION = "0.2.0-recovery.1";
    const DEFAULT_CHAIN_KEY = "pulsechain";
    const DEVELOPMENT_CHAIN_KEY = "pulsechainTestnetV4";

    function deepFreeze(value) {
        if (!value || typeof value !== "object" || Object.isFrozen(value)) {
            return value;
        }

        Object.freeze(value);

        for (const child of Object.values(value)) {
            deepFreeze(child);
        }

        return value;
    }

    function chainIdToHex(chainId) {
        const numeric = Number(chainId);

        if (!Number.isSafeInteger(numeric) || numeric <= 0) {
            throw new TypeError(`Invalid EVM chain id: ${chainId}`);
        }

        return `0x${numeric.toString(16)}`;
    }

    function defineChain(config) {
        return {
            ...config,
            chainIdHex: chainIdToHex(config.chainId),
            deployment: config.deployment ?? null
        };
    }

    const CHAINS = deepFreeze({
        pulsechain: defineChain({
            key: "pulsechain",
            chainId: 369,
            name: "PulseChain",
            shortName: "PulseChain",
            networkType: "mainnet",
            nativeCurrency: {
                name: "Pulse",
                symbol: "PLS",
                decimals: 18
            },
            explorerUrl: "https://scan.pulsechain.com",
            rpcUrls: [
                "https://rpc.pulsechain.com"
            ],
            faucetUrl: null,
            root: true,
            enabled: true,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        pulsechainTestnetV4: defineChain({
            key: "pulsechainTestnetV4",
            chainId: 943,
            name: "PulseChain Testnet V4",
            shortName: "PulseChain V4",
            networkType: "testnet",
            nativeCurrency: {
                name: "Test Pulse",
                symbol: "tPLS",
                decimals: 18
            },
            explorerUrl: "https://scan.v4.testnet.pulsechain.com",
            rpcUrls: [
                "https://rpc.v4.testnet.pulsechain.com"
            ],
            faucetUrl: "https://faucet.v4.testnet.pulsechain.com",
            root: false,
            enabled: false,
            testingEnabled: true,
            publishingEnabled: false,
            deployment: null
        }),

        ethereum: defineChain({
            key: "ethereum",
            chainId: 1,
            name: "Ethereum",
            shortName: "Ethereum",
            networkType: "mainnet",
            nativeCurrency: {
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            },
            explorerUrl: "https://etherscan.io",
            rpcUrls: [],
            faucetUrl: null,
            root: false,
            enabled: false,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        base: defineChain({
            key: "base",
            chainId: 8453,
            name: "Base Mainnet",
            shortName: "Base",
            networkType: "mainnet",
            nativeCurrency: {
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            },
            explorerUrl: "https://base.blockscout.com",
            rpcUrls: [
                "https://mainnet.base.org"
            ],
            faucetUrl: null,
            root: false,
            enabled: false,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        baseSepolia: defineChain({
            key: "baseSepolia",
            chainId: 84532,
            name: "Base Sepolia",
            shortName: "Base Sepolia",
            networkType: "testnet",
            nativeCurrency: {
                name: "Sepolia Ether",
                symbol: "ETH",
                decimals: 18
            },
            explorerUrl: "https://sepolia-explorer.base.org",
            rpcUrls: [
                "https://sepolia.base.org"
            ],
            faucetUrl: null,
            root: false,
            enabled: false,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        robinhoodChain: defineChain({
            key: "robinhoodChain",
            chainId: 4663,
            name: "Robinhood Chain",
            shortName: "Robinhood Chain",
            networkType: "mainnet",
            nativeCurrency: {
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            },
            explorerUrl: "https://robinhoodchain.blockscout.com",
            rpcUrls: [
                "https://rpc.mainnet.chain.robinhood.com"
            ],
            faucetUrl: null,
            root: false,
            enabled: false,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        robinhoodChainTestnet: defineChain({
            key: "robinhoodChainTestnet",
            chainId: 46630,
            name: "Robinhood Chain Testnet",
            shortName: "Robinhood Chain Testnet",
            networkType: "testnet",
            nativeCurrency: {
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            },
            explorerUrl: "https://explorer.testnet.chain.robinhood.com",
            rpcUrls: [
                "https://rpc.testnet.chain.robinhood.com"
            ],
            faucetUrl: null,
            root: false,
            enabled: false,
            testingEnabled: false,
            publishingEnabled: false,
            deployment: null
        })
    });

    const POLICY = deepFreeze({
        nativeDeploymentsOnly: true,
        bridgeHellboxNfts: false,
        conceptualPublicationIdentity: "publicationKey",
        onchainAssetIdentity: [
            "chainId",
            "contractAddress",
            "tokenId"
        ]
    });

    function getChainByKey(key) {
        if (typeof key !== "string") {
            return null;
        }

        return CHAINS[key] || null;
    }

    function getChainById(chainId) {
        const numeric = Number(chainId);

        if (!Number.isSafeInteger(numeric)) {
            return null;
        }

        return Object.values(CHAINS).find((chain) => {
            return chain.chainId === numeric;
        }) || null;
    }

    function getDefaultChain() {
        return CHAINS[DEFAULT_CHAIN_KEY];
    }

    function getDevelopmentChain() {
        return CHAINS[DEVELOPMENT_CHAIN_KEY];
    }

    function listChains(options = {}) {
        const {
            includeDisabled = true,
            includeTestnets = true
        } = options;

        return Object.values(CHAINS).filter((chain) => {
            if (!includeDisabled && !chain.enabled) {
                return false;
            }

            if (!includeTestnets && chain.networkType === "testnet") {
                return false;
            }

            return true;
        });
    }

    function hasDeployment(chainOrKey) {
        const chain = typeof chainOrKey === "string"
            ? getChainByKey(chainOrKey)
            : chainOrKey;

        return Boolean(
            chain &&
            chain.deployment &&
            chain.deployment.contractAddress
        );
    }

    function canPublish(chainOrKey) {
        const chain = typeof chainOrKey === "string"
            ? getChainByKey(chainOrKey)
            : chainOrKey;

        return Boolean(
            chain &&
            chain.publishingEnabled &&
            hasDeployment(chain)
        );
    }

    function getWalletAddParams(chainOrKey) {
        const chain = typeof chainOrKey === "string"
            ? getChainByKey(chainOrKey)
            : chainOrKey;

        if (!chain || !Array.isArray(chain.rpcUrls) || chain.rpcUrls.length === 0) {
            return null;
        }

        const params = {
            chainId: chain.chainIdHex,
            chainName: chain.name,
            nativeCurrency: {
                name: chain.nativeCurrency.name,
                symbol: chain.nativeCurrency.symbol,
                decimals: chain.nativeCurrency.decimals
            },
            rpcUrls: [...chain.rpcUrls]
        };

        if (chain.explorerUrl) {
            params.blockExplorerUrls = [chain.explorerUrl];
        }

        return params;
    }

    window.HellboxChains = deepFreeze({
        REGISTRY_VERSION,
        DEFAULT_CHAIN_KEY,
        DEVELOPMENT_CHAIN_KEY,
        POLICY,
        CHAINS,
        getChainByKey,
        getChainById,
        getDefaultChain,
        getDevelopmentChain,
        listChains,
        hasDeployment,
        canPublish,
        getWalletAddParams
    });
})();
