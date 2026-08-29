# HELLBOX PROJECT STATE

Last updated: 2026-08-28
Current production branch: `main`
Current live checkpoint: Gate 0.1 / known-good recovery
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

For every change:
1. Explain why that exact file is next.
2. Provide the complete replacement file, never a patch requiring manual splicing.
3. User commits/deploys that one file.
4. Verify the live result and/or backend behavior.
5. Only then move to the next file.

For backend/API work:
- test the changed backend behavior immediately
- isolate failures to the specific file/change that caused them
- do not stack unverified backend changes

Avoid unnecessary repository restructuring.

Do not modify `src/index.js`, `wrangler.jsonc`, `.assetsignore`, or deployment structure casually.

Update this file whenever:
- a meaningful decision is locked
- a file is changed
- a bug is discovered
- a test passes/fails
- architecture changes
- the exact next task changes

---

## 3. CURRENT REPOSITORY / DEPLOYMENT STATE

The repository was recovered after a broken Gate 0.2 deployment.

Current production state:
- Cloudflare rollback confirmed working
- GitHub `main` restored to the exact same tree as known-good commit `5373ba1`
- recovery commit on `main`: `2890ab0`
- tree hash verified identical before push
- current live site works

The failed Gate 0.2 state was preserved before recovery on:
`backup-broken-gate02-20260828`

Do not merge that branch into `main`.

Gate 0.2 is NOT current production.

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

Next Press must be redesigned around actual future functions before new artwork is approved.

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

PulseChain is Hellbox’s root and first chain.

Hellbox must be multi-chain-ready across EVM networks.

Future chain activation should be configuration-driven.

Possible future chains include:
- Base
- Robinhood Chain
- Ethereum
- other compatible EVM networks

Adding a chain should mean:
- add/enable chain config
- configure RPC
- deploy native HellboxNFT contract
- record deployment
- enable publishing

No frontend fork.
No new Reader.
No new Archive.
No NFT bridging.

Do not display a chain selector when only one chain is active.
The loaded publication determines the chain.

---

## 23. LOCALIZATION — LOCKED DIRECTION

Localization must cover the entire website experience, not just menus.

Must translate/adapt:
- static copy
- buttons
- labels
- wallet states
- Press states
- Archive states
- drawers
- Harrow dialogue
- ticker
- errors
- accessibility text
- live announcements
- page metadata

Harrow’s voice must be adapted, not translated literally.

Publication language remains independent.
A publication is only translated when an intentional localized edition exists.

Language priority should be research-driven based on crypto/EVM adoption.

Planned broad priority:
- English canonical
- Spanish
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

Do not expose a public locale until the full pack is complete.

RTL support is required before Urdu/Arabic launch.

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

Mainnet contract deployment is deferred until project wallet funds are available around September 2–3.

PulseChain Testnet V4 may be used before then if faucet tPLS is available.

---

## 26. CURRENT RESPONSIVE STATUS

Current live checkpoint is the recovered Gate 0.1 tree.

Known later intentions that need to be re-applied carefully:
- hidden environmental discoveries
- no plus signs
- improved mobile composition
- standard laptop polish
- full localization
- multi-chain configuration foundation

Do NOT reapply all of this in one package.

Reapply incrementally, one file at a time, with live verification after each file.

Widescreen work remains deferred until correct monitors are available.

---

## 27. CURRENT KNOWN RISKS

- Previous Gate 0.2 multi-file package broke production.
- Broken Gate 0.2 state is preserved as a backup branch and must not be merged.
- CSS contains many historical overrides; future cleanup must be incremental.
- Frontend JS is large and monolithic.
- Worker/backend is large and monolithic.
- Publication registry is still prototype/hardcoded.
- Real minting is not implemented.
- NFT contract is not deployed.
- Archive ownership is not production-real.
- Reader authentication/ownership flow needs production implementation.
- Current local relationship system is not real Hellion authority.

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

### NEXT FILE TO ADD:
`HELLBOX_PROJECT_STATE.md`

This document is that file.

Add it to the repository root.

Commit it alone.

Verify Cloudflare deploys successfully and the live site remains unchanged.

Only after that verification choose the next single file.

Recommended next engineering action after this file:
- inspect current recovered Gate 0.1 frontend
- identify the smallest single-file change that restores hidden environmental hotspot presentation without breaking production
- change only that file
- deploy and test

Do NOT jump directly back to Gate 0.2.

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
