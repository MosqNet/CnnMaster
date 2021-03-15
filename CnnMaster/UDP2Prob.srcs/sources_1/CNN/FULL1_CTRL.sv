`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/01 15:43:39
// Design Name: 
// Module Name: FULL1_CTRL
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

module FULL1_CTRL(
//-- System Commos
input wire IRST,
input wire ICLK,
//-- Input
input wire ILAST,
input wire IINIT,
input wire ISTART,
//-- Output
output wire OINIT,
output wire OEN,
output wire [7:0] OPARAM_ADDR,
output wire [3:0] OST
);
    
   localparam [3:0] INIT_LEN = 4'd4;
   localparam [3:0] END_LEN  = 4'd4;
   localparam [3:0] U0_LEN  = 4'hF;
   localparam [3:0] U1_LEN  = 4'hF;
   localparam [3:0] U2_LEN  = 4'hF;
   localparam [3:0] U3_LEN  = 4'hF;
   localparam [3:0] U4_LEN  = 4'hF;
   localparam [3:0] U5_LEN  = 4'hF;
   localparam [3:0] U6_LEN  = 4'hF;
   localparam [3:0] U7_LEN  = 4'hF;
   localparam [3:0] U8_LEN  = 4'hF;
   localparam [3:0] U9_LEN  = 4'hF;
   localparam [3:0] U10_LEN  = 4'hF;
   localparam [3:0] U11_LEN  = 4'hF;
   localparam [3:0] U12_LEN  = 4'hF;
   localparam [3:0] U13_LEN  = 4'hF;
   localparam [3:0] U14_LEN  = 4'hF;
   localparam [3:0] U15_LEN  = 4'hF;
    
   reg        r_start;
   reg [7:0]  st, nx;
   reg [3:0]  r_init_cyc;
   reg [3:0]  r_end_cyc;
   reg [3:0]  r_last;
   reg r_first;
    
    always_ff @ (posedge ICLK) begin
       if (IRST) r_start <= 1'b0;
       else      r_start <= ISTART;
    end
    wire s_start = ISTART & ~r_start; //-- detect riseing.
    
//    always @ (posedge ICLK) begin
//       if (IRST)               r_last <= 4'hF;
//       else if (IINIT || ILAST)     r_last <= 4'hF;
//       else if (r_last > 4'h0) r_last <= r_last - 4'h1;
//    end
//    wire s_unit_end = (r_last == 4'h1);
    /*
     * FSM
     */
    always_comb begin
       nx = st; //-- default hold current state.
       case (st) 
         `FULL1_IDLE_ST: if(s_start) nx = `FULL1_INIT_ST;
         `FULL1_INIT_ST: if(r_init_cyc==INIT_LEN) nx = `FULL1_N000_ST;
         `FULL1_N000_ST: nx = `FULL1_N001_ST;`FULL1_N001_ST: nx = `FULL1_N002_ST;
         `FULL1_N002_ST: nx = `FULL1_N003_ST;`FULL1_N003_ST: nx = `FULL1_N004_ST;
         `FULL1_N004_ST: nx = `FULL1_N005_ST;`FULL1_N005_ST: nx = `FULL1_N006_ST;
         `FULL1_N006_ST: nx = `FULL1_N007_ST;`FULL1_N007_ST: nx = `FULL1_N008_ST;
         `FULL1_N008_ST: nx = `FULL1_N009_ST;`FULL1_N009_ST: nx = `FULL1_N010_ST;
         `FULL1_N010_ST: nx = `FULL1_N011_ST;`FULL1_N011_ST: nx = `FULL1_N012_ST;
         `FULL1_N012_ST: nx = `FULL1_N013_ST;`FULL1_N013_ST: nx = `FULL1_N014_ST;
         `FULL1_N014_ST: nx = `FULL1_N015_ST;`FULL1_N015_ST: nx = `FULL1_N016_ST;
         `FULL1_N016_ST: nx = `FULL1_N017_ST;`FULL1_N017_ST: nx = `FULL1_N018_ST;
         `FULL1_N018_ST: nx = `FULL1_N019_ST;`FULL1_N019_ST: nx = `FULL1_N020_ST;
         `FULL1_N020_ST: nx = `FULL1_N021_ST;`FULL1_N021_ST: nx = `FULL1_N022_ST;
         `FULL1_N022_ST: nx = `FULL1_N023_ST;`FULL1_N023_ST: nx = `FULL1_N024_ST;
         `FULL1_N024_ST: nx = `FULL1_N025_ST;`FULL1_N025_ST: nx = `FULL1_N026_ST;
         `FULL1_N026_ST: nx = `FULL1_N027_ST;`FULL1_N027_ST: nx = `FULL1_N028_ST;
         `FULL1_N028_ST: nx = `FULL1_N029_ST;`FULL1_N029_ST: nx = `FULL1_N030_ST;
         `FULL1_N030_ST: nx = `FULL1_N031_ST;`FULL1_N031_ST: nx = `FULL1_N032_ST;
         `FULL1_N032_ST: nx = `FULL1_N033_ST;`FULL1_N033_ST: nx = `FULL1_N034_ST;
         `FULL1_N034_ST: nx = `FULL1_N035_ST;`FULL1_N035_ST: nx = `FULL1_N036_ST;
         `FULL1_N036_ST: nx = `FULL1_N037_ST;`FULL1_N037_ST: nx = `FULL1_N038_ST;
         `FULL1_N038_ST: nx = `FULL1_N039_ST;`FULL1_N039_ST: nx = `FULL1_N040_ST;
         `FULL1_N040_ST: nx = `FULL1_N041_ST;`FULL1_N041_ST: nx = `FULL1_N042_ST;
         `FULL1_N042_ST: nx = `FULL1_N043_ST;`FULL1_N043_ST: nx = `FULL1_N044_ST;
         `FULL1_N044_ST: nx = `FULL1_N045_ST;`FULL1_N045_ST: nx = `FULL1_N046_ST;
         `FULL1_N046_ST: nx = `FULL1_N047_ST;`FULL1_N047_ST: nx = `FULL1_N048_ST;
         `FULL1_N048_ST: nx = `FULL1_N049_ST;`FULL1_N049_ST: nx = `FULL1_N050_ST;
         `FULL1_N050_ST: nx = `FULL1_N051_ST;`FULL1_N051_ST: nx = `FULL1_N052_ST;
         `FULL1_N052_ST: nx = `FULL1_N053_ST;`FULL1_N053_ST: nx = `FULL1_N054_ST;
         `FULL1_N054_ST: nx = `FULL1_N055_ST;`FULL1_N055_ST: nx = `FULL1_N056_ST;
         `FULL1_N056_ST: nx = `FULL1_N057_ST;`FULL1_N057_ST: nx = `FULL1_N058_ST;
         `FULL1_N058_ST: nx = `FULL1_N059_ST;`FULL1_N059_ST: nx = `FULL1_N060_ST;
         `FULL1_N060_ST: nx = `FULL1_N061_ST;`FULL1_N061_ST: nx = `FULL1_N062_ST;
         `FULL1_N062_ST: nx = `FULL1_N063_ST;`FULL1_N063_ST: nx = `FULL1_N064_ST;
         `FULL1_N064_ST: nx = `FULL1_N065_ST;`FULL1_N065_ST: nx = `FULL1_N066_ST;
         `FULL1_N066_ST: nx = `FULL1_N067_ST;`FULL1_N067_ST: nx = `FULL1_N068_ST;
         `FULL1_N068_ST: nx = `FULL1_N069_ST;`FULL1_N069_ST: nx = `FULL1_N070_ST;
         `FULL1_N070_ST: nx = `FULL1_N071_ST;`FULL1_N071_ST: nx = `FULL1_N072_ST;
         `FULL1_N072_ST: nx = `FULL1_N073_ST;`FULL1_N073_ST: nx = `FULL1_N074_ST;
         `FULL1_N074_ST: nx = `FULL1_N075_ST;`FULL1_N075_ST: nx = `FULL1_N076_ST;
         `FULL1_N076_ST: nx = `FULL1_N077_ST;`FULL1_N077_ST: nx = `FULL1_N078_ST;
         `FULL1_N078_ST: nx = `FULL1_N079_ST;`FULL1_N079_ST: nx = `FULL1_N080_ST;
         `FULL1_N080_ST: nx = `FULL1_N081_ST;`FULL1_N081_ST: nx = `FULL1_N082_ST;
         `FULL1_N082_ST: nx = `FULL1_N083_ST;`FULL1_N083_ST: nx = `FULL1_N084_ST;
         `FULL1_N084_ST: nx = `FULL1_N085_ST;`FULL1_N085_ST: nx = `FULL1_N086_ST;
         `FULL1_N086_ST: nx = `FULL1_N087_ST;`FULL1_N087_ST: nx = `FULL1_N088_ST;
         `FULL1_N088_ST: nx = `FULL1_N089_ST;`FULL1_N089_ST: nx = `FULL1_N090_ST;
         `FULL1_N090_ST: nx = `FULL1_N091_ST;`FULL1_N091_ST: nx = `FULL1_N092_ST;
         `FULL1_N092_ST: nx = `FULL1_N093_ST;`FULL1_N093_ST: nx = `FULL1_N094_ST;
         `FULL1_N094_ST: nx = `FULL1_N095_ST;`FULL1_N095_ST: nx = `FULL1_N096_ST;
         `FULL1_N096_ST: nx = `FULL1_N097_ST;`FULL1_N097_ST: nx = `FULL1_N098_ST;
         `FULL1_N098_ST: nx = `FULL1_N099_ST;`FULL1_N099_ST: nx = `FULL1_N100_ST;
         `FULL1_N100_ST: nx = `FULL1_N101_ST;`FULL1_N101_ST: nx = `FULL1_N102_ST;
         `FULL1_N102_ST: nx = `FULL1_N103_ST;`FULL1_N103_ST: nx = `FULL1_N104_ST;
         `FULL1_N104_ST: nx = `FULL1_N105_ST;`FULL1_N105_ST: nx = `FULL1_N106_ST;
         `FULL1_N106_ST: nx = `FULL1_N107_ST;`FULL1_N107_ST: nx = `FULL1_N108_ST;
         `FULL1_N108_ST: nx = `FULL1_N109_ST;`FULL1_N109_ST: nx = `FULL1_N110_ST;
         `FULL1_N110_ST: nx = `FULL1_N111_ST;`FULL1_N111_ST: nx = `FULL1_N112_ST;
         `FULL1_N112_ST: nx = `FULL1_N113_ST;`FULL1_N113_ST: nx = `FULL1_N114_ST;
         `FULL1_N114_ST: nx = `FULL1_N115_ST;`FULL1_N115_ST: nx = `FULL1_N116_ST;
         `FULL1_N116_ST: nx = `FULL1_N117_ST;`FULL1_N117_ST: nx = `FULL1_N118_ST;
         `FULL1_N118_ST: nx = `FULL1_N119_ST;`FULL1_N119_ST: nx = `FULL1_END_ST;
         `FULL1_END_ST: if (r_end_cyc==END_LEN) nx = `FULL1_IDLE_ST;
         `FULL1_ERR_ST: nx = `FULL1_ERR_ST; // stay in error.
         default: begin
            nx = `FULL1_ERR_ST;
         end
       endcase // case (st)
    end // always_comb
    
    
    always_ff @ (posedge ICLK) begin
       if (IRST)       st <= `FULL1_IDLE_ST;
       else if (IINIT) st <= `FULL1_IDLE_ST;
       else            st <= nx;
    end
    /*
     * r_init_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_init_cyc <= 4'd0;
       else if (st==`FULL1_IDLE_ST) r_init_cyc <= 4'd0;
       else if (st==`FULL1_INIT_ST) r_init_cyc <= r_init_cyc + 4'd1;
    end
    /*
     * r_end_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_end_cyc <= 4'd0;
       else if (st==`FULL1_IDLE_ST) r_end_cyc <= 4'd0;
       else if (st==`FULL1_END_ST) r_end_cyc <= r_end_cyc + 4'd1;
    end
    /*
     * r_u*_cyc[]
     */
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_first <= 4'h0;
//       else if (st==`FULL1_INIT_ST) r_first <= 4'h0;
//       else if (st==`FULL1_N000_ST)   r_first <= (r_first==4'hF)? 4'hF : (r_first + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u1_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u1_cyc <= 4'h0;
//       else if (st==`CONV2_U1_ST)   r_u1_cyc <= (r_u1_cyc==4'hF)? 4'hF : (r_u1_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u2_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u2_cyc <= 4'h0;
//       else if (st==`CONV2_U2_ST)   r_u2_cyc <= (r_u2_cyc==4'hF)? 4'hF : (r_u2_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u3_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u3_cyc <= 4'h0;
//       else if (st==`CONV2_U3_ST)   r_u3_cyc <= (r_u3_cyc==4'hF)? 4'hF : (r_u3_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u4_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u4_cyc <= 4'h0;
//       else if (st==`CONV2_U4_ST)   r_u4_cyc <= (r_u4_cyc==4'hF)? 4'hF : (r_u4_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u5_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u5_cyc <= 4'h0;
//       else if (st==`CONV2_U5_ST)   r_u5_cyc <= (r_u5_cyc==4'hF)? 4'hF : (r_u5_cyc + 4'h1);
//    end
    
//       always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u6_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u6_cyc <= 4'h0;
//       else if (st==`CONV2_U6_ST)   r_u6_cyc <= (r_u6_cyc==4'hF)? 4'hF : (r_u6_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u7_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u7_cyc <= 4'h0;
//       else if (st==`CONV2_U7_ST)   r_u7_cyc <= (r_u7_cyc==4'hF)? 4'hF : (r_u7_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u8_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u8_cyc <= 4'h0;
//       else if (st==`CONV2_U8_ST)   r_u8_cyc <= (r_u8_cyc==4'hF)? 4'hF : (r_u8_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u9_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u9_cyc <= 4'h0;
//       else if (st==`CONV2_U9_ST)   r_u9_cyc <= (r_u9_cyc==4'hF)? 4'hF : (r_u9_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u10_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u10_cyc <= 4'h0;
//       else if (st==`CONV2_U10_ST)   r_u10_cyc <= (r_u10_cyc==4'hF)? 4'hF : (r_u10_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u11_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u11_cyc <= 4'h0;
//       else if (st==`CONV2_U11_ST)   r_u11_cyc <= (r_u11_cyc==4'hF)? 4'hF : (r_u11_cyc + 4'h1);
//    end
//       always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u12_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u12_cyc <= 4'h0;
//       else if (st==`CONV2_U12_ST)   r_u12_cyc <= (r_u12_cyc==4'hF)? 4'hF : (r_u12_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u13_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u13_cyc <= 4'h0;
//       else if (st==`CONV2_U13_ST)   r_u13_cyc <= (r_u13_cyc==4'hF)? 4'hF : (r_u13_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u14_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u14_cyc <= 4'h0;
//       else if (st==`CONV2_U14_ST)   r_u14_cyc <= (r_u14_cyc==4'hF)? 4'hF : (r_u14_cyc + 4'h1);
//    end
//    always_ff @(posedge ICLK) begin
//       if (IRST)                    r_u15_cyc <= 4'h0;
//       else if (st==`CONV2_INIT_ST) r_u15_cyc <= 4'h0;
//       else if (st==`CONV2_U15_ST)   r_u15_cyc <= (r_u15_cyc==4'hF)? 4'hF : (r_u15_cyc + 4'h1);
//    end
    
    always_ff @ (posedge ICLK) begin
       if (IRST)                    r_first <= 0;
       else if (st==`FULL1_INIT_ST) r_first <= 0;
       else if (st==`FULL1_N000_ST)   r_first <= 1;
       else if (st==`FULL1_END_ST) r_first <= 0;
    end
    
    (*dont_touch="true"*)reg [7:0] d_first; //
    always_ff @(posedge ICLK)begin
       if(IRST) d_first <= 8'b0;
       else d_first <= {d_first[6:0],r_first};
    end
    
    //assign DSIGNAL = d_first[1]; // delay read bias by 2 cycles
    assign OINIT = d_first[7];
    /*
     * Address control logic at FULL1
     */
     
     reg [7:0] r_oparam_addr;
     
    always_ff @ (posedge ICLK) begin
       if (IRST) r_oparam_addr <= 5'h8F;
       else begin
          case(st)
            `FULL1_N000_ST: r_oparam_addr <= 7'h0; `FULL1_N001_ST: r_oparam_addr <= 7'h1;
          `FULL1_N002_ST: r_oparam_addr <= 7'h2; `FULL1_N003_ST: r_oparam_addr <= 7'h3;
          `FULL1_N004_ST: r_oparam_addr <= 7'h4; `FULL1_N005_ST: r_oparam_addr <= 7'h5;
          `FULL1_N006_ST: r_oparam_addr <= 7'h6; `FULL1_N007_ST: r_oparam_addr <= 7'h7;
          `FULL1_N008_ST: r_oparam_addr <= 7'h8; `FULL1_N009_ST: r_oparam_addr <= 7'h9;
          `FULL1_N010_ST: r_oparam_addr <= 7'hA; `FULL1_N011_ST: r_oparam_addr <= 7'hB;
          `FULL1_N012_ST: r_oparam_addr <= 7'hC; `FULL1_N013_ST: r_oparam_addr <= 7'hD;
          `FULL1_N014_ST: r_oparam_addr <= 7'hE; `FULL1_N015_ST: r_oparam_addr <= 7'hF;
          `FULL1_N016_ST: r_oparam_addr <= 7'h10;`FULL1_N017_ST: r_oparam_addr <= 7'h11;
          `FULL1_N018_ST: r_oparam_addr <= 7'h12;`FULL1_N019_ST: r_oparam_addr <= 7'h13;
          `FULL1_N020_ST: r_oparam_addr <= 7'h14;`FULL1_N021_ST: r_oparam_addr <= 7'h15;
          `FULL1_N022_ST: r_oparam_addr <= 7'h16;`FULL1_N023_ST: r_oparam_addr <= 7'h17;
          `FULL1_N024_ST: r_oparam_addr <= 7'h18;`FULL1_N025_ST: r_oparam_addr <= 7'h19;
          `FULL1_N026_ST: r_oparam_addr <= 7'h1A;`FULL1_N027_ST: r_oparam_addr <= 7'h1B;
          `FULL1_N028_ST: r_oparam_addr <= 7'h1C;`FULL1_N029_ST: r_oparam_addr <= 7'h1D;
          `FULL1_N030_ST: r_oparam_addr <= 7'h1E;`FULL1_N031_ST: r_oparam_addr <= 7'h1F;
          `FULL1_N032_ST: r_oparam_addr <= 7'h20;`FULL1_N033_ST: r_oparam_addr <= 7'h21;
          `FULL1_N034_ST: r_oparam_addr <= 7'h22;`FULL1_N035_ST: r_oparam_addr <= 7'h23;
          `FULL1_N036_ST: r_oparam_addr <= 7'h24;`FULL1_N037_ST: r_oparam_addr <= 7'h25;
          `FULL1_N038_ST: r_oparam_addr <= 7'h26;`FULL1_N039_ST: r_oparam_addr <= 7'h27;
          `FULL1_N040_ST: r_oparam_addr <= 7'h28;`FULL1_N041_ST: r_oparam_addr <= 7'h29;
          `FULL1_N042_ST: r_oparam_addr <= 7'h2A;`FULL1_N043_ST: r_oparam_addr <= 7'h2B;
          `FULL1_N044_ST: r_oparam_addr <= 7'h2C;`FULL1_N045_ST: r_oparam_addr <= 7'h2D;
          `FULL1_N046_ST: r_oparam_addr <= 7'h2E;`FULL1_N047_ST: r_oparam_addr <= 7'h2F;
          `FULL1_N048_ST: r_oparam_addr <= 7'h30;`FULL1_N049_ST: r_oparam_addr <= 7'h31;
          `FULL1_N050_ST: r_oparam_addr <= 7'h32;`FULL1_N051_ST: r_oparam_addr <= 7'h33;
          `FULL1_N052_ST: r_oparam_addr <= 7'h34;`FULL1_N053_ST: r_oparam_addr <= 7'h35;
          `FULL1_N054_ST: r_oparam_addr <= 7'h36;`FULL1_N055_ST: r_oparam_addr <= 7'h37;
          `FULL1_N056_ST: r_oparam_addr <= 7'h38;`FULL1_N057_ST: r_oparam_addr <= 7'h39;
          `FULL1_N058_ST: r_oparam_addr <= 7'h3A;`FULL1_N059_ST: r_oparam_addr <= 7'h3B;
          `FULL1_N060_ST: r_oparam_addr <= 7'h3C;`FULL1_N061_ST: r_oparam_addr <= 7'h3D;
          `FULL1_N062_ST: r_oparam_addr <= 7'h3E;`FULL1_N063_ST: r_oparam_addr <= 7'h3F;
          `FULL1_N064_ST: r_oparam_addr <= 7'h40;`FULL1_N065_ST: r_oparam_addr <= 7'h41;
          `FULL1_N066_ST: r_oparam_addr <= 7'h42;`FULL1_N067_ST: r_oparam_addr <= 7'h43;
          `FULL1_N068_ST: r_oparam_addr <= 7'h44;`FULL1_N069_ST: r_oparam_addr <= 7'h45;
          `FULL1_N070_ST: r_oparam_addr <= 7'h46;`FULL1_N071_ST: r_oparam_addr <= 7'h47;
          `FULL1_N072_ST: r_oparam_addr <= 7'h48;`FULL1_N073_ST: r_oparam_addr <= 7'h49;
          `FULL1_N074_ST: r_oparam_addr <= 7'h4A;`FULL1_N075_ST: r_oparam_addr <= 7'h4B;
          `FULL1_N076_ST: r_oparam_addr <= 7'h4C;`FULL1_N077_ST: r_oparam_addr <= 7'h4D;
          `FULL1_N078_ST: r_oparam_addr <= 7'h4E;`FULL1_N079_ST: r_oparam_addr <= 7'h4F;
          `FULL1_N080_ST: r_oparam_addr <= 7'h50;`FULL1_N081_ST: r_oparam_addr <= 7'h51;
          `FULL1_N082_ST: r_oparam_addr <= 7'h52;`FULL1_N083_ST: r_oparam_addr <= 7'h53;
          `FULL1_N084_ST: r_oparam_addr <= 7'h54;`FULL1_N085_ST: r_oparam_addr <= 7'h55;
          `FULL1_N086_ST: r_oparam_addr <= 7'h56;`FULL1_N087_ST: r_oparam_addr <= 7'h57;
          `FULL1_N088_ST: r_oparam_addr <= 7'h58;`FULL1_N089_ST: r_oparam_addr <= 7'h59;
          `FULL1_N090_ST: r_oparam_addr <= 7'h5A;`FULL1_N091_ST: r_oparam_addr <= 7'h5B;
          `FULL1_N092_ST: r_oparam_addr <= 7'h5C;`FULL1_N093_ST: r_oparam_addr <= 7'h5D;
          `FULL1_N094_ST: r_oparam_addr <= 7'h5E;`FULL1_N095_ST: r_oparam_addr <= 7'h5F;     
          `FULL1_N096_ST: r_oparam_addr <= 7'h60;`FULL1_N097_ST: r_oparam_addr <= 7'h61;
          `FULL1_N098_ST: r_oparam_addr <= 7'h62;`FULL1_N099_ST: r_oparam_addr <= 7'h63;
          `FULL1_N100_ST: r_oparam_addr <= 7'h64;`FULL1_N101_ST: r_oparam_addr <= 7'h65;
          `FULL1_N102_ST: r_oparam_addr <= 7'h66;`FULL1_N103_ST: r_oparam_addr <= 7'h67;
          `FULL1_N104_ST: r_oparam_addr <= 7'h68;`FULL1_N105_ST: r_oparam_addr <= 7'h69;
          `FULL1_N106_ST: r_oparam_addr <= 7'h6A;`FULL1_N107_ST: r_oparam_addr <= 7'h6B;
          `FULL1_N108_ST: r_oparam_addr <= 7'h6C;`FULL1_N109_ST: r_oparam_addr <= 7'h6D;
          `FULL1_N110_ST: r_oparam_addr <= 7'h6E;`FULL1_N111_ST: r_oparam_addr <= 7'h6F;      
          `FULL1_N112_ST: r_oparam_addr <= 7'h70;`FULL1_N113_ST: r_oparam_addr <= 7'h71;
          `FULL1_N114_ST: r_oparam_addr <= 7'h72;`FULL1_N115_ST: r_oparam_addr <= 7'h73;
          `FULL1_N116_ST: r_oparam_addr <= 7'h74;`FULL1_N117_ST: r_oparam_addr <= 7'h75;
          `FULL1_N118_ST: r_oparam_addr <= 7'h76;`FULL1_N119_ST: r_oparam_addr <= 7'h77; 
          default: r_oparam_addr <= 7'd60;
          endcase
       end // else: !if(IRST)
    end // always_ff @
    
    assign OPARAM_ADDR = r_oparam_addr;
    
    assign OST = st;
    //assign FULL1_CMP = (r_end_cyc==END_LEN)? 1 : 0;
endmodule
