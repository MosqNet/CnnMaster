`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 18:42:33
// Design Name: 
// Module Name: FULL1_RDPARAMS
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


module FULL1_RDPARAMS(
    input wire  IRST,
    input wire  ICLK,
    input wire  full1_bias_delay_sig,
    input wire  [7:0]  full1_params_addr,
    output wire [31:0] full1_bias_dout,
    output wire [255:0] full1_params00_dout,
    output wire [255:0] full1_params01_dout,
    output wire [255:0] full1_params02_dout,
    output wire [255:0] full1_params03_dout,
    output wire [255:0] full1_params04_dout,
    output wire [255:0] full1_params05_dout,
    output wire [255:0] full1_params06_dout,
    output wire [255:0] full1_params07_dout,
    output wire [255:0] full1_params08_dout,
    output wire [255:0] full1_params09_dout,
    output wire [255:0] full1_params10_dout,
    output wire [255:0] full1_params11_dout,
    output wire [255:0] full1_params12_dout,
    output wire [255:0] full1_params13_dout,
    output wire [255:0] full1_params14_dout,
    output wire [255:0] full1_params15_dout
);
    /* ----- parameter ----- */
    /* ------ register ----- */
    
    (*dont_touch="true"*)reg [7:0] d_addr4 [4:0];
    (*dont_touch="true"*)reg [31:0] addr4;
    
    /* ------- wire -------  */
    wire rsta_busy;
    wire [31:0] addr32={24'b0,full1_params_addr}<<5;
    //wire [31:0] addr4={24'b0,full1_params_addr}<<2;
    //wire [31:0] addr4;
    
    /* --------  delay  --------- */
    always_ff @(posedge ICLK)begin
        d_addr4 <= {d_addr4[3:0], full1_params_addr};
    end
    
    always_ff @(posedge ICLK)begin
        addr4 <= {24'b0,d_addr4[4]}<<2;
    end
    
    //assign addr4 = d_addr4;
    
    FULL1_PARAMS00 full1_params00 (
       .douta        (full1_params00_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS01 full1_params01 (
       .douta        (full1_params01_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS02 full1_params02 (
       .douta        (full1_params02_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS03 full1_params03 (
       .douta        (full1_params03_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS04 full1_params04 (
       .douta        (full1_params04_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS05 full1_params05 (
       .douta        (full1_params05_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS06 full1_params06 (
       .douta        (full1_params06_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS07 full1_params07 (
       .douta        (full1_params07_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS08 full1_params08 (
       .douta        (full1_params08_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS09 full1_params09 (
       .douta        (full1_params09_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS10 full1_params10 (
       .douta        (full1_params10_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS11 full1_params11 (
       .douta        (full1_params11_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS12 full1_params12 (
       .douta        (full1_params12_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS13 full1_params13 (
       .douta        (full1_params13_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS14 full1_params14 (
       .douta        (full1_params14_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );
    
    FULL1_PARAMS15 full1_params15 (
       .douta        (full1_params15_dout), //--[255:0] for each [7:0] weights params and a bias param.
       .addra        (addr32),
       .clka         (ICLK)
    );    

    FULL1_BIAS full1_bias(
        .douta        (full1_bias_dout), //--[127:0] for each [7:0] bias param.
        .addra        (addr4),
        .clka         (ICLK)
    );

endmodule
