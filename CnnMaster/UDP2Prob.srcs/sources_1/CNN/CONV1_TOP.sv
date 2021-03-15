//                              -*- Mode: Verilog -*-
// Filename        : CONV1_TOP.sv
// Description     :
// Author          : 
// Created On      : Wed Nov 11 15:18:06 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 19:02:04
// Update Count    : 0
// Status          : Unknown, Use with caution!

module CONV1_TOP (
    //-- System commons
    input wire IRST,
    input wire ICLK,
    //-- Input
    input wire IINIT,
    input wire ISTART,
    input wire [255:0] IPARAMS,
    //input wire [7:0]   IIMG[0:24],
    //input wire IIMG [0:24],
    input wire [1023:0] IIMG,
//  input wire           IIMG_VALID,
//  input wire [4:0]   IIMG_X,  //-- left-uuper position of x.
//  input wire [4:0]   IIMG_Y,  //-- left-uuper position of y.
    //-- Output
    output wire CONV1_START,
    output wire CONV1_CMP,
    output wire OVALID,
    output wire [3:0]  OPARAMS_ADDR,
    output wire [4:0]  OX,
    output wire [4:0]  OY,
    output wire signed [12:0] OCONV1
   );

   /*
    * Select the specified 5x5 pixels from input 32x32 image.
    */
    
    wire [4:0] px_data_x;
    wire [4:0] px_data_y;
    wire [24:0] knl_window;
    wire knl_window_valid;
    
    IMG_CUTTER1 img_cutter1(
        //--System Commons
        .IRST (IRST),
        .ICLK (ICLK),
        //-- Input
        .conv1_st (CONV1_START),
        .s_img(IIMG),
        //-- Output
        .px_data_x (px_data_x),
        .px_data_y (px_data_y),
        .opx_data_valid(knl_window_valid),
        .opx_data (knl_window)
    );
    
    wire xy_last;
    
   CONV1_CORE conv1_core (
      .IPIX     (knl_window),        //[7:0][0:24] <-- "knl_window"
      .IKNL   (IPARAMS),               //[255:0] <-- "knl_params"
      .IX        (px_data_x),
      .IY        (px_data_y),
      .IVALID   (knl_window_valid),    // <-- "knl_window"
      .OPIX_CONV(OCONV1), 
      .OVALID   (OVALID),
      .OX       (OX),
      .OY       (OY),
      .OXY_LAST (xy_last),
      .IRST     (IRST), 
      .ICLK     (ICLK)
   );

   /*
    * Arbiter for 1st convolutions.
    */
   wire [3:0]       ctrl_st;  //-- FSM
   wire [31:0]      conv1_params_wea; //byte write enable.
   
    CONV1_CTRL ctrl (
    //-- System
    .ICLK   (ICLK),
    .IRST   (IRST),
    //-- Input
    .IINIT    (IINIT),
    .ISTART   (ISTART),   //--> rising edge detect.
    .ILAST    (xy_last),    //<-- 
    //-- Output
    .CONV1_CMP (CONV1_CMP),
    .OINIT    (CONV1_START),    //--> "img_cutter"
    .OPARAM_ADDR (OPARAMS_ADDR), //--> "conv1_params"
    .OST    (ctrl_st)    //[2:0]--> current operating unit index.
    );

endmodule // CONV1_TOP

