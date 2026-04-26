module Reg_E (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire        jb,
    input  wire [31:0] next_pc,
    input  wire [31:0] next_rs1_data,
    input  wire [31:0] next_rs2_data,
    input  wire [31:0] next_sext_imm,
    output reg  [31:0] current_pc,
    output reg  [31:0] current_rs1_data,
    output reg  [31:0] current_rs2_data,
    output reg  [31:0] current_sext_imm
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_pc       <= 32'b0;
            current_rs1_data <= 32'b0;
            current_rs2_data <= 32'b0;
            current_sext_imm <= 32'b0;
        end
        else if (stall || jb) begin
            current_pc       <= 32'b0;
            current_rs1_data <= 32'b0;
            current_rs2_data <= 32'b0;
            current_sext_imm <= 32'b0;
        end
        else begin
            current_pc       <= next_pc;
            current_rs1_data <= next_rs1_data;
            current_rs2_data <= next_rs2_data;
            current_sext_imm <= next_sext_imm;
        end
    end
endmodule