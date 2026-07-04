<!-- TEMPLATE INSTRUCTIONS
  FILE: ASSETS.md
  PURPOSE: Central inventory of all assets required by the project. Tracks what is needed,
           what exists, what is a placeholder, and what still needs to be created.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [ASSET_CATEGORY] with your asset categories (e.g., "Character Sprites", "UI Icons").
  - Replace [ASSET_NAME], [FORMAT], [SIZE], [NOTES] with specifics for each asset.
  - Replace [PLATFORM] with the platforms your project targets.
  - Update the Summary table as assets are completed.
  - Mark the "Exists" column with: Yes / No / Placeholder.
  - Add rows to any section as needed; add entirely new sections if your project has unique asset types.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Asset Inventory

---

## Summary

| Category | Needed | Exists | Remaining |
|----------|--------|--------|-----------|
| App Icons & Branding | | | |
| Visual Assets | | | |
| **Total** | | | |

---

## App Icons & Branding

Specifications for icons and brand assets required for submission and display.

| Asset | Format | Size(s) | Exists | Notes |
|-------|--------|---------|--------|-------|
| App Icon | [FORMAT] | [SIZE] | | |
| Adaptive Icon (foreground) | [FORMAT] | [SIZE] | | |
| Adaptive Icon (background) | [FORMAT] | [SIZE] | | |
| Splash / Loading Screen Image | [FORMAT] | [SIZE] | | |
| Favicon (web) | [FORMAT] | [SIZE] | | |

---

## Visual Assets

Sprites, illustrations, backgrounds, and other [DOMAIN_ENTITY]-related visual content.

| Asset Name | Category | Format | Size | Exists | Notes |
|------------|----------|--------|------|--------|-------|
| [ASSET_NAME] | [ASSET_CATEGORY] | [FORMAT] | [SIZE] | | |
| [ASSET_NAME] | [ASSET_CATEGORY] | [FORMAT] | [SIZE] | | |
| [ASSET_NAME] | [ASSET_CATEGORY] | [FORMAT] | [SIZE] | | |

### Visual Asset Style Guide

| Property | Specification |
|----------|--------------|
| Style | [e.g., pixel art, flat vector, illustrated] |
| Dimensions | [e.g., 64×64, 128×128] |
| Color depth | [e.g., 32-bit RGBA] |
| Format | [e.g., PNG with transparency] |
| Naming convention | [e.g., `category_name_variant.ext`] |

---

## Existing Placeholder Inventory

Assets that exist in the project as placeholders and need to be replaced with final versions.

| Asset | Location | Replace With | Priority |
|-------|----------|-------------|----------|
| [ASSET_NAME] | `[path/to/file]` | [Description of final asset] | High / Medium / Low |
| [ASSET_NAME] | `[path/to/file]` | [Description of final asset] | High / Medium / Low |

---

## Placeholder Characters / Icons in Code

Locations in the codebase where emoji, Unicode symbols, or placeholder glyphs are used in place of final visual assets.

| Location | Current Placeholder | Final Asset | Priority |
|----------|--------------------|-----------| ----------|
| `[path/to/file]` | [emoji or symbol] | [Asset description] | High / Medium / Low |
| `[path/to/file]` | [emoji or symbol] | [Asset description] | High / Medium / Low |

---

_Last updated: [YYYY-MM-DD]_
