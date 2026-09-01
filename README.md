# Hellbox Comics

**Hellbox Comics is an underground digital publishing house operated by Harrow.**

Product priority:

1. comics
2. collecting
3. ownership
4. interaction
5. blockchain

> **The machinery is disciplined. The operator is not.**

## Start here

Before changing this repository, read in this exact order:

1. `HELLBOX_PROJECT_STATE.md` — authoritative technical/product/handoff state.
2. `HARROW_CHARACTER_BIBLE.md` — Harrow autobiography, voice, visual and creative canon.
3. `README.md` — concise repository orientation.
4. `CURRENT_GATE_BLUEPRINT.md` — complete detailed architecture for the Gate currently being implemented.
5. only then inspect the implementation files relevant to the immediate frontier.

Do not reconstruct Hellbox architecture from old chat history.

If README conflicts with Project State, Project State wins.

If a current-Gate progress sentence lags behind verified committed source/tests/terminal or Testnet evidence, preserve the verified implementation and synchronize the documentation rather than rolling working code backward.

## Authoritative root documentation

Keep only four authoritative Markdown files at repository root:

```text
HELLBOX_PROJECT_STATE.md
HARROW_CHARACTER_BIBLE.md
README.md
CURRENT_GATE_BLUEPRINT.md
```

Completed Gate blueprints are archived below root under:

```text
docs/architecture/gates/
```

A completed Gate's detailed architecture must be archived before `CURRENT_GATE_BLUEPRINT.md` is repurposed for the next Gate.

## Current checkpoint

- Gate 0 — COMPLETE
- Gate 1 — COMPLETE
- Gate 2 — COMPLETE
- Gate 3 — COMPLETE
- **Gate 4 — IN PROGRESS**
- Mainnet — NOT part of Gate 4

Current verified Gate 4 implementation:

- Foundry configured
- Foundry `1.8.1` verified in creator terminal output
- Solidity `0.8.36`
- EVM `shanghai`
- OpenZeppelin Contracts `v5.1.0` pinned
- `HellboxPublication.sol` V1 kernel implemented
- JavaScript/Solidity `HELLBOX_ABI_V1` golden vector implemented and unchanged by trait enforcement
- deterministic issuance accounting core implemented
- deployment-time enforcement-preimage digest anchors implemented without changing the frozen `HELLBOX_ABI_V1` release fingerprint
- `HellboxPublicationFactory.sol` V1 implemented with size-safe full deployment
- factory provenance/uniqueness + approved creation-code-hash controls implemented
- `HellboxBirthPolicy.sol` non-upgradeable per-publication companion implemented and independently tested
- `HellboxBirthPolicyCodeStore.sol` immutable inert bytecode store implemented and independently tested
- factory generation permanently binds the approved BirthPolicy code store and exact BirthPolicy creation-code hash
- every publication copies/verifies the approved policy bytes and creates its own permanently bound BirthPolicy atomically during deployment
- malformed stores, wrong hashes and invalid policy preimages fail the whole publication deployment instead of registering a bad release
- direct publication-constructor `new HellboxBirthPolicy(...)` topology remains rejected; production source contains no direct BirthPolicy creation-code embed
- the internal immediate creator, normal non-tail and Final-3 issuance paths now assign and consume one immutable per-token MARK/DEFECT identity atomically; no collector-facing mint endpoint exists yet
- only the permanently bound publication can call BirthPolicy assignment; no publisher/admin setter or reroll exists
- Harrow #001–#006 fixed MARKS, shared-random creator DEFECTS and #066 HELLBOUND/public-candidate behavior are enforced and tested
- enabled-axis trait inventory remains synchronized with pending immediate copies + actual candidate pool; failed assignment reverts issuance/accounting together
- current post-push regression: **85 Solidity tests passed / 0 failed**
- issuance fuzz boundary: **256 runs passed**
- focused suites:
  - factory/provenance/atomic deployment: **21 / 21**
  - BirthPolicy: **21 / 21**
  - issuance/atomic traits: **13 / 13**
  - code store: **4 / 4**
- unoptimized Shanghai runtimes:
  - `HellboxPublication`: **16,411 bytes** / **8,165 bytes EIP-170 headroom**
  - `HellboxPublicationFactory`: **9,423 bytes** / **15,153 bytes EIP-170 headroom**
  - `HellboxBirthPolicy`: **9,123 bytes** / **15,453 bytes EIP-170 headroom**
  - `HellboxBirthPolicyCodeStore`: actual deployed inert runtime **20,609 bytes** / **3,967 bytes EIP-170 headroom** (`forge build --sizes` nominal runtime stub: **62 bytes**)
- BirthPolicy initcode: **20,608 bytes** / **28,544 bytes EIP-3860 headroom**
- code-store creation size: **20,871 bytes** / **28,281 bytes EIP-3860 headroom**
- measured native publication deployment payload: **31,665 bytes** / **17,487 bytes EIP-3860 headroom**

**Exact next frontier:** complete the production-randomness/native-timed-closure architecture checkpoint before exposing collector minting. Select and prove the entropy request/fulfillment/fallback model for normal candidate assignment and unbiased native-expiry Final-3 selection; then implement phase eligibility, V1 `FREE`/`FIXED_PLS` payment enforcement and the public collector mint path one file at a time.

The interactive-comic, Archive/reward, future independent-creator Press and future-token directions do **not** widen this immediate Gate 4 randomness/payment/phase/closure frontier and do not require a `HELLBOX_ABI_V1` change.

## Gate 4 issuance invariant

For the standard native 216-copy profile, after Harrow's immediate #001–#006:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

Those values are intentionally different.

The final Harrow three are not preselected or removed from the 210-candidate pool. They are the literal final three candidates left after all 207 allowed non-tail primary issuances.

Therefore the initial next-pull odds denominator is **210**, not 207.

## Current architecture

```text
First outside visit
    ↓
THE 30-MACHINE PROBLEM
Byte #6 → ... → Byte #333
    ↓
/campaign-complete
    ↓
current Hellbox public experience

Browser
    ├── static site / Press / Reader
    └── /api/*
          ↓
Cloudflare Worker — src/index.js
    ├── D1: hellbox-production
    ├── EVM RPC ownership checks
    ├── R2: hellbox-public
    └── R2: hellbox-private
```

On-chain publication model currently committed:

```text
reviewed HellboxPublication V1 creation bytecode
    ↓ exact hash approved per factory generation
HellboxPublicationFactory V1
    ↓ ordinary CREATE / full deployment
fresh HellboxPublication V1 per release
```

The reusable `HellboxBirthPolicy` companion and immutable `HellboxBirthPolicyCodeStore` are now fully wired into publication deployment.

Current proven topology:

```text
approved HellboxBirthPolicyCodeStore
    ↓ exact policy bytes

HellboxPublicationFactory V1
    ↓ freezes approved store/hash per factory generation
    ↓ ordinary CREATE / full deployment

HellboxPublication V1
    ↓ verifies exact approved policy bytes
    ↓ creates one BirthPolicy during publication deployment

HellboxBirthPolicy companion
    publication = actual HellboxPublication
```

If the store, approved hash or policy inputs are wrong, publication deployment fails atomically and the factory does not register the broken release.

The rejected direct-embed approach would have left only about **1.5 KB** of practical deployment room. The proven code-store path measures **31,665 bytes** for the native publication deployment payload, leaving **17,487 bytes** of EIP-3860 headroom. Do not resurrect the embedded approach or add a setter/proxy/initializer/upgrade escape hatch.

One publication/release = one native ERC-721 collection.

V1 is not a clone/proxy/upgrade model, and does not use CREATE2.

Never bridge Hellbox NFTs.

## Current native issue model

Standard native baseline:

- max supply: `216`
- tokenId = collector-facing copy number
- public/non-tail issuance randomized and non-sequential
- primary lifetime wallet cap: `6`
- max per transaction: `1`
- batch mint: false
- V1 primary payment: **PLS only**
- per-issue PLS mint price: frozen at PUBLISH and allowed to differ by issue
- native primary mint window: exactly **66 days + 6 hours + 6 minutes + 6 seconds** from that issue's frozen go-live time
- sellout may finish sooner; the published deadline cannot be extended or reopened

PRESS MARK:

- HELLBOUND `6`
- PRESS PROOF `12`
- GOLD `18`
- STANDARD `180`

PRESS DEFECT:

- REDACTED `6`
- CORRUPTED PLATE `12`
- BLED OUT `18`
- OFF REGISTER `24`
- NONE `156`

Harrow immediate copies:

- #001/#002 HELLBOUND
- #003/#004 PRESS PROOF
- #005/#006 GOLD

Harrow's DEFECTS remain random.

#066 is a public HELLBOUND and remains in the random candidate pool.

Harrow's Final 3 are never preselected by token ID and Harrow cannot choose them.

- if all allowed non-tail issuances finish before the native deadline, the literal final three candidates go to Harrow at true mint-out;
- if the native deadline arrives first while more than three candidates remain, exactly three remaining candidates must go to Harrow through the final approved unbiased closure mechanism;
- every other still-unminted candidate is permanently extinguished and can never be reopened or minted later;
- #066, if still present at expiry, participates under the same unbiased remaining-candidate rule.

## SciVive

`publicationKey: scivive`

- ERC-721
- max supply `5,555`
- free mint
- max 1 primary copy/wallet
- max 1/tx
- royalty 369 bps
- explicitly exempt from the native `66d 6h 6m 6s` mint-window rule
- protected 461-page Reader
- still private/not publicly mintable
- Gate 4 will use it to prove real Testnet mint → ownership → Archive/library → Reader

SciVive is intentionally narrower than Native Issue #1 and is not required to use the native interactive-comic structure.

## Native owner experience direction

A native Hellbox comic is intended to be more than a linear digital page reader.

The private owner experience is a **finite, Harrow-authored interactive narrative graph**:

```text
comic stage/page
    ↓
final frame becomes an escape-room entrance
    ↓
escape / timed survival
    ↓
authored decision or consequence
    ↓
next pre-authored stage
```

Locked principles:

- all canonical pages, stage variants, rooms, branches and endings are authored before PUBLISH;
- AI may assist Harrow during production, testing and asset creation, but canonical story content is **not generated live by AI for the reader**;
- early rooms teach the interaction language and difficulty rises toward the end;
- community collaboration around difficult rooms is intentional;
- progress saves between visits and meaningful progression must ultimately be server-authoritative;
- story choices create legitimate surviving branches, not merely disguised right/wrong buttons;
- every interactive issue has one intended/ideal surviving ending and at least one authored alternate surviving ending;
- authored deaths may result from consequential choices and/or failure to complete a timed room;
- branches should reconverge where practical so one creator can author and validate the issue without exponential content growth;
- MARK/DEFECT can create trait-specific interactions, rooms, presentation and Harrow dialogue;
- HELLBOUND should have genuine HELLBOUND-specific experiences;
- ordinary/common copies must still be able to complete the core story and reach the ideal ending;
- rarity changes the experience without becoming pay-to-win access to the core story.

Birth rarity and experience history are different systems. MARK/DEFECT are permanent birth traits and do not change because a reader dies, escapes, earns an achievement, burns something or participates in rewards.

## Archive / reward direction

Archive is the digital preservation state: the sealed collectible is metaphorically protected under plastic/slab rather than handled.

Current doctrine:

- Archive is available only while the artifact remains SEALED;
- archived copies cannot enter/play the interactive Reader;
- archived copies cannot acquire handling-derived experience marks while archived;
- **only archived copies earn ordinary official Archive rewards** under the current model;
- official Archive earning is intended to be **rarity-weighted** from immutable MARK/DEFECT;
- exact MARK/DEFECT weights, combination formula, emissions, reward asset and payout rules are **not locked yet**;
- unarchive stops new accrual but the artifact may rearchive while still SEALED;
- UNSEAL is irreversible and ends ordinary Archive eligibility under the current model.

Harrow's immediate creator copies **#001–#006 earn zero official Archive rewards for six years after mint**. If archived during that period, their effective official reward weight is `0`.

Future burn/consume mechanics may affect earning or effective reward power, but burn economics remain deliberately open and may never rewrite MARK/DEFECT birth rarity.

## Gate 4 V1 pricing / revenue boundary

V1 pricing scope is intentionally narrow:

- `FREE` for SciVive/proving releases explicitly configured free;
- `FIXED_PLS` for native Hellbox issues;
- no V1 stablecoin mint route;
- no V1 USD-target pricing;
- no V1 PLS/USD oracle, adapter or conversion path.

Frozen per issue at PUBLISH:

- accepted primary payment asset;
- primary mint price;
- headline ERC-2981 royalty rate/BPS;
- native go-live/deadline where applicable;
- supply/copy/rarity promises.

Operationally mutable downstream of receipt:

- mint-proceeds destinations/splits;
- royalty-proceeds destinations/splits;
- reward-pool routing;
- future reward-token identity/address/tokenomics;
- buy/burn/reward strategy;
- project-funding allocation.

The publication should point at durable Hellbox routing endpoints rather than hard-code today's final downstream wallets/splits into every issue.

Current operating concept — **not protocol-locked**:

```text
ROYALTIES
1/3 → Feed Harrow and future plans
1/3 → holder reward pool in native token
1/3 → buy/burn future reward-token mechanism

MINT PROCEEDS
1/3 → Feed Harrow and future plans
2/3 → buy future Hellbox reward token
      ├─ 1/2 → holder reward pool
      └─ 1/2 → burn
```

No reward-token name, address, supply, emissions, formula, distribution or tokenomics is locked by Gate 4.

## PLS settlement / accounting boundary

Hellbox-native paid releases are customer-facing **PLS transactions**, not USD checkout:

- `FIXED_PLS` freezes the collector-facing PLS amount at PUBLISH;
- PLS volatility does not let the Press rewrite a published issue price;
- no PLS/USD oracle is required inside the publication contract merely for checkout;
- back-office records still preserve the transaction hash, PLS amount, time and transaction-time fiat fair-market value when required for accounting/tax reporting.

The customer experience can remain entirely PLS-denominated while the accounting machine quietly produces the records needed behind the scenes.

## Future independent-creator Press lane

After Hellbox's own publishing machine is mature, the Press may open a separate launch lane for outside creators:

- outside creators can publish their own independent comics/ebooks or conforming interactive packages through supported Press/Reader standards;
- their titles are **not Hellbox-native**, do not receive a Hellbox title stamp/canon/native reward status, and do not imply Harrow created the work;
- creators remain responsible for canonical asset hosting through their own Cloudflare/IPFS/Arweave/other supported storage;
- Hellbox may validate package URIs/hashes and provide Reader compatibility, but does not become the permanent canonical host for outsider assets by default;
- outsiders receive public packaging/deployment specifications, not Harrow's private comic-generation/authoring machinery;
- exact launch prerequisites, fees, primary-mint percentages, royalty participation or subscriptions remain **OPEN**;
- any Harrow-flavored creator standing/reputation belongs at the website/account layer, not inside immutable publication authenticity.

This is a later Press/Reader lane. It does **not** open the Hellbox-native V1 factory to arbitrary outside publishing.

## Future token separation

Harrow's product identity is comics, collectibles and Press infrastructure — not “crypto founder.”

For any future token Hellbox chooses to endorse/use:

- an official Hellbox project wallet does **not** deploy the token;
- Hellbox does **not** hold token admin keys or control permanently locked liquidity;
- a launch may originate from an unattributed/anonymous wallet, but anonymous is not automatically the same thing as independent/unaffiliated;
- an official Hellbox wallet may later buy an already-public token through ordinary market transactions before or after endorsement;
- public statements must describe actual control, holdings, compensation and relationships truthfully;
- Hellbox makes no promise of price support, appreciation, liquidity maintenance or profit from Harrow/Hellbox efforts;
- token address, launch wallet, supply, distribution, reward formula and buy/burn economics remain outside Gate 4 and are not hard-coded into the publication kernel.

## Reader / ownership

Gate 3 production authority:

- wallet identity: D1-backed challenge/signature/session
- ownership: publication contract `balanceOf(wallet)`
- D1 ownership rows: bounded evidence/cache only
- Archive and Reader share one Worker ownership verifier
- localStorage/frontend flags cannot grant ownership

Normal public SciVive Reader remains protected.

## Public development routing

Outside first visit:

```text
hellboxcomics.com → Byte #6
```

Completion:

```text
Byte #333 → /campaign-complete → current Hellbox
```

Replay:

```text
/campaign-reset → Byte #6
```

Harrow private access:

```text
/__harrow
```

Campaign completion never grants wallet, Reader, ownership or Harrow-private authority.

## HairyLabs testing exclusion

Until the creator explicitly confirms the Byte lane is refreshed, do not use Byte pages in acceptance/regression.

Known externally stale pages when last checked:

```text
#6 #11 #13 #19 #20 #23 #104 #223 #333
```

Pulse Byte / `$SPUNK` world note, exact mechanics excluded from Gate 4 issuance:

- real Pulse Bytes can replenish/reload RPC allowance through `$SPUNK`;
- `$SPUNK` burns in that loop;
- Hellbox may use the hungry-Byte/feeding-infrastructure joke;
- exact amounts, thresholds, formulas and deeper Hellbox integration timing remain outside this Gate unless explicitly resolved from authoritative Byte rules.

## Important repository paths

```text
contracts/                         Gate 4 Solidity
test/                              Foundry tests
script/                            deployment scripts
lib/                               pinned Solidity dependencies
src/press/releaseFingerprint.js    Press-side HELLBOX_ABI_V1 encoder
src/index.js                       Cloudflare Worker
index.html                         application shell
prelaunch.html                     sealed public surface
app.js                             browser runtime
style.css / gate02.css             visual system
migrations/                        production D1 schema
publications/scivive/              SciVive package
schemas/                           package schemas
locales/                           UI locale packs
tools/                             Reader/auth/build tests
docs/architecture/gates/           archived finalized Gate blueprints
HELLBOX_PROJECT_STATE.md           authoritative project state
HARROW_CHARACTER_BIBLE.md          authoritative Harrow canon
README.md                          concise orientation
CURRENT_GATE_BLUEPRINT.md          active detailed Gate architecture
```

## Development / solo-operator workflow

Hellbox must remain safely operable by one non-developer creator with a demanding primary career and fragmented availability.

Core rules:

- one implementation/config file at a time; no general multi-file code batching
- complete replacement files, never splice patches
- direct file + ZIP downloaded into `~/Downloads`
- hash-verified Bash places the file in its exact repo path; no manual file placement
- exactly one Bash command/block per turn, then inspect its complete output before the next command
- verify source/target/package hashes before replacement
- validate every backend/contract/content change before moving on
- verify focused/full tests, production sizes, deployments/live behavior and Git state as applicable
- routine engineering decisions belong to the engineer/AI assistant
- open technical decisions are researched/tested by the engineer
- creator approval is reserved for product/economic/scarcity/authority/immutability/canon decisions
- before each major implementation file, perform the internal checkpoint defined in `HELLBOX_PROJECT_STATE.md`
- documentation is independently rebuilt in dependency/authority order; only the final reviewed install/checkpoint may be bundled
- documentation installation batching is not permission to batch review or code engineering
- documentation contradiction sweeps are mandatory before synchronization is declared complete
- repeated manual operations must become scripts, validators, generated interfaces or executable runbooks
- no critical workflow may exist only in chat history, Terminal scrollback or Harrow's memory
- after interruption/new session, prove actual Git/hash/test state rather than assuming the previous command finished
- unexpected hashes, files, failing tests or unclear authority boundaries are stop-the-line conditions
- the public prelaunch progress percentage represents **overall Hellbox completeness**, not current-Gate completion; formally review/recalculate it at each Gate close

AI is expected to reduce workload through engineering, testing, narrative planning, puzzle design, asset production, validation and documentation. AI output receives the same tests/review as human output.

AI may **not** autonomously publish irreversible releases, sign mainnet/treasury transactions, receive signing secrets, change frozen product promises, or substitute plausible-looking output for repository/test evidence.

The finished production machine should be pre-engineered enough that Harrow can safely operate reviewed workflows in short, interrupted sessions without reproducing developer-only reasoning.

## Gate 4 security / economics

- minimize custom Solidity
- use pinned audited OpenZeppelin primitives for solved standards
- no publication or birth-policy proxy/upgrades in V1
- no generic publication owner
- `HellboxBirthPolicy` has one narrow publication-only birth-assignment endpoint and no publisher/admin setter, reroll or replacement surface
- `HellboxBirthPolicyCodeStore` is inert immutable infrastructure, not an admin/economic control surface
- no collector-token seizure/forced transfer
- no per-publication custom-Solidity/audit treadmill
- security cost is amortized across reusable reviewed versions/modules
- V1 collector economics freeze the issue's payment asset, mint price and royalty rate; downstream routing/splits remain operational
- do not hard-code an unlaunched reward token, Archive-weight formula, burn modifier or today's downstream revenue split into the publication kernel
- ERC-2981 royalty information does not guarantee marketplace enforcement or revenue
- production randomness/failure policy must be manipulation-resistant before valuable rarity/timed-Final-3 behavior reaches mainnet
- ownership-critical and mint-critical operation must not ultimately depend on one unmonitored RPC/provider
- when authoritative truth is unavailable, unsafe writes fail closed rather than guessing

Hellbox must remain worth owning if:
- a future reward token never launches or has little value;
- secondary royalties are zero;
- secondary-market liquidity is poor;
- Archive rewards are reduced or paused.

Strong pre-mainnet durability requirement:

> **dynamic when alive; durable when dead**

Before Native Issue #1 mainnet release, documented backups and a successful clean-room recovery drill must prove that the platform/publication/Reader state can be recovered without relying on one workstation, one chat or Harrow's memory.

## Risk controls

The detailed risk register lives in `HELLBOX_PROJECT_STATE.md`. The highest-priority controls are:

- **scope:** interactive issues use finite scope budgets, branch reconvergence, reusable room/trait components and a vertical slice before full production;
- **solo operation:** recurring work becomes automation/runbooks and normal production cannot require daily Harrow intervention;
- **content workload:** Gate 6 must produce a reusable narrative/package compiler with automated reachability, asset, trait-combination and ending validation;
- **puzzle quality:** progressive difficulty, human playtesting, accessibility and fair timer/start/outage behavior are hard release requirements;
- **immutable code:** unit/revert/fuzz/invariant/adversarial/static/Testnet evidence plus focused external review before mainnet;
- **randomness:** never silently fall back to manipulable entropy; pause safely instead;
- **economics:** rewards remain modular and cannot become a prerequisite for the comic/artifact to have value;
- **infrastructure:** backups, low-noise monitoring, provider failover and clean-room restoration are required before first native mainnet release;
- **handoff:** repository evidence must let a different AI/developer resume without oral reconstruction.

## Security / privacy

Public Git identity:

```text
Harrow <noreply@hellboxcomics.com>
```

Never commit:

- creator personal/legal identity
- personal email/local hostname
- private keys/seed phrases
- Cloudflare/API secrets
- private Reader binaries
- temporary credentials
- unsanitized terminal output

Do not resurrect old pre-privacy repository history.

## Roadmap

- Gate 4 — artifact kernel/factory/issuance/Testnet ownership proof
- Gate 5 — Press V2 + private release builder + real mint UX
- Gate 6 — deterministic ingest/art/metadata + interactive narrative/package compiler
- Gate 7 — Seal/Archive + rarity-weighted rewards + ERC-6551 + artifact history + Hellforge/evolution
- Gate 8 — Hellion relationship depth
- Gate 9 — freeze/security/accessibility/localization/content/performance/operations/recovery hardening
- Gate 10 — deterministic mainnet release candidate + first native issue

Native Issue #1 does not launch until the promised foundational artifact model is proven **and** its interactive narrative package, path coverage, human playtesting, performance/accessibility, operational runbooks and clean-room recovery barrier pass.

For full detail, read `HELLBOX_PROJECT_STATE.md`, then `CURRENT_GATE_BLUEPRINT.md`.
