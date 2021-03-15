`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/08 14:28:40
// Design Name: 
// Module Name: CONV1_RDPARAMS
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


module CONV1_RDPARAMS(
    //-- System commons
    input  wire         IRST,
    input  wire         ICLK,
    input  wire [3:0]   conv1_params_addr,
    //-- Output
    output wire [255:0] conv1_params_dout
);
    /* ----- parameter ----- */
    /* ------ register ----- */
    /* ------- wire -------  */
    wire [31:0] addr32={28'b0,conv1_params_addr}<<5;
    
    CONV1_PARAMS conv1_params (
        .douta        (conv1_params_dout), //--[255:0] for each [7:0] weights params and a bias param.
        .addra        (addr32),
        .clka           (ICLK)
//        .rsta           (IRST)
    );

endmodule