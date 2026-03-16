# 🎨 UI/UX Design Specifications - ArchitectHub

## Overview

ArchitectHub follows a modern, clean design language with a focus on usability and visual hierarchy. The design system emphasizes clarity, accessibility, and professional aesthetics suitable for construction and architecture professionals.

## Design Principles

### 1. Clarity First

- Clear information hierarchy
- Readable typography at all sizes
- High contrast for important elements
- Minimalist approach to reduce cognitive load

### 2. Professional & Modern

- Clean lines and structured layouts
- Professional color palette
- Consistent spacing and alignment
- Modern UI patterns

### 3. Mobile-First

- Touch-friendly targets (minimum 44pt)
- Thumb-friendly navigation
- Responsive layouts
- Optimized for one-handed use

### 4. Data Visualization

- Clear charts and graphs
- Intuitive progress indicators
- Color-coded status systems
- Real-time data updates

## Color System

### Primary Colors

```
Primary Blue: #2563EB
- Used for: Primary actions, navigation highlights, key indicators
- Variations:
  - Light: #3B82F6
  - Dark: #1E40AF
  - Tint (10%): #2563EB1A
  - Tint (20%): #2563EB33
```

### Secondary Colors

```
Success Green: #10B981
- Used for: Completed status, positive actions, success states
- Context: Completion badges, success messages

Warning Amber: #F59E0B
- Used for: Pending items, caution states, attention needed
- Context: Pending badges, warnings

Error Red: #EF4444
- Used for: Critical alerts, errors, dangerous actions
- Context: Emergency buttons, error messages

Info Blue: #3B82F6
- Used for: Informational elements, in-progress states
- Context: Info badges, progress indicators
```

### Neutral Colors

```
Background: #F8FAFC - Main app background
Surface: #FFFFFF - Card backgrounds, containers
Text Primary: #1E293B - Main text content
Text Secondary: #64748B - Supporting text, labels
Border: #E2E8F0 - Dividers, borders
Disabled: #CBD5E1 - Disabled states
```

## Typography

### Font Family

- Primary: System default (San Francisco iOS, Roboto Android)
- Weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

### Text Styles

```
H1 - Hero Headers
- Size: 32px
- Weight: 700 (Bold)
- Line Height: 40px
- Usage: Screen titles, major headings

H2 - Section Headers
- Size: 24px
- Weight: 600 (SemiBold)
- Line Height: 32px
- Usage: Card titles, section headings

H3 - Subsection Headers
- Size: 20px
- Weight: 600 (SemiBold)
- Line Height: 28px
- Usage: List item titles, sub-sections

H4 - Small Headers
- Size: 18px
- Weight: 600 (SemiBold)
- Line Height: 24px
- Usage: Card headers, modal titles

Body - Standard Text
- Size: 16px
- Weight: 400 (Regular)
- Line Height: 24px
- Usage: Main content, descriptions

Body Small - Supporting Text
- Size: 14px
- Weight: 400 (Regular)
- Line Height: 20px
- Usage: Secondary information, metadata

Caption - Tiny Text
- Size: 12px
- Weight: 400 (Regular)
- Line Height: 16px
- Usage: Timestamps, labels, hints

Button Text
- Size: 16px
- Weight: 600 (SemiBold)
- Line Height: 24px
- Usage: Button labels, CTAs
```

## Spacing System

Based on 8px grid system:

```
xs: 4px   - Tight spacing, related elements
sm: 8px   - Small gaps, list items
md: 16px  - Standard spacing, card padding
lg: 24px  - Section spacing, margins
xl: 32px  - Large sections, top/bottom padding
xxl: 48px - Hero sections, major dividers
```

## Border Radius

```
sm: 4px   - Small elements, tags
md: 8px   - Standard cards, buttons
lg: 12px  - Large cards, modals
xl: 16px  - Hero sections, images
round: 999px - Circular elements (avatars, dots)
```

## Shadows & Elevation

### Small Shadow (Level 1)

```
shadowColor: #000
shadowOffset: { width: 0, height: 2 }
shadowOpacity: 0.1
shadowRadius: 4
elevation: 2

Usage: List items, small cards
```

### Medium Shadow (Level 2)

```
shadowColor: #000
shadowOffset: { width: 0, height: 4 }
shadowOpacity: 0.15
shadowRadius: 8
elevation: 4

Usage: Cards, floating buttons
```

### Large Shadow (Level 3)

```
shadowColor: #000
shadowOffset: { width: 0, height: 8 }
shadowOpacity: 0.2
shadowRadius: 16
elevation: 8

Usage: Modals, FABs, important elements
```

## Component Specifications

### 1. Cards

```
Background: #FFFFFF (Surface)
Border Radius: 12px (lg)
Padding: 16px (md)
Shadow: Medium
Margin: 16px bottom
```

### 2. Buttons

**Primary Button**

```
Background: #2563EB (Primary)
Text Color: #FFFFFF (Surface)
Border Radius: 12px (lg)
Padding: 16px vertical, 24px horizontal
Height: 48px minimum
Shadow: Medium
Font: 16px SemiBold
```

**Secondary Button**

```
Background: #FFFFFF (Surface)
Text Color: #2563EB (Primary)
Border: 1px solid #2563EB
Border Radius: 12px (lg)
Padding: 16px vertical, 24px horizontal
Height: 48px minimum
Font: 16px SemiBold
```

**Icon Button**

```
Size: 40x40px
Border Radius: 8px (md)
Background: Primary + 10% opacity
Icon Color: Primary
```

### 3. Input Fields

```
Background: #FFFFFF (Surface)
Border: 1px solid #E2E8F0 (Border)
Border Radius: 8px (md)
Height: 48px
Padding: 12px horizontal
Font: 16px Regular
Focus Border: #2563EB (Primary)
```

### 4. Status Badges

```
Padding: 8px horizontal, 4px vertical
Border Radius: 8px (md)
Font: 12px SemiBold
Background: Status color + 20% opacity
Text: Status color (100%)

Status Colors:
- In Progress: #3B82F6
- Completed: #10B981
- Pending: #F59E0B
- On Hold: #EF4444
```

### 5. Progress Bars

```
Height: 8px (standard), 12px (large)
Border Radius: 4px (sm)
Background: #E2E8F0 (Border)
Fill: #2563EB (Primary)
Overflow: hidden
```

### 6. Navigation Tabs

```
Height: 60px (bottom tabs)
Background: #FFFFFF (Surface)
Active Color: #2563EB (Primary)
Inactive Color: #64748B (Text Secondary)
Icon Size: 24px
Label: 12px Medium
Border Top: 1px solid #E2E8F0
```

### 7. FAB (Floating Action Button)

```
Size: 56x56px
Border Radius: 999px (round)
Background: #2563EB (Primary)
Icon: 28px, #FFFFFF
Shadow: Large
Position: Bottom right, 24px margin
```

## Screen-Specific Designs

### Dashboard Screen

**Layout:**

- Hero section with gradient background
- 2x2 statistics grid
- Quick actions (2x2 grid)
- Recent projects list
- Alerts section

**Key Elements:**

- Stat cards with left border accent
- Icon-based quick actions
- Swipeable project cards
- Color-coded alerts

### Projects Screen

**Layout:**

- Search bar with add button
- Horizontal filter chips
- Vertical scrolling list
- Project cards with images

**Key Elements:**

- Search with icon
- Pill-style filters
- Image placeholders (140px height)
- Progress bars
- Action buttons

### Project Detail Screen

**Layout:**

- Header image (180px height)
- Tab navigation (4 tabs)
- Scrollable content
- Quick action grid

**Key Elements:**

- Overlay text on header
- Tab indicators
- Info list with icons
- Action cards (3 columns)

### Analytics Screen

**Layout:**

- Metric cards (2x2 grid)
- Chart sections
- Status distribution
- Top performers list

**Key Elements:**

- Trend indicators
- Line/bar charts
- Progress bars
- Export button

## Iconography

### Icon Library

- **Library**: Material Community Icons
- **Sizes**: 16px (small), 20px (standard), 24px (large), 32px (hero)
- **Colors**: Follow text or primary color guidelines

### Common Icons

```
Dashboard: view-dashboard
Projects: office-building
Map: map-marker
Tasks: format-list-checks
Security: shield-check
Maintenance: tools
Analytics: chart-line
Profile: account
Add: plus
Edit: pencil
Delete: delete
Camera: camera
Calendar: calendar
Location: map-marker
```

## Interaction Design

### Touch Targets

- Minimum size: 44x44pt (iOS) / 48x48dp (Android)
- Spacing between targets: 8px minimum
- Button height: 48px minimum

### Gestures

- **Tap**: Primary action
- **Long Press**: Contextual menu (future)
- **Swipe**: Navigation, dismiss
- **Pull to Refresh**: Update data

### Feedback

- **Visual**: Color change, scale animation
- **Haptic**: Light feedback on important actions
- **Toast**: Success/error messages (3 seconds)
- **Loading**: Spinner or skeleton screens

### Transitions

- **Screen transitions**: Slide (250ms ease-out)
- **Modal presentation**: Fade + scale (200ms)
- **List items**: Fade in (150ms)
- **Button press**: Scale 0.95 (100ms)

## Accessibility

### Color Contrast

- Text/Background: Minimum 4.5:1 (WCAG AA)
- Large Text: Minimum 3:1
- Interactive elements: Clear visual feedback

### Text

- Minimum size: 12px (with good contrast)
- Recommended: 14px+ for body text
- Line height: 1.5x font size minimum

### Touch Targets

- Minimum: 44x44pt clickable area
- Clear visual boundaries
- Adequate spacing

## Responsive Design

### Breakpoints

```
Small phones: < 375px width
Standard phones: 375-414px
Large phones: 414-480px
Tablets: > 480px
```

### Adaptations

- 2-column grids on larger devices
- Wider margins on tablets
- Larger text on tablets
- More content per view

## Animation Principles

### Timing

- Quick: 100-150ms (small element changes)
- Standard: 200-250ms (screen transitions)
- Slow: 300-400ms (complex animations)

### Easing

- **Ease-out**: Most UI animations (deceleration)
- **Ease-in-out**: Smooth beginning and end
- **Spring**: Natural feeling (iOS native)

## Assets & Resources

### Image Guidelines

- Format: PNG (icons), JPEG (photos)
- Resolution: @2x and @3x for iOS
- Optimization: Compress all images
- Max file size: 200KB per image

### Icons

- Vector format preferred
- Consistent weight (2px stroke)
- Aligned to pixel grid
- Single color for flexibility

## Design Tokens

All design values are centralized in `src/theme/theme.ts`:

```typescript
export const theme = {
  colors: {...},
  spacing: {...},
  borderRadius: {...},
  typography: {...},
  shadows: {...},
};
```

## Future Enhancements

### Planned Features

- Dark mode support
- Custom themes per user
- Accessibility mode (high contrast)
- Animation preferences
- Landscape layouts for tablets
- Split-screen support

### Design System Evolution

- Component library documentation
- Storybook integration
- Design token automation
- Figma design system sync

---

**Version**: 1.0.0  
**Last Updated**: March 7, 2026  
**Maintained by**: ArchitectHub Design Team
