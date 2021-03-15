`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/20 14:12:37
// Design Name: 
// Module Name: IMG_CUTTER1
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


module IMG_CUTTER1(
//--System
input wire ICLK,
input wire IRST,
//-- Input
input wire conv1_st,
input wire [1023:0] s_img,
//-- Output
output wire [4:0] px_data_x,
output wire [4:0] px_data_y,
output wire opx_data_valid,
output wire[24:0] opx_data
);
    
    parameter   px_size     =   6'd32;   
    parameter   IDLE        =   4'h0;
    parameter   EXEC       =   4'h1;
    
    reg [3:0]   st;
    reg [3:0]   nx;
    reg [4:0]   px_cnt_x;
    reg [4:0]   px_cnt_y;
    reg [24:0] px_data;
    reg px_data_valid;
    
    wire [10:0] px = px_cnt_x + (px_cnt_y<<5);
    wire frame_end = (px_cnt_y==px_size-5)&&(px_cnt_x==px_size-5);
    
    
    always_ff @(posedge ICLK)begin
        if(IRST)   st <= IDLE;
        else        st <= nx;
    end
    
    always_comb begin
        nx = st;
        case (st)
            IDLE : begin
                if(conv1_st) nx = EXEC;
            end
            EXEC : begin
                if(frame_end) nx = IDLE;
            end
        endcase
    end
    
    always_ff @(posedge ICLK) begin
        if(st==EXEC) begin
            if(px_cnt_x==px_size-5) px_cnt_x <= 5'b0;
            else    px_cnt_x <= px_cnt_x + 5'b1;
        end else    px_cnt_x <= 5'b0;
    end
    
   always_ff @(posedge ICLK)begin
        if(st==EXEC) begin
            if(px_cnt_x==px_size-5) px_cnt_y <= px_cnt_y + 5'b1;
        end
        else    px_cnt_y <= 5'b0;
    end
    
    always_ff @ (posedge ICLK) begin
       if (IRST) px_data_valid <= 1'b0;
       else if (st==EXEC) begin
            if (px_cnt_x==5'd0 && px_cnt_y==5'd0) begin
             px_data_valid <= 1'b1; //-- Assert
            end
       end
       else px_data_valid <= 1'b0;
    end
    
    reg [4:0] r_data_x;
    reg [4:0] r_data_y;
 
    always @ (posedge ICLK) begin
       if(IRST) begin
          r_data_x <= 5'h1F;
          r_data_y <= 5'h1F;
       end
       else if (st==EXEC) begin
          r_data_x <= px_cnt_x;
          r_data_y <= px_cnt_y;
       end
       else begin
          r_data_x <= 5'h1F;
          r_data_y <= 5'h1F;
       end
    end
    
    assign px_data_x = r_data_x;
    assign px_data_y = r_data_y;
    
    always_ff @(posedge ICLK)begin
        //-- 1st line
        px_data[0] <= s_img[px];
        px_data[1] <= s_img[px + 1];
        px_data[2] <= s_img[px + 2];
        px_data[3] <= s_img[px + 3];
        px_data[4] <= s_img[px + 4];
        //-- 2nd line
        px_data[5] <= s_img[px + 32];
        px_data[6] <= s_img[px + 33];
        px_data[7] <= s_img[px + 34];
        px_data[8] <= s_img[px + 35];
        px_data[9] <= s_img[px + 36];
        //-- 3rd line
        px_data[10] <= s_img[px + 64];
        px_data[11] <= s_img[px + 65];
        px_data[12] <= s_img[px + 66];
        px_data[13] <= s_img[px + 67];
        px_data[14] <= s_img[px + 68];
        //-- 4th line
        px_data[15] <= s_img[px + 96];
        px_data[16] <= s_img[px + 97];
        px_data[17] <= s_img[px + 98];
        px_data[18] <= s_img[px + 99];
        px_data[19] <= s_img[px + 100];
        //-- 5th line
        px_data[20] <= s_img[px + 128];
        px_data[21] <= s_img[px + 129];
        px_data[22] <= s_img[px + 130];
        px_data[23] <= s_img[px + 131];
        px_data[24] <= s_img[px + 132];
    end
    
    assign opx_data = px_data;
    assign opx_data_valid = px_data_valid;
    
endmodule
