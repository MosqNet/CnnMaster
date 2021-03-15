//                              -*- Mode: Verilog -*-
// Filename        : IMG_CUTTER.sv
// Description     : 
// Author          : 
// Created On      : Sun Nov  8 19:52:51 2020
// Last Modified By: 
// Last Modified On: 2020-11-10 12:07:16
// Update Count    : 0
// Status          : Unknown, Use with caution!

module IMG_CUTTER (
   input wire       IINIT, //-- Initialize OX and OY to zeros.
   input wire       IEN, //-- Increment OX and/or OY.
   output reg [4:0] OX, //-- coordinate(x,y),
   output reg [4:0] OY, //-- 2 < x,y < 30     
   output reg       OVALID,
   output reg       OCR, //-- Asserted the end of a X line.
   output reg       OLAST, //-- Asserted the end of X-Y window.
   input wire       IRST,
   input wire       ICLK
   );
   localparam [4:0] INIT_X = 5'd31;
   localparam [4:0] INIT_Y = 5'd31;
   localparam [4:0] MAX_X = 5'd27; // 32 - 5 pixel
   localparam [4:0] MAX_Y = 5'd27; // 
   
   // (X,Y)=
   // ( 0, 0) -> ( 1, 0) -> ( 2, 0) -> ( 3, 0) ->...-> (27, 0) ->
   // ( 0, 1) -> ( 1, 1) -> ( 2, 1) -> ( 3, 1) ->...-> (27, 1) ->
   // ( 0, 2) -> ( 1, 2) -> ( 3, 2) -> ( 3, 2) ->...-> (27, 2) ->
   // ...
   // ( 0,27) -> ( 1,27) -> ( 2,27) -> ( 3,27) ->...-> (27,27).

   /*
    * Output OX[]
    */
   wire       OX_is_MAX = (OX >= MAX_X);
   wire [4:0] s_OX = (OX_is_MAX)? 5'd0 : (OX + 5'd1);
   always_ff @ (posedge ICLK) begin
      if (IRST)       OX <= INIT_X;
      else if (IINIT) OX <= INIT_X;
      else if (IEN)   OX <= s_OX;
   end
   /*
    * Output OY[]
    */
   wire       OY_is_MAX = (OY >= MAX_Y);
   wire [4:0] s_OY = (!OX_is_MAX)? OY :
                     (!OY_is_MAX)? (OY + 5'd1) : 5'd0;

   always_ff @ (posedge ICLK) begin
      if (IRST)       OY <= INIT_Y;
      else if (IINIT) OY <= INIT_Y;
      else if (IEN)   OY <= s_OY;
   end
   /*
    * OCR
    */
   wire s_OCR = (s_OX == MAX_X);
   always_ff @ (posedge ICLK) begin
      if (IRST)     OCR <= 1'b0;
      else if (IEN) OCR <= s_OCR;
   end
   /*
    * OLAST
    */
   wire s_OLAST = s_OCR & (s_OY == MAX_Y);
   always_ff @ (posedge ICLK) begin
      if (IRST)     OLAST <= 1'b0;
      else if (IEN) OLAST <= s_OLAST;
   end
   /*
    * OVALID
    */
   always_ff @ (posedge ICLK) begin
      if (IRST) OVALID <= 1'b0;
      else      OVALID <= IEN;
   end
endmodule // IMG_CUTTER

