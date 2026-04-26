module Controller (
    input  wire        clk,
    input  wire        rst_n,
    
    // Datapath Inputs
    input  wire [31:0] inst,         // From Decode Stage
    input  wire        jb,           // From JB Unit (E_jb_out)
    
    // F Stage (Fetch)
    output reg         next_pc_sel,  // 0: PC+4, 1: Jump/Branch Target
    output wire [3:0]  F_im_w_en,    // Instruction Memory Write Enable (Always 0)
    output reg         stall,        // Stall Signal
    
    // D Stage (Decode)
    output reg         D_rs1_data_sel, 
    output reg         D_rs2_data_sel, 
    
    // E Stage (Execute)
    output reg  [4:0]  E_op,
    output reg  [2:0]  E_f3,
    output reg         E_f7,          
    output reg  [4:0]  E_rd,
    output reg  [4:0]  E_rs1,
    output reg  [4:0]  E_rs2,
    output reg  [1:0]  E_rs1_data_sel, // Forwarding Select
    output reg  [1:0]  E_rs2_data_sel, // Forwarding Select
    output reg         E_jb_op1_sel,   // Jump/Branch operand select
    output reg         E_alu_op1_sel,  // ALU operand 1 select
    output reg         E_alu_op2_sel,  // ALU operand 2 select
    
    // M Stage (Memory)
    output reg  [4:0]  M_op,
    output reg  [2:0]  M_f3,
    output reg  [4:0]  M_rd,
    output reg  [3:0]  M_dm_w_en,      // Data Memory Write Enable
    
    // W Stage (Writeback)
    output reg  [4:0]  W_op,
    output reg  [2:0]  W_f3,
    output reg  [4:0]  W_rd,
    output reg         W_wb_en,        // RegFile Write Enable
    output reg  [4:0]  W_rd_index,
    output reg         W_wb_data_sel   // 0: ALU, 1: Load Data
);

    // 1. Instruction Decode
    wire [4:0] opcode = inst[6:2];
    wire [4:0] rd     = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];
    wire       funct7 = inst[30]; 
    
    localparam OP_R_TYPE  = 5'b01100;
    localparam OP_I_TYPE  = 5'b00100;
    localparam OP_LOAD    = 5'b00000;
    localparam OP_STORE   = 5'b01000;
    localparam OP_BRANCH  = 5'b11000;
    localparam OP_JAL     = 5'b11011;
    localparam OP_JALR    = 5'b11001;
    localparam OP_LUI     = 5'b01101;
    localparam OP_AUIPC   = 5'b00101;

    // Decode Signals (Before Pipeline Reg)
    reg        d_reg_write;
    reg        d_mem_write; 
    reg        d_alu_op1_sel;
    reg        d_alu_op2_sel;
    reg        d_jb_op1_sel;
    reg        d_wb_data_sel;
    reg        is_branch, is_jump;
    
    always @(*) begin
        // Defaults
        d_reg_write   = 0;
        d_mem_write   = 0;
        d_alu_op1_sel = 0; // 0: Reg, 1: PC
        d_alu_op2_sel = 0; // 0: Reg, 1: Imm
        d_jb_op1_sel  = 0; // 0: PC, 1: Reg(rs1)
        d_wb_data_sel = 0; // 0: ALU, 1: Mem
        is_branch     = 0;
        is_jump       = 0;

        next_pc_sel   = jb;

        case (opcode)
            OP_R_TYPE: begin
                d_reg_write = 1;
            end
            OP_I_TYPE: begin
                d_reg_write   = 1;
                d_alu_op2_sel = 1;
            end
            OP_LOAD: begin
                d_reg_write   = 1;
                d_alu_op2_sel = 1;
                d_wb_data_sel = 1;
            end
            OP_STORE: begin
                d_mem_write   = 1;
                d_alu_op2_sel = 1;
            end
            OP_BRANCH: begin
                is_branch    = 1;
                d_jb_op1_sel = 0; // Branch target = PC + imm
            end
            OP_JAL: begin
                d_reg_write  = 1;
                is_jump      = 1;
                d_jb_op1_sel = 0;
                // [修正] ALU op1 select PC for PC+4
                d_alu_op1_sel = 1;
            end
            OP_JALR: begin
                d_reg_write   = 1;
                is_jump       = 1;
                d_alu_op2_sel = 1;
                d_jb_op1_sel  = 1; // JALR target = rs1 + imm
                // [修正] ALU op1 select PC for PC+4
                d_alu_op1_sel = 1;
            end
            OP_LUI: begin
                d_reg_write   = 1;
                d_alu_op2_sel = 1;
            end
            OP_AUIPC: begin
                d_reg_write   = 1;
                d_alu_op1_sel = 1; // PC
                d_alu_op2_sel = 1; // imm
            end
            default: ;
        endcase
    end
    
    assign F_im_w_en = 4'b0000;
    
    // 2. Hazard Detection Unit
    wire is_E_load = (E_op == OP_LOAD);
    always @(*) begin
        stall = 0;
        if (is_E_load && (E_rd != 0) && ((E_rd == rs1) || (E_rd == rs2))) begin
            stall = 1;
        end
    end

    // Flush Logic
    wire flush = next_pc_sel;
    
    // 3. Pipeline Registers (D -> E)
    reg        E_reg_write;
    reg        E_mem_write;
    reg        E_wb_data_sel_internal;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            E_op <= 0; E_f3 <= 0; E_f7 <= 0; E_rd <= 0; E_rs1 <= 0; E_rs2 <= 0;
            E_alu_op1_sel <= 0; E_alu_op2_sel <= 0; E_jb_op1_sel <= 0;
            E_reg_write <= 0; E_mem_write <= 0; E_wb_data_sel_internal <= 0;
        end else begin
            if (stall) begin
                // Stall bubble
                E_op <= 0;
                E_f3 <= 0;
                E_f7 <= 0;
                E_rd <= 0;
                E_rs1 <= 0;
                E_rs2 <= 0;
                E_alu_op1_sel <= 0;
                E_alu_op2_sel <= 0;
                E_jb_op1_sel  <= 0;
                E_reg_write <= 0;
                E_mem_write <= 0;
                E_wb_data_sel_internal <= 0;
            end else if (flush) begin
                // Flush logic
                E_op <= 0;
                E_f3 <= 0;
                E_f7 <= 0;
                E_rd <= 0;
                E_rs1 <= 0;
                E_rs2 <= 0;
                E_alu_op1_sel <= 0;
                E_alu_op2_sel <= 0;
                E_jb_op1_sel  <= 0;
                E_reg_write <= 0;
                E_mem_write <= 0;
                E_wb_data_sel_internal <= 0;
            end else begin
                E_op  <= opcode;     
                E_f3  <= funct3;
                E_f7  <= funct7;
                E_rd  <= rd;
                E_rs1 <= rs1;
                E_rs2 <= rs2;
                
                E_alu_op1_sel <= d_alu_op1_sel;
                E_alu_op2_sel <= d_alu_op2_sel;
                E_jb_op1_sel  <= d_jb_op1_sel;
                
                E_reg_write <= d_reg_write;
                E_mem_write <= d_mem_write;
                E_wb_data_sel_internal <= d_wb_data_sel;
            end
        end
    end
    
    // 4. Forwarding Logic (E Stage Combinational)
    wire M_writes_reg =
    (M_op == OP_R_TYPE)  ||
    (M_op == OP_I_TYPE)  ||
    (M_op == OP_LOAD)    ||
    (M_op == OP_JAL)     ||
    (M_op == OP_JALR)    ||
    (M_op == OP_LUI)     ||
    (M_op == OP_AUIPC);

    always @(*) begin
        E_rs1_data_sel = 2'b00;
        E_rs2_data_sel = 2'b00;

        if (M_writes_reg && (M_rd != 0) && (M_rd == E_rs1))
            E_rs1_data_sel = 2'b10;
        else if (W_wb_en && (W_rd != 0) && (W_rd == E_rs1))
            E_rs1_data_sel = 2'b01;

        if (M_writes_reg && (M_rd != 0) && (M_rd == E_rs2))
            E_rs2_data_sel = 2'b10;
        else if (W_wb_en && (W_rd != 0) && (W_rd == E_rs2))
            E_rs2_data_sel = 2'b01;
    end
    
    // W to D Bypass
    always @(*) begin
        if (W_wb_en && (W_rd != 0) && (W_rd == rs1))
            D_rs1_data_sel = 1'b1;
        else
            D_rs1_data_sel = 1'b0;

        if (W_wb_en && (W_rd != 0) && (W_rd == rs2))
            D_rs2_data_sel = 1'b1;
        else
            D_rs2_data_sel = 1'b0;
    end
    
    // 5. Pipeline Registers (E -> M)
    reg M_mem_write;
    reg M_wb_data_sel_internal;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            M_op <= 0; M_f3 <= 0; M_rd <= 0;
            M_wb_data_sel_internal <= 0;
            M_mem_write <= 0;
        end else begin
            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;

            M_mem_write <= E_mem_write;
            M_wb_data_sel_internal <= E_wb_data_sel_internal;
        end
    end
    
    // Memory Write Enable Decode
    always @(*) begin
        if (M_mem_write) begin
            case (M_f3)
                3'b000: M_dm_w_en = 4'b0001; // SB
                3'b001: M_dm_w_en = 4'b0011; // SH
                3'b010: M_dm_w_en = 4'b1111; // SW
                default: M_dm_w_en = 4'b0000;
            endcase
        end else begin
            M_dm_w_en = 4'b0000;
        end
    end
    
    // 6. Pipeline Registers (M -> W)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            W_op <= 0; W_f3 <= 0; W_rd <= 0; W_rd_index <= 0;
            W_wb_en <= 0; W_wb_data_sel <= 0;
        end else begin
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;
            W_rd_index <= M_rd;
            
            case (M_op)
                OP_R_TYPE,
                OP_I_TYPE,
                OP_LOAD,
                OP_JAL,
                OP_JALR,
                OP_LUI,
                OP_AUIPC: W_wb_en <= 1'b1;
                default:  W_wb_en <= 1'b0;
            endcase

            W_wb_data_sel <= M_wb_data_sel_internal;
        end
    end

endmodule