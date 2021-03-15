`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 16:20:25
// Design Name: 
// Module Name: FULL1_CORE
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

module FULL1_CORE(
    //-- System commons
    input wire ICLK,
    input wire IRST,
    //-- Inputs
    input wire IVALID,
    input wire signed [24:0]  IPIX [24:0], 
    input wire [255:0] IKNL,  //<-- from RAM.
    input wire [31:0] IBIAS, //<-- from ROM
    input wire [4:0]   IX,
    input wire [4:0]   IY,
    //-- Outputs
    output wire signed [31:0]  OPIX_FULL //-- Convoluted value 1 pixel.
    //output wire        OVALID,
    //output reg [11:0]  OWADDR
    ); //-----------------------------------------------------------------
    
    /* ----- parameter ----- */
    /* ------ register ----- */
    reg [2:0]          r_valid;
    /* ------- wire -------  */
    wire signed [31:0] mul[0:24];
    wire signed [7:0]  knl[0:24];
    wire signed [7:0]  bias;
    wire signed [31:0] s_bias;
    
    /*
     * Slice bits by each byte.
     */
    
    generate
          genvar knl_id;
          for(knl_id=0; knl_id<25; knl_id=knl_id+1)begin
              assign knl[knl_id] = (IKNL[255-(knl_id*8)]) ? ~{1'b0,IKNL[254-(knl_id*8) : 248-(knl_id*8)]} + 1 : IKNL[255-(knl_id*8) : 248-(knl_id*8)];
          end
    endgenerate
   
   /*
    * convert to 2's complement
    */
    assign bias = (IBIAS[31]) ? ~{1'b0,IBIAS[30:24]}+1 : IBIAS[31:24];
 
    assign s_bias = 32'(signed'(bias) <<< 16);
    
    /*
     * 25 Parallel multiplication
     */
    genvar mult_id;
    generate
    for(mult_id=0; mult_id<25; mult_id=mult_id+1)begin
        FULL1MULT mult(.A(IPIX[mult_id]), .B(knl[mult_id]), .P(mul[mult_id]), .CLK(ICLK));
    end
    endgenerate
    
    reg signed [31:0] r_smul;
    reg signed [31:0] s_mul0;
    reg signed [31:0] s_mul1;
    reg signed [31:0] s_mul2;
    reg signed [31:0] s_mul3;
    reg signed [31:0] s_mul4;
    
    // Calculation split
        
    always_ff @(posedge ICLK) begin
        s_mul0 <= mul[0]  + mul[1]  + mul[2]  + mul[3]  + mul[4];
        s_mul1 <= mul[5]  + mul[6]  + mul[7]  + mul[8]  + mul[9];
        s_mul2 <= mul[10] + mul[11] + mul[12] + mul[13] + mul[14];
        s_mul3 <=  mul[15] + mul[16] + mul[17] + mul[18] + mul[19];
        s_mul4 <=  mul[20] + mul[21] + mul[22] + mul[23] + mul[24];
    end 

   always_ff @(posedge ICLK) begin
      r_smul <= s_mul0 + s_mul1 + s_mul2 + s_mul3 + s_mul4;
   end
    
    
    assign OPIX_FULL = r_smul;
    
//    always_ff @(posedge ICLK) begin
//       OPIX_FULL <= mul[0]  + mul[1]  + mul[2]  + mul[3]  + mul[4]  +
//               mul[5]  + mul[6]  + mul[7]  + mul[8]  + mul[9]  +
//               mul[10] + mul[11] + mul[12] + mul[13] + mul[14] +
//               mul[15] + mul[16] + mul[17] + mul[18] + mul[19] +
//               mul[20] + mul[21] + mul[22] + mul[23] + mul[24];
//               // +bias; // is bias.
//    end
    
//    always_ff @ (posedge ICLK) begin
//       if (IRST) r_valid <= 0;
//       else      r_valid <= {r_valid[1:0], IVALID};
//    end
//    assign OVALID = r_valid[2];
        
//    /*
//     * TODO:  convert from IX, IY to RAM address.
//     */
//    always @ (posedge ICLK) begin
//       OWADDR <= 12'h1234;
//    end
    
//    `ifdef SIM_FLAG
//        real r_OPIX_FULL, exp_OPIX_CONV, r_bias;
//        real exp_MUL [24:0];
//        real r_PIX [24:0];
//        real r_KNL [24:0];
//        real r_MUL [24:0];
//        genvar g;
//        always_comb begin
//            r_OPIX_FULL = $itor(OPIX_FULL) / 128.0;
//            r_bias      = $itor(s_bias)    / 64.0;
//        end    
//        generate
//        for(g=0;g<25;g=g+1)begin
//            assign r_PIX[g] = $itor(IPIX[g]) / 65536.0;
//            assign r_KNL[g] = $itor(knl[g])   / 64.0;
//            assign r_MUL[g] = $itor(mul[g]) / 4194304.0;
//            assign exp_MUL[g] = r_PIX[g] * r_KNL[g];
//        end
//        endgenerate
//        assign exp_OPIX_CONV = exp_MUL[0]   + exp_MUL[1]   + exp_MUL[2]   + exp_MUL[3]   + exp_MUL[4]   +
//                                                  exp_MUL[5]   + exp_MUL[6]   + exp_MUL[7]   + exp_MUL[8]   + exp_MUL[9]   +
//                                                  exp_MUL[10] + exp_MUL[11] + exp_MUL[12] + exp_MUL[13] + exp_MUL[14] +
//                                                  exp_MUL[15] + exp_MUL[16] + exp_MUL[17] + exp_MUL[18] + exp_MUL[19] +
//                                                  exp_MUL[20] + exp_MUL[21] + exp_MUL[22] + exp_MUL[23] + exp_MUL[24];
//                               // +r_bias;
//    `endif
    



endmodule
