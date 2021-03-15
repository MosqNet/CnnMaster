`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 18:36:00
// Design Name: 
// Module Name: CONV2_RESULTS
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
module CONV2_RESULTS(
//-- System commons
    input wire          IRST,
    input wire          ICLK,
//-- Input 
    input wire signed [24:0]  ID,
    input wire  [6:0]   IWADDR,
    input wire  [15:0]  IWE,
    input wire  [6:0]   IRADDR,
//-- Output
    output wire signed [24:0]  OD [15:0]
);

    parameter KERNEL_NUM = 16;

    genvar g;
    generate
        for (g=0;g<KERNEL_NUM;g=g+1) begin : CONV2_RESULT
    CONV2_RESULT conv2_ram (
       //-- Write side                        
       .dina     (ID),      // [31:0](one pixel)
       .addra    (IWADDR), // [6:0]
       .wea      (IWE[g]),
       .clka     (ICLK),
       //-- Read side
       .addrb    (IRADDR),
       .doutb    (OD[g]), // [31:0](one pixel) -->
       .clkb     (ICLK)
       );
    end
    endgenerate

endmodule
