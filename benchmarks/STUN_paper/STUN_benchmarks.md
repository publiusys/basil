## STUN's Different Benchmarks

- **Performance with micro-benchmark.** To confirm the detailed performance improvement of STUN, we chose a micro-benchmark, i.e., hackbench, and compare its performance under the optimized scheduler parameters by STUN with that under the default scheduler environment.
- **Performance under real workload.** To evaluate the performance impact of STUN for a real workload, we ran a face detection application using Haar Cascades and compare the execution time and frames per second of the application between the cases with
  default and optimized settings.
- **Improvement based on the number of CPU cores**. To confirm whether the number of CPU cores affects the performance of STUN, we compared the performance improvement rates by optimizing Sysbench in 4-core, 44-core, and 120-core machines

## STUN's Performance with Different Benchmarks

- **HackBench** : The learning results show a 27.7% reduction in the Hackbench execution time from the default setting: 2.72 to 1.95 s.

- **Face Detection** : The results of the face detection program on the actual image after applying the optimal value are as shown in Figure 8. The total execution time decreased by 18.3% from 58.998 to 48.198 s, and the number of frames per second increased by 22.4% from 16.95 to 20.748

- **Different CPU Cores (Sysbench)**: The performance improvements in Sysbench with STUN on each machine were as follows. As a result of the 4-core machine optimization with STUN, the number of events per second in Sysbench increased by 26.97% from 4419 to 5611. On a 44-core machine, STUN showed a performance improvement of 54.42%, from 3763 to 5811, and on a 120-core machine, it showed an improvement of 256.13%, from 1206 to 4295.