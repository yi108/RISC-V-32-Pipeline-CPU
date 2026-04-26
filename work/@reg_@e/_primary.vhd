library verilog;
use verilog.vl_types.all;
entity Reg_E is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        stall           : in     vl_logic;
        jb              : in     vl_logic;
        next_pc         : in     vl_logic_vector(31 downto 0);
        next_rs1_data   : in     vl_logic_vector(31 downto 0);
        next_rs2_data   : in     vl_logic_vector(31 downto 0);
        next_sext_imm   : in     vl_logic_vector(31 downto 0);
        current_pc      : out    vl_logic_vector(31 downto 0);
        current_rs1_data: out    vl_logic_vector(31 downto 0);
        current_rs2_data: out    vl_logic_vector(31 downto 0);
        current_sext_imm: out    vl_logic_vector(31 downto 0)
    );
end Reg_E;
