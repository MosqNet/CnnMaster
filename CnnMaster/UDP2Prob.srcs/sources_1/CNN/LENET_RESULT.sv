`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 20:19:04
// Design Name: 
// Module Name: LENET_RESULT
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

module LENET_RESULT(
    input   wire signed [63:0] ID,
    input   wire        IVALID,
    input   wire        IINIT,
    output wire  signed [63:0] LENET_RESULT[0:9],
    output wire        OVALID,
    output wire PMOD_C0,
    output wire PMOD_C1,
    input   wire        IRST,
    input   wire        ICLK    
);

    reg [63:0] R_OUT_ID;
    reg [3:0] cnt10;
    
    always_ff @ (posedge ICLK) begin
        if(IRST)
            cnt10 <= 0;
        else if(IINIT)
            cnt10 <= cnt10+1;
        else
            cnt10 <= 0;
    end
    
    reg signed [63:0] r_lenet_result[0:9];
    
    always_ff @ (posedge ICLK)begin
        if(IINIT)
            r_lenet_result[cnt10] <= ID;
    end
    
    assign LENET_RESULT = r_lenet_result;
    
    assign PMOD_C0 = IINIT;
    
    /* ------ simulation ------- */
    `ifdef SIM_FLAG
    
    real r_IFULL; 
    real r_LENET_RESULT [0:9]; 
    real exp_FULL2_RESULT;
        
    genvar sim;
    generate
        for (sim=0; sim<10; sim=sim+1)begin
            assign r_LENET_RESULT[sim]  = $itor(LENET_RESULT[sim]) / 17179869184.0;
        end
    endgenerate
        
    always_comb begin
        assign r_IFULL = $itor(ID) / 17179869184.0; ;
        //assign exp_FULL1_RESULT   = (!r_IFULL) ?  0 :  $itor(r_IFULL) / 4194304.0;
    end    
    
    `endif
    
endmodule
