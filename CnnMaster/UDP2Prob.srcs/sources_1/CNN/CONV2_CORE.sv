`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 19:27:13
// Design Name: 
// Module Name: CONV2_CORE
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

//                              -*- Mode: Verilog -*-
// Filename        : CONV1_CORE.sv
// Description     : 
// Author          : 
// Created On      : Sun Nov  8 17:23:53 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 18:57:36
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module CONV2_CORE (
   input wire         ICLK,
   input wire         IRST,
   //-- Inputs
   input wire         IVALID,
   input wire signed [14:0]  IPIX[24:0], 
   input wire [255:0] IKNL,  //<-- from RAM.
   input wire [31:0] IBIAS, //<-- from ROM
   input wire [4:0]   IX,
   input wire [4:0]   IY,
   //-- Outputs
   output wire signed [24:0]  OPIX_CONV, //-- Convoluted value 1 pixel.
   output wire OVALID
   //output reg [11:0]  OWADDR
   ); //-----------------------------------------------------------------
   
   /* ----- parameter ----- */
   /* ------ register ----- */
   reg [2:0]          r_valid;
   /* ------- wire -------  */
   wire signed [15:0] mul[0:24];
   //wire signed [31:0] amul[0:24];
   wire signed [7:0]  knl[0:24];
   wire signed [7:0]  bias;
   wire signed [15:0] s_bias;
   
   /*
    * Slice bits by each byte and convert to 2's complement
    */
   generate
        genvar knl_id;
        for(knl_id=0; knl_id<25; knl_id=knl_id+1)begin
            assign knl[knl_id] = (IKNL[255-(knl_id*8)]) ? ~{1'b0,IKNL[254-(knl_id*8) : 248-(knl_id*8)]} + 1 : IKNL[255-(knl_id*8) : 248-(knl_id*8)];
            //assign amul[knl_id] = (IFLOATP[knl_id]) ? mul[knl_id] >>> 2 :  mul[knl_id];
        end
   endgenerate
   
   /*
   * convert to 2's complement
   */
   assign bias = (IBIAS[31]) ? ~{1'b0,IBIAS[30:24]}+1 : IBIAS[31:24];

   assign s_bias = 16'(signed'(bias) <<< 8);
   
   /*
    * 25 Parallel multiplication
    */
   genvar mult_id;
   generate
   for(mult_id=0; mult_id<25; mult_id=mult_id+1)begin
       CONV2MULT mult(.A(IPIX[mult_id]), .B(knl[mult_id]), .P(mul[mult_id]), .CLK(ICLK));
   end
   endgenerate
   
//   integer i;
//   reg [24:0] s_OPIX_CONV;
   
//   always_comb begin
//      s_OPIX_CONV = 0;
//      for (i=0;i<25;i=i+1) begin
//           s_OPIX_CONV = s_OPIX_CONV + mul[i];
//      end
//   end
//   always_ff @ (posedge ICLK)begin
//      OPIX_CONV <= s_OPIX_CONV; 
//   end   

    reg [24:0] r_opix_conv;

    always_ff @(posedge ICLK) begin
        r_opix_conv <= mul[0] + mul[1] + mul[2] + mul[3] + mul[4] + 
                                  mul[5] + mul[6] + mul[7] + mul[8] + mul[9] + 
                                  mul[10] + mul[11] + mul[12] + mul[13] + mul[14] + 
                                  mul[15] + mul[16] + mul[17] + mul[18] + mul[19] + 
                                  mul[20] + mul[21] + mul[22] + mul[23] + mul[24]; 
    end
   
   assign OPIX_CONV = r_opix_conv;

   always_ff @ (posedge ICLK) begin
      if (IRST) r_valid <= 0;
      else      r_valid <= {r_valid[1:0], IVALID};
   end
   assign OVALID = r_valid[2];

   /*
    * TODO:  convert from IX, IY to RAM address.
    */
//   always @ (posedge ICLK) begin
//      OWADDR <= 12'h1234;
//   end
   
//`ifdef SIM_FLAG
//    real r_OPIX_CONV, exp_OPIX_CONV, r_bias;
//    real exp_MUL [24:0];
//    real r_PIX [24:0];
//    real r_KNL [24:0];
//    real r_MUL [24:0];
//    genvar g;
//    always_comb begin
//        r_OPIX_CONV = $itor(OPIX_CONV) / 16384.0;
//        r_bias      = $itor(bias) / 64.0 ;
//    end    
//    generate
//    for(g=0;g<25;g=g+1)begin
//        //assign r_PIX[g] = (IFLOATP[g]) ? $itor(IPIX[g])/256.0 : $itor(IPIX[g])/64.0 ;
//        assign r_PIX[g] =  $itor(IPIX[g]) /256.0;
//        assign r_KNL[g] = $itor(knl[g])   / 64.0;
//        assign r_MUL[g] = $itor(mul[g]) / 16384.0;
//        always_ff @(posedge ICLK) begin
//           exp_MUL[g] = r_PIX[g] * r_KNL[g];
//        end
//    end
//    endgenerate
    
//    always_ff @(posedge ICLK) begin
//        exp_OPIX_CONV <= exp_MUL[0]   + exp_MUL[1]   + exp_MUL[2]  + exp_MUL[3]  + exp_MUL[4]  +
//                                         exp_MUL[5]   + exp_MUL[6]   + exp_MUL[7]  + exp_MUL[8]  + exp_MUL[9]  +
//                                         exp_MUL[10] + exp_MUL[11] + exp_MUL[12] + exp_MUL[13] + exp_MUL[14] +
//                                         exp_MUL[15] + exp_MUL[16] + exp_MUL[17] + exp_MUL[18] + exp_MUL[19] +         
//                                         exp_MUL[20] + exp_MUL[21] + exp_MUL[22] + exp_MUL[23] + exp_MUL[24];
//                                         //+r_bias;
//     end
//`endif
   
endmodule // CONV2_CORE
