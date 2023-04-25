library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity master_spi_3_4_hilos is
port(nRst:        in std_logic;							  -- Reset asíncrono
     clk:         in std_logic;                           -- 50 MHz
     -- Config
     MSB_1st:     in std_logic;							  -- 0 -> modo MSB First, 1 -> modo LSB First
     mode_3_4_h:  in std_logic;							  -- 0 -> modo 3 hilos, 1 -> modo 4 hilos
     str_sgl_ins: in std_logic;							  -- 0 -> modo streaming, 1 -> modo single instruction

     -- Ctrl_SPI
     start:       in     std_logic;                       -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
     no_bytes:    in     std_logic_vector(2 downto 0);    -- Numero de bytes totales en la transferencia (incluyendo direccion) 
     dato_in:     in     std_logic_vector(47 downto 0);   -- dato de entrada (alineado a la izquierda)
     dato_rd:     buffer std_logic_vector(7 downto 0);    -- valor del byte leido
     ena_rd:      buffer std_logic;                       -- valida a nivel alto a dato_rd -> Ignorar en operacion de escritura
     rdy:         buffer std_logic;                       -- unidad preparada para aceptar start

     -- bus SPI
     nCS:         buffer std_logic;                      -- chip select
     SPC:         buffer std_logic;                      -- clock SPI (25 MHz) 
     SDI:         in     std_logic;                      -- Master Data input (connected to slave SDO)
     SDIO:        inout std_logic);                      -- Master Data Output (connected to slave SDI)
     
end entity;

architecture rtl of master_spi_3_4_hilos is
 --Reloj del bus
 signal cnt_SPC:     std_logic_vector(2 downto 0);   --Para generar SPC
 signal fdc_cnt_SPC: std_logic;
 signal SPC_posedge: std_logic;
 signal SPC_negedge: std_logic;

 constant SPC_LH: natural := 5;                      -- Duracion de los niveles de SPC
  
 -- Contador de bits y bytes transmitidos
 signal cnt_bits_SPC: std_logic_vector(6 downto 0);  -- maximo {stream 10 x8 } = 80

 -- Sincro SDI y Registro de transmision y recepcion
 signal SDI_syn, SDI_meta: std_logic;
 signal SDIO_syn, SDIO_meta: std_logic; 

 signal reg_SPI: std_logic_vector(47 downto 0);
 signal nWR_RD:  std_logic_vector(1 downto 0);

 signal n_ctrl_SDIO, n_ctrl_SDIO_dly1, n_ctrl_SDIO_dly2: std_logic; 
 signal SDIO_o:  std_logic;

 -- Para el control
 signal fin: std_logic;
 signal no_bytes_r: std_logic_vector(2 downto 0);

begin
  -- Generacion de nCS:
  process(nRst, clk)
  begin
    if nRst = '0' then
      nCS <= '1';

    elsif clk'event and clk = '1' then
      if start = '1' and nCS = '1' then
        nCS <= '0';

      elsif fin = '1' and SPC_negedge = '1' then
        nCS <= '1';

      end if;
    end if;
  end process;
  
  rdy <= nCS;

  -- Generacion de SPC:
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_SPC <= (1 => '1', others => '0');
      SPC <= '0';

    elsif clk'event and clk = '1' then
      if nCS = '1' then  
        cnt_SPC <= (1 => '1', others => '0');
        SPC <= '0';

      elsif fdc_cnt_SPC = '1' then  
        SPC <= not SPC;
        cnt_SPC <= (0 => '1', others => '0');

      else
        cnt_SPC <= cnt_SPC + 1;

      end if;
    end if;
  end process;

  fdc_cnt_SPC <= '1' when cnt_SPC = SPC_LH else
                 '0';

  SPC_posedge <= SPC when cnt_SPC = 1 else
                 '0'; 

  SPC_negedge <= not SPC when cnt_SPC = 1 else
                 '0'; 

  -- Cuenta bits y bytes:
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_bits_SPC <= (others => '0');
      
    elsif clk'event and clk = '1' then  
      if SPC_posedge = '1' then  
        cnt_bits_SPC <= cnt_bits_SPC + 1;

      elsif nCS = '1' then
        cnt_bits_SPC <= (others => '0');

      end if;
    end if;
  end process;

  -- Registro
  process(nRst, clk)
  begin
    if nRst = '0' then
      reg_SPI <= (others => '0');
      SDI_syn <= '0';
      SDIO_syn <= '0';
      SDI_meta <= '0';
      SDIO_meta <= '0';

    elsif clk'event and clk = '1' then  
      SDI_meta  <= SDI; 
      SDI_syn  <= SDI_meta;
      SDIO_meta <= SDIO; 
      SDIO_syn <= SDIO_meta; 

      if start = '1' and nCS = '1' then
          nWR_RD <= dato_in(47) & dato_in(23);
          if MSB_1st = '0' then
            reg_SPI <= dato_in;

          elsif str_sgl_ins = '0' then
            reg_SPI(15 downto 0)  <= dato_in(47 downto 32);
            reg_SPI(23 downto 16) <= dato_in(31 downto 24);
            reg_SPI(31 downto 24) <= dato_in(23 downto 16);
            reg_SPI(39 downto 32) <= dato_in(15 downto 8);
            reg_SPI(47 downto 40) <= dato_in(7 downto 0);

          else             
            reg_SPI(15 downto 0)  <= dato_in(47 downto 32);
            reg_SPI(23 downto 16) <= dato_in(31 downto 24);
            reg_SPI(39 downto 24) <= dato_in(23 downto 8);
            reg_SPI(47 downto 40) <= dato_in(7 downto 0);

          end if;

      elsif SPC_negedge = '1' then
        if MSB_1st = '0' then
          reg_SPI(47 downto 1) <= reg_SPI(46 downto 0);

        else
          reg_SPI(46 downto 0) <= reg_SPI(47 downto 1);

        end if;

      elsif SPC_posedge = '1' and cnt_bits_SPC /= 0 then
        if MSB_1st = '0' then
          if mode_3_4_h = '0' then
            reg_SPI(0) <= SDIO_syn;

          else
            reg_SPI(0) <= SDI_syn;

          end if;

        else
          if mode_3_4_h = '0' then
            reg_SPI(47) <= SDIO_syn;

          else
            reg_SPI(47) <= SDI_syn;

          end if;

        end if;
      end if;
    end if;
  end process;

  ena_rd <= SPC_negedge and nWR_RD(1) when cnt_bits_SPC(2 downto 0) = 0 and cnt_bits_SPC(6 downto 3) > 2 and str_sgl_ins = '0' else
            SPC_negedge and nWR_RD(1) when cnt_bits_SPC(2 downto 0) = 0 and cnt_bits_SPC(6 downto 3) = 3 and str_sgl_ins = '1' else  
            SPC_negedge and nWR_RD(0) when cnt_bits_SPC(2 downto 0) = 0 and cnt_bits_SPC(6 downto 3) = 6 and str_sgl_ins = '1' else  
            '0';  

  dato_rd <= reg_SPI(7 downto 0) when MSB_1st = '0' else
             reg_SPI(47 downto 40);




  SDIO_o <= reg_SPI(47) when MSB_1st = '0' else
            reg_SPI(0);

  n_ctrl_SDIO <= nCS              when cnt_bits_SPC(6 downto 3) < 2                        else
                 nCS or nWR_RD(1) when cnt_bits_SPC(6 downto 3) = 2                        else
                 nCS or nWR_RD(1) when cnt_bits_SPC(6 downto 3) > 2  and str_sgl_ins = '0' else
                 nCS              when cnt_bits_SPC(6 downto 3) < 5  and str_sgl_ins = '1' else
                 nCS or nWR_RD(0) when cnt_bits_SPC(6 downto 3) = 5                        else  
                 '1';

  process(nRst, clk)
  begin
    if nRst = '0' then
		n_ctrl_SDIO_dly1 <= '1';
		n_ctrl_SDIO_dly2 <= '1';
		
    elsif clk'event and clk = '1' then  
		n_ctrl_SDIO_dly1 <= n_ctrl_SDIO;
		n_ctrl_SDIO_dly2 <= n_ctrl_SDIO_dly1;

    end if;
  end process;

  SDIO <= SDIO_o when n_ctrl_SDIO_dly2 = '0' else 
          'Z'; 

  -- Control heuristico
  process(nRst, clk)
  begin
    if nRst = '0' then
      no_bytes_r <= (others => '0');

    elsif clk'event and clk = '1' then  
      if start = '1' and nCS = '1' then
        no_bytes_r <= no_bytes;

      end if;
    end if;
  end process;

  fin <= '1' when cnt_bits_SPC(6 downto 3) = no_bytes_r else
         '0';
 
end rtl;
