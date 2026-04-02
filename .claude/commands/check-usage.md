Check rate limit status and advise on capacity.

Steps:
1. Read /tmp/coordinator-rate-limits.log if it exists — show when rate limits were last hit
2. Count how many rate limit events occurred today
3. Check REGISTRY.md for number of active workers and projects
4. Advise:
   - If rate limit hit in the last hour: "CAUTION — rate limit hit recently. Avoid launching new workers. Let existing work complete."
   - If rate limit hit today but not recently: "Rate limit hit earlier today. Proceed with caution. Space out worker launches."
   - If no rate limit hits today: "No rate limit issues today. Normal operations."
5. Remind CEO they can check detailed usage with the /usage command (built-in Claude Code command)