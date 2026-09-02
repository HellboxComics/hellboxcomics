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

Latest source/test implementation baseline before this documentation-only synchronization:

```text
9a153dd6fef4f275476f74c9254d2f3beb90007e
```

Committed/pushed Gate 4 state:

- Solidity `0.8.36`, EVM `shanghai`;
- optimizer enabled, 200 runs, `via_ir = false`;
- OpenZeppelin Contracts `v5.1.0` pinned;
- full-deployment `HellboxPublication V1` + `HELLBOX_ABI_V1` golden vector;
- size-safe factory provenance and immutable BirthPolicy code-store/deployment graph;
- permanent one-time MARK/DEFECT assignment/inventory enforcement;
- frozen drand `evmnet` verifier, one immutable verifier per factory generation, and publication-side verifier binding;
- append-only future-round requests, exact FIFO permissionless proof fulfillment, and internal one-time Prize Wallet same-pool issuance;
- permanent eight-test Prize Wallet FIFO regression;
- committed self-authorized EOA campaign registry with official-publication approval, reserve→complete deposit accounting, pending-deposit claim blocking, direct winner-wallet claim, no-reuse and rotation boundaries;
- permanent 15-test Prize Wallet registry/progressive-jackpot regression;
- **120 committed Solidity tests**.

Exact committed registry identities:

```text
factory commit: 7208590223107257c92524095a951e162b3c7349
factory: 1178 lines
sha256: 885d81b731aa28bb9a1f27de714d7d16e16d9c5a7e73fd75bbba9620c1d4a90d

registry-test latest commit: 9a153dd6fef4f275476f74c9254d2f3beb90007e
registry-test initial commit: c91763768c54130991f9b83df9a54971ed021bd6
registry test: 986 lines
sha256: 5b1300174947af2307fcd522613804ca3c96d8e978d4cb7f40d8a9cbfa75ba16
```

Creator terminal evidence for those exact bytes:

- **15/15** focused registry tests passed;
- **120/120** total tests passed, 0 failed, 0 skipped;
- issuance fuzz boundary **256 runs**;
- optimized runtimes: publication **14,818 bytes**, factory **12,424 bytes**, verifier **5,138 bytes**;
- factory initcode with arguments **19,742 bytes**, leaving **29,410 bytes** EIP-3860 headroom;
- worktree and index clean after the progressive-regression commit.

The three progressive-jackpot regressions are now committed and prove multi-publication accumulation, generation-isolated approvals and owner-only approval management. Production publication↔registry integration is still open.

**Exact next frontier:** wire production publication reserve→FIFO request→fulfillment→deposit completion through the real creator-initialization path; then implement native timed closure. Phase/payment/public mint and immutable renderer/`tokenURI` work remain closed until those pass.

The interactive comic, Prize Wallet campaign, Continuity Covenant, Archive/reward, outside-creator Press and future-token directions do **not** authorize a `HELLBOX_ABI_V1` change or early collector mint.

## Gate 4 issuance invariant

For the standard native 216-copy profile, after Harrow's immediate #001–#006:

```text
candidatePoolRemaining   = 210
nonTailIssuanceRemaining = 207
```

Those values are intentionally different.

The final Harrow three are not preselected or removed from the 210-candidate pool. They are the literal final three candidates left after all 207 allowed non-tail primary issuances.

The seventh successful mint event is the one-time Prize Wallet draw for that publication. It sees all **210** candidates and is **not guaranteed to mint token/copy #007**. After it succeeds:

```text
candidatePoolRemaining   = 209
nonTailIssuanceRemaining = 206
```

The first ordinary collector draw uses the live 209-candidate pool and authoritative remaining trait inventory.

## Progressive Prize Wallet campaign

- one fresh ordinary EOA is generated offline from a **12-word MetaMask-compatible Secret Recovery Phrase**;
- the EOA self-authorizes its factory generation with EIP-712;
- Harrow receives only public activation/package artifacts—never the phrase, private key, final unlock key or answer sheet;
- the same campaign wallet remains active across any number of issue releases;
- each approved publication contributes exactly one random seventh-mint comic;
- the puzzle is a separate persistent Byte-site Hellbox introduction, not an escape room inside each comic;
- the jackpot display grows from completed approved-publication deposit events without changing the puzzle package;
- the solver decrypts all 12 words locally, restores the EOA and calls `confirmPrizeWalletClaim()`;
- the old EOA is never reset/reused, and a fresh campaign can begin only after claim and zero pending deposits;
- unsolicited transfers are not official prizes unless covered by an append-only official campaign disclosure.

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

The rejected direct-embed approach left only about **1.5 KB** of practical room in the pre-optimizer experiment. The code-store path was proven with a **31,665-byte** pre-optimizer native publication payload and **17,487 bytes** of headroom; remeasure after production registry wiring. Do not resurrect the embedded approach or add a setter/proxy/initializer/upgrade escape hatch.

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
- paid-phase default: **native PLS**, with a pre-PUBLISH option for one standards-compatible same-chain ERC-20/PRC-20 per phase
- allowlist/early/public/partner phases may intentionally use different free/paid policies; each selected asset and exact raw-unit amount freezes at PUBLISH
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

Repeating promotional Prize Wallet:

- after Harrow's six, the **seventh successful mint event** is the first non-tail issuance and goes to the active approved campaign EOA;
- it draws blindly from the same 210 candidates, may draw #066 and receives no guaranteed copy ID, MARK or DEFECT;
- it consumes one non-tail slot, leaving 209 candidates / 206 non-tail issuances before ordinary phases;
- the same EOA accumulates one random comic from each approved issue until the separate Byte-site puzzle is solved;
- Harrow cannot preview, choose, reroll, withdraw, claim, reset the campaign or receive the phrase/private key/unlock key;
- pending publication deposits block winner confirmation and campaign rotation;
- optional promotional assets are never guaranteed, require official disclosure and do not come from Archive rewards;
- while unclaimed, prize copies have effective official Archive reward weight `0`;
- after direct winner-wallet confirmation, the old EOA remains winner-owned and a completely fresh campaign may be activated.

The locked low-cost model is a network-disabled Prize Capsule Builder plus a fresh 12-word MetaMask-compatible EOA—not a smart-contract vault. AI/Harrow design the maze with dummy placeholders; local final assembly encrypts the complete phrase and inserts secret-bearing clues without giving Harrow an answer sheet. Completed approved-publication events define official comic deposits; unsolicited transfers do not.

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

V1 pricing is configurable in the private Press before `PUBLISH`, then immutable. Each enabled collector phase may be `FREE`, `FIXED_NATIVE` or `FIXED_ERC20`. No phase may be repriced after deployment, including one that has not started.

- `FREE` — no payment;
- `FIXED_NATIVE` — exact native amount; on PulseChain this is PLS;
- `FIXED_ERC20` — exact amount in one selected standards-compatible same-chain ERC-20/PRC-20.

PLS is the standard paid preset, not a mandatory asset. `$6.66` is not a contract constant, required price, floor, ceiling or permanent default.

Allowlist/whitelist, reserved/partner, early-Press and public-Press phases may each be free or use different frozen prices/payment assets. A V1 phase has one deterministic payment choice; simultaneous choose-your-token checkout and live oracle conversion remain outside V1.

Frozen per phase/issue at PUBLISH:

- pricing mode;
- accepted payment asset/contract;
- exact raw-unit amount;
- phase-to-pricing/route assignment;
- headline ERC-2981 royalty rate/BPS;
- native go-live/deadline where applicable;
- supply/copy/rarity promises.

Settlement safeguards:

- free phases reject native value and perform no token transfer;
- native phases require exact `msg.value` and revert on under/overpayment;
- ERC-20 phases require zero native value and an exact safe token transfer;
- token failure or short receipt reverts the mint atomically;
- fee-on-transfer, rebasing, callback-dependent and materially nonstandard tokens are rejected by the V1 validation/enforcement boundary;
- token symbol/decimals are display metadata; chain ID, contract address and raw amount are authoritative.

Operationally mutable downstream of receipt:

- mint-proceeds destinations/splits;
- royalty-proceeds destinations/splits;
- reward-pool routing;
- future reward-token identity/address/tokenomics;
- buy/burn/reward strategy;
- project-funding allocation.

The publication should point at durable Hellbox routing endpoints rather than hard-code today's final downstream wallets/splits into every issue. A routing change may not rewrite a frozen phase asset or price.

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

## PLS default / accounting boundary

Native PLS is the default PulseChain checkout preset, not the only configurable payment asset:

- no PLS/USD oracle is required inside the publication merely to take payment;
- volatility does not permit repricing after `PUBLISH`;
- the private Press may show a fiat estimate while drafting, but the contract freezes exact on-chain units;
- back-office records preserve transaction hash, phase, asset address, exact amount, time and transaction-time fiat fair-market value when required for accounting/tax reporting.

The customer-facing settlement can remain simple while the accounting machine quietly produces the records needed behind the scenes.

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

## Fully on-chain artifact / ownership standard

For every native Hellbox issue, the canonical ERC-721 metadata and evolving cover are intended to be reconstructible from verified chain code, immutable art-data stores and on-chain artifact state alone.

That means:

- no OpenSea, Hellbox API, mutable HTTP URL, DNS name, CDN or IPFS gateway is required to prove what the canonical collectible looks like;
- `tokenURI` must return self-contained metadata for native issues and its standard `image` field must resolve to the self-contained canonical cover;
- the canonical cover is generated by a frozen non-upgradeable renderer from immutable on-chain data and ruled on-chain state;
- renderer/data-store code has no reachable self-destruction, proxy upgrade, replacement or deletion path, and its frozen runtime/data hashes are independently verifiable;
- the canonical cover is the complete approved collectible rendition—not a thumbnail, placeholder or hash-only proxy;
- native rendering follows a frozen layered model: complete plate → immutable MARK → immutable DEFECT → finite artifact-history/context overlays → Archive plastic/slab last;
- vector/SVG art is the affordable preferred path; a raster plate is allowed only when every compressed source byte is stored on-chain, embedded without an external `href`, and passes deployment/RPC/marketplace limits;
- art bytes use a reviewed immutable Hellbox data-store primitive; an unaudited third-party SSTORE2 package is not silently imported merely because the storage pattern is useful;
- optional contextual protocol overlays must fail safely to a deterministic on-chain base cover rather than brick `tokenURI`;
- no scripts, remote media/fonts/stylesheets, event handlers, wallet-supplied markup or unbounded user strings enter canonical SVG;
- time-based wear uses finite frozen milestones with a permissionless checkpoint/event path; Archive freezes handling/raw-age accumulation rather than hiding continuing damage;
- any transfer-derived handling state uses the pinned ERC-721 implementation's single canonical ownership-update hook, so mint/transfer/burn paths cannot bypass or double-count it;
- R2/IPFS/Arweave copies are mirrors and performance/preservation tools, not the sole source of the NFT art;
- no mutable base URI, admin image replacement or renderer upgrade exists after publication;
- metadata changes use frozen rules and ERC-4906-compatible signaling;
- the full interactive Reader package remains a separately protected/content-addressed work with the Publisher Continuity fallback.
- the existing `dynamicMetadataEnabled`, `rendererRulesDigest`, `metadataPolicyDigest`, package/capability/compatibility commitments leave room for this binding without changing `HELLBOX_ABI_V1`; those commitments are not a substitute for implementing and proving the zero-host renderer path.

Ownership claims must remain legally honest. The collector owns the ERC-721, its copy identity and unique artifact state, can transfer it without Hellbox and can reconstruct the canonical cover without a hosting company. Copyright, trademarks and official-canon authority remain governed by the publication's frozen rights statement/license; token ownership does not silently transfer them.

The exact Native Issue #1 commercial-use license remains a creator/legal decision, but **an explicit durable holder license is mandatory before launch**. Its exact text cannot depend only on a mutable website page.

This architecture directly rejects the common “you only own a hosted URL/JPEG” failure mode while avoiding a false claim that every visible copy of the image or the underlying copyright belongs exclusively to the token holder.

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

## HairyLabs testing status

**Resolved 2026-09-01:** the prior Byte-page problem was an indexing issue. Pages `#6 #11 #13 #19 #20 #23 #104 #223 #333` are repaired and the old acceptance/regression exclusion is lifted.

Do not keep reviving or asking about this resolved blanket exclusion. A future incident needs fresh evidence and a newly scoped response.

Pulse Byte / `$SPUNK` world note, exact mechanics excluded from Gate 4 issuance:

- real Pulse Bytes can replenish/reload RPC allowance through `$SPUNK`;
- `$SPUNK` burns in that loop;
- Hellbox may use the hungry-Byte/feeding-infrastructure joke;
- exact amounts, thresholds, formulas and deeper Hellbox integration timing remain outside this Gate unless explicitly resolved from authoritative Byte rules.

## Publisher continuity / 666 Covenant

Hellbox is now formally designed to be **dynamic when alive and durable when dead**.

While active, Harrow keeps exclusive control of official canon, the official Press and unpublished secret sauce. Published artifacts/Reader packages must not die solely because Harrow disappears, a workstation fails, Cloudflare is lost or PulseChain becomes unusable.

Locked inactivity clock:

```text
666 days + 6 hours + 6 minutes + 6 seconds
= 57,564,366 seconds
```

After that period, continuity becomes permissionlessly activatable. A voluntary nuclear path must use repeated warnings and a cancelable public timelock.

Activation may release/mirror infrastructure, published packages and a static Rescue Reader. It does **not** automatically publish unreleased stories, spoilers, personal identity, seed phrases, private legal files or the right to make new official Harrow canon. Without a legal successor, official canon freezes.

A separate Continuity Reserve funds durable storage/recovery; it is not the Archive reward pool and must not depend on speculative DeFi yield. Exact contracts, legal escrow, storage and drill implementation remain later-Gate work, but Native Issue #1 cannot launch until continuity/recovery tests pass.

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
- V1 collector economics freeze each phase's payment mode, asset and exact raw-unit price plus the issue royalty rate; downstream routing/splits remain operational
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
- **Prize Wallet:** fresh offline 12-word EOA, same unbiased draw, persistent cross-release Byte-site campaign, no Harrow phrase/claim/withdraw/reroll power, pending-deposit liveness controls and no reward farming while unclaimed;
- **continuity:** exact heartbeat, Rescue Reader/packages, separate reserve, legal succession and permissionless recovery activation before mainnet;
- **on-chain artifact:** native canonical cover/metadata must pass zero-host chain reconstruction; a digest or IPFS pointer alone is not enough;
- **rights:** holder license must be explicit and durable; do not equate token ownership with copyright ownership;
- **payment assets:** configurable ERC-20/PRC-20 routes must pass standards/exact-balance preflight and freeze per phase at `PUBLISH`;
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
- Gate 5 — Press V2 + private release builder + real mint UX + Prize Wallet campaign/operator controls
- Gate 6 — deterministic ingest + immutable on-chain art-data/metadata renderer + interactive narrative/package compiler + production Prize Capsule/Rescue Reader packaging
- Gate 7 — Seal/Archive + rarity-weighted rewards + ERC-6551 + artifact history + Hellforge/evolution + separate Continuity Reserve hooks
- Gate 8 — Hellion relationship depth
- Gate 9 — freeze/security/accessibility/localization/content/performance/operations/continuity/legal recovery hardening
- Gate 10 — deterministic mainnet release candidate + first native issue

Native Issue #1 does not launch until the promised foundational artifact model is proven **and** its interactive narrative package, path coverage, human playtesting, performance/accessibility, operational runbooks and clean-room recovery barrier pass.

For full detail, read `HELLBOX_PROJECT_STATE.md`, then `CURRENT_GATE_BLUEPRINT.md`.
