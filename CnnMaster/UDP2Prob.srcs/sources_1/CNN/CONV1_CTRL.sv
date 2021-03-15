//                              -*- Mode: Verilog -*-
// Filename        : CONV1_CTRL.sv
// Description     : 
// Author          : 
// Created On      : Tue Nov 10 13:20:04 2020
// Last Modified By: 
// Last Modified On: 2020-11-11 18:17:57
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "LENET.vh"

module CONV1_CTRL (
    //-- System common
    input wire ICLK,
    input wire IRST,
    //-- Input
    input wire IINIT,
    input wire ISTART,
    input wire ILAST,
    //-- Output
    output wire CONV1_CMP,
    output wire OINIT,
    output wire OEN,
    output wire [3:0] OPARAM_ADDR,
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

   reg        r_start;
   reg [3:0]  st, nx;
   reg [3:0]  r_init_cyc;
   reg [3:0]  r_end_cyc;
   reg [3:0]  r_u0_cyc;
   reg [3:0]  r_u1_cyc;
   reg [3:0]  r_u2_cyc;
   reg [3:0]  r_u3_cyc;
   reg [3:0]  r_u4_cyc;
   reg [3:0]  r_u5_cyc;
   reg [3:0]  r_last;

   reg [1:0] d_ISTART;
   always_ff @(posedge ICLK)begin
      d_ISTART <= {d_ISTART[0],ISTART};
   end

   always_ff @ (posedge ICLK) begin
      if (IRST) r_start <= 1'b0;
      else      r_start <= d_ISTART[1];
   end
   wire s_start = d_ISTART[1] & ~r_start; //-- detect riseing.

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
        `CONV1_IDLE_ST: if(s_start) nx = `CONV1_INIT_ST;
        `CONV1_INIT_ST: if(r_init_cyc==INIT_LEN) nx = `CONV1_U0_ST;
        `CONV1_U0_ST: if(r_u0_cyc==U0_LEN && s_unit_end) nx = `CONV1_U1_ST;
        `CONV1_U1_ST: if(r_u1_cyc==U1_LEN && s_unit_end) nx = `CONV1_U2_ST;
        `CONV1_U2_ST: if(r_u2_cyc==U2_LEN && s_unit_end) nx = `CONV1_U3_ST;
        `CONV1_U3_ST: if(r_u3_cyc==U3_LEN && s_unit_end) nx = `CONV1_U4_ST;
        `CONV1_U4_ST: if(r_u4_cyc==U4_LEN && s_unit_end) nx = `CONV1_U5_ST;
        `CONV1_U5_ST: if(r_u5_cyc==U5_LEN && s_unit_end) nx = `CONV1_END_ST;
        `CONV1_END_ST: if (r_end_cyc==END_LEN) nx = `CONV1_IDLE_ST;
        `CONV1_ERR_ST: nx = `CONV1_ERR_ST; // stay in error.
        default: begin
           nx = `CONV1_ERR_ST;
        end
      endcase // case (st)
   end // always_comb
   always_ff @ (posedge ICLK) begin
      if (IRST)       st <= `CONV1_IDLE_ST;
      else if (IINIT) st <= `CONV1_IDLE_ST;
      else            st <= nx;
   end
   /*
    * r_init_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST) r_init_cyc <= 4'd0;
      else if (st==`CONV1_IDLE_ST) r_init_cyc <= 4'd0;
      else if (st==`CONV1_INIT_ST) r_init_cyc <= r_init_cyc + 4'd1;
   end
   /*
    * r_end_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST) r_end_cyc <= 4'd0;
      else if (st==`CONV1_IDLE_ST) r_end_cyc <= 4'd0;
      else if (st==`CONV1_END_ST) r_end_cyc <= r_end_cyc + 4'd1;
   end
   /*
    * r_u*_cyc[]
    */
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u0_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u0_cyc <= 4'h0;
      else if (st==`CONV1_U0_ST)   r_u0_cyc <= (r_u0_cyc==4'hF)? 4'hF : (r_u0_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u1_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u1_cyc <= 4'h0;
      else if (st==`CONV1_U1_ST)   r_u1_cyc <= (r_u1_cyc==4'hF)? 4'hF : (r_u1_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u2_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u2_cyc <= 4'h0;
      else if (st==`CONV1_U2_ST)   r_u2_cyc <= (r_u2_cyc==4'hF)? 4'hF : (r_u2_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u3_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u3_cyc <= 4'h0;
      else if (st==`CONV1_U3_ST)   r_u3_cyc <= (r_u3_cyc==4'hF)? 4'hF : (r_u3_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u4_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u4_cyc <= 4'h0;
      else if (st==`CONV1_U4_ST)   r_u4_cyc <= (r_u4_cyc==4'hF)? 4'hF : (r_u4_cyc + 4'h1);
   end
   always_ff @(posedge ICLK) begin
      if (IRST)                    r_u5_cyc <= 4'h0;
      else if (st==`CONV1_INIT_ST) r_u5_cyc <= 4'h0;
      else if (st==`CONV1_U5_ST)   r_u5_cyc <= (r_u5_cyc==4'hF)? 4'hF : (r_u5_cyc + 4'h1);
   end
   
   /*
    * OINIT
    */
    
    reg r_oinit;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_oinit <= 1'b0;
      else begin
         case(st)
           `CONV1_U0_ST: r_oinit <= (r_u0_cyc==4'h1);
           `CONV1_U1_ST: r_oinit <= (r_u1_cyc==4'h1);
           `CONV1_U2_ST: r_oinit <= (r_u2_cyc==4'h1);
           `CONV1_U3_ST: r_oinit <= (r_u3_cyc==4'h1);
           `CONV1_U4_ST: r_oinit <= (r_u4_cyc==4'h1);
           `CONV1_U5_ST: r_oinit <= (r_u5_cyc==4'h1);
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
           `CONV1_U0_ST: begin
              if (r_u0_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV1_U1_ST: begin
              if (r_u1_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV1_U2_ST: begin
              if (r_u2_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV1_U3_ST: begin
              if (r_u3_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV1_U4_ST: begin
              if (r_u4_cyc==4'h3) r_oen <= 1'b1;
              else if (ILAST)     r_oen <= 1'b0;
           end
           `CONV1_U5_ST: begin
              if (r_u5_cyc==4'h3) r_oen <= 1'b1;
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
    
    reg [3:0] r_oparam_addr;
    
   always_ff @ (posedge ICLK) begin
      if (IRST) r_oparam_addr <= 4'hF;
      else begin
         case(st)
           `CONV1_U0_ST: r_oparam_addr <= 4'h0;
           `CONV1_U1_ST: r_oparam_addr <= 4'h1;
           `CONV1_U2_ST: r_oparam_addr <= 4'h2;
           `CONV1_U3_ST: r_oparam_addr <= 4'h3;
           `CONV1_U4_ST: r_oparam_addr <= 4'h4;
           `CONV1_U5_ST: r_oparam_addr <= 4'h5;
           default: r_oparam_addr <= 4'hF;
         endcase
      end // else: !if(IRST)
   end // always_ff @
   
   assign OPARAM_ADDR = r_oparam_addr;

   assign OST = st;
   assign CONV1_CMP = (st ==`CONV1_END_ST)? 1 : 0;
   //assign CNN_START = (st ==`CONV1_U0_ST)? 1 : 0;
   
endmodule // CONV1_CTRL

