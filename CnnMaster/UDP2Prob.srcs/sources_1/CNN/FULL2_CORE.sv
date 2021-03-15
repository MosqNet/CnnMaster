`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 16:05:58
// Design Name: 
// Module Name: FULL2_CORE
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

module FULL2_CORE(
    //-- Inputs
    input wire         IVALID,
   // input wire signed [31:0]  IPIX[119:0], 
    input wire signed [31:0]  IPIX[0:119], 
    input wire signed [1023:0]IWEIGHT,
    input wire signed [31:0] IBIAS,
    //-- Outputs
    output wire signed [41:0]  OPIX_FULL, //-- Convoluted value 1 pixel.
    output wire OVALID,
    //output wire [11:0]  OWADDR,
    //-- system
    input wire         ICLK,
    input wire         IRST    
);
       
    (*dont_touch="true"*) wire signed [31:0] mul [0:119];
    reg [2:0]          r_valid;
    
    (*dont_touch="true"*) wire signed [7:0] weight [0:119];
    wire signed [7:0] bias;
    wire signed [31:0] s_bias;
    
    genvar wi;//weight index
    generate
    for (wi=0;wi<120;wi=wi+1) begin
        assign weight[wi] = (IWEIGHT[1023-(wi*8)]) ? ~{1'b0,IWEIGHT[1022-(wi*8) : 1016-(wi*8)]}+1 : IWEIGHT[1023-(wi*8) : 1016-((wi*8))];
    end
    endgenerate
    
   /*
     * convert to 2's complement
     */
     assign bias = (IBIAS[31]) ? ~{1'b0,IBIAS[30:24]}+1 : IBIAS[31:24];
  
     assign s_bias = 32'(signed'(bias) <<< 22);
    
     /*
     * 119 Parallel multiplication
     */
     genvar f2mi;//full2 mult index
     generate
     for (f2mi=0; f2mi<120; f2mi=f2mi+1)begin
        FULL2_MULT mult(.A(IPIX[f2mi]), .B(weight[f2mi]), .P(mul[f2mi]), .CLK(ICLK));
     end
     
     endgenerate

    integer i;
    reg signed [41:0] s_OPIX_FULL;
    reg signed [41:0] s_mul  [0:23];
    reg signed [41:0] s_mul0;
    reg signed [41:0] s_mul1;
    reg signed [41:0] s_mul2;
    reg signed [41:0] s_mul3;
    
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
            s_mul [16] <= mul[80] + mul[81] + mul[82] + mul[83] + mul[84];
            s_mul [17] <= mul[85] + mul[86] + mul[87] + mul[88] + mul[89];
            s_mul [18] <= mul[90] + mul[91] + mul[92] + mul[93] + mul[94];
            s_mul [19] <= mul[95] + mul[96] + mul[97] + mul[98] + mul[99];
            s_mul [20] <= mul[100] + mul[101] + mul[102] + mul[103] + mul[104];
            s_mul [21] <= mul[105] + mul[106] + mul[107] + mul[108] + mul[109];
            s_mul [22] <= mul[110] + mul[111] + mul[112] + mul[113] + mul[114];
            s_mul [23] <= mul[115] + mul[116] + mul[117] + mul[118] + mul[119];
    end
    
    // Calculation split
        
    always_ff @(posedge ICLK) begin
        s_mul0 <= s_mul[0]  + s_mul[1]  + s_mul[2]  + s_mul[3]  + s_mul[4] + s_mul[5];
        s_mul1 <= s_mul[6]  + s_mul[7]  + s_mul[8]  + s_mul[9]  + s_mul[10] + s_mul[11];
        s_mul2 <= s_mul[12] + s_mul[13] + s_mul[14] + s_mul[15] + s_mul[16] + s_mul[17];
        s_mul3 <= s_mul[18] + s_mul[19] + s_mul[20] + s_mul[21] + s_mul[22] + s_mul[23];
    end 
    
    (*dont_touch="true"*) reg  [41:0] r_opix_full;

   always_ff @(posedge ICLK) begin
      r_opix_full <= s_mul0 + s_mul1 + s_mul2 + s_mul3 + s_bias;
   end
     
     assign OPIX_FULL =r_opix_full;
     
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
     
//     `ifdef SIM_FLAG
//         real r_OPIX_FULL, exp_OPIX_CONV, r_bias;
//         real exp_MUL [0:119];
//         real r_PIX [0:119];
//         real r_WEIGHT [0:119];
//         real r_MUL [0:119];
         
//         always_comb begin
//             r_OPIX_FULL = $itor(OPIX_FULL) / (2**28);
//             r_bias      = $itor(bias)    / 64.0;
//         end
         
//         genvar g;    
//         generate
//         for(g=0;g<120;g=g+1)begin
//             assign r_PIX[g] = $itor(IPIX[g]) / 4194304.0;
//             assign r_WEIGHT[g] = $itor(weight[g])   / 64.0;
//             assign r_MUL[g] = $itor(mul[g]) / 268435456.0;
//             assign exp_MUL[g] = r_PIX[g] * r_WEIGHT[g];
//         end
//         endgenerate
         
//         integer j;
         
//         always_comb begin
//            for (j=0; j<120; j=j+1)begin
//                exp_OPIX_CONV = exp_OPIX_CONV + exp_MUL[j];
//            end
//            exp_OPIX_CONV = exp_OPIX_CONV +r_bias;
//         end
         

         
////         assign exp_OPIX_CONV = exp_MUL[0]  + exp_MUL[1]  + exp_MUL[2]  + exp_MUL[3]  + exp_MUL[4]  +
////                              exp_MUL[5]  + exp_MUL[6]  + exp_MUL[7]  + exp_MUL[8]  + exp_MUL[9]  +
////                              exp_MUL[10] + exp_MUL[11] + exp_MUL[12] + exp_MUL[13] + exp_MUL[14] +
////                              exp_MUL[15] + exp_MUL[16] + exp_MUL[17] + exp_MUL[18] + exp_MUL[19] +
////                              exp_MUL[20] + exp_MUL[21] + exp_MUL[22] + exp_MUL[23] + exp_MUL[24] +
////                              exp_MUL[25] + exp_MUL[26] + exp_MUL[27] + exp_MUL[28] + exp_MUL[29] +
////                              exp_MUL[30] + exp_MUL[31] + exp_MUL[32] + exp_MUL[33] + exp_MUL[34] +
////                              exp_MUL[35] + exp_MUL[36] + exp_MUL[37] + exp_MUL[38] + exp_MUL[39] +
////                              exp_MUL[40] + exp_MUL[41] + exp_MUL[42] + exp_MUL[43] + exp_MUL[44] +
////                              exp_MUL[45] + exp_MUL[46] + exp_MUL[67] + exp_MUL[68] + exp_MUL[69] +
////                              exp_MUL[70] + exp_MUL[71] + exp_MUL[72] + exp_MUL[73] + exp_MUL[74] +
////                              exp_MUL[75] + exp_MUL[76] + exp_MUL[77] + exp_MUL[78] + exp_MUL[79] +
////                              exp_MUL[80] + exp_MUL[81] + exp_MUL[82] + exp_MUL[83] + exp_MUL[84] +
////                              exp_MUL[85] + exp_MUL[86] + exp_MUL[87] + exp_MUL[88] + exp_MUL[89] +
////                              exp_MUL[90] + exp_MUL[91] + exp_MUL[92] + exp_MUL[93] + exp_MUL[94] +
////                              exp_MUL[95] + exp_MUL[96] + exp_MUL[97] + exp_MUL[98] + exp_MUL[99] +
////                              exp_MUL[100]+ exp_MUL[101]+ exp_MUL[102]+ exp_MUL[103]+ exp_MUL[104]+
////                              exp_MUL[105]+ exp_MUL[106]+ exp_MUL[107]+ exp_MUL[108]+ exp_MUL[109]+
////                              exp_MUL[110]+ exp_MUL[111]+ exp_MUL[112]+ exp_MUL[113]+ exp_MUL[114]+
////                              exp_MUL[115]+ exp_MUL[116]+ exp_MUL[117]+ exp_MUL[118]+ exp_MUL[119]+
////                              r_bias; // is bias.
//     `endif
     
    
endmodule
