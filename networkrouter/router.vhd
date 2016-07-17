library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity router is
generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO
PORT (
D1in,D2in,D3in,D4in :in std_logic_vector((M-1) downto 0);
D1out,D2out,D3out,D4out :out std_logic_vector((M-1) downto 0);
clk,rst,init : in std_logic
);

end entity router;
Architecture behave of router is


----------------------------------------------------------
----------------------------------------------------------

component mux41 is 
PORT (
      D1in,D2in,D3in,D4in :in std_logic_vector(63 downto 0);
      s: in std_logic_vector(1 downto 0);
      Dout : out std_logic_vector(63 downto 0)
     );
end component mux41 ;

--component counter is 
--PORT 
--(
--clk,pin : in std_logic;
--op : out std_logic_vector (1 downto 0)
--);

--end component counter;

component FIFO is

 generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO
 port (CLK, PUSH, POP, INIT: in std_logic;
 DIN: in std_logic_vector(M-1 downto 0);
DOUT: out std_logic_vector(M-1 downto 0);
 FULL, EMPTY, NOPUSH, NOPOP: out std_logic);
end component FIFO;
-----------------------------------------------------------
-----------------------------------------------------------

TYPE traffic is array (4 downto 1) of std_logic_vector (15 downto 0);
signal a: traffic:= (x"0000",x"0000",x"0000",x"0000");

------------------------------------------------------------------------------
---------------------------------------------------------------------------------
TYPE traffic_out is array (4 downto 1) of std_logic_vector (15 downto 0);
signal traffic_val: traffic_out;

----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
signal s : std_logic_vector(1 downto 0);
TYPE RVT is array (39 downto 0) of std_logic_vector ((M-1) downto 0);
-----------------------------------------------------------------------
--------------------------------------------------------------------------
TYPE temp_array is array (39 downto 0) of std_logic_vector ((M-1) downto 0);
signal temparray_sg : temp_array; 
-----------------------------------------------------------------------
TYPE state is (idle,route,compare,analyze,output_route,traffic_update);
signal current_state, next_state : state:= idle;
------------------------------------------------------------------
------------------------------------------------------------------
signal router_sg : std_logic_vector((M-1) downto 0);
subtype count_integer is integer range 0 to 40;
signal val_j  :count_integer;
--variable route_path : std_logic_vector(63 downto 0);
----------------------------------------------------------------
----------------------------------------------------------------
----fifo input side signals---------------------------------------
signal FULL_1_in,EMPTY_1_in, NOPUSH_1_in , NOPOP_1_in : std_logic;
signal FULL_2_in,EMPTY_2_in, NOPUSH_2_in , NOPOP_2_in : std_logic;
signal FULL_3_in,EMPTY_3_in, NOPUSH_3_in , NOPOP_3_in : std_logic;
signal FULL_4_in,EMPTY_4_in, NOPUSH_4_in , NOPOP_4_in : std_logic;

signal PUSH_1_in, POP_1_in : std_logic;
signal PUSH_2_in, POP_2_in : std_logic;
signal PUSH_3_in, POP_3_in : std_logic;
signal PUSH_4_in, POP_4_in : std_logic;
signal D1in_sg,D2in_sg,D3in_sg,D4in_sg,mux_out,packet_route,route_sg : std_logic_vector((M-1) downto 0);

------------------------------------------------------------------------
-----------------------------------------------------------------------
------------------------------------------------------------------------



signal pin : std_logic :='0';
----------------------------------------------------------------
----------------------------------------------------------------
----fifo output side signals---------------------------------------
signal FULL_1_out,EMPTY_1_out, NOPUSH_1_out , NOPOP_1_out : std_logic;
signal FULL_2_out,EMPTY_2_out, NOPUSH_2_out , NOPOP_2_out : std_logic;
signal FULL_3_out,EMPTY_3_out, NOPUSH_3_out , NOPOP_3_out : std_logic;
signal FULL_4_out,EMPTY_4_out, NOPUSH_4_out , NOPOP_4_out : std_logic;

signal PUSH_1_out, POP_1_out : std_logic;
signal PUSH_2_out, POP_2_out : std_logic;
signal PUSH_3_out, POP_3_out : std_logic;
signal PUSH_4_out, POP_4_out : std_logic;
signal D1out_sg,D2out_sg,D3out_sg,D4out_sg : std_logic_vector((M-1) downto 0);

------------------------------------------------------------------------
-----------------------------------------------------------------------
------------------------------------------------------------------------




signal rvt_signal: RVT := (x"10000001"&a(1)&x"0000",  --39
                           x"10000002"&a(2)&x"0000",  --38
                            x"10000003"&a(3)&x"0000",  --37
                             x"10000004"&a(4)&x"0000",  --36

                              x"10010001"&a(1)&x"0000",  --35
                           x"10010002"&a(2)&x"0000",     --34
                            x"10010003"&a(3)&x"0000",    --33
                             x"10010004"&a(4)&x"0000",    --32

                            x"10020001"&a(1)&x"0000",     --31
                           x"10020002"&a(2)&x"0000",      --30
                            x"10020003"&a(3)&x"0000",     --29
                             x"10020004"&a(4)&x"0000",     --28

                              x"10030001"&a(1)&x"0000",    --27
                           x"10030002"&a(2)&x"0000",       --26
                            x"10030003"&a(3)&x"0000",      --25
                             x"10030004"&a(4)&x"0000",     --24
                                      
                             x"10040001"&a(1)&x"0000",     --23
                           x"10040002"&a(2)&x"0000",       --22
                            x"10040003"&a(3)&x"0000",      --21
                             x"10040004"&a(4)&x"0000",     --20

                              x"10050001"&a(1)&x"0000",    --19
                           x"10050002"&a(2)&x"0000",       --18
                            x"10050003"&a(3)&x"0000",      --17
                             x"10050004"&a(4)&x"0000",      --16

                            x"10060001"&a(1)&x"0000",       --15
                           x"10060002"&a(2)&x"0000",        --14
                            x"10060003"&a(3)&x"0000",       --13
                             x"10060004"&a(4)&x"0000",      --12

                              x"10070001"&a(1)&x"0000",     --11
                           x"10070002"&a(2)&x"0000",        --10
                            x"10070003"&a(3)&x"0000",         --9
                             x"10070004"&a(4)&x"0000",       --8
                                 
                             x"10080001"&a(1)&x"0000",        --7
                           x"10080002"&a(2)&x"0000",          --6
                            x"10080003"&a(3)&x"0000",         --5
                             x"10080004"&a(4)&x"0000",         --4

                              x"10090001"&a(1)&x"0000",        --3
                           x"10090002"&a(2)&x"0000",            --2
                            x"10090003"&a(3)&x"0000",           --1
                             x"10090004"&a(4)&x"0000"           --0
                                     );
begin
 U1_mux: entity work.mux41(muxarch)
Port map (D1in=>D1in_sg, D2in=>D2in_sg, D3in=>D3in_sg, D4in=>D4in_sg, s=>s, Dout=>mux_out);



--------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------input fifos---------------------------------------------------------
-------------------------------------------------------------------------------------
fifo1in: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_1_in, POP=> POP_1_in, init=>init,
         DIN => D1in, DOUT => D1in_sg,
         FULL=>FULL_1_in,EMPTY => EMPTY_1_in,NOPUSH=>NOPUSH_1_in,NOPOP=>NOPOP_1_in
           ); 

fifo2in: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_2_in, POP=> POP_2_in, init=>init,
         DIN => D2in, DOUT => D2in_sg,
         FULL=>FULL_2_in,EMPTY => EMPTY_2_in,NOPUSH=>NOPUSH_2_in,NOPOP=>NOPOP_2_in
           ); 

fifo3in: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_3_in, POP=> POP_3_in, init=>init,
         DIN => D3in, DOUT => D3in_sg,
         FULL=>FULL_3_in,EMPTY => EMPTY_3_in,NOPUSH=>NOPUSH_3_in,NOPOP=>NOPOP_3_in
           ); 

fifo4in: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_4_in, POP=> POP_4_in, init=>init,
         DIN => D4in, DOUT => D4in_sg,
         FULL=>FULL_4_in,EMPTY => EMPTY_4_in,NOPUSH=>NOPUSH_4_in,NOPOP=>NOPOP_4_in
           ); 

-----------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------output fifos------------------------------------------------------------

fifo1out: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_1_out, POP=> POP_1_out, init=>init,
         DIN => D1out_sg, DOUT => D1out,
         FULL=>FULL_1_out,EMPTY => EMPTY_1_out,NOPUSH=>NOPUSH_1_out,NOPOP=>NOPOP_1_out
           ); 

fifo2out: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_2_out, POP=> POP_2_out, init=>init,
         DIN => D2out_sg, DOUT => D2out,
         FULL=>FULL_2_out,EMPTY => EMPTY_2_out,NOPUSH=>NOPUSH_2_out,NOPOP=>NOPOP_2_out
           ); 

fifo3out: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_3_out, POP=> POP_3_out, init=>init,
         DIN => D3out_sg, DOUT => D3out,
         FULL=>FULL_3_out,EMPTY => EMPTY_3_out,NOPUSH=>NOPUSH_3_out,NOPOP=>NOPOP_3_out
           ); 

fifo4out: entity work.FIFO(TOP_HIER)
generic map (M=> M, N=> N)
port map (clk =>clk, PUSH => PUSH_4_out, POP=> POP_4_out, init=>init,
         DIN => D4out_sg, DOUT => D4out,
         FULL=>FULL_4_out,EMPTY => EMPTY_4_out,NOPUSH=>NOPUSH_4_out,NOPOP=>NOPOP_4_out
           ); 


clk_proc : process(clk,rst) 
  begin
   if (rst ='1') then
      current_state <= idle;
	elsif (clk ='1' and clk'event) then 
	current_state <= next_state;
	end if;
 
end process clk_proc;


eval : process (current_state, init)
variable i,j : count_integer:= 0 ;
 variable route_path : std_logic_vector(63 downto 0);
begin

case current_state is
when idle =>

PUSH_1_in <= '1';
PUSH_2_in <= '1';
PUSH_3_in <= '1';
PUSH_4_in <= '1';

POP_1_in <= '1';
POP_2_in <= '1';
POP_3_in <= '1';
POP_4_in <= '1';

traffic_val(1) <= x"0000";
traffic_val(2) <= x"0000";
traffic_val(3) <= x"0000";
traffic_val(4) <= x"0000";
if (init ='1') then
s <= "00";
next_state <=idle;
else 
next_state <= route;
end if;

------------------------------------------------
---- route state assigns route_sg the output of mux by updating the counter----------
----------------------------------------------------------------------
when route =>

if (s ="11") then
s <="00";
else
s <= s+1;
end if;
route_sg <=mux_out;
next_state <= compare;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
----comparing signal value with rvt, storing packets with same ID in another array-------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

when compare  =>
for i in 0 to 39 loop 
if (route_sg(63 downto 48) = rvt_signal(i)(63 downto 48)) then
temparray_sg(j) <= rvt_signal(i);
j := j+1;
end if;
end loop;
val_j <= j;
if (j = 0) then
next_state <= route;
end if; 
next_state <= analyze;

---------------------------------------------------
---------------------------------------------------
-- vector table values with matching ID to the signal are now stored in a temp array for further processing
---------------------------------------------------
---------------------------------------------------
when analyze =>
route_path := temparray_sg(0);
for i in 1 to val_j loop 
if (temparray_sg(i)(31 downto 16) < route_path(31 downto 16)) then
route_path := temparray_sg(i);         ----find the minimum traffic path.
end if;
end loop;
j:=0;
val_j <= 0;
packet_route <= route_path;
next_state <= output_route;

-------------route it to appropriate gateway output fifo---------------------------------
when output_route =>
if (packet_route(47 downto 32) = x"0001") then 
D1out_sg <= route_sg;
PUSH_1_out <='1';
traffic_val(1) <= traffic_val(1) +1;

elsif (packet_route(47 downto 32) = x"0002") then 
D2out_sg <= route_sg;
PUSH_2_out <='1';
traffic_val(2) <= traffic_val(2) +1;

elsif (packet_route(47 downto 32) = x"0003") then 
D3out_sg <= route_sg;
PUSH_3_out <='1';
traffic_val(3) <= traffic_val(3) +1;

elsif (packet_route(47 downto 32) = x"0004") then 
D4out_sg <= route_sg;
PUSH_4_out <='1';
traffic_val(4) <= traffic_val(4) +1;
end if;
next_state <= traffic_update;

when traffic_update =>
---update traffic details-----------

rvt_signal(0)(31 downto 16) <= traffic_val(4);
rvt_signal(4)(31 downto 16) <= traffic_val(4);
rvt_signal(8)(31 downto 16) <= traffic_val(4);
rvt_signal(12)(31 downto 16) <= traffic_val(4);
rvt_signal(16)(31 downto 16) <= traffic_val(4);
rvt_signal(20)(31 downto 16) <= traffic_val(4);
rvt_signal(24)(31 downto 16) <= traffic_val(4);
rvt_signal(28)(31 downto 16) <= traffic_val(4);
rvt_signal(32)(31 downto 16) <= traffic_val(4);
rvt_signal(36)(31 downto 16) <= traffic_val(4);


rvt_signal(1)(31 downto 16) <= traffic_val(3);
rvt_signal(5)(31 downto 16) <= traffic_val(3);
rvt_signal(9)(31 downto 16) <= traffic_val(3);
rvt_signal(13)(31 downto 16) <= traffic_val(3);
rvt_signal(17)(31 downto 16) <= traffic_val(3);
rvt_signal(21)(31 downto 16) <= traffic_val(3);
rvt_signal(25)(31 downto 16) <= traffic_val(3);
rvt_signal(29)(31 downto 16) <= traffic_val(3);
rvt_signal(33)(31 downto 16) <= traffic_val(3);
rvt_signal(37)(31 downto 16) <= traffic_val(3);

rvt_signal(2)(31 downto 16) <= traffic_val(2);
rvt_signal(6)(31 downto 16) <= traffic_val(2);
rvt_signal(10)(31 downto 16) <= traffic_val(2);
rvt_signal(14)(31 downto 16) <= traffic_val(2);
rvt_signal(18)(31 downto 16) <= traffic_val(2);
rvt_signal(22)(31 downto 16) <= traffic_val(2);
rvt_signal(26)(31 downto 16) <= traffic_val(2);
rvt_signal(30)(31 downto 16) <= traffic_val(2);
rvt_signal(34)(31 downto 16) <= traffic_val(2);
rvt_signal(38)(31 downto 16) <= traffic_val(2);

rvt_signal(3)(31 downto 16) <= traffic_val(1);
rvt_signal(7)(31 downto 16) <= traffic_val(1);
rvt_signal(11)(31 downto 16) <= traffic_val(1);
rvt_signal(15)(31 downto 16) <= traffic_val(1);
rvt_signal(19)(31 downto 16) <= traffic_val(1);
rvt_signal(23)(31 downto 16) <= traffic_val(1);
rvt_signal(27)(31 downto 16) <= traffic_val(1);
rvt_signal(31)(31 downto 16) <= traffic_val(1);
rvt_signal(35)(31 downto 16) <= traffic_val(1);
rvt_signal(39)(31 downto 16) <= traffic_val(1);

POP_1_out <='1';
POP_2_out <='1';
POP_3_out <='1';
POP_4_out <='1';

pin<='1';
next_state <= route;

when others =>  
next_state <= idle;

end case;

end process eval;
end architecture behave;










