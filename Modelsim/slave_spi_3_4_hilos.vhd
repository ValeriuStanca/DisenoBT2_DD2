library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity slave_spi_4_hilos is
port(nRst:        in     std_logic;							  -- Reset asíncrono
     clk:         in     std_logic;                           -- 50 MHz
     nCS:         buffer std_logic;                      -- chip select
     SPC:         buffer std_logic;                      -- clock SPI (25 MHz) 
     SDI:         out    std_logic;                      -- MISO(Master input Slave Output)
     SDIO:        in     std_logic);                      -- MOSI(Master Output Slave Input)
     
end entity;


