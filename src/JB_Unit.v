module JB_Unit (
    input  [31:0] operand1,   // PC or rs1
    input  [31:0] operand2,   // Immediate
    output [31:0] jb_out
);

    assign jb_out = (operand1 + operand2) & ~32'd3;
endmodule