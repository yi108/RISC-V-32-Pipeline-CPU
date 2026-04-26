module RegFile (
    input  clk,
    input  wb_en,
    input  [31:0] wb_data,
    input  [4:0]  rd_index,
    input  [4:0]  rs1_index,
    input  [4:0]  rs2_index,
    output [31:0] rs1_data_out,
    output [31:0] rs2_data_out
);
    reg [31:0] registers [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Read Logic (x0 always 0)
    assign rs1_data_out = (rs1_index == 5'b0) ? 32'b0 : registers[rs1_index];
    assign rs2_data_out = (rs2_index == 5'b0) ? 32'b0 : registers[rs2_index];

    // Write Logic
    always @(posedge clk) begin
        if (wb_en && (rd_index != 5'b0)) begin 
            registers[rd_index] <= wb_data;
        end
    end
endmodule