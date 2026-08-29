# HELLBOX PROJECT STATE

Last updated: 2026-08-29
Current production branch: `main`
Current live checkpoint: Gate 1 COMPLETE — publication platform & durable data model
Latest verified production commit: `6f1206d` — `Gate 1: read publications from D1`
Known-good historical commit: `5373ba1460babdd3b1f577dba16137fd83ffa6a1`
Recovery commit on `main`: `2890ab0`
Recovery tree hash: `b19c2df2f533960305cd2aaf65fdd0842ade5e6e`
Broken Gate 0.2 backup branch: `backup-broken-gate02-20260828`

---

## 1. PURPOSE

This is the living handoff document for Hellbox Comics.

Any future ChatGPT thread, Claude session, human developer, or other assistant should read this file before changing the project.

It records:
- current live state
- locked product decisions
- architecture
- known bugs
- workflow rules
- completed work
- deferred work
- exact next step
- files that must not be changed casually

If an old chat conflicts with this file, prefer the most recent explicit decision recorded here or in the current repository.

---

## 2. DEVELOPMENT WORKFLOW — LOCKED

Do not use giant multi-file replacement packages by default.

Work incrementally, one file at a time.

For every code/config change:
1. Explain why that exact file is next.
2. Provide the complete replacement file, never a patch requiring manual splicing.
3. User commits/deploys that one file.
4. Verify the live result and/or backend behavior.
5. Only then move to the next file.

For backend/API work:
- test changed backend behavior immediately
- isolate failures to the specific file/change that caused them
- do not stack unverified backend changes

For static assets/runtime files:
- if CSS/JS URLs are versioned, bump the cache version when the asset changes
- do not assume a deployed file is active until the live page is confirmed to request the new version

Project-state maintenance is checkpoint-based:
- update `HELLBOX_PROJECT_STATE.md` at completion of each established Gate
- update it immediately for major architecture, lore, tokenomics, publication-rule, Harrow-canon, or product-direction changes
- do NOT interrupt implementation to document every minor CSS/file change
- the file must remain comprehensive enough that another competent AI/developer can resume without asking the user dozens of questions

Localization workflow:
- every new user-visible interaction/text added during development gets a canonical English locale key when created
- secondary languages may temporarily fall back to English while English copy is still changing
- after English copy freeze, run a full locale delta and final cross-language QA across every hotspot, button, link, state, drawer, error, announcement, Reader/Press/Archive state, metadata field and accessibility string

Avoid unnecessary repository restructuring.

File handoff rules:
- direct `.js` downloads are unreliable for the user, so deliver JavaScript replacement files inside ZIP archives
- the user normally drops delivered items into the repository root
- when a destination folder does not already exist in the repository root, include the required folder structure inside the ZIP so extracting from the root creates the correct path automatically
- when the destination folder already exists in the repository root, do not recreate/repackage the existing project folder; state the exact target path and let the user place the extracted replacement file there
- always print the complete current terminal/deploy/verification commands in the same response; never tell the user to look back at an earlier message for required steps

Do not modify `src/index.js`, `wrangler.jsonc`, `.assetsignore`, or deployment structure casually.

---

## 3. CURRENT REPOSITORY / DEPLOYMENT STATE

The repository was recovered after a broken all-at-once Gate 0.2 deployment, then Gate 0.2 was rebuilt incrementally and verified.

Current production state:
- branch: `main`
- Cloudflare deployment is live
- Gate 0 foundation is complete
- Gate 1 publication platform/data model is complete
- latest verified production commit: `6f1206d` — `Gate 1: read publications from D1`
- public site works in English and Spanish
- current Gate 0.2 frontend runtime cache generation: `runtime-05`
- current Gate 0.2 layout stylesheet cache generation: `gate0-2-04`
- GA4 is installed with Measurement ID `G-5E9EX1RE0Z`
- GA4 Realtime was verified; Brave Shields can block the user's own Analytics requests
- public/backend multi-chain foundation is live
- production D1 database `hellbox-production` is bound to the Worker as `DB`
- remote D1 migrations `0001_publication_platform.sql`, `0002_refine_asset_location_identity.sql`, and `0003_seed_scivive.sql` are applied
- SciVive is the first durable publication record and remains intentionally private
- Worker publication APIs read D1 rather than a hardcoded publication registry
- live health reports publication engine `publication-key-d1-v1` and registry source `d1`
- public publication enumeration returns zero publications while SciVive is private
- direct normal-app lookup of private SciVive returns `404 Publication not found.` by design
- Press prototype is usable enough to defer, but is not final

Recovery history remains:
- known-good historical commit: `5373ba1460babdd3b1f577dba16137fd83ffa6a1`
- recovery commit: `2890ab0`
- recovery tree hash: `b19c2df2f533960305cd2aaf65fdd0842ade5e6e`
- broken backup branch: `backup-broken-gate02-20260828`

The broken branch is forensic history only.
Do not merge it wholesale into `main`.

---

## 4. ACTIVE VISUAL TARGETS

Until widescreen monitors are available again:
- optimize standard laptop/desktop
- optimize mobile

Deferred:
- vertical widescreen
- horizontal widescreen

Widescreen-specific tuning resumes separately; do not force one breakpoint to serve every display.

---

## 5. HELLBOX CORE PRODUCT — LOCKED

Hellbox Comics is an underground digital publishing house.

Priority:
1. comics
2. collecting
3. ownership
4. interaction
5. blockchain

The blockchain is infrastructure underneath the publishing experience.

Hellbox is PulseChain-rooted but not permanently PulseChain-only.

Future EVM expansion must be configuration-driven and use native deployments per chain.

Never bridge Hellbox NFTs.

One conceptual publication is identified by a chain-independent `publicationKey`.

A specific blockchain asset is identified by:
`(chainId, contractAddress, tokenId)`

A collector-facing copy number is separate from token ID.

---

## 6. HARROW — LOCKED CORE

Harrow is:
- writer
- artist
- publisher
- operator
- narrator
- host
- problem

Harrow is manic, sleepless, perfectionistic, paranoid, narcissistic, reckless, brilliant, funny, suspicious, highly productive, promiscuous, and convinced he is normal.

He behaves like a 1%er:
- does not ask permission
- does not seek approval
- does not beg people to buy
- assumes people return because the work is the best
- treats fascination as inevitable

Emotional target:
- first reaction: “this dude is fucked”
- then: “he is disturbingly observant”
- then: “he is absolutely right”
- eventually: “why is he my favorite person?”

Harrow must not become:
- a generic Web3 founder
- a community manager
- a Joker knockoff
- a random edgelord
- a detective/cop character
- a superhero
- a fantasy demon king

He lives in the audience’s real world and should feel like someone who could appear at the next crypto convention.

Core art-direction rule:
**The machinery is disciplined. The operator is not.**

Private lore:
- Harrow is secretly a career fireman
- never state this publicly
- only extremely subtle clues are allowed

Motorcycle:
- black Harley-Davidson Road King Special / heavy bagger identity
- Harrow hates cars: “Cars are cages.”
- old bike name `DEADLINE` is rejected permanently
- bike currently remains unnamed

---

## 7. HARROW ART STYLE DIRECTION

Working artistic identity:
**Infernal Outlaw Editorial Realism**

Primary study influences:
- David Mann — biker authenticity, machine identity, outlaw atmosphere
- Geof Darrow — obsessive machinery and dense visual storytelling
- Bill Sienkiewicz — psychological instability and expressive mixed media
- Dave McKean — artifacts, collage, typography, documents, memory
- Ralph Steadman — manic marks, satirical aggression, handwritten disruption
- Eduardo Risso — noir clarity, silhouettes, readable darkness

Secondary influences:
- Richard Corben
- Simon Bisley
- Harvey Kurtzman / MAD
- South Park satire logic
- Norman Rockwell staging, inverted into Hellbox
- Hieronymus Bosch micro-stories
- David Fincher visual discipline

Do not imitate any single artist directly.

---

## 8. HERO — CURRENT STATE

Canonical hero asset URL:
`https://cdn.hellboxcomics.com/assets/brand/hellbox/banners/hellbox-hero-production.png`

Latest hero master is approved for production.

Important hero rules:
- no fake CSS pencil
- no visible plus-sign hotspots
- environmental discoveries should be invisible
- `PUT THAT BACK` belongs on the production folder marked NOT FOR RELEASE
- bike remains unnamed
- Pulse Byte / infrastructure hotspot maps to actual infrastructure
- Harrow, comic pages, bike, production folder, cabal/wall, infrastructure are meaningful discoverables

Current recovered Gate 0.1 may not yet contain every later intended refinement.
Reapply later changes incrementally, one file at a time, and verify.

---

## 9. ENVIRONMENTAL DISCOVERY PHILOSOPHY

Do not show:
- plus signs
- map pins
- bouncing icons
- “click here”
- persistent hotspot circles

Interactive objects should be discovered.

Desktop:
- subtle local lighting/contrast when approached
- cursor/environment reaction
- keyboard focus remains visible

Mobile:
- no hover dependency
- subtle environmental disturbance
- large invisible tap regions
- no cheesy tutorial overlays

Accessibility:
- every hidden interaction still needs a useful accessible name
- keyboard and screen reader access remain intact

---

## 10. HELLION SYSTEM — LOCKED DIRECTION

HELLION is not a cheap return-user badge.

Hellion is the top-tier initiatory class.

The relationship system should feel like a school the user did not know they enrolled in.

Structural inspiration:
- deep secret-degree / Masonic-style progression
- hidden internal degrees
- never publicly presented as XP or a normal loyalty program

No public:
- progress bar
- score
- leaderboard
- “Hellion Level 4”
- recipe for becoming Hellion

A useful internal structure is 33 hidden degrees, with Hellion beginning only in the highest band.

Hellion recognition should be rare, approximately top 1–5% of meaningful users once real behavior exists.

Relationship model distinguishes:
- permanent history
- current standing
- volatile favor

Money matters but cannot fully buy status.

Top hidden Hellion status should require balanced depth:
- ownership
- reading
- participation
- time
- discoveries
- release history
- current relevance
- collection completeness

Hellion certificate:
- sarcastic award made by Harrow
- Harrow keeps custody
- can be ripped/VOID/revoked later
- history still records that the person once earned it
- restored status can result in the certificate being taped back together

Alias behavior:
- Harrow may learn wallet alias/name
- usually deliberately gets it slightly wrong
- correct-name usage should be rare and emotionally meaningful

Current local prototype must NOT cheaply award Hellion from localStorage interactions.

---

## 11. COMIC / PUBLICATION FORMAT

`NO CONSENSUS` is NOT canon.
It was only a placeholder title during early format work.

Current standard ordinary Hellbox comic issue format:
- 14 story pages
- 64 chronological frames
- frame numbering never resets within an issue
- repeated production template

Harrow may:
- create one issue and leave that title dormant for a year
- rotate among multiple titles
- publish one-shots
- obsessively make many issues in one title
- revisit dormant stories later

Future titles, flagship series, main characters, and casts are still open.

Editorial focus:
- approximately 80–90% crypto / blockchain / real-world satire
- factual blockchain happenings, culture, projects, tokens, NFT collections, community behavior
- mature South Park-like satire
- fictional stories grounded in recognizable real-world truths
- no generic superhero fiction disconnected from the community

Hellbox is mature/adult-oriented, not for children.

---

## 12. NFT ARCHITECTURE — LOCKED

Preferred standard:
- ERC-721 / PRC-721 style individual copies
- each copy is a unique token

One stable Hellbox NFT collection/master contract per chain.
Do not deploy a new NFT contract for every publication.

Do not use ERC721Enumerable as the core ownership index.

Preferred ownership/indexing:
- index `Transfer` events
- verify with `ownerOf`
- maintain fast backend cache/index

Publication lifecycle:
`private → announced → mint_live → circulating`

Standard future paid Hellbox edition:
- max supply: 216
- 6 × 6 × 6
- supply never increases above 216
- surviving supply may only decrease through burns
- general target primary price: ~$6.66 equivalent
- general planned royalty: 666 bps
- general future primary limit: max 6 lifetime primary mints per wallet/publication

SciVive is the exception.

---

## 13. COPY NUMBER ASSIGNMENT

Human copy numbers should ideally be shuffled/unpredictable.

Reason:
- reduce sniping of lore-relevant copy numbers
- separate mint order from collectible copy identity

Lore-relevant numbers may include:
- 13
- 23
- 33
- 66
- other intentionally selected numbers

Special copies may differ by:
- NFT cover/plate
- metadata
- Reader content
- environmental behavior
- temporary effects
- permanent state
- future Hellforge eligibility

Do not convert this into generic rarity tiers.

Perfect anti-sniping is not a launch blocker.

---

## 14. SEALED / UNSEALED — LOCKED DIRECTION

For publications that support sealing:

SEALED:
- unread
- may participate in future sealed $SIN reward path
- cannot burn
- may have transfer restrictions while actively locked in future reward system

UNSEAL:
- one-way permanent state change
- becomes readable/experiential
- can never earn $SIN again from sealed reward path
- any accrued $SIN should be forced/withdrawn to owner wallet on unseal
- sealed-related transfer restrictions end according to final implementation
- unsealed copies may burn
- sealed copies may not burn

SciVive does NOT use sealing.

---

## 15. BURN — LOCKED PHILOSOPHY

Burning must create a direct compelling benefit to the burner.

It cannot exist only to reduce supply or enrich surviving holders.

Strong future direction:
- burn one or more eligible unsealed copies
- transform a surviving copy
- record consumed copy history
- unlock meaningful state, cover, Reader path, proof, or future Hellforge result

Burn rules are publication-specific.

No universal public burn button.

SciVive has no burn feature.

---

## 16. FUTURE $SIN

$SIN is future/classified.

Do not front-run it publicly.

Expected launch route:
- PUMP.tires

Do not build a bespoke SIN ERC-20 unless strategy changes.

Future conceptual revenue routing:
- 1/3 Hellbox/project
- 1/3 market-buy $SIN + burn
- 1/3 market-buy $SIN + rewards

Keep this private until intentionally revealed.

Future NFT/token-bound direction:
- eligible comics may act like token-bound wallets/accounts
- sealed eligible copies may participate in future reward systems
- unsealing permanently ends sealed SIN earning eligibility

Exact reward formulas remain open.

---

## 17. HELLFORGE / SINVAULT

Hellforge:
- future transformation/evolution machinery
- publication-specific recipes
- exact rules NOT locked

SinVault:
- future economic/reward component
- exact mechanics NOT locked
- do not turn it into generic staking by assumption

ERC-6551/token-bound architecture:
- optional future capability
- not a launch blocker

---

## 18. SCIVIVE — LOCKED TEST PUBLICATION

`publicationKey: scivive`

SciVive:
- standalone publication
- not Issue #1
- PulseChain
- ERC-721
- max supply 5,555
- free primary mint
- max 1 primary mint per wallet
- max 1 per transaction
- royalty 369 bps
- Reader enabled

SciVive does NOT use:
- Hellforge
- $SIN
- sealing
- vault
- evolution
- burn gimmicks
- easter-egg token transformations

SciVive source:
- existing open-source ebook package
- EPUB exists
- PDF cover/source exists
- source is rough/unfinished
- Harrow will NOT rewrite, edit, restore, sanitize, or finish Richard Heart’s book
- Harrow is publisher, not co-author/editor

Purpose:
- prove mint → ownership → Archive → protected Reader

About one year after initial Hellbox SciVive release:
- planned graphic-novel adaptation
- follows standard 14-page Hellbox comic rules
- exact supply/price not yet locked
- may cost more because it requires significant Harrow production work

---

## 19. READER — PRODUCT PRIORITY

The Reader is the heart of the product.

It must not feel like an embedded PDF viewer.

Reader presentation classes:
- BOOK
- COMIC
- future ENHANCED

BOOK:
- prose/facsimile, e.g. SciVive

COMIC:
- fixed page/spread reading

ENHANCED:
- future artist-authored sound, timing, depth, lighting, frame effects
- deliberate and restrained
- no automatic gimmick animation

Reader principles:
- artwork is the star
- UI disappears when not needed
- fit page
- fit width
- paged
- continuous
- keyboard
- touch/swipe
- preloading
- accessibility
- optional sound with captions/transcripts where needed
- ownership gate
- protected assets
- no dishonest DRM claims

---

## 20. PRESS — CURRENT / FUTURE

Current Press artwork/interface is a prototype.

Gate 0.2 status:
- desktop/laptop overlap regression was repaired enough to continue
- `HARROW // MACHINE` is structurally separated from the left publication/wallet card in tested standard desktop widths
- current Press formatting is tolerable, not polished
- Press formatting/art is intentionally back-burnered until the dedicated Press Gate unless a regression makes the site unusable

The production Press must be redesigned around real functions before final art/layout approval.

Future Press zones should intentionally support:
- ingest
- publication display
- wallet/collector recognition
- chain/RPC
- release/payment terms
- QC
- signing
- Press core
- copy counter
- release gate
- fault board
- classified future bay

The physical real lever should be the activation control.
Do not add fake CSS levers.

Next Press art must contain clean dynamic screen regions for live HTML data.

Target state sequence:
- ASLEEP
- LOADED
- IDENTIFYING
- RECOGNIZED
- READY
- ARMED
- SIGNING
- PRESSING
- CONFIRMING
- NUMBERING
- RELEASED
- YOURS

Fault states must be clear and honest.

---

## 21. PUBLICATION ENGINE — TARGET END STATE

Desired workflow for a new issue:
1. prepare finished publication package
2. upload it
3. review automatic validation
4. preview Press/Archive/Reader/metadata
5. approve
6. sign one publication configuration transaction
7. choose when Press goes live

No:
- manual site code edits
- new contract per issue
- manual R2 file juggling
- hand-written metadata for every launch
- complicated deployment ceremony

---

## 22. MULTI-CHAIN — LOCKED

PulseChain is Hellbox's root and first chain.

Gate 0 foundation now includes a tested multi-chain backend registry.

Configured networks:
- PulseChain mainnet — chain ID 369 — enabled/root
- PulseChain Testnet V4 — chain ID 943 — development/testing configuration
- Ethereum — configured, disabled
- Base — configured, disabled
- Base Sepolia — configured, disabled
- Robinhood Chain — configured, disabled
- Robinhood Chain Testnet — configured, disabled

Verified backend behavior:
- `/api/health` reports multi-chain-ready architecture
- `/api/chains` returns seven configured networks
- `/api/chain-status?chain=pulsechain` returns a live PulseChain block
- `/api/chain-status?chain=base` correctly refuses Base because it is configured but inactive
- publishing is disabled on all chains until a real Hellbox contract deployment is recorded

Public `config/chains.js` exists as a dormant frontend foundation.
It is intentionally NOT loaded by the current page because the first loader integration caused regressions.
Do not re-enable it casually.

Future chain activation should mean:
- enable/add chain config
- configure RPC
- deploy native Hellbox NFT contract
- record deployment
- enable publishing

No frontend fork.
No new Reader.
No new Archive.
No NFT bridging.

Do not display a chain selector when only one chain is active.
The loaded publication determines the chain.

Before multi-chain launch, eliminate frontend/backend registry drift with a shared/generated source of truth or automated parity validation.

---

## 23. LOCALIZATION — LOCKED DIRECTION

Localization covers the entire website experience, not just menus.

Gate 0 implementation:
- English is canonical
- canonical English catalog currently contains 815 semantic keys
- Spanish contains matching 815 approved keys
- Spanish is the Gate 0 proof/test secondary locale
- desktop `ACCESS // LANGUAGE` control is live
- `?lang=es` and persisted locale selection work
- dynamic Harrow/dialogue/Press/Archive/Reader/interaction copy is keyed
- no live Google translation runs in the visitor browser
- no DOM-scraping translation engine
- no arbitrary JavaScript-string extraction into locale JSON
- deferred locales are hidden from the selector

Google-assisted production workflow:
- canonical English source
- Google Cloud Translation machine draft
- protected Hellbox terminology
- Harrow voice/editorial adaptation
- layout/accessibility QA
- approved static JSON pack

Build tool:
- `tools/google_translate_locale.py`
- API key comes from environment only
- Google key is never stored in site/repo files
- hard local source-character safety cap: 50,000 characters per run

Current Google Cloud note:
- temporary account has $300 trial credit / 90-day trial
- use only for useful temporary/build-time work that remains free or explicitly approved
- do not move production Hellbox infrastructure onto Google merely to consume trial credit
- verify current free-tier/pricing again before future paid-capable use

Deferred until canonical English wording is near final:
- Brazilian Portuguese
- Vietnamese
- Indonesian
- Hindi
- Urdu
- Ukrainian
- Turkish
- Simplified Chinese
- Korean
- Japanese
- French
- Arabic

Every new user-visible string introduced after Gate 0 must receive a canonical English locale key when created.

After English copy freeze:
1. run a locale delta against existing packs
2. translate only added/changed keys where practical
3. perform Harrow voice adaptation
4. perform full interaction QA
5. test every hotspot, button, link, drawer, state, error, notification, metadata field, Reader state, Press state, Archive state and accessibility announcement
6. add RTL support before Urdu/Arabic launch

Publication language remains independent.
A publication is translated only when an intentional localized edition exists.

---

## 24. ACCESSIBILITY — LOCKED IMPORTANCE

Accessibility is a first-class product requirement.

Target practical standard:
- WCAG 2.2 AA

Important support:
- screen readers
- keyboard navigation
- visible keyboard focus
- semantic dialogs
- focus trapping/restoration
- reduced motion
- high contrast
- larger text
- safe touch targets
- captions/transcripts for sound-dependent experiences
- no progression/discovery requiring hearing
- language metadata for assistive technology
- future Reader accessibility

Do not destroy environmental mystery to achieve accessibility.
Use invisible semantic controls plus keyboard/screen-reader access.

---

## 25. LOW-COST OPERATING REQUIREMENT

Hellbox is operated by a solo, part-time creator.

Recurring infrastructure costs should remain as low as practical.

Preferred architecture:
- Cloudflare Worker/static assets
- R2 public/private storage
- D1 database
- no always-on application server unless needed
- no expensive indexer initially
- no CMS unless justified
- direct-to-R2 uploads for large publication packages
- lazy Reader delivery
- event indexing + `ownerOf` verification

Google Cloud:
- temporary trial has $300 credit and a 90-day window
- use for temporary/build-time work only when useful and free
- current example: machine-draft localization
- do not create a permanent production dependency on expiring trial resources
- do not activate/upgrade paid Google Cloud use without explicit user decision

Mainnet contract deployment belongs after product/testnet validation.
PulseChain Testnet V4 should be used first when tPLS is available.

---

## 26. CURRENT RESPONSIVE STATUS

Current live checkpoint: Gate 1 complete.

Verified:
- mobile remains usable
- standard laptop/desktop remains usable
- full-screen standard desktop Press no longer falls back to the original overlap after removing the arbitrary 1699px Gate 0.2 ceiling
- hidden hero/theory interactions function
- English/Spanish switching functions

Known visual debt intentionally deferred:
- Press prototype composition is tolerable but far from final
- direct section anchors can land close to the fixed header
- hero top is still partially sacrificed to fixed-header composition
- hero copy still competes with `PUT THAT BACK`
- transient Harrow response cards can cover nearby content
- Harrow → Keep Up transition has excess vertical space
- horizontal/vertical widescreen tuning remains outstanding

Do not reopen cosmetic Press work until the dedicated Press Gate unless a regression makes the prototype unusable.

---

## 27. CURRENT KNOWN RISKS

- Broken historical Gate 0.2 branch remains preserved and must never be merged wholesale.
- CSS contains many historical overrides; future cleanup must be incremental.
- Frontend `app.js` is large and monolithic.
- Worker/backend `src/index.js` is large and monolithic.
- D1 publication storage is live; Gate 2 Reader manifest/protected-delivery/session infrastructure is not yet implemented.
- SciVive package remains `draft` with 0 validation errors and 2 non-blocking validation warnings at the Gate 1 checkpoint.
- Real minting is not implemented.
- NFT contract is not deployed.
- Archive ownership is not production-real.
- Reader authentication/ownership flow still needs production implementation.
- Current relationship/Hellion system is not server-authoritative.
- Hidden hotspots make exhaustive manual QA difficult; build an internal hotspot inventory/debug mode before release candidate.
- Frontend and backend chain registries can drift until a shared source/parity check exists.
- Final internationalization is incomplete by design until English copy freezes.
- GA4 can be blocked by privacy browsers/extensions; blocker behavior is not a site failure.
- Current Press is only a visual/interaction prototype and must not dictate final Press architecture.
- Current hero composition contains temporary hotspot-coordinate workarounds.

---

## 28. FILES THAT MUST NOT BE CHANGED CASUALLY

`src/index.js`
- Cloudflare Worker entrypoint / backend
- test after every change

`wrangler.jsonc`
- deployment configuration
- edit only for a specific binding/runtime requirement

`.assetsignore`
- controls public static deployment
- do not alter casually

`index.html`
- public DOM structure
- changes affect many frontend systems

`style.css`
- large historical cascade
- test layout after every change

`app.js`
- main frontend runtime
- test interactions after every change

---

## 29. EXACT NEXT STEP

The old decimal `0.3` plan is retired.

The project is rebased onto a production-style Gate 0 through Gate 9 system described in Section 31.

Current position:
- Gate 0 COMPLETE
- Gate 1 COMPLETE
- Gate 2 NEXT

Begin Gate 2 by turning the durable SciVive publication package into the first real Hellbox Reader vertical slice.

First inspect the existing Reader-related frontend/backend paths in `app.js` and `src/index.js` plus the current SciVive package definition. Then choose the smallest single-file Reader implementation step. Do not stack frontend and backend Reader changes before either one is verified.

Gate 2 may use an explicitly authorized test session. Do not prematurely implement Gate 3 wallet ownership, Gate 4 contracts, final Press art, or broad visual polish.

---


## 31. PRODUCTION GATE SYSTEM — REBASED 2026-08-29

The previous decimal sub-gates were useful during recovery but are no longer the right planning model.

The production roadmap is now ten gates total: Gate 0 through Gate 9.

This follows the practical progression for a real digital publishing product:
foundation → durable publication platform → Reader vertical slice → identity/ownership → testnet contract → real Press/mint experience → publisher operations → relationship depth → experience/content freeze → release candidate/mainnet.

### GATE 0 — STABILIZATION & PLATFORM FOUNDATION — COMPLETE

Delivered:
- recovered deployable baseline
- safe one-file-at-a-time workflow
- standard laptop/mobile responsive baseline
- hidden environmental discovery system
- accessibility baseline
- English/Spanish localization architecture
- Google-assisted offline translation tooling
- GA4 integration/verification
- backend multi-chain registry/status APIs
- PulseChain live status
- future chains configured but disabled
- Press prototype made usable enough to defer
- living source-of-truth handoff

Gate 0 means the foundation is stable enough to build the actual product.
It does NOT mean the Hellbox product loop is complete.

### GATE 1 — PUBLICATION PLATFORM & DATA MODEL — COMPLETE

Goal:
Make a Hellbox publication a real first-class durable data object rather than hardcoded prototype data.

Delivered:
- D1-backed publication model
- lifecycle records
- chain-independent `publicationKey`
- per-chain deployment/token identity fields
- release/payment/supply configuration
- public/private publication visibility
- R2 public/private package-location model
- publication package manifest/schema
- validation rules
- SciVive as the first real private publication package
- verified SciVive PDF/EPUB SHA-256 fingerprints and IPFS CIDs
- refined asset-location identity supporting primary delivery, source, and mirror locations
- production `DB` binding to D1 database `hellbox-production`
- Worker publication APIs read durable D1 data rather than a hardcoded array

Gate 1 production migrations:
- `0001_publication_platform.sql`
- `0002_refine_asset_location_identity.sql`
- `0003_seed_scivive.sql`

SciVive durable checkpoint:
- `publicationKey`: `scivive`
- lifecycle: `private`
- public visible: `false`
- presentation class: `book`
- Reader enabled: `true`
- Reader access policy: `ownership`
- PulseChain chain ID: `369`
- max supply: `5555`
- payment: `free`
- max primary mints per wallet: `1`
- max per transaction: `1`
- royalty: `369` bps
- publishing enabled: `false`
- contract address: `null`
- package status: `draft`
- package validation: `0` errors, `2` non-blocking warnings

Live verification at Gate 1 close:
- `/api/health` reports `publicationEngine: publication-key-d1-v1`
- `/api/health` reports registry source `d1`
- D1 registry counts: total `1`, public `0`, private `1`
- `/api/publications` returns an empty public list while SciVive is private
- `/api/publications/scivive` returns HTTP `404` to a normal unauthenticated/public request
- all expected bindings report configured, including database/public bucket/private bucket/assets
- repository working tree was clean after production verification

Exit criteria status:
- SciVive exists as a real private publication record: PASS
- package validates without blocking errors: PASS
- public/private asset locations are defined: PASS
- Worker returns publication metadata from durable storage: PASS
- no contract required yet: PASS
- no manual public-site edit required merely to represent the publication: PASS

### GATE 2 — READER VERTICAL SLICE — NEXT

Goal:
Make SciVive genuinely readable inside Hellbox.

Build:
- BOOK Reader production path
- protected private R2 delivery
- short signed Reader session
- page/chapter manifest
- fit page / fit width
- paged / continuous
- keyboard/touch
- preloading
- accessibility
- honest failure states

Exit criteria:
- authorized test session opens SciVive
- unauthorized normal app request cannot fetch protected reading assets
- Reader works on mobile and laptop
- Reader does not feel like an embedded PDF viewer

### GATE 3 — IDENTITY, OWNERSHIP & ARCHIVE

Goal:
Make wallet identity and ownership real.

Build:
- wallet-signature authentication
- short server session
- chain-aware address identity
- Transfer-event ownership index/cache
- `ownerOf` verification
- real Archive
- Reader authorization using the same authority
- privacy-safe event/history model

Exit criteria:
- wallet connects/signs
- Archive reflects real indexed ownership
- Archive and Reader agree
- localStorage prototype cannot grant authority

### GATE 4 — PULSECHAIN TESTNET CONTRACT

Goal:
Prove the onchain model before mainnet.

Build/deploy on PulseChain Testnet V4:
- stable Hellbox ERC-721 master contract
- publication configuration
- lifecycle rules
- supply limits
- royalty config
- mint limits
- event model
- copy-number assignment baseline
- SciVive test publication configuration

Exit criteria:
- real testnet mint succeeds
- ownership reaches Archive
- minted ownership opens Reader
- native future-chain deployment model is proven without bridging

### GATE 5 — PRESS V2 / REAL MINT EXPERIENCE

Goal:
Turn the Press from prototype art into the real publishing/mint machine.

This is when current Press formatting/art debt is intentionally revisited.

Build:
- final Press functional map
- new/final Press art only after functions are known
- real lever activation
- wallet recognition
- publication display
- transaction preparation/signing
- confirmation
- numbering
- clear failure states
- copy counter
- dynamic screen regions
- testnet mint integration

Exit criteria:
Press → wallet transaction → token → Archive → Reader works end-to-end.

### GATE 6 — PUBLISHER / INGEST OPERATIONS

Goal:
Make new publications plug-and-play.

Build:
- publication package upload
- validation
- asset ingest
- metadata generation
- preview
- release configuration
- Press/Archive/Reader preview
- one publication configuration transaction
- controlled go-live

Exit criteria:
A second test publication can be onboarded without frontend code edits, manual R2 juggling, or another NFT contract.

### GATE 7 — RELATIONSHIP / HELLION PRODUCT DEPTH

Goal:
Replace the local prototype with the real long-term relationship system.

Build:
- permanent history
- current standing
- volatile favor
- server-authoritative events
- discovery history
- reading/ownership/release history
- rare Hellion thresholding
- certificate custody/revocation/restoration
- alias/name behavior
- privacy controls

Exit criteria:
Hellion cannot be cheaply earned through local clicks and persists according to real behavior.

### GATE 8 — EXPERIENCE FREEZE, CONTENT FREEZE & HARDENING

Goal:
Freeze the product experience before launch.

Resolve deferred work here:
- final hero composition
- show full hero below fixed header
- move copy off `PUT THAT BACK`
- restore true hotspot mapping
- stripper-pole hotspot
- `WHO'S NEXT?` hotspot
- woman/crypto obsession-wall thread
- final Press visual polish
- widescreen/vertical layouts
- final English wording
- final Harrow voice pass
- final locale delta
- remaining languages generated/reviewed
- accessibility audit
- performance audit
- privacy/consent
- analytics event taxonomy
- SEO/social metadata
- legal/contact/privacy surfaces as required
- internal hotspot inventory/test mode
- browser/device matrix

Exit criteria:
feature freeze + content freeze + visual freeze.

### GATE 9 — RELEASE CANDIDATE / MAINNET LAUNCH

Goal:
Turn the frozen product into production.

Build/verify:
- PulseChain mainnet contract deployment
- production publication configuration
- production secrets/bindings
- monitoring/logging
- rate limiting/abuse handling
- backup/recovery plan
- Analytics verification
- rollback procedure
- launch rehearsal
- SciVive production mint
- ownership/Archive/Reader full-path validation
- post-launch checklist

Exit criteria:
SciVive is live and the complete Hellbox publishing loop works in production.

### CURRENT CRITICAL PATH

`Gate 2 Reader → Gate 3 ownership → Gate 4 testnet contract → Gate 5 Press`

Do not spend weeks polishing prototype surfaces before this vertical slice works.

---

## 32. GATE 0 COMPLETION / DEFERRED BACKLOG

Gate 0 was intentionally closed with known non-blocking visual debt.

Deferred to later appropriate gates:
- final Press formatting/art → Gate 5
- hero structural composition/hotspot truth → Gate 8
- stripper pole / `WHO'S NEXT?` / woman-crypto obsession-wall additions → Gate 8
- widescreen/vertical layouts → Gate 8
- all languages beyond Spanish → Gate 8 after English copy freeze
- privacy/consent layer and final Analytics event taxonomy → Gate 8
- mainnet contracts → Gate 9

Localization permanent rule:
Every future user-visible interaction must enter the English catalog at creation time and be included in final locale delta/QA.

---

## 33. EXACT NEXT ENGINEERING ACTION

Begin Gate 2 — Reader vertical slice.

First inspect, without changing them yet:
- current Reader-related routes/authorization behavior in `src/index.js`
- current Reader/open-publication behavior in `app.js`
- `publications/scivive/publication.json` Reader/package fields
- existing SciVive source asset locations and formats

Then choose the smallest single-file Gate 2 implementation step. The first durable Reader artifact should establish the Reader content/manifest contract for SciVive before broad UI work. Do not edit `app.js` and `src/index.js` together as one unverified change.

Gate 2 authorization can begin with an explicit authorized test session so Reader delivery can be proven independently. Wallet-signature identity and real ownership authority belong to Gate 3.

Reader constraints already locked:
- SciVive must read like a native Hellbox BOOK experience, not an embedded PDF viewer
- support fit-page / fit-width and paged / continuous modes
- support keyboard, touch, preloading, accessibility, and honest failure states
- unauthorized normal app requests must not be able to fetch protected Reader assets
- SciVive's publicly retrievable source provenance is separate from Hellbox Reader access policy

Do not touch final Press art or contract deployment during this step.

---

## 30. RECOVERY RECORD

Broken state:
- backup branch: `backup-broken-gate02-20260828`
- broken `main` HEAD before recovery: `b7d5fde`

Known-good reference:
- short commit: `5373ba1`
- full commit: `5373ba1460babdd3b1f577dba16137fd83ffa6a1`

Recovery commit:
- `2890ab0`

Tree verification:
- recovery tree:
  `b19c2df2f533960305cd2aaf65fdd0842ade5e6e`
- known-good tree:
  `b19c2df2f533960305cd2aaf65fdd0842ade5e6e`

The hashes matched before the recovery was pushed.

---

END OF CURRENT PROJECT STATE
