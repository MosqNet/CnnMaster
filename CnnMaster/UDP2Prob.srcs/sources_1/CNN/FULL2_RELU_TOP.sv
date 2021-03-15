`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 17:16:31
// Design Name: 
// Module Name: FULL2_RELU_TOP
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


module FULL2_RELU_TOP(
    input   wire [63:0] FULL2_ID,
    input   wire        IVALID,
    input   wire        IINIT,
    output  wire [63:0] full2_result[83:0],
    output  wire        OVALID,
    input   wire        IRST,
    input   wire        ICLK    
    );

FULL2_RELU full2_relu (
    .FULL2_ID         (FULL2_ID),   //[31:0]
    .IVALID           (IVALID),
    .IINIT            (IINIT),
    .full2_result    (full2_result),        //--> "conv2_ram_u{0,1,2,-->,14,15}"
    .IRST             (IRST),
    .ICLK             (ICLK)
);
endmodule
