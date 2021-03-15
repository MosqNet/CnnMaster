//                              -*- Mode: Verilog -*-
// Filename        : CONV2_CTRL.sv
// Description     : 
// Author          : 
// Created On      : Tue Nov 10 13:20:04 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 18:17:57
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
`define CONV2_IDLE_ST   4'h1
`define CONV2_INIT_ST   4'h2
`define CONV2_U0_ST     4'h4
`define CONV2_U1_ST     4'h5
`define CONV2_U2_ST     4'h6
`define CONV2_U3_ST     4'h7
`define CONV2_U4_ST     4'h8
`define CONV2_U5_ST     4'h9
`define CONV2_END_ST    4'hE
`define CONV2_ERR_ST    4'hF
*/
`include "LENET.vh"

module CONV2_CTRL (
//-- System Commons
input wire IRST,
input wire ICLK,
//-- Input
input wire IINIT,
input wire ISTART,
input wire ILAST,
//-- Output
output wire RELUINIT,
output wire OINIT,
output wire OEN,
output wire [4:0] OPARAM_ADDR,
output wire [3:0] OST,
output wire CONV2_CMP
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
   reg [4:0]  st, nx;
   reg [3:0]  r_init_cyc;
   reg [3:0]  r_end_cyc;
   reg [3:0]  r_u0_cyc;
   reg [3:0]  r_u1_cyc;
   reg [3:0]  r_u2_cyc;
   reg [3:0]  r_u3_cyc;
   reg [3:0]  r_u4_cyc;
   reg [3:0]  r_u5_cyc;
   reg [3:0]  r_u6_cyc;
   reg [3:0]  r_u7_cyc;
   reg [3:0]  r_u8_cyc;
   reg [3:0]  r_u9_cyc;
   reg [3:0]  r_u10_cyc;
   reg [3:0]  r_u11_cyc;
   reg [3:0]  r_u12_cyc;
   reg [3:0]  r_u13_cyc;
   reg [3:0]  r_u14_cyc;
   reg [3:0]  r_u15_cyc;
   reg [3:0]  r_last;

   always @ (posedge ICLK) begin
      if (IRST) r_start <= 1'b0;
      else      r_start <= ISTART;
   end
   wire s_start = ISTART & ~r_start; //-- detect riseing.

   always @ (posedge ICLK) begin
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
        `CONV2_IDLE_ST: if(s_start) nx = `CONV2_INIT_ST;
        `CONV2_INIT_ST: if(r_init_cyc==INIT_LEN) nx = `CONV2_U0_ST;
        `CONV2_U0_ST: if(r_u0_cyc==U0_LEN && s_unit_end) nx = `CONV2_U1_ST;
        `CONV2_U1_ST: if(r_u1_cyc==U1_LEN && s_unit_end) nx = `CONV2_U2_ST;
        `CONV2_U2_ST: if(r_u2_cyc==U2_LEN && s_unit_end) nx = `CONV2_U3_ST;
        `CONV2_U3_ST: if(r_u3_cyc==U3_LEN && s_unit_end) nx = `CONV2_U4_ST;
        `CONV2_U4_ST: if(r_u4_cyc==U4_LEN && s_unit_end) nx = `CONV2_U5_ST;
        `CONV2_U5_ST: if(r_u5_cyc==U5_LEN && s_unit_end) nx = `CONV2_U6_ST;
        `CONV2_U6_ST: if(r_u6_cyc==U6_LEN && s_unit_end) nx = `CONV2_U7_ST;
        `CONV2_U7_ST: if(r_u7_cyc==U7_LEN && s_unit_end) nx = `CONV2_U8_ST;
        `CONV2_U8_ST: if(r_u8_cyc==U8_LEN && s_unit_end) nx = `CONV2_U9_ST;
        `CONV2_U9_ST: if(r_u9_cyc==U9_LEN && s_unit_end) nx = `CONV2_U10_ST;
        `CONV2_U10_ST: if(r_u10_cyc==U10_LEN && s_unit_end) nx = `CONV2_U11_ST;
        `CONV2_U11_ST: if(r_u11_cyc==U11_LEN && s_unit_end) nx = `CONV2_U12_ST;
        `CONV2_U12_ST: if(r_u12_cyc==U12_LEN && s_unit_end) nx = `CONV2_U13_ST;
        `CONV2_U13_ST: if(r_u13_cyc==U13_LEN && s_unit_end) nx = `CONV2_U14_ST;
        `CONV2_U14_ST: if(r_u14_cyc==U14_LEN && s_unit_end) nx = `CONV2_U15_ST;
        `CONV2_U15_ST: if(r_u15_cyc==U15_LEN && s_unit_end) nx = `CONV2_END_ST;
        `CONV2_END_ST: if (r_end_cyc==END_LEN) nx = `CONV2_IDLE_ST;
        `CONV2_ERR_ST: nx = `CONV2_ERR_ST; // stay in error.
        default: begin
           nx = `CONV2_ERR_ST;
        end
      endcase // case (st)
   end // always_comb
   always_ff @ (posedge ICLK) begin
      if (IRST)       st <= `CONV2_IDLE_ST;
      else if (IINIT) st <= `CONV2_IDLE_ST;
      else            st <= nx;
   end
   /*
    * r_init_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST) r_init_cyc <= 4'd0;
      else if (st==`CONV2_IDLE_ST) r_init_cyc <= 4'd0;
      else if (st==`CONV2_INIT_ST) r_init_cyc <= r_init_cyc + 4'd1;
   end
   /*
    * r_end_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST) r_end_cyc <= 4'd0;
      else if (st==`CONV2_IDLE_ST) r_end_cyc <= 4'd0;
      else if (st==`CONV2_END_ST) r_end_cyc <= r_end_cyc + 4'd1;
   end
   /*
    * r_u*_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u0_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u0_cyc <= 4'h0;
      else if (st==`CONV2_U0_ST)   r_u0_cyc <= (r_u0_cyc==4'hF)? 4'hF : (r_u0_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u1_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u1_cyc <= 4'h0;
      else if (st==`CONV2_U1_ST)   r_u1_cyc <= (r_u1_cyc==4'hF)? 4'hF : (r_u1_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u2_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u2_cyc <= 4'h0;
      else if (st==`CONV2_U2_ST)   r_u2_cyc <= (r_u2_cyc==4'hF)? 4'hF : (r_u2_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u3_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u3_cyc <= 4'h0;
      else if (st==`CONV2_U3_ST)   r_u3_cyc <= (r_u3_cyc==4'hF)? 4'hF : (r_u3_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u4_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u4_cyc <= 4'h0;
      else if (st==`CONV2_U4_ST)   r_u4_cyc <= (r_u4_cyc==4'hF)? 4'hF : (r_u4_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u5_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u5_cyc <= 4'h0;
      else if (st==`CONV2_U5_ST)   r_u5_cyc <= (r_u5_cyc==4'hF)? 4'hF : (r_u5_cyc + 4'h1);
   end
   
      always_ff @(posedge ICLK) begin
      if (IRST)                    r_u6_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u6_cyc <= 4'h0;
      else if (st==`CONV2_U6_ST)   r_u6_cyc <= (r_u6_cyc==4'hF)? 4'hF : (r_u6_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u7_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u7_cyc <= 4'h0;
      else if (st==`CONV2_U7_ST)   r_u7_cyc <= (r_u7_cyc==4'hF)? 4'hF : (r_u7_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u8_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u8_cyc <= 4'h0;
      else if (st==`CONV2_U8_ST)   r_u8_cyc <= (r_u8_cyc==4'hF)? 4'hF : (r_u8_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u9_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u9_cyc <= 4'h0;
      else if (st==`CONV2_U9_ST)   r_u9_cyc <= (r_u9_cyc==4'hF)? 4'hF : (r_u9_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u10_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u10_cyc <= 4'h0;
      else if (st==`CONV2_U10_ST)   r_u10_cyc <= (r_u10_cyc==4'hF)? 4'hF : (r_u10_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u11_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u11_cyc <= 4'h0;
      else if (st==`CONV2_U11_ST)   r_u11_cyc <= (r_u11_cyc==4'hF)? 4'hF : (r_u11_cyc + 4'h1);
   end
      always_ff @(posedge ICLK) begin
      if (IRST)                    r_u12_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u12_cyc <= 4'h0;
      else if (st==`CONV2_U12_ST)   r_u12_cyc <= (r_u12_cyc==4'hF)? 4'hF : (r_u12_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u13_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u13_cyc <= 4'h0;
      else if (st==`CONV2_U13_ST)   r_u13_cyc <= (r_u13_cyc==4'hF)? 4'hF : (r_u13_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u14_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u14_cyc <= 4'h0;
      else if (st==`CONV2_U14_ST)   r_u14_cyc <= (r_u14_cyc==4'hF)? 4'hF : (r_u14_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u15_cyc <= 4'h0;
      else if (st==`CONV2_INIT_ST) r_u15_cyc <= 4'h0;
      else if (st==`CONV2_U15_ST)   r_u15_cyc <= (r_u15_cyc==4'hF)? 4'hF : (r_u15_cyc + 4'h1);
   end
   /*
    * OINIT
    */
    
    reg r_oinit;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_oinit <= 1'b0;
      else begin
         case(st)
           `CONV2_U0_ST: r_oinit <= (r_u0_cyc==4'h1);
           `CONV2_U1_ST: r_oinit <= (r_u1_cyc==4'h1);
           `CONV2_U2_ST: r_oinit <= (r_u2_cyc==4'h1);
           `CONV2_U3_ST: r_oinit <= (r_u3_cyc==4'h1);
           `CONV2_U4_ST: r_oinit <= (r_u4_cyc==4'h1);
           `CONV2_U5_ST: r_oinit <= (r_u5_cyc==4'h1);
           `CONV2_U6_ST: r_oinit <= (r_u6_cyc==4'h1);
           `CONV2_U7_ST: r_oinit <= (r_u7_cyc==4'h1);
           `CONV2_U8_ST: r_oinit <= (r_u8_cyc==4'h1);
           `CONV2_U9_ST: r_oinit <= (r_u9_cyc==4'h1);
           `CONV2_U10_ST: r_oinit <= (r_u10_cyc==4'h1);
           `CONV2_U11_ST: r_oinit <= (r_u11_cyc==4'h1);
           `CONV2_U12_ST: r_oinit <= (r_u12_cyc==4'h1);
           `CONV2_U13_ST: r_oinit <= (r_u13_cyc==4'h1);
           `CONV2_U14_ST: r_oinit <= (r_u14_cyc==4'h1);
           `CONV2_U15_ST: r_oinit <= (r_u15_cyc==4'h1);
           default: r_oinit <= 1'b0;
         endcase // case (st)
      end // else: !if(IRST)
   end // always_ff @
   
   assign OINIT = r_oinit;
   
   /*
    * OEN
    */
    
    reg r_oen;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_oen <= 1'b0;
      else begin
         case(st)
           `CONV2_U0_ST: begin
              if (r_u0_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U1_ST: begin
              if (r_u1_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U2_ST: begin
              if (r_u2_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U3_ST: begin
              if (r_u3_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U4_ST: begin
              if (r_u4_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U5_ST: begin
              if (r_u5_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV2_U6_ST: begin
             if (r_u6_cyc==4'h3) r_oen <= 1'b1;
             else if (ILAST)     r_oen <= 1'b0;
           end
          `CONV2_U7_ST: begin
             if (r_u7_cyc==4'h3) r_oen <= 1'b1;
             else if (ILAST)     r_oen <= 1'b0;
          end
          `CONV2_U8_ST: begin
             if (r_u8_cyc==4'h3) r_oen <= 1'b1;
             else if (ILAST)     r_oen <= 1'b0;
          end
          `CONV2_U9_ST: begin
             if (r_u9_cyc==4'h3) r_oen <= 1'b1;
             else if (ILAST)     r_oen <= 1'b0;
          end
          `CONV2_U10_ST: begin
             if (r_u10_cyc==4'h3) r_oen <= 1'b1;
             else if (ILAST)     r_oen <= 1'b0;
          end
           `CONV2_U11_ST: begin
                if (r_u11_cyc==4'h3) r_oen <= 1'b1;
                else if (ILAST)     r_oen <= 1'b0;
             end
            `CONV2_U12_ST: begin
                if (r_u12_cyc==4'h3) r_oen <= 1'b1;
                else if (ILAST)     r_oen <= 1'b0;
            end
         `CONV2_U13_ST: begin
            if (r_u13_cyc==4'h3) r_oen <= 1'b1;
            else if (ILAST)     r_oen <= 1'b0;
         end
         `CONV2_U14_ST: begin
            if (r_u14_cyc==4'h3) r_oen <= 1'b1;
            else if (ILAST)     r_oen <= 1'b0;
         end
         `CONV2_U15_ST: begin
            if (r_u15_cyc==4'h3) r_oen <= 1'b1;
            else if (ILAST)     r_oen <= 1'b0;                 
           end
           default: r_oen <= 1'b0;
         endcase // case (st)
      end // else: !if(IRST)
   end // always_ff @
   
   assign OEN = r_oen;
   
   /*
    * Switch U* weight and bias parameters.
    */
    
    reg [4:0] r_oparam_addr;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_oparam_addr <= 5'h1F;
      else begin
         case(st)
           `CONV2_U0_ST: r_oparam_addr <= 4'h0;
           `CONV2_U1_ST: r_oparam_addr <= 4'h1;
           `CONV2_U2_ST: r_oparam_addr <= 4'h2;
           `CONV2_U3_ST: r_oparam_addr <= 4'h3;
           `CONV2_U4_ST: r_oparam_addr <= 4'h4;
           `CONV2_U5_ST: r_oparam_addr <= 4'h5;
           `CONV2_U6_ST: r_oparam_addr <= 4'h6;
           `CONV2_U7_ST: r_oparam_addr <= 4'h7;
           `CONV2_U8_ST: r_oparam_addr <= 4'h8;
           `CONV2_U9_ST: r_oparam_addr <= 4'h9;
           `CONV2_U10_ST: r_oparam_addr <= 4'hA;
           `CONV2_U11_ST: r_oparam_addr <= 4'hB;
           `CONV2_U12_ST: r_oparam_addr <= 4'hC;
           `CONV2_U13_ST: r_oparam_addr <= 4'hD;
           `CONV2_U14_ST: r_oparam_addr <= 4'hE;
           `CONV2_U15_ST: r_oparam_addr <= 4'hF;
           default: r_oparam_addr <= 5'h1F;
         endcase
      end // else: !if(IRST)
   end // always_ff @
   
   assign OPARAM_ADDR = r_oparam_addr;
   
   reg r_first;
   
   always_ff @ (posedge ICLK) begin
      if (IRST)                    r_first <= 0;
      else if (st==`CONV2_INIT_ST) r_first <= 0;
      else if (st==`CONV2_U0_ST)   r_first <= 1;
      else if (st==`CONV2_END_ST) r_first <= 0;
   end
   
   reg [5:0] d_first; //
   
   
   always_ff @(posedge ICLK)begin
      d_first <= {d_first[4:0],r_first};
   end
   
   assign RELUINIT = d_first[5];

   assign OST = st;
   assign CONV2_CMP = (st==`CONV2_END_ST)? 1 : 0;
   
endmodule // CONV2_CTRL
