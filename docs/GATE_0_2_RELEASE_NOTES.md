# Hellbox Comics — Gate 0.2 Release Notes

## Checkpoint

**Gate 0.2 — Laptop Polish + Globalization + Multi-Chain Foundation**

Build:

`20260828-gate0-2-01`

## Public experience

- Environmental discoveries no longer display plus signs, circles, or map pins.
- The Press no longer draws `PULL IT. I DARE YOU.` or `DO NOT PULL THAT.` over
  the machine.
- Standard-laptop section spacing is reduced without retuning the frozen
  widescreen compositions.
- Harrow's orb suppresses itself while dialogs, the Reader, the mobile menu,
  form controls, active scrolling, or pannable artwork own the screen.
- The Theory ticker is rebuilt as a duplicated continuous sequence.
- The ticker pause control is moved out of the thought stream.
- The Press state rail uses horizontal scroll snapping.

## Full-site localization

Public packs:

- English
- Spanish
- Brazilian Portuguese

Gate 0.2 localizes the complete website shell and authored site experience:

- static section copy;
- navigation;
- buttons and states;
- Harrow responses;
- environmental drawers;
- errors;
- accessibility labels and announcements;
- metadata.

The selected locale persists locally and is shareable with `?lang=`.

Publication content remains in its actual published language unless a localized
edition exists.

## Multi-chain foundation

- Added public and Worker-side EVM registries.
- Added `/api/chains`.
- Active-chain labels are driven by configuration.
- Wallet logic reads the active chain through the registry.
- PulseChain remains the root and only enabled public deployment.
- Base, Ethereum, Robinhood Chain, and test networks remain disabled until
  native contracts are deployed.
- Bridging is explicitly unsupported.

## Files added

- `/gate02.css`
- `/gate02.js`
- `/config/chains.js`
- `/src/config/chains.js`
- `/locales/en.json`
- `/locales/es.json`
- `/locales/pt-BR.json`
- `/locales/manifest.json`
- `/docs/GLOBALIZATION_AND_MULTICHAIN_STANDARD.md`

## Widescreen

No deliberate vertical-widescreen or ultrawide redesign was performed in this
checkpoint. Those layouts remain scheduled for review on the proper displays.
