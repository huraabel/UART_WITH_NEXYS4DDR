
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TX_FSM is
 Port (
        clk: in std_logic;
        TX_DATA: in std_logic_vector(7 downto 0);
        TX_EN : in std_logic;
        RST : in std_logic;
        BAUD_EN : in std_logic;
        
        TX : out std_logic;
        TX_RDY : out std_logic );
end TX_FSM;

architecture Behavioral of TX_FSM is
type state is (idle, start, bits, stop);
signal curent_state: state; 
signal bit_cnt : std_logic_vector(2 downto 0):="000";

begin
    
    
    process(clk,rst,tx_en,bit_cnt)
    begin
    
    
        if(rst = '1') then curent_state <= idle ; bit_cnt <= "000";
        
        elsif( rising_edge(clk)) then
              if(BAUD_EN = '1') then
                case curent_state is
                    
                    when idle => bit_cnt <= "000";
                                 if (tx_en = '1') then
                                    curent_state <= start;
                                 else
                                    curent_state<= idle;
                                 end if;
                                 
                                 
                    when start => bit_cnt <= "000";
                                  curent_state <= bits;
                    
                    when bits =>  if( bit_cnt < 7) then
                                    bit_cnt <= bit_cnt + 1;
                                    curent_state <= bits;
                                  else
                                    curent_state <= stop;
                                  end if;
                    when stop =>  bit_cnt <= "000";
                                  curent_state <= idle;  
                
                end case;
                end if;
       end if;
       
    
    end process;
    
    
    process(curent_state)
    begin
        case curent_state is
             when idle => tx<= '1'; tx_rdy <= '1';
             when start => tx <= '0'; tx_rdy<='0';
             when bits => tx <= tx_data(conv_integer(bit_cnt)); tx_rdy<='0';
             when stop => tx<='1'; tx_rdy<='0';
        end case;
    
    end process;
    
    
    
    
    
    
    
    
    
    
    
    

end Behavioral;
