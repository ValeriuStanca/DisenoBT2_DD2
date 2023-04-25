library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity presentacion is
port(clk:           in     std_logic;							-- 50 MHz
     nRst:          in     std_logic;							-- Reset asíncrono
     tic_2_5ms:     in     std_logic;							-- tic de 2,5 milisegundos
     tic_0_5s:      in     std_logic;							-- tic de 500 milisegundos
     info_disp:     in     std_logic_vector(2 downto 0);	    -- bits(1 downto 0) -> display que está siendo editado, bit(2) -> modo de edición de registros de configuracion (0) o de operacion (1)
     reg_tx:        in     std_logic_vector(15 downto 0);	    -- Información para los cuatro dígitos hexadecimales ( uno por display)
     seg:           buffer std_logic_vector(7 downto 0);		-- Salida para los segmentos del display
     mux_disp:      buffer std_logic_vector(3 downto 0));		-- Salida para la habilitación de los displays
          
end entity;

architecture rtl of presentacion is
  -- Multiplexacion de displays:
  signal reg_mux: std_logic_vector(3 downto 0);
  signal HEX:     std_logic_vector(3 downto 0);
  signal punto:   std_logic;
  
begin
  -- Control multiplexacion de displays
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_mux <= (0 => '0', others => '1');

    elsif clk'event and clk = '1' then
      if tic_2_5ms = '1' then      
        reg_mux <= reg_mux(2 downto 0)&reg_mux(3);

      end if;
    end if;
  end process;

  -- Segnales de multiplexacion
  mux_disp <= reg_mux when info_disp(2) = '0' else
              reg_mux or "0100";                    -- Apaga el disp cuando reg control

  -- Mux decodificador BCD-7seg
  HEX <= reg_tx(3 downto 0)  when reg_mux = X"E"                         else
         reg_tx(7 downto 4)  when reg_mux = X"D"                         else
         reg_tx(11 downto 8) when reg_mux = X"B"                         else
         reg_tx(11 downto 8) when reg_mux = X"7" and info_disp(2) = '1'  else
         reg_tx(15 downto 12);

  -- Decodificador HEX  a 7 segmentos: salidas activas a nivel alto
  process(HEX)
  begin
    case HEX is            --abcdefg
      when "0000" => seg(6 downto 0) <= "1111110"; -- 0 
      when "0001" => seg(6 downto 0) <= "0110000"; -- 1
      when "0010" => seg(6 downto 0) <= "1101101"; -- 2 
      when "0011" => seg(6 downto 0) <= "1111001"; -- 3
      when "0100" => seg(6 downto 0) <= "0110011"; -- 4
      when "0101" => seg(6 downto 0) <= "1011011"; -- 5
      when "0110" => seg(6 downto 0) <= "1011111"; -- 6
      when "0111" => seg(6 downto 0) <= "1110000"; -- 7
      when "1000" => seg(6 downto 0) <= "1111111"; -- 8
      when "1001" => seg(6 downto 0) <= "1110011"; -- 9

      when "1010" => seg(6 downto 0) <= "1110111"; -- A
      when "1011" => seg(6 downto 0) <= "0011111"; -- B
      when "1100" => seg(6 downto 0) <= "1001110"; -- C
      when "1101" => seg(6 downto 0) <= "0111101"; -- D
      when "1110" => seg(6 downto 0) <= "1001111"; -- E
      when "1111" => seg(6 downto 0) <= "1000111"; -- F
      when others => seg(6 downto 0) <= "XXXXXXX";
  
    end case;
  end process;

  -- Intermitencia edicion
  -- Control multiplexacion de displays
  process(clk, nRst)
  begin
    if nRst = '0' then
      punto <= '0';

    elsif clk'event and clk = '1' then
      if tic_0_5s = '1' then      
        punto <= not punto;

      end if;
    end if;
  end process;

  seg(7) <= punto when info_disp = 0 and reg_mux = X"E" else
            punto when info_disp = 4 and reg_mux = X"E" else
            punto when info_disp = 1 and reg_mux = X"D" else
            punto when info_disp = 5 and reg_mux = X"D" else
            punto when info_disp = 2 and reg_mux = X"B" else
            punto when info_disp = 3 and reg_mux = X"7" else
            punto when info_disp = 6 and reg_mux = X"7" else
            '0';


end rtl;