library verilog;
use verilog.vl_types.all;
entity Decoder is
    port(
        inst            : in     vl_logic_vector(31 downto 0);
        dc_out_opcode   : out    vl_logic_vector(4 downto 0);
        dc_out_func3    : out    vl_logic_vector(2 downto 0);
        dc_out_func7    : out    vl_logic;
        dc_out_rs1_index: out    vl_logic_vector(4 downto 0);
        dc_out_rs2_index: out    vl_logic_vector(4 downto 0);
        dc_out_rd_index : out    vl_logic_vector(4 downto 0)
    );
end Decoder;
