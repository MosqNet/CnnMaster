//                              -*- Mode: Verilog -*-
// Filename        : POOL1_TOP.sv
// Description     : 
// Author          : 
// Created On      : Wed Nov 11 16:08:00 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 16:12:54
// Update Count    : 0
// Status          : Unknown, Use with caution!

module POOL2_TOP #(
    parameter POOL2_IIMG_SIZE = 100,
    parameter POOL2_WIDTH = 5,
    parameter POOL2_SIZE = POOL2_WIDTH * POOL2_WIDTH 
)
(
    input wire         ISTART,
    output wire       OEND,

    input wire signed [24:0]  ID [15:0],
    output wire [6:0]  ORADDR,
   
   output wire L2LED_o,
   output wire signed [24:0] POOL2_RESULT [15:0][POOL2_SIZE-1:0],

    input wire         IRST,
    input wire         ICLK
    );

    wire  [7:0] pool_xy;
    wire        pool_en;
    POOL2_CTRL #(
        .POOL2_IIMG_SIZE   (POOL2_IIMG_SIZE),
        .POOL2_WIDTH       (POOL2_WIDTH),
        .POOL2_SIZE        (POOL2_SIZE)
    ) pool2_ctrl (
       .ISTART     (ISTART),
       .OPOOL_XY   (pool_xy), //[7:0]
       .OPOOL_EN   (pool_en),
       .ORADDR     (ORADDR),
       .L2LED_o(L2LED_o),
       .OEND       (OEND),
       .IRST       (IRST),
       .ICLK       (ICLK)
    );

    POOL2 #(
        .POOL2_WIDTH       (POOL2_WIDTH),
        .POOL2_SIZE        (POOL2_SIZE)
    ) pool2 (
       .ID         (ID),
       .IPOOL_XY   (pool_xy),
       .IPOOL_EN   (pool_en),
       .POOL2_RESULT (POOL2_RESULT),
       .IRST       (IRST),
       .ICLK       (ICLK)
    );

endmodule // POOL2_TOP
