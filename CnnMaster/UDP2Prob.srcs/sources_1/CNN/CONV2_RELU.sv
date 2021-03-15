`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 18:36:00
// Design Name: 
// Module Name: CONV2_RELU
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

module CONV2_RELU(
    //-- System commons
    input wire IRST,
    input wire ICLK,
    //-- Input
    input wire        IINIT,
    input wire        IEN,
    input wire        IVALID,
    input wire [3:0]  IPARAMS_ADDR,
    input wire [4:0]  IX, 
    input wire [4:0]  IY,
    input wire signed [24:0] IPIX_CONV,
    //-- Output
    //output reg        OVALID,   
    output wire [15:0] ORELU_WE,
    output wire [6:0]  ORELU_ADDR,
    output wire signed [24:0] ORELU
);//---------------------------Conv2 Relu
    
    /* ----- parameter ----- */
    /* ------ register ----- */
    /* ------- wire -------  */
    
    wire        s_sign_bit = IPIX_CONV[24];
    wire signed [24:0] s_relu = (s_sign_bit)? 25'd0 : IPIX_CONV;
    
//    always_ff @ (posedge ICLK) begin
//       ORELU <= s_relu;
//    end

    reg signed [24:0] r_orelu;

    always_comb begin
        r_orelu <= s_relu;
    end
    
    assign ORELU = r_orelu;
    
//    always_ff @ (posedge ICLK) begin
//       if(IRST) OVALID <= 1'b0;
//       else     OVALID <= IVALID;
//    end
    
    reg [2:0] d_valid;
    
    always_ff @ (posedge ICLK) begin
        if(IRST)
            d_valid <= 0;
        else
            d_valid <= {d_valid[1:0],IVALID};
    end
    
    //add 1/2 
    
    
    reg [4:0] RELUX, RELUY;
    wire y_update = (RELUX==9)? 1: 0;
    wire xy_reset = (RELUX==9 && RELUY==9)? 1 : 0;
    
    always_ff @ (posedge ICLK) begin
        if(d_valid[2]) begin
            if(xy_reset)begin
                RELUX <= 0;
                RELUY <= 0;
            end else if(y_update) begin
                RELUX <= 0;
                RELUY <= RELUY + 1;
            end else begin
                RELUX <= RELUX + 1;
            end
        end else begin                
            RELUX <= 0;
            RELUY <= 0;
        end
    end
    
    /*---Control RAM Signal---*/
    //wire [6:0] s_addr = IX + (IY << 3) + (IY << 1);  // IX + IY * 10
    wire [6:0] s_addr = RELUX + (RELUY << 3) + (RELUY << 1);
    
    reg [6:0] r_orelu_addr;
    
    always_ff @(posedge ICLK)begin
       r_orelu_addr <= s_addr;
    end
    
    assign ORELU_ADDR = r_orelu_addr;
    
    //wire mul_en = IEN & IVALID;   // Mul Result Enable
    wire mul_en = d_valid[1];
    reg [15:0] r_orelu_we;
    
    always_ff @(posedge ICLK) begin
        if(IRST) r_orelu_we <= 5'b0;
        else begin
            case(IPARAMS_ADDR)
                4'd0  : r_orelu_we[0] <= mul_en;
                4'd1  : r_orelu_we[1] <= mul_en;
                4'd2  : r_orelu_we[2] <= mul_en;
                4'd3  : r_orelu_we[3] <= mul_en;
                4'd4  : r_orelu_we[4] <= mul_en;
                4'd5  : r_orelu_we[5] <= mul_en;
                4'd6  : r_orelu_we[6] <= mul_en;
                4'd7  : r_orelu_we[7] <= mul_en;
                4'd8  : r_orelu_we[8] <= mul_en;
                4'd9  : r_orelu_we[9] <= mul_en;
                4'd10 : r_orelu_we[10] <= mul_en;
                4'd11 : r_orelu_we[11] <= mul_en;
                4'd12 : r_orelu_we[12] <= mul_en;
                4'd13 : r_orelu_we[13] <= mul_en;
                4'd14 : r_orelu_we[14] <= mul_en;
                4'd15 : r_orelu_we[15] <= mul_en;
                default : r_orelu_we <= 5'b0;
           endcase
       end
    end
    
    assign ORELU_WE = r_orelu_we;
    
    /* ------ simulation ------- */
    `ifdef SIM_FLAG
    
    real r_IPIX_CONV, r_ORELU ,exp_ORELU;
        
    always_comb begin
        assign r_IPIX_CONV = $itor(IPIX_CONV) / 16384.0;
        assign r_ORELU     = $itor(ORELU)    / 16384.0;
        assign exp_ORELU   = (IPIX_CONV[31]) ?  0 :  $itor(IPIX_CONV) / 16384.0;
    end    
    
    `endif
    
endmodule
