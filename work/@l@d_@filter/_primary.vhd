library verilog;
use verilog.vl_types.all;
entity LD_Filter is
    port(
        func3           : in     vl_logic_vector(2 downto 0);
        ld_data         : in     vl_logic_vector(31 downto 0);
        ld_data_f       : out    vl_logic_vector(31 downto 0)
    );
end LD_Filter;
