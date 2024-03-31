# L1-Spilt-Cache

This project involves design and simulation of a spilt L1 cache for a 32-bit processor. 
The system employs a MESI protocol to ensure Cache Coherence. 

L1 instruction cache is a four-way set associative cache and consists of 16k sets of 64-byte lines. 
L1 data cache is a right-way set associative caches and consists of 16k sets of 64-byte lines. 
Both caches employ LRU replacement policy and are backed by shared L2 cache. Implements MESI protocol and L1 caches may have to communicate with L2 Cache. 

<h2>Trace file explanation</h2>
<b>n address</b>
<b>Where n is</b>
<b>0 read data request to L1 data cache</b>
<b>1 write data request to L1 data cache</b>
<b>2 instruction fetch (a read request to L1 instruction cache)</b>
<b>3 invalidate command from L2</b>
<b>4 data request from L2 (in response to snoop)</b>
<b>8 clear the cache and reset all state (and statistics)</b>
<b>9 print contents and state of the cache (allow subsequent trace activity)</b>
The address will be a hex value. For example:
2 408ed4
0 10019d94
2 408ed8
1 10019d88
2 408edc
