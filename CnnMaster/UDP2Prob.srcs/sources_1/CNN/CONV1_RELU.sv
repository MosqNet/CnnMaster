//                              -*- Mode: Verilog -*-
// Filename        : CONV1_RELU.sv
// Description     : 
// Author          : 
// Created On      : Wed Nov 11 13:39:11 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 19:05:01
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module CONV1_RELU (
    //-- System commons
    input wire        IRST,
    input wire        ICLK,
    //-- Input
    input wire        IVALID,
    input wire [3:0]  IPARAMS_ADDR,
    input wire [4:0]  IX, 
    input wire [4:0]  IY,
    input wire signed [12:0] IPIX_CONV,
    //-- Output
    // output wire        OVALID,
    output wire [5:0]  ORELU_WE,
    output wire [9:0]  ORELU_ADDR,
    output wire signed [12:0] ORELU
   );//------------------------------------------------------
   
   /* ----- parameter ----- */
   /* ------ register ----- */
   /* ------- wire -------  */
   
   wire s_sign_bit = IPIX_CONV[12];
   wire signed [12:0] s_relu = (s_sign_bit)? 13'd0 : IPIX_CONV;
   
   reg signed [12:0] r_orelu;
   
   always_ff @(posedge ICLK) begin
    r_orelu <= s_relu;
   end
   
   assign ORELU = r_orelu;
   
//   always_ff @ (posedge ICLK) begin
//      if(IRST) OVALID <= 1'b0;
//      else     OVALID <= IVALID;
//   end
   /*---Control RAM Signal---*/
   wire [9:0] s_addr = IX + (IY << 2) + (IY << 3) + (IY << 4);  // IX + IY * 28
   reg  [9:0] r_orelu_addr;
   always_ff @(posedge ICLK)begin
      r_orelu_addr <= s_addr;
   end

    assign ORELU_ADDR = r_orelu_addr;

   wire mul_en = IVALID;   // Mul Result Enable

   reg [5:0] r_orelu_we;
   
   always_ff @(posedge ICLK) begin
      if(IRST) r_orelu_we <= 5'b0;
      else begin
          case(IPARAMS_ADDR)
             4'd0 : r_orelu_we[0] <= mul_en;
             4'd1 : r_orelu_we[1] <= mul_en;
             4'd2 : r_orelu_we[2] <= mul_en;
             4'd3 : r_orelu_we[3] <= mul_en;
             4'd4 : r_orelu_we[4] <= mul_en;
             4'd5 : r_orelu_we[5] <= mul_en;
             default : r_orelu_we <= 5'b0;
          endcase
      end
   end
   
   assign ORELU_WE = r_orelu_we;
   
   /* ------ simulation ------- */
   `ifdef SIM_FLAG
   
   real r_IPIX_CONV, r_ORELU ,exp_ORELU;
       
   always_comb begin
       assign r_IPIX_CONV = $itor(IPIX_CONV) / 64.0;
       assign r_ORELU     = $itor(ORELU)    / 64.0;
       assign exp_ORELU   = (IPIX_CONV[31]) ?  0 :  $itor(IPIX_CONV)/64.0;
   end    
   
   `endif

endmodule // CONV1_RELU
