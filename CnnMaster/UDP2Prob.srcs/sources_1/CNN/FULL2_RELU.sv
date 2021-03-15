`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 16:53:28
// Design Name: 
// Module Name: FULL2_RELU
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


module FULL2_RELU(
//-- System commons
input wire IRST,
input wire ICLK,
//-- Input 
input   wire signed [41:0] IFULL2,
input   wire        IVALID,
input   wire        IINIT,
//-- Output
output wire L4LED_o,
output wire PMOD_B4,
output wire PMOD_B5,
output wire FULL2_CMP,
output wire signed [41:0]  FULL2_RESULT[0:83]
//output  reg         OVALID
);

    reg [6:0]  cnt84;

    wire s_sign_bit = IFULL2[41];
    wire [41:0] s_relu = (s_sign_bit)? 41'd0 : IFULL2;
    
//    always_ff @(posedge ICLK)begin
//        O_RELU <= s_relu;
//    end
    
//    always_ff @ (posedge ICLK) begin
//       if(IRST) OVALID <= 1'b0;
//       else     OVALID <= IVALID;
//    end
    
    always_ff @ (posedge ICLK) begin
        if(IRST)
            cnt84 <= 0;
        else if(IINIT)
            cnt84 <= cnt84+1;
        else
            cnt84 <= 0;
    end
    
    reg signed [41:0] r_full2_result [0:83];
    
    always_ff @ (posedge ICLK)begin
        if(IINIT)
            r_full2_result[cnt84] <= s_relu;
    end
    
    assign FULL2_RESULT = r_full2_result;
    
    reg full2_cmp;
    
    always_ff @(posedge ICLK) begin
        if(cnt84==83) full2_cmp <= 1;
        else full2_cmp <= 0;
    end
    
    assign FULL2_CMP = full2_cmp;
    
    reg r_led;
    
    always_ff @(posedge ICLK) begin
    if(IRST) r_led <= 1'b0;
    else if(full2_cmp) r_led <= ~IINIT; 
    end

    assign L4LED_o = r_led;
    
    assign PMOD_B4 = IINIT;
    assign PMOD_B5 = full2_cmp;
    
    
   /* ------ simulation ------- */
   `ifdef SIM_FLAG
   
   real r_IFULL; 
   real r_FULL2_RESULT [0:83]; 
   real exp_FULL2_RESULT;
       
   genvar sim;
   generate
       for (sim=0; sim<84; sim=sim+1)begin
           assign r_FULL2_RESULT[sim]  = $itor(FULL2_RESULT[sim])    / 268435456.0;
       end
   endgenerate
       
   always_comb begin
       assign r_IFULL = $itor(IFULL2) / 268435456.0;
       //assign exp_FULL1_RESULT   = (!r_IFULL) ?  0 :  $itor(r_IFULL) / 4194304.0;
   end    
   
   `endif

endmodule
