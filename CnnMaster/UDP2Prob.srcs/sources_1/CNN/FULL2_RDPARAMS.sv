`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 18:42:33
// Design Name: 
// Module Name: FULL1_RDPARAMS
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


module FULL2_RDPARAMS(
    input wire  IRST,
    input wire  ICLK,
    input wire  [7:0]  full2_params_addr,
    output wire [31:0] full2_bias_dout,
    output wire [1023:0] full2_params_dout
);
    /* ----- parameter ----- */
    /* ------ register ----- */
    //reg [15:0] d_addr4;
    reg [7:0] d_addr4 [2:0];
    reg [31:0] addr4;
    /* ------- wire -------  */
    wire rsta_busy;
    wire [31:0] addr128={24'b0,full2_params_addr}<<7;

    always_ff @(posedge ICLK)begin
        d_addr4 <= {d_addr4[1:0],full2_params_addr};
    end
    
    always_ff @(posedge ICLK)begin
        addr4 <= {24'b0,d_addr4[2]}<<2;
    end
    
    FULL2_PARAMS full2_params (
       .douta        (full2_params_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr128),
       .clka         (ICLK)
    );

    FULL2_BIAS full2_bias(
        .douta        (full2_bias_dout), //--[127:0] for each [7:0] bias param.
        .addra        (addr4),
        .clka         (ICLK)
    );

endmodule
