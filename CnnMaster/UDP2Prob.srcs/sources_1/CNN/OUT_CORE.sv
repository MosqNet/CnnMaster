`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 19:58:20
// Design Name: 
// Module Name: OUT_CORE
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

module OUT_CORE(
    input wire         ICLK,
    input wire         IRST,
    //-- Inputs
    input wire         IVALID,
    input wire signed [41:0]  IPIX[0:83], 
    input wire signed [1023:0] IWEIGHT,
    input wire signed [31:0]  IBIAS,
    //-- Outputs
    output wire signed [63:0]  OPIX_FULL, //-- Convoluted value 1 pixel.
    output wire        OVALID
    //output wire [11:0]  OWADDR    
);

    wire signed [63:0] mul[0:83];
    reg [2:0]          r_valid;
    
    wire signed [7:0] weight [0:83];
    wire signed [7:0] bias;
    wire signed [63:0] s_bias;
    
    genvar wi;
    generate
    for (wi=0;wi<84;wi=wi+1) begin
        assign weight[wi] = (IWEIGHT[1023-(wi*8)]) ? ~{1'b0,IWEIGHT[1022-(wi*8) : 1016-(wi*8)]}+1 : IWEIGHT[1023-(wi*8) : 1016-((wi*8))];
    end
    endgenerate
    
   /*
      * convert to 2's complement
      */
      assign bias = (IBIAS[31]) ? ~{1'b0,IBIAS[30:24]}+1 : IBIAS[31:24];
   
      assign s_bias = 64'(signed'(bias) <<< 28);
    
     /*
     * 84 Parallel multiplication
     */
     genvar i;
     generate
     for (i=0; i<84; i=i+1)begin
        OUT_MULT mult(.A(IPIX[i]), .B(weight[i]), .P(mul[i]), .CLK(ICLK));
     end
     
     endgenerate
     
     reg signed [63:0] r_smul;
     reg signed [63:0] s_mul [0:16];
     reg signed [63:0] s_mul0;
     reg signed [63:0] s_mul1;
     reg signed [63:0] s_mul2;
     reg signed [63:0] s_mul3;
     
     always_ff @(posedge ICLK) begin
             s_mul [0] <= mul[0]  + mul[1]  + mul[2]  + mul[3]  + mul[4];
             s_mul [1] <= mul[5]  + mul[6]  + mul[7]  + mul[8]  + mul[9];
             s_mul [2] <= mul[10] + mul[11] + mul[12] + mul[13] + mul[14];
             s_mul [3] <= mul[15] + mul[16] + mul[17] + mul[18] + mul[19];
             s_mul [4] <= mul[20] + mul[21] + mul[22] + mul[23] + mul[24];
             s_mul [5] <= mul[25] + mul[26] + mul[27] + mul[28] + mul[29];
             s_mul [6] <= mul[30] + mul[31] + mul[32] + mul[33] + mul[34];
             s_mul [7] <= mul[35] + mul[36] + mul[37] + mul[38] + mul[39];
             s_mul [8] <= mul[40] + mul[41] + mul[42] + mul[43] + mul[44];
             s_mul [9] <= mul[45] + mul[46] + mul[47] + mul[48] + mul[49];
             s_mul [10] <= mul[50] + mul[51] + mul[52] + mul[53] + mul[54]; 
             s_mul [11] <= mul[55] + mul[56] + mul[57] + mul[58] + mul[59];
             s_mul [12] <= mul[60] + mul[61] + mul[62] + mul[63] + mul[64];
             s_mul [13] <= mul[65] + mul[66] + mul[67] + mul[68] + mul[69];
             s_mul [14] <= mul[70] + mul[71] + mul[72] + mul[73] + mul[74];
             s_mul [15] <= mul[75] + mul[76] + mul[77] + mul[78] + mul[79];
             s_mul [16] <= mul[80] + mul[81] + mul[82] + mul[83];
     end
     
     always_ff @(posedge ICLK) begin
         s_mul0 <= s_mul[0]  + s_mul[1]  + s_mul[2]  + s_mul[3];                          
         s_mul1 <= s_mul[4] + s_mul[5]   + s_mul[6]  + s_mul[7];
         s_mul2 <= s_mul[8]  + s_mul[9]  + s_mul[10] + s_mul[11];
         s_mul3 <= s_mul[12] + s_mul[13] + s_mul[14] + s_mul[15] + s_mul[16];
     end 

   always_ff @(posedge ICLK) begin
      r_smul <= s_mul0 + s_mul1 + s_mul2 + s_mul3 + s_bias;
   end
   
   assign OPIX_FULL = r_smul;
     
     always_ff @ (posedge ICLK) begin
        if (IRST) r_valid <= 0;
        else      r_valid <= {r_valid[1:0], IVALID};
     end
     assign OVALID = r_valid[2];
     
     /*
      * TODO:  convert from IX, IY to RAM address.
      */
//     always @ (posedge ICLK) begin
//        OWADDR <= 12'h1234;
//     end
     
    `ifdef SIM_FLAG
         real r_OPIX_FULL, exp_OPIX_CONV, r_bias;
         real exp_MUL [0:83];
         real r_PIX [0:83];
         real r_WEIGHT [0:83];
         real r_MUL [0:83];
         genvar g;
         always_comb begin
             r_OPIX_FULL = $itor(OPIX_FULL) / 17179869184.0;
             r_bias      = $itor(bias)    / 64.0;
         end    
         generate
         for(g=0;g<84;g=g+1)begin
             assign r_PIX[g] = $itor(IPIX[g]) / 268435456.0;
             assign r_WEIGHT[g] = $itor(weight[g])   / 64.0;
             assign r_MUL[g] = $itor(mul[g]) / 17179869184.0;
             assign exp_MUL[g] = r_PIX[g] * r_WEIGHT[g];
         end
         endgenerate
         assign exp_OPIX_CONV = exp_MUL[0]  + exp_MUL[1]  + exp_MUL[2]  + exp_MUL[3]  + exp_MUL[4]  +
                                                      exp_MUL[5]  + exp_MUL[6]  + exp_MUL[7]  + exp_MUL[8]  + exp_MUL[9]  +
                                                      exp_MUL[10] + exp_MUL[11] + exp_MUL[12] + exp_MUL[13] + exp_MUL[14] +
                                                      exp_MUL[15] + exp_MUL[16] + exp_MUL[17] + exp_MUL[18] + exp_MUL[19] +
                                                      exp_MUL[20] + exp_MUL[21] + exp_MUL[22] + exp_MUL[23] + exp_MUL[24] +
                                                      exp_MUL[25] + exp_MUL[26] + exp_MUL[27] + exp_MUL[28] + exp_MUL[29] +
                                                      exp_MUL[30] + exp_MUL[31] + exp_MUL[32] + exp_MUL[33] + exp_MUL[34] +
                                                      exp_MUL[35] + exp_MUL[36] + exp_MUL[37] + exp_MUL[38] + exp_MUL[39] +
                                                      exp_MUL[40] + exp_MUL[41] + exp_MUL[42] + exp_MUL[43] + exp_MUL[44] +
                                                      exp_MUL[45] + exp_MUL[46] + exp_MUL[47] + exp_MUL[48] + exp_MUL[49] +
                                                      exp_MUL[50] + exp_MUL[51] + exp_MUL[52] + exp_MUL[53] + exp_MUL[54] + 
                                                      exp_MUL[55] + exp_MUL[56] + exp_MUL[57] + exp_MUL[58] + exp_MUL[59] +
                                                      exp_MUL[60] + exp_MUL[61] + exp_MUL[62] + exp_MUL[63] + exp_MUL[64] + 
                                                      exp_MUL[65] + exp_MUL[66] + exp_MUL[67] + exp_MUL[68] + exp_MUL[69] + 
                                                      exp_MUL[70] + exp_MUL[71] + exp_MUL[72] + exp_MUL[73] + exp_MUL[74] + 
                                                      exp_MUL[75] + exp_MUL[76] + exp_MUL[77] + exp_MUL[78] + exp_MUL[79] + 
                                                      exp_MUL[80] + exp_MUL[81] + exp_MUL[82] + exp_MUL[83];//; + r_bias; // is bias.
     `endif

endmodule
