# POS Analytics Dashboard Design

## Overview
Create a "Command Center" style POS Analytics Dashboard. It provides a highly scannable, KPI-driven overview of financial, product, time, and payment metrics using the Impeccable Bento design system.

## Data Model & Aggregation
- **Input:** `OrdersStream` and selected `TimeRange` (Today, This Week, This Month, This Year).
- **Output (`AnalyticsSummary`):**
  - Financials: `totalRevenue`, `netSales`, `taxCollected`
  - Orders: `totalOrders`, `averageOrderValue` (AOV)
  - Products: `topProducts` (List of items with quantity & revenue)
  - Payments: `paymentMethods` (Revenue breakdown by type)
  - Time: `peakHours` (Order count by hour of day)
- **Mock Data:** A mock data generator will be created to populate the dashboard for testing without requiring real local DB transactions.

## UI Architecture & Layout
- **Main View (`AnalyticsDashboardView`):**
  - Top row: `TimeRangeSelector`.
  - Body: Responsive Bento Grid (using `Wrap` or `SliverGrid`) composed of `BentoCard` widgets.

### Grid Composition
1. **Financial KPIs (Top Row):**
   - Container: `BentoCard`
   - Content: Row of `MetricTile` widgets (Total Revenue [Accent Color], Net Sales, Tax, AOV).
2. **Product Performance (Middle Left):**
   - Container: `BentoCard`
   - Content: List of "Top 5 Products" showing name, quantity sold, and revenue.
3. **Peak Times (Middle Right):**
   - Container: `BentoCard`
   - Content: Simple bar chart or list showing busiest hours.
4. **Payment Types (Bottom):**
   - Container: `BentoCard`
   - Content: Breakdown of revenue by payment method (Cash, Card, etc.).

## Visual Standards
- **Impeccable Bento System:** Use existing `BentoCard` and `MetricTile` components.
- **Hierarchy:** High contrast for primary metrics (Revenue).
- **Interaction:** Hover lifts on cards.
- **Charts:** Keep visual representations simple (KPI-driven with sparklines or simple bars).
