library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Processor is
	port(clk:in std_logic;
		 switch:in std_logic;
		 an:out std_logic_vector(3 downto 0);
		 seg:out std_logic_vector(6 downto 0));
end Processor;

architecture Behavioral of Processor is
	type reg_type is array(0 to 31)of std_logic_vector(31 downto 0);
	signal reg:reg_type:=(others=>(others=>'0'));
	signal state:integer:=-2;
	signal cmd:std_logic_vector(31 downto 0);
	signal opcode:std_logic_vector(5 downto 0);
	signal rs:std_logic_vector(4 downto 0);
	signal rt:std_logic_vector(4 downto 0);
	signal rd:std_logic_vector(4 downto 0);
	signal shamt:std_logic_vector(4 downto 0);
	signal funct:std_logic_vector(5 downto 0);
	signal adrs:std_logic_vector(15 downto 0);
    signal rt_copy:std_logic_vector(4 downto 0);
    signal rd_copy:std_logic_vector(4 downto 0);
	signal ena:std_logic:='1';
    signal wea:std_logic_vector(0 downto 0):="0";
    signal addra:std_logic_vector(11 downto 0):=(others=>'0');
    signal dina:std_logic_vector(31 downto 0):=(others=>'0');
    signal douta:std_logic_vector(31 downto 0);
    signal i:integer:=0;
    signal k:integer:=0;
	signal value:std_logic_vector(15 downto 0):=(others=>'0');
	signal counter:std_logic_vector(19 downto 0):=(others=>'0');
	signal position:std_logic_vector(1 downto 0):=(others=>'0');
	signal digit:std_logic_vector(3 downto 0):=(others=>'0');
    component blk_mem_gen_0 is
      port(
        clka:in std_logic;
        ena:in std_logic;
        wea:in std_logic_vector(0 downto 0);
        addra:in std_logic_vector(11 downto 0);
        dina:in std_logic_vector(31 downto 0);
        douta:out std_logic_vector(31 downto 0)
      );
	end component;
begin
    mem:blk_mem_gen_0 port map(clk,ena,wea,addra,dina,douta);
	process(clk)
		variable j: integer:=0;
	begin
		if(clk='1')and clk'event then
		    if(state=-2)then
				k<=k+1;
				state<=-1;
				addra<=std_logic_vector(to_unsigned(i,12));
				i<=i+1;
		    elsif(state=-1)then
    	        k<=k+1;
		        state<=0;
		        addra<=std_logic_vector(to_unsigned(i,12));
		        i<=i+1;
			elsif(state=0)then
    	        k<=k+1;
				state<=1;
				addra<=std_logic_vector(to_unsigned(i,12));
				cmd <= douta(31 downto 0);
                opcode<=douta(31 downto 26);
                rs<=douta(25 downto 21);
                rt<=douta(20 downto 16);
                rd<=douta(15 downto 11);
                shamt<=douta(10 downto 6);
                funct<=douta(5 downto 0);
                adrs<=douta(15 downto 0);
				i<=i+1;
   			elsif(state=1)then
    	        k<=k+1;
   			    addra<=std_logic_vector(to_unsigned(i,12));
				cmd <= douta(31 downto 0);
				opcode<=douta(31 downto 26);
				rs<=douta(25 downto 21);
				rt<=douta(20 downto 16);
				rd<=douta(15 downto 11);
				shamt<=douta(10 downto 6);
				funct<=douta(5 downto 0);
				adrs<=douta(15 downto 0);
				rt_copy<=rt;
				rd_copy<=rd; 
				if(cmd="00000000000000000000000000000000")then
					state<=2;
					k<=k;
					if j=2 then value<=reg(to_integer(unsigned(rd_copy)))(15 downto 0); 
					else value<=reg(to_integer(unsigned(rt_copy)))(15 downto 0); 
					end if; 
					--value<=adrs;
				elsif(opcode="000000")then
				    j:=2;
					if(funct="100000")then--add
						reg(to_integer(unsigned(rd)))<=std_logic_vector(signed(reg(to_integer(unsigned(rs))))+signed(reg(to_integer(unsigned(rt)))));
						--value<=rt(15 downto 0); 
						--value<=(std_logic_vector(signed(reg(to_integer(unsigned(rs))))+signed(reg(to_integer(unsigned(rt))))))(15 downto 0);
					elsif(funct="100010")then--sub
						reg(to_integer(unsigned(rd)))<=std_logic_vector(signed(reg(to_integer(unsigned(rs))))-signed(reg(to_integer(unsigned(rt)))));
						--value<=(std_logic_vector(signed(reg(to_integer(unsigned(rs))))-signed(reg(to_integer(unsigned(rt))))))(15 downto 0);
					elsif(funct="000000")then--sll
						reg(to_integer(unsigned(rd)))<=std_logic_vector(shift_left(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt))));
						--value<=(std_logic_vector(shift_left(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt)))))(15 downto 0);
					elsif(funct="000010")then--srl
						reg(to_integer(unsigned(rd)))<=std_logic_vector(shift_right(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt))));
						--value<=(std_logic_vector(shift_right(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt)))))(15 downto 0);
					end if;
					i<=i+1;
 				elsif(opcode="100011")then--lw
 				    --rt_copy<=rt;
 				    addra<=std_logic_vector(to_unsigned(((to_integer(unsigned(reg(to_integer(unsigned(rs))))))+(to_integer(signed(adrs)))),12));
 				    state<=3;
 				    j:=0;
				elsif(opcode="101011")then--sw
				    dina<=reg(to_integer(unsigned(rt)));
					value<=reg(to_integer(unsigned(rt)))(15 downto 0);
				    wea<="1";
				    state<=3;
				    j:=1;
				    addra<=std_logic_vector(to_unsigned(((to_integer(unsigned(reg(to_integer(unsigned(rs))))))+(to_integer(signed(adrs)))),12));
				end if;
			elsif(state=3)then
				k<=k+1;
				if(j=1)then
					wea<="0";
				end if;
			    addra<=std_logic_vector(to_unsigned(i-1,12));
				state<=4;
            elsif(state=4)then
    	        k<=k+1;
                if(j=0)then--lw
                    reg(to_integer(unsigned(rt_copy)))<=douta;
					value<=douta(15 downto 0);
                    addra<=std_logic_vector(to_unsigned(i,12));
                    state<=1;
                elsif(j=1)then--sw
                    addra<=std_logic_vector(to_unsigned(i,12));
                    state<=1;
                end if;
                i<=i+1;
			end if;
		end if;
	end process;
	process(digit)
    begin
        case digit is
			when"0000"=>seg<="0000001";--"0"
	        when"0001"=>seg<="1001111";--"1"
	        when"0010"=>seg<="0010010";--"2"
	        when"0011"=>seg<="0000110";--"3"
	        when"0100"=>seg<="1001100";--"4"
	        when"0101"=>seg<="0100100";--"5"
	        when"0110"=>seg<="0100000";--"6"
	        when"0111"=>seg<="0001111";--"7"
	        when"1000"=>seg<="0000000";--"8"
	        when"1001"=>seg<="0000100";--"9"
	        when"1010"=>seg<="0001000";--"A"
	        when"1011"=>seg<="1100000";--"B"
	        when"1100"=>seg<="0110001";--"C"
	        when"1101"=>seg<="1000010";--"D"
	        when"1110"=>seg<="0110000";--"E"
	        when others=>seg<="0111000";--"F"
        end case;
    end process;
    process(clk)
    begin
        if(clk='1')and clk'event then
            counter<=std_logic_vector(to_unsigned(to_integer(unsigned(counter)+1),20));-- counter+1;
        end if;
    end process;
    position<=counter(19 downto 18);
    process(position)
        variable key: std_logic_vector(15 downto 0):=std_logic_vector(to_unsigned(k,16)); 
    begin
        case position is
        when"11"=>
            an<="0111";
			if(switch='0')then
            	digit<=value(15 downto 12);
			else
				digit<=key(15 downto 12);
			end if;
        when"10"=>
            an<="1011";
			if(switch='0')then
            	digit<=value(11 downto 8);
			else
				digit<=key(11 downto 8);
			end if;
        when"01"=>
            an<="1101";
			if(switch='0')then
            	digit<=value(7 downto 4);
			else
				digit<=key(7 downto 4);
			end if;
        when others=>
            an<="1110";
			if(switch='0')then
            	digit<=value(3 downto 0);
			else
				digit<=key(3 downto 0);
			end if;
        end case;
    end process;

end Behavioral;