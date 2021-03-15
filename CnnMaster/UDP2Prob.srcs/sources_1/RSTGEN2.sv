`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/09 16:24:22
// Design Name: 
// Module Name: RSTGEN2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RSTGEN2(
   // Outputs
    reset_o,
    // Inputs
    clk,locked_i
    ) ;
    input clk;
    input locked_i;
    output reset_o; 

    reg [149:0] sft=150'b0;
    wire reset_root = locked_i;

    always_ff @(posedge clk) begin
        if(reset_root) sft <= {sft[148:0],1'b1};
    end
    //assign reset_o = ~(sft[149] ^ sft[0]);
    assign reset_o = (sft[149]) & reset_root;
    
endmodule
