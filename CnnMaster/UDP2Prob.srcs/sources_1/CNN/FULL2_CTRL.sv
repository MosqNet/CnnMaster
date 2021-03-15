`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/01 15:43:39
// Design Name: 
// Module Name: FULL2_CTRL
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

module FULL2_CTRL(
//-- System commons
input wire IRST,
input wire ICLK,
//-- Input
input wire IINIT,
input wire ISTART,
input wire ILAST,
//-- Output
output wire OINIT,
output wire OEN,
output wire [7:0] OPARAM_ADDR,
output wire [3:0] OST
);
    
   localparam [3:0] INIT_LEN = 4'd4;
   localparam [3:0] END_LEN  = 4'd5;
    
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
    
    always_ff @ (posedge ICLK) begin
       if (IRST)               r_last <= 4'hF;
       if (IINIT || ILAST)     r_last <= 4'hF;
       else if (r_last > 4'h0) r_last <= r_last - 4'h1;
    end
    wire s_unit_end = (r_last == 4'h1);
    /*
     * FSM
     */
    always_comb begin
       nx = st; //-- default hold current state.
       case (st) 
         `FULL2_IDLE_ST: if(s_start) nx = `FULL2_INIT_ST;
         `FULL2_INIT_ST: if(r_init_cyc==INIT_LEN) nx = `FULL2_N00_ST;
         `FULL2_N00_ST: nx = `FULL2_N01_ST;`FULL2_N01_ST: nx = `FULL2_N02_ST;
         `FULL2_N02_ST: nx = `FULL2_N03_ST;`FULL2_N03_ST: nx = `FULL2_N04_ST;
         `FULL2_N04_ST: nx = `FULL2_N05_ST;`FULL2_N05_ST: nx = `FULL2_N06_ST;
         `FULL2_N06_ST: nx = `FULL2_N07_ST;`FULL2_N07_ST: nx = `FULL2_N08_ST;
         `FULL2_N08_ST: nx = `FULL2_N09_ST;`FULL2_N09_ST: nx = `FULL2_N10_ST;
         `FULL2_N10_ST: nx = `FULL2_N11_ST;`FULL2_N11_ST: nx = `FULL2_N12_ST;
         `FULL2_N12_ST: nx = `FULL2_N13_ST;`FULL2_N13_ST: nx = `FULL2_N14_ST;
         `FULL2_N14_ST: nx = `FULL2_N15_ST;`FULL2_N15_ST: nx = `FULL2_N16_ST;
         `FULL2_N16_ST: nx = `FULL2_N17_ST;`FULL2_N17_ST: nx = `FULL2_N18_ST;
         `FULL2_N18_ST: nx = `FULL2_N19_ST;`FULL2_N19_ST: nx = `FULL2_N20_ST;
         `FULL2_N20_ST: nx = `FULL2_N21_ST;`FULL2_N21_ST: nx = `FULL2_N22_ST;
         `FULL2_N22_ST: nx = `FULL2_N23_ST;`FULL2_N23_ST: nx = `FULL2_N24_ST;
         `FULL2_N24_ST: nx = `FULL2_N25_ST;`FULL2_N25_ST: nx = `FULL2_N26_ST;
         `FULL2_N26_ST: nx = `FULL2_N27_ST;`FULL2_N27_ST: nx = `FULL2_N28_ST;
         `FULL2_N28_ST: nx = `FULL2_N29_ST;`FULL2_N29_ST: nx = `FULL2_N30_ST;
         `FULL2_N30_ST: nx = `FULL2_N31_ST;`FULL2_N31_ST: nx = `FULL2_N32_ST;
         `FULL2_N32_ST: nx = `FULL2_N33_ST;`FULL2_N33_ST: nx = `FULL2_N34_ST;
         `FULL2_N34_ST: nx = `FULL2_N35_ST;`FULL2_N35_ST: nx = `FULL2_N36_ST;
         `FULL2_N36_ST: nx = `FULL2_N37_ST;`FULL2_N37_ST: nx = `FULL2_N38_ST;
         `FULL2_N38_ST: nx = `FULL2_N39_ST;`FULL2_N39_ST: nx = `FULL2_N40_ST;
         `FULL2_N40_ST: nx = `FULL2_N41_ST;`FULL2_N41_ST: nx = `FULL2_N42_ST;
         `FULL2_N42_ST: nx = `FULL2_N43_ST;`FULL2_N43_ST: nx = `FULL2_N44_ST;
         `FULL2_N44_ST: nx = `FULL2_N45_ST;`FULL2_N45_ST: nx = `FULL2_N46_ST;
         `FULL2_N46_ST: nx = `FULL2_N47_ST;`FULL2_N47_ST: nx = `FULL2_N48_ST;
         `FULL2_N48_ST: nx = `FULL2_N49_ST;`FULL2_N49_ST: nx = `FULL2_N50_ST;
         `FULL2_N50_ST: nx = `FULL2_N51_ST;`FULL2_N51_ST: nx = `FULL2_N52_ST;
         `FULL2_N52_ST: nx = `FULL2_N53_ST;`FULL2_N53_ST: nx = `FULL2_N54_ST;
         `FULL2_N54_ST: nx = `FULL2_N55_ST;`FULL2_N55_ST: nx = `FULL2_N56_ST;
         `FULL2_N56_ST: nx = `FULL2_N57_ST;`FULL2_N57_ST: nx = `FULL2_N58_ST;
         `FULL2_N58_ST: nx = `FULL2_N59_ST;`FULL2_N59_ST: nx = `FULL2_N60_ST;
         `FULL2_N60_ST: nx = `FULL2_N61_ST;`FULL2_N61_ST: nx = `FULL2_N62_ST;
         `FULL2_N62_ST: nx = `FULL2_N63_ST;`FULL2_N63_ST: nx = `FULL2_N64_ST;
         `FULL2_N64_ST: nx = `FULL2_N65_ST;`FULL2_N65_ST: nx = `FULL2_N66_ST;
         `FULL2_N66_ST: nx = `FULL2_N67_ST;`FULL2_N67_ST: nx = `FULL2_N68_ST;
         `FULL2_N68_ST: nx = `FULL2_N69_ST;`FULL2_N69_ST: nx = `FULL2_N70_ST;
         `FULL2_N70_ST: nx = `FULL2_N71_ST;`FULL2_N71_ST: nx = `FULL2_N72_ST;
         `FULL2_N72_ST: nx = `FULL2_N73_ST;`FULL2_N73_ST: nx = `FULL2_N74_ST;
         `FULL2_N74_ST: nx = `FULL2_N75_ST;`FULL2_N75_ST: nx = `FULL2_N76_ST;
         `FULL2_N76_ST: nx = `FULL2_N77_ST;`FULL2_N77_ST: nx = `FULL2_N78_ST;
         `FULL2_N78_ST: nx = `FULL2_N79_ST;`FULL2_N79_ST: nx = `FULL2_N80_ST;
         `FULL2_N80_ST: nx = `FULL2_N81_ST;`FULL2_N81_ST: nx = `FULL2_N82_ST;
         `FULL2_N82_ST: nx = `FULL2_N83_ST;`FULL2_N83_ST: nx = `FULL2_END_ST;
         `FULL2_END_ST: if (r_end_cyc==END_LEN) nx = `FULL2_IDLE_ST;
         `FULL2_ERR_ST: nx = `FULL2_ERR_ST; // stay in error.
         default: begin
            nx = `FULL2_ERR_ST;
         end
       endcase // case (st)
    end // always_comb
    
    
    always_ff @ (posedge ICLK) begin
       if (IRST)       st <= `FULL2_IDLE_ST;
       else if (IINIT) st <= `FULL2_IDLE_ST;
       else            st <= nx;
    end
    /*
     * r_init_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_init_cyc <= 4'd0;
       else if (st==`FULL2_IDLE_ST) r_init_cyc <= 4'd0;
       else if (st==`FULL2_INIT_ST) r_init_cyc <= r_init_cyc + 4'd1;
    end
    /*
     * r_end_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_end_cyc <= 4'd0;
       else if (st==`FULL2_IDLE_ST) r_end_cyc <= 4'd0;
       else if (st==`FULL2_END_ST) r_end_cyc <= r_end_cyc + 4'd1;
    end
    
    always_ff @ (posedge ICLK) begin
       if (IRST)                    r_first <= 0;
       else if (st==`FULL2_INIT_ST) r_first <= 0;
       else if (st==`FULL2_N00_ST)  r_first <= 1;
       else if (st==`FULL2_END_ST)  r_first <= 0;
    end
    
    (*dont_touch="true"*) reg [7:0] d_first; //
    always_ff @(posedge ICLK)begin
       if(IRST)   d_first <= 8'd0;
       else d_first <= {d_first[6:0],r_first};
    end
    
    assign OINIT = d_first[7];
    
    /*
     * Address control logic at FULL2
     */
     
     reg [7:0] r_oparam_addr;
     
    always_ff @ (posedge ICLK) begin
        if (IRST) r_oparam_addr <= 5'h8F;
        else begin
           case(st)
             `FULL2_N00_ST: r_oparam_addr <= 7'h0; `FULL2_N01_ST: r_oparam_addr <= 7'h1;
             `FULL2_N02_ST: r_oparam_addr <= 7'h2; `FULL2_N03_ST: r_oparam_addr <= 7'h3;
             `FULL2_N04_ST: r_oparam_addr <= 7'h4; `FULL2_N05_ST: r_oparam_addr <= 7'h5;
             `FULL2_N06_ST: r_oparam_addr <= 7'h6; `FULL2_N07_ST: r_oparam_addr <= 7'h7;
             `FULL2_N08_ST: r_oparam_addr <= 7'h8; `FULL2_N09_ST: r_oparam_addr <= 7'h9;
             `FULL2_N10_ST: r_oparam_addr <= 7'hA; `FULL2_N11_ST: r_oparam_addr <= 7'hB;
             `FULL2_N12_ST: r_oparam_addr <= 7'hC; `FULL2_N13_ST: r_oparam_addr <= 7'hD;
             `FULL2_N14_ST: r_oparam_addr <= 7'hE; `FULL2_N15_ST: r_oparam_addr <= 7'hF;
             `FULL2_N16_ST: r_oparam_addr <= 7'h10;`FULL2_N17_ST: r_oparam_addr <= 7'h11;
             `FULL2_N18_ST: r_oparam_addr <= 7'h12;`FULL2_N19_ST: r_oparam_addr <= 7'h13;
             `FULL2_N20_ST: r_oparam_addr <= 7'h14;`FULL2_N21_ST: r_oparam_addr <= 7'h15;
             `FULL2_N22_ST: r_oparam_addr <= 7'h16;`FULL2_N23_ST: r_oparam_addr <= 7'h17;
             `FULL2_N24_ST: r_oparam_addr <= 7'h18;`FULL2_N25_ST: r_oparam_addr <= 7'h19;
             `FULL2_N26_ST: r_oparam_addr <= 7'h1A;`FULL2_N27_ST: r_oparam_addr <= 7'h1B;
             `FULL2_N28_ST: r_oparam_addr <= 7'h1C;`FULL2_N29_ST: r_oparam_addr <= 7'h1D;
             `FULL2_N30_ST: r_oparam_addr <= 7'h1E;`FULL2_N31_ST: r_oparam_addr <= 7'h1F;
             `FULL2_N32_ST: r_oparam_addr <= 7'h20;`FULL2_N33_ST: r_oparam_addr <= 7'h21;
             `FULL2_N34_ST: r_oparam_addr <= 7'h22;`FULL2_N35_ST: r_oparam_addr <= 7'h23;
             `FULL2_N36_ST: r_oparam_addr <= 7'h24;`FULL2_N37_ST: r_oparam_addr <= 7'h25;
             `FULL2_N38_ST: r_oparam_addr <= 7'h26;`FULL2_N39_ST: r_oparam_addr <= 7'h27;
             `FULL2_N40_ST: r_oparam_addr <= 7'h28;`FULL2_N41_ST: r_oparam_addr <= 7'h29;
             `FULL2_N42_ST: r_oparam_addr <= 7'h2A;`FULL2_N43_ST: r_oparam_addr <= 7'h2B;
             `FULL2_N44_ST: r_oparam_addr <= 7'h2C;`FULL2_N45_ST: r_oparam_addr <= 7'h2D;
             `FULL2_N46_ST: r_oparam_addr <= 7'h2E;`FULL2_N47_ST: r_oparam_addr <= 7'h2F;
             `FULL2_N48_ST: r_oparam_addr <= 7'h30;`FULL2_N49_ST: r_oparam_addr <= 7'h31;
             `FULL2_N50_ST: r_oparam_addr <= 7'h32;`FULL2_N51_ST: r_oparam_addr <= 7'h33;
             `FULL2_N52_ST: r_oparam_addr <= 7'h34;`FULL2_N53_ST: r_oparam_addr <= 7'h35;
             `FULL2_N54_ST: r_oparam_addr <= 7'h36;`FULL2_N55_ST: r_oparam_addr <= 7'h37;
             `FULL2_N56_ST: r_oparam_addr <= 7'h38;`FULL2_N57_ST: r_oparam_addr <= 7'h39;
             `FULL2_N58_ST: r_oparam_addr <= 7'h3A;`FULL2_N59_ST: r_oparam_addr <= 7'h3B;
             `FULL2_N60_ST: r_oparam_addr <= 7'h3C;`FULL2_N61_ST: r_oparam_addr <= 7'h3D;
             `FULL2_N62_ST: r_oparam_addr <= 7'h3E;`FULL2_N63_ST: r_oparam_addr <= 7'h3F;
             `FULL2_N64_ST: r_oparam_addr <= 7'h40;`FULL2_N65_ST: r_oparam_addr <= 7'h41;
             `FULL2_N66_ST: r_oparam_addr <= 7'h42;`FULL2_N67_ST: r_oparam_addr <= 7'h43;
             `FULL2_N68_ST: r_oparam_addr <= 7'h44;`FULL2_N69_ST: r_oparam_addr <= 7'h45;
             `FULL2_N70_ST: r_oparam_addr <= 7'h46;`FULL2_N71_ST: r_oparam_addr <= 7'h47;
             `FULL2_N72_ST: r_oparam_addr <= 7'h48;`FULL2_N73_ST: r_oparam_addr <= 7'h49;
             `FULL2_N74_ST: r_oparam_addr <= 7'h4A;`FULL2_N75_ST: r_oparam_addr <= 7'h4B;
             `FULL2_N76_ST: r_oparam_addr <= 7'h4C;`FULL2_N77_ST: r_oparam_addr <= 7'h4D;
             `FULL2_N78_ST: r_oparam_addr <= 7'h4E;`FULL2_N79_ST: r_oparam_addr <= 7'h4F;
             `FULL2_N80_ST: r_oparam_addr <= 7'h50;`FULL2_N81_ST: r_oparam_addr <= 7'h51;
             `FULL2_N82_ST: r_oparam_addr <= 7'h52;`FULL2_N83_ST: r_oparam_addr <= 7'h53;
             default: r_oparam_addr <= 7'd60;
           endcase
        end // else: !if(IRST)
     end // always_ff @
     
    assign OPARAM_ADDR = r_oparam_addr;
    
    assign OST = st;
    //assign FULL2_CMP = (r_end_cyc==END_LEN)? 1 : 0;
endmodule
