library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity router_tb is 
generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO

end entity router_tb;


Architecture routertb of router_tb is

component router is

generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO
PORT (
D1in :in std_logic_vector((M-1) downto 0);
D2in :in std_logic_vector((M-1) downto 0);
D3in :in std_logic_vector((M-1) downto 0);
D4in :in std_logic_vector((M-1) downto 0) ;

D1out,D2out,D3out,D4out :out std_logic_vector((M-1) downto 0);
clk,rst,init : in std_logic
);


end component;


signal D1in,D2in,D3in,D4in : std_logic_vector((M-1) downto 0);
signal D1out,D2out,D3out,D4out : std_logic_vector((M-1) downto 0);

signal clk: std_logic;
signal rst: std_logic := '0';
signal init: std_logic := '1' ;
constant clk_period : time := 10ns;

begin

router_E1 : entity work.router(behave)
generic map(M => M, N=> N)
port map 
(
D1in => D1in,
D2in => D2in,
D3in => D3in,
D4in => D4in,
D1out =>D1out,
D2out =>D2out,
D3out =>D3out,
D4out =>D4out,
clk => clk,
rst => rst,
init => init
);

stim_proc: process
   begin     
--rst <= '1';
--wait for 20 ns;
init <='1';
wait for 20 ns;
init <='0';
wait for 10ns;
D1in <= x"1000000000001010";
D2in <= x"1000000000001AAA";
D3in <= x"1000000000001BBB";
D4in <= x"1000000000001CCC";

wait for 200 ns;
D1in <= x"1000000000001011";
D2in <= x"100000000000AAA1";
D3in <= x"100000000000BBB1";
D4in <= x"100000000000CCC1";

wait for 200 ns;
D1in <= x"1000000000001ABC";
D2in <= x"1000000000001BAD";
D3in <= x"1000000000001DDE";
D4in <= x"1000000000001FFE";


wait for 200 ns;
D1in <= x"1001000000001EFE";
D2in <= x"1001000000001BCD";
D3in <= x"1002000000001DFF";
D4in <= x"1002000000001FDE";


wait for 200 ns;
D1in <= x"1000000000001ABF";
D2in <= x"1003000000001BDC";
D3in <= x"1002000000001DDE";
D4in <= x"1006000000002FED";


wait for 200 ns;
D1in <= x"1000000000001BBC";
D2in <= x"1003000000001BED";
D3in <= x"1008000000001DCE";
D4in <= x"100800000000166E";




wait for 200 ns;
D1in <= x"1006000011001ABC";
D2in <= x"1002000011001AEC";
D3in <= x"1000000011001FFF";
D4in <= x"1001000011001CDE";


wait for 200 ns;
D1in <= x"10660000ABCD1011";
D2in <= x"1002000011423677";
D3in <= x"1000000011EDFFF";
D4in <= x"100100001FEDAAA";

wait for 200 ns;
D1in <= x"1006000011002222";
D2in <= x"1002000011003333";
D3in <= x"1000000011002345";
D4in <= x"1001000011001228";

wait for 200 ns;
D1in <= x"10060000110EDFCC";
D2in <= x"1002000011001AEC";
D3in <= x"1000000011001FFF";
D4in <= x"1001000011001CDE";

wait for 200 ns;
D1in <= x"10060000110034522";
D2in <= x"10020000110023111";
D3in <= x"100000001100ABBCC";
D4in <= x"10010000110098765";

wait for 200 ns;
D1in <= x"1006000011001ABE";
D2in <= x"1002000011001111";
D3in <= x"1000000011008765";
D4in <= x"1001000011005678";

--rst<='0';
--wait for 10ns;
--init <='0';
--wait for 5 ns;      

        wait;

end process stim_proc;

clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process clk_process;
end routertb;