//                              -*- Mode: Verilog -*-
// Filename        : LENET.sv
// Description     : 
// Author          : 
// Created On      : Sun Nov  8 20:42:18 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 19:03:31
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module LENET (
   //-- System commons
   input wire   ICLK, //-- 125MHz
   input wire   IRST, //-- Reset signal
   //-- Input
   //input wire [7:0] IIMG [0:24], //-- Cut to 5x5 pixels image(gray scale).
   input wire [1023:0] IIMG,
   input wire LENET_INIT, //-- Lenet initialize signal
   input wire LENET_START, //-- Lenet Start signal
   //-- Output.
   //output wire  CONV1_START, //-- cnn start signal
   output wire  LENET_CMP, //-- lenet end signal
   output wire  [4:0] LED_o,
   output wire  [7:0] PMOD_B_o,
   output wire  [7:0] PMOD_C_o,
   output wire signed [63:0] LENET_RESULT[0:9], // lenet result
   input [3:0]  SW
//   output wire signed [63:0] OPOOL2_RESULT [0:9],
//   output wire signed [63:0] OFULL1_RESULT[0:9],
//   output              OPOOL2_END,
//   output              OFULL1_CMP
);

   wire clkcnn; //-- Half speed of ICLK.
   wire rstcnn;
   wire clkcnn_locked;
   
   CLKGEN_CNN clkgen_cnn (.OCLKCNN(clkcnn), .ICLK125(ICLK), .reset(IRST), .locked(clkcnn_locked));  
   RSTGEN rstgen_cnn ( .reset_o(rstcnn), .reset_i(IRST), .locked_i(clkcnn_locked),  .clk(clkcnn));
   
   /* ------------------------------------------------------------- */
   /* ----- LAYER 1 (convolution and max pooling) ----- */
   /* ------------------------------------------------------------- */
   
//   /* --- Parameter --- */
//   /* --- reg & wire --- */

   wire LAYER1_END;
   wire signed [14:0] POOL1_RESULT [5:0][195:0]; // layer 1 output
   
   LAYER1 layer1(
    //-- System commons
    .ICLK(clkcnn),  //(ICLK),
    .IRST(rstcnn),  //(IRST),
    //-- Input
    .IIMG(IIMG),
    //.IIMG_VALID(s_img_valid),
    .LENET_INIT(LENET_INIT),
    .LENET_START(LENET_START),
    //-- Output
    .L1LED_o(LED_o[0]),
//    .CONV1_START(CONV1_START),
    .POOL1_END(LAYER1_END),
    .POOL1_RESULT(POOL1_RESULT)
   );
      
    /* ------------------------------------------------- */
    /* ----- LAYER 2 (convolution and max pooling) ----- */
    /* ------------------------------------------------- */
    
    wire  L2_START = LAYER1_END;
    wire  POOL2_END;
    wire signed [24:0] POOL2_RESULT [15:0][24:0];
    //-- test
//    reg r_start;
//    always_ff @ (posedge clkcnn) begin
//        if (IRST) r_start <= 1'b0;
//        else      r_start <= LENET_START;
//    end
//    wire s_start = LENET_START & ~r_start; //-- detect riseing.
////    wire signed [63:0] pool2_result [0:9] = {{39'b0,POOL2_RESULT[0][0]},{39'b0,POOL2_RESULT[0][1]},{39'b0,POOL2_RESULT[0][2]},{39'b0,POOL2_RESULT[0][3]},{39'b0,POOL2_RESULT[0][4]},{39'b0,POOL2_RESULT[0][5]},{39'b0,POOL2_RESULT[0][6]},{39'b0,POOL2_RESULT[0][7]},{39'b0,POOL2_RESULT[0][8]},{39'b0,POOL2_RESULT[0][9]}};
//    wire signed [63:0] pool2_result [0:9] = {{39'b0,25'd0},{39'b0,25'd1},{39'b0,25'd2},{39'b0,25'd3},{39'b0,25'd4},{39'b0,25'd5},{39'b0,25'd6},{39'b0,25'd7},{39'b0,25'd8},{39'b0,25'd9}};
//    reg pool2_end0;
//    reg pool2_end1;
//    reg pool2_end2;
//    always_ff @(posedge ICLK)begin
//        pool2_end0 <= POOL2_END;
//        pool2_end1 <= pool2_end0;
//        pool2_end2 <= pool2_end1;
//    end
//    reg signed [63:0] pool2_result0 [0:9];
//    reg signed [63:0] pool2_result1 [0:9];
//    reg signed [63:0] pool2_result2 [0:9]; 
//    always_ff @(posedge ICLK)begin
//        pool2_result0 <= pool2_result;
//        pool2_result1 <= pool2_result0;
//        pool2_result2 <= pool2_result1;
//    end
    
//    assign OPOOL2_END = pool2_end2;
//    assign OPOOL2_RESULT = pool2_result2;
    
        
    LAYER2 layer2(
    //-- System commons
    .ICLK(clkcnn), //(ICLK),
    .IRST(rstcnn),   //(IRST),
    //-- Input
    .L2_INIT(LENET_INIT),
    .L2_START(L2_START),
    .POOL1_RESULT(POOL1_RESULT),
    //-- Output
    .L2LED_o(LED_o[1]),
    .POOL2_END(POOL2_END),
    .POOL2_RESULT(POOL2_RESULT)
    );
       
//    /* ------------------------------------------------- */
//    /* ----------- LAYER 3 (full connection) ----------- */
//    /* ------------------------------------------------- */
    
    (*dont_touch="true"*) wire L3_START = POOL2_END;
    wire FULL1_CMP;    
    wire signed  [31:0] FULL1_RESULT [0:119];

    LAYER3 layer3(
    //-- System commons
    .ICLK(clkcnn),  //(ICLK),
    .IRST(rstcnn),    //(IRST),
    //-- Input
    .L3_START(L3_START),
    .POOL2_RESULT(POOL2_RESULT),
    //-- Output
    .L3LED_o(LED_o[2]),
    .PMOD_B1(PMOD_B_o[1]),
    .PMOD_B2(PMOD_B_o[2]),
    .FULL1_CMP(FULL1_CMP),
    .FULL1_RESULT(FULL1_RESULT)
    );
    
//    //-- debug
//    assign PMOD_B_o[0] = L3_START;
    //-- test
//    reg full1_cmp0;
//    reg full1_cmp1;
//    reg full1_cmp2;
//    always_ff @(posedge ICLK)begin
//        full1_cmp0 <= FULL1_CMP;
//        full1_cmp1 <= full1_cmp0;
//        full1_cmp2 <= full1_cmp1;
//    end
//    assign OFULL1_CMP = full1_cmp2;
//    reg signed [63:0] full1_result0 [0:9];
//    reg signed [63:0] full1_result1 [0:9];
//    reg signed [63:0] full1_result2 [0:9];
//    always_ff @(posedge ICLK)begin
//        full1_result0 <= {{32'b0,FULL1_RESULT[0]},{32'b0,FULL1_RESULT[1]},{32'b0,FULL1_RESULT[2]},{32'b0,FULL1_RESULT[3]},{32'b0,FULL1_RESULT[4]},{32'b0,FULL1_RESULT[5]},{32'b0,FULL1_RESULT[6]},{32'b0,FULL1_RESULT[7]},{32'b0,FULL1_RESULT[8]},{32'b0,FULL1_RESULT[9]}};
//        full1_result1 <= full1_result0;
//        full1_result2 <= full1_result1;
//    end
//    assign OFULL1_RESULT = full1_result2;
    
    
//    /* ------------------------------------------------- */
//    /* ----------- LAYER 4 (full connection) ----------- */
//    /* ------------------------------------------------- */
    
    wire FULL2_START = FULL1_CMP;
    wire FULL2_CMP;
    wire signed [41:0] FULL2_RESULT [0:83];
    
    LAYER4 layer4(
    //-- System commons
    .ICLK(clkcnn),  //(ICLK),
    .IRST(rstcnn),  //IRST),
    //-- Input
    .FULL2_START(FULL2_START),
    .FULL1_RESULT(FULL1_RESULT),
    //-- Output
    .L4LED_o(LED_o[3]),
    .PMOD_B4(PMOD_B_o[4]),
    .PMOD_B5(PMOD_B_o[5]),
    .FULL2_CMP(FULL2_CMP),
    .FULL2_RESULT(FULL2_RESULT)
    );
    
    //-- debug
    assign PMOD_B_o[3] = FULL2_START;
    
    /* ------------------------------------------------- */
    /* ---------------- LAYER 5 (output) --------------- */
    /* ------------------------------------------------- */
    
    wire L5_END;
    wire OUT_START = FULL2_CMP;
    wire signed [63:0] L5_RESULT [0:9];
    
    LAYER5 layer5(
    //-- System commons
    .ICLK(clkcnn), //(ICLK),
    .IRST(rstcnn),  //(IRST),
    //-- Input
    .FULL2_CMP(OUT_START),
    .FULL2_RESULT(FULL2_RESULT),
    //-- Output
    .L5LED_o(LED_o[4]),
    .PMOD_C0(PMOD_C_o[0]),
    .PMOD_C1(PMOD_C_o[1]),
    .LENET_CMP(L5_END),
    .LENET_RESULT(L5_RESULT)
    );
   
    assign PMOD_B_o[6] = OUT_START;
    assign PMOD_C_o[2] = L5_END;
    
    reg [1:0] d_cmp;
    always_ff @(posedge ICLK)begin
        d_cmp[0] <= L5_END;
        d_cmp[1] <= d_cmp[0];
    end
    
    assign LENET_CMP = d_cmp;
    
    //---test
    wire signed [31:0] FULL1_test0 = FULL1_RESULT[0];   //32bit
    wire signed [31:0] FULL1_test1 = FULL1_RESULT[1];
    wire signed [31:0] FULL1_test2 = FULL1_RESULT[2];
    wire signed [31:0] FULL1_test3 = FULL1_RESULT[3];
    wire signed [41:0] FULL2_test0 = FULL2_RESULT[0];   //42bit
    wire signed [41:0] FULL2_test1 = FULL2_RESULT[1];
    wire signed [41:0] FULL2_test2 = FULL2_RESULT[2];
    wire signed [41:0] FULL2_test3 = FULL2_RESULT[3];
    reg signed [63:0] RESULT_SEL [0:9];
    always_comb begin
        case(SW)
            4'd0 : begin
                RESULT_SEL = {{49'b0,POOL1_RESULT[0][0]},{49'b0,POOL1_RESULT[0][1]},{49'b0,POOL1_RESULT[0][2]},{49'b0,POOL1_RESULT[0][3]},{49'b0,POOL1_RESULT[0][4]},{49'b0,POOL1_RESULT[0][5]},{49'b0,POOL1_RESULT[0][6]},{49'b0,POOL1_RESULT[0][7]},{49'b0,POOL1_RESULT[0][8]},{49'b0,POOL1_RESULT[0][9]}};// 
            end
            4'd1 : begin
                RESULT_SEL = {{39'b0,POOL2_RESULT[0][0]},{39'b0,POOL2_RESULT[0][1]},{39'b0,POOL2_RESULT[0][2]},{39'b0,POOL2_RESULT[0][3]},{39'b0,POOL2_RESULT[0][4]},{39'b0,POOL2_RESULT[0][5]},{39'b0,POOL2_RESULT[0][6]},{39'b0,POOL2_RESULT[0][7]},{39'b0,POOL2_RESULT[0][8]},{39'b0,POOL2_RESULT[0][9]}};
            end
            4'd2 : begin
                RESULT_SEL[0] = {{32{FULL1_test0[31]}},FULL1_test0};
                RESULT_SEL[1] = {{32{FULL1_test1[31]}},FULL1_test1};
                RESULT_SEL[2] = {{32{FULL1_test2[31]}},FULL1_test2};
                RESULT_SEL[3]  ={{32{FULL1_test3[31]}},FULL1_test3};
                RESULT_SEL[4] = 64'b0;
                RESULT_SEL[5] = 64'b0;
                RESULT_SEL[6] = 64'b0;
                RESULT_SEL[7] = 64'b0;
                RESULT_SEL[8] = 64'b0;
                RESULT_SEL[9] = 64'b0;
            end
            4'd3 : begin
                RESULT_SEL[0] = {{22{FULL2_test0[41]}},FULL2_test0};
                RESULT_SEL[1] = {{22{FULL2_test1[41]}},FULL2_test1};
                RESULT_SEL[2] = {{22{FULL2_test2[41]}},FULL2_test2};
                RESULT_SEL[3]  ={{22{FULL2_test3[41]}},FULL2_test3};
                RESULT_SEL[4] = 64'b0;
                RESULT_SEL[5] = 64'b0;
                RESULT_SEL[6] = 64'b0;
                RESULT_SEL[7] = 64'b0;
                RESULT_SEL[8] = 64'b0;
                RESULT_SEL[9] = 64'b0;
            end
            4'd4 : begin
                RESULT_SEL = L5_RESULT;
            end
            default : begin
                RESULT_SEL = L5_RESULT;
            end
        endcase
    end
    
    assign LENET_RESULT = RESULT_SEL;
   
endmodule // LENET

