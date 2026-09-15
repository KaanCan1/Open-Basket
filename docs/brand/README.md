# Brand assets

Monochrome only. The mark is three solid masses forming an open vessel, cut by two diagonal
negative-space slices; the wordmark is lowercase `open basket`. Do not recolour, outline, rotate,
stretch or add effects to either.

## Supplied originals

| File | Size | Use |
|---|---|---|
| `open-basket-white-on-black-banner.png` | 2172x724 | README and social headers, dark background |
| `open-basket-black-on-white-banner.png` | 2172x724 | README and social headers, light background |
| `open-basket-white-emblem.png` | 1254x1254 | Square emblem, white on opaque black |

The prompts that generated them are kept in `prompts/`, so a variant can be regenerated in the
same style rather than redrawn.

## Derived (generated from `open-basket-white-emblem.png`)

| File | Use |
|---|---|
| `open-basket-emblem-white-transparent.png` | White mark, alpha background — in-app on dark surfaces |
| `open-basket-emblem-black-transparent.png` | Black mark, alpha background — in-app on light surfaces |
| `open-basket-black-emblem.png` | Black mark on opaque white |
| `open-basket-app-icon-1024.png` | 1024x1024 launcher/store icon master, white on black |

These were thresholded out of the original at luminance 128, which also removed the generation
grain — that is why they are about 10 KB where the originals are several hundred. Regenerate them
the same way if the emblem is ever replaced.

## Still to do

The launcher icons themselves are not wired up yet: Android adaptive icons and the iOS icon set
still need generating from `open-basket-app-icon-1024.png`, and that touches
`open_basket_flutter/` and its platform folders. It belongs to B, and `PLAN.md` schedules it for
Day 22.
