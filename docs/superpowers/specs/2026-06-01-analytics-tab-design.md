# Analytics Tab & Admin UI Overhaul Design

## Overview
Create dedicated 'Analytics' tab in Admin Dashboard for sales tracking and product insights. Overhaul Admin UI using Impeccable standards.

## Architecture
- `AnalyticsManagementView` widget: Primary container.
- `analyticsProvider`: State provider for time-range filtering.
- Data Source: Existing `ordersStreamProvider` via `drift` DB.
- Admin UI Framework: Hierarchical Bento-style composition.

## UI/UX Standards (Impeccable)
- **Hierarchy:** Scale contrast; revenue metrics dominant.
- **Composition:** Bento-grid layout for cards (Revenue, Stats, Lists).
- **Depth:** Surface cards with elevation (shadows/border).
- **Interaction:** Hover states (lift), focus states, active click feedback.
- **Color:** Semantic usage; accent reserved for high-value insights.

## Data Flow
User selection updates provider state -> re-aggregates order data -> refreshes UI (Bento grid).

## Implementation Rules
- Use exclusively `/superpowers` tooling.
- Do NOT use GSD methodology.
- Follow Impeccable design patterns for Admin surface.

## Testing Plan
- Unit tests for aggregation logic.
- Widget test for tab rendering.
- Visual inspection of Bento grid responsiveness.
