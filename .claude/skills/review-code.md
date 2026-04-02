---
name: review-code
description: Code review criteria and process for reviewing worker submissions. Use when COMM.md status is DONE_AWAITING_REVIEW.
disable-model-invocation: false
---

# Code Review Process

When a worker sets DONE_AWAITING_REVIEW, perform these checks:

## 1. Acceptance Criteria Match
- Read the acceptance criteria from COMM.md
- Verify EVERY criterion is met, not just some
- Check the code diff against each criterion explicitly

## 2. Test Verification
- Navigate to the code repo
- Run the full test suite: `npm test`, `pytest`, or whatever the project uses
- ALL tests must pass — both new tests and existing tests
- If no tests exist for new functionality, this is a rejection reason

## 3. Code Quality
- No obvious bugs or logic errors
- Proper error handling (no unhandled promises, no bare excepts)
- No security issues (no hardcoded secrets, no SQL injection, no XSS)
- Input validation where appropriate

## 4. Conventions
- Code follows the project's tech stack and conventions (from PROJECT.md)
- Consistent with existing patterns in the codebase
- Descriptive variable and function names

## 5. Clean Feature Branch
- No debug code (console.log, debugger statements, print statements)
- No commented-out code blocks
- No TODO comments (unless explicitly part of acceptance criteria)
- No unrelated changes (scope creep)

## 6. Regression Check
- All existing tests still pass
- No breaking changes to existing functionality
- No removed or modified existing exports/APIs without justification

## Verdict

**If ANY check fails:**
- Set COMM.md status to REVISION_NEEDED
- Write specific feedback in COMM.md under "Revision History":
  - Reference exact file paths and line numbers
  - Describe what is wrong and what the expected behavior is
  - Include test output if tests failed
- Append review to REVIEW_LOG.md
- Increment revision count

**If ALL checks pass:**
- Set COMM.md status to APPROVED
- Append review to REVIEW_LOG.md with APPROVED verdict
- Proceed to write next task or compile milestone report
