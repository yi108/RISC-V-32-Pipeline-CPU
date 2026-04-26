library verilog;
use verilog.vl_types.all;
entity Mux1 is
    port(
        sel             : in     vl_logic;
        in0             : in     vl_logic_vector(31 downto 0);
        in1             : in     vl_logic_vector(31 downto 0);
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end Mux1;
