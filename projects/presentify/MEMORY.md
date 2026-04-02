# Presentify — Context Memory

## Architecture Assessment
- Next.js 16 App Router with React 19 — cutting-edge stack
- Modular AI agent architecture: orchestrator pattern with separate agents for outline, slide content, editing, theming
- SSE streaming for real-time slide generation feedback
- localStorage-based persistence (no database, no backend state)
- No authentication — intentionally designed for local/private use
- Multi-provider AI: Anthropic (primary), OpenRouter, Ollama fallback

## Key Patterns
- **AI pipeline:** Opus for planning/outline → Sonnet for individual slide generation and edits
- **Component system:** 21 typed slide components with props interface, registered in `src/components/slides/index.ts`
- **Edit modes:** Chat (AI), click-to-edit (direct DOM), toolbar (visual controls), JSON (raw), AImprovise (Opus redesign)
- **Type system:** Strong TypeScript types in `src/lib/types.ts` — ThemeConfig, Slide, Section, PresentationConfig, etc.
- **Slide validation:** JSON validator (`src/lib/validateSlide.ts`) to fix common AI output issues
- **Retry logic:** Exponential backoff for AI API calls
- **Style system:** Nested — theme → per-slide overrides → per-section overrides → per-column overrides

## Recent Commit Themes (last 30 days — entire project history)
- Multi-provider AI support (Anthropic/OpenRouter/Ollama)
- Web search (Tavily) and image search (Unsplash) enrichment
- Slide JSON validator for AI output reliability
- AImprovise feature (Opus-powered slide redesign)
- Slide management (add, duplicate, delete, reorder)
- Color palette system (10 curated palettes)
- Editable outlines with detailed metadata
- Content overflow guardrails
- Section/slide style overrides
- Component variants and enhancements

## Code Quality Observations
- Consistent conventional commit messages
- TypeScript strict mode
- Well-organized module structure (agents, components, lib)
- README is comprehensive and up-to-date
- AGENTS.md provides good dev guidelines
- Test setup exists (Jest + Testing Library) but test coverage appears minimal
- No linting config visible (no eslint)
- npm (not pnpm) as package manager
