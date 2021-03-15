`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/08 14:28:40
// Design Name: 
// Module Name: CONV2_RDPARAMS
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


module CONV2_RDPARAMS(
    //-- System commons
    input wire ICLK,
    input wire IRST,
    //-- Input
    input  wire [4:0] conv2_params_addr,
    //-- Output
    output wire [31:0] conv2_bias_dout,
    output wire [255:0] conv2_params00_dout,
    output wire [255:0] conv2_params01_dout,
    output wire [255:0] conv2_params02_dout,
    output wire [255:0] conv2_params03_dout,
    output wire [255:0] conv2_params04_dout,
    output wire [255:0] conv2_params05_dout
);
    /* ----- parameter ----- */
    /* ------ register ----- */
    /* ------- wire -------  */
    
    wire [31:0] addr32={27'b0,conv2_params_addr}<<5;
    wire [31:0] addr4={27'b0,conv2_params_addr}<<2;
    
    CONV2_PARAMS00 conv2_params00 (
    .douta        (conv2_params00_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_PARAMS01 conv2_params01 (
    .douta        (conv2_params01_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_PARAMS02 conv2_params02 (
    .douta        (conv2_params02_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_PARAMS03 conv2_params03 (
    .douta        (conv2_params03_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_PARAMS04 conv2_params04 (
    .douta        (conv2_params04_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_PARAMS05 conv2_params05 (
    .douta        (conv2_params05_dout), //--[255:0] for each [7:0] weights params and a bias param.
    .addra        (addr32),
    .clka         (ICLK)
    );
    
    CONV2_BIAS conv2_bias(
    .douta        (conv2_bias_dout), //--[127:0] for each [7:0] bias param.
    .addra        (addr4),
    .clka         (ICLK)
    );

endmodule
