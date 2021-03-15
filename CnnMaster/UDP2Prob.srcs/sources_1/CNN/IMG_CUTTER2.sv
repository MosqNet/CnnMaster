//                              -*- Mode: Verilog -*-
// Filename        : IMG_CUTTER.sv
// Description     : 
// Author          : 
// Created On      : Sun Nov  8 19:52:51 2020
// Last Modified By: 
// Last Modified On: 2020-11-10 12:07:16
// Update Count    : 0
// Status          : Unknown, Use with caution!

module IMG_CUTTER2 (
   input wire       IINIT, //-- Initialize OX and OY to zeros.
   input wire       IEN, //-- Increment OX and/or OY.
   output wire [4:0] OX, //-- coordinate(x,y),
   output wire [4:0] OY, //-- 2 < x,y < 30     
   output wire       OVALID,
   output wire       OCR, //-- Asserted the end of a X line.
   output wire       OLAST, //-- Asserted the end of X-Y window.
   input wire       IRST,
   input wire       ICLK
   );
   localparam [4:0] INIT_X = 5'd13;
   localparam [4:0] INIT_Y = 5'd13;
   localparam [4:0] MAX_X = 5'd9; // 32 - 5 pixel
   localparam [4:0] MAX_Y = 5'd9; // 
   
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
   
   reg [4:0] r_ox;
   reg [4:0] r_oy;
   
   always_ff @ (posedge ICLK) begin
      if (IRST)       r_ox <= INIT_X;
      else if (IINIT) r_ox <= INIT_X;
      else if (IEN)   r_ox <= s_OX;
   end
   
    assign OX = r_ox;

    
   /*
    * Output OY[]
    */
   wire       OY_is_MAX = (OY >= MAX_Y);
   wire [4:0] s_OY = (!OX_is_MAX)? OY :
                     (!OY_is_MAX)? (OY + 5'd1) : 5'd0;

   always_ff @ (posedge ICLK) begin
      if (IRST)       r_oy  <= INIT_Y;
      else if (IINIT) r_oy <= INIT_Y;
      else if (IEN)   r_oy <= s_OY;
   end
   
       assign OY = r_oy;
   /*
    * OCR
    */
    
    reg r_ocr;
    
   wire s_OCR = (s_OX == MAX_X);
   always_ff @ (posedge ICLK) begin
      if (IRST)     r_ocr <= 1'b0;
      else if (IEN) r_ocr <= s_OCR;
   end
   
   assign OCR = r_ocr;
   
   /*
    * OLAST
    */
    
    reg r_olast;
    
   wire s_OLAST = s_OCR & (s_OY == MAX_Y);
   always_ff @ (posedge ICLK) begin
      if (IRST)     r_olast <= 1'b0;
      else if (IEN) r_olast <= s_OLAST;
   end
   
   assign OLAST = r_olast;
   
   /*
    * OVALID
    */
    
    reg r_ovalid;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_ovalid <= 1'b0;
      else      r_ovalid <= IEN;
   end
   
   assign OVALID = r_ovalid;
   
endmodule // IMG_CUTTER
