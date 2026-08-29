# Hellbox Comics — Globalization and Multi-Chain Standard

## Purpose

Hellbox is PulseChain-rooted, not PulseChain-confined.

PulseChain is the origin of Harrow, the first deployment, and the culture that
made Hellbox necessary. The product itself must remain portable across EVM
networks without forking the website, Reader, Archive, Press, or publication
pipeline.

## Localization policy

The website language and a publication's language are separate.

Changing the Hellbox interface changes:

- navigation;
- section copy;
- wallet and chain states;
- Press states;
- Archive states;
- Reader controls;
- drawers and environmental lore;
- Harrow responses, errors, and interruptions;
- accessibility labels and announcements;
- page and social metadata.

It does **not** silently translate a book. A publication is translated only when
an intentional localized edition exists in its publication package.

English is the canonical source voice for Harrow. Localized Harrow copy must be
adapted for rhythm, insult, implication, and humor rather than translated word
for word.

A language is not shown publicly until its entire site pack is complete.

### Public Gate 0.2 packs

- English (`en`)
- Spanish (`es`)
- Brazilian Portuguese (`pt-BR`)

### Planned research-driven waves

Wave 1:

- Vietnamese (`vi`)
- Indonesian (`id`)

Wave 2:

- Hindi (`hi`)
- Urdu (`ur`, right-to-left)
- Ukrainian (`uk`)
- Turkish (`tr`)

Wave 3:

- Simplified Chinese (`zh-Hans`)
- Korean (`ko`)
- Japanese (`ja`)
- French (`fr`)
- Arabic (`ar`, right-to-left)

The locale manifest is stored at:

`/locales/manifest.json`

## Chain architecture

One public-safe chain registry lives at:

`/config/chains.js`

The Worker registry lives at:

`/src/config/chains.js`

Each entry defines:

- stable chain key;
- numeric and hexadecimal chain ID;
- display names;
- native currency;
- explorer;
- RPC environment keys;
- contract environment key;
- root status;
- enabled status.

The active deployment remains PulseChain until another native HellboxNFT
contract is intentionally deployed and enabled.

## Native deployment rule

Hellbox NFTs are never bridged.

A conceptual publication is recognized across the platform by `publicationKey`.

A specific NFT is always identified by:

`(chainId, contractAddress, tokenId)`

Adding another EVM chain should require:

1. enable or add a registry entry;
2. configure an RPC secret;
3. deploy the same audited HellboxNFT system natively;
4. save the deployment address;
5. enable publishing for that chain in the private Pressroom.

It must not require a new public website, Reader, Archive, or forked frontend.

## Current Gate 0.2 registry

Configured entries:

- PulseChain
- PulseChain Testnet V4
- Ethereum
- Ethereum Sepolia
- Base
- Base Sepolia
- Robinhood Chain

Only PulseChain is enabled by default. A configured chain is not considered
publishing-ready until a native deployment address exists.

## Environment names

Examples:

- `PULSECHAIN_RPC_URL`
- `PULSEBYTE_RPC_URL`
- `PULSECHAIN_V4_RPC_URL`
- `ETHEREUM_RPC_URL`
- `SEPOLIA_RPC_URL`
- `BASE_RPC_URL`
- `BASE_SEPOLIA_RPC_URL`
- `ROBINHOOD_RPC_URL`

Contract deployment examples:

- `HELLBOX_NFT_PULSECHAIN`
- `HELLBOX_NFT_PULSECHAIN_V4`
- `HELLBOX_NFT_ETHEREUM`
- `HELLBOX_NFT_SEPOLIA`
- `HELLBOX_NFT_BASE`
- `HELLBOX_NFT_BASE_SEPOLIA`
- `HELLBOX_NFT_ROBINHOOD`

Disabled chains remain inert even when their metadata exists.
