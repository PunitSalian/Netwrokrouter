  library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity DRAM is
 generic (W: integer := 8; K:integer := 64);
 port (WR,clk: in std_logic;
 ADDR: in std_logic_vector(W-1 downto 0);
DIN: in std_logic_vector(K-1 downto 0);
DOUT: out std_logic_vector(K-1 downto 0)
 );
end entity DRAM;


Architecture behave of DRAM is

type matrix is array(1000 downto 0) of std_logic_vector (K-1 downto 0);
signal arr : matrix;
signal i : integer range 0 to 50;
signal data_add: std_logic_vector(W-1 downto 0):="00000000";


begin
--i <= to_integer (unsigned(ADDR((W-1) downto W/2)));
--j <= to_integer (unsigned(ADDR (((W/2)-1) downto 0)));
process (clk,WR) 
variable temp: std_logic_vector(K-1 downto 0);
begin
if (clk='1' and clk'event) then
if (WR = '1') then 
arr(to_integer(unsigned(ADDR))) <= DIN;

else 
--data_add <= ADDR;
DOUT <= arr(to_integer(unsigned(ADDR)));
end if;
end if;  
end process;


end behave;