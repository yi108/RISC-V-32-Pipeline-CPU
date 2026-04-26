library verilog;
use verilog.vl_types.all;
entity Imm_Ext is
    port(
        inst            : in     vl_logic_vector(31 downto 0);
        imm_ext_out     : out    vl_logic_vector(31 downto 0)
    );
end Imm_Ext;
