Check if the coordinator round-robin loop is running. List all scheduled tasks. If the coordinator-check-cycle loop is not active, restart it immediately:

/loop 15m coordinator-check-cycle

Report the status: running (with job ID and interval) or restarted (with new job ID).