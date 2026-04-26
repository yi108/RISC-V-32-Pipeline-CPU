library verilog;
use verilog.vl_types.all;
entity ALU is
    port(
        opcode          : in     vl_logic_vector(4 downto 0);
        func3           : in     vl_logic_vector(2 downto 0);
        func7           : in     vl_logic;
        operand1        : in     vl_logic_vector(31 downto 0);
        operand2        : in     vl_logic_vector(31 downto 0);
        alu_out         : out    vl_logic_vector(31 downto 0);
        zero            : out    vl_logic
    );
end ALU;
