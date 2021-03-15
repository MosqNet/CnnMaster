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

module CONV1_CORE (
   //-- System
   input wire         ICLK,
   input wire         IRST,
   //-- Inputs
   input wire         IVALID,
   //input wire [7:0]   IPIX[0:24], 
   input wire [24:0]IPIX , 
   input wire [255:0] IKNL,  //<-- from RAM.
   input wire [4:0]   IX,
   input wire [4:0]   IY,
   //-- Outputs
   output wire signed [12:0]  OPIX_CONV, //-- Convoluted value 1 pixel.
   output wire        OVALID,
   output wire [4:0]  OX,
   output wire [4:0]  OY,
   output wire          OXY_LAST
); //-----------------------------------------------------------------
   
   /* ----- parameter ----- */
   localparam [4:0] x_last = 5'd27;
   localparam [4:0] y_last = 5'd27;
   /* ------ register ----- */
   reg [2:0]          r_valid;
   /* ------- wire -------  */
   wire signed [12:0] mul[0:24];
   wire signed [7:0]  knl[0:24];
   wire signed [7:0]  bias;
   wire signed [12:0] s_bias;
   
   /*
    * Slice bits by each byte.
    */

   generate
       genvar knl_id;
       for(knl_id=0; knl_id<25; knl_id=knl_id+1)begin
           assign knl[knl_id] = (IKNL[255-(knl_id*8)]) ? ~{1'b0,IKNL[254-(knl_id*8) : 248-(knl_id*8)]} + 1 : IKNL[255-(knl_id*8) : 248-(knl_id*8)];
       end
   endgenerate
   
      /*
     * convert to 2's complement
     */
     assign bias = (IKNL[55]) ? ~{1'b0,IKNL[54:48]}+1 : IKNL[55:48];
  
     assign s_bias = 13'(signed'(bias));
     
   /*
    * 25 Parallel multiplication
    */
   genvar mult_id;
   generate
   for(mult_id=0; mult_id<25; mult_id=mult_id+1)begin
       CONV1MULT mult(.A(IPIX[mult_id]), .B(knl[mult_id]), .P(mul[mult_id]), .CLK(ICLK));
   end
   endgenerate

   reg mul_valid;
   always @ (posedge ICLK)begin
      if(IRST) mul_valid <= 1'b0;
      else     mul_valid <= IVALID;
   end

   reg [4:0] pos_x;
   reg [4:0] pos_y;
   always @ (posedge ICLK) begin
      if(IRST) begin
         pos_x <= 5'h1e;
         pos_y <= 5'h1e;
      end
      else if (IVALID) begin
         pos_x <= IX;
         pos_y <= IY;
      end
      else begin
         pos_x <= 5'h1e;
         pos_y <= 5'h1e;
      end
   end // always @ (posedge ICLK)
   
    reg [4:0]  r_ox;
    reg [4:0]  r_oy;
   
   always @ (posedge ICLK) begin
      if(IRST) begin
         r_ox <= 5'h1e;
         r_oy <= 5'h1e;
      end
      else if (mul_valid) begin
         r_ox <= pos_x;
         r_oy <= pos_y;
      end
      else begin
         r_ox <= 5'h1e;
         r_oy <= 5'h1e;
      end
   end // always @ (posedge ICLK)
   
   assign OX = r_ox;
   assign OY = r_oy;

   assign OXY_LAST = (IRST)? 1: (pos_x==x_last && pos_y==y_last);

    integer i;
    reg [12:0] s_OPIX_FULL;
    reg [12:0] r_opix_full;
    
    always_comb begin
       s_OPIX_FULL = 0;
       for (i=0;i<25;i=i+1) begin
            s_OPIX_FULL = s_OPIX_FULL + mul[i];
       end
    end
    always_ff @ (posedge ICLK)begin
       r_opix_full <= s_OPIX_FULL+ s_bias; 
    end   
    
    assign OPIX_CONV = r_opix_full;
    
   reg sum_valid;
   always @ (posedge ICLK)begin
      if(IRST) sum_valid <= 1'b0;
      else     sum_valid <= mul_valid;
   end
   assign OVALID = sum_valid;
   
   /* ------ simulation ------ */
   
   `ifdef SIM_FLAG
       real PIX_CONV_RESULT[0:195];
       real r_OPIX_CONV, exp_OPIX_CONV, r_bias;
       real exp_MUL [0:24];
       real r_PIX [0:24];
       real r_KNL [0:24];
       real r_MUL [0:24];
       genvar g;
       always_comb begin
           r_OPIX_CONV = $itor(OPIX_CONV) / 64.0;
           r_bias      = $itor(bias)    / 64.0;
       end    
       generate
       for(g=0;g<25;g=g+1)begin
           assign r_PIX[g] = $itor(IPIX[g]);
           assign r_KNL[g] = $itor(knl[g])   / 64.0;
           assign r_MUL[g] = $itor(mul[g]) / 64.0;
           assign exp_MUL[g] = r_PIX[g] * r_KNL[g];
       end
       endgenerate
       
       always_ff @(posedge ICLK) begin
        exp_OPIX_CONV <= exp_MUL[0]  + exp_MUL[1]  + exp_MUL[2]  + exp_MUL[3]  + exp_MUL[4]  +
                                                  exp_MUL[5]  + exp_MUL[6]  + exp_MUL[7]  + exp_MUL[8]  + exp_MUL[9]  +
                                                  exp_MUL[10] + exp_MUL[11] + exp_MUL[12] + exp_MUL[13] + exp_MUL[14] +
                                                  exp_MUL[15] + exp_MUL[16] + exp_MUL[17] + exp_MUL[18] + exp_MUL[19] +
                                                  exp_MUL[20] + exp_MUL[21] + exp_MUL[22] + exp_MUL[23] + exp_MUL[24] +
                                                  r_bias;
       end
       
   `endif
   
   
endmodule // CONV1_CORE