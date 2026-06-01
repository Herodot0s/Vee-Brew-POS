# Codebase Concerns

**Analysis Date:** 2026-06-01

## Tech Debt

**[General]:**
- Project lacks comprehensive error handling across database operations
- Dependency management requires audit for version pinning

## Fragile Areas

**[Database Layer]:**
- Direct SQLite interactions without repository abstraction
- Risky: Changes to schema require manual updates to SQL strings

---

*Concerns audit: 2026-06-01*
