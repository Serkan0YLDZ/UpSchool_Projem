---
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: '1.6'
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 20px
  margin: 24px
---

## Brand & Style

This design system is built on the principles of Neo-brutalism, optimized for a habit-tracking and calendar environment. It rejects the soft, airy aesthetic of modern SaaS in favor of high-impact visual structures. The brand personality is unapologetically bold, utilizing raw structural elements to create a sense of urgency and accomplishment. 

The UI should feel tactile and physical, like a digital sticker book or a physical planner. It uses aggressive contrast and structural honesty—where borders and shadows are not just accents, but the primary architecture of the interface. This approach transforms routine habit tracking into a high-energy, gamified experience that feels both sturdy and expressive.

## Colors

The palette is centered around a high-contrast relationship between deep blues and pure black structural elements. 

- **Primary Container (#0077B6):** Used for active states, primary call-to-actions, and successful habit completions.
- **Tertiary Fixed (#9FEFFE):** Used for secondary highlights, progress bars, and calendar "today" markers to provide a vibrant contrast against the primary blue.
- **Background (#F8FBFF):** A very light cool tint that prevents the starkness of pure white while allowing the thick black borders to pop.
- **Structural Black (#000000):** Used exclusively for borders, hard shadows, and typography to maintain the brutalist hierarchy.

## Typography

This design system utilizes **Plus Jakarta Sans** across all levels to maintain a contemporary, geometric feel. 

Headings must always use **Bold (700)** or **ExtraBold (800)** weights to compete with the heavy 4px borders. For display text, a slight negative letter spacing is encouraged to create a "tight" editorial look. Body text should remain at a medium weight (500) to ensure readability against vibrant background containers. Labels and utility text often utilize uppercase styling to reinforce the structural, technical nature of the calendar grid.

## Layout & Spacing

The layout follows a **fluid grid system** with rigid gutters. Because the design system relies on heavy borders and shadows, whitespace is not used for "breathability" but rather for "separation."

- **Grid:** A 12-column grid for desktop and a 4-column grid for mobile.
- **Rhythm:** Spacing is based on a 4px baseline.
- **The Sticker Effect:** Containers should not always align perfectly to the grid; small, intentional "sticker-style" rotations (between -1deg and +1deg) should be applied to cards and floating elements to break the digital perfection.

## Elevation & Depth

Depth in this design system is purely structural and avoids all blurs or gradients. 

Hierarchy is communicated through **Hard Shadows**:
- All primary cards and buttons feature a **6px 6px 0px #000000** offset shadow.
- When an element is "pressed" or "active," the shadow should transition to **2px 2px 0px #000000**, simulating the physical compression of the button against the surface.
- Layering is achieved by stacking containers with identical 3px-4px black borders, creating a "comic book" paneled effect rather than a traditional Z-axis depth.

## Shapes

The shape language is a mix of high-rigidity and playful curvature. 

Every container, button, and input field must feature **rounded corners (xl / 1.5rem)**. This softness contrasts with the aggressive **4px black borders**. 

For "Sticker-rotate" components:
- Top-level cards should have a random or alternating rotation of **-1.5° or +1.5°**.
- Internal elements like input fields or smaller chips should remain at **0°** for readability and functional alignment.
- Selection states (checkboxes/radio buttons) should use sharp corners or extreme pill shapes to distinguish them from the main container logic.

## Components

### Buttons
Primary buttons use the Primary Container color (#0077B6) with a 4px black border and the signature 6px hard shadow. Text is white and bold. On hover, the button tilts slightly. On click, the shadow shrinks to 2px.

### Cards & Habit Trackers
Habit cards use a White (#FFFFFF) background with 4px borders. When a habit is marked "complete," the background flips to Primary Container or Tertiary Fixed. Use the asymmetrical "sticker-rotate" for cards in a dashboard view.

### Input Fields
Inputs use the Background color (#F8FBFF) for the fill, a 3px black border, and a 6px hard shadow. The placeholder text is a muted black. Upon focus, the border thickness remains, but the shadow color could shift to a branded blue or stay black for consistency.

### Calendar Grid
The calendar uses 3px borders to separate days. The "current day" is indicated by a Tertiary Fixed (#9FEFFE) box with a 4px border, slightly rotated to stand out from the rigid monthly grid.

### Chips & Tags
Used for categorizing habits. These use a Pill-shape (rounded-full), 3px borders, and no shadows to keep them visually subordinate to primary cards. Apply various rotations to a group of chips to create a "scattered" aesthetic.