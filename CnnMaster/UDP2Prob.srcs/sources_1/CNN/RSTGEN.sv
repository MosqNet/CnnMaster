//                              -*- Mode: Verilog -*-
// Filename        : RSTGEN.v
// Description     : 
// Author          : 
// Created On      : Sun Feb  4 21:11:18 2018
// Last Modified By: 
// Last Modified On: 2018-02-04 21:11:19
// Update Count    : 0
// Status          : Unknown, Use with caution!

module RSTGEN (/*AUTOARG*/
   // Outputs
   reset_o,
   // Inputs
   clk, locked_i, reset_i
   ) ;
   input clk;
   input locked_i; //--
   input reset_i; //--
   output reset_o;  //-- 

   reg [7:0] sft;
   wire      rst_root = (~locked_i | reset_i);
 
   always @(posedge clk, posedge rst_root) begin
      if (rst_root) sft <= 8'hFF;
      else          sft <= {sft[6:0], 1'b0};
   end
   assign reset_o = sft[7];
endmodule // RSTGEN
