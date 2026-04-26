module Adder (
    input  [31:0] src1,
    input  [31:0] src2,
    output [31:0] sum
);

    assign sum = src1 + src2;

endmodule