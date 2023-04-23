library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package pack_test_spi is
  procedure pulsar (signal   tic_tecla:   out std_logic;
                    signal   tecla:       out std_logic_vector(3 downto 0);
                    constant digito:      in  std_logic_vector(3 downto 0);
                    signal   clk:         in  std_logic);

  procedure set_modo_reg_op (signal   tic_tecla: out std_logic;
                             signal   tecla:     out std_logic_vector(3 downto 0);
                             signal   info_disp: in  std_logic_vector(2 downto 0);
                             signal   clk:       in  std_logic);

  procedure set_modo_reg_conf (signal   tic_tecla: out std_logic;
                               signal   tecla:     out std_logic_vector(3 downto 0);
                               signal   info_disp: in  std_logic_vector(2 downto 0);
                               signal   clk:       in  std_logic);

  procedure editar_reg_op (signal   tic_tecla:   out std_logic;
                           signal   tecla:       out std_logic_vector(3 downto 0);
                           signal   info_disp:   in  std_logic_vector(2 downto 0);
                           signal   reg_tx:      in  std_logic_vector(15 downto 0);
                           constant valor:       in  std_logic_vector(15 downto 0);
                           signal   clk:         in  std_logic);

  procedure editar_reg_conf (signal   tic_tecla:   out std_logic;
                             signal   tecla:       out std_logic_vector(3 downto 0);
                             signal   info_disp:   in  std_logic_vector(2 downto 0);
                             signal   reg_tx:      in  std_logic_vector(15 downto 0);
                             constant add:         in  std_logic_vector(3 downto 0);
                             constant valor:       in  std_logic_vector(7 downto 0);
                             signal   clk:         in  std_logic);

end package pack_test_spi;

package body pack_test_spi is

  procedure pulsar (signal   tic_tecla:   out std_logic;
                    signal   tecla:       out std_logic_vector(3 downto 0);
                    constant digito:      in  std_logic_vector(3 downto 0);
                    signal   clk:         in  std_logic) is
  begin
    wait until clk'event and clk = '1';
    tecla <= digito;
    tic_tecla <= '1';

    wait until clk'event and clk = '1';
    tic_tecla <= '0';
    
    wait until clk'event and clk = '1';

  end procedure pulsar;

  procedure set_modo_reg_op (signal   tic_tecla: out std_logic;
                             signal   tecla:     out std_logic_vector(3 downto 0);
                             signal   info_disp: in  std_logic_vector(2 downto 0);
                             signal   clk:       in  std_logic) is

  begin
    if info_disp(2) = '1' then
      pulsar(tic_tecla, tecla, X"C" , clk);

    end if;

  end procedure set_modo_reg_op;

  procedure set_modo_reg_conf (signal   tic_tecla: out std_logic;
                               signal   tecla:     out std_logic_vector(3 downto 0);
                               signal   info_disp: in  std_logic_vector(2 downto 0);
                               signal   clk:       in  std_logic) is

  begin
    if info_disp(2) = '0' then
      pulsar(tic_tecla, tecla, X"C" , clk);

    end if;

  end procedure set_modo_reg_conf;

  procedure editar_reg_op (signal   tic_tecla:   out std_logic;
                           signal   tecla:       out std_logic_vector(3 downto 0);
                           signal   info_disp:   in  std_logic_vector(2 downto 0);
                           signal   reg_tx:      in  std_logic_vector(15 downto 0);
                           constant valor:       in  std_logic_vector(15 downto 0);
                           signal   clk:         in  std_logic) is
    
  begin
    for i in 1 to 4 loop
      case info_disp(1 downto 0) is 
        when "00" =>
          while(reg_tx(3 downto 0) /= valor(3 downto 0)) loop
            if valor(3 downto 0) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when "01" =>
          while(reg_tx(7 downto 4) /= valor(7 downto 4)) loop
            if valor(7 downto 4) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when "10" =>
          while(reg_tx(11 downto 8) /= valor(11 downto 8)) loop
            if valor(11 downto 8) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when "11" =>
          while(reg_tx(15 downto 12) /= valor(15 downto 12)) loop
            if valor(15 downto 12) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when others => null;

      end case;
      pulsar(tic_tecla, tecla, X"D" , clk);

    end loop;
  end procedure;


  procedure editar_reg_conf (signal   tic_tecla:   out std_logic;
                             signal   tecla:       out std_logic_vector(3 downto 0);
                             signal   info_disp:   in  std_logic_vector(2 downto 0);
                             signal   reg_tx:      in  std_logic_vector(15 downto 0);
                             constant add:         in  std_logic_vector(3 downto 0);
                             constant valor:       in  std_logic_vector(7 downto 0);
                             signal   clk:         in  std_logic) is
    
  begin
    for i in 1 to 4 loop
      case info_disp(1 downto 0) is 
        when "00" =>
          while(reg_tx(3 downto 0) /= valor(3 downto 0)) loop
            if valor(3 downto 0) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when "01" =>
          while(reg_tx(7 downto 4) /= valor(7 downto 4)) loop
            if valor(7 downto 4) < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when "10" =>
          while(reg_tx(11 downto 8) /= add) loop
            if add < 9 then
              pulsar(tic_tecla, tecla, X"A" , clk);

            else
              pulsar(tic_tecla, tecla, X"B" , clk);

            end if;
            wait until clk'event and clk = '1';

          end loop;

        when others => null;

      end case;
      pulsar(tic_tecla, tecla, X"D" , clk);

    end loop;
  end procedure;



end package body pack_test_spi;