# 05_CORE_CSS_HIGHEND.md
Version: 1.2 (2026-02-01)

## 1) Hard Rule
In `core/core.css` wird ausschließlich **ein** globaler Override-Block gepflegt und zwar am Dateiende:

```css
/* FS_ACTIVE_THEME_START */
/* FS_ACTIVE_THEME_END */
```

Kein zweites Theme, kein zweites `:root`, keine weiteren Fade-Blöcke irgendwo.

## 2) Design-Zielbild
- ruhig, technisch, Swiss high-end
- ein durchgehender Canvas (keine harten Section-Cuts)
- konsistentes System für Typo, Spacing, Radii, Shadows

## 3) Token-Contract (Beispiele)
Folgende Tokens müssen im Active Theme existieren (Name/Meaning stabil):
- Farben:
  - `--fs-bg0`, `--fs-bg1`, `--fs-surface`, `--fs-line`
  - `--fs-ink`, `--fs-muted`
  - `--fs-brand`
- Layout:
  - `--fs-container`, `--fs-gutter`, `--fs-section-py`
- Typo:
  - `--fs-font`, `--fs-h1`, `--fs-h2`, `--fs-body`, `--fs-lh`
- Physik:
  - `--fs-r1`, `--fs-r2`, `--fs-r3`
  - `--fs-sh1`, `--fs-sh2`, `--fs-hair`
- Transitions:
  - `--fs-fade-h`

## 4) Layout-Contract
- `.w-container` wird systemisiert:
  - `max-width: var(--fs-container)`
  - `padding-left/right: var(--fs-gutter)`
- `section[id]` bekommt Rhythmus:
  - `padding-top/bottom: var(--fs-section-py)`
  - `position: relative; isolation: isolate;`

## 5) Fade-to-Light (ohne sichtbare Bänder)
- Ziel: keine harten Kanten zwischen Sections.
- Umsetzung: Fades über Mask/Gradient auf `section[id]::before/::after` oder section surfaces.
- Wichtig: Fades dürfen nicht wie „Layer-Balken“ wirken.

## 6) Header-Integration (Nav-Glass)
- `.w-nav` wird visuell integriert:
  - halbtransparenter Hintergrund
  - `backdrop-filter: blur(...)`
  - Hairline Border
  - sehr weicher Shadow (keine harte Kante)

Wichtig: Sticky-Verhalten kommt über CSS (nicht über Webflow "Position: fixed").

## 7) Keine Webflow-Optik
Webflow soll keine „Design-Quelle“ sein:
- keine lokalen Font/Color Overrides
- keine manuell gesetzten Abstände pro Element
- Design immer im Active Theme zentralisieren
