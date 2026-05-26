# Product

## Register

product

## Users

Primary: **patients and visitors** navigating an unfamiliar hospital — often stressed, in pain, time-pressured, or accompanying a sick relative. Phone held one-handed while walking corridors. Indoor wayfinding where GPS is unreliable is the highest-value job.

Secondary: **caregivers and family** coordinating on behalf of a patient (parking, appointments, finding a ward). Mixed digital literacy; sometimes elderly.

Tertiary: **first-responder / SOS scenarios** — emergency context where the screen must be glanceable, friction-free, and forgiving.

Hospital staff are not a primary target for this app's UI; staff tooling lives elsewhere.

## Product Purpose

Make a hospital legible from the moment someone arrives. Indoor navigation that works without GPS, plus the small ancillary tasks (parking, weather, SOS, info hub, account) the same person needs while on site. Success looks like a stressed first-time visitor finding the right ward in under two minutes without asking staff for directions.

## Brand Personality

**Calm, trustworthy, clear.** Quietly competent. Reduces anxiety rather than performing reassurance. Feels like a well-run hospital — not a tech company, not a wellness app, not a government portal.

Voice: plain, direct, never clever. Acknowledges that the user is probably having a bad day without saying so.

## Anti-references

- **Sterile-corporate hospital portals** (Epic / MyChart, generic gov-form aesthetics). Cold blue gradients, dense forms, clinical jargon, a11y treated as a checkbox.
- **Consumer-cute health apps** (Duolingo-style mascots, confetti, every-corner-rounded, cheerful illustrations). Inappropriate for medical context.
- **Generic SaaS dashboards** (Linear/Stripe clones). Power-user density does not fit stressed first-time visitors.
- **Trendy AI-glow / crypto aesthetics** (neon-on-black, decorative glassmorphism, dark-default for vibe). Reflex-reject lane; many absolute bans.

## Design Principles

1. **Legibility before personality.** A stressed visitor reading at arm's length in bright atrium light must be able to see and parse every primary action. Style decisions lose to legibility decisions.
2. **One job per screen.** Each screen has a single primary action that a first-time user can identify in under one second. Secondary actions are quieter, not hidden but not competing.
3. **The map is the product.** Navigation is the spine. Everything else (parking, weather, info, settings) is a side affordance and should yield in hierarchy, color weight, and surface area.
4. **Forgiving by default.** Big tap targets, generous spacing, undoable actions, no destructive confirmation modals as a primary pattern. Assume the user is tired, one-handed, or holding a child.
5. **Quiet motion, honest states.** Motion clarifies cause and effect (route preview, transitions between zoom levels). It never decorates. Loading, empty, and error states are first-class, not afterthoughts.

## Accessibility & Inclusion

Target: **WCAG 2.1 AA, with elderly / low-vision treated as a primary user need rather than an edge case.**

- Minimum tap target 48×48 dp; default closer to 56 for primary actions.
- Body text floor 16 sp; primary action labels 18 sp+. Support OS font scaling up to 200% without layout breakage.
- Color-contrast ratio ≥ 4.5:1 for text, ≥ 3:1 for non-text UI; never rely on color alone to convey state.
- Respect `MediaQuery.disableAnimations` / reduced-motion preference; provide non-animated fallbacks for route previews, transitions, and any decorative motion.
- All interactive elements reachable by screen reader with meaningful semantics labels (Flutter `Semantics`).
- SOS path must be operable with one thumb, in under two taps, regardless of auth state.
