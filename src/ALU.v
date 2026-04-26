module ALU (
    input  [4:0]  opcode,
    input  [2:0]  func3,
    input         func7,
    input  [31:0] operand1,
    input  [31:0] operand2,
    output reg [31:0] alu_out,
    output reg        zero 
);

    always @(*) begin
        zero = 1'b0;
        case(opcode)
            5'b01100, 5'b00100: begin // R-Type & I-Type
                case(func3)
                    3'b000: begin // ADD/SUB
                        if (opcode == 5'b01100 && func7) 
                            alu_out = operand1 - operand2;
                        else 
                            alu_out = operand1 + operand2;
                    end
                    3'b001: alu_out = operand1 << operand2[4:0]; // SLL
                    3'b010: alu_out = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; // SLT
                    3'b011: alu_out = (operand1 < operand2) ? 32'b1 : 32'b0; // SLTU
                    3'b100: alu_out = operand1 ^ operand2; // XOR
                    3'b101: begin // SRL/SRA
                        if (func7) 
                            alu_out = $signed(operand1) >>> operand2[4:0]; // SRA
                        else 
                            alu_out = operand1 >> operand2[4:0]; // SRL
                    end
                    3'b110: alu_out = operand1 | operand2; // OR
                    3'b111: alu_out = operand1 & operand2; // AND
                    default: alu_out = 32'b0;
                endcase
            end

            5'b00000, 5'b01000: begin // Load & Store
                alu_out = operand1 + operand2; 
            end

            5'b11000: begin // Branch
                case (func3)
                    3'b000, 3'b001: begin // BEQ, BNE
                        alu_out = operand1 - operand2;
                        if (alu_out == 32'd0) zero = 1'b1;
                    end
                    3'b100, 3'b101: begin // BLT, BGE
                        alu_out = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
                    end
                    3'b110, 3'b111: begin // BLTU, BGEU
                        alu_out = (operand1 < operand2) ? 32'b1 : 32'b0;
                    end
                    default: alu_out = 32'b0;
                endcase
            end
            
            5'b11011, 5'b11001: begin // JAL & JALR
                alu_out = operand1 + 4; // PC + 4
            end

            5'b01101: begin // LUI
                alu_out = operand2;
            end

            5'b00101: begin // AUIPC
                alu_out = operand1 + operand2;
            end

            default: alu_out = 32'b0;
        endcase
    end
endmodule