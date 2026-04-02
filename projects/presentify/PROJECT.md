# PROJECT: Presentify

## Overview

Open-source AI-powered presentation builder. Users describe their talk through a 4-step intake wizard, AI generates structured outlines (via Claude Opus) and then beautiful animated slides (via Claude Sonnet). Supports 5 editing modes: chat, click-to-edit, visual toolbar, JSON editor, and AImprovise (Opus-powered redesign).

**Client:** Internal / Open-source
**Type:** Existing project (active development)
**Code Repo (local):** `/Users/dhaval/Documents/work/antigravity/charusat-presentation/presentify`
**Code Repo (GitHub):** `git@github.com:AppGambitStudio/Presentify.git`

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Next.js (App Router) | 16.2.1 |
| React | React | 19.2.4 |
| Language | TypeScript | 5.x |
| Styling | Tailwind CSS v4 + clsx | 4.x |
| AI | Anthropic SDK (Opus + Sonnet) | 0.80.0 |
| Animation | Motion (Framer Motion) | 12.38.0 |
| Charts | Recharts | 3.8.1 |
| Icons | Lucide React | 1.7.0 |
| QR Codes | react-qr-code | 2.0.18 |
| Testing | Jest + Testing Library | 30.x |
| Package Manager | npm | - |

**Multi-provider AI support:** Anthropic (primary), OpenRouter, Ollama (local)
**Optional integrations:** Tavily (web search), Unsplash (image search)

---

## Current State

- **85 commits** — all within last 30 days (very active development)
- **80 source files**, ~6,200 lines of TypeScript/React
- **Branch:** main
- **Working:** Full generation pipeline, editing, presentation mode

### What's Already Built
- 4-step intake wizard (Identity, Context, Structure, Constraints)
- 12 slide types (title, agenda, context, content, comparison, data, demo, story, quote, action, closing, thankyou)
- 21 slide components (text, cards, data viz, steps, media, utility)
- Claude Opus outline generation with editable outlines
- Claude Sonnet slide generation with SSE streaming
- 5 editing modes: chat, click-to-edit, toolbar, JSON, AImprovise
- Slide management: add (AI-generated), duplicate, delete, reorder
- 10 curated color palettes + AI-generated themes
- Per-slide and per-section style overrides
- Spring-physics presentation mode with keyboard navigation
- Saved presentations (localStorage) with edit/present/delete
- Web search (Tavily) and image search (Unsplash) enrichment
- Slide JSON validator for AI output
- Retry logic with exponential backoff
- Form draft persistence (localStorage)
- Confirmation dialogs on destructive operations

### Architecture
- **Frontend:** Next.js App Router with React 19
- **API routes:** Next.js API routes (`src/app/api/`) — generate, edit-slide, improvise-slide, generate-slide, provider-info
- **AI agents:** Modular agent architecture (`src/agents/`) — orchestrator, generateOutline, generateSlideContent, editSlide, improviseSlide, generateTheme
- **Components:** Reusable slide components (`src/components/slides/`), renderer, workspace, intake
- **State:** localStorage-based persistence, no database
- **Auth:** None (intentionally — local/internal use only)

---

## Open Questions

1. **What are the next priorities for this project?** New features, bug fixes, refactoring?
2. **Any known bugs or tech debt to address first?**
3. **Any upcoming deadlines or demo dates?**
4. **Is there a specific feature roadmap you have in mind?**
5. **Should we add authentication for any deployment scenario?**
6. **Any areas of the code that need refactoring?**
7. **Who has been working on this? Any context on the CHARUSAT presentation connection?**

---

## Reference Documents

(none provided yet — CEO can add to `projects/presentify/docs/`)

---

*Status: DISCOVERY*
*Created: 2026-04-02*
