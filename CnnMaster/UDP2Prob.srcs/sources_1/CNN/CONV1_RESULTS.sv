//                              -*- Mode: Verilog -*-
// Filename        : CONV1_RESULTS.sv
// Description     : 
// Author          : 
// Created On      : Wed Nov 11 14:45:26 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 15:05:06
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module CONV1_RESULTS (
    //-- System common
    input wire         IRST,
    input wire         ICLK,
    //-- Input
    input wire [5:0]   IWE,
    input wire [9:0]   IWADDR,
    input wire [9:0]   IRADDR,
    input wire signed  [12:0]  ID,
    //-- Output
    output wire signed [12:0] OD [5:0]
   );
   
    generate
        genvar ram_id;
        for(ram_id=0; ram_id < 6; ram_id = ram_id + 1)begin
        
        CONV1_RESULT conv1_ram(
        //-- Write side                        
        .dina     (ID),      // [31:0](one pixel)
        .addra    (IWADDR), // [9:0]
        .wea      (IWE[ram_id]),
        .clka     (ICLK),
        //-- Read side
        .addrb    (IRADDR),
        .doutb    (OD[ram_id]), // [31:0](one pixel) -->
        .clkb     (ICLK)
        );
            
      end
    endgenerate
    
    /* ------ simulation ------ */
    
//    `ifdef SIM_FLAG
//        real r_ID ;
//        real r_OD [783:0];
        
//        assign r_ID = $itor(ID) / 64.0;
        
//        genvar ram_i;
//        generate
//        for(ram_i=0;ram_i<784;ram_i=ram_i+1)begin
//            assign r_OD[ram_i] = $itor(OD[ram_i]) / 64.0;
//        end
//        endgenerate
        
//    `endif

endmodule // CONV1_RESULTS
