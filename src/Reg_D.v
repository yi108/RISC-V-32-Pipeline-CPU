module Reg_D (
    input  clk,
    input  rst,
    input  stall,
    input  jb,
    input  [31:0] next_inst,
    input  [31:0] next_pc,
    output reg [31:0] current_pc,
    output reg [31:0] current_inst
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_pc   <= 32'b0;
            current_inst <= 32'b0;
        end
        // JB Flush priority > Stall
        else if (jb) begin
            current_pc   <= 32'b0;
            current_inst <= 32'b0;
        end
        else if (stall) begin
            current_pc   <= current_pc;
            current_inst <= current_inst;
        end
        else begin
            current_pc   <= next_pc;
            current_inst <= next_inst;
        end
    end
endmodule