---
name: Bubbly Habit Tracker
colors:
  surface: '#f7fafe'
  surface-dim: '#d7dade'
  surface-bright: '#f7fafe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f8'
  surface-container: '#ebeef2'
  surface-container-high: '#e5e8ec'
  surface-container-highest: '#e0e3e7'
  on-surface: '#181c1f'
  on-surface-variant: '#404850'
  inverse-surface: '#2d3134'
  inverse-on-surface: '#eef1f5'
  outline: '#707881'
  outline-variant: '#bfc7d1'
  surface-tint: '#006399'
  primary: '#005d90'
  on-primary: '#ffffff'
  primary-container: '#0077b6'
  on-primary-container: '#f3f7ff'
  inverse-primary: '#94ccff'
  secondary: '#006875'
  on-secondary: '#ffffff'
  secondary-container: '#9cecfb'
  on-secondary-container: '#016d7a'
  tertiary: '#006176'
  on-tertiary: '#ffffff'
  tertiary-container: '#007c95'
  on-tertiary-container: '#ecf9ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cde5ff'
  primary-fixed-dim: '#94ccff'
  on-primary-fixed: '#001d32'
  on-primary-fixed-variant: '#004b74'
  secondary-fixed: '#9feffe'
  secondary-fixed-dim: '#83d3e1'
  on-secondary-fixed: '#001f24'
  on-secondary-fixed-variant: '#004f59'
  tertiary-fixed: '#b3ebff'
  tertiary-fixed-dim: '#4cd6fb'
  on-tertiary-fixed: '#001f27'
  on-tertiary-fixed-variant: '#004e5f'
  background: '#f7fafe'
  on-background: '#181c1f'
  surface-variant: '#e0e3e7'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  margin-mobile: 20px
  margin-desktop: 48px
  gutter: 16px
---

## Brand & Style

The visual identity of this design system centers on the concept of "Effortless Flow." It is designed for individuals seeking a stress-free path to self-improvement, emphasizing positive reinforcement over rigid discipline. The emotional response is one of calm, clarity, and optimism—evoking the feeling of a serene ocean breeze.

The style is a hybrid of **Minimalism** and **Tactile Softness**. By combining generous whitespace with "squishy," approachable elements, the UI feels responsive and friendly. It avoids sharp edges and harsh contrasts to ensure the user feels encouraged rather than pressured during their habit-tracking journey.

## Colors

The palette is derived from sea-level gradients, moving from deep water blues to light coastal foams. 

- **Primary (#0077B6):** Used for active states, primary buttons, and successful habit completions.
- **Secondary (#90E0EF):** Used for soft accents, progress bar backgrounds, and secondary interactions.
- **Surface & Backgrounds:** The design system utilizes a tiered background strategy. Pure white (#FFFFFF) is used for the base canvas, while a very light Sea Foam (#CAF0F8) or Ice Blue (#F8FBFF) is used for cards and grouped content to create subtle containment without heavy borders.
- **Success/Warning:** While predominantly blue, functional success states should lean into a slightly more cyan-tinted blue to distinguish from the brand primary.

## Typography

The typography uses **Plus Jakarta Sans** for its modern, rounded terminals and friendly proportions. This choice reinforces the "bubbly" nature of the design system.

- **Headlines:** Set with tight tracking and bold weights to provide a strong anchor for each screen.
- **Body Text:** Uses a slightly more generous line height to ensure readability and a sense of "airiness" within the layout.
- **Labels:** Uppercase styles should be used sparingly for small metadata to maintain a clean, uncluttered look.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model that prioritizes organic grouping over rigid columns. 

- **Rhythm:** An 8px base unit drives all padding and margins. 
- **Breathing Room:** Significant vertical spacing (LG/XL) is encouraged between major sections to mimic the openness of the sea.
- **Containment:** Content should be grouped in soft-edged containers with a standard 24px (MD) internal padding to ensure elements never feel cramped.
- **Mobile First:** Given the habit-tracking nature, the layout should prioritize a single-column thumb-friendly stack with elements easily reachable within a 48px to 56px height range.

## Elevation & Depth

This design system avoids heavy drop shadows in favor of **Ambient Shadows** and **Tonal Layers**.

- **Shadow Character:** Shadows are extremely diffuse and tinted with the primary blue hue (`rgba(0, 119, 182, 0.08)`). This prevents the UI from looking "dirty" and instead makes elements appear to float gently on the surface.
- **Tonal Stacking:** Depth is primarily communicated through color. A background starts at White, a card sits on top in Light Blue (#CAF0F8), and an active element (like a habit button) sits on top of that with a soft shadow.
- **Focus:** Interactive elements should slightly scale up (e.g., 1.02x) when pressed or hovered, rather than drastically changing shadow depth, maintaining the tactile "bubbly" feel.

## Shapes

The shape language is consistently high in roundedness to evoke the smoothness of river stones or bubbles.

- **Standard Elements:** Cards, input fields, and modals use a `rounded-lg` (16px/1rem) radius.
- **Interactive Elements:** Buttons and habit-tracking chips often utilize a full pill-shape (`rounded-full`) to encourage tapping.
- **Iconography:** Icons should feature rounded caps and corners, avoiding any 90-degree angles.

## Components

- **Habit Bubbles:** The core component. These are large, circular or pill-shaped buttons that use a semi-transparent primary blue fill. Upon completion, they transition to a solid primary blue with a subtle inner glow.
- **Fluid Buttons:** Primary buttons should have a subtle gradient (Primary to Tertiary) and a soft shadow. They should feel "pressable" and "soft."
- **Soft Cards:** Cards should have no borders. Instead, use a light blue background and a very soft, spread-out ambient shadow.
- **Progress Rings:** Use a thick stroke with rounded end-caps. The background of the track should be a very pale version of the primary color (#CAF0F8).
- **Input Fields:** Use a solid light background (#F8FBFF) instead of an outline. On focus, a 2px soft-blue shadow should appear rather than a hard border.
- **Chips & Tags:** Small, pill-shaped elements for categorizing habits (e.g., "Health," "Mindfulness") using low-saturation versions of the sea-blue palette.