----------------------------------------------------------------------------------
-- Creator : Milad Rabiei (Student of Electrical Engineering at SBU)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity fileread is
	generic (width 	: integer := 620;
				height 	: integer := 875);
	port (clk	:	in		std_logic;
			runx	:	in		std_ulogic 	:= '0';
			kernel:	in 	bit 			:= '0');
end fileread;

architecture behave of fileread is
	
	type states is (reading, writing, sobeling, waiting);
	signal pr_state, nx_state 	:	states := waiting;
	
	type img_arr	is array (0 to height, 0 to width) of integer range 0 to 255;
	
	type kernel_3 	is array(0 to 2, 0 to 2) of integer range -2 to +2;
	type kernel_5 	is array(0 to 4, 0 to 4) of integer range -20 to +20;
	
begin

	-- ###################################################
	process (clk)
	begin
		if rising_edge(clk) then
			pr_state <= nx_state;
		end if;
	end process;
	
	-- ###################################################
	process (pr_state, runx)
	
	file   inp_buf	: 		text;
	file 	 out_buf	: 		text;
	variable read_col_from_inp_buf	: 	line;
	variable write_col_to_out_buf 	: 	line;
	variable	val_col1						: 	integer;
	
	variable yval, xval, kernel_select 	: integer := 0;
	
	variable arrayed	:		img_arr ;
	variable maked		: 		img_arr := (others => (others => 0));
	
	constant horizn3	:		kernel_3 := ((-1, 0, 1),
													 (-2, 0, 2),
													 (-1, 0, 1));
													 
	constant vertic3	:		kernel_3 := ((1, 2, 1), 
													 (0, 0, 0), 
													 (-1, -2, -1));
													 
	constant horizn5	:		kernel_5 := ((1, 2, 0, -2, -1), 
													 (4, 8, 0, -8, -4), 
													 (6, 12, 0, -12, -6), 
													 (4, 8, 0, -8, -4), 
													 (1, 2, 0, -2, -1));
													 
	constant vertic5	:		kernel_5 := ((1, 4, 6, 4, 1), 
													 (2, 8, 12, 8, 2), 
													 (0, 0, 0, 0, 0), 
													 (-2, -8, -12, -8, -2), 
													 (-1, -4, -6, -4, -1));

	begin
	
		case pr_state is
			-----------------
			when	waiting 	=>
				if (runx'EVENT and runx = '1') then
					nx_state <= reading;
				end if;
			
			-----------------
			when 	reading 	=>
				file_open(inp_buf, "pixels.txt", read_mode);
				for i in 0 to height-1 loop
					for j in 0 to width-1 loop
						readline(inp_buf, read_col_from_inp_buf);
						read(read_col_from_inp_buf, val_col1);
						arrayed (i, j) := val_col1;
					end loop;
				end loop;
				file_close(inp_buf);
				nx_state <= sobeling;
			
			-----------------
			when 	sobeling	=>
				if kernel = '0' then
					kernel_select := 3;
				else
					kernel_select := 5;
				end if;
				for i in kernel_select-2 to height-kernel_select+2 loop
					for j in kernel_select-2 to width-kernel_select+2 loop
						xval := 0;
						yval := 0;
						for m in 0 to kernel_select-1 loop
							for n in 0 to kernel_select-1 loop
								if kernel = '0' then
									xval := xval + horizn3(m,n) * arrayed(i+m-1, j+n-1);
								else
									xval := xval + horizn5(m,n) * arrayed(i+m-1, j+n-1);
								end if;
							end loop;
						end loop;
						for m in 0 to kernel_select-1 loop
							for n in 0 to kernel_select-1 loop
								if kernel = '0' then
									yval := yval + vertic3(m,n) * arrayed(i+m-1, j+n-1);
								else
									yval := yval + vertic5(m,n) * arrayed(i+m-1, j+n-1);
								end if;
							end loop;
						end loop;
						maked (i, j) := (abs(xval) + abs(yval)) / (kernel_select * kernel_select);
					end loop;
				end loop;
				nx_state <= writing;
				
			-----------------
			when 	writing 	=>
				file_open(out_buf, "resultpixels.txt", write_mode);
				for i_y in 0 to height-1 loop
					for i_x in 0 to width-1 loop
						write(write_col_to_out_buf, maked (i_y, i_x));
						writeline(out_buf, write_col_to_out_buf); 
					end loop;
				end loop;
				file_close(out_buf);
				nx_state <= waiting;
				
		end case;
	end process;
	
end behave;

