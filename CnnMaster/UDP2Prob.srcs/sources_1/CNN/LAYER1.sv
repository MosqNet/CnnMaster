`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/14 15:50:58
// Design Name: 
// Module Name: LAYER1
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


module LAYER1(
    //-- System commons
    input wire  ICLK,
    input wire  IRST,
    //-- Input
    //input wire [7:0] IIMG [0:24], //-- 32 x 32 pixels image(gray scale).
    input wire [1023:0] IIMG,
    input wire  LENET_INIT,
    input wire  LENET_START,
    //-- Output.
    output wire L1LED_o,
    output wire CONV1_START, // cnn start signal
    output wire POOL1_END,
    output wire signed [14:0] POOL1_RESULT [5:0][195:0] // Layer1 result
);

   /*
    * ROM for Weight and bias parameters at 1st convolutions layer.
    */
    
    /* --- Parameter --- */
    /* --- reg & wire --- */
    
    wire [3:0]    conv1_params_addr; // RAM address register
    wire [255:0]  conv1_params_dout; // convolution 1 parameter register
    
    CONV1_RDPARAMS conv1_rdparams(
        //-- System commons
        .IRST               (IRST),
        .ICLK               (ICLK),
        //-- Input
        .conv1_params_addr  (conv1_params_addr),
        //-- Output
        .conv1_params_dout  (conv1_params_dout)
    );
   
   /*
    * Convolution processing at 1st layer
    */
    
    /* --- Parameter --- */
    /* --- reg & wire --- */
   wire signed [12:0]  conv1_pix;
   wire [4:0] conv1_x, conv1_y;
   wire conv1_valid;
   wire CONV1_CMP; // convolution 1 complete signal
    
    CONV1_TOP conv1_top (
     //-- System commons
     .IRST         (IRST),
     .ICLK         (ICLK),
     //-- Input
     .IINIT        (LENET_INIT),
     .ISTART       (LENET_START),
     .IPARAMS      (conv1_params_dout), //-- [255:0]
     .IIMG         (IIMG), //-- Input 32x32 image.
     //-- Output
     .CONV1_START    (CONV1_START),
     .CONV1_CMP    (CONV1_CMP),
     //.OEN          (conv1_en),
     .OVALID       (conv1_valid),
     .OPARAMS_ADDR (conv1_params_addr), //--> "conv1_params"
     .OX           (conv1_x), //-->  "conv1_relu"
     .OY           (conv1_y), //-->  "conv1_relu"
     .OCONV1       (conv1_pix) //[31:0] signed.
    );
   
   /*
    * ReLU at CONV1
    */
    
    /* --- Parameter --- */
    /* --- reg & wire --- */
    wire signed [12:0]    conv1_relu_out;
    wire        [9:0]     conv1_relu_addr;
    wire        [5:0]     conv1_relu_we;
   
   CONV1_RELU conv1_relu (
     //-- System commons
     .IRST         (IRST),
     .ICLK         (ICLK),
     //-- Input
     .IVALID      (conv1_valid),
     .IPARAMS_ADDR(conv1_params_addr),
     .IX          (conv1_x),
     .IY          (conv1_y),
     .IPIX_CONV   (conv1_pix), //[31:0] signed
     //-- Output 
     .ORELU_WE    (conv1_relu_we), //--> "conv1_ram_u0"
     .ORELU_ADDR  (conv1_relu_addr),  //--> "conv1_ram_u{0,1,2,3,4,5}"
     .ORELU       (conv1_relu_out)       //--> "conv1_ram_u{0,1,2,3,4,5}"
    );
      
   /*
    * Store CONV1 result
    */
    
   wire signed [12:0] conv1_result [5:0];
   wire [9:0]   conv1_result_addr;
   
   CONV1_RESULTS conv1_results (
    //-- System commons
    .IRST(IRST), 
    .ICLK(ICLK),
    //-- Input
    .IWE(conv1_relu_we), //[5:0]
    .IWADDR(conv1_relu_addr),
    .IRADDR(conv1_result_addr),
    .ID(conv1_relu_out),
    //-- Output
    .OD(conv1_result)
   );

   wire        pool1_start = CONV1_CMP;
   
   parameter   POOL1_IIMG_SIZE = 784;
   parameter   POOL1_WIDTH = 14;
   parameter   POOL1_SIZE = POOL1_WIDTH * POOL1_WIDTH;
   
   POOL1_TOP #(
       //-- Parameters
       .POOL1_IIMG_SIZE   (POOL1_IIMG_SIZE),
       .POOL1_WIDTH       (POOL1_WIDTH),
       .POOL1_SIZE        (POOL1_SIZE)
   ) pool1_top (
       //-- Input
       .ISTART (pool1_start),
       .OEND   (POOL1_END),
       .ID     (conv1_result),
       //-- Output
       .ORADDR (conv1_result_addr),
       .L1LED_o (L1LED_o),
       .POOL1_RESULT(POOL1_RESULT),
       //-- System Commons
       .IRST   (IRST),
       .ICLK   (ICLK)
   );

endmodule
