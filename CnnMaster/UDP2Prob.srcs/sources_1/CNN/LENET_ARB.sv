//                              -*- Mode: Verilog -*-
// Filename        : LENET_ARB.sv
// Description     : 
// Author          : 
// Created On      : Wed Nov 11 17:03:31 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 17:12:52
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module LENET_ARB (
   input wire ISTART,
   output wire OCONV1_INIT,
   output wire OCONV1_START,
   output wire OPOOL1_INIT,
   output wire OPOOL1_START,
   output wire OCONV2_INIT,
   output wire OCONV2_START,

   input wire IRST,
   input wire ICLK
   ) ;
   reg  st, nx;
   
   always @ (posedge ICLK) begin
      if (IRST) st <= `LENET_IDLE_ST;
      else      st <= nx;
   end
   always_comb begin
      nx = st;
      case (st) 
        `LENET_IDLE_ST: begin
           
        end
      endcase // case (st)
   end
   
endmodule // LENET_ARB

