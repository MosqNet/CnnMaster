module POOL2_CTRL #(
    parameter POOL2_IIMG_SIZE = 100,
    parameter POOL2_WIDTH = 5,
    parameter POOL2_SIZE = POOL2_WIDTH * POOL2_WIDTH 
)
(
    input   wire    ISTART,

    output  wire    [7:0]   OPOOL_XY,
    output  wire    OPOOL_EN,
    output  wire    [6:0]   ORADDR,
    output  wire    OEND,
    output  wire    L2LED_o,

    input   wire    IRST,
    input   wire    ICLK
);
    /*---parameter---*/
    parameter   IDLE        =  4'h0;
    parameter   POOL        =  4'h1;
    parameter   POOL_END    =  4'h2;
    parameter   SEND_DENSE  =  4'h3;

    /*---wire/reg---*/
    reg  r_start;
    reg [3:0] st;
    reg [3:0] nx;
    reg  pool_end;
    wire s_start;
    
    always_ff @(posedge ICLK) begin
        if (IRST) r_start <= 1'b0;
        else      r_start <= ISTART;
    end
    assign s_start = ~r_start & ISTART;

    always_ff @(posedge ICLK)begin
        if (IRST)   st <= 0;
        else        st <= nx;
    end
    
    always_comb begin
        nx = st;
        case(st)
            IDLE : if(s_start) nx = POOL;
            POOL : if(pool_end) nx = POOL_END;
            POOL_END : nx = SEND_DENSE;
            SEND_DENSE : nx = IDLE;
            default : nx = IDLE;
        endcase
    end

    reg [1:0] pool_cnt;
    reg [3:0] x_cnt;    // Pooling Count
    reg [3:0] y_cnt;
    reg [9:0] pool_end_cnt;
    wire VALID = (pool_end_cnt>=10'd2&&pool_end_cnt<=POOL2_IIMG_SIZE+10'd1) ? 1'b1 : 1'b0;
    always_ff @(posedge ICLK)begin
        if (IRST)       pool_cnt <= 2'b0;
        if(st==POOL)    pool_cnt <= pool_cnt + 2'b1;
        else            pool_cnt <= 2'b0;
    end

    always_ff @(posedge ICLK)begin
        if (IRST)                           x_cnt <= 4'b0;
        if (st==POOL)begin
            if (pool_cnt==2'd3)begin
                if (x_cnt==POOL2_WIDTH-1)    x_cnt <= 4'b0;
                else                        x_cnt <= x_cnt + 4'b1;
            end
        end
        else                                x_cnt <= 4'b0;
    end

    always_ff @(posedge ICLK)begin
        if (IRST) y_cnt <= 4'b0;
        if (st==POOL)begin
            if (pool_cnt==2'd3)begin
                if (x_cnt==POOL2_WIDTH-1)begin
                    if (y_cnt==POOL2_WIDTH-1)    y_cnt <= 4'd0;
                    else                        y_cnt <= y_cnt + 4'b1;
                end
            end
        end
        else                                    y_cnt <= 4'd0;
    end

    reg [4:0] addr_ctl [3:0];
    always_ff @(posedge ICLK)begin
        if (IRST)      addr_ctl <= {5'd11,5'd10,5'd1,5'd0};
        if (st==POOL)  addr_ctl <= {addr_ctl[0],addr_ctl[3],addr_ctl[2],addr_ctl[1]};
        else           addr_ctl <= {5'd11,5'd10,5'd1,5'd0};
    end

    assign ORADDR = addr_ctl[0] + (x_cnt << 1) + (y_cnt<<4) + (y_cnt<<2); //addr_ctl[0] + x*2 + y*20

    always_ff @(posedge ICLK)begin
        if (IRST)      pool_end_cnt <= 10'b0;
        if (st==POOL)  pool_end_cnt <= pool_end_cnt + 10'b1;
        else           pool_end_cnt <= 10'b0;
    end
   
    always_ff @(posedge ICLK)begin
        if (IRST) pool_end <= 1'b0;
        else begin
            case (st)
                IDLE : pool_end <= 1'b0;
                POOL : if(pool_end_cnt==POOL2_IIMG_SIZE) pool_end <= 1'b1;
                POOL_END : pool_end <= 1'b0;
                default : pool_end <= 1'b0;
            endcase
        end
    end

    reg [1:0]   pool_en_cnt;
    reg         pool_en;
    reg [7:0]   pool_XY;
    always_ff @(posedge ICLK)begin
        if (IRST)      pool_en_cnt <= 2'b0;
        if (st==POOL)
            if(VALID)  pool_en_cnt <= pool_en_cnt + 2'b1;
        else           pool_en_cnt <= 2'b0;
    end
    always_ff @(posedge ICLK)begin
        if (pool_en_cnt==2'd3)
            pool_en <= 1'b1;
        else
            pool_en <= 1'b0;
    end
    always_ff @(posedge ICLK)begin
        if (IRST)         pool_XY <= 8'b0;
        if (pool_en)      pool_XY <= pool_XY + 8'b1;
        else if(st==IDLE) pool_XY <= 8'b0;
    end
    assign OPOOL_EN = pool_en;
    assign OPOOL_XY = pool_XY;

    reg r_oend;
    always_ff @(posedge ICLK)begin
        if (st==POOL_END)   r_oend <= 1'b1;
        else                r_oend <= 1'b0;
    end
    
    assign OEND = r_oend;
    
    reg r_led;
    
    always_ff @(posedge ICLK) begin
    if(IRST) r_led <= 1'b0;
    else if(st==POOL_END) begin
            if(pool_end) r_led <= pool_en; 
    end
    end

    assign L2LED_o = r_led;
    
endmodule