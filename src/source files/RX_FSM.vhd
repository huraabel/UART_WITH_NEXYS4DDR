

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RX_FSM is
   Port (clk: in STD_LOGIC;
 RX_RDY: out std_logic;
 RX_DATA: out std_logic_Vector(7 downto 0);
 BAUD_EN: IN STD_LOGIC;
 rst:in std_logic;
 rx:in std_logic );
end RX_FSM;

architecture Behavioral of RX_FSM is

type state is (idle , start,bits, stop,waits);
signal curent_state : state;
signal baud_cnt : std_logic_vector (3 downto 0) := "0000";
signal bit_cnt : std_logic_vector( 2 downto 0) := "000";

begin
    
    process( clk, rst, bit_cnt, baud_cnt)
    begin
    
    if(rst = '1') then curent_state <= idle ; bit_cnt<="000";
    
    elsif ( rising_edge(clk)) then
        if(baud_en = '1') then
            
            
            case curent_state is
                when idle => baud_cnt <= "0000";
                             bit_cnt <= "000";
                             if( rx ='0') then
                             curent_state <= start;
                             else
                             curent_state <= idle;
                             end if; 
                when start =>   
                                if(rx = '1') then
                                    curent_state <= idle;
                                elsif(baud_cnt < 7) then
                                    baud_cnt<= baud_cnt + 1;
                                    curent_state <= start;
                                elsif(baud_cnt =7 and rx ='0') then
                                    baud_cnt <= "0000";
                                    curent_state <= bits;
                                end if;
               
               when bits => baud_cnt<= baud_cnt + 1;
                            if( baud_cnt = 15) then
                                rx_data(conv_integer(bit_cnt)) <= rx;
                                baud_cnt <= "0000";
                                bit_cnt <= bit_cnt + 1;
                                
                                
                                if(bit_cnt = 7) then
                                    baud_cnt <= "0000";
                                    bit_cnt <= "000";
                                    curent_state <= stop;
                                else
                                    curent_state <= bits;
                                end if;
                            else
                                curent_state <= bits;    
                            end if;
                                
               when stop =>   if( baud_cnt <15 ) then
                                baud_cnt <= baud_cnt +1;
                                curent_state <= stop;
                              else
                                baud_cnt <= "0000";
                                curent_state <= waits;
                              end if;   
               
               when waits =>  if( baud_cnt <7 ) then
                                   baud_cnt <= baud_cnt +1;
                                   curent_state <= waits;
                               else  
                                    baud_cnt <= "0000";
                                    curent_state <= idle;
                               end if;
            end case;
        end if;
    end if;
    
    
    end process;
    
    process(curent_state)
    begin
    case curent_state is
    when idle => rx_rdy <= '0';
    when start => rx_rdy <= '0';
    when bits => rx_rdy <= '0';
    when stop => rx_rdy <= '0';
    when waits => rx_rdy <= '1';
    end case;
    end process;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

end Behavioral;
