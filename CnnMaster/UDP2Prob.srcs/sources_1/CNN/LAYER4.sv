`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 15:50:58
// Design Name: 
// Module Name: LAYER4
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


module LAYER4(
//-- System commons
input wire         ICLK,
input wire         IRST, 
//-- Input
input wire FULL2_START,
input wire signed [31:0] FULL1_RESULT [0:119],
//-- Output
output wire L4LED_o,
output wire PMOD_B4,
output wire PMOD_B5,
output wire FULL2_CMP,
output wire signed [41:0] FULL2_RESULT [0:83]
    );
    
    /*------------ FULL2 READ PARAMS---------------*/
    
    wire [7:0]    full2_params_addr;
    wire [31:0]   full2_bias_dout;
    wire [1023:0] full2_params_dout;
    
    FULL2_RDPARAMS full2_rdparams(
        .full2_params_addr (full2_params_addr),
        .full2_bias_dout   (full2_bias_dout),
        .full2_params_dout (full2_params_dout),
        //--system
        .IRST(IRST),
        .ICLK(ICLK)
    );
    
    /*------------ FULL2 TOP  ---------------*/
    
    wire signed [41:0] OFULL2;
    wire full2_result_we;
    
    FULL2_TOP full2_top (
    //-- System commons      
    .IRST(IRST),
    .ICLK(ICLK),
    //-- Input
    .IINIT           (0),
    .FULL2_START     (FULL2_START),
    .ID              (FULL1_RESULT),
    .FULL2_BIAS_ID   (full2_bias_dout),
    .IPARAMS         (full2_params_dout),
    .OPARAMS_ADDR    (full2_params_addr),
    .OINIT           (full2_result_we),
    .ofull2_core     (OFULL2)
    );
    
    /*------------ FULL2 RELU  ---------------*/
           
    FULL2_RELU full2_relu (
        .IFULL2       (OFULL2),   //[31:0]
        .IVALID        (),
        .IINIT            (full2_result_we),
        .L4LED_o    (L4LED_o),
        .PMOD_B4(PMOD_B4),
        .PMOD_B5(PMOD_B5),
        .FULL2_CMP (FULL2_CMP),
        .FULL2_RESULT     (FULL2_RESULT),        //--> "conv2_ram_u{0,1,2,-->,14,15}"
        .IRST             (IRST),
        .ICLK             (ICLK)
    );
    
//    FULL2_RELU_TOP full2_relu_top(
//        .FULL2_ID       (OFULL2),   //[31:0]
//        //.IVALID           (full1_valid),
//        .IINIT            (full2_result_we),
//        .full2_result     (FULL2_RESULT),   //[31:0]
//        //.OVALID           (),
//        .IRST             (IRST),
//        .ICLK             (ICLK)
//    );
    
endmodule
