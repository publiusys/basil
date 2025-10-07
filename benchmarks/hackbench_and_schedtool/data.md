## First Run (without minimized noise)

| Scheduler | Mean Time (s) | Standard Deviation (s) |
| --------- | ------------- | ---------------------- |
| NORMAL    | 10.756        | 0.062                  |
| FIFO      | 13.049        | 0.045                  |
| RR        | 13.058        | 0.036                  |
| BATCH     | 10.635        | 0.058                  |

## Second Run (with first draft of minimized noise running) (did not work, need to look more into)

1. run scaling_governer
2. turboboost
3. hyperthreading

- I ended up setting the # of groups to 2 and # of loops to 150

| Scheduler | Mean Time (s) | Standard Deviation (s) |
| --------- | ------------- | ---------------------- |
| NORMAL    | 9.386         | 0.038                  |
| FIFO      | 9.130         | 0.019                  |
| RR        | 9.050         | 0.057                  |
| BATCH     | 9.387         | 0.055                  |

## Third run (without minimized noise)

| Scheduler | Mean Time (s) | Standard Deviation (s) |
| --------- | ------------- | ---------------------- |
| NORMAL    | 10.156        | 0.030                  |
| FIFO      | 11.418        | 0.031                  |
| RR        | 11.442        | 0.073                  |
| BATCH     | 10.025        | 0.025                  |

---

## Fourth run (with minimized noise)

| Scheduler | Mean Time (s) | Standard Deviation (s) |
| --------- | ------------- | ---------------------- |
| NORMAL    | 15.273        | 0.036                  |
| FIFO      | 17.817        | 0.209                  |
| RR        | 17.684        | 0.158                  |
| BATCH     | 15.217        | 0.105                  |
