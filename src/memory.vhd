--    Memory
--    Evan Allen, 7/19/2018, 10:37 AM

library STD;
use STD.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    generic (
        mem_file : STRING
    );
    port (
        i_clk : in STD_LOGIC;
        i_address : in STD_LOGIC_VECTOR;
        i_rw : in STD_LOGIC;                -- '0'=read, '1'=write
        io_data : inout STD_LOGIC_VECTOR
    );
end memory;

architecture behavioral of memory is
    type MEM_T is array(0 to (2**i_address'length)-1) of STD_LOGIC_VECTOR(io_data'range);
    constant word_size : NATURAL := io_data'length;

    -- Based off https://electronics.stackexchange.com/questions/180446/how-to-load-std-logic-vector-array-from-text-file-at-start-of-simulation
    -- Hex input file must be formatted with one WORD (no more, no less) per line in the form of hex characters (CAPITAL A-F or 0-9).
        --> *** IF this is incorrect, the memory may begin with 'U' sections or worse.
    impure function memory_readMemFile(file_name : STRING) return MEM_T is
        file file_handle        : TEXT open READ_MODE is file_name;
        variable current_line   : LINE;
        variable result_mem     : mem_T := (others => (others => '0'));
    begin
        assert (word_size mod 4 = 0) report "Size of io_data must be divisible by 4." severity error;

        for i in 0 to MEM_T'length - 1 loop
            exit when endfile(file_handle);

            readline(file_handle, current_line);
            hread(current_line, result_mem(i));
        end loop;

        return result_mem;
    end function;

    signal mem : MEM_T := memory_readMemFile(mem_file);
    signal w_data : STD_LOGIC_VECTOR(io_data'range) := (others => 'Z');
begin

    UPDATE : process (i_rw, mem, i_address, io_data)
    begin
        if (i_rw = '0' or i_rw = 'U') then
            w_data <= mem(to_integer(UNSIGNED(i_address)));
        else
            w_data <= (others => 'Z');
            mem(to_integer(UNSIGNED(i_address))) <= io_data;
        end if;
    end process UPDATE;

    io_data <= w_data;
end behavioral;