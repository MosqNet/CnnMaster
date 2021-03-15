`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 15:46:43
// Design Name: 
// Module Name: FULL1_TOP
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


module FULL2_TOP(
    input wire IINIT,
    input wire FULL2_START,
    input wire signed [31:0]  ID[119:0],
    input wire [31:0]  FULL2_BIAS_ID,
    input wire [1023:0] IPARAMS,
    output wire [7:0] OPARAMS_ADDR,
    output wire OINIT,
    //--
    output wire signed [41:0] ofull2_core,
    //-- system.
    input wire IRST,
    input wire ICLK 
    );
    
    wire full2_core_valid;
    
//    assign  ID00 = ID[0];
    
//    genvar id_i;
//    generate
//    for (id_i=0;id_i<=119;id_i=id_i+1)begin
     FULL2_CORE full2_core(
        .IPIX     (ID),        //[7:0][0:24] <-- "knl_window"
        .IWEIGHT  (IPARAMS),               //[255:0] <-- "knl_params"
        .IBIAS    (FULL2_BIAS_ID),
        .OPIX_FULL(ofull2_core), 
        .OVALID   (full2_core_valid),
        //.OWADDR   (),
        //--system
        .IRST     (IRST), 
        .ICLK     (ICLK)
    );
//    end
//    endgenerate
    

    
                    
    FULL2_CTRL full2_ctrl(
        //-- Main controls.
        .IINIT    (IINIT),
        .ISTART   (FULL2_START),   //--> rising edge detect.
        //-- "img_cutter"
        .OINIT    (OINIT),    //--> "img_cutter"
//        .OEN      (),      //--> "img_cutter"
//        .ILAST    (),    //<-- "img_cutter"                
        .OPARAM_ADDR (OPARAMS_ADDR), //--> "conv1_params"
        //-- Info
//        .OST    (ctrl_st),    //[2:0]--> current operating unit index.
        //-- System
        .IRST   (IRST),
        .ICLK   (ICLK)
    );
    
    
endmodule

