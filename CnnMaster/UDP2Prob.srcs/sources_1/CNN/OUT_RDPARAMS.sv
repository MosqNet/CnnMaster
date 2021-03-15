`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 19:58:20
// Design Name: 
// Module Name: OUT_RDPARAMS
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


module OUT_RDPARAMS(
    input wire  IRST,
    input wire  ICLK,
    input wire  [7:0]  out_params_addr,
    output wire [31:0] out_bias_dout,
    output wire [1023:0] out_params_dout
);

    /* ----- parameter ----- */
    /* ------ register ----- */
    reg [7:0] d_addr4 [4:0];
    reg [31:0] addr4;
    /* ------- wire -------  */
    wire [31:0] addr128={24'b0,out_params_addr}<<7;
    
    always_ff @(posedge ICLK)begin
        d_addr4 <= {d_addr4[3:0],out_params_addr};
    end
    
    always_ff @(posedge ICLK)begin
        if(IRST) addr4 <= 0;
        else addr4 <= {24'b0,d_addr4[4]}<<2;
    end

    OUT_PARAMS out_params (
       .douta        (out_params_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr128),
       .clka         (ICLK)
    );    

    OUT_BIAS OUT_bias(
        .douta        (out_bias_dout), //--[127:0] for each [7:0] bias param.
        .addra        (addr4),
        .clka         (ICLK)
    );
endmodule
