/**********************************************************************/
/*              L1 SPILT CACHE                                        */										
/* Description: This system verilog file designs the Data cache       */
/*              of L1 spilt Cache for 32 bit processor. L1 data cache */			
/*              is 8-way set associative and consists of 16k sets and */
/*              64 byte lines.L1 data cache is write-back using write-*/
/*              back. Cache employs LRU replacement policy            */
/* Authors : Achyuth Krishna Chepuri                                  */
/* 			                                                          */
/**********************************************************************/

module DataCache(clock,reset,addressbits,n);

parameter MODE = 0;
parameter InstrWays = 4;
parameter CacheLineSize = 64;
parameter sets = 16*1024;
parameter N = 32;
parameter byteoffset =  $clog2(CacheLineSize);
parameter indexbits = $clog2(sets);
parameter TagBits = N - indexbits - byteoffset;

input logic [N-1:0]addressbits;
input logic [3:0]n;
input clock,reset;
logic HIT=0;

logic [InstrWays-1:0]hitway;
logic [InstrWays-1:0]invaliddataway;
logic [InstrWays-1:0]lruway;
logic [InstrWays-1:0]lruupdate;
logic [byteoffset-1:0]byteoffsetbits;
logic [indexbits-1:0]index;
logic [TagBits-1:0]tag;


int LRU;

logic invalid;
int hitcount,misscount;
int tracedata;
int		file;

real hitratio;

assign byteoffsetbits = addressbits[byteoffset-1:0];
assign index = addressbits[19:6];
assign tag = addressbits[31:20];


typedef enum {INVALID,MODIFIED,SHARED,EXCLUSIVE}MESI;
typedef struct packed{
		MESI mesi;
		bit [$clog2(InstrWays)-1:0]LRU;
		bit [TagBits-1:0]Tag;
}Cache;

Cache [sets -1:0][InstrWays-1:0]cacheline;

always@(posedge clock)
case(n)
	0: ReadDataRequestToL1DataCache();
	1: WriteDataRequestToL1DataCache();
	3: InvalidateCommandFromL2();
	4: DataRequestFromL2();
	9: PrintContentsAndStateOfTheCache();
endcase


task ReadDataRequestToL1DataCache();
for(int i=0;i<InstrWays;i=i+1)
	begin 
	if(cacheline[index][i].Tag == tag)
	begin 
		HIT = 1'b1;
		hitway = i;
		$display("%d",hitway);
		break;
	end
	end
	if(HIT)
	begin
		$display("Hit Tag- %h Hit Index - %h",tag,index);		
		hitcount++;
		lru(hitway);
		if(cacheline[index][hitway].mesi == EXCLUSIVE)	cacheline[index][hitway].mesi = SHARED;
		else cacheline[index][hitway].mesi = EXCLUSIVE;
		HIT = 0;
		$display("%p",cacheline[index][hitway].mesi);
		$display("**hit**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
	end
	else 
	begin
	misscount++;
		for(int i=0;i<InstrWays;i=i+1)
		begin 
			if(cacheline[index][i].mesi == INVALID) 
			invalid = 1'b1;
			invaliddataway=i;
			break;
		end	
		if(invalid)
		begin 
			$display("Tag- %h Index - %h",tag,index);
			$display("invaliddataway- %d",invaliddataway);
			cacheline[index][invaliddataway].Tag = tag;	
			lru(invaliddataway);
			cacheline[index][invaliddataway].mesi = EXCLUSIVE;
			invalid = 0;
			$display("%p",cacheline[index][invaliddataway].mesi);
			$monitor("cacheline[invaliddataway][index]: %h",cacheline[index][invaliddataway].Tag);
			$display("**invalid**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
		end
		else
		begin 
			for(int i=0;i<InstrWays;i=i+1)
			begin 
			if(cacheline[index][i].LRU == '0)
				begin 
				lruway = i;
				cacheline[index][lruway].Tag = tag;	
				break;
				end
			end
			lru(lruway);
			cacheline[index][lruway].mesi = EXCLUSIVE;
			$display("**lru**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
		end	
	end
endtask 


task InvalidateCommandFromL2();
for(int i=0;i<InstrWays;i=i+1)
begin 
	if(cacheline[index][i].Tag == tag)
	begin 
		HIT = 1'b1;
		hitway = i;
		$display("%d",hitway);
		break;
	end
end
	if(HIT)
	begin
		if(cacheline[index][hitway].mesi == MODIFIED && MODE == 1)
			$display("Write to L2, Address : ",addressbits);
		cacheline[index][hitway].mesi = INVALID;
	end
endtask


task DataRequestFromL2();
for(int i=0;i<InstrWays;i=i+1)
begin 
if(cacheline[index][i].Tag == tag)
	begin 
	HIT = 1'b1;
	hitway = i;
	$display("%d",hitway);
	break;
	end
end
	if(HIT)
	begin 
		if(cacheline[index][hitway].mesi == MODIFIED && MODE == 1)
			$display("Read for Ownership from L2, Address : ",addressbits);
		cacheline[index][hitway].mesi = INVALID;
	end
endtask


task WriteDataRequestToL1DataCache();
for(int i=0;i<InstrWays;i=i+1)
	begin 
	if(cacheline[index][i].Tag == tag)
	begin 
		HIT = 1'b1;
		hitway = i;
		$display("%d",hitway);
		break;
	end
	end
	if(HIT)
	begin
		$display("Hit Tag- %h Hit Index - %h",tag,index);		
		hitcount++;
		lru(hitway);
		if(cacheline[index][hitway].mesi == EXCLUSIVE || SHARED || INVALID)	cacheline[index][hitway].mesi = MODIFIED;
		HIT = 0;
		$display("%p",cacheline[index][hitway].mesi);
		$display("**hit**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
		
	end
	else 
	begin
	misscount++;
		for(int i=0;i<InstrWays;i=i+1)
		begin 
			if(cacheline[index][i].mesi == INVALID) 
			invalid = 1'b1;
			invaliddataway=i;
			break;
		end	
		if(invalid)
		begin 
			$display("Tag- %h Index - %h",tag,index);
			$display("invaliddataway- %d",invaliddataway);
			cacheline[index][invaliddataway].Tag = tag;	
			lru(invaliddataway);
			cacheline[index][invaliddataway].mesi = MODIFIED;
			invalid = 0;
			$display("%p",cacheline[index][invaliddataway].mesi);
			$monitor("cacheline[invaliddataway][index]: %h",cacheline[index][invaliddataway].Tag);
			$display("**invalid**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
			if(MODE ==1)
			begin 
				$display("Read for Ownership from L2, Address : ",addressbits);
				$display("Write to L2, Address : ",addressbits);
			end
		end
		else
		begin 
			for(int i=0;i<InstrWays;i=i+1)
			begin 
			if(cacheline[index][i].LRU == '0)
				begin 
				lruway = i;
				cacheline[index][lruway].Tag = tag;	
				break;
				end
			end
			lru(lruway);
			cacheline[index][lruway].mesi = MODIFIED;
			$display("**lru**cacheline[index][0] - %p, cacheline[index][1]= %p,cacheline[index][2]= %p,cacheline[index][3]= %p",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
		end	
	end

endtask

task lru(logic[1:0] lway);
logic[InstrWays-1:0] temp;
$display("lway: %0d index = %0d",lway , index); 
temp = cacheline[index][lway].LRU;
	for(int j=0;j<InstrWays;j=j+1)
	begin 
		cacheline[index][j].LRU = cacheline[index][j].LRU > temp ? cacheline[index][j].LRU - 1'b1 : cacheline[index][j].LRU;
	end	
	cacheline[index][lway].LRU = '1;
endtask

task PrintContentsAndStateOfTheCache();
$display("cacheline[index][0] - %h, cacheline[index][1]= %h,cacheline[index][2]= %h,cacheline[index][3]= %h",cacheline[14'h3784][0],cacheline[14'h3784][1],cacheline[14'h3784][2],cacheline[14'h3784][3]);
$display("ByeOffset: %0d",byteoffset); 
$display("IndexBits: %0d",indexbits); 
$display("TagBits: %0d",TagBits); 
$monitor("Address: %0h",addressbits);
$monitor("byteoffsetbits: %0h,tag: %0h,index: %0h",byteoffsetbits,tag,index);

$display("Hit Count: %0d",hitcount);
$display("Miss Count: %0d",misscount);

if(hitcount + misscount == 0)
	$display ("Denominator cannot be zero (ie, data_miss and data_hit is zero)");
else 
	begin 
		hitratio = (hitcount * 100)/(hitcount + misscount);
		$display("DATA CACHE HIT ratio = %f", hitratio);
	end
endtask 

endmodule