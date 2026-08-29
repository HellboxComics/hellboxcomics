# Hellbox Comics

Production website and frontend prototype for **Hellbox Comics**, built and operated by Harrow.

This repository currently contains the public interactive website, prototype Press/Archive/Reader frontend, accessibility/localization foundation, and Cloudflare Worker API skeleton. It does **not** yet contain a deployed NFT contract or production publication engine.

## Current checkpoint

**Gate 0.1 — Laptop + Mobile Master Pass**  
Version: `20260828-gate0-1-02`

This checkpoint:

- loads the final production hero through a cache-busted CDN URL;
- repairs hero hotspot click blocking;
- removes visible `+` markers from environmental discoveries;
- keeps discoveries invisible but keyboard/screen-reader operable;
- turns mobile hero, theory wall, and Press art into horizontally explorable rooms;
- adds mouse drag and keyboard panning to interactive artwork;
- replaces the finite theory ticker with a seamless duplicated Harrow thought loop;
- adds a real pause/resume control to moving ticker content;
- compacts and auto-hides the mobile header while preserving section navigation;
- moves mobile Harrow interruptions out of page copy;
- reduces the Harrow orb and hides its count until something is discovered;
- recomposes mobile Archive, Theory, Press, Harrow, Signals, Classified, Exit, and footer layouts;
- compresses ordinary-laptop dead space while leaving widescreen-specific tuning deferred;
- adds skip navigation, focus containment/restoration, larger-text, high-contrast, reduced-motion, forced-colors, and screen-reader foundations;
- adds English, Spanish, and Brazilian Portuguese **interface-control** language packs;
- keeps Harrow's authored prose in original English until each language receives human localization;
- keeps fake local Hellion promotion disabled.

## Root files

- `index.html` — public page structure
- `style.css` — current visual system and responsive compositions
- `app.js` — browser interactions and prototype application state
- `src/index.js` — Cloudflare Worker/API skeleton
- `wrangler.jsonc` — Cloudflare deployment configuration
- `.assetsignore` — keeps Worker source and internal docs out of public static assets
- `locales/` — interface-control language packs
- `docs/ACCESSIBILITY_AND_LOCALIZATION_STANDARD.md` — product accessibility/localization requirements
- `docs/HARROW_CHARACTER_BIBLE_V1.md` — current Harrow character, art, writing, and lore direction

## Deploy

1. Replace the complete repository with this checkpoint.
2. Commit to `main`.
3. Wait for Cloudflare deployment to finish.
4. Hard-refresh the browser.
5. Verify at ordinary laptop width and on mobile.

No manual code splicing is required.

## Required Gate 0.1 checks

- Hero hotspots open their correct drawers on laptop.
- No visible plus-sign discovery markers remain.
- Mobile art rooms pan horizontally by touch.
- Arrow keys, Home, and End pan focused art rooms.
- Mobile menu opens and section links work.
- Harrow response boxes do not cover the paragraph being read.
- The thought ticker loops without a blank ending and can be paused.
- The discovery count is absent at zero.
- Accessibility panel settings persist after refresh.
- English, Spanish, and Brazilian Portuguese interface controls load.
- No browser activity awards HELLION.

## Production truth

- Public branding and website assets are served from `cdn.hellboxcomics.com`.
- The final hero uses:
  `https://cdn.hellboxcomics.com/assets/brand/hellbox/banners/hellbox-hero-production.png?v=20260828-gate0-1-02`
- Real Hellion standing will eventually be backend-authoritative. The browser prototype cannot award Hellion.
- The current Press remains a temporary functional prototype. Press V2 will be redesigned from the functional blueprint before new production artwork is created.
- SciVive is not yet registered, mintable, or Reader-accessible through this repository.
- Widescreen desktop/rotated-display tuning remains intentionally deferred until the correct screens are available.

## Never commit

- private publication pages;
- wallet private keys or seed phrases;
- Cloudflare API tokens;
- admin secrets;
- Reader signing secrets;
- unreleased protected publication packages.
