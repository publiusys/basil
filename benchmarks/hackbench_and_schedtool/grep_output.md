## Notes on grap output from last time

| Parameter                                  | Description                                                                                              |
| :----------------------------------------- | :------------------------------------------------------------------------------------------------------- |
| **kernel.sched_autogroup_enabled**         | Controls whether the scheduler automatically groups tasks from the same session into a task group.       |
| **kernel.sched_cfs_bandwidth_slice_us**    | Sets the time slice for the Completely Fair Scheduler (CFS) bandwidth control.                           |
| **kernel.sched_deadline_period_max_us**    | Defines the maximum period for the deadline scheduler.                                                   |
| **kernel.sched_deadline_period_min_us**    | Sets the minimum period for the deadline scheduler.                                                      |
| **kernel.sched_rr_timeslice_ms**           | Specifies the time slice for tasks using the SCHED_RR (Round-Robin) real-time scheduling policy.         |
| **kernel.sched_rt_period_us**              | Defines the period for real-time task throttling.                                                        |
| **kernel.sched_rt_runtime_us**             | Sets the total CPU time available for all real-time tasks during the `kernel.sched_rt_period_us` period. |
| **kernel.sched_schedstats**                | Enables or disables scheduler statistics.                                                                |
| **kernel.sched_util_clamp_max**            | Clamps the maximum CPU utilization of a task.                                                            |
| **kernel.sched_util_clamp_min**            | Clamps the minimum CPU utilization of a task.                                                            |
| **kernel.sched_util_clamp_min_rt_default** | Sets the default minimum CPU utilization for real-time tasks.                                            |
| **net.mptcp.scheduler**                    | Specifies the scheduler for the Multipath TCP (MPTCP) protocol.                                          |

## Sources

- man 7 sched: The Linux manual page for the scheduler. This is the most authoritative source for details on scheduling policies, parameters, and system calls.
- The Linux Kernel Documentation: The official documentation for the Linux kernel often includes detailed descriptions of various scheduler parameters. You can find these documents in the source code under the Documentation/ directory. For example, look for files related to sched/ and sysctl/.
- LWN.net: This is a great resource for in-depth articles on Linux kernel development, including changes and explanations of scheduler behavior. You can search their archives for articles on topics like "CFS," "real-time scheduling," or "schedstats."
