`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 19:58:20
// Design Name: 
// Module Name: OUT_TOP
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


module OUT_TOP(
    input wire IINIT,
    input wire OUT_START,
    input wire signed [41:0]  ID[83:0],
    input wire [31:0]  OUT_BIAS_ID,
    input wire [1023:0] IPARAMS,
    output wire [7:0] OPARAMS_ADDR,
    output wire OINIT,
    output wire OUT_CMP,
    //--
    //output wire [31:0] OFULL1[119:0],
    output wire signed  [63:0] OUT_CORE,
    //-- system.
    input wire IRST,
    input wire ICLK 
);

    wire out_core_valid;

//    genvar id_i;
//    generate
//    for (id_i=0;id_i<=83;id_i=id_i+1)begin
    OUT_CORE OUT_core(
        .IPIX     (ID),        //[7:0][0:24] <-- "knl_window"
        .IWEIGHT  (IPARAMS),               //[255:0] <-- "knl_params"
        .IBIAS    (OUT_BIAS_ID),
        .OPIX_FULL(OUT_CORE), 
        .OVALID   (out_core_valid),
        //.OWADDR   (),
        .IRST     (IRST), 
        .ICLK     (ICLK)
    );
//    end
//    endgenerate
    
    OUT_CTRL out_ctrl(
        //-- Main controls.
        .IINIT    (IINIT),
        .ISTART   (OUT_START),   //--> rising edge detect.
        //-- "img_cutter"
        .OINIT    (OINIT),    //--> "img_cutter"
        //        .OEN      (),      //--> "img_cutter"
        //        .ILAST    (),    //<-- "img_cutter"                
        .OPARAM_ADDR (OPARAMS_ADDR), //--> "conv1_params"
        //-- Info
        //        .OST    (ctrl_st),    //[2:0]--> current operating unit index.
        .OUT_CMP (OUT_CMP),
        //-- System
        .IRST   (IRST),
        .ICLK   (ICLK)
    );

endmodule
