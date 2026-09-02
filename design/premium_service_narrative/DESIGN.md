---
name: Premium Service Narrative
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#454652'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#767683'
  outline-variant: '#c6c5d4'
  surface-tint: '#4c56af'
  primary: '#000666'
  on-primary: '#ffffff'
  primary-container: '#1a237e'
  on-primary-container: '#8690ee'
  inverse-primary: '#bdc2ff'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#380b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#5c1800'
  on-tertiary-container: '#e17c5a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#343d96'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#ffdbd0'
  tertiary-fixed-dim: '#ffb59d'
  on-tertiary-fixed: '#390c00'
  on-tertiary-fixed-variant: '#7b2e12'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
  charcoal-text: '#121212'
  slate-body: '#4B5563'
  success-green: '#2E7D32'
  verified-blue: '#2D5BFF'
  border-light: '#E5E7EB'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  stat-lg:
    fontFamily: Hanken Grotesk
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  label-caps:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  margin-mobile: 20px
  margin-desktop: 64px
  gutter: 16px
  section-gap: 32px
  component-padding: 24px
---

## Brand & Style

This design system embodies **Corporate Minimalism** with a focus on premium utility. It shifts from a purely functional marketplace to a high-end service platform that emphasizes individual expertise and institutional reliability. The aesthetic is defined by extreme cleanliness, high-contrast typography, and a "human-centered" layout that prioritizes the service provider as the centerpiece of the experience.

The design should evoke a sense of professional excellence and frictionless interaction. It utilizes heavy whitespace to reduce cognitive load and premium glass-like or soft-layered surfaces to suggest a modern, technologically-advanced cooperative. The tone is confident, sophisticated, and transparent.

## Colors

The palette is anchored in a high-end, editorial aesthetic. 
- **Primary (Deep Navy):** Used for critical actions, headers, and navigation to establish a foundation of authority and stability.
- **Secondary (Forest Green):** Reserved exclusively for "Verified," "Available," and "Success" states, providing a clear, positive signal.
- **Neutral (Snow & Ice):** A combination of pure white surfaces on very light gray backgrounds to create depth without relying on heavy shadows.
- **Typography:** Uses a strict "Charcoal" (#121212) for headlines to ensure maximum impact and a "Slate" (#4B5563) for body text to maintain a soft, premium feel.

## Typography

This system uses **Hanken Grotesk** for headings and statistics to project a sharp, modern, and technical edge, paired with **Inter** for body text to ensure peerless legibility across all mobile devices.

- **Statistical Emphasis:** Numbers (earnings, ratings, distance) are treated as primary visual elements using `stat-lg`.
- **Hierarchical Scan-paths:** Large, bold headers are used for worker names and service titles to allow users to navigate quickly by skimming.
- **Micro-copy:** Small caps labels are used for secondary data metadata to maintain a clean, organized grid.

## Layout & Spacing

The layout is **Human-Centered and Mobile-First**, utilizing generous whitespace to create a "breathable" interface.

- **Grid Model:** A 4-column fluid grid for mobile and a 12-column fixed centered grid (max-width 1200px) for desktop.
- **Spacing Rhythm:** Based on an 8px scale. `component-padding` (24px) is the standard for card internals to ensure data doesn't feel cramped.
- **Safe Zones:** Mobile layouts must respect a 20px lateral margin. Sections are separated by a 32px gap to clearly distinguish between different data sets (e.g., Profile vs. Statistics vs. Reviews).

## Elevation & Depth

Hierarchy is achieved through **Tonal Layers** and **Low-Contrast Outlines**.

- **Surface 0 (Background):** A clean, off-white (#F8F9FA) canvas.
- **Surface 1 (Cards):** Pure white (#FFFFFF) containers with a 1px subtle border (#E5E7EB).
- **Depth:** Instead of traditional heavy shadows, use extremely soft, large-radius ambient shadows (Blur: 24px, Opacity: 4%, Color: Navy) to make cards appear as if they are floating slightly above the surface.
- **Glassmorphism:** Use backdrop blurs (20px) on sticky headers and navigation bars to maintain context of the content scrolling underneath.

## Shapes

The design uses a **Pill-shaped and Large-Rounded** language to appear modern and friendly.

- **Primary Containers:** Large cards must use a minimum of 24px (rounded-xl) corner radius to create a distinct, soft-tech aesthetic.
- **Interactive Elements:** Buttons, chips, and filters are fully pill-shaped (radius: 999px) to differentiate them from content containers.
- **Avatars:** Use a 50% circular radius with a 2px white "halo" border when overlapping background imagery.

## Components

- **Statistics Cards:** Large white containers with `stat-lg` numbers. Labels are placed beneath the value in `label-caps` Slate text. These should be arranged in a horizontal scroll or a 2x2 grid on mobile.
- **Pill Buttons:** Primary CTA buttons are Deep Navy with White text, fully pill-shaped, and high-reaching (min-height 52px).
- **Service Chips:** Use a light gray background with Charcoal text for filters; active filters toggle to Deep Navy background.
- **Verification Badges:** An elegant circular badge in `verified-blue` or `success-green` featuring a checkmark. For "Cooperative" badges, use a gold/indigo combination with a subtle metallic gradient.
- **Profile Headers:** Feature a wide-format background image with a circular avatar overlapping the bottom-left corner, followed immediately by the name in `headline-lg`.
- **Inputs:** Clean, borderless appearances with a light gray background fill and 16px internal padding, shifting to a Navy 1px stroke on focus.