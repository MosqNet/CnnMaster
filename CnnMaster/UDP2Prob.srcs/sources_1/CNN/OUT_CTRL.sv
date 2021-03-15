`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 19:58:20
// Design Name: 
// Module Name: OUT_CTRL
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

module OUT_CTRL(
//--System commons
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
output wire [3:0] OST,
output wire OUT_CMP
);
    
   localparam [3:0] INIT_LEN = 4'd4;
   localparam [3:0] END_LEN  = 4'd9;
   localparam [4:0] SEND_UDP_LEN = 5'd8;
    
   reg        r_start;
   reg [7:0]  st, nx;
   reg [3:0]  r_init_cyc;
   reg [3:0]  r_end_cyc;
   reg [4:0] send_udp_cyc;
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
         `OUT_IDLE_ST: if(s_start) nx = `OUT_INIT_ST;
         `OUT_INIT_ST: if(r_init_cyc==INIT_LEN) nx = `OUT_N00_ST;
         `OUT_N00_ST: nx = `OUT_N01_ST;
         `OUT_N01_ST: nx = `OUT_N02_ST;
         `OUT_N02_ST: nx = `OUT_N03_ST;
         `OUT_N03_ST: nx = `OUT_N04_ST;
         `OUT_N04_ST: nx = `OUT_N05_ST;
         `OUT_N05_ST: nx = `OUT_N06_ST;
         `OUT_N06_ST: nx = `OUT_N07_ST;
         `OUT_N07_ST: nx = `OUT_N08_ST;
         `OUT_N08_ST: nx = `OUT_N09_ST;
         `OUT_N09_ST: nx = `OUT_END_ST;
         `OUT_END_ST: if (r_end_cyc==END_LEN) nx = `SEND_UDP_ST;
         `SEND_UDP_ST : if(send_udp_cyc == SEND_UDP_LEN) nx = `OUT_IDLE_ST;
         `OUT_ERR_ST: nx = `OUT_ERR_ST; // stay in error.
         default: begin
            nx = `OUT_ERR_ST;
         end
       endcase // case (st)
    end // always_comb
    
    
    always_ff @ (posedge ICLK) begin
       if (IRST)       st <= `OUT_IDLE_ST;
       else if (IINIT) st <= `OUT_IDLE_ST;
       else            st <= nx;
    end
    /*
     * r_init_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_init_cyc <= 4'd0;
       else if (st==`OUT_IDLE_ST) r_init_cyc <= 4'd0;
       else if (st==`OUT_INIT_ST) r_init_cyc <= r_init_cyc + 4'd1;
    end
    /*
     * r_end_cyc[]
     */
    always_ff @(posedge ICLK) begin
       if (IRST) r_end_cyc <= 4'd0;
       else if (st==`OUT_IDLE_ST) r_end_cyc <= 4'd0;
       else if (st==`OUT_END_ST) r_end_cyc <= r_end_cyc + 4'd1;
    end
    
     /*
     * send_udp_cyc
     */
    always_ff @(posedge ICLK) begin
        if (IRST) send_udp_cyc <= 4'd0;
        else if (st==`OUT_IDLE_ST) send_udp_cyc <= 4'd0;
        else if (st==`SEND_UDP_ST) send_udp_cyc <= send_udp_cyc + 4'd1;
     end
    
    
    always_ff @ (posedge ICLK) begin
       if (IRST)                    r_first <= 0;
       else if (st==`OUT_INIT_ST) r_first <= 0;
       else if (st==`OUT_N00_ST)  r_first <= 1;
       else if (st==`OUT_END_ST)  r_first <= 0;
    end
    
    reg [8:0] d_first; //
    always_ff @(posedge ICLK)begin
       if(IRST) d_first <= 9'b0;
       else d_first <= {d_first[7:0],r_first};
    end  
    assign OINIT = d_first[8];
    
    /*
     * Address control logic at OUT
     */
     
     reg [7:0] r_oparams_addr;
     
    always_ff @ (posedge ICLK) begin
       if (IRST) r_oparams_addr <= 5'h8F;
       else begin
          case(st)
            `OUT_N00_ST: r_oparams_addr <= 7'h0;
            `OUT_N01_ST: r_oparams_addr <= 7'h1;
            `OUT_N02_ST: r_oparams_addr <= 7'h2;
            `OUT_N03_ST: r_oparams_addr <= 7'h3;
            `OUT_N04_ST: r_oparams_addr <= 7'h4;
            `OUT_N05_ST: r_oparams_addr <= 7'h5;
            `OUT_N06_ST: r_oparams_addr <= 7'h6; 
            `OUT_N07_ST: r_oparams_addr <= 7'h7;
            `OUT_N08_ST: r_oparams_addr <= 7'h8;
            `OUT_N09_ST: r_oparams_addr <= 7'h9;
            default: r_oparams_addr <= 7'd60;
          endcase
       end // else: !if(IRST)
    end // always_ff @
    
    assign OPARAM_ADDR = r_oparams_addr;
    
    assign OST = st;
    assign OUT_CMP = (st==`SEND_UDP_ST) ? 1 : 0;
endmodule

