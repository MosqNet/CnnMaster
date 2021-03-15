module trans_prob(
    /*---INPUT---*/
    clk_i,
    rst_i,
    UDP_st_i,
    cnn_cmp_i,
    my_MACadd_i,
    my_IPadd_i,
    DstMAC_i,
    DstIP_i,
    SrcPort_i,
    DstPort_i,
//    OFULL1_RESULT,
//    OPOOL2_RESULT,
    result_i,       // �m��
    /*---Output---*/
    UDP_o
);
    /*---I/O Declare---*/
    input           clk_i;
    input           rst_i;
    input           UDP_st_i;
    input           cnn_cmp_i;
    input [47:0]    my_MACadd_i;
    input [31:0]    my_IPadd_i;
    input [47:0]    DstMAC_i;
    input [31:0]    DstIP_i;
    input [15:0]    SrcPort_i;
    input [15:0]    DstPort_i;
//    input signed [63:0] OFULL1_RESULT [0:9];
//    input signed [63:0] OPOOL2_RESULT [0:9];
    input signed [63:0] result_i [0:9];

    output [8:0]    UDP_o;

    /*---parameter---*/
    parameter   IDLE    =   8'h00;
    parameter   Presv   =   8'h01;
    parameter   READY   =   8'h02;
    parameter   Hcsum   =   8'h03;
    parameter   Hc_End  =   8'h04;
    parameter   Tx_En   =   8'h05;
    parameter   Select  =   8'h06;
    parameter   Tx_End  =   8'h07;
    parameter   ERROR   =   8'h08;
    
    parameter   eth_head =  4'd14;
    parameter   FTYPE   =   16'h08_00;
    parameter   MsgSize =   16'd90;
    parameter   TTL     =   8'd255;
    parameter   cls_num =   10;
    parameter   PckSize =   136;

    /*---wire/register---*/
    reg [7:0]   st;
    reg [7:0]   nx;
    reg [47:0]  DstMAC;
    reg [31:0]  DstIP;
    reg [10:0]  UDP_cnt;  // �Œ蒷��UDP�f�[�^�p�J�E���g
    reg [15:0]  SrcPort;
    reg [15:0]  DstPort;
    reg         csum_ok;
    reg [7:0]   TXBUF [PckSize-1:0];
    reg [1:0]   csum_cnt;
    reg         data_en;    // 
    reg         data_en_d;
    reg [10:0]  tx_cnt;
    reg [10:0]  packet_cnt = 0;
    reg         tx_end;
    reg [8:0]   UDP_data;

    wire [47:0] my_MACadd;
    wire [31:0] my_IPadd;
    wire        hcsum_end  = (csum_cnt==8'd3);
    wire [15:0] csum_o;
    wire [10:0] packet_cnt_sel = 0;

    always_ff @(posedge clk_i)begin
        if (rst_i)  st <= IDLE;
        else        st <= nx;
    end
    
    always_comb begin
        nx = st;
        case (st)
            IDLE : begin
                if (cnn_cmp_i) nx = Presv;
            end
            Presv : begin
                nx = READY;
            end
            READY : begin
                nx = Hcsum;
            end
            Hcsum : begin
                if (hcsum_end) nx = Hc_End;
            end
            Hc_End : begin
                nx = Tx_En;
            end
            Tx_En : begin
                if(tx_end)        nx = Select;
            end
            Select : begin
                if(packet_cnt==packet_cnt_sel) nx = Tx_End;       // add 2018.12.5
                else                 nx = READY;
            end
            Tx_End : begin
                nx = IDLE;
            end
            ERROR :begin
                nx = IDLE;
            end
            default : begin
                nx = ERROR;
            end
        endcase
    end

    
    /*---�f�[�^�̎󂯓n��---*/
    always_ff @(posedge clk_i)begin
        if (UDP_st_i) begin
            DstMAC    <= DstMAC_i;
            DstIP     <= DstIP_i;
            SrcPort   <= SrcPort_i;
            DstPort   <= DstPort_i;
        end
    end
    assign my_MACadd = my_MACadd_i;
    assign my_IPadd = my_IPadd_i;

    /*---UDP�p�P�b�g����---*/
    integer i;
    always_ff @(posedge clk_i)begin
        if(st==READY)begin
            /*-�C�[�T�l�b�g�w�b�_-*/
            {TXBUF[0],TXBUF[1],TXBUF[2],TXBUF[3],TXBUF[4],TXBUF[5]} <= DstMAC;
            {TXBUF[6],TXBUF[7],TXBUF[8],TXBUF[9],TXBUF[10],TXBUF[11]} <= my_MACadd;
            {TXBUF[12],TXBUF[13]} <= FTYPE;
            /*-IP�w�b�_-*/
            TXBUF[14] <= 8'h45;                             // Version/IHL
            TXBUF[15] <= 8'h00;                             // ToS
            {TXBUF[16],TXBUF[17]} <= 5'd20+4'd8+MsgSize;    // Total Length(IP�w�b�_(20)+UDP�w�b�_(8�o�C�g)+UDP�f�[�^)
            {TXBUF[18],TXBUF[19]} <= 16'hAB_CD;             // Identification
            {TXBUF[20],TXBUF[21]} <= {3'b010,13'd0};        // Flags[15:13] ,Flagment Offset[12:0]
            TXBUF[22] <= TTL;                               // Time To Live
            TXBUF[23] <= 8'h11;                             // Protocol 8'h11==8'd17==UDP
            {TXBUF[24],TXBUF[25]} <= 16'h00_00;             // IP Checksum
            {TXBUF[26],TXBUF[27],TXBUF[28],TXBUF[29]} <= my_IPadd;
            {TXBUF[30],TXBUF[31],TXBUF[32],TXBUF[33]} <= DstIP;
            /*-UDP�w�b�_-*/
            {TXBUF[34],TXBUF[35]} <= DstPort;               // ���M���|�[�g�ԍ�
            {TXBUF[36],TXBUF[37]} <= SrcPort;               // ����|�[�g�ԍ�   
            {TXBUF[38],TXBUF[39]} <= MsgSize+4'd8;          // UDP�f�[�^�� UDP�w�b�_(8�o�C�g)+UDP�f�[�^
            {TXBUF[40],TXBUF[41]} <= 16'h00_00;             // UDP Checksum (���z�w�b�_+UDP)
            /*-�m��-*/
            for(i=0;i<10;i++)begin
                TXBUF[42+i*9] <= i;
                {TXBUF[43+i*9],TXBUF[44+i*9],TXBUF[45+i*9],TXBUF[46+i*9],TXBUF[47+i*9],TXBUF[48+i*9],TXBUF[49+i*9],TXBUF[50+i*9]} <= result_i[i];  //8bit+64bit
            end
//            {TXBUF[42],TXBUF[43],TXBUF[44],TXBUF[45],TXBUF[46],TXBUF[47],TXBUF[48],TXBUF[49],TXBUF[50]} <= {8'h0,OPOOL2_RESULT[0]};  //8bit+64bit
//            {TXBUF[51],TXBUF[52],TXBUF[53],TXBUF[54],TXBUF[55],TXBUF[56],TXBUF[57],TXBUF[58],TXBUF[59]} <= {8'h1,OPOOL2_RESULT[1]};
//            {TXBUF[60],TXBUF[61],TXBUF[62],TXBUF[63],TXBUF[64],TXBUF[65],TXBUF[66],TXBUF[67],TXBUF[68]} <= {8'h2,OPOOL2_RESULT[2]};
//            {TXBUF[69],TXBUF[70],TXBUF[71],TXBUF[72],TXBUF[73],TXBUF[74],TXBUF[75],TXBUF[76],TXBUF[77]} <= {8'h3,OPOOL2_RESULT[3]};
//            {TXBUF[78],TXBUF[79],TXBUF[80],TXBUF[81],TXBUF[82],TXBUF[83],TXBUF[84],TXBUF[85],TXBUF[86]} <= {8'h4,OPOOL2_RESULT[4]};
//            {TXBUF[87],TXBUF[88],TXBUF[89],TXBUF[90],TXBUF[91],TXBUF[92],TXBUF[93],TXBUF[94],TXBUF[95]} <= {8'h5,OPOOL2_RESULT[5]};
//            {TXBUF[96],TXBUF[97],TXBUF[98],TXBUF[99],TXBUF[100],TXBUF[10],TXBUF[102],TXBUF[103],TXBUF[104]} <= {8'h6,OPOOL2_RESULT[6]};
//            {TXBUF[105],TXBUF[106],TXBUF[107],TXBUF[108],TXBUF[109],TXBUF[110],TXBUF[111],TXBUF[112],TXBUF[113]} <= {8'h7,OPOOL2_RESULT[7]};
//            {TXBUF[114],TXBUF[115],TXBUF[116],TXBUF[117],TXBUF[118],TXBUF[119],TXBUF[120],TXBUF[121],TXBUF[122]} <= {8'h8,OPOOL2_RESULT[8]};
//            {TXBUF[123],TXBUF[124],TXBUF[125],TXBUF[126],TXBUF[127],TXBUF[128],TXBUF[129],TXBUF[130],TXBUF[131]} <= {8'h9,OPOOL2_RESULT[9]};
//            {TXBUF[42],TXBUF[43],TXBUF[44],TXBUF[45],TXBUF[46],TXBUF[47],TXBUF[48],TXBUF[49],TXBUF[50]} <= {8'h0,OFULL1_RESULT[0]};  //8bit+64bit
//            {TXBUF[51],TXBUF[52],TXBUF[53],TXBUF[54],TXBUF[55],TXBUF[56],TXBUF[57],TXBUF[58],TXBUF[59]} <= {8'h1,OFULL1_RESULT[1]};
//            {TXBUF[60],TXBUF[61],TXBUF[62],TXBUF[63],TXBUF[64],TXBUF[65],TXBUF[66],TXBUF[67],TXBUF[68]} <= {8'h2,OFULL1_RESULT[2]};
//            {TXBUF[69],TXBUF[70],TXBUF[71],TXBUF[72],TXBUF[73],TXBUF[74],TXBUF[75],TXBUF[76],TXBUF[77]} <= {8'h3,OFULL1_RESULT[3]};
//            {TXBUF[78],TXBUF[79],TXBUF[80],TXBUF[81],TXBUF[82],TXBUF[83],TXBUF[84],TXBUF[85],TXBUF[86]} <= {8'h4,OFULL1_RESULT[4]};
//            {TXBUF[87],TXBUF[88],TXBUF[89],TXBUF[90],TXBUF[91],TXBUF[92],TXBUF[93],TXBUF[94],TXBUF[95]} <= {8'h5,OFULL1_RESULT[5]};
//            {TXBUF[96],TXBUF[97],TXBUF[98],TXBUF[99],TXBUF[100],TXBUF[10],TXBUF[102],TXBUF[103],TXBUF[104]} <= {8'h6,OFULL1_RESULT[6]};
//            {TXBUF[105],TXBUF[106],TXBUF[107],TXBUF[108],TXBUF[109],TXBUF[110],TXBUF[111],TXBUF[112],TXBUF[113]} <= {8'h7,OFULL1_RESULT[7]};
//            {TXBUF[114],TXBUF[115],TXBUF[116],TXBUF[117],TXBUF[118],TXBUF[119],TXBUF[120],TXBUF[121],TXBUF[122]} <= {8'h8,OFULL1_RESULT[8]};
//            {TXBUF[123],TXBUF[124],TXBUF[125],TXBUF[126],TXBUF[127],TXBUF[128],TXBUF[129],TXBUF[130],TXBUF[131]} <= {8'h9,OFULL1_RESULT[9]};
            /*-CRC-*/
            {TXBUF[PckSize-4],TXBUF[PckSize-3],TXBUF[PckSize-2],TXBUF[PckSize-1]} <= 32'h01_02_03_04;   // dummy
        end
        else if(st==Hc_End) {TXBUF[24],TXBUF[25]} <= csum_o;
        else if(st==Tx_En)  TXBUF <= {TXBUF[0],TXBUF[PckSize-1:1]};
    end

    /*---�w�b�_�[�`�F�b�N�T��---*/
    always_ff @(posedge clk_i)begin         
        if(st==IDLE)        csum_cnt <= 0;
        else if(st==Hcsum)  csum_cnt <= csum_cnt + 1;
        else                csum_cnt <= 0;
    end

    always_ff @(posedge clk_i)begin
        if(st==Hcsum)       data_en <= `HI;
        else if(st==Tx_En)  data_en <= `LO;
        else if(st==IDLE)   data_en <= `LO;
    end

    wire [7:0] csum_data [19:0];
    genvar g;
    generate
        for (g=0; g < 20; g=g+1)
        begin
            assign csum_data[g] = TXBUF[g+14];
        end
    endgenerate   

    csum_fast trans_checksum(
        .CLK_i      (clk_i),
        .data_i     (csum_data),
        .dataen_i   (data_en),
        .reset_i    (rst_i),
        .csum_o     (csum_o)
    );

    /*---���M---*/
    always_ff @(posedge clk_i)begin
        if(st==Tx_En)begin
            tx_cnt <= tx_cnt + 11'b1;
        end
        else begin
            tx_cnt <= 11'b0;
        end
    end

    always_ff @(posedge clk_i)begin
        if(st==Tx_En)begin
            if(tx_cnt==PckSize) tx_end <= `HI; 
        end
        else begin
            tx_end <= `LO;
        end
    end

    always_ff @(posedge clk_i)begin
        if (st==Tx_En)  UDP_data <= {(tx_cnt<(PckSize-3'd4)),TXBUF[0]};
        else            UDP_data <= 0;
    end
    assign UDP_o = UDP_data;

endmodule