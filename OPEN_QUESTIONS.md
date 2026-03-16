# OPEN_QUESTIONS.md - Blockers, Assumptions & Escalation

## Overview

15 open questions requiring decisions before/during Flutter development. Organized by criticality and phase.

---

## CRITICAL BLOCKERS (Must Answer Before Phase 1)

### Q1: Does backend API exist?

**Impact**: 🔴 **CRITICAL** - Blocks Phase 3+ entirely  
**Phase**: Phase 1 (decision), Phase 7 (integration)

**Question**: Is there a working backend API matching the data model in DATA_MODEL_MAP.md?

**Options**:
1. ✅ **Yes, API exists** → Use real endpoints in Phase 7
2. ⚠️ **Partial API** → Use mock server for missing endpoints
3. ❌ **No API exists** → Build mock server first (delay Phase 7)

**Proposed Assumption**: 
- **Assume**: Backend API exists and will provide endpoints
- **Mitigation**: Create mock_server.dart in Phase 1 for offline dev
- **Acceptance**: API contract in DATA_MODEL_MAP.md is the source of truth

**Escalation Path**: 
- Engineer → Tech Lead → Product Manager
- **Decision Required By**: End of Phase 1
- **Action**: Backend team confirms endpoint availability

---

### Q2: What authentication scheme?

**Impact**: 🔴 **CRITICAL** - Blocks Phase 1 (auth system)  
**Phase**: Phase 1

**Question**: JWT, OAuth2, API key, or custom session?

**Options**:
1. ✅ **JWT (access + refresh tokens)** ← Recommended
2. ⚠️ **OAuth2** - More complex, requires third-party provider
3. ❌ **API Keys** - Not suitable for user apps
4. ❌ **Custom sessions** - Building from scratch is risky

**Proposed Assumption**:
- **Use**: JWT with 15-min access token + 7-day refresh token
- **Storage**: Secure storage (Hive encrypted)
- **Refresh**: Automatic on 401 response (Dio interceptor)
- **Reference**: CLAUDE.md (Auth Provider section)

**Escalation Path**:
- Engineer → Backend Lead → Security Officer
- **Decision Required By**: End of Phase 1 kickoff
- **Action**: Backend team confirms JWT endpoint format

---

### Q3: What is the source of truth for API format?

**Impact**: 🔴 **CRITICAL** - Blocks Phase 7 (real API integration)  
**Phase**: Phase 7

**Question**: How do we resolve differences between:
- DATA_MODEL_MAP.md (Flutter specification)
- Backend implementation (actual API)
- React Native prototype (what it currently does)

**Current Situation**:
- React Native uses hardcoded data (no actual API calls)
- DATA_MODEL_MAP.md is Flutter's assumed API contract
- Backend might have different structure

**Proposed Assumption**:
- **Source of Truth**: Backend API as documented
- **If conflict**: Backend spec wins (DATA_MODEL_MAP updated to match)
- **Verification**: Integration tests validate real API responses

**Escalation Path**:
- Engineer → Backend Tech Lead
- **Decision Required By**: Before Phase 7
- **Action**: Backend team provides formal API specification

---

## PHASE-LEVEL BLOCKERS (Must Answer Before Phase Starts)

### Q4: Should we include offline-first sync?

**Impact**: 🟡 **HIGH** - Affects Phase 3 architecture  
**Phase**: Phase 3

**Question**: Full offline support with sync queue, or online-only?

**Options**:
1. ✅ **Offline-first** (Phase 3) - Full queue + sync when reconnect
2. ⚠️ **Offline-read only** (Phase 3) - Cache reads, block writes
3. ❌ **Online-only** (skip Phase 3 offline parts)

**Trade-offs**:
- Offline-first: 3 extra days (Phase 3), +2 critical bugs to fix
- Offline-read: 1 extra day (Phase 3)
- Online-only: Saves 3 days, but app unusable on flight/tunnels

**Current State**: React Native has no offline support

**Proposed Assumption**:
- **Go with**: Offline-first (full Phase 3 implementation)
- **Rationale**: Users expect to work in vehicles/sites without service
- **Schedule impact**: +3 days → Phase 8 (not MVP critical path)

**Decision Required By**: End of Phase 1  
**Escalation**: Product Manager (features) vs Engineer (effort)

---

### Q5: Which screens are MVP vs nice-to-have?

**Impact**: 🟡 **HIGH** - Defines Phase 6 go/no-go  
**Phase**: Phase 6 (MVP)

**Question**: What are the absolute minimum screens to release to beta users?

**Options**:
1. **6 screens** (Recommended):
   - Login, Dashboard, Projects, Tasks, Quality, Maintenance
2. **4 screens** (Bare minimum):
   - Login, Dashboard, Projects, Tasks
3. **All 16 screens**:
   - Everything (Phase 12, not MVP)

**Current Proposal**: 6 screens (MVP = Phase 6 end)

**Proposed Assumption**:
- **MVP Screens**: Login, Dashboard, Projects (CRUD), Tasks, Quality Checklist, Maintenance
- **Phase 6 Release**: All 6 screens 100% functional, tested, stable
- **Nice-to-have (Phase 7+)**: Maps, Analytics, Security, Profile editing

**Escalation**: Product Manager (business) + Scrum Master (priority)  
**Decision Required By**: Start of Phase 1

---

### Q6: Should we integrate Google Maps?

**Impact**: 🟡 **HIGH** - Phase 6 or defer to Phase 7?  
**Phase**: Phase 6

**Question**: Maps screen critical for MVP or Phase 7+?

**Options**:
1. ✅ **Include Maps in Phase 6** (3 extra days) - MVP release with maps
2. ⚠️ **Defer to Phase 7** (post-MVP) - Release MVP without maps
3. ❌ **Skip maps** (Phase 7-8 if time)

**Cost**:
- Phase 6 delay: 1 week (maps + testing)
- Phase 7 already loaded (backend integration + testing)

**Proposed Assumption**:
- **Include Maps in Phase 6** - Users expect location visualization
- **Simple implementation**: Interactive markers + list below map
- **Advanced features** (real-time tracking, route calc): Phase 7+

**Escalation**: Product Manager (must-have?) + Engineer (effort estimate)  
**Decision Required By**: Before Phase 5 ends

---

## TECHNICAL DECISIONS

### Q7: Should we use Firebase services?

**Impact**: 🟡 **HIGH** - Affects Phase 7+  
**Phase**: Phase 10+ (notifications, analytics)

**Question**: Firebase Cloud Messaging, Crashlytics, Analytics, or roll our own?

**Options**:
1. ✅ **Firebase (full stack)** - FCM + Crashlytics + Analytics
2. ⚠️ **Firebase (selective)** - Only Crashlytics, custom notifications
3. ❌ **No Firebase** - All custom (huge work)

**Proposed Assumption**:
- **Use Firebase** for: Crashlytics (error tracking), FCM (push notifications)
- **Skip**: Analytics (custom logging sufficient for MVP)
- **Timeline**: Phase 10 (not MVP critical)

**Escalation**: Backend + DevOps (Firebase setup)  
**Decision Required By**: End of Phase 8

---

### Q8: What's the database strategy for backend?

**Impact**: 🟡 **MEDIUM** - Affects data model  
**Phase**: Phase 1 (information), Phase 7 (integration)

**Question**: Is backend PostgreSQL, MongoDB, Firebase, or something else?

**Current State**: Unknown (not specified in React Native prototype)

**Proposed Assumption**:
- **Assume**: PostgreSQL (standard for REST APIs)
- **Mitigation**: DATA_MODEL_MAP.md is database-agnostic (API contracts work either way)
- **Validation**: Backend team confirms in Phase 1

**Escalation**: Backend Tech Lead  
**Decision Required By**: Before Phase 7

---

### Q9: What's the deployment strategy?

**Impact**: 🟡 **MEDIUM** - Phase 11+  
**Phase**: Phase 12 (release)

**Question**: Google Play Store, Apple App Store, Firebase App Distribution, or TestFlight?

**Timeline for each**:
- Google Play: 4 hours review (usually< 1 day)
- App Store: 24-48 hours review
- Firebase Distribution: 0 hours (instant)
- TestFlight: 0 hours (instant)

**Proposed Assumption**:
- **Beta**: Firebase App Distribution (fast iteration)
- **Release**: Google Play + App Store (production)
- **Timeline**: Phase 12

**Escalation**: Product Manager + DevOps  
**Decision Required By**: End of Phase 8

---

## DESIGN & UX

### Q10: Dark mode required for MVP?

**Impact**: 🟢 **LOW** - Nice-to-have  
**Phase**: Phase 8+ (not MVP)

**Question**: Should MVP include dark mode?

**Options**:
1. ✅ **Yes** (+2 days in Phase 1) - Theme system from start
2. ❌ **No** - Add in Phase 8+ if time

**Current Status**: React Native has light theme only

**Proposed Assumption**:
- **Skip dark mode for MVP** - Add in Phase 8 if time permits
- **Prepare**: Use Riverpod themeProvider (easy to add later)

**Escalation**: Product Manager (user demand?)  
**Decision Required By**: Start of Phase 1 (yes=change Phase 1 plan)

---

### Q11: Multilingual support (beyond Arabic/English)?

**Impact**: 🟢 **LOW** - Phase 8+  
**Phase**: Phase 8 (localization)

**Question**: English + Arabic only, or Spanish, French, etc.?

**Current State**: React Native has English/Arabic toggle (not really implemented)

**Proposed Assumption**:
- **MVP**: English + Arabic only
- **Phase 8+**: Add more languages if product demand

**Escalation**: Product Manager (market requirements)  
**Decision Required By**: End of Phase 1

---

## RESOURCE & PLANNING

### Q12: Who's the backend API team?

**Impact**: 🟡 **HIGH** - Coordination needed  
**Phase**: Phase 1-7

**Question**: Is there a backend team? Who do we coordinate with on API?

**Current State**: Unknown (backend unclear from React Native prototype)

**Proposed Assumption**:
- **Call out**: Identify backend team lead by end of Phase 1
- **Sync**: Weekly 30-min sync (Flutter + Backend) starting Phase 1
- **Contract**: API spec is source of truth (DATA_MODEL_MAP.md)

**Action Items**:
- [ ] Assign backend team lead
- [ ] Schedule weekly API sync meetings
- [ ] Formalize API contract document

---

### Q13: What's the testing strategy for backend?

**Impact**: 🟡 **MEDIUM** - Affects Phase 7  
**Phase**: Phase 7

**Question**: Does backend have automated tests? How do we validate API?

**Proposed Assumption**:
- **Backend tests**: Assume backend has 80%+ coverage (we verify)
- **Flutter validates**: Integration tests call real API, verify responses
- **Manual testing**: Both teams do manual sanity checks Phase 7

**Escalation**: Backend Tech Lead  
**Decision Required By**: Before Phase 7

---

### Q14: What's the team structure?

**Impact**: 🟡 **HIGH** - Affects timeline  
**Phase**: Phase 0 (planning)

**Question**: 1 Flutter dev, 2, or 3? Full-time or part-time?

**Timeline implications**:
- 1 dev FT: 8-12 weeks (sequential)
- 2 dev FT: 4-6 weeks (parallel)
- 3 dev FT: 3-4 weeks (aggressive)

**Current Assumption**: 1-2 developers

**Proposed Assumption**:
- **Resources**: 1 lead Flutter engineer + 1 junior (starting Phase 2)
- **Ramp-up**: Junior learns during Phase 1, productive Phase 2+
- **Estimate**: 10 weeks total (Phase 1-6 = 6 weeks, Phase 7-8 = 4 weeks)

**Escalation**: Engineering Manager  
**Decision Required By**: Before Phase 1 start

---

### Q15: What CI/CD infrastructure exists?

**Impact**: 🟡 **MEDIUM** - Phase 9+  
**Phase**: Phase 9 (DevOps)

**Question**: GitHub Actions, Jenkins, GitLab CI, or manual?

**Proposed Assumption**:
- **Use**: GitHub Actions (free, integrated with GitHub)
- **Pipeline**: Lint → Test → Build APK/IPA on each commit
- **Deployment**: Manual to Play Store/App Store (Phase 12)

**Escalation**: DevOps Engineer  
**Decision Required By**: End of Phase 8

---

## Summary Table

| Q# | Topic | Impact | Phase | Status | Escalation |
|----|----|--------|-------|--------|------------|
| 1 | Backend API exists? | 🔴 Critical | 1 | ⏳ Pending | Tech Lead |
| 2 | Auth scheme (JWT)? | 🔴 Critical | 1 | ⏳ Pending | Backend Lead |
| 3 | API source of truth? | 🔴 Critical | 7 | ⏳ Pending | Backend Tech Lead |
| 4 | Offline-first sync? | 🟡 High | 3 | ✅ Proposed | Product Manager |
| 5 | MVP screens (6)? | 🟡 High | 6 | ✅ Proposed | Product Manager |
| 6 | Include maps Phase 6? | 🟡 High | 6 | ✅ Proposed | Product Manager |
| 7 | Firebase services? | 🟡 High | 10 | ✅ Proposed | Backend Lead |
| 8 | Backend DB type? | 🟡 High | 1 | ⏳ Pending | Backend Tech Lead |
| 9 | Deployment strategy? | 🟡 Medium | 12 | ✅ Proposed | Product Manager |
| 10 | Dark mode MVP? | 🟢 Low | 1 | ✅ Proposed | Product Manager |
| 11 | Multilingual (beyond AR/EN)? | 🟢 Low | 8 | ✅ Proposed | Product Manager |
| 12 | Backend team contact? | 🟡 High | 1 | ⏳ Pending | Engineering Manager |
| 13 | Backend test strategy? | 🟡 Medium | 7 | ⏳ Pending | Backend Tech Lead |
| 14 | Team structure (1/2/3 devs)? | 🟡 High | 0 | ⏳ Pending | Engineering Manager |
| 15 | CI/CD infrastructure? | 🟡 Medium | 9 | ⏳ Pending | DevOps Engineer |

---

## Escalation Contacts (Template)

```
| Role | Contact | Email | Questions |
|------|---------|-------|-----------|
| Product Manager | [Name] | [Email] | Q4, Q5, Q6, Q10, Q11 |
| Backend Tech Lead | [Name] | [Email] | Q1, Q2, Q3, Q7, Q8, Q13 |
| Engineering Manager | [Name] | [Email] | Q12, Q14 |
| DevOps Engineer | [Name] | [Email] | Q9, Q15 |
```

---

## Pre-Phase-1 Checklist

Before starting Phase 1, these deve answers MUST be obtained:

- [ ] Q1: Backend API exists (or timeline to build it)
- [ ] Q2: Auth scheme confirmed (JWT assumed approved)
- [ ] Q3: API format strategy (backend spec wins)
- [ ] Q8: Backend database type confirmed
- [ ] Q12: Backend team lead assigned
- [ ] Q14: Team structure (devs assigned)

**All 6 must be locked before coding starts.**

---
