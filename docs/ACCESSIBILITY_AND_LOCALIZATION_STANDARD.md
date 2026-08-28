# Hellbox Accessibility + Localization Standard V1

**Status:** Product requirement. Applies to the public website, Press, Archive, Reader, future audio, and every publication package.

Hellbox may be hostile in character. The product itself must not be hostile to a disabled visitor.

## Accessibility target

Hellbox should be built toward **WCAG 2.2 AA** as its practical baseline, with stronger treatment where the experience allows it.

## Blind and low-vision access

- Every functional control must be reachable and operable by keyboard.
- Interactive artwork must expose meaningful button names to assistive technology even when the visual hit areas remain invisible.
- Pannable art rooms must support arrow keys, Home, and End in addition to touch/drag.
- Dialogs, drawers, the Reader, and access settings must announce themselves, keep focus contained, close with Escape, and return focus to the triggering control.
- Decorative images use empty alternative text. Informational images receive concise alternative text.
- Comic publications eventually need publication-provided page summaries, panel descriptions, and transcript material as optional accessibility assets. Do not ask a screen reader to interpret a flattened page image with no alternative.
- Text enlargement and high-contrast presentation must not break layout or hide controls.
- Status cannot be communicated by color alone.

## Deaf and hard-of-hearing access

- Sound is optional and off until the visitor intentionally enables it.
- Every spoken line, sound-dependent clue, or timed audio event requires a caption, transcript, or equivalent visible cue.
- No discovery, ownership right, Reader content, or relationship progression may require hearing.
- Future enhanced comics must let artists author captions and sound descriptions alongside audio events.

## Motor and cognitive access

- Primary controls should provide at least a 44 × 44 CSS-pixel usable target.
- No precision drag should be the only way to reach content.
- Moving content must be pausable.
- Reduced-motion preferences must stop ticker motion, ambient hotspot pulses, automatic nudges, and unnecessary transition effects.
- Interactions must remain understandable without rushing the visitor or imposing short time limits.
- Harrow's insults may be chaotic; system messages about money, signatures, errors, ownership, and access must remain plain and unambiguous.

## Reader requirements

The Reader is where accessibility matters most.

- BOOK mode must support semantic/reflowable text where the publication legally and editorially permits it, plus facsimile mode when preserving the source is important.
- COMIC mode must provide page-level and optional panel-level descriptions supplied in the publication package.
- Keyboard, swipe, paged, fit-page, fit-width, and continuous navigation must remain available without relying on animation.
- Reader progress must be announced without repeatedly interrupting screen-reader users.
- Enhanced effects must be individually suppressible and must never replace the original artwork or required story information.

## Localization standard

- Source files use UTF-8.
- The document declares its language and direction.
- Interface strings live outside layout code and load from locale packs.
- Gate 0.1 includes English, Spanish, and Brazilian Portuguese **interface-control packs**.
- Harrow's authored prose, jokes, insults, and story text remain source-language material until a human rewrites/localizes them. Literal machine translation is not acceptable for character voice.
- Each future publication package declares its language, available translations, reading direction, and localized assets.
- Layout must eventually support right-to-left languages without mirroring artwork that should remain unchanged.
- Dates, numbers, prices, and plural forms must use locale-aware formatting once those systems become live.

## Gate 0.1 implementation

Gate 0.1 adds:

- skip navigation;
- meaningful landmarks and dialog semantics;
- keyboard-pannable interactive art rooms;
- invisible visual discoveries with accessible names;
- focus containment and restoration;
- a pause control for the moving thought ticker;
- reduced-motion, larger-text, and high-contrast controls;
- forced-colors and system contrast support;
- compact mobile navigation;
- English, Spanish, and Brazilian Portuguese interface packs;
- an honest localization note distinguishing interface translation from Harrow's authored English voice.

## Non-negotiable rule

**Accessibility is not a skin added after launch. Every new Hellbox feature must ship with its non-visual, non-audio, keyboard, motion-reduced, and localized-content strategy defined.**
