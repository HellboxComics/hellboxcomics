/**
 * HELLBOX COMICS — PUBLIC EVM CHAIN REGISTRY
 * Gate 0.2
 *
 * PulseChain is the active root deployment. Other EVM networks remain disabled
 * until a native HellboxNFT contract has been deployed and the registry entry
 * has been enabled. Hellbox NFTs are never bridged.
 */
(() => {
    "use strict";

    const CHAINS = Object.freeze({
        pulsechain: Object.freeze({
            key: "pulsechain",
            chainId: 369,
            chainIdHex: "0x171",
            name: "PulseChain",
            shortName: "PulseChain",
            currency: Object.freeze({
                name: "Pulse",
                symbol: "PLS",
                decimals: 18
            }),
            explorerUrl: "https://scan.pulsechain.com",
            rpcUrls: Object.freeze([
                "https://rpc.pulsechain.com"
            ]),
            root: true,
            enabled: true,
            publishingEnabled: true,
            deployment: null
        }),

        pulsechainTestnetV4: Object.freeze({
            key: "pulsechainTestnetV4",
            chainId: 943,
            chainIdHex: "0x3af",
            name: "PulseChain Testnet V4",
            shortName: "PulseChain V4",
            currency: Object.freeze({
                name: "Test Pulse",
                symbol: "tPLS",
                decimals: 18
            }),
            explorerUrl: "https://scan.v4.testnet.pulsechain.com",
            rpcUrls: Object.freeze([
                "https://rpc.v4.testnet.pulsechain.com"
            ]),
            faucetUrl: "https://faucet.v4.testnet.pulsechain.com",
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        ethereum: Object.freeze({
            key: "ethereum",
            chainId: 1,
            chainIdHex: "0x1",
            name: "Ethereum",
            shortName: "Ethereum",
            currency: Object.freeze({
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            }),
            explorerUrl: "https://etherscan.io",
            rpcUrls: Object.freeze([]),
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        sepolia: Object.freeze({
            key: "sepolia",
            chainId: 11155111,
            chainIdHex: "0xaa36a7",
            name: "Ethereum Sepolia",
            shortName: "Sepolia",
            currency: Object.freeze({
                name: "Sepolia Ether",
                symbol: "ETH",
                decimals: 18
            }),
            explorerUrl: "https://sepolia.etherscan.io",
            rpcUrls: Object.freeze([]),
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        base: Object.freeze({
            key: "base",
            chainId: 8453,
            chainIdHex: "0x2105",
            name: "Base",
            shortName: "Base",
            currency: Object.freeze({
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            }),
            explorerUrl: "https://basescan.org",
            rpcUrls: Object.freeze([
                "https://mainnet.base.org"
            ]),
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        baseSepolia: Object.freeze({
            key: "baseSepolia",
            chainId: 84532,
            chainIdHex: "0x14a34",
            name: "Base Sepolia",
            shortName: "Base Sepolia",
            currency: Object.freeze({
                name: "Sepolia Ether",
                symbol: "ETH",
                decimals: 18
            }),
            explorerUrl: "https://sepolia.basescan.org",
            rpcUrls: Object.freeze([
                "https://sepolia.base.org"
            ]),
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        }),

        robinhood: Object.freeze({
            key: "robinhood",
            chainId: 4663,
            chainIdHex: "0x1237",
            name: "Robinhood Chain",
            shortName: "Robinhood",
            currency: Object.freeze({
                name: "Ether",
                symbol: "ETH",
                decimals: 18
            }),
            explorerUrl: null,
            rpcUrls: Object.freeze([]),
            root: false,
            enabled: false,
            publishingEnabled: false,
            deployment: null
        })
    });

    const DEFAULT_CHAIN_KEY = "pulsechain";

    function getChainByKey(key) {
        return CHAINS[key] || CHAINS[DEFAULT_CHAIN_KEY];
    }

    function getChainById(chainId) {
        const numeric = Number(chainId);

        return Object.values(CHAINS).find((chain) => {
            return chain.chainId === numeric;
        }) || null;
    }

    window.HellboxChains = Object.freeze({
        CHAINS,
        DEFAULT_CHAIN_KEY,
        getChainByKey,
        getChainById
    });
})();
