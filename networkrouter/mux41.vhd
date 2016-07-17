library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity mux41 is 

PORT (
      D1in,D2in,D3in,D4in :in std_logic_vector(63 downto 0);
      s: in std_logic_vector(1 downto 0);
      Dout : out std_logic_vector(63 downto 0)
     );
end entity mux41;


Architecture muxarch of mux41 is 
begin
process(s)
variable temp : std_logic_vector (63 downto 0);
begin
if ( s= "00") then 
temp := D1in;
elsif (s="01") then
 temp := D2in;
elsif (s= "10") then 
temp := D3in;
elsif (s= "11") then 
temp := D4in;
end if;
Dout <=temp;
end process;
end architecture;