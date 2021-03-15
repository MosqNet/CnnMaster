`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 17:47:26
// Design Name: 
// Module Name: CONV2_TOP
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
`include "LENET.vh"

module CONV2_TOP(
    //-- System commons
    input wire IRST,
    input wire ICLK,
    //-- Input
    input wire L2_INIT,
    input wire L2_START,
    input wire signed [14:0] IIMG [5:0][195:0],
    input wire [31:0] CONV2_BIAS_DOUT,
    input wire [255:0] IPARAMS [5:0],
    //-- Output
    output wire [4:0] OPARAMS_ADDR,
    output wire signed [24:0] OCONV2,
    output wire CONV2_CMP,
    output wire OEN,
    output wire OVALID,
    output wire [4:0]  OX,
    output wire [4:0]  OY,
    output wire CONV2_START,
    output wire RELUINIT
);

   wire [4:0]       cutter_x, cutter_y;
   wire             cutter_init, cutter_en, cutter_valid;
   wire             cutter_cr, cutter_last;
   
   assign CONV2_START = cutter_init;
   assign OX = cutter_x;
   assign OY = cutter_y;
   assign OEN = cutter_en;
   assign OVALID = cutter_valid;

   /*
    * Generate (x,y) coordinate sequence from the 32x32 input image.
    */
   IMG_CUTTER2 img_cutter2 (
      .IINIT    (cutter_init),
      .IEN      (cutter_en),
      .OX       (cutter_x),       //--> "knl_window"
      .OY       (cutter_y),       //--> "knl_window"
      .OVALID   (cutter_valid),   //--> "knl_window"
      .OCR      (cutter_cr),
      .OLAST    (cutter_last),
      .IRST     (IRST),
      .ICLK     (ICLK)
   );
   /*
    * Select the specified 5x5 pixels from input 32x32 image.
    */
   wire signed [14:0] window_img[5:0][24:0];
   wire [5:0] window_valid;
   wire [4:0] window_x [5:0];
   wire [4:0] window_y [5:0];
   
   parameter WIN_NUM = 6;
   
   genvar win_i;
   generate
    for(win_i=0;win_i<WIN_NUM;win_i=win_i+1)begin
       CONV2_KNL_WINDOW conv2_knl_window (
       .IIMG     (IIMG[win_i]),    //<-- INPUT
       .IX       (cutter_x),       //<-- "img_cutter"
       .IY       (cutter_y),       //<-- "img_cutter"
       .IVALID   (cutter_valid),   //<-- "img_cutter"
       .OIMG     (window_img[win_i]),     //[7:0][0:24] --> "conv1_core"
       .OVALID   (window_valid[win_i]),
       .OX       (window_x[win_i]),
       .OY       (window_y[win_i]),
       .IRST     (IRST),
       .ICLK     (ICLK)
    );
    end
   endgenerate

   //wire       conv2_core_valid;
   parameter KERNEL_NUM = 6;
   wire signed [24:0] oconv2_core [5:0];
   
   //add 2020 12/30
   wire signed [7:0] bias;
   wire signed [24:0] s_bias;
   
   genvar img_i;
   generate
   
   for(img_i=0;img_i<6;img_i=img_i+1)begin
    CONV2_CORE conv2_core(
    .IPIX     (window_img[img_i]),        //[7:0][0:24] <-- "knl_window"
    .IKNL     (IPARAMS[img_i]),               //[255:0] <-- "knl_params"
    .IBIAS    (CONV2_BIAS_DOUT),
    .IX       (window_x[0]),
    .IY       (window_y[0]),
    .IVALID   (window_valid[0]),    // <-- "knl_window"
    .OPIX_CONV(oconv2_core[img_i]), 
    //.OVALID   (conv2_core_valid),
    //.OWADDR   (),
    .IRST     (IRST), 
    .ICLK     (ICLK)
    );
   end
   endgenerate
   
   assign bias = (CONV2_BIAS_DOUT[31]) ? ~{1'b0,CONV2_BIAS_DOUT[30:24]}+1 : CONV2_BIAS_DOUT[31:24];
   assign s_bias = 24'(signed'(bias) <<< 8);

   assign OCONV2 = oconv2_core[0] + oconv2_core[1] + oconv2_core[2] + oconv2_core[3] + 
                                 oconv2_core[4] + oconv2_core[5] + s_bias;

   /*
    * Arbiter for 1st convolutions.
    */
   wire [3:0]       ctrl_st;  //-- FSM
   wire [31:0]      conv1_params_wea; //byte write enable.
   CONV2_CTRL conv2_ctrl (
        //-- System Commons
        .IRST   (IRST),
        .ICLK   (ICLK),
        //-- Main controls.
        .IINIT    (L2_INIT),
        .ISTART   (L2_START),   //--> rising edge detect.
        //-- "img_cutter"
        .OINIT    (cutter_init),    //--> "img_cutter"
        .OEN      (cutter_en),      //--> "img_cutter"
        .ILAST    (cutter_last),    //<-- "img_cutter"                
        .OPARAM_ADDR (OPARAMS_ADDR), //--> "conv1_params"
        .RELUINIT (RELUINIT),
        //-- Info
        .OST    (ctrl_st),    //[2:0]--> current operating unit index.
        .CONV2_CMP (CONV2_CMP)
   );
   
   
   /* ----- simulation ----- */
   `ifdef SIM_FLAG
   real r_oconv2[5:0];
   real r_OCONV2;
   real sum_oconv2;
   real exp_OCONV2;
   real r_bias;
    
    genvar sim_i;
    generate
        for(sim_i=0; sim_i<6; sim_i=sim_i+1)begin
            always_comb begin
                r_oconv2[sim_i] =  $itor(oconv2_core[sim_i]) /16384.0;
            end
        end
    endgenerate
    
    assign r_bias      = $itor(bias) / 64.0 ;
    
    assign sum_oconv2 = r_oconv2[0]+r_oconv2[1]+r_oconv2[2]+r_oconv2[3]+r_oconv2[4]+r_oconv2[5];
    assign exp_OCONV2 = r_oconv2[0]+r_oconv2[1]+r_oconv2[2]+r_oconv2[3]+r_oconv2[4]+r_oconv2[5]+r_bias;
    assign r_OCONV2 = $itor(OCONV2)   / 16384.0;
   
   `endif
   
endmodule
