# APPGAMBIT AI Company — System Specification

> A $300/month AI-native software agency powered by Claude Code CLI, headless workers, and a Git-based coordination protocol.

---

## Overview

APPGAMBIT AI Company is an autonomous AI workforce that manages software projects end-to-end. A human CEO provides high-level direction. An AI Coordinator handles all planning, assignment, review, and operational management. AI Workers execute development tasks as headless Claude Code CLI processes, each scoped to its own project directory. The entire system communicates through a single private Git repository — the Management Repo. There is no custom orchestration framework, no queue system, no database. Files and Git commits are the protocol.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2026-03-31 | Initial specification |
| v1.1 | 2026-04-01 | Rolling window protocol, discovery phase, worker autonomy |
| v1.2 | 2026-04-02 | Claude Code CLI features — /loop, Channels, headless mode, hooks, permission modes, subagents |
| v1.3 | 2026-04-02 | Split into modular spec files, added context preparation workflow and error recovery rules |

---

## Table of Contents

| # | File | Covers |
|---|------|--------|
| 1 | [Roles](spec/01-roles.md) | CEO, Coordinator, Workers — responsibilities, loops, permissions |
| 2 | [Infrastructure](spec/02-infrastructure.md) | Accounts, session management, Git repos |
| 3 | [Repo Structure](spec/03-repo-structure.md) | Management repo directory layout |
| 4 | [File Protocols](spec/04-file-protocols.md) | CEO_INBOX, REGISTRY, PROJECT, MILESTONES, COMM, REVIEW_LOG, ARCHIVE, BRIEF formats |
| 5 | [State Machine](spec/05-state-machine.md) | COMM.md states, valid transitions, project lifecycle |
| 6 | [Workflows](spec/06-workflows.md) | Onboarding, task cycle, escalation, rate limits, priority changes, session recovery, context preparation |
| 7 | [Rules](spec/07-rules.md) | Quality gate, conflicts, capacity, context loss, cooldown, rolling window, non-interactive, permissions, channels, subagents, error recovery |
| 8 | [Bootstrap](spec/08-bootstrap.md) | Getting started steps |
| 9 | [Cost & Future](spec/09-cost-and-future.md) | Cost analysis, future extensions |

---

*Author: Dhaval Nagar + Claude (APPGAMBIT AI Company design session)*
