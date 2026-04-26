library verilog;
use verilog.vl_types.all;
entity RegFile is
    port(
        clk             : in     vl_logic;
        wb_en           : in     vl_logic;
        wb_data         : in     vl_logic_vector(31 downto 0);
        rd_index        : in     vl_logic_vector(4 downto 0);
        rs1_index       : in     vl_logic_vector(4 downto 0);
        rs2_index       : in     vl_logic_vector(4 downto 0);
        rs1_data_out    : out    vl_logic_vector(31 downto 0);
        rs2_data_out    : out    vl_logic_vector(31 downto 0)
    );
end RegFile;
