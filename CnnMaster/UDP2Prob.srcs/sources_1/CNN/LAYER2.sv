`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 15:50:58
// Design Name: 
// Module Name: LAYER2
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


module LAYER2(
//-- System commons
input wire         ICLK,
input wire         IRST,
//-- Input
input wire L2_INIT,
input wire L2_START,
input wire signed [14:0] POOL1_RESULT [5:0][195:0],
//-- Output
output wire L2LED_o,
output wire POOL2_END,
output wire signed [24:0] POOL2_RESULT [15:0][24:0]
    );
    
    /*
    * ROM for Weight and bias parameters at 2nd convolutions layer.
    */

    wire [4:0]   conv2_params_addr;
    wire [31:0] conv2_bias_dout;
    wire [255:0] conv2_params_dout [5:0];
    
    CONV2_RDPARAMS conv2_rdparams(
    //-- System commons
    .ICLK   (ICLK),
    .IRST   (IRST),
    //-- Input
    .conv2_params_addr    (conv2_params_addr),
    .conv2_bias_dout      (conv2_bias_dout),
    //-- Output
    .conv2_params00_dout  (conv2_params_dout[0]),
    .conv2_params01_dout  (conv2_params_dout[1]),
    .conv2_params02_dout  (conv2_params_dout[2]),
    .conv2_params03_dout  (conv2_params_dout[3]),
    .conv2_params04_dout  (conv2_params_dout[4]),
    .conv2_params05_dout  (conv2_params_dout[5])
    );

   /*
    * Convolution processing at 2nd layer
    */
    
    wire RELUINIT;
    wire signed [24:0] conv2_pix;
    wire [4:0]  conv2_x, conv2_y;
    wire conv2_en,conv2_valid;
    wire CONV2_CMP;
    
    CONV2_TOP conv2_top (
    //-- System Commons
    .IRST(IRST),
    .ICLK(ICLK),
    //-- Input
    .L2_INIT (L2_INIT),
    .L2_START(L2_START),
    .IIMG(POOL1_RESULT),
    .CONV2_BIAS_DOUT(conv2_bias_dout),
    .IPARAMS(conv2_params_dout),
    //-- Output 
    .OPARAMS_ADDR(conv2_params_addr),
    .OCONV2       (conv2_pix), //[31:0] signed.
    //.CONV2_START(L2_START),
    .CONV2_CMP (CONV2_CMP),
    .OX           (conv2_x),
    .OY           (conv2_y),
    .OEN          (conv2_en),
    .OVALID       (conv2_valid),
    .RELUINIT     (RELUINIT)
    );
       
/*------------ CONV2 RELU  ---------------*/
    wire signed [24:0]    conv2_relu_out;
    wire [6:0]     conv2_relu_addr;
    wire [15:0]    conv2_relu_we;
    
    CONV2_RELU conv2_relu(
    //-- System commons
    .IRST         (IRST),
    .ICLK         (ICLK),
    //-- Input
    .IINIT       (RELUINIT),
    .IEN         (conv2_en),
    .IVALID      (conv2_valid),
    .IPARAMS_ADDR(conv2_params_addr),
    .IX          (conv2_x),
    .IY          (conv2_y),
    .IPIX_CONV   (conv2_pix), //[31:0] signed
    //-- Output 
    .ORELU_WE    (conv2_relu_we), //--> "conv1_ram_u0"
    .ORELU_ADDR  (conv2_relu_addr),  //--> "conv1_ram_u{0,1,2,3,4,5}"
    .ORELU       (conv2_relu_out)       //--> "conv1_ram_u{0,1,2,3,4,5}"
   );
   
   
   
/*------------- CONV2 RESULTS  -----------------*/
    wire [6:0] conv2_result_addr;
    wire signed [24:0] conv2_result [15:0];
    
    CONV2_RESULTS conv2_results(
        //-- System commons
        .IRST   (IRST),
        .ICLK   (ICLK),
        //-- Input (write)
        .IWE    (conv2_relu_we),        //[15:0]
        .IWADDR (conv2_relu_addr),      //[6:0]
        .IRADDR (conv2_result_addr),    //[6:0]
        .ID     (conv2_relu_out),       //[31:0]
        //-- Output (read)
        .OD   (conv2_result)         //[31:0][15:0]
    );

/*----------- CONV2 POOLING -----------*/
    parameter   POOL2_IIMG_SIZE = 100;
    parameter   POOL2_WIDTH = 5;
    parameter   POOL2_SIZE = POOL2_WIDTH * POOL2_WIDTH;
    wire        pool2_start = CONV2_CMP;
    
    
    POOL2_TOP #(
        .POOL2_IIMG_SIZE   (POOL2_IIMG_SIZE),
        .POOL2_WIDTH       (POOL2_WIDTH),
        .POOL2_SIZE        (POOL2_SIZE)
    ) pool2_top (
        .ISTART (pool2_start),
        .OEND   (POOL2_END),
        .ID     (conv2_result),
        .L2LED_o (L2LED_o),
        .ORADDR (conv2_result_addr),
        .POOL2_RESULT (POOL2_RESULT),
        .IRST   (IRST),
        .ICLK   (ICLK)
    );
    
endmodule
