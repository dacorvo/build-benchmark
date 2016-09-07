Comparing build systems performance for a large C project.

Requirements
------------

- support more than 1000 files in the project
- support build 'fragments' in each subdirectory
- take advantage of gcc automatic dependencies

Please refer to this [blog post](http://kaizou.org/2016/09/build-benchmark-large-c-project/) for details about the solutions.

Results
-------

I ran the benchmark on a Intel Core i7 with 16 GB RAM and an SSD drive.

All build times are in seconds.
~~~~
$make --version
GNU Make 3.81
$cmake --version
cmake version 2.8.12.2
$ninja --version
1.3.4
~~~~

Tree = 2 levels, 10 subdirectories per level (12 .c files)

~~~~
|               | kbuild | nrecur | static | cmake | b/make | cninja | ninja |
|---------------|--------|--------|--------|-------|--------|--------|-------|
| cold start    |  0.08  |  0.06  |  0.08  | 0.55  |  0.08  |  0.36  | 0.08  |
| full rebuild  |  0.06  |  0.06  |  0.06  | 0.23  |  0.07  |  0.04  | 0.06  |
| rebuild leaf  |  0.04  |  0.03  |  0.03  | 0.16  |  0.04  |  0.05  | 0.02  |
| nothing to do |  0.01  |  0.00  |  0.00  | 0.06  |  0.01  |  0.00  | 0.00  |
~~~~

Tree = 3 levels, 10 subdirectories per level (112 .c files)

~~~~
|               | kbuild | nrecur | static | cmake | b/make | cninja | ninja |
|---------------|--------|--------|--------|-------|--------|--------|-------|
| cold start    |  0.47  |  0.45  |  0.51  | 1.84  |  0.52  |  0.91  | 0.53  |
| full rebuild  |  0.48  |  0.46  |  0.44  | 1.34  |  0.54  |  0.39  | 0.32  |
| rebuild leaf  |  0.10  |  0.09  |  0.09  | 0.46  |  0.11  |  0.07  | 0.05  |
| nothing to do |  0.06  |  0.05  |  0.06  | 0.40  |  0.07  |  0.00  | 0.01  |
~~~~

Tree = 4 levels, 10 subdirectories per level (1112 .c files)

~~~~
|               | kbuild | nrecur | static | cmake | b/make | cninja | ninja |
|---------------|--------|--------|--------|-------|--------|--------|-------|
| cold start    |  4.62  |  4.57  |  5.78  | 16.72 |  5.48  |  7.50  |  5.61 |
| full rebuild  |  4.85  |  4.57  |  4.78  | 15.12 |  5.56  |  6.39  |  3.90 |
| rebuild leaf  |  0.98  |  0.86  |  1.04  |  4.47 |  1.07  |  0.28  |  0.21 |
| nothing to do |  0.53  |  0.67  |  0.82  |  4.44 |  0.88  |  0.05  |  0.03 |
~~~~

Tree = 5 levels, 10 subdirectories per level (11112 .c files)

~~~~
|               | kbuild | nrecur | static | cmake  | b/make | cninja | ninja |
|---------------|--------|--------|--------|--------|--------|--------|-------|
| cold start    |  59.01 |  54.07 | 118.00 | 509.96 |  72.41 | 175.58 | 70.00 |
| full rebuild  |  63.41 |  61.38 | 103.95 | 376.40 |  80.17 | 101.76 | 49.66 |
| rebuild leaf  |  10.86 |  17.18 |  59.03 | 215.44 |  20.19 |   2.81 |  2.28 |
| nothing to do |   5.13 |  14.95 |  56.87 | 220.49 |  17.78 |   0.47 |  0.03 |
~~~~

My two cents
------------

From the results above, I conclude that:

- for my use case, and with my hardware (I suspect SSD is a huge bonus for recursive Make), non-recursive and recursive Makefiles are equivalent,
- my generated Makefile is completely suboptimal (would need to investigate),
- CMake generated Makefiles are pretty darn slow ...
- As long as you don't generate the `build.ninja` with CMake, Ninja is as good as the best plain Make solutions for cold start and faster for rebuild,
- Ninja is by far the fastest build-system when only a few files have changed.

