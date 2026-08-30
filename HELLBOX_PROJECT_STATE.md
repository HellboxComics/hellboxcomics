# HELLBOX PROJECT STATE

Last updated: 2026-08-30
Current production branch: `main`
Current live checkpoint: Gate 3 COMPLETE and pushed; Gate 4 pre-implementation architecture alignment substantially complete; no Gate 4 contract/tooling implementation has begun
Current roadmap position: Gate 4 — HELLBOX ARTIFACT KERNEL + VERSIONED PUBLICATION FACTORY; next deliverable is the Publication Configuration Blueprint before Foundry/Solidity work
Public repository identity: `Harrow <noreply@hellboxcomics.com>`
Repository privacy status: scrubbed and verified after Gate 2; no personal identity references remain in commit identity, tracked content, commit messages, or historical paths
Checkpoint-reference rule: use Gate/checkpoint names plus live validation results; do not treat commit hashes as durable handoff identifiers
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

This repository is developed incrementally and must remain recoverable at every checkpoint.

Do not use giant multi-file replacement packages by default.

Work one file at a time.

For every code/config change:
1. Explain why that exact file is next.
2. Provide the complete replacement file, never a patch requiring manual splicing.
3. User places that one file in the exact repository path.
4. Validate that only the expected file changed before committing when appropriate.
5. User commits/deploys that one file.
6. Verify the live result and/or backend behavior.
7. Only then move to the next file.

Interaction cadence is also locked:
- give the user one immediate terminal action/validation step at a time
- do not dump long batches of future commands
- wait for the result of the current step before giving the next
- if a deployment can lag, verify the actual live version rather than assuming the push has propagated

Pre-Gate architecture alignment — mandatory:
- before implementation begins on every new Gate, stop and restate the Gate in plain English
- explicitly define what the Gate is meant to achieve and what it is **not** meant to build
- identify irreversible/hard-to-change decisions before code is written
- identify future capabilities that today's architecture must preserve
- distinguish locked decisions from open decisions and ask the creator to resolve material open choices
- define the Gate's acceptance path and non-goals
- do not install tooling, create implementation files, or start coding until this alignment review is complete
- record meaningful architectural decisions in the living documents before implementation if losing them would cause a future thread to build the wrong system

For backend/API work:
- test changed backend behavior immediately
- isolate failures to the specific file/change that caused them
- do not stack unverified backend changes
- temporary test mechanisms must be explicitly removed after proof and their secrets deleted

For static assets/runtime files:
- if CSS/JS URLs are versioned, bump the cache version when the asset changes
- do not assume a deployed file is active until the live page is confirmed to request the new version
- Cloudflare edge cache can temporarily serve an older unversioned asset even after deployment; verify the versioned path and then verify the normal path after propagation

Gate-close documentation procedure — mandatory:
1. Finish technical acceptance for the Gate.
2. Update `HELLBOX_PROJECT_STATE.md` as the authoritative project/engineering/product handoff.
3. Review and update `HARROW_CHARACTER_BIBLE.md` as the authoritative Harrow creative-canon handoff. If no Harrow canon changed during the Gate, still advance its Gate maintenance record.
4. Update `README.md` as the concise project-facing overview/setup/status document.
5. Keep all three living documents mutually consistent and remove superseded/contradictory statements rather than merely appending new ones.
6. Commit and verify each documentation file incrementally.
7. Give the user a short macro-progress report that reflects actual project effort and risk, not simple gate-count percentages.
8. Only then begin the next Gate.

Living-document authority:
- `HELLBOX_PROJECT_STATE.md` = exhaustive project, product, architecture, infrastructure, workflow, validation, risk, and exact-next-action authority
- `HARROW_CHARACTER_BIBLE.md` = exhaustive Harrow visual, psychological, verbal, narrative, environmental, satire, social, and creative-canon authority
- `README.md` = concise repository orientation and current operating status
- important product/Harrow intersections must be reflected in both relevant authority documents so either handoff path preserves the decision
- chat history is not an acceptable substitute for any of these files

`HELLBOX_PROJECT_STATE.md` must be comprehensive enough that a new ChatGPT thread, Claude session, or competent human developer can continue immediately without asking the user to re-explain:
- what Hellbox Comics is
- product purpose and end goal
- enough Harrow identity/voice/visual direction to understand the product, with full creative canon delegated to `HARROW_CHARACTER_BIBLE.md`
- architecture and infrastructure
- publication/Reader/Press/Archive model
- locked decisions and non-goals
- workflow and file-handoff rules
- current production state
- completed proofs
- known risks/debt
- exact next engineering action

`HARROW_CHARACTER_BIBLE.md` maintenance:
- it is a mandatory living repository document, not a one-time creative brief
- review it at every Gate close
- update it immediately when a meaningful Harrow canon, visual-reference, voice, lore, satire, social, website-host, environmental, or rejected/superseded creative decision changes
- authoritative supplied visual references outrank older generated variations
- preserve `LOCKED`, `STRONG DIRECTION`, `OPEN`, `CLASSIFIED`, `SUPERSEDED`, and `REJECTED` distinctions
- do not let creative canon survive only in conversation history

README maintenance:
- keep `README.md` current between Gates
- it is not a substitute for either living bible
- README should stay concise enough for repository orientation while the two bibles carry exhaustive project and creative handoff context

Repository privacy workflow — locked:
- public Git identity is `Harrow <noreply@hellboxcomics.com>`
- never expose the user's personal/legal identity in tracked project material, commit metadata, committed terminal logs, example paths, or public documentation
- when copying terminal output into documentation, remove local usernames/hostnames and any private tokens/secrets
- commit hashes are not durable handoff anchors; privacy/history maintenance can invalidate them
- prefer Gate/checkpoint names, commit subjects, filenames, migrations, durable data state, and live acceptance results
- old pre-privacy clones/history must never be merged back into `main`

Living-document maintenance between formal Gate closes:
- update this file immediately for major architecture, tokenomics, publication-rule, platform, security, ownership, deployment, or product-direction changes
- update `HARROW_CHARACTER_BIBLE.md` immediately for meaningful Harrow canon, visual, voice, lore, environment, satire, social, or creative-direction changes
- when a Harrow decision changes product behavior, record the consequence here as well
- do NOT interrupt implementation to document every minor CSS/file change

Localization workflow:
- every new user-visible interaction/text added during development gets a canonical English locale key when created
- secondary languages may temporarily fall back to English while English copy is still changing
- after English copy freeze, run a full locale delta and final cross-language QA across every hotspot, button, link, state, drawer, error, announcement, Reader/Press/Archive state, metadata field and accessibility string

Avoid unnecessary repository restructuring.

Creative-canon handoff rule — locked:
- `HARROW_CHARACTER_BIBLE.md` is the canonical creative reference for Harrow
- do not reconstruct Harrow from chat memory when the bible or authoritative supplied reference assets answer the question
- if a new explicit creator decision conflicts with the bible, the new decision wins and the bible must be updated
- generated art does not silently create or change canon

File handoff rules:
- every replacement artifact/file must be delivered in **both** forms: a direct file and a ZIP copy
- direct `.js` downloads have been unreliable for the user, so the ZIP is especially important for JavaScript, but still provide both
- the user normally drops delivered items into the repository root
- if the destination folder already exists in the repository, the ZIP contains only the replacement file(s) being handed off; do not recreate/nest the existing folder structure inside the archive
- if the destination folder is new, include only the folder structure required so extraction from the repository root creates the correct new path
- always state the exact destination path for every delivered file
- always print the complete current terminal/deploy/verification command needed for the immediate step
- never tell the user to look back at an earlier message for required commands

Do not modify `src/index.js`, `wrangler.jsonc`, `.assetsignore`, or deployment structure casually.

## 3. CURRENT REPOSITORY / DEPLOYMENT STATE

The repository was recovered after a broken all-at-once Gate 0.2 deployment, then rebuilt incrementally.

Current production state:
- branch: `main`
- Cloudflare deployment is live
- Gate 0 foundation is complete
- Gate 1 publication platform/data model is complete
- Gate 2 SciVive Reader vertical slice is complete
- Gate 2 closeout state bible and README are complete
- Gate 3 identity, ownership authority, Archive integration, Reader authority wiring, sealed Press, and permanent first-introduction routing are complete
- outside first-time document navigation to `hellboxcomics.com` now redirects to `https://hairylabs.io/page/6`
- `/campaign-complete` sets only non-authoritative onboarding completion state and returns to the current Hellbox public experience
- `/campaign-reset` clears only onboarding completion state and redirects to Byte #6
- the sealed Press contains an accessible native replay link: `START ANOTHER INCIDENT`
- valid Harrow `/__harrow` private access bypasses both campaign completion requirements and the sealed surface so development work can continue directly on the real site
- Gate 3 introduced the permanent repo-root `HARROW_CHARACTER_BIBLE.md` creative-canon authority
- Gate closeout now requires all three living documents: `HELLBOX_PROJECT_STATE.md`, `HARROW_CHARACTER_BIBLE.md`, and `README.md`
- public Git history was privacy-rewritten after Gate 2; old pre-rewrite SHAs are intentionally obsolete
- identify implementation checkpoints by commit subject/Gate rather than hard-coded SHA in handoff documentation
- public site works in English and Spanish
- current main frontend runtime query version: `20260829-gate3-archive-09d20a8`
- current Gate 0.2 layout stylesheet cache generation remains `gate0-2-04`
- GA4 is installed with Measurement ID `G-5E9EX1RE0Z`
- GA4 Realtime was verified; Brave Shields can block the user's own Analytics requests
- public/backend multi-chain foundation is live
- production D1 database `hellbox-production` is bound to the Worker as `DB`
- production R2 buckets remain `hellbox-public` and `hellbox-private`
- SciVive protected Reader delivery is stored in `hellbox-private`
- Worker publication APIs read D1 rather than a hardcoded publication registry
- Worker Reader delivery pointers (`reader_manifest_key` and `private_prefix`) come from D1
- Worker wallet authentication authority is D1-backed (`wallet-signature-d1-session`)
- live health reports publication engine `publication-key-d1-v1`, registry source `d1`, `readerConfiguredCount: 1`, authentication engine `wallet-signature-d1-session`, and ownership engine `publication-contract-balance-d1-cache-v1`
- SciVive remains intentionally private and not publicly enumerable
- normal unauthenticated/public `/api/reader/scivive` returns HTTP `404` by design
- the temporary Gate 2 preview route was removed after testing
- temporary Cloudflare secret `HELLBOX_GATE2_READER_KEY` was permanently deleted after testing
- Press prototype is usable enough to defer, but is not final

### Gate 3.1 — SEALED PRESS — COMPLETE

The launched-but-incomplete site is intentionally hidden behind a Harrow-themed prelaunch surface while development continues.

Current sealed-surface facts:
- public document navigation is intercepted Worker-first and serves `prelaunch.html`
- `wrangler.jsonc` uses `assets.run_worker_first: true` so the Worker wins before static `index.html`
- `HELLBOX_PRELAUNCH_MODE` is `sealed`
- public sealed document responses use no-store/cache-eviction headers so stale Cloudflare/browser HTML cannot expose the old homepage
- private owner/developer entry is `/__harrow`
- reseal route is `/__harrow/reseal`
- public status route is `/api/prelaunch/status`
- private access uses Cloudflare secret `HELLBOX_PRELAUNCH_ACCESS_KEY`
- the bypass cookie is secure/HttpOnly/SameSite=Strict and separate from all wallet/Reader/ownership authority
- the secret is never placed in URLs, localStorage, tracked files, or public HTML
- `.assetsignore` was tightened after static deployment was found capable of exposing repository internals
- live `/.git/config` was verified HTTP `404`
- a fresh outside mobile visit was verified to see `THE PRESS IS CLOSED`
- a valid Harrow bypass session was verified to see the real development site
- resealing was verified to restore the closed surface
- this private Harrow bypass must remain higher-priority than any future public onboarding redirect

### THE 30-MACHINE PROBLEM — CAMPAIGN COMPLETE; PERMANENT ONBOARDING INTEGRATION PENDING

The marketing campaign is complete as a 30-transmission linear interactive comic distributed across thirty Pulse Bytes owned/controlled for the project. HairyLabs page caching/propagation is expected before the public-entry redirect is enabled.

Permanent product decision:
- **THE 30-MACHINE PROBLEM is Hellbox Comics' permanent first-introduction medium, not a disposable prelaunch stunt**
- while the site is in development, first-time/outside visitors will be sent to Byte #6 before they see the sealed Press screen
- after the full site launches, the same first-introduction path remains; its story is revised over time to reflect Hellbox's current status and the completion destination becomes the live Hellbox experience
- visitors who have completed it can deliberately replay it as many times as they want
- the sealed screen must gain an in-world replay control that clears only the campaign-completion marker and returns to Byte #6
- campaign completion/replay state is **not authorization** and must never grant wallet identity, ownership, Reader access, Harrow bypass, or other privileged state

Locked transmission sequence:

`#6 → #11 → #13 → #19 → #20 → #23 → #27 → #39 → #41 → #44 → #55 → #62 → #64 → #67 → #77 → #82 → #84 → #85 → #100 → #103 → #104 → #122 → #145 → #149 → #219 → #223 → #237 → #238 → #282 → #333 → Hellbox`

Campaign production rules:
- TX01 / Byte #6, beginning `ONE OF MINE FOUND YOU.`, is the canonical creative/technical template
- every transmission is introduced/created/narrated by Harrow from inside his world
- every Byte is a distinct subordinate machine/servant/accomplice carrying a real Hellbox job
- the actual Byte art is loaded from HairyLabs using the chain/contract/token thumbnail endpoint
- each page is a comic page/panel experience, not a generic campaign landing page
- every transmission explicitly inherits a consequence/clue/order from the prior Byte and routes to the next actual Byte
- humor is mandatory; clues, riddles, lore and project explanation are delivered through Harrow/Byte behavior rather than brochure copy
- HairyLabs Byte pages currently use **zero JavaScript** as the deployment-safe baseline; interactivity uses native HTML such as `<details>/<summary>` plus CSS
- HairyLabs page payload ceiling is approximately `32,768` bytes; canonical campaign pages were kept comfortably below it
- Byte #333 is the final reveal/exit and must route through Hellbox campaign completion rather than merely linking to `/`

Campaign day architecture:
- Day 1 / TX01–06 — **BREACH**: what are these machines and why did one find me?
- Day 2 / TX07–12 — **PROOF**: Hellbox is a comics-first publisher; Reader/Archive/finite publication proof
- Day 3 / TX13–18 — **MACHINERY**: pooled Byte infrastructure, RPC, Chain ID 369, identity, provenance, native-chain discipline
- Day 4 / TX19–24 — **OPERATOR**: Harrow himself; sleepless obsession, outlaw posture, music, bike, earned recognition
- Day 5 / TX25–30 — **IGNITION**: artifact history, Press, detail/calibration, manifest, final distributed-comic reveal

Locked final narrative principle:
> **DO NOT MARKET HELLBOX. DEMONSTRATE WHAT HELLBOX DOES. MAKE THE MACHINERY TELL THE STORY.**

Rejected/superseded campaign work:
- the earlier generic 29-page package that treated transmissions as loosely related marketing pages is invalid and must never be reused
- the canonical remaining 29 pages were rebuilt from TX01's approved Byte #6 grammar
- JavaScript-dependent campaign buttons are not the baseline while HairyLabs deployment behavior remains unreliable

### Permanent first-visit flow — LIVE / LOCKED

Current public behavior:

`new visitor → hellboxcomics.com → Byte #6 → linear 30-Byte story → Byte #333 → /campaign-complete → current Hellbox experience`

During development, the current Hellbox experience after completion is `THE PRESS IS CLOSED`.

Replay behavior:

`current Hellbox experience → START ANOTHER INCIDENT → /campaign-reset → Byte #6`

Live routing/security facts:
- ordinary outside document navigation without campaign-completion state redirects to `https://hairylabs.io/page/6`
- `/campaign-complete` sets a secure HttpOnly SameSite=Lax, non-authoritative completion cookie and redirects to `/`
- `/campaign-reset` clears that completion state and redirects to Byte #6
- campaign redirect/completion/reset responses use no-store/no-cache semantics
- APIs are handled before public onboarding routing; static assets remain available and are not trapped in the story
- Harrow's valid `/__harrow` bypass is independent and takes priority over campaign completion and the sealed surface
- campaign state grants no wallet identity, ownership, Reader access, Hellion status, or private Harrow privilege
- Byte #333's final Hellbox exits now route through `https://hellboxcomics.com/campaign-complete`
- `prelaunch.html` now contains an accessible normal link to `/campaign-reset`
- after main launch, completion will return to the live Hellbox site while the first-introduction story remains permanent and is revised to reflect current project status

### HairyLabs cache/history dependency — EXTERNAL / NON-BLOCKING

The campaign code/content work is complete, but several HairyLabs Byte pages may temporarily display older inscribed/cached versions until HairyLabs refreshes or provides a history-clear/update control.

Known pages awaiting external refresh when last checked:
- Byte #6
- Byte #11
- Byte #13
- Byte #19
- Byte #20
- Byte #23
- Byte #104
- Byte #223
- Byte #333

Locked testing rule while this external state remains:
- **do not use any Byte page in acceptance/regression testing**
- public-gated testing goes directly to Hellbox completion/prelaunch endpoints as appropriate
- real-site/application testing uses the Harrow private bypass and the actual index/application
- stale HairyLabs behavior is not a Hellbox failure
- resume full `#6 → #333` end-to-end acceptance only after the creator explicitly confirms the Byte lane is fully refreshed/clear
- at the end of every upcoming Gate, explicitly ask whether HairyLabs has refreshed the affected pages
- do not reopen Hellbox code merely to compensate for HairyLabs cache/history lag unless an actual Hellbox defect is discovered

Production D1 migrations applied:
- `0001_publication_platform.sql`
- `0002_refine_asset_location_identity.sql`
- `0003_seed_scivive.sql`
- `0004_connect_scivive_reader.sql`
- `0005_wallet_identity.sql`
- `0006_ownership_index.sql`

Gate 3 durable wallet identity checkpoint:
- wallet signing challenges are stored in D1 (`wallet_auth_challenges`)
- challenges are single-use via durable `consumed_at`
- wallet sessions are stored in D1 (`wallet_sessions`)
- sessions are chain-aware, expiring, and revocable
- live production test proved challenge → `personal_sign` → verify → D1 session → session restore → revocation → HTTP `401`
- challenge replay returned HTTP `409`
- live browser acceptance proved the real homepage can reach `VERIFIED` using a throwaway wallet and real production auth endpoints
- identity remains separate from ownership (`VERIFIED` identity did not create an owned publication)
- account/chain changes clear browser-side authenticated state
- throwaway challenge/session records were deleted after testing
- live browser acceptance tool: `tools/test_wallet_auth_ui.py`

Gate 3 ownership/Archive/Reader authority checkpoint:
- `wallet_publication_holdings` exists in production D1
- `ownership_verification_events` exists in production D1
- `active_wallet_publication_ownerships` view exists in production D1
- D1 ownership records are evidence/cache only; blockchain state remains authoritative
- one native ERC-721 collection contract per publication/release is the locked model
- publication-level ownership is verified with that publication contract's `balanceOf(wallet)`
- successful owned/not-owned observations are cached in D1 only for a bounded freshness window
- RPC errors create audit/error evidence and must never silently rewrite a prior owner as `not_owned`
- `/api/wallet-status` requires an authenticated D1-backed wallet session; unauthenticated calls return HTTP `401`
- verified frontend Archive state comes from authenticated `/api/wallet-status`, never localStorage or browser claims
- Reader manifest/page authorization and Archive ownership both call the same Worker ownership authority
- browser/localStorage poisoning was explicitly tested and could not create an owned publication or enable Reader access
- Reader regression acceptance passes at laptop, tablet, and mobile sizes using an authoritative owned fixture
- live wallet identity acceptance passes after Archive integration
- SciVive still has no deployed contract by design; therefore no positive on-chain owner can exist until Gate 4
- because SciVive remains private, normal public Archive does not enumerate it and normal Reader requests continue to return HTTP `404`

SciVive durable Reader binding:
- package status: `draft`
- private page prefix: `comics/scivive/001/reader/pages/`
- Reader manifest key: `comics/scivive/001/reader/manifest.json`
- validation errors: `0`
- validation warnings: `1`
- publishing enabled: `0`
- Reader manifest registered as `reader-manifest`
- Reader manifest access class: `reader_gated`
- Reader manifest provider: `r2_private`
- Reader manifest public retrievable: `0`

Gate 2 private Reader storage:
- canonical source PDF bytes: `8,433,084`
- canonical source PDF SHA-256: `d105e16e991944b63d8e696c8236f5b4497d3c959119a87e580f46f2181bc548`
- canonical source PDF page count: `461`
- Reader presentation format: WebP facsimile pages
- generated Reader pages: `461`
- generated Reader page bytes: `156,576,522`
- private objects in delivery plan: `462` total (manifest + 461 pages)
- all `462/462` objects were downloaded back from remote R2 and matched local byte size + SHA-256
- page `0001` was subsequently fetched through the production Worker and matched the local generated WebP byte-for-byte

Gate 2 browser acceptance:
- laptop `1440x900`: PASS
- tablet `820x1180`: PASS
- mobile `390x844`: PASS
- browser acceptance test: `tools/test_reader_ui.py`
- production publication/ownership data is not modified by that browser test
- laptop/tablet verify the full web Reader control surface
- compact phone layout verifies protected image display, next/previous navigation, close, page-fit presentation, and viewport containment
- protected page transport uses authenticated `fetch` → Blob → `URL.createObjectURL(...)`, not direct protected URLs in `<img src>`
- Reader is not implemented as an embedded PDF viewer

Recovery history remains:
- the repository was restored from the last known-good Gate 0 baseline after a broken all-at-once Gate 0.2 deployment
- `main` was rebuilt incrementally from that recovered baseline
- broken backup branch: `backup-broken-gate02-20260828`
- the later privacy rewrite intentionally changed historical commit hashes across both branches

The broken branch is forensic history only.
Do not merge it wholesale into `main`.
Do not restore or merge an old pre-privacy clone, bundle, or branch snapshot back into the live repository, because doing so could reintroduce scrubbed identity metadata.

## 4. ACTIVE VISUAL / DEVICE TARGETS

Website priority:
1. exceptional PC/Mac browser experience
2. polished and genuinely usable tablet/mobile web experience
3. dedicated native mobile/tablet app later

The website must be dialed in before native-app development begins.

Current web acceptance sizes established in Gate 2:
- laptop: `1440x900`
- tablet: `820x1180`
- phone: `390x844`

Reader product rule:
- laptop/desktop web is allowed the richest control surface
- tablet web should retain strong Reader functionality
- compact phone web may simplify controls when necessary, but must remain polished, readable, navigable, contained within the viewport, and ownership-safe
- do not require desktop-control parity on compact phone layouts merely to claim responsiveness
- long-term app-store mobile/tablet experience will be purpose-built after the website is mature

Until dedicated widescreen monitors are available again:
- optimize standard laptop/desktop
- optimize tablet/mobile

Deferred:
- vertical widescreen
- horizontal widescreen

Widescreen-specific tuning resumes separately; do not force one breakpoint to serve every display.

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

For native Hellbox collectibles, the ERC-721 `tokenId` is the collector-facing Hellbox copy number; public assignment is randomized/shuffled rather than issued sequentially.

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

## 12. NATIVE NFT / ARTIFACT ARCHITECTURE — LOCKED WORKING CONSTITUTION

Hellbox is not building generic NFT collections.

A native Hellbox comic is a **versioned programmable publishing artifact** whose release rules freeze while the object can continue changing according to those frozen rules.

Core rule:

> **THE RULES ARE IMMUTABLE. THE ARTIFACT IS ALIVE.**

Preferred token standard:
- ERC-721 / PRC-721 style individual copies
- one unique token per copy
- **token ID is the Hellbox copy number** for collector clarity
- do not display a second independent copy-number system unless the creator explicitly reverses this decision

### One publication = one native collection — LOCKED

Each publication/release gets its own native ERC-721 collection contract per chain.

Hellbox.com is the publisher/library that unifies those separate finite collections.

Never return to one endlessly growing master Hellbox collection.

Never bridge Hellbox NFTs.

### Versioned immutable publication system — LOCKED

Do not hand-code a bespoke contract implementation for every issue.

The platform uses:
- standardized/audited `HellboxPublication` implementations/templates
- `HellboxPublicationFactory`
- one fresh publication instance per release
- explicit immutable template/protocol version recorded for every deployed release

Released publication instances are **not upgradeable**.

Future capability should come from:
- newer approved publication-template versions for future releases
- modular/external Hellbox protocols that old compatible releases can interact with

Do not silently redefine an old version. Register a new version instead.

Minimal proxy / clone deployment remains preferred **only if** Gate 4 proves good security, verification, explorer, marketplace, wallet and tooling compatibility on PulseChain. Full deployments remain an acceptable fallback.

### Immutable launch configuration versus mutable artifact state

Once a publication mint goes live, Harrow must lose the ability to rewrite that release's rules.

Freeze at launch as applicable:
- publication identity
- template/protocol version
- max supply
- creator allocation policy
- pricing policy and target/static amounts
- accepted payment routes
- mint schedule/phases
- per-wallet allowances
- 1-copy-per-transaction rule
- royalty percentage
- birth-trait vocabulary/counts
- reserved/fixed copy rules
- package/content commitment
- base art/layer commitment
- renderer/version rules
- randomness/allocation rules
- seal/archive capability
- external protocol compatibility
- other edition-specific promises shown by the Press

State may then legitimately change under those frozen rules:
- SEALED / UNSEALED
- ARCHIVED / AVAILABLE
- dynamic covers
- permanent incident/history state
- contextual wallet-dependent traits
- official Archive balance
- Hellforge/evolution state
- token-bound account assets
- metadata output

No publisher seizure, arbitrary confiscation, forced transfer, blacklist, arbitrary owner burn or ownership override.

### Supply

Standard native issue baseline:
- max supply: **216**
- 6 × 6 × 6
- cap can never increase after launch
- burns may reduce surviving supply
- an issue may be permanently closed before reaching max supply; unminted capacity may be destroyed according to the final close/finalization design

SciVive remains a special test publication with supply `5,555`.

### Publication/package commitment

Each release should cryptographically commit to the exact publication system Harrow approved before launch, including as practical:
- canonical/base NFT cover
- actual Reader/publication package
- base publication/package digest
- PRESS MARK assets/layers
- PRESS DEFECT assets/layers
- distribution manifest
- reserved/fixed-copy manifest
- renderer/compositor version/rules
- pricing/mint-policy configuration
- protocol/template version

Protected Reader content does not need to be placed publicly on-chain merely to prove integrity.

---

## 13. COPY ASSIGNMENT, CREATOR PULL & BIRTH TRAITS

### Token ID = copy number — LOCKED

Collector-facing identity is simple:

`tokenId 66 = COPY #066`

Public minting must **not** assign remaining token IDs predictably/sequentially.

The allocation/reveal mechanism must:
- shuffle/randomize the drawable copy IDs
- preserve fixed/reserved IDs
- prevent easy sniping of known grail IDs such as #066
- make the unrevealed trait-to-ID map difficult for Harrow and collectors to predict/manipulate
- be auditable and publicly defensible
- avoid a secret publisher-controlled rarity map
- be tested on PulseChain before the first native mainnet issue

The exact randomness/oracle/reveal implementation is still OPEN for Gate 4 design/testing.

### Standard 216-copy PRESS MARK grammar — LOCKED

Permanent primary birth class:

| PRESS MARK | Total | Meaning |
|---|---:|---|
| `HELLBOUND` | 6 | Top birth rarity; infernal/forbidden edition treatment |
| `PRESS PROOF` | 12 | Harrow working-proof aesthetic: crop marks, corrections, production marks |
| `GOLD` | 18 | Premium gold/foil NFT-readable treatment |
| `STANDARD` | 180 | Canonical normal edition |

Do not dilute this into generic `Rare / Legendary / Mythic / Platinum` NFT rarity soup.

### Standard 216-copy PRESS DEFECT grammar — LOCKED

A separate permanent birth axis:

| PRESS DEFECT | Total |
|---|---:|
| `REDACTED` | 6 |
| `CORRUPTED PLATE` | 12 |
| `BLED OUT` | 18 |
| `OFF REGISTER` | 24 |
| `NONE` | 156 |

PRESS MARK and PRESS DEFECT:
- are separate axes
- may overlap on the same public/randomized copy
- remain permanent with the token across owners
- do not change merely because the owner changes or later wallet conditions change
- may disappear only if the original token itself is explicitly consumed/burned under an owner-authorized transformation

Earlier development labels such as `MISPRINT`, `DAMAGED`, `ERROR COPY`, generic `INK BLEED`, and the idea of many generic rarity tiers are superseded by this stronger publishing/Harrow vocabulary.

### Harrow creator allocation — LOCKED

Harrow has a **maximum 9-copy creator allocation** on a standard native issue, all counted inside the fixed max supply.

Immediate first six:

| ID | PRESS MARK | Harrow's intended path |
|---:|---|---|
| #001 | HELLBOUND | open / break seal |
| #002 | HELLBOUND | preserve sealed |
| #003 | PRESS PROOF | open / break seal |
| #004 | PRESS PROOF | preserve sealed |
| #005 | GOLD | open / break seal |
| #006 | GOLD | preserve sealed |

These six are removed from the public draw immediately.

PRESS DEFECT is **not** preset for Harrow. His copies participate in the same fair defect assignment process; sometimes Harrow gets lucky, sometimes he does not.

Public grail:
- #066 is HELLBOUND
- #066 belongs to the randomized non-Harrow pool and must not be trivially snipable

### Harrow tail reserve — LOCKED

Harrow's final three are **not preselected**.

After #001–#006 are removed:
- the remaining IDs / PRESS MARKS / PRESS DEFECTS participate in the shared randomized mint pool
- public/allowlist/free/reserve phases consume the pool
- three issuance slots are held for the tail
- only on a **true mint-out** do the final three copies left in the machine go to Harrow
- Harrow does not know those IDs/marks/defects in advance
- if Harrow permanently closes a release before true mint-out, he does **not** automatically receive the final three

Press-facing creator language should make this transparent, e.g.:
- `HARROW PULL // 6 TAKEN`
- `3 STILL IN THE MACHINE`
- the final three become Harrow's only at actual mint-out

### Harrow rule of threes — CHARACTER GUIDANCE, NOT CONTRACT LAW

Harrow's collector philosophy:
- rule of 3s
- at least one sealed and one unsealed copy to experience both paths
- one copy may be the practical sell/double
- one may be the ridiculous moonshot
- one may be the forever copy

This is advice from Harrow to collectors/Hellions-in-training. The contract does not enforce his personal collecting theology, and Harrow still does not necessarily approve of what they do.

---

## 14. MINT SCHEDULE, SINGLE-PULL CHAOS & TRANSPARENT ODDS

### Standard native wallet/transaction rule — LOCKED

- maximum primary allowance: **6 copies per wallet/publication**
- **1 copy per transaction**
- no public quantity/batch mint
- contract must enforce quantity = 1; frontend-only enforcement is insufficient
- all normal phases follow the same one-copy-per-transaction rule unless a future explicit release rule says otherwise

PulseChain gas is intentionally inexpensive enough that this friction is part of the experience.

Purpose:
- slow rapid six-copy sweeps
- create more interleaving among collectors
- make every copy a separate Press event
- recalculate rarity/defect odds after every issuance
- create deliberate Harrow-style chaos

This is **not** Sybil protection. One human can use multiple wallets; never claim otherwise.

### Mint phase model — LOCKED REQUIREMENT

The publication builder/contract model must support configurable immutable phases such as:
- creator pull
- reserved/partner claims
- free claims
- allowlist / whitelist
- early Press access
- public Press

Each phase can define before launch:
- start/end or transition condition
- total phase allocation/cap
- per-wallet allowance
- eligibility commitment/proof
- free versus paid
- price policy
- rollover behavior

Use scalable eligibility proofs such as Merkle-style claims where appropriate instead of embedding large bespoke wallet lists.

Unless explicitly and transparently configured otherwise before a release:
- all non-Harrow phases draw from the same remaining randomized copy pool
- allowlist/free/early users do not secretly receive better birth-trait odds

### Live Press transparency — LOCKED PRODUCT REQUIREMENT

The public Press must expose live HTML overlays/screens showing as applicable:
- total run
- Harrow immediate pull
- 3-copy tail reserve
- phase allocations
- minted / remaining
- current phase
- connected wallet
- wallet eligibility
- wallet allowance / used / remaining
- free/reserve/WL status
- payment routes
- current quote
- PRESS MARK remaining counts
- PRESS DEFECT remaining counts
- live percentages/odds

Odds must be recalculated from the **actual remaining drawable pool**, not original supply.

Conceptual formula:

`remaining copies with trait / remaining drawable copies`

Update all relevant screens after every confirmed single-copy mint before the next pull.

When a trait is exhausted, Harrow language may simply report:

`GONE.`

---

## 15. PRICING POLICY — PER PUBLICATION, IMMUTABLE AT LAUNCH

Every publication chooses and previews its pricing policy before mint starts.

Different releases may intentionally have different economics:
- ordinary native issue target may be around `$6.66`
- a labor-intensive graphic novel may target something like `$66.66`
- future market response may justify different future-release pricing
- changing a future release never changes an older one

Required policy modes:

### FREE

No primary payment.

### FIXED_STABLE

Fixed stable/USD-style amount chosen before launch.

### FIXED_PLS

Fixed PLS amount chosen before launch.

The amount does not float with USD value for that release.

### USD_TARGET_DUAL

The collector may choose:
- fixed stable/USD route
- current PLS equivalent of the frozen USD target

Example:
- release target freezes at `$6.66`
- PLS amount changes at mint time as PLS/USD moves
- Harrow is not editing the publication every minute

The architecture should use a trusted pricing adapter/oracle/TWAP-style mechanism rather than manual Harrow updates.

Collector protection:
- current PLS quote shown clearly on Press
- quote tolerance / maximum authorized PLS amount
- if price moves beyond tolerance, revert rather than silently overcharge
- excess handling/refund behavior must be explicit and tested

Exact PulseChain price-source/oracle design remains OPEN and must be researched/tested before locking.

Publication mint terms freeze when mint goes live.

Treasury/royalty routing should be designed so operational wallet rotation does not require mutating historical publication economics; routing contracts/modules may be preferable to changeable per-publication promises.

---

## 16. SEALED, ARCHIVE & UNSEALED STATE — LOCKED DIRECTION

These are different concepts.

### SEALED

- comic has never been opened/read
- may be Archive-eligible
- may participate in future official reward systems if that publication supports them

### ARCHIVE — REVERSIBLE WHILE SEALED

Archive is non-custodial:
- NFT remains in current owner's wallet
- owner may ARCHIVE
- owner may UNARCHIVE
- owner may later ARCHIVE again while the seal remains intact

While archived:
- official accrual may run
- NFT transfer execution is locked/reverts
- Hellbox must not permit listing through its own UI
- visual cover gains an archival plastic/protective sleeve treatment
- compatible marketplaces should receive useful locked-state signaling where practical

Important marketplace honesty:
- third-party marketplaces may create/display off-chain signed listings without calling the token contract
- Hellbox cannot guarantee that no third-party UI displays a listing
- the contract **can** guarantee the actual transfer/sale execution cannot succeed while archived

UNARCHIVE:
- stops new official accrual
- unlocks transfer
- does **not** have to force claim already accrued official rewards
- unclaimed official Archive balance may remain attached to the NFT and follow it to a later owner if transferred unclaimed

### UNSEALED — IRREVERSIBLE

Opening/reading breaks the seal permanently.

Once unsealed:
- cannot reseal
- can never become Archive/reward eligible again
- cannot resume official Archive earning
- metadata/cover reflects the broken seal permanently

Before UNSEAL:
- token must be out of Archive
- official accrued reward must be finalized/paid/claimed or otherwise cleared according to the final protocol
- official reward state becomes `0 / INELIGIBLE` afterward

Every irreversible action must receive a Harrow-voiced, hard-to-miss warning and deliberate confirmation. Humor may surround the warning but must not obscure permanence.

---

## 17. DYNAMIC METADATA, ARTIFACT HISTORY & CONTEXT

Metadata output must remain dynamic.

Do **not** permanently freeze one static JSON file for every token.

Freeze:
- release rules
- renderer/protocol version
- canonical base assets/package
- birth traits/assignments
- immutable publication configuration

Allow metadata to reflect legitimate evolving state:
- PRESS MARK
- PRESS DEFECT
- SEAL
- ARCHIVE
- permanent incident/history state
- current contextual traits
- official Archive balance/status
- Hellforge/evolution state
- cover changes

Marketplace refresh/update signaling must be supported so compatible markets know when dynamic metadata should be re-read.

### Public Harrow-facing metadata grammar

Technical internals can use conventional code names. Collector-facing metadata must read like Harrow made it.

Current stable/strong vocabulary:

| Internal concept | Collector-facing Hellbox vocabulary |
|---|---|
| birth class | `PRESS MARK` |
| birth anomaly | `PRESS DEFECT` |
| sealed/unsealed | `SEAL` → `INTACT / BROKEN` |
| archive state | `ARCHIVE` → e.g. `SLEEVED / AVAILABLE / INELIGIBLE` |
| official accrual | `ARCHIVE BALANCE` |
| series wallet condition | `SET STATUS` → e.g. `COMPLETE / MISSING PIECES` |
| contract/protocol generation | `PRESS VERSION` |

`DAMAGE REPORT` is rejected/superseded as the public name for permanent history because it makes lower sound better.

Current **STRONG DIRECTION**, not yet final canon:
- `LIVED THROUGH` = positive count of permanent incidents/history
- `INCIDENT LOG` = the actual persistent history entries

The goal is for more permanent history to make an artifact more interesting/desirable, not make it read like lower condition grade.

### Permanent versus contextual state

Permanent artifact events:
- follow the token forever across owners
- examples may include owner-authorized Hellforge transformation, burn-survivor history, event marks, permanent incident state
- exact incident taxonomy remains open

Contextual traits:
- describe something true about the **current owner/context**
- may appear/disappear without mutating permanent artifact history
- example: current owner holds every issue in a series
- selling one issue can turn `SET STATUS` from `COMPLETE` to `MISSING PIECES`

---

## 18. TOKEN-BOUND ACCOUNTS, OFFICIAL REWARDS & HELLFORGE COMPATIBILITY

### ERC-6551 / token-bound account — REQUIRED FOR NATIVE ISSUE #1 CAPABILITY

Native Hellbox issues must be compatible with token-bound accounts before the first native mainnet issue.

The token-bound account is the NFT's general-purpose asset/account layer.

Do not give Hellbox seizure/sweep authority over arbitrary assets somebody places in that account.

### Official Archive reward accounting — SEPARATE SYSTEM

Do not equate:
- arbitrary assets physically held in a token-bound account
with
- Hellbox's official Archive reward balance

Preferred architecture:
- dedicated Hellbox reward/vault/accounting protocol
- official balance keyed to the NFT/artifact
- NFT stays in owner's wallet
- owner may claim official accrued rewards at any time
- unclaimed official rewards can follow the NFT to the new owner
- unarchiving stops new accrual but does not necessarily erase/force-claim the existing official balance
- irreversible unseal clears/finalizes official accrual and permanently ends eligibility

Before the future reward token is publicly launched:
- do not expose `$SIN` by name in metadata/Press/public UI
- use neutral language such as `ARCHIVE BALANCE`

Future reward formulas remain OPEN.

### Hellforge / burn / evolution

Before the first native mainnet issue, Native Issue #1 must be compatible with:
- Hellforge
- owner-authorized burn-to-transform
- permanent evolution state
- hidden traits
- dynamic covers
- permanent incident/history state
- contextual wallet-dependent traits

Prefer modular/external Hellforge machinery where practical rather than hardcoding every future recipe into every publication contract.

Hellforge must not be able to burn/transform a token merely because Harrow wants it changed. The current owner must deliberately authorize irreversible transformations.

Burning must provide a direct compelling benefit/result to the participant; it cannot exist only to reduce supply or enrich surviving holders.

The publication kernel needs the interfaces/state/event framework for future protocols without knowing every future recipe at birth.

### Future $SIN

$SIN remains future/classified.

Do not front-run it publicly.

Expected launch route remains PUMP.tires unless strategy changes.

Do not build a bespoke ERC-20 merely because artifact architecture needs future reward compatibility.

---

## 18A. SCIVIVE — LOCKED TEST PUBLICATION / EXCEPTION

`publicationKey: scivive`

SciVive:
- standalone publication
- not Native Issue #1
- PulseChain
- ERC-721
- max supply `5,555`
- free primary mint
- max 1 primary mint per wallet
- max 1 per transaction
- royalty `369` bps
- Reader enabled

Newest SciVive capability direction supersedes the older blanket "no sealing" statement:

SciVive **may use**:
- dynamic covers
- SEALED / UNSEALED
- later contextual visual/state change when the same wallet also owns the future SciVive Graphic Novel

SciVive still does **not** use the full native Hellbox artifact system unless explicitly reopened later:
- no full Hellforge economy
- no $SIN/Archive reward path
- no native 216-copy PRESS MARK / PRESS DEFECT rarity grammar
- no broad burn-to-transform program
- no full native evolution stack

SciVive source:
- existing source book/package
- EPUB exists
- canonical PDF/Reader source exists
- Harrow will NOT rewrite, edit, restore, sanitize or finish Richard Heart's book
- Harrow is publisher/presenter, not source-book co-author/editor

Purpose:
- prove mint → ownership → Archive/library recognition → protected Reader
- exercise the publication factory and basic dynamic cover/seal primitives without pretending SciVive is Native Issue #1

About one year after initial SciVive release:
- planned graphic-novel adaptation
- follows standard Hellbox comic production rules
- exact supply/price remains open
- may intentionally cost substantially more because of Harrow production labor

Native Issue #1 is a separate launch barrier and does not go mainnet until the full artifact capability set is proven.

## 19. READER — PRODUCT PRIORITY

The Reader is the heart of the product.

It must not feel like an embedded PDF viewer.

Reader presentation classes:
- BOOK
- COMIC
- future ENHANCED

BOOK:
- prose/facsimile, e.g. SciVive
- Gate 2 proves BOOK via page-based WebP facsimile delivery from a verified source PDF

COMIC:
- fixed page/spread reading
- later work can add comic-specific spread behavior without replacing the Reader architecture

ENHANCED:
- future artist-authored sound, timing, depth, lighting, frame effects
- deliberate and restrained
- no automatic gimmick animation

Reader principles:
- artwork/content is the star
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
- protected pages must not rely on raw private URLs that can be dropped directly into `<img src>`
- authenticated browser delivery should fetch protected bytes, convert them to Blob/object URLs, and revoke them when no longer needed

Gate 2 implemented BOOK Reader foundation:
- SciVive Reader manifest: `publications/scivive/reader/manifest.json`
- manifest page count: `461`
- deterministic page storage keys: `page-0001.webp` through `page-0461.webp`
- reproducible source/render tool: `tools/build_scivive_reader.py`
- reproducible private R2 upload/verification tool: `tools/upload_scivive_reader.py`
- browser acceptance tool: `tools/test_reader_ui.py`
- private R2 manifest: `comics/scivive/001/reader/manifest.json`
- private R2 pages: `comics/scivive/001/reader/pages/page-0001.webp` through `page-0461.webp`
- D1 is authoritative for Reader manifest key and private page prefix
- Worker validates private manifest publication identity, page prefix, and page count before serving it
- frontend uses authenticated blob transport for protected page images
- adjacent page preloading is implemented
- continuous mode lazy-loads protected blob images
- normal public SciVive Reader request remains HTTP `404`

Gate 2 authorization proof:
- a narrowly scoped temporary Gate 2 preview session was created solely to prove production private delivery before Gate 3 ownership exists
- the session loaded the real private 461-page manifest from production R2 through the Worker
- page 1 returned HTTP `200`
- Worker-delivered page 1 SHA-256: `822feb5e0b165ae9ba395d7eb1a8821a631951a80cafaae5b9604f2800c94171`
- it matched the locally generated source page byte-for-byte
- the temporary preview routes were then removed
- `HELLBOX_GATE2_READER_KEY` was deleted from Cloudflare
- public Reader protection was re-verified as HTTP `404`

Browser acceptance at Gate 2 close:
- laptop `1440x900`: PASS
- tablet `820x1180`: PASS
- mobile `390x844`: PASS
- laptop/tablet exercise full fit/layout controls
- phone intentionally hides desktop-only FIT PAGE / FIT WIDTH / CONTINUOUS controls below the compact breakpoint while preserving page display, previous/next, close, page-fit, and no horizontal overflow

Important current boundary:
- Gate 2 proves Reader delivery and UI
- Gate 3 now proves production wallet identity plus shared Archive/Reader ownership authority
- SciVive still has no deployed publication contract, so positive real ownership cannot exist until Gate 4
- SciVive remains private/non-public and cannot be considered a production collector-access release until the testnet/mainnet publication path is deliberately advanced

## 20. PRESS — PRIVATE BUILDER + PUBLIC MINT MACHINE

The current Press visual/interface is a prototype.

The future Press has two related but distinct roles.

### A. HARROW PRIVATE / GATED PRESS — PUBLICATION COMPILER

Harrow's private Press is the intake, package, contract and release builder.

For every release it must eventually let Harrow provide/configure, validate and preview the complete release **before PUBLISH**.

Minimum creative/package inputs:
1. canonical/base NFT cover
2. actual comic/Reader publication file/package
3. Harrow-authored reusable PRESS MARK assets/layers/masks/rules
4. Harrow-authored reusable PRESS DEFECT assets/layers/masks/rules
5. release-specific metadata/copy
6. publication economics and mint schedule
7. artifact/protocol/version capabilities

Automation pipeline — LOCKED DIRECTION:

`INPUT → VALIDATE → PREVIEW → FREEZE COUNTS/RULES → COMMIT PACKAGE/ART RULES → RANDOMIZE/ASSIGN → RENDER VARIANTS → GENERATE METADATA → DEPLOY → OPEN PRESS`

This is **not AI image generation by default**.

Preferred system:
- reproducible/deterministic compositing
- canonical Harrow base cover
- masks/overlays/typography/effects/transformation rules authored/approved by Harrow
- automated rendering into final token-art variants
- cryptographic commitment to package/rules before launch

Harrow should not manually author every token combination and should not know the full hidden trait-to-ID map before reveal.

Fixed MARK guarantee:
- #001–#006 receive the established creator PRESS MARKS

Everything else follows the approved random/allocation rules.

PRESS DEFECT is not guaranteed to Harrow.

The builder must validate that:
- total MARK counts equal max supply
- total DEFECT counts equal max supply
- fixed assignments do not exceed distribution counts
- Harrow immediate/tail reserve rules are coherent
- phase allocations do not exceed drawable supply
- pricing policy is complete
- renderer/package can reproduce expected artifacts
- all irreversible launch configuration is shown before signature/deployment/go-live

### B. PUBLIC PRESS — COLLECTOR EXPERIENCE

The production mint experience must feel like operating Hellbox publishing machinery, not a generic wallet + mint button.

Public Press uses live HTML overlays over intentionally empty/dynamic regions in the final Press artwork.

Required live information includes:
- publication
- current phase
- wallet/identity
- WL/free/reserve eligibility
- max wallet allowance `6`
- used / remaining allowance
- max 1 per transaction
- supply/minted/remaining
- Harrow immediate pull `6`
- Harrow tail reserve `3`
- phase allocations/claims
- payment modes
- USD target/static amount
- current PLS quote where applicable
- quote validity/tolerance
- live PRESS MARK remaining counts/odds
- live PRESS DEFECT remaining counts/odds
- state/fault information
- transaction progress
- ejected copy/token ID
- resulting MARK/DEFECT/state

The real physical lever remains the desired activation metaphor.

Do not add fake CSS levers.

After every successful single-copy mint:
- refresh supply
- refresh wallet allowance
- refresh phase state
- refresh drawable counts
- recalculate MARK odds
- recalculate DEFECT odds
- show what just came out
- only then permit/quote the next pull

Irreversible actions such as UNSEAL / Hellforge / owner-authorized burn require a separate deliberate warning flow and are not hidden behind ordinary Press excitement.

---

## 21. PUBLICATION ENGINE / PACKAGE BUILDER — TARGET END STATE

Desired workflow for a new publication:

1. Harrow creates the actual comic/publication and canonical cover
2. enter the gated private Press
3. start NEW PUBLICATION
4. upload/attach canonical Reader/publication package
5. upload/attach canonical base NFT cover
6. select/preview approved MARK/DEFECT layer families
7. choose supply and creator rules
8. choose pricing policy
9. configure mint phases / claims / allowlist / free / reserve rules
10. configure artifact capabilities/version
11. validate package and distribution math
12. preview representative token-art output
13. preview Press/Archive/Reader/marketplace metadata
14. preview the exact immutable configuration that will freeze
15. commit package/art/rules
16. deploy a fresh standardized versioned publication contract through the factory
17. record deployment in Hellbox durable publication data
18. choose/open the public Press according to the frozen schedule

The package builder should ultimately generate reproducibly:
- publication package manifest
- Reader delivery manifest/pointers
- contract deployment configuration
- trait distribution manifest
- fixed assignment manifest
- renderer/compositor manifest/version
- metadata
- cryptographic digests/commitments
- allowlist/eligibility commitments
- pricing policy
- phase configuration
- verification/preview report

No:
- manual frontend edits for each issue
- bespoke Solidity implementation for each issue
- hand-juggling R2 objects
- hand-writing every metadata JSON
- Harrow preselecting every random rarity combination
- mutable release promises after mint goes live

### Publication Configuration Blueprint — NEXT REQUIRED GATE 4 DELIVERABLE

Before Foundry is installed or Solidity implementation begins, Gate 4 must produce and approve one complete schema/blueprint listing **every field the private Press must decide and freeze**.

At minimum it must cover:
- identity/version
- chain
- supply
- immediate creator pull
- tail reserve
- fixed IDs
- trait distributions
- art/package inputs
- renderer/version
- randomization/reveal policy
- pricing mode
- price targets/static amounts
- accepted assets
- mint phases
- allowlist/claim commitments
- per-wallet limit
- one-per-transaction rule
- royalty
- treasury/routing
- seal/archive capability
- dynamic metadata capability
- ERC-6551 compatibility
- external protocol/Hellforge compatibility
- package/content digest
- freeze/finalization semantics

This blueprint is the shared source from which future contract config, D1 data, private Press UI and validation tooling should derive.

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
- deploy/record that chain's standardized `HellboxPublication` implementation + `HellboxPublicationFactory`
- deploy each publication as its own native release contract through the factory
- record each publication's `(chainId, contractAddress)` deployment
- enable publishing only for configured/validated native publication deployments

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

Current live checkpoint: Gate 3 COMPLETE — the authority system, sealed Press, permanent first-introduction routing, completion/replay flow, and private Harrow bypass are live-proven; Gate 4 is next.

Verified:
- standard laptop/desktop remains usable
- tablet Reader acceptance passes at `820x1180`
- compact mobile Reader acceptance passes at `390x844`
- full-screen standard desktop Press no longer falls back to the original overlap after removing the arbitrary 1699px Gate 0.2 ceiling
- hidden hero/theory interactions function
- English/Spanish switching functions
- Gate 2 Reader UI passes browser acceptance at laptop, tablet, and phone sizes
- compact phone Reader remains viewport-contained with working previous/next/close controls
- versioned frontend runtime is live as `/app.js?v=20260829-gate3-archive-09d20a8`

Known visual debt intentionally deferred:
- Press prototype composition is tolerable but far from final
- direct section anchors can land close to the fixed header
- hero top is still partially sacrificed to fixed-header composition
- hero copy still competes with `PUT THAT BACK`
- transient Harrow response cards can cover nearby content
- Harrow → Keep Up transition has excess vertical space
- horizontal/vertical widescreen tuning remains outstanding
- compact phone Reader intentionally has a reduced control surface compared with laptop/tablet; native mobile/tablet app comes later after website maturity

Do not reopen cosmetic Press work until the dedicated Press Gate unless a regression makes the prototype unusable.

## 27. CURRENT KNOWN RISKS

- Broken historical Gate 0.2 branch remains preserved and must never be merged wholesale.
- CSS contains many historical overrides; future cleanup must be incremental.
- Frontend `app.js` is large and monolithic.
- Worker/backend `src/index.js` is large and monolithic.
- D1 publication/Reader delivery, wallet identity, and shared Archive/Reader ownership authority are live; positive minted-owner proof remains legitimately unavailable because SciVive has no deployed contract until Gate 4.
- SciVive package remains intentionally `draft` with 0 validation errors and 1 non-blocking warning.
- SciVive remains intentionally private/non-public until real ownership authorization exists.
- Real minting is not implemented.
- NFT contract is not deployed.
- Archive ownership logic is production-authoritative and chain-backed by design; it currently returns no positive SciVive ownership because Gate 4 has not yet supplied a real publication contract/mint.
- Gate 2 used a temporary preview authorization solely for proof; it has been removed and its Cloudflare secret deleted. Do not resurrect it as production auth.
- Reader browser transport now consumes the same Gate 3 wallet/session/ownership authority as Archive; positive collector access awaits Gate 4's first real contract/mint.
- Current relationship/Hellion system is not server-authoritative.
- Hidden hotspots make exhaustive manual QA difficult; build an internal hotspot inventory/debug mode before release candidate.
- Frontend and backend chain registries can drift until a shared source/parity check exists.
- Final internationalization is incomplete by design until English copy freezes.
- GA4 can be blocked by privacy browsers/extensions; blocker behavior is not a site failure.
- Current Press is only a visual/interaction prototype and must not dictate final Press architecture.
- Current hero composition contains temporary hotspot-coordinate workarounds.
- Cloudflare static-asset edge cache may briefly serve an older unversioned asset after deployment. Keep versioned JS/CSS references and verify the normal path after propagation.
- Browser acceptance currently validates the Reader UI with mocked publication/Reader API responses so it cannot mutate production ownership state. Production private-byte delivery is separately proven through the Worker/R2 Gate 2 verification.
- Public first-visit campaign routing is **not yet implemented**; the live site currently still goes directly to the sealed Press surface for outside visitors.
- HairyLabs campaign pages require their platform-side cache/propagation before Hellbox should begin redirecting first-time public traffic to Byte #6.
- The campaign-completion marker must remain non-authoritative and isolated from Harrow bypass, wallet session, ownership, Reader, and publication security state.
- HairyLabs may temporarily serve stale historical Byte-page inscriptions for campaign pages; this is an external cache/history issue, not a Hellbox routing defect. Bytes are excluded from testing until the creator confirms the lane is clear.

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

Gate status:
- Gate 0 COMPLETE
- Gate 1 COMPLETE
- Gate 2 COMPLETE
- Gate 3 COMPLETE
- **Gate 4 PRE-IMPLEMENTATION ARCHITECTURE ALIGNMENT COMPLETE ENOUGH TO BUILD THE BLUEPRINT**
- no Gate 4 contract/tooling implementation has started
- Foundry is **not installed**

HairyLabs Byte-cache status remains external/non-blocking:
- do not include Bytes in testing until the creator explicitly says the lane is clear
- ask for refresh status at every upcoming Gate close

### Immediate next action in a new Gate 4 thread

Read, in order:
1. `HELLBOX_PROJECT_STATE.md`
2. `HARROW_CHARACTER_BIBLE.md`
3. `README.md`

Then do **not** jump directly to Solidity.

First produce and review the **Publication Configuration Blueprint** defined in Section 21.

The blueprint must make explicit:
- which fields are immutable at mint start
- which state can change later according to frozen rules
- which fields belong in the publication contract
- which belong in factory/version registry
- which belong in external protocols
- which belong off-chain/D1/package manifests
- what is cryptographically committed
- what is publicly displayed on Press
- what is open for later Gates but must be compatible from Native V1

After the creator approves that blueprint:
- choose/install contract tooling
- current recommendation: Foundry
- repository currently has no `package.json`, lockfile, Foundry config, Hardhat config, `contracts/`, `test/`, or equivalent contract-tooling structure
- `forge`, `cast`, and `anvil` are currently not installed
- then begin the smallest one-file Gate 4 implementation step

## 31. PRODUCTION GATE SYSTEM — WORKING ROADMAP REBASED 2026-08-30

The earlier Gate 0–9 compression was useful, but the native Hellbox artifact model is now intentionally broader.

The working roadmap is **Gate 0 through Gate 10** so early Native Issue #1 collectors do not receive a stripped-down artifact that later releases outperform structurally.

This roadmap may be refined deliberately in future pre-Gate alignment reviews, but do not compress major artifact capabilities merely to preserve the old gate count.

### GATE 0 — STABILIZATION & PLATFORM FOUNDATION — COMPLETE

Foundation/recovery, responsive web, accessibility/localization, analytics, multi-chain foundation and safe workflow.

### GATE 1 — PUBLICATION PLATFORM & DATA MODEL — COMPLETE

D1 publication model, package/schema model, R2 public/private locations and SciVive private package.

### GATE 2 — READER VERTICAL SLICE — COMPLETE

461-page protected SciVive Reader, private R2 delivery, reproducible build/upload tooling and browser acceptance.

### GATE 3 — IDENTITY, OWNERSHIP, ARCHIVE & PUBLIC ENTRY — COMPLETE

D1 wallet identity/session, shared blockchain-authoritative ownership, Archive/Reader authority, SEALED PRESS, permanent 30-machine introduction, completion/reset and Harrow bypass.

External only:
- full Byte #6→#333 traversal waits for HairyLabs cache/history refresh and does not block future Gates

### GATE 4 — HELLBOX ARTIFACT KERNEL + VERSIONED PUBLICATION FACTORY — CURRENT

Goal:
Create the immutable/versioned on-chain kernel every publication can build on without painting Native Issue #1 into a corner.

Pre-implementation architecture alignment has established:
- versioned non-upgradeable publication instances
- one native ERC-721 collection per publication
- tokenId = copy number
- randomized anti-sniping public assignment
- 216-copy native baseline
- PRESS MARK / PRESS DEFECT permanent birth grammar
- Harrow immediate six + true-mintout three-copy tail reserve
- one-copy-per-transaction / max-six-per-wallet standard
- pricing-policy modes
- dynamic metadata requirement
- SEALED / ARCHIVE / UNSEALED primitives
- future ERC-6551 / reward / Hellforge compatibility
- publication-package/art cryptographic commitment
- private Press publication-compiler direction

Gate 4 implementation should establish/test:
- Publication Configuration Blueprint first
- `HellboxPublication` versioned kernel/template
- `HellboxPublicationFactory` / approved template registry
- immutable configuration/finalization boundaries
- supply enforcement
- token/copy assignment architecture
- mint schedule/config representation
- pricing-policy interface/representation
- royalty/event baseline
- dynamic metadata/renderer interface
- seal/archive-compatible primitives/interfaces as appropriate
- external protocol compatibility points
- package/content commitment
- metadata update signaling
- SciVive test deployment
- second dummy publication deployment
- real testnet mint reaching Gate 3 ownership → Archive → Reader

Gate 4 is PulseChain Testnet V4 only.

### GATE 5 — PRESS V2 + PRIVATE RELEASE/CONTRACT BUILDER + REAL MINT UX

Private publication builder plus collector Press, pricing/phase UX, live dynamic screens, one-copy pulls and real mint transactions.

### GATE 6 — INGEST + DYNAMIC METADATA + RARITY/RENDERING PACKAGE ENGINE

Automated package intake, canonical cover/Reader ingest, deterministic MARK/DEFECT rendering, random assignment/reveal integration, metadata renderer and marketplace refresh signaling.

### GATE 7 — ARTIFACT PROTOCOLS

SEALED/UNSEALED, reversible Archive, transfer lock, official reward accounting, ERC-6551, permanent/contextual traits, dynamic covers, Hellforge, owner-authorized burn/evolution and protocol compatibility.

### GATE 8 — RELATIONSHIP / HELLION PRODUCT DEPTH

Durable relationship history, standing/favor, Hellion thresholds, certificates, aliases and privacy controls.

### GATE 9 — EXPERIENCE/CONTENT FREEZE + AUDIT/HARDENING

Final art/content, accessibility/localization, performance/privacy/analytics/SEO/legal, browser matrix, contract/security review and full Native Issue #1 prelaunch audit.

### GATE 10 — RELEASE CANDIDATE / MAINNET + FIRST NATIVE ISSUE

PulseChain mainnet production contracts/protocols, launch rehearsal, SciVive production path, first native Hellbox issue and full post-launch acceptance.

### NATIVE ISSUE #1 HARD RELEASE BARRIER

SciVive is allowed to be the proving exception.

The first **native Hellbox comic issue** does not launch until all intended foundational artifact capabilities are proven so early adopters are not second-class collectors.

Before Native Issue #1 mainnet, prove:
- unique versioned publication contract
- immutable release configuration
- 216-copy standard grammar
- tokenId/copy randomization
- Harrow immediate/tail allocation
- PRESS MARK / PRESS DEFECT
- dynamic generated covers/metadata
- marketplace metadata updates
- all mint phases and one-copy-per-transaction rule
- live odds/transparency
- chosen payment policy / dynamic PLS pricing where used
- SEALED / ARCHIVED / UNSEALED
- non-custodial official reward compatibility
- transfer locking while archived
- ERC-6551
- permanent incident/history state
- contextual traits
- Hellforge
- owner-authorized burn/transformation
- hidden traits/evolution
- protocol/version recognition
- complete Press warnings/UX

### CURRENT CRITICAL PATH

`Gate 4 artifact kernel → Gate 5 Press/builder → Gate 6 package/metadata/rendering → Gate 7 artifact protocols → Gate 8 Hellion → Gate 9 freeze/audit → Gate 10 mainnet`

## 32. GATE 0 COMPLETION / DEFERRED BACKLOG

Gate 0 was intentionally closed with known non-blocking visual debt.

Deferred to later appropriate gates:
- final Press production art/UX → Gate 5, with final freeze in Gate 9
- hero structural composition/hotspot truth → Gate 9
- stripper pole / `WHO'S NEXT?` / woman-crypto obsession-wall additions → Gate 9
- widescreen/vertical layouts → Gate 9
- all languages beyond Spanish → Gate 9 after English copy freeze
- privacy/consent layer and final Analytics event taxonomy → Gate 9
- mainnet contracts → Gate 10

Localization permanent rule:
Every future user-visible interaction must enter the English catalog at creation time and be included in final locale delta/QA.

---

## 33. EXACT NEXT ENGINEERING ACTION

**GATE 4 IMPLEMENTATION HAS NOT STARTED. DO NOT SKIP THE BLUEPRINT.**

Repository inspection already proved:
- no `package.json`
- no package-manager lockfile
- no `foundry.toml`
- no Hardhat config
- no `contracts/`
- no `test/` / `tests/` contract structure
- `forge`, `cast`, `anvil` not installed

Working tool recommendation remains **Foundry**, but installing it is **not** the immediate next action.

### First Gate 4 deliverable in the new thread

Create the **Publication Configuration Blueprint**.

It must enumerate every release field and classify each as:
- immutable at mint-go-live
- mutable artifact state under frozen rules
- factory/template-registry state
- publication-contract state
- external-protocol state
- D1/off-chain package state
- cryptographic commitment
- private-Press-only draft state
- public Press/display state

The blueprint must include at least:
- publication identity
- chain
- template/protocol version
- collection name/symbol
- max supply
- immediate Harrow six
- true-mintout three-copy tail reserve
- fixed IDs such as #066
- PRESS MARK distribution
- PRESS DEFECT distribution
- randomization/allocation/reveal policy
- canonical cover
- Reader package
- layer/manifests
- renderer version
- package/content digest
- pricing mode
- stable/USD target
- static PLS amount
- accepted payment routes
- price adapter/oracle reference where applicable
- quote/slippage rules
- mint phases
- phase caps
- eligibility/Merkle commitments
- wallet allowance 6
- one-copy-per-transaction
- royalty
- treasury/routing
- metadata/renderer interface
- metadata refresh signaling
- SEALED capability
- ARCHIVE compatibility
- UNSEAL behavior
- ERC-6551 compatibility
- external reward protocol compatibility
- Hellforge/burn/evolution compatibility
- event/indexing requirements
- freeze/finalization state

### After blueprint approval

Then:
1. install/initialize the chosen contract toolchain
2. preserve one-file-at-a-time workflow
3. create the smallest first Gate 4 contract/config file
4. test immediately
5. do not deploy mainnet
6. do not use stale HairyLabs Bytes in testing

### Gate 4 acceptance target

`factory/template → SciVive Testnet V4 collection → 1-copy mint → Gate 3 balanceOf ownership → Archive owned → Reader opens`

and:

`same factory/template/version → second dummy publication without bespoke Solidity changes`

Gate 4 must also prove that its kernel/config model does **not** prevent the full Native Issue #1 artifact requirements assigned to later Gates.

At Gate 4 close:
- update all three living documents
- provide weighted progress
- ask whether HairyLabs has refreshed Bytes #6, #11, #13, #19, #20, #23, #104, #223, #333

## 30. RECOVERY AND PRIVACY RECORD

### Recovery

The repository was recovered after a broken all-at-once Gate 0.2 deployment.

Locked recovery facts:
- backup branch: `backup-broken-gate02-20260828`
- the last known-good production tree was restored to `main`
- recovery was validated by matching the recovered tree to the known-good tree before incremental development resumed
- Gate 0, Gate 1, and Gate 2 were then rebuilt/advanced incrementally under the one-file-at-a-time workflow
- exact pre-privacy commit/tree hashes are intentionally no longer recorded here because the later privacy rewrite changed the public history

The broken backup branch is forensic history only.
Do not merge it wholesale into `main`.

### Repository privacy hardening — completed after Gate 2

Public identity rule:
- all Hellbox Git author/committer identity must be `Harrow <noreply@hellboxcomics.com>`
- the user's personal/legal name, personal email, local machine username/hostname, or other directly identifying strings must not be introduced into tracked files, commit messages, examples, screenshots/logs committed to Git, or handoff documentation
- use Harrow/project-level identifiers in public repository material

Completed privacy work:
- all historical commit author and committer identities were rewritten to Harrow
- tracked-file identity references were scrubbed across historical snapshots
- commit messages were scanned
- historical filenames/paths were scanned
- verification result: `0` non-Harrow commit identities
- verification result: `0` historical commits containing the scrubbed personal identity strings
- verification result: `0` historical paths containing those strings
- both `main` and `backup-broken-gate02-20260828` were force-updated to the scrubbed histories using guarded `--force-with-lease`
- GitHub remote branch refs were verified to match the scrubbed local branches
- the local pre-scrub Git bundle was deleted
- `.git/filter-repo` temporary rewrite data was deleted
- temporary Gate 2 shell credentials were cleared

Important consequence:
- every pre-scrub commit hash is obsolete
- do not use old chat logs or old documentation SHAs as authoritative repository checkpoints
- do not resurrect an old clone/bundle without first ensuring it cannot reintroduce pre-scrub history
- durable handoff references should use Gate names, commit subjects, file paths, schema/migration names, production state, and explicit validation evidence rather than SHA values

---

END OF CURRENT PROJECT STATE
