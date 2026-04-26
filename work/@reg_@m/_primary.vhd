library verilog;
use verilog.vl_types.all;
entity Reg_M is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        next_alu_out    : in     vl_logic_vector(31 downto 0);
        next_rs2_data   : in     vl_logic_vector(31 downto 0);
        current_alu_out : out    vl_logic_vector(31 downto 0);
        current_rs2_data: out    vl_logic_vector(31 downto 0)
    );
end Reg_M;
