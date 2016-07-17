library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fifo_tb is 
generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO

end entity fifo_tb;


Architecture fifotb of fifo_tb is

component FIFO is

generic (N: integer := 8; -- number of address bits for 2**N address locations
M: integer := 64); -- number of data bits to/from FIFO
 port (CLK, PUSH, POP, INIT: in std_logic;
 DIN: in std_logic_vector(M-1 downto 0);
DOUT: out std_logic_vector(M-1 downto 0);
 FULL, EMPTY, NOPUSH, NOPOP: out std_logic
);


end component;


signal CLK, PUSH, POP, INIT:  std_logic;
 signal DIN:  std_logic_vector(M-1 downto 0);
signal DOUT:  std_logic_vector(M-1 downto 0);
signal FULL, EMPTY, NOPUSH, NOPOP:  std_logic;
constant clk_period : time := 10ns;

begin

router_E1 : entity work.FIFO(TOP_HIER)
generic map(M => M, N=> N)
port map 
(
CLK => CLK , PUSH => PUSH, POP=> POP, INIT =>INIT,
 DIN => DIN,
DOUT => DOUT,
 FULL => FULL, EMPTY => EMPTY, NOPUSH => NOPUSH, NOPOP => NOPOP
);

stim_proc: process
   begin     
--rst <= '1';
--wait for 20 ns;
init<='1';
wait for 10ns;
init <='0';
PUSH <= '1';
POP <='0';
DIN <= x"1000000000001CCC";
wait for 10ns;
PUSH <='1';
POP <='1';
DIN <= x"CDEF000000001CCC";
wait for 10ns;
PUSH <= '1';
POP <='0';
wait for 10ns;
DIN <= x"1FDE000000001CCC";
wait for 10ns;

DIN <= x"2600000567341CCC";
wait for 10ns;

DIN <= x"7853400000001CCC";
wait for 10ns;

PUSH <='0';
POP <='1';
wait for 10ns;
PUSH <='0';
POP <='1';
DIN <= x"78534FDE00001CCC";
wait for 10ns;

DIN <= x"2600000567341CCC";
wait for 10ns;

PUSH <='0';
POP <='1';

        wait;

end process stim_proc;

clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process clk_process;
end fifotb;