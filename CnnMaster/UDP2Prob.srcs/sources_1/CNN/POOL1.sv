`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/17 16:46:41
// Design Name: 
// Module Name: POOL1
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

module POOL1 #(
    parameter POOL1_WIDTH = 14,
    parameter POOL1_SIZE = POOL1_WIDTH * POOL1_WIDTH     
)
(
   //--System Commons
   input wire          IRST,
   input wire          ICLK,
   //-- Input
    input wire          IINIT,
    input wire          ISTART,
    input wire signed [12:0] ID [5:0],
    input wire [7:0]   IPOOL_XY,
    input wire IPOOL_EN,
   //-- Output
    output wire signed [14:0] POOL1_RESULT [5:0][POOL1_SIZE-1:0]
);

    reg signed [14:0] r_pool1_result [5:0][POOL1_SIZE-1:0];
    wire signed [14:0] pool_result [5:0];
    
    genvar pi; //pooling index
    generate
    for (pi=0;pi<6;pi=pi+1)begin
        L1_POOLING l1_pooling(
            .ID     (ID[pi]),
            .OD     (pool_result[pi]),
            .IRST   (IRST),
            .ICLK   (ICLK)
        );
    end
    endgenerate

    wire [7:0] XY = IPOOL_XY;
    genvar result;
    integer i;
    generate
    for (result=0;result<6;result=result+1)begin
        always_ff @(posedge ICLK)begin
            //if (IPOOL_EN) POOL1_RESULT[result][XY] <= pool_result[result];
            // recude  LUT ?
            if (IPOOL_EN) begin
                 r_pool1_result[result][195] <= pool_result[result];
                 for(i=1;i<=195;i=i+1) begin
                       r_pool1_result[result][i-1] <= r_pool1_result[result][i] ;
                 end
            end 
        end
    end
    endgenerate
    
    assign POOL1_RESULT = r_pool1_result;
    
       /* ------ simulation ------ */
    
    `ifdef SIM_FLAG
    
    real r_ID[5:0];
    real r_OD[5:0];
    real r_POOL_DATA [5:0][3:0];
    real r_POOL_SUM[5:0];
    real r_POOL1_RESULT[5:0][0:195];
    real exp_POOL1_RESULT[5:0];
        
    integer r_PD_i;
    
    always_ff @(posedge ICLK) begin
        if (TOP.R_Arbiter.udp2cnn.LENET.layer1.conv1_result_addr==1) r_PD_i <= 0;
        else if (r_PD_i==3) r_PD_i <= 0; 
        else r_PD_i <= r_PD_i + 1;
    end
 
    genvar u_id ,pr_id;
    generate
    
    for(u_id=0;u_id<6;u_id=u_id+1)begin
        for(pr_id=0; pr_id<196; pr_id=pr_id+1)begin

            always_comb begin
                if (TOP.R_Arbiter.udp2cnn.LENET.layer1.conv1_result_addr==0) r_POOL_DATA[u_id] <= {0,0,0,0};
                else r_POOL_DATA[u_id][r_PD_i] <= $itor(ID[u_id])/64.0;
            end
            
            always_ff @(posedge ICLK) begin
                if (r_PD_i==3)
                    exp_POOL1_RESULT[u_id] = $itor(r_POOL_SUM[u_id]/4);
            end
            
            assign r_ID[u_id] = $itor(ID[u_id]) / 64.0;

            //assign r_OD[u_id] = (floatp_valid[u_id]) ? $itor(pool_result[u_id]) / 256.0 : $itor(pool_result[u_id]) / 64.0;

            assign r_POOL1_RESULT[u_id][pr_id] = $itor(POOL1_RESULT[u_id][pr_id]) / 256.0;
                                
            assign r_POOL_SUM[u_id] = r_POOL_DATA[u_id][0]+r_POOL_DATA[u_id][1]+ 
                                      r_POOL_DATA[u_id][2]+r_POOL_DATA[u_id][3];
                                 
        end
    end
     
    endgenerate
    `endif

endmodule // POOL1