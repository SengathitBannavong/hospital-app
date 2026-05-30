---
name: Hospital App
description: Indoor hospital wayfinding for stressed visitors, with the small ancillary tasks they need on site.
colors:
  primary: "#0A6DC2"
  primary-light: "#3B9FE3"
  primary-dark: "#074E8C"
  primary-surface: "#E8F4FD"
  secondary: "#0E8A6D"
  secondary-light: "#2DBDA0"
  secondary-dark: "#086650"
  secondary-surface: "#F0FAF6"
  emergency: "#D92D20"
  emergency-active: "#DC6803"
  emergency-surface: "#FEE4E2"
  on-emergency: "#FFFFFF"
  task-in-progress: "#0A6DC2"
  task-waiting: "#B54708"
  task-done: "#067647"
  background-light: "#F8F9FA"
  surface-light: "#FFFFFF"
  surface-variant-light: "#F1F3F5"
  border-light: "#E2E8F0"
  border-subtle-light: "#F1F3F5"
  text-primary-light: "#1A1D21"
  text-secondary-light: "#4A5568"
  text-tertiary-light: "#94A3B8"
  background-dark: "#121417"
  surface-dark: "#1E2128"
  text-primary-dark: "#E2E8F0"
typography:
  display:
    fontFamily: "Plus Jakarta Sans, system-ui, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Plus Jakarta Sans, system-ui, sans-serif"
    fontSize: "24px"
    fontWeight: 600
    lineHeight: 1.3
  title:
    fontFamily: "Plus Jakarta Sans, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Plus Jakarta Sans, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "Plus Jakarta Sans, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.4
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
  xxxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-emergency}"
    rounded: "{rounded.md}"
    padding: "14px 24px"
    height: "48px"
  button-emergency:
    backgroundColor: "{colors.emergency}"
    textColor: "{colors.on-emergency}"
    rounded: "{rounded.md}"
    padding: "14px 24px"
    height: "48px"
  button-text:
    textColor: "{colors.primary}"
    padding: "14px 16px"
    height: "48px"
  card:
    backgroundColor: "{colors.surface-light}"
    rounded: "{rounded.lg}"
    padding: "16px"
  chip:
    backgroundColor: "{colors.surface-variant-light}"
    textColor: "{colors.text-secondary-light}"
    rounded: "{rounded.full}"
    padding: "6px 12px"
  input:
    backgroundColor: "{colors.surface-variant-light}"
    textColor: "{colors.text-primary-light}"
    rounded: "{rounded.md}"
    padding: "14px 16px"
---

# Design System: Hospital App

## 1. Overview

**Creative North Star: "The Calm Corridor"**

A hospital app for people having a bad day. The user is rarely a happy one: they are stressed, in pain, accompanying a sick relative, or arriving as a first responder. The interface answers with quiet competence rather than performed reassurance — no welcome cards, no "all systems operating normally" pills, no decorative motion that delays a primary action. Plus Jakarta Sans on a near-white surface, one calm medical blue carrying primary actions, one named red carrying emergencies, and everything tappable sized for a thumb.

This system explicitly rejects three category reflexes. It is not a **sterile-corporate hospital portal** (Epic/MyChart cold blue gradients, dense gov-form layouts, accessibility-as-checkbox). It is not a **consumer-cute health app** (Duolingo mascots, confetti, every-corner-rounded cheer). It is not a **generic SaaS dashboard** (Linear/Stripe density that fits power users, not stressed first-time visitors). And it is never the **trendy AI-glow lane** (neon-on-black, decorative glassmorphism, dark-as-vibe).

The map is the product. Every other surface in the app yields to it in hierarchy, color weight, and screen real estate.

**Key Characteristics:**
- Legibility before personality — type and contrast win over style.
- One job per screen — a single primary action visible in under one second.
- Forgiving by default — 48 dp tap targets minimum, undoable actions, no destructive modals as a primary pattern.
- Quiet motion — animation clarifies cause and effect; it never decorates. Reduced-motion users opt out automatically.
- A11y is the baseline, not the bonus — WCAG 2.1 AA with elderly / low-vision treated as a primary user need.

## 2. Colors

A calm medical blue carries identity and primary actions; a health green carries secondary affordances; a named emergency red is reserved for SOS and destructive confirmations. Neutrals are warm enough not to read as government-form gray.

### Primary
- **Medical Blue** (`#0A6DC2`): the carrier of trust. Primary buttons, navigation indicators, focus rings, the map's "current floor" emphasis. Never used decoratively.
- **Medical Blue — Light** (`#3B9FE3`): the dark-theme primary; also chip-selected backgrounds in light.
- **Medical Blue — Dark** (`#074E8C`): pressed/active state and `onPrimaryContainer` text in light.
- **Primary Surface** (`#E8F4FD`): the tinted container the primary lives on top of for chips, status pills, and the linear progress track.

### Secondary
- **Health Green** (`#0E8A6D`): non-emergency vitality and positive outcomes. Used for the user-position dot on the map, "task done" confirmations, and the secondary-container family.
- **Health Green — Light / Dark / Surface** (`#2DBDA0` / `#086650` / `#F0FAF6`): the corresponding tonal triplet.

### Tertiary — Role tokens (emergency + task status)
- **Emergency Red** (`#D92D20`): the SOS hero, the logout confirm button, every destructive primary. Never decorative.
- **Emergency Active** (`#DC6803`): the orange-shifted state for "SOS in progress, dispatch en route".
- **Emergency Surface** (`#FEE4E2`): the un-filled portion of the SOS hold-to-confirm ring.
- **On Emergency** (`#FFFFFF`): text and icons that sit on a saturated emergency solid.
- **Task In Progress** (`#0A6DC2` — aliases Primary): a named alias so task-status code doesn't reach for `Colors.blue`.
- **Task Waiting** (`#B54708`): the amber-on-cream for "queue position pending".
- **Task Done** (`#067647`): the resolved-confirm green; not health green's lighter mid-tone.

### Neutral (Light)
- **Background** (`#F8F9FA`): the page surface beneath cards.
- **Surface** (`#FFFFFF`): card and sheet faces.
- **Surface Variant** (`#F1F3F5`): input fields, chips at rest, subtle dividers.
- **Border** (`#E2E8F0`) and **Border Subtle** (`#F1F3F5`): outlines on cards and inputs.
- **Text Primary / Secondary / Tertiary** (`#1A1D21` / `#4A5568` / `#94A3B8`): the three-step text hierarchy.

### Neutral (Dark)
- **Background / Surface / Surface Variant** (`#121417` / `#1E2128` / `#2A2D35`): the layered dark canvas; not pure black.
- **Text Primary / Secondary / Tertiary** (`#E2E8F0` / `#94A3B8` / `#64748B`): the inverted three-step.

### Named Rules

**The Emergency-Only Red Rule.** The emergency role colors (`#D92D20`, `#DC6803`, `#FEE4E2`) are reserved for SOS and destructive confirmations. They never appear as decoration, badge accents, marketing emphasis, or "look at this" highlights. If a red feels right anywhere else, the answer is the wrong red.

**The No-Raw-Color Rule.** Feature code never references `Colors.red / blue / green / orange / white / black` or raw `Color(0xFF…)` literals. The only legal palettes are `AppColors.*` role tokens and `context.colorScheme.*`. The single documented exception is `AppToast`, where white text sits on a saturated solid by design. The rule is documented in `analysis_options.yaml`.

**The Map Owns Green Rule.** Health Green is the user-position dot on the map and the task-done check. It does not become a status pill, an icon tint, or a generic "go ahead" highlight. The map's green earns its weight by being scarce elsewhere.

## 3. Typography

**Display Font:** Plus Jakarta Sans (with `system-ui, sans-serif` fallback)
**Body Font:** Plus Jakarta Sans
**Mono Font:** none — the system has no mono surface worth documenting.

**Character:** a humanist sans whose open apertures and slightly soft terminals read as competent without being clinical. It is not a tech-brand geometric (Inter, Söhne, Geist) and not a healthcare cliché (Lato, Open Sans). The pairing is intentionally narrow: one family, six weights, no display contrast — the hierarchy comes from size and weight only.

### Hierarchy
- **Display Large / Medium / Small** (700/600 weight, 32 / 28 / 24 px, line-height 1.2–1.3): reserved for the SOS "SOS" lettering and the auth-flow hero greetings. Not used in everyday product surfaces.
- **Headline Small** (600, 18 px, 1.4): on-card welcome headers and dialog titles.
- **Title Medium** (600, 16 px, 1.4): the workhorse — section headers ("Truy cập nhanh", "Tổng quan", "Thông báo"), AppBar titles, sheet titles.
- **Title Small** (600, 14 px, 1.4): card-section labels and chips.
- **Body Large** (400, 16 px, 1.6): the floor for primary running copy. Patient-facing instructions never go below this.
- **Body Medium** (400, 14 px, 1.6): the default body. Used for ListTile titles, button labels, dialog body.
- **Body Small** (400, 12 px, 1.5): subtitles, weather and metadata strings, secondary helper text only.
- **Label Large** (600, 14 px, 1.4): button text, chip text when selected, the SOS hero helper line.

### Named Rules

**The 16 sp Floor Rule.** Body copy that the patient reads to make a decision is never below 16 sp. 12 sp `bodySmall` is for metadata and unit suffixes (`°C`, `km/h`), not for "press X to do Y" instructions.

**The Hierarchy-By-Size-and-Weight Rule.** Hierarchy is communicated through scale (≥1.25 ratio between steps) and weight contrast. The system has no "lighter color = lower hierarchy" treatment beyond the three-step text-primary / text-secondary / text-tertiary palette. Faded grey-on-grey text is forbidden.

## 4. Elevation

This system is **flat by default with token-defined ambient shadows for true elevation moments only**. AppBars, cards at rest, chips, and inputs have `elevation: 0` and rely on a 1 px subtle border (`Border Subtle`) to separate from the page background. The token system defines three shadow recipes — `card`, `elevated`, `bottomNav` — applied only when a surface actually rises above the page (modals, sheets, dropdowns, the SOS hero glow).

### Shadow Vocabulary
- **Card** (`0 2px 8px rgba(0,0,0,0.03), 0 4px 24px rgba(0,0,0,0.02)`): a barely-there ambient that gives content cards a sense of paper, not lift. Used sparingly; most cards now use the 1 px border instead.
- **Elevated** (`0 8px 16px rgba(0,0,0,0.06), 0 16px 40px rgba(0,0,0,0.03)`): bottom sheets, modals, the SOS hero glow.
- **Bottom Nav** (`0 -4px 20px rgba(0,0,0,0.04)`): the upward-facing shadow on the persistent bottom navigation.

### Named Rules

**The Border-Before-Shadow Rule.** Surfaces at rest separate from the page with a 1 px `Border Subtle` outline, not with a shadow. Shadow is reserved for elements that have left the page — sheets, dialogs, the SOS hero ring. If a card needs a shadow to be visible, the contrast against the background is wrong.

**The Flat AppBar Rule.** AppBars are `elevation: 0`, `scrolledUnderElevation: 0.5`. The AppBar is part of the page, not a layer hovering above it.

## 5. Components

### Buttons
- **Shape:** medium radius (12 px), all variants.
- **Minimum height:** 48 dp on Elevated, Outlined, Text. IconButton hit area also 48 dp via `padding: 12, iconSize: 24`. This is a project-wide floor, not a per-button choice.
- **Primary (FilledButton/Elevated):** Medical Blue background, white-on-primary text, 14 sp 600 weight, no shadow, horizontal padding 24, vertical padding 14.
- **Emergency (FilledButton):** Emergency Red background, On-Emergency white text. Used for SOS hero confirm and logout-sheet confirm. Never for non-destructive primary actions.
- **Outlined:** Medical Blue text, 1 px `Border` outline, transparent fill.
- **Text:** Medical Blue text, no border, no fill. Used for sheet "Hủy" actions and inline footer links.

### SOS Hero (signature component)
A 180 dp circular FilledButton that requires a **1.2 s long-press** to confirm — not a tap. While held, a 196 dp `CircularProgressIndicator` ring fills around the perimeter. Releasing before completion cancels. Reduced-motion users (`MediaQuery.disableAnimations`) get a plain tap fallback. State (idle / sending / active) is differentiated by **icon shape**, not color alone: `Icons.emergency_rounded` → `Icons.hourglass_top_rounded` → `Icons.priority_high_rounded`. Outer `boxShadow` is a 24 px blur in the role color at 40% alpha.

### Cards / Containers
- **Corner Style:** large radius (16 px).
- **Background:** Surface (`#FFFFFF`) in light, Surface Dark (`#1E2128`) in dark.
- **Border:** 1 px `Border Subtle`. Shadow only when the card has lifted (sheets, modals).
- **Internal Padding:** 16 px default; 20 px for large content cards (`cardPaddingLarge`).
- **No nested cards.** A card inside a card is always wrong.

### Chips
- **Shape:** full pill (999 px radius).
- **Style:** `Surface Variant` background, `Text Secondary` 13 sp 500 weight label, 1 px `Border Subtle` outline.
- **Selected:** `Primary Surface` background, Primary text at 600 weight. No separate "filter chip" variant — chips are one thing.

### Inputs / Fields
- **Style:** filled with `Surface Variant`, no border at rest, 12 px radius, 16/14 padding.
- **Focus:** 1.5 px Medical Blue outline appears on the focused border only.
- **Error:** 1 px Emergency Red outline (and 1.5 px on focused-error).
- **Label / Hint:** 14 sp; placeholder uses `Text Tertiary`.

### Navigation (NavigationBar)
- Material 3 NavigationBar at the bottom. Surface background, Primary Surface indicator pill behind the selected icon. Selected icon Primary at 600 weight 12 sp label; unselected `Text Tertiary` at 400.
- **AppBar:** flat (`elevation: 0`), title 18 sp 600 left-aligned, **maximum two actions**: notifications + a `PopupMenuButton` overflow. The four-icon AppBar is forbidden.

### Bottom Sheet
- Drag handle 40×4 px, `Border Light` color. 20 px top-corner radius. Surface background, no surface tint. Used for non-emergency confirmation (logout, settings sub-flows) instead of `AlertDialog`.

### Map Hero (signature component)
A 180 dp full-width `MapPreviewCard` on the home screen that pushes the rest of Home below the fold. A single InkWell on the whole card routes to `/map`. The component is the literal expression of "the map is the product".

## 6. Do's and Don'ts

### Do:
- **Do** use `AppColors.emergency` for SOS and destructive primary actions. Use `AppColors.taskInProgress / taskWaiting / taskDone` for queue/task status. Use `context.colorScheme.*` for everything else.
- **Do** floor every tappable element at 48 dp. The theme already does this for `TextButton`, `ElevatedButton`, `OutlinedButton`, `IconButton` — don't override.
- **Do** wrap custom-painted, gesture-composed, or stack-built interactive widgets in `Semantics(button: true, label: …, hint: …)`. The map, the SOS hero, and notification badges all do this.
- **Do** gate decorative motion on `MediaQuery.disableAnimations`. The `FadeSlideTransition` widget already does — pass through it, don't roll your own.
- **Do** lead the home screen with a `MapPreviewCard` and demote everything else.
- **Do** differentiate state by icon shape AND color, never color alone. Active vs. resolved vs. waiting must all read with red-green color blindness.

### Don't:
- **Don't** use raw `Colors.red / blue / green / orange / white / black` or raw `Color(0xFF…)` in `lib/features/**`. The single documented exception is `AppToast`. The rule is enforced by code review and noted in `analysis_options.yaml`.
- **Don't** use `AlertDialog` as a primary confirmation pattern. Bottom sheet for non-emergency confirms; press-and-hold for the SOS confirm. The "OK / Cancel" modal is forbidden as a default.
- **Don't** ship a **sterile-corporate hospital portal** — no cold blue gradients, no dense gov-form layouts, no accessibility-as-checkbox. (PRODUCT.md anti-reference.)
- **Don't** ship a **consumer-cute health app** — no Duolingo mascots, no confetti, no every-corner-rounded cheer. (PRODUCT.md anti-reference.)
- **Don't** ship a **generic SaaS dashboard** — no Linear/Stripe density. The user is a stressed first-time visitor, not a power user. (PRODUCT.md anti-reference.)
- **Don't** ship a **trendy AI-glow / crypto aesthetic** — no neon-on-black, no decorative glassmorphism, no dark-default for vibe. (PRODUCT.md anti-reference.)
- **Don't** nest a `Card` inside a `Card`. Don't stack four-or-more `Card` siblings in one scroll page.
- **Don't** add vanity copy ("Welcome back!", "All systems operating normally", "Your health is our priority"). If removing the text wouldn't block a primary task, the text shouldn't be there.
- **Don't** put four IconButtons in an AppBar. Two actions maximum; the rest live in a `PopupMenuButton` overflow.
- **Don't** hard-code widget widths (`width: 150`) on text-bearing elements. Use `GridView` / `IntrinsicWidth` / theme spacing so the layout survives OS font scale at 200%.
- **Don't** animate page entries with delays past 200 ms. A stressed visitor isn't waiting for a choreographed reveal.
