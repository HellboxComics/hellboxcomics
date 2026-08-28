# Hellbox Comics

The live Hellbox Comics website and Cloudflare Worker.

Hellbox is Harrow's underground, PulseChain-first digital publishing house. The website is the public lair; the publication engine, protected Reader, Archive ownership, and real Press mint flow are being built behind it.

## Gate 0 stabilization

This repository checkpoint installs the final production hero and keeps the live prototype honest while the real publishing systems are built.

- Uses the lowercase, cache-versioned production hero URL.
- Removes the rejected fake pencil overlay.
- Remaps all hero hotspots to the final 1672 × 941 hero artwork.
- Moves **PUT THAT BACK** to the visible production copy marked **NOT FOR RELEASE**.
- Removes the rejected motorcycle name; the bike remains intentionally unnamed.
- Maps the infrastructure interaction to the HairyLabs Pulse Byte.
- Removes the premature physical “Box” explainer.
- Removes police/detective language outside Harrow's own obsession wall.
- Prevents the local browser prototype from awarding fake **HELLION** status.
- Removes obsolete Ashbox metadata that was not backed by real publication assets.

## Important files

- `index.html` — website structure
- `style.css` — current visual system
- `app.js` — browser interactions and prototype behavior
- `src/index.js` — Cloudflare Worker/API skeleton
- `wrangler.jsonc` — Worker, static assets, and R2 bindings

## Deploy this checkpoint

1. Replace the existing repository contents with this complete checkpoint.
2. Commit the changes to `main`.
3. Let the existing Cloudflare deployment finish.
4. Open `https://hellboxcomics.com/` on the vertical monitor and hard-refresh once.
5. Verify the six hero interactions before changing anything else.

The hero, CSS, and JavaScript URLs are versioned in `index.html`, so normal browser cache should not preserve the previous hero or rejected overlay.

## Current production truth

The public experience is an advanced prototype. Real minting, authoritative ownership, signed Reader sessions, SciVive ingestion, the publication registry, and the production Hellion engine are not live yet. No interface should imply otherwise.

## Infrastructure

- Public CDN: `cdn.hellboxcomics.com`
- Asset domain: `assets.hellboxcomics.com`
- Chain: PulseChain (`369`)
- R2 bindings: public, assets, and private buckets

Do not commit private publication pages, wallet secrets, API secrets, or deployment credentials to this repository.
