`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 15:46:43
// Design Name: 
// Module Name: FULL1_TOP
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


module FULL1_TOP(
    input wire IINIT,
    input wire FULL1_START,
    input wire signed [24:0]  ID [15:0][24:0],
    input wire [31:0]  FULL1_BIAS_ID,
    input wire [255:0] IPARAMS [15:0],
    output wire [7:0] OPARAMS_ADDR,
    output wire OINIT,
    //--
    output wire signed [31:0] OFULL1,
    //-- system.
    input wire IRST,
    input wire ICLK 
    );
    
    //wire full1_core_valid;
    wire signed [31:0] ofull1_core [15:0];
    
    //add 2021 1/2
    
    wire signed [7:0] bias;
    wire signed [31:0] s_bias;
    
    genvar core_i;
    generate
        for(core_i=0; core_i<16; core_i=core_i+1) begin
                FULL1_CORE full1_core(
                 .IPIX     (ID[core_i]),                    //[399:0] <-- "knl_window"
                .IKNL     (IPARAMS[core_i]),        //[255:0] <-- "knl_params"
                .IBIAS    (FULL1_BIAS_ID),         
                .OPIX_FULL(ofull1_core[core_i]), 
//                .OVALID   (full1_core_valid),
//                .OWADDR   (),
                .IRST     (IRST), 
                .ICLK     (ICLK)
                );
        end
    endgenerate
    
    assign bias = (FULL1_BIAS_ID[31]) ? ~{1'b0,FULL1_BIAS_ID[30:24]}+1 : FULL1_BIAS_ID[31:24];
    assign s_bias = 32'(signed'(bias) <<< 16);
    
    reg  signed [31:0] s_ofull1_core0;
    reg  signed [31:0] s_ofull1_core1;
    reg  signed [31:0] s_ofull1_core2;
    
    always_ff@(posedge ICLK )begin
        s_ofull1_core0 <= ofull1_core[0]+ofull1_core[1]+ofull1_core[2]+ofull1_core[3]+ofull1_core[4]+ofull1_core[5];
        s_ofull1_core1 <= ofull1_core[6]+ofull1_core[7]+ofull1_core[8]+ofull1_core[9]+ofull1_core[10]+ofull1_core[11];
        s_ofull1_core2 <= ofull1_core[12]+ofull1_core[13]+ofull1_core[14]+ofull1_core[15];
    end
    
    assign OFULL1 = s_ofull1_core0 + s_ofull1_core1 + s_ofull1_core2 + s_bias;
    
//    assign OFULL1 = ofull1_core[0]+ofull1_core[1]+ofull1_core[2]+ofull1_core[3]+ofull1_core[4]+ofull1_core[5]+
//                                 ofull1_core[6]+ofull1_core[7]+ofull1_core[8]+ofull1_core[9]+ofull1_core[10]+ofull1_core[11]+
//                                 ofull1_core[12]+ofull1_core[13]+ofull1_core[14]+ofull1_core[15]+s_bias;
                    
    FULL1_CTRL full1_ctrl(
        //-- Main controls.
        .IINIT    (IINIT),
        .ISTART   (FULL1_START),   //--> rising edge detect.
        //-- "img_cutter"
        .OINIT    (OINIT),    //--> "img_cutter" 
        //.DSIGNAL(DSIGNAL),       
        .OPARAM_ADDR (OPARAMS_ADDR), //--> "conv1_params"
        //-- Info
        //-- System
        .IRST   (IRST),
        .ICLK   (ICLK)
    );
    
    /* ----- simulation ----- */
//    `ifdef SIM_FLAG
//    real r_ofull1_c[15:0];
//    real r_OFULL1;
//    real sum_ofull1;
//    real exp_OFULL1;
//    real r_bias;
     
//     genvar sim_i;
//     generate
//         for(sim_i=0; sim_i<16; sim_i=sim_i+1)begin
//             always_comb begin
//                 r_ofull1_c[sim_i] =  $itor(ofull1_core[sim_i]) /4194304.0;
//             end
//         end
//     endgenerate
     
//     assign r_bias = $itor(bias) / 64.0 ;
     
//     assign sum_ofull1 = r_ofull1_c[0]+r_ofull1_c[1]+r_ofull1_c[2]+r_ofull1_c[3]+r_ofull1_c[4]+
//                                     r_ofull1_c[5]+r_ofull1_c[6]+r_ofull1_c[7]+r_ofull1_c[8]+r_ofull1_c[9]+
//                                     r_ofull1_c[10]+r_ofull1_c[11]+r_ofull1_c[12]+r_ofull1_c[13]+r_ofull1_c[14]+r_ofull1_c[15];
                                     
//     assign exp_OFULL1 = r_ofull1_c[0]+r_ofull1_c[1]+r_ofull1_c[2]+r_ofull1_c[3]+r_ofull1_c[4]+
//                                         r_ofull1_c[5]+r_ofull1_c[6]+r_ofull1_c[7]+r_ofull1_c[8]+r_ofull1_c[9]+
//                                         r_ofull1_c[10]+r_ofull1_c[11]+r_ofull1_c[12]+r_ofull1_c[13]+r_ofull1_c[14]+r_ofull1_c[15]+r_bias;
                                        
//     assign r_OFULL1 = $itor(OFULL1)   / 4194304.0;
    
//    `endif
    
    
endmodule

