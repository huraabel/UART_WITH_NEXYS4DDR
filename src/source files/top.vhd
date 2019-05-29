
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port ( 
    btn : in std_logic_vector(4 downto 0);
    clk : in std_logic;
    cat : out std_logic_vector (6 downto 0);
    led : out std_logic_vector(15 downto 0);
    sw : in std_logic_vector(15 downto 0);
    an : out std_logic_vector (7 downto 0);
    
    RX: in std_logic;
    TX :out std_logic
    
   );
end top;





architecture Behavioral of top is

    component TX_FSM is
  Port ( 
         clk: in std_logic;   
         TX_DATA: in std_logic_vector(7 downto 0);
         TX_EN : in std_logic;
         RST : in std_logic;
         BAUD_EN : in std_logic;
         
         TX : out std_logic;
         TX_RDY : out std_logic
  
  );
 end component TX_FSM;
 
 component RX_FSM is
   Port (clk: in STD_LOGIC;
   RX_RDY: out std_logic;
   RX_DATA: out std_logic_Vector(7 downto 0);
   BAUD_EN: IN STD_LOGIC;
   rst:in std_logic;
   rx:in std_logic );
 end component RX_FSM;
 
 
 component MPG is
   port(
       btn  : in std_logic ;     
       clk : in std_logic;
       enable: out std_logic
       );
   end component;
 
   component SSD is
   Port ( 
            digit1 : in std_logic_vector (3 downto 0);
            digit2 : in std_logic_vector (3 downto 0);
            digit3 : in std_logic_vector (3 downto 0);
            digit4 : in std_logic_vector (3 downto 0);  
            clk : in std_logic;
            cat : out std_logic_vector (6 downto 0);
            an : out std_logic_vector (3 downto 0)
            );
   end component;

 signal baud_cnt : std_logic_vector(15 downto 0):=X"0000";
   signal baud_en : std_logic;
   
   signal tx_en : std_logic;
   signal tx_mpg : std_logic;
   signal res: std_logic;
   signal tx_data: std_logic_vector(7 downto 0);
   signal TX_RDY :  std_logic;
   signal tx_1 : std_logic;
   
   
      -- RX
   signal  RX_RDY: std_logic;
   signal  RX_DATA: std_logic_Vector(7 downto 0);
   signal  RX_BAUD_EN:  STD_LOGIC;
   signal  rx_rst: std_logic;
   signal  rx_1: std_logic ;
   signal  rx_baud_cnt :std_logic_vector(15 downto 0):=X"0000";
begin
    
     -- baud_en generator TX
   process(clk)  
   begin
   if( rising_edge(clk)) then
       if (baud_cnt = "0010100010110000" ) then    --10416
           baud_en <= '1';
           baud_cnt<=X"0000";
       else
           baud_en <= '0';
           baud_cnt <= baud_cnt + 1;
       end if;
   end if;
   end process;
   
   -- tx_en generate
   process(clk)
       begin
       if(rising_edge(clk)) then
            if( tx_mpg = '1') then
                      tx_en <= '1';       
            end if;
           
           if(baud_en = '1') then
               tx_en <= '0';
           end if;
           
       end if;
    end process;
       
    M3: MPG port map (btn(2), clk, res);
    M4: MPG port map (btn(3), clk, tx_mpg);
          
   UART : TX_FSM port map(clk,tx_data,tx_en,res,baud_en,tx_1,TX_RDY);
   
   tx_data<= sw(15 downto 8);
   led(15) <= tx_1;
   led(14) <= tx_rdy;
   tx<= tx_1;
   
   
   --baud generator RX
   process(clk)
   begin
       if(rising_edge(clk)) then
           if( rx_baud_cnt = 651 ) then
               rx_baud_en <= '1';
               rx_baud_cnt<=X"0000";
           else
               rx_baud_en <= '0';
               rx_baud_cnt<= rx_baud_cnt + 1;
           end if;
       end if;
   end process;
   
   UART_RX : RX_FSM port map (clk,rx_rdy, rx_data, rx_baud_en,res,rx);
   SSD2 : SSD port map (rx_data(3 downto 0), rx_data(7 downto 4), "0000", "0000",
                        clk, cat,an(7 downto 4) );
   

end Behavioral;
