`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 15:50:58
// Design Name: 
// Module Name: LAYER3
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


module LAYER3(
//-- System commons
input wire         ICLK,
input wire         IRST, 
//-- Input
input wire L3_START,
input wire signed [24:0] POOL2_RESULT [15:0][24:0],
//-- Output
output wire L3LED_o,
output wire PMOD_B1,
output wire PMOD_B2,
output wire FULL1_CMP,
output wire signed [31:0] FULL1_RESULT[0:119]
    );

    /* ------------------ REPLACE ----------------- */
    
    wire signed [24:0] REPLACE_RESULT [15:0][24:0];
    
    ARRAY_REPLACE array_replace(
        //-- Input
        .POOL2_RESULT(POOL2_RESULT),
        //-- Output
        .REPLACE_RESULT(REPLACE_RESULT) 
    );
    
        /*------------ FULL1 READ PARAMS---------------*/
    
    (*dont_touch="true"*)wire [7:0]  full1_params_addr;
    (*dont_touch="true"*)wire [31:0] full1_bias_dout;
    (*dont_touch="true"*)wire [255:0] full1_params_dout [15:0];
    
    FULL1_RDPARAMS full1_rdparams(
        .full1_params_addr(full1_params_addr),
        .full1_bias_dout(full1_bias_dout),
        .full1_params00_dout(full1_params_dout[0]),
        .full1_params01_dout(full1_params_dout[1]),
        .full1_params02_dout(full1_params_dout[2]),
        .full1_params03_dout(full1_params_dout[3]),
        .full1_params04_dout(full1_params_dout[4]),
        .full1_params05_dout(full1_params_dout[5]),
        .full1_params06_dout(full1_params_dout[6]),
        .full1_params07_dout(full1_params_dout[7]),
        .full1_params08_dout(full1_params_dout[8]),
        .full1_params09_dout(full1_params_dout[9]),
        .full1_params10_dout(full1_params_dout[10]),
        .full1_params11_dout(full1_params_dout[11]),
        .full1_params12_dout(full1_params_dout[12]),
        .full1_params13_dout(full1_params_dout[13]),
        .full1_params14_dout(full1_params_dout[14]),
        .full1_params15_dout(full1_params_dout[15]),
        //--system
        .IRST(IRST),
        .ICLK(ICLK)
    );
    
    /*------------ FULL1 TOP  ---------------*/
    
    
    wire signed [31:0] OFULL1;
    wire full1_result_we;
    wire FULL1_END;
    
    FULL1_TOP full1_top (
    //-- System commons
    .IRST(IRST),
    .ICLK(ICLK),
    //-- Input
       .FULL1_START     (L3_START),
       .IINIT           (0),
       .ID              (REPLACE_RESULT),
       .FULL1_BIAS_ID   (full1_bias_dout),
       .IPARAMS       (full1_params_dout),
       .OPARAMS_ADDR    (full1_params_addr),
       .OINIT           (full1_result_we),
       .OFULL1     (OFULL1)
    );
       
       /*------------ FULL1 RELU  ---------------*/
       wire [31:0]    full1_relu_out;
       wire [6:0]     full1_relu_addr;
       wire [15:0]    full1_relu_we;
       
       FULL1_RELU full1_relu (
           .IFULL1       (OFULL1),   //[31:0]
           .IVALID        (),
           .IINIT            (full1_result_we),
           .L3LED_o    (L3LED_o),
           .PMOD_B1(PMOD_B1),
           .PMOD_B2(PMOD_B2),
           .FULL1_CMP       (FULL1_CMP),
           .FULL1_RESULT     (FULL1_RESULT),        //--> "conv2_ram_u{0,1,2,-->,14,15}"
           .IRST             (IRST),
           .ICLK             (ICLK)
       );
       
       
//       FULL1_RELU_TOP full1_relu_top(
//           .FULL1_ID       (OFULL1),   //[31:0]
//           //.IVALID           (full1_valid),
//           .IINIT            (full1_result_we),
//           .full1_result     (FULL1_RESULT),   //[31:0]
//           //.OVALID           (),
//           .IRST             (IRST),
//           .ICLK             (ICLK)
//       );

endmodule
