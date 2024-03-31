# L1-Spilt-Cache

This project involves design and simulation of a spilt L1 cache for a 32-bit processor. 
The system employs a MESI protocol to ensure Cache Coherence. 

L1 instruction cache is a four-way set associative cache and consists of 16k sets of 64-byte lines. 
L1 data cache is a right-way set associative caches and consists of 16k sets of 64-byte lines. 
Both caches employ LRU replacement policy and are backed by shared L2 cache. Implements MESI protocol and L1 caches may have to communicate with L2 Cache. 

The following Statistics are reported: <br>
● Number of caches reads <br>
● Number of cache writes <br>
● Number of cache hits <br>
● Number of cache misses <br>
● Cache hit ratio <br>

![image](https://github.com/krishnaachyuth/L1-Spilt-Cache/assets/34981932/5d2aee6a-45f8-48b1-8c27-c44b8fb3d6da)

<h2>Trace file explanation</h2>

<b>n address</b><br>
 Where n is<br>
 0 read data request to L1 data cache<br>
 1 write data request to L1 data cache<br>
 2 instruction fetch (a read request to L1 instruction cache)<br>
 3 invalidate command from L2<br>
 4 data request from L2 (in response to snoop)<br>
 8 clear the cache and reset all state (and statistics)<br>
 9 print contents and state of the cache (allow subsequent trace activity)<br>

The address will be a hex value. For example:<br>
2 408ed4<br>
0 10019d94<br>
2 408ed8<br>
1 10019d88<br>
2 408edc<br>

<h2> Cache Coherence </h2>
 Cache Coherence is a situation where multiple processor cores share the 
same memory hierarchy, but have their own L1 Data and instruction Caches. <br>

<h2> MESI Protocol </h2>

![image](https://github.com/krishnaachyuth/L1-Spilt-Cache/assets/34981932/c6033736-bd95-4e3e-8d12-d49ce3926ccb)

MESI protocol is one of the Cache Coherence protocols which is four states as in above image, 
namely: <br>
<b>M – Modified</b><br> 
<b>E – Exclusive</b><br>
<b>S – Shared</b><br>
<b>I – Invalid</b><br>
<br>
State Transitions: <br>
Modified: Cache line has been modified, is different from main memory- is the only cached copy.<br>
Exclusive: Cache line is the same as main memory and is the only Cached Copy.<br>
Shared: Same as main memory but copies may exist in other Caches. <br>
Invalid: Line data is not valid.<br>
