`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 18:36:00
// Design Name: 
// Module Name: FULL1_RELU
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
  
module FULL1_RELU(
//-- System commons
input wire IRST,
input wire ICLK,
//-- Input
input   wire signed [31:0] IFULL1,
input   wire        IVALID,
input   wire        IINIT,
//-- Output
output wire L3LED_o,
output wire PMOD_B1,
output wire PMOD_B2,
output wire FULL1_CMP,
output wire signed [31:0]  FULL1_RESULT[0:119]
//output  reg         OVALID
);//------------------------------------------------------
   (*dont_touch="true"*) reg full1_cmp;
   
    assign PMOD_B1 = IINIT;
    assign PMOD_B2 = full1_cmp;
    
    (*dont_touch="true"*) reg [6:0]  cnt120;
    
    wire s_sign_bit = IFULL1[31];
    
    wire [31:0] s_relu = (s_sign_bit)? 32'd0 : IFULL1;

//    always_ff @ (posedge ICLK) begin
//       if(IRST) OVALID <= 1'b0;
//       else     OVALID <= IVALID;
//    end
    
    always_ff @ (posedge ICLK) begin
        if(IRST)
            cnt120 <= 0;
        else if(IINIT)
            cnt120 <= cnt120+1;
        else
            cnt120 <= 0;
    end
    

    
    reg signed [31:0] r_full1_result [0:119];
    
    always_ff @ (posedge ICLK)begin
        if(IINIT)
            r_full1_result[cnt120] <= s_relu;
    end
    
    assign FULL1_RESULT = r_full1_result;
    
    always_ff @(posedge ICLK) begin
        if(cnt120==119) full1_cmp <= 1;
        else full1_cmp <= 0;
    end
    
    assign FULL1_CMP = full1_cmp;
    
    (*dont_touch="true"*) reg r_led;
    
    always_ff @(posedge ICLK) begin
    if (IRST)  r_led <= 1'b0;
    else if(full1_cmp) r_led <= ~IINIT; 
    end

    assign L3LED_o = r_led;
    
    
     /* ------ simulation ------- */
    `ifdef SIM_FLAG
    
    real r_IFULL; 
    real r_FULL1_RESULT [0:119]; 
    real exp_FULL1_RESULT;
        
    genvar sim;
    generate
        for (sim=0; sim<120; sim=sim+1)begin
            assign r_FULL1_RESULT[sim]  = $itor(FULL1_RESULT[sim])    / 4194304.0;
        end
    endgenerate
        
    always_comb begin
        r_IFULL = $itor(IFULL1) / 4194304.0;
        //assign exp_FULL1_RESULT   = (!r_IFULL) ?  0 :  $itor(r_IFULL) / 4194304.0;
    end    
    
    `endif
    
endmodule