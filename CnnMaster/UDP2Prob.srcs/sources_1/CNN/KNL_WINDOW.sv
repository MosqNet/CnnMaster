//                              -*- Mode: Verilog -*-
// Filename        : KNL_WINDOW.sv
// Description     : 
// Author          : 
// Created On      : Sun Nov  8 19:52:51 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 18:52:04
// Update Count    : 0
// Status          : Unknown, Use with caution!

module KNL_WINDOW (
   input wire [7:0]  IIMG [24:0], //-- 32 x 32 pixels.
   input wire [4:0]  IX, //-- coordinate(x,y),
   input wire [4:0]  IY, //-- 2 < x,y < 30     
   input wire        IVALID,
   output wire [7:0] OIMG[24:0], //-- 5 x 5 pixels.
   output wire       OVALID,
   output wire [4:0] OX,
   output wire [4:0] OY,
   input wire        IRST,
   input wire        ICLK
);
   wire [9:0]       pos_x = {5'b0, IX};
   wire [9:0]       pos_y = {5'b0, IY};
   wire [9:0]       s_start_px;
   reg [9:0]        r_start_px;


   //-- convert from the (x,y) coordinate to address.
   assign s_start_px = (pos_y << 5) + pos_x; // 32 * IY + IX
   always_ff @(posedge ICLK) begin
      if (IVALID) begin
         r_start_px <= s_start_px;
      end
   end
   
   assign OIMG = IIMG;

   reg [1:0]      r_valid;
   always_ff @ (posedge ICLK) begin
      if (IRST)   r_valid <= 2'b0;
      else        r_valid <= {r_valid[0], IVALID};
   end
   assign OVALID = r_valid[1];

   reg [4:0] r_x [1:0];
   reg [4:0] r_y [1:0];
   always_ff @ (posedge ICLK) begin
      if (IRST) begin
         {r_x[1], r_x[0]} <= {5'h1F, 5'h1F};
         {r_y[1], r_y[0]} <= {5'h1F, 5'h1F};
      end else begin
         {r_x[1], r_x[0]} <= {r_x[0], IX};
         {r_y[1], r_y[0]} <= {r_y[0], IY};
      end
   end
   assign OX = r_x[1];
   assign OY = r_y[1];
endmodule // KNL_WINDOW




