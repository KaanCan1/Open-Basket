# Brand assets

The mark is three solid masses forming an open vessel, cut by two diagonal
negative-space slices; the wordmark is lowercase `open basket`. Two colours only: ink
`#0F0F0E` and Signal `#E2FB33`, the same tokens as `open_basket_flutter/lib/src/core/theme.dart`.
The app logo is the ink mark on Signal. Do not outline, rotate, stretch or add effects.

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
| `open-basket-app-icon-1024.png` | 1024x1024 launcher/store icon master, ink on Signal |
| `open-basket-logo-signal-1254.png` | The app logo at the original's size, ink on Signal |

These were thresholded out of the original at luminance 128, which also removed the generation
grain — that is why they are about 10 KB where the originals are several hundred. Regenerate them
the same way if the emblem is ever replaced.

## Launcher icons

`open_basket_flutter/flutter_launcher_icons.yaml` generates the iOS icon set and the Android
adaptive icon from the master above (ADR-027). Replace the master, then run
`dart run flutter_launcher_icons` in `open_basket_flutter/`.
