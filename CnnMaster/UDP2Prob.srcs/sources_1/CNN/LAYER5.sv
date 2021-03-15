`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 15:50:58
// Design Name: 
// Module Name: LAYER5
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


module LAYER5(
//-- System commons
input wire         ICLK,
input wire         IRST,
//-- Input
input wire FULL2_CMP,
input wire signed [41:0]    FULL2_RESULT [0:83],
//-- Output
output wire L5LED_o,
output wire PMOD_C0,
output wire PMOD_C1,
output wire LENET_CMP,
output wire signed [63:0] LENET_RESULT[0:9]

    );
    
    //     /*------------ OUT READ PARAMS---------------*/
         
         wire [7:0]  out_params_addr;
         wire [31:0] out_bias_dout;
         wire [1023:0] out_params_dout;
         
         OUT_RDPARAMS out_rdparams(
             .out_params_addr   (out_params_addr),
             .out_bias_dout     (out_bias_dout),
             .out_params_dout   (out_params_dout),
             //--system
             .IRST(IRST),
             .ICLK(ICLK)
         );
         
         
         /*------------ OUT TOP  ---------------*/
         
         wire OUT_CMP;
         wire signed [63:0] OUT_CORE;
         wire out_result_we;
         
         OUT_TOP OUT_top (
         //-- System commons
         .IRST(IRST),
         .ICLK(ICLK),
         //-- Input
            .IINIT          (0),
            .OUT_START     (FULL2_CMP),
            .ID              (FULL2_RESULT),
            .OUT_BIAS_ID   (out_bias_dout),
            .IPARAMS         (out_params_dout),
            .OPARAMS_ADDR    (out_params_addr),
            .OUT_CMP         (OUT_CMP),
            .OINIT           (out_result_we),
            .OUT_CORE        (OUT_CORE)
         );
         
         assign LENET_CMP = OUT_CMP;     
         
         LENET_RESULT lenet_result(
            .ID       (OUT_CORE),   //[31:0]
            //.IVALID           (full1_valid),
            .IINIT            (out_result_we),
            .PMOD_C0(PMOD_C0),
            .PMOD_C1(PMOD_C1),
            .LENET_RESULT    (LENET_RESULT),   //[31:0]
            //.OVALID           (),
            .IRST             (IRST),
            .ICLK             (ICLK)
         );
endmodule
