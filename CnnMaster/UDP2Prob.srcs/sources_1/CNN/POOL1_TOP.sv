//                              -*- Mode: Verilog -*-
// Filename        : POOL1_TOP.sv
// Description     : 
// Author          : 
// Created On      : Wed Nov 11 16:08:00 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 16:12:54
// Update Count    : 0
// Status          : Unknown, Use with caution!

module POOL1_TOP #(
    parameter POOL1_IIMG_SIZE = 784,
    parameter POOL1_WIDTH = 14,
    parameter POOL1_SIZE = POOL1_WIDTH * POOL1_WIDTH 
)
(
    //-- System commons
    input wire         ICLK,
    input wire         IRST,
    //-- Input
    input wire         IINIT,
    input wire         ISTART,
    input wire         CONV2_START,
    input wire         CONV2_CMP,
    input wire         IVALID,
    input wire signed [12:0] ID [5:0],
    //-- Output
    output wire        OEND,
    output wire        OVALID,
    output wire [9:0]  ORADDR,
    output wire L1LED_o,
    output wire signed [14:0] POOL1_RESULT [5:0][POOL1_SIZE-1:0]
   );
   
   wire  [7:0] pool_xy;
   wire        pool_en;
   
   POOL1_CTRL #(
       .POOL1_IIMG_SIZE   (
       ),
       .POOL1_WIDTH       (POOL1_WIDTH),
       .POOL1_SIZE        (POOL1_SIZE)
   ) pool1_ctrl (
      .ISTART     (ISTART),
      .OPOOL_XY   (pool_xy), //[7:0]
      .OPOOL_EN   (pool_en),
      .ORADDR     (ORADDR),
      .OEND       (OEND),
      .L1LED_o  (L1LED_o),
      .IRST       (IRST),
      .ICLK       (ICLK)
   );

   POOL1 #(
       .POOL1_WIDTH       (POOL1_WIDTH),
       .POOL1_SIZE        (POOL1_SIZE)
   ) pool1 (
      .ID         (ID),
      .IPOOL_XY   (pool_xy),
      .IPOOL_EN   (pool_en),
      .POOL1_RESULT (POOL1_RESULT),
      .IRST       (IRST),
      .ICLK       (ICLK)
   );


endmodule // POOL1_TOP