library verilog;
use verilog.vl_types.all;
entity Controller is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        jb              : in     vl_logic;
        next_pc_sel     : out    vl_logic;
        F_im_w_en       : out    vl_logic_vector(3 downto 0);
        stall           : out    vl_logic;
        D_rs1_data_sel  : out    vl_logic;
        D_rs2_data_sel  : out    vl_logic;
        E_op            : out    vl_logic_vector(4 downto 0);
        E_f3            : out    vl_logic_vector(2 downto 0);
        E_f7            : out    vl_logic;
        E_rd            : out    vl_logic_vector(4 downto 0);
        E_rs1           : out    vl_logic_vector(4 downto 0);
        E_rs2           : out    vl_logic_vector(4 downto 0);
        E_rs1_data_sel  : out    vl_logic_vector(1 downto 0);
        E_rs2_data_sel  : out    vl_logic_vector(1 downto 0);
        E_jb_op1_sel    : out    vl_logic;
        E_alu_op1_sel   : out    vl_logic;
        E_alu_op2_sel   : out    vl_logic;
        M_op            : out    vl_logic_vector(4 downto 0);
        M_f3            : out    vl_logic_vector(2 downto 0);
        M_rd            : out    vl_logic_vector(4 downto 0);
        M_dm_w_en       : out    vl_logic_vector(3 downto 0);
        W_op            : out    vl_logic_vector(4 downto 0);
        W_f3            : out    vl_logic_vector(2 downto 0);
        W_rd            : out    vl_logic_vector(4 downto 0);
        W_wb_en         : out    vl_logic;
        W_rd_index      : out    vl_logic_vector(4 downto 0);
        W_wb_data_sel   : out    vl_logic
    );
end Controller;
