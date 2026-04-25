# Design System: The Celestial Void

## 1. Overview & Creative North Star
**Creative North Star: "The Celestial Curator"**

This design system is an exploration of "The Void"—a high-contrast, minimalist ecosystem where content floats in a boundless digital expanse. Unlike traditional apps that rely on rigid grids and heavy borders, this system uses intentional asymmetry and vast negative space to create a premium, editorial feel. 

We are moving away from "utility-first" design toward "experience-first" aesthetics. By pairing a whimsical, fairytale-inspired serif with a brutalist black-hole motif, we create a visual tension between the organic and the geometric. This system is designed to feel less like a tool and more like a curated gallery of captured media.

---

## 2. Colors & Surface Philosophy

The color logic is built on the concept of "luminous depth." We use a pure black foundation to allow secondary and tertiary elements to "glow" against the darkness.

### The Palette
- **Background (`#000000` / `surface`):** The absolute base. Everything emerges from here.
- **Primary (`#f9f9f9`):** High-contrast white used for critical typography and primary navigation.
- **Secondary (`#fd9000`):** Vibrant orange for "Hero" moments and primary calls to action.
- **Tertiary (`#a0e0ff`):** A soft light blue reserved strictly for links and interactive pathways.
- **Utility Icons:** Muted sage green (`outline-variant` logic) to keep secondary utilities from distracting the eye.

### Critical Rules for Layout
*   **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. To define a boundary, use a shift in surface tone (e.g., placing a `surface-container-low` card on a `surface` background). 
*   **Surface Hierarchy & Nesting:** Treat the UI as a series of stacked layers. Use the `surface-container` tiers (Lowest to Highest) to create depth. For instance, a video preview card should use `surface-container-high` to naturally "lift" off the pure black background without needing a stroke.
*   **Signature Textures:** For primary CTA buttons, utilize a subtle radial gradient transitioning from `secondary` (`#fd9000`) to `secondary_container` (`#8e4e00`) to simulate the glowing edge of an event horizon.

---

## 3. Typography: The Storyteller’s Hand

The typography scale is a dialogue between the whimsical and the functional.

*   **Display & Headline (Noto Serif / Fairytale Custom):** Used for titles and filenames. This whimsical serif breaks the coldness of the black background, giving the app a "storybook" quality. It suggests that every downloaded video is a story being saved.
*   **Body (Noto Serif):** Maintains the editorial feel for longer descriptions, ensuring the whimsical nature of the brand remains consistent.
*   **Labels (Plus Jakarta Sans):** For technical data—file sizes, timestamps, and utility labels—we switch to a clean, geometric sans-serif. This provides a clear "functional" layer that contrasts with the "narrative" layer of the filenames.

---

## 4. Elevation & Depth: Tonal Layering

Shadows in "The Void" are not grey; they are an absence of light.

*   **The Layering Principle:** Rather than using shadows for every element, rely on the `surface-container` tokens. An element with higher importance simply uses a lighter shade of black/dark grey (`surface-bright`).
*   **Ambient Shadows:** When a floating effect is required (e.g., the central download sphere), use a shadow with a blur radius of 40px+ at 8% opacity, using a tint of the `on-surface` color.
*   **Glassmorphism:** For overlays or navigation bars, use `surface` at 60% opacity with a `20px backdrop-blur`. This allows the "void" behind the element to remain visible, maintaining the sense of infinite space.
*   **The Ghost Border:** If accessibility requires a container edge, use the `outline-variant` token at 15% opacity. It should be felt, not seen.

---

## 5. Components

### The "Event Horizon" Button (Primary)
*   **Shape:** Purely spherical (`rounded-full`).
*   **Color:** Radial gradient from `secondary` to `secondary_dim`.
*   **Interaction:** On press, the gradient expands, mimicking an intake of light.
*   **Usage:** The main action button (e.g., the "Download" trigger).

### Content Cards
*   **Style:** No borders. Use `surface-container-low`. 
*   **Spacing:** High internal padding (`1.5rem`) to ensure the whimsical serif titles have "room to breathe."
*   **Dividers:** Forbidden. Use `2rem` of vertical white space to separate list items.

### Geometric Dot-Grid Icons
*   **Style:** Icons must be constructed from a geometric dot-grid pattern rather than solid paths. This reinforces the "celestial/digital" theme.
*   **Color:** Sage green for utility (Settings, Info) and Orange for active states.

### Input Fields
*   **Style:** A single `primary` line or a subtle `surface-container-highest` background. 
*   **Typography:** The whimsical serif should be used for the input text to make the act of "pasting a link" feel like writing in a journal.

---

## 6. Do's and Don'ts

### Do:
*   **Embrace the Void:** Use more negative space than you think you need. A single button in the center of a black screen is a feature, not a bug.
*   **Use Tonal Shifts:** Distinguish between a "Read" and "Unread" video file solely by shifting the title from `primary` (white) to `on-surface-variant` (grey).
*   **Asymmetric Layouts:** Allow titles to be left-aligned while utility icons are offset to the right, breaking the expected grid.

### Don't:
*   **Don't use Dividers:** Never use a line to separate content. If it feels cluttered, increase the padding.
*   **Don't use Box Shadows:** Avoid heavy, 90s-style drop shadows. Stick to tonal layering or extremely soft ambient glows.
*   **Don't use Standard Sans-Serif for Titles:** Using a standard font like Arial or Helvetica for filenames will break the "Celestial Curator" magic. Stick to the fairytale serif.
*   **Don't Overuse Orange:** The secondary color is a "flash of light." If more than 10% of the screen is orange, you have lost the high-contrast impact.