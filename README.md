# Poolfold

Poolfold is for a volunteer treasurer running a community game night. Split tonight's opening cash across door stations, ring walk-in admissions only after that pool closes, and advance the bout card on this device. Nothing leaves the phone.

## Architecture

The floor is a value-type fold over stations, lots, shifts, and bouts. The phase is derived: Bare when there are no stations, Dark before clock-in, OnShift while lots are still short of the opening pool, Allocated when the sums match, and Live after the bracket is seeded. Clock, allocate, ring, seed, and advance are the only writers, and each one appends to a single mark tape. That suits a treasurer because the night has a hard order: cash is seated before any till moves, and the card cannot start early. `FloorFoldEngine` holds the rules. `FloorStore` is the only persistence seam.

## Allocate, then ring

The home verb is placing the remaining cent lot on the open station. A ring while the fold is still OnShift writes a DriftMark and does not create a TillMark or change Float. Over cap writes OverMark. An empty pool writes DryMark. Allocate while Dark is refused. The bracket seeds only from Allocated, then an OnDeck tap writes AdvanceMark and any other tap writes FaultMark. The simulator seed clocks the shift and leaves one station vacant so the first screen can place that last lot.

## Art

Style: geometric pattern tiles, thick borders, isometric solids, typographic numerals. Each asset was generated opaque, then the outer field was cleared to a real alpha channel.

- `pfd_Onboarding1`: Crisp geometric pattern tiles combined with bold typographic numerals and architectural floor-plan linework, rendered with thick structural borders, sharp isometric angles, and solid cutout silhouettes with transparent outer corners and opaque centers., a person or object that is this product in one glance
- `pfd_Onboarding2`: Crisp geometric pattern tiles combined with bold typographic numerals and architectural floor-plan linework, rendered with thick structural borders, sharp isometric angles, and solid cutout silhouettes with transparent outer corners and opaque centers., the primary action of this product, mid-gesture
- `pfd_Onboarding3`: Crisp geometric pattern tiles combined with bold typographic numerals and architectural floor-plan linework, rendered with thick structural borders, sharp isometric angles, and solid cutout silhouettes with transparent outer corners and opaque centers., a later moment when the product has accumulated meaning
- `pfd_EmptyHome`: Crisp geometric pattern tiles combined with bold typographic numerals and architectural floor-plan linework, rendered with thick structural borders, sharp isometric angles, and solid cutout silhouettes with transparent outer corners and opaque centers., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass
- `pfd_TwistHero`: Crisp geometric pattern tiles combined with bold typographic numerals and architectural floor-plan linework, rendered with thick structural borders, sharp isometric angles, and solid cutout silhouettes with transparent outer corners and opaque centers., an emblem representing this app's signature feature
- `pfd_EmptyFloorCutout`: Isometric geometric door station podium with bold typographic number plates and thick architectural linework, solid center subject, cutout with transparent background
- `pfd_PoolTokenCrest`: Octagonal geometric cashier token stamped with a bold serif numeral and crisp concentric border lines, solid center subject, cutout with transparent background

`pfd_TwistHero` and `pfd_EmptyFloorCutout` sit with the floor art set. The hero drawing on the floor itself is the isometric board.

## How this differs

Same family as other venue floors, but the persisted home verb is allocate-the-float. Per-station lots from one pool must close before any till mark. The board and the pool inspector stay on screen. Shifts, the bracket, finance, and settings arrive as sheets.

## Build

```bash
cd apps/Poolfold
xcodegen generate
xcodebuild -scheme Poolfold -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```
