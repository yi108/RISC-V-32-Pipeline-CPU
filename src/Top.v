module Top (
    input  wire clk,
    input  wire rst    // Active High Reset
);

    // ==========================================
    // Wires Definitions
    // ==========================================
    
    // Global Control
    wire stall;
    
    // --- F Stage (Fetch) ---
    wire [31:0] F_pc_in, F_pc_out;
    wire [31:0] F_pc_plus_4;
    wire [31:0] F_inst;
    wire        next_pc_sel;
    wire [31:0] jb_target_addr;
    wire [3:0]  F_im_w_en; 
    
    // --- D Stage (Decode) ---
    wire [31:0] D_pc, D_inst;
    wire [31:0] D_rs1_data, D_rs2_data;
    wire [31:0] D_sext_imm;
    wire        D_rs1_data_sel; 
    wire        D_rs2_data_sel; 
    wire [31:0] D_rs1_data_final; 
    wire [31:0] D_rs2_data_final;
    
    // --- E Stage (Execute) ---
    wire [31:0] E_pc, E_rs1_data, E_rs2_data, E_sext_imm;
    wire [31:0] E_alu_op1, E_alu_op2;
    wire [31:0] E_jb_op1;
    wire [31:0] E_alu_out;
    wire        E_alu_zero;
    wire [31:0] E_newest_rs1_data; 
    wire [31:0] E_newest_rs2_data; 
    
    // E Stage Control Signals
    wire [4:0]  E_op;
    wire [2:0]  E_f3;
    wire        E_f7;
    wire [4:0]  E_rd;
    wire [4:0]  E_rs1;
    wire [4:0]  E_rs2;
    wire [1:0]  E_rs1_data_sel; 
    wire [1:0]  E_rs2_data_sel; 
    wire        E_jb_op1_sel;
    wire        E_alu_op1_sel;
    wire        E_alu_op2_sel;
    wire        E_jb_out; 
    
    // --- M Stage (Memory) ---
    wire [31:0] M_alu_out, M_rs2_data;
    wire [31:0] M_ld_data;
    wire [31:0] M_ld_data_f; 
    
    // M Stage Control Signals
    wire [4:0]  M_op;
    wire [2:0]  M_f3;
    wire [4:0]  M_rd;
    wire [3:0]  M_dm_w_en;
    
    // --- W Stage (Writeback) ---
    wire [31:0] W_alu_out, W_ld_data;
    wire [31:0] W_wb_data;
    
    // W Stage Control Signals
    wire [4:0]  W_op;
    wire [2:0]  W_f3;
    wire [4:0]  W_rd;
    wire        W_wb_en;
    wire [4:0]  W_rd_index;
    wire        W_wb_data_sel;

    // ==========================================
    // Module Instantiations
    // ==========================================

    // 1. Controller
    Controller controller_inst (
        .clk            (clk),
        .rst_n          (~rst),          // Active Low for Controller
        .inst           (D_inst),    
        .jb             (E_jb_out),  
        
        .next_pc_sel    (next_pc_sel),
        .F_im_w_en      (F_im_w_en),
        .stall          (stall),
        
        .D_rs1_data_sel (D_rs1_data_sel),
        .D_rs2_data_sel (D_rs2_data_sel),
        
        .E_op           (E_op),
        .E_f3           (E_f3),
        .E_f7           (E_f7),
        .E_rd           (E_rd),
        .E_rs1          (E_rs1),
        .E_rs2          (E_rs2),
        .E_rs1_data_sel (E_rs1_data_sel),
        .E_rs2_data_sel (E_rs2_data_sel),
        .E_jb_op1_sel   (E_jb_op1_sel),
        .E_alu_op1_sel  (E_alu_op1_sel),
        .E_alu_op2_sel  (E_alu_op2_sel),
        
        .M_op           (M_op),
        .M_f3           (M_f3),
        .M_rd           (M_rd),
        .M_dm_w_en      (M_dm_w_en),
        
        .W_op           (W_op),
        .W_f3           (W_f3),
        .W_rd           (W_rd),
        .W_wb_en        (W_wb_en),
        .W_rd_index     (W_rd_index),
        .W_wb_data_sel  (W_wb_data_sel)
    );

    // --- Fetch Stage ---
    Mux1 next_pc_mux (
        .sel (next_pc_sel),
        .in0 (F_pc_plus_4),
        .in1 (jb_target_addr), 
        .out (F_pc_in)
    );

    Reg_PC reg_pc (
        .clk        (clk),
        .rst        (rst),
        .stall      (stall),
        .next_pc    (F_pc_in),
        .current_pc (F_pc_out)
    );

    Adder pc_plus_4_adder (
        .src1 (F_pc_out),
        .src2 (32'd4),
        .sum  (F_pc_plus_4)
    );

    SRAM im (
        .clk        (clk),
        .w_en       (F_im_w_en), 
        .address    (F_pc_out[15:0]), 
        .write_data (32'b0),
        .read_data  (F_inst)
    );

    // --- IF/ID Pipeline Register ---
    Reg_D reg_d (
        .clk          (clk),
        .rst          (rst),
        .stall        (stall),
        .jb           (E_jb_out), 
        .next_inst    (F_inst),
        .next_pc      (F_pc_out),
        .current_pc   (D_pc),
        .current_inst (D_inst)
    );

    // --- Decode Stage ---
    RegFile regfile (
        .clk          (clk),
        .wb_en        (W_wb_en),
        .wb_data      (W_wb_data),
        .rd_index     (W_rd),       
        .rs1_index    (D_inst[19:15]), 
        .rs2_index    (D_inst[24:20]),
        .rs1_data_out (D_rs1_data),
        .rs2_data_out (D_rs2_data)
    );

    Imm_Ext imm_ext (
        .inst        (D_inst),
        .imm_ext_out (D_sext_imm)
    );

    Mux1 d_rs1_mux (
        .sel (D_rs1_data_sel),
        .in0 (D_rs1_data),
        .in1 (W_wb_data),
        .out (D_rs1_data_final)
    );

    Mux1 d_rs2_mux (
        .sel (D_rs2_data_sel),
        .in0 (D_rs2_data),
        .in1 (W_wb_data),
        .out (D_rs2_data_final)
    );

    // --- ID/EX Pipeline Register ---
    Reg_E reg_e (
        .clk              (clk),
        .rst              (rst),
        .stall            (stall),       
        .jb               (E_jb_out),    
        .next_pc          (D_pc),
        .next_rs1_data    (D_rs1_data_final),
        .next_rs2_data    (D_rs2_data_final),
        .next_sext_imm    (D_sext_imm),
        .current_pc       (E_pc),
        .current_rs1_data (E_rs1_data),
        .current_rs2_data (E_rs2_data),
        .current_sext_imm (E_sext_imm)
    );

    // --- Execute Stage ---
    Mux2 e_rs1_fwd_mux (
        .sel (E_rs1_data_sel),
        .in0 (E_rs1_data),
        .in1 (W_wb_data),   // 01: From W Stage
        .in2 (M_alu_out),   // 10: From M Stage (Priority)
        .out (E_newest_rs1_data)
    );

    Mux2 e_rs2_fwd_mux (
        .sel (E_rs2_data_sel),
        .in0 (E_rs2_data),
        .in1 (W_wb_data),   
        .in2 (M_alu_out),   
        .out (E_newest_rs2_data)
    );

    Mux1 e_alu_op1_mux (
        .sel (E_alu_op1_sel),
        .in0 (E_newest_rs1_data),
        .in1 (E_pc),
        .out (E_alu_op1)
    );

    Mux1 e_alu_op2_mux (
        .sel (E_alu_op2_sel),
        .in0 (E_newest_rs2_data),
        .in1 (E_sext_imm),
        .out (E_alu_op2)
    );

    ALU alu (
        .opcode   (E_op), 
        .func3    (E_f3),
        .func7    (E_f7),
        .operand1 (E_alu_op1),
        .operand2 (E_alu_op2),
        .alu_out  (E_alu_out),
        .zero     (E_alu_zero)
    );

    Mux1 jb_op1_mux (
        .sel (E_jb_op1_sel),
        .in0 (E_pc),
        .in1 (E_newest_rs1_data), 
        .out (E_jb_op1)
    );

    JB_Unit jb_unit (
        .operand1 (E_jb_op1),
        .operand2 (E_sext_imm),
        .jb_out   (jb_target_addr)
    );

    // JB Control Logic
    localparam [4:0] OP_BRANCH = 5'b11000;
    localparam [4:0] OP_JAL    = 5'b11011;
    localparam [4:0] OP_JALR   = 5'b11001;

    assign E_jb_out = (E_op == OP_JAL) || 
                      (E_op == OP_JALR) ||
                      (E_op == OP_BRANCH && (
                          (E_f3 == 3'b000 && E_alu_zero) ||       // BEQ
                          (E_f3 == 3'b001 && !E_alu_zero) ||      // BNE
                          (E_f3 == 3'b100 && E_alu_out[0]) ||     // BLT
                          (E_f3 == 3'b101 && !E_alu_out[0]) ||    // BGE
                          (E_f3 == 3'b110 && E_alu_out[0]) ||     // BLTU
                          (E_f3 == 3'b111 && !E_alu_out[0])       // BGEU
                      ));

    // --- EX/MEM Pipeline Register ---
    Reg_M reg_m (
        .clk              (clk),
        .rst              (rst),
        .next_alu_out     (E_alu_out),
        .next_rs2_data    (E_newest_rs2_data), 
        .current_alu_out  (M_alu_out),
        .current_rs2_data (M_rs2_data)
    );

    // --- Memory Stage ---
    SRAM dm (
        .clk        (clk),
        .w_en       (M_dm_w_en),       
        .address    (M_alu_out[15:0]), 
        .write_data (M_rs2_data),  
        .read_data  (M_ld_data)        
    );

    LD_Filter ld_filter (
        .func3     (M_f3),
        .ld_data   (M_ld_data),
        .ld_data_f (M_ld_data_f) 
    );

    // --- MEM/WB Pipeline Register ---
    Reg_W reg_w (
        .clk             (clk),
        .rst             (rst),
        .next_alu_out    (M_alu_out),
        .next_ld_data    (M_ld_data_f),
        .current_alu_out (W_alu_out),
        .current_ld_data (W_ld_data)
    );

    // --- Writeback Stage ---
    Mux1 wb_mux (
        .sel (W_wb_data_sel),
        .in0 (W_alu_out),
        .in1 (W_ld_data),
        .out (W_wb_data)
    );

endmodule