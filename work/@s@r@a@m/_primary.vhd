library verilog;
use verilog.vl_types.all;
entity SRAM is
    port(
        clk             : in     vl_logic;
        w_en            : in     vl_logic_vector(3 downto 0);
        address         : in     vl_logic_vector(15 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        read_data       : out    vl_logic_vector(31 downto 0)
    );
end SRAM;
