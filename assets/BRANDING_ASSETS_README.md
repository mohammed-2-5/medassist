# MedAssist Branding Assets

This folder contains the branding assets for the MedAssist application.

## Required Assets

### App Icon
**Location:** `assets/icon/`

1. **app_icon.png** (1024x1024px)
   - Main app icon for iOS
   - Square image with transparent or branded background
   - Should feature a medical/pill themed icon
   - Recommended: Simple, recognizable design with teal (#0BA9A7) color

2. **app_icon_foreground.png** (1024x1024px)
   - Foreground layer for Android adaptive icon
   - Should be the icon design without background
   - Transparent background
   - Design should fit within the safe zone (center 432x432px)

### Splash Screen
**Location:** `assets/splash/`

1. **splash_logo.png** (1152x1152px recommended)
   - Logo shown during app launch
   - Will be centered on teal background (#0BA9A7)
   - Keep it simple and clean
   - Should work well on teal background

## Brand Colors

- **Primary (Teal):** #0BA9A7
- **Accent (Blue):** #1E88E5
- **Text on Teal:** White (#FFFFFF)

## Generating Icons and Splash

After adding the required assets, run these commands:

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Design Guidelines

### Icon Design
- Simple and memorable
- Medical/healthcare themed
- High contrast for visibility
- Works well at small sizes (48dp)
- Follows Material Design guidelines

### Splash Logo
- Clean and minimal
- Represents medication/healthcare
- Centered composition
- Should render in < 250ms

## Temporary Placeholder

Until proper assets are added, the app will:
- Use default Flutter icon
- Show teal splash screen with no logo (just background color)

## Asset Specifications

| Asset | Size | Format | Background |
|-------|------|--------|------------|
| app_icon.png | 1024x1024 | PNG | Opaque or transparent |
| app_icon_foreground.png | 1024x1024 | PNG | Transparent |
| splash_logo.png | 1152x1152 | PNG | Transparent |

## Next Steps

1. Create or commission icon designs following the guidelines above
2. Save assets in the correct locations
3. Run the generation commands
4. Test on both iOS and Android devices
5. Verify splash screen timing and appearance
