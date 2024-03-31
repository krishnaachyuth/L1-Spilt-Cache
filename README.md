# L1-Spilt-Cache

This project involves design and simulation of a spilt L1 cache for a 32-bit processor. 
The system employs a MESI protocol to ensure Cache Coherence. 

L1 instruction cache is a four-way set associative cache and consists of 16k sets of 64-byte lines. 
L1 data cache is a right-way set associative caches and consists of 16k sets of 64-byte lines. 
Both caches employ LRU replacement policy and are backed by shared L2 cache. Implements MESI protocol and L1 caches may have to communicate with L2 Cache. 
