module Imm_Ext(
    input  wire [31:0] inst,
    output reg  [31:0] imm_ext_out
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-type
            7'b0000011, 7'b0010011, 7'b1100111: begin 
                imm_ext_out = {{20{inst[31]}}, inst[31:20]};
            end

            // S-type
            7'b0100011: begin 
                imm_ext_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            // B-type
            7'b1100011: begin 
                imm_ext_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            // U-type
            7'b0110111, 7'b0010111: begin 
                imm_ext_out = {inst[31:12], 12'b0};
            end

            // J-type
            7'b1101111: begin 
                imm_ext_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            default: begin
                imm_ext_out = 32'b0;
            end
        endcase
    end
endmodule