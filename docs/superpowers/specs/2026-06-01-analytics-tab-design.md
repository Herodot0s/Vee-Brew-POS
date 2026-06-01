# Analytics Tab Design

## Overview
Create dedicated 'Analytics' tab in Admin Dashboard for sales tracking and product insights.

## Architecture
- `AnalyticsManagementView` widget: Primary container.
- `analyticsProvider`: State provider for time-range filtering.
- Data Source: Existing `ordersStreamProvider` via `drift` DB.

## UI Components
- `TimeRangeSelector`: Segmented control (Daily, Weekly, Monthly, Yearly, Custom).
- `RevenueCard`: Displays total revenue (BinancePlex).
- `TopProductsList`: List of top products by quantity sold.

## Data Flow
User selection updates provider state -> re-aggregates order data -> refreshes UI.

## Testing Plan
- Unit tests for aggregation logic.
- Widget test for tab rendering.
