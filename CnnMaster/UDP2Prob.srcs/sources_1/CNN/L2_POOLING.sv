`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/13 02:21:44
// Design Name: 
// Module Name: L1_POOLING
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

module L2_POOLING(
    input   wire signed [24:0]  ID,
    output  wire signed [24:0]  OD,
    input   wire            IRST,
    input   wire            ICLK
);

    /*---reg/wire---*/
    reg signed [24:0] pool_data [3:0];
    
    always_ff @(posedge ICLK)begin
        if (IRST)   pool_data <= {25'b0,25'b0,25'b0,25'b0};
        else        pool_data <= {ID, pool_data[3], pool_data[2], pool_data[1]};
    end

    //wire [33:0] pool_sum = pool_data[0] + pool_data[1] + pool_data[2] + pool_data[3];
//    wire signed [24:0] pool_sum = pool_data[0] + pool_data[1] + pool_data[2] + pool_data[3];
    reg [24:0] pool_sum;
    always_ff @(posedge ICLK)begin
        pool_sum <= pool_data[0] + pool_data[1] + pool_data[2] + pool_data[3];
    end
    //wire erorr_valid = pool_sum[0] | pool_sum[1];
    
//    assign OD = (floatp_valid) ? pool_sum : pool_sum >>> 2;
    
    assign OD = pool_sum;


//    /* ------ simulation ------ */
    
//    `ifdef SIM_FLAG
    
//    real r_pool_data0,r_pool_data1,r_pool_data2,r_pool_data3;
//    real r_pool_sum;
//    real r_OD;
    
//    assign r_pool_data0 = $itor(ID)/64.0;
//    assign r_pool_data1 = $itor(pool_data[3])/64.0;
//    assign r_pool_data2 = $itor(pool_data[2])/64.0;
//    assign r_pool_data3 = $itor(pool_data[1])/64.0;
    
//    assign r_pool_sum  = $itor(pool_sum)/64.0;
//    //assign r_OD        = (floatp_valid) ? $itor(OD)/256.0 : $itor(OD)/64.0;
//    assign r_OD = $itor(OD)/256.0;

//    `endif
    
endmodule