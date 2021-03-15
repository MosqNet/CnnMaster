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

module POOL2 #(
    parameter POOL2_WIDTH = 5,
    parameter POOL2_SIZE = POOL2_WIDTH * POOL2_WIDTH     
)
(
    input wire          IINIT,
    input wire          ISTART,

    input wire signed [24:0]   ID [15:0],
    input wire [7:0]    IPOOL_XY,
    input               IPOOL_EN,

    output wire         OVALID,
    
    output wire  signed [24:0] POOL2_RESULT [15:0][POOL2_SIZE-1:0],

    input wire          IRST,
    input wire          ICLK
    );

    reg signed [24:0] r_pool2_result [15:0][POOL2_SIZE-1:0];
    wire signed [24:0] pool_result [15:0];
    genvar g;
    generate
    for (g=0;g<16;g=g+1)begin
        L2_POOLING l2_pooling(
            .ID     (ID[g]),
            .OD     (pool_result[g]),
            .IRST   (IRST),
            .ICLK   (ICLK)
        );
    end
    endgenerate
    
    //reg [31:0] r_pool_result[15:0][POOL2_SIZE-1:0];

    reg [7:0] XY;
    always_ff @(posedge ICLK)begin
        XY <= IPOOL_XY;
    end
    reg pool_en;
    always_ff @(posedge ICLK)begin
        pool_en <= IPOOL_EN;
    end

    genvar result;
    generate
    for (result=0;result<16;result=result+1)begin
        always_ff @(posedge ICLK)begin
            if (pool_en) r_pool2_result[result][XY] <= pool_result[result];
        end
    end
    endgenerate
    
    assign POOL2_RESULT = r_pool2_result;

           /* ------ simulation ------ */
 
 `ifdef SIM_FLAG
 
 real r_ID[15:0];
 real r_OD[15:0];
 real r_POOL_DATA [15:0][3:0];
 real r_POOL_SUM[15:0];
 real r_POOL2_RESULT[15:0][24:0];
 real exp_POOL2_RESULT[15:0];
     
 integer r_PD_i;
 
 always_ff @(posedge ICLK) begin
     if (TOP.R_Arbiter.udp2cnn.LENET.layer2.conv2_result_addr==1) r_PD_i <= 0;
     else if (r_PD_i==3) r_PD_i <= 0; 
     else r_PD_i <= r_PD_i + 1;
 end

 genvar u_id ,pr_id;
 generate
 
 for(u_id=0;u_id<16;u_id=u_id+1)begin
     for(pr_id=0; pr_id<25; pr_id=pr_id+1)begin
     
         always_comb begin
             if (TOP.R_Arbiter.udp2cnn.LENET.layer1.conv1_result_addr==0) r_POOL_DATA[u_id] <= {0,0,0,0};
             else r_POOL_DATA[u_id][r_PD_i] <= $itor(ID[u_id])/16384.0;
         end
         
         always_ff @(posedge ICLK) begin
             if (r_PD_i==3)
                 exp_POOL2_RESULT[u_id] = $itor(r_POOL_SUM[u_id]/4);
         end
         
         assign r_ID[u_id] = $itor(ID[u_id]) / 16384.0;

         assign r_POOL2_RESULT[u_id][pr_id] = $itor(POOL2_RESULT[u_id][pr_id]) / 65536.0;
                             
         assign r_POOL_SUM[u_id] = r_POOL_DATA[u_id][0]+r_POOL_DATA[u_id][1]+ 
                                   r_POOL_DATA[u_id][2]+r_POOL_DATA[u_id][3];
                                    
     end
 end
  
 endgenerate
 `endif

endmodule // POOL2