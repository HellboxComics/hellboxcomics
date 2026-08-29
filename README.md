

# Gate 0.2 — Globalization + Multi-Chain Foundation

The current public checkpoint is **Gate 0.2**.

## New runtime files

- `gate02.css` — stabilized laptop/mobile interaction layer.
- `gate02.js` — complete-site localization, active-chain presentation, and
  floating-UI coordination.
- `config/chains.js` — public-safe EVM chain registry.
- `src/config/chains.js` — Worker-side chain registry.
- `locales/` — complete public locale packs and planned-locale manifest.
- `docs/GLOBALIZATION_AND_MULTICHAIN_STANDARD.md` — architecture rules.

## Current public languages

- English
- Spanish
- Brazilian Portuguese

A language must not be added to the public selector until its entire site pack,
Harrow voice adaptation, errors, accessibility text, and metadata are complete.

The website language does not translate a publication. Publication language is
declared by the publication package.

## Current chain state

PulseChain is the root and only enabled public deployment.

Other EVM entries are present but disabled until HellboxNFT is deployed natively
and the deployment is enabled. Hellbox NFTs are never bridged.

Public chain metadata:

`GET /api/chains`

## Deployment

Replace the entire repository checkpoint and commit to `main`.

Do not merge individual Gate 0.1 and Gate 0.2 files. Gate 0.2 loads its chain
registry before `app.js`, then loads `gate02.js` after the main application.
