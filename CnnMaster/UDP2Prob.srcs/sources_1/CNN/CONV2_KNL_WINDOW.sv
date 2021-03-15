`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/18 20:15:33
// Design Name: 
// Module Name: CONV2_KNL_WINDOW
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

module CONV2_KNL_WINDOW(
   input wire signed [14:0] IIMG [195:0],
   input wire [4:0]  IX, //-- coordinate(x,y),
   input wire [4:0]  IY, //-- 2 < x,y < 30     
   input wire        IVALID,
   output wire signed [14:0] OIMG [24:0], //-- 5 x 5 pixels.
   output wire       OVALID,
   output wire [4:0] OX,
   output wire [4:0] OY,
   input wire        IRST,
   input wire        ICLK
);
   wire [9:0]       pos_x = {5'b0, IX};
   wire [9:0]       pos_y = {5'b0, IY};
   wire [9:0]       s_start_px;
   reg  [9:0]       r_start_px;
   reg  signed [14:0] KIMG [24:0]; // 


   //-- convert from the (x,y) coordinate to address.
   assign s_start_px = (pos_y << 3) + (pos_y << 2) + (pos_y << 1) + pos_x; // 14 * IY + IX
   always_ff @(posedge ICLK) begin
      if (IVALID) begin
         r_start_px <= s_start_px;
      end
   end
   
   always_ff @(posedge ICLK) begin
      //-- 1st line
      KIMG[0] <= IIMG[r_start_px]; 
      KIMG[1] <= IIMG[r_start_px + 1];
      KIMG[2] <= IIMG[r_start_px + 2];
      KIMG[3] <= IIMG[r_start_px + 3];
      KIMG[4] <= IIMG[r_start_px + 4];
      //-- 2nd line
      KIMG[5] <= IIMG[r_start_px + 14];
      KIMG[6] <= IIMG[r_start_px + 15];
      KIMG[7] <= IIMG[r_start_px + 16];
      KIMG[8] <= IIMG[r_start_px + 17];
      KIMG[9] <= IIMG[r_start_px + 18];
      //-- 3rd line
      KIMG[10] <= IIMG[r_start_px + 28];
      KIMG[11] <= IIMG[r_start_px + 29];
      KIMG[12] <= IIMG[r_start_px + 30];
      KIMG[13] <= IIMG[r_start_px + 31];
      KIMG[14] <= IIMG[r_start_px + 32];
      //-- 4th line
      KIMG[15] <= IIMG[r_start_px + 42];
      KIMG[16] <= IIMG[r_start_px + 43];
      KIMG[17] <= IIMG[r_start_px + 44];
      KIMG[18] <= IIMG[r_start_px + 45];
      KIMG[19] <= IIMG[r_start_px + 46];
      //-- 5th line
      KIMG[20] <= IIMG[r_start_px + 56];
      KIMG[21] <= IIMG[r_start_px + 57];
      KIMG[22] <= IIMG[r_start_px + 58];
      KIMG[23] <= IIMG[r_start_px + 59];
      KIMG[24] <= IIMG[r_start_px + 60];
   end // always_ff @
   
    assign OIMG = KIMG;

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
   
 /* ------ simulation ------ */

//`ifdef SIM_FLAG
    
//`endif

endmodule // KNL_WINDOW
