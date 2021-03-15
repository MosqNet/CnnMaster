`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/15 18:55:08
// Design Name: 
// Module Name: tb_RARP
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

module tb_rarp(
);
    reg P_RXDV;
    reg P_RXCLK;
    reg [3:0] P_RXD;
    wire P_TXEN;
    wire P_TXCLK;
    wire [3:0] P_TXD;
    reg SYSCLK;
    reg CPU_RSTN;
    reg reset;
    reg tx_flg;
    reg BTN;
    reg [7:0] SW;
    
    reg [3:0] state; //Signals that hold state
    reg i_start;     //read signal of external file 
    reg i_end;       //read complete signal
    integer fd = 0,fd2=0; //file descriptor
    integer lf = 0; //loop flag
    
    integer i;
    integer sim_cnt;
    integer sd,sd2;
    
    reg [0:1023] imageArray; //register that stores the value of the external file
    reg [0:1023] imageArray2; 

    TOP TOP_i(
        .ETH_RXD    (P_RXD),
        .ETH_RXCK   (P_RXCLK),
        .ETH_RXCTL  (P_RXDV),
        .ETH_TXD    (P_TXD),
        .ETH_TXCK   (P_TXCLK),
        .ETH_TXCTL  (P_TXEN),
        .SW         (SW)
    );

    initial begin
        P_RXDV = 0;
        sim_cnt = 0;
        reset = 0;
        CPU_RSTN = 1;
        state = 0;
        i_start = 0;
        i_end   = 0;
        SW = 8'd0;    // add 2018.12.5
        #18.5;
        reset = 1;
        #18.5;
    end
    
//    initial begin

//        i <= 0;
        
//        forever begin


//        @(posedge TOP.R_Arbiter.udp2cnn.LENET.layer1.CNN_START);
//            for (i=0; i<25; i=i+1)
//                #4  TOP.R_Arbiter.udp2cnn.LENET.layer1.conv1_top.conv1_core.i <= i;
//        end
//    end
        
    initial begin
        forever begin
            #5 SYSCLK = 0;
            #5 SYSCLK = 1;
        end
    end
        
    initial begin
        #7;    //-- phase trimm
        forever begin
            #4 P_RXCLK = 1'b0; //- 125 MHz
            sim_cnt = sim_cnt +1 ;
            #4 P_RXCLK = 1'b1;
        end
    end
    
//    integer img_i;
    
//    initial begin
//    img_i = $fopen("i_img.txt","w");
//    wait(sim_cnt == 1733) begin
//        $fdisplay(img_i, TOP.R_Arbiter.udp2cnn.LENET.IIMG[1023:0]);
//    end
//    $fclose(img_i);
//    end
    
    
    
//    integer sim_i;
    
//    initial begin
//    sd = $fopen("POOL1_RESULT.txt","w");
//    wait(sim_cnt == 13479) begin
//    for (sim_i=0; sim_i<6; sim_i=sim_i+1)
//        $fdisplay(sd,  TOP.R_Arbiter.udp2cnn.LENET.layer1.pool1_top.pool1.r_POOL1_RESULT[sim_i]);
//    end
//    $fclose(sd);
//    end
    
//    integer sim16, sim25;
    
//    initial begin
    
//    sd2 = $fopen("POOL2_RESULT.txt","w");
//    wait(sim_cnt == 18990) begin
//    for (sim16=0; sim16<16; sim16=sim16 +1)begin
//        for(sim25=0;sim25<25; sim25=sim25+1)begin
//        $fdisplay(sd2,  TOP.R_Arbiter.udp2cnn.LENET.layer3.array_replace.r_REPLACE_RESULT[sim16][sim25]);
//        end
//    end
//    end
//    $fclose(sd2);
//    end
    
//    integer sim120;
//    integer sd3;
    
//    initial begin
    
//    sd3 = $fopen("FULL1_RESULT.txt","w");
//    wait(sim_cnt == 18689) begin
//    for (sim120=0; sim120<120; sim120=sim120+1)begin
//        $fdisplay(sd3,  TOP.R_Arbiter.udp2cnn.LENET.layer3.full1_relu.r_FULL1_RESULT[sim120]);
//    end
//    end
//    $fclose(sd3);
//    end
    
//    integer sim84;
//    integer sd4;
    
//    initial begin
    
//    sd4 = $fopen("FULL2_RESULT.txt","w");
//    wait(sim_cnt == 35393) begin
//    for (sim84=0; sim84<84; sim84=sim84+1)begin
//        $fdisplay(sd4,  TOP.R_Arbiter.udp2cnn.LENET.layer4.full2_relu.r_FULL2_RESULT[sim84]);
//    end
//    end
//    $fclose(sd4);
//    end
    
//    integer sim10;
//    integer sd5;
    
//    initial begin
    
//    sd5 = $fopen("LENET_RESULT.txt","w");
//    wait(sim_cnt == 18790) begin
//    for (sim10=0; sim10<10; sim10=sim10+1)begin
//        $fdisplay(sd5,  TOP.R_Arbiter.udp2cnn.LENET.layer5.lenet_result.r_LENET_RESULT[sim10]);
//    end
//    end
//    $fclose(sd5);
//    end

    initial begin
        #100;
        rstCPU();
        #4000;
        SW = 8'd0;
        #16
        // ARP();
        // #2500;
        @(posedge P_RXCLK)
            i_start = 1;        
        @(posedge i_end)
            GRAY();

        #164400;  // wait ddr3 calib
        
        GRAY2();

    end
    //**
    //** receive 1 Byte via RGMII.
    //**
    task recvByte(input [7:0] c);
        begin
            @(posedge P_RXCLK) ;
            P_RXD = c[3:0];
            P_RXDV = 1'b1;
            @(negedge P_RXCLK) ;
            P_RXD = c[7:4];
        end
    endtask
    task recvMac(input [47:0] addr);
        begin
            recvByte(addr[47:40]);
            recvByte(addr[39:32]);
            recvByte(addr[31:24]);
            recvByte(addr[23:16]);
            recvByte(addr[15:8]);
            recvByte(addr[7:0]);
        end
    endtask
    task recvIp(input [31:0] addr);
        begin
            recvByte(addr[31:24]);
            recvByte(addr[23:16]);
            recvByte(addr[15:8]);
            recvByte(addr[7:0]);
        end
    endtask
    task rstCPU();
        begin
            CPU_RSTN = 0;
            #1000;
            CPU_RSTN = 1;
        end
    endtask
    /*---Glay_Image---*/
    /*--32x32--*/
    task GRAY();
        begin
        // プリアンブル
        repeat(7) recvByte(8'h55);
        recvByte(8'hd5);
        // 宛�??MAC
        recvMac(48'h00_0A_35_02_0F_B0);
        // 送信元MAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        //フレー�?タイ�?
        recvByte(8'h08);
        recvByte(8'h00);
   
        /*--IP header--*/
        // Varsion / IHL
        recvByte(8'h45);

        // ToS
        recvByte(8'h00);
   
        // Total Length = 1,486 - 18 = 1468 = 16'h05_BC
        recvByte(8'h05);
        recvByte(8'hBC);
   
        // Identification
        recvByte(8'hAB);
        recvByte(8'hCD);
   
        // Flags[15:13]/Flagment Offset[12:0]
        recvByte(8'h40);
        recvByte(8'h00);
     
        // Time To Live
        recvByte(8'd255);
   
        // Protocol
        recvByte(8'h11);
   
        // Header Checksum
        recvByte(8'hCD);
        recvByte(8'h01);
   
        // SrcIP 172.31.210.129
        recvIp({8'd172, 8'd31, 8'd210, 8'd129});
   
        // DstIP 172.31.210.130
        recvIp({8'd172, 8'd31, 8'd210, 8'd160});         
   
        /*--UDPHeader--*/
        // SrcPort
        recvByte(8'hAF);
        recvByte(8'hDB);
        // DstPort
        recvByte(8'hEA);
        recvByte(8'h60);
        // UDP Len  1,440+8 = 1448 = 16'h05_A8
        recvByte(8'h05);
        recvByte(8'hA8);
        // UDP_Checksum
        recvByte(8'h00);
        recvByte(8'h00); 
        /*--UDP Data--*/    // 1024[px]
//        repeat(32)  recvByte(8'h00);
//        repeat(320) recvPixel(8'hFF,8'h00,8'hFF);
//        repeat(32)  recvByte(8'h00);
        sendimage();
           
        // CRC
        recvByte(8'h06);
        recvByte(8'h3d);
        recvByte(8'h82);
        recvByte(8'hd1);
        recv_end();
        
        //P_RXCLK = 0;
        @(posedge P_RXCLK)
        P_RXD = 4'h0;            
        end
        endtask
        
        task GRAY2();
                begin
        // プリアンブル
        repeat(7) recvByte(8'h55);
        recvByte(8'hd5);
        // 宛�??MAC
        recvMac(48'h00_0A_35_02_0F_B0);
        // 送信元MAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        //フレー�?タイ�?
        recvByte(8'h08);
        recvByte(8'h00);
   
        /*--IP header--*/
        // Varsion / IHL
        recvByte(8'h45);

        // ToS
        recvByte(8'h00);
   
        // Total Length = 1,486 - 18 = 1468 = 16'h05_BC
        recvByte(8'h05);
        recvByte(8'hBC);
   
        // Identification
        recvByte(8'hAB);
        recvByte(8'hCD);
   
        // Flags[15:13]/Flagment Offset[12:0]
        recvByte(8'h40);
        recvByte(8'h00);
     
        // Time To Live
        recvByte(8'd255);
   
        // Protocol
        recvByte(8'h11);
   
        // Header Checksum
        recvByte(8'hCD);
        recvByte(8'h01);
   
        // SrcIP 172.31.210.129
        recvIp({8'd172, 8'd31, 8'd210, 8'd129});
   
        // DstIP 172.31.210.130
        recvIp({8'd172, 8'd31, 8'd210, 8'd160});         
   
        /*--UDPHeader--*/
        // SrcPort
        recvByte(8'hAF);
        recvByte(8'hDB);
        // DstPort
        recvByte(8'hEA);
        recvByte(8'h60);
        // UDP Len  1,440+8 = 1448 = 16'h05_A8
        recvByte(8'h05);
        recvByte(8'hA8);
        // UDP_Checksum
        recvByte(8'h00);
        recvByte(8'h00); 
        /*--UDP Data--*/    // 1024[px]
//        repeat(32)  recvByte(8'h00);
//        repeat(320) recvPixel(8'hFF,8'h00,8'hFF);
//        repeat(32)  recvByte(8'h00);
        sendimage2();
           
        // CRC
        recvByte(8'h88);
        recvByte(8'h04);
        recvByte(8'h98);
        recvByte(8'h40);
        recv_end();
        
        //P_RXCLK = 0;
        @(posedge P_RXCLK)
        P_RXD = 4'h0;            
        end
        
    endtask
    
    
    
    /*--48x30--*/
    integer glay;
    task GLAY_3();
        for(glay=0;glay<3;glay=glay+1)begin
            UDP_GLAY();
            #96;
        end
    endtask
    /*---Color_Image---*/
    /*--640x480--*/
    integer color;
    task COLOL_640();
        for(color=0;color<640;color=color+1)begin
            UDP_COLOR();
            #96;
        end
    endtask
    /*--1PIXEL--*/
    task recvPixel(input [7:0] blue, input [7:0] green, input [7:0] red);
        begin
            recvByte(blue);
            recvByte(green);
            recvByte(red);
        end
    endtask
    /*--送信--*/
    task UDP_COLOR();
        begin
        // プリアンブル
        repeat(7) recvByte(8'h55);
        recvByte(8'hd5);
        // 宛�??MAC
        recvMac(48'h00_0A_35_02_0F_B0);
        // 送信元MAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        //フレー�?タイ�?
        recvByte(8'h08);
        recvByte(8'h00);
   
        /*--IP header--*/
        // Varsion / IHL
        recvByte(8'h45);

        // ToS
        recvByte(8'h00);
   
        // Total Length = 1,486 - 18 = 1468 = 16'h05_BC
        recvByte(8'h05);
        recvByte(8'hBC);
   
        // Identification
        recvByte(8'hAB);
        recvByte(8'hCD);
   
        // Flags[15:13]/Flagment Offset[12:0]
        recvByte(8'h40);
        recvByte(8'h00);
     
        // Time To Live
        recvByte(8'd255);
   
        // Protocol
        recvByte(8'h11);
   
        // Header Checksum
        recvByte(8'hCD);
        recvByte(8'h01);
   
        // SrcIP 172.31.210.129
        recvIp({8'd172, 8'd31, 8'd210, 8'd129});
   
        // DstIP 172.31.210.130
        recvIp({8'd172, 8'd31, 8'd210, 8'd160});         
   
        /*--UDPHeader--*/
        // SrcPort
        recvByte(8'hAF);
        recvByte(8'hDB);
        // DstPort
        recvByte(8'hEA);
        recvByte(8'h60);
        // UDP Len  1,440+8 = 1448 = 16'h05_A8
        recvByte(8'h05);
        recvByte(8'hA8);
        // UDP_Checksum
        recvByte(8'h00);
        recvByte(8'h00); 
        /*--UDP Data--*/    // 480[px]
        repeat(60) recvPixel(8'hAA,8'hBB,8'hCC);
        repeat(60) recvPixel(8'h00,8'hFF,8'h00);
        repeat(60) recvPixel(8'h00,8'h00,8'hFF);
        repeat(60) recvPixel(8'hBB,8'h00,8'h00);
        repeat(60) recvPixel(8'h00,8'hBB,8'h00);
        repeat(60) recvPixel(8'h00,8'h00,8'hBB);
        repeat(60) recvPixel(8'hFF,8'hAA,8'hBB);
        repeat(59) recvPixel(8'hCC,8'hDD,8'hEE);
        recvPixel(8'hAA,8'hBB,8'hCC);
           
        // CRC
        recvByte(8'h39);
        recvByte(8'hCE);
        recvByte(8'hA7);
        recvByte(8'h40);
        recv_end();
   
        //P_RXCLK = 0;
        @(posedge P_RXCLK)
        P_RXD = 4'h0;            
        end   
    endtask   
    task UDP_GLAY();
    begin
        // プリアンブル
        repeat(7) recvByte(8'h55);
        recvByte(8'hd5);
        // 宛�??MAC
        recvMac(48'h00_0A_35_02_0F_B0);
        // 送信元MAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        //フレー�?タイ�?
        recvByte(8'h08);
        recvByte(8'h00);
   
        /*--IP header--*/
        // Varsion / IHL
        recvByte(8'h45);

        // ToS
        recvByte(8'h00);
   
        // Total Length = 1,486 - 18 = 1468 = 16'h05_BC
        recvByte(8'h05);
        recvByte(8'hBC);
   
        // Identification
        recvByte(8'hAB);
        recvByte(8'hCD);
   
        // Flags[15:13]/Flagment Offset[12:0]
        recvByte(8'h40);
        recvByte(8'h00);
     
        // Time To Live
        recvByte(8'd255);
   
        // Protocol
        recvByte(8'h11);
   
        // Header Checksum
        recvByte(8'hCD);
        recvByte(8'h01);
   
        // SrcIP 172.31.210.129
        recvIp({8'd172, 8'd31, 8'd210, 8'd129});
   
        // DstIP 172.31.210.130
        recvIp({8'd172, 8'd31, 8'd210, 8'd160});         
   
        /*--UDPHeader--*/
        // SrcPort
        recvByte(8'hAF);
        recvByte(8'hDB);
        // DstPort
        recvByte(8'hEA);
        recvByte(8'h60);
        // UDP Len  1,440+8 = 1448 = 16'h05_A8
        recvByte(8'h05);
        recvByte(8'hA8);
        // UDP_Checksum
        recvByte(8'h00);
        recvByte(8'h00); 
        /*--UDP Data--*/    // 480[px]
        repeat(60) recvPixel(8'hFF,8'hFF,8'hFF);
        repeat(60) recvPixel(8'h00,8'h00,8'h00);
        repeat(60) recvPixel(8'hFF,8'hFF,8'hFF);
        repeat(60) recvPixel(8'hFF,8'hFF,8'hFF);
        repeat(60) recvPixel(8'h00,8'h00,8'h00);
        repeat(60) recvPixel(8'h00,8'h00,8'h00);
        repeat(60) recvPixel(8'hFF,8'hFF,8'hFF);
        repeat(59) recvPixel(8'hFF,8'hFF,8'hFF);
        recvPixel(8'h00,8'h00,8'h00);
           
        // CRC
        recvByte(8'h3E);
        recvByte(8'h73);
        recvByte(8'hBC);
        recvByte(8'hFF);
        recv_end();
   
        //P_RXCLK = 0;
        @(posedge P_RXCLK)
        P_RXD = 4'h0;            
        end   
    endtask
   
    task recv_end();
        begin
        @(posedge P_RXCLK);
        P_RXDV = 0;
        end
    endtask

    task ARP();
        begin
        // プリアンブル
        repeat(7) recvByte(8'h55);
        recvByte(8'hd5);
        // 宛�??MAC
        recvMac(48'hFF_FF_FF_FF_FF_FF);
        // 送信元MAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        //フレー�?タイ�?
        recvByte(8'h08);
        recvByte(8'h06);
        // ハ�?�ドウェアタイ�?
        recvByte(8'h00);
        recvByte(8'h01);
        // プロトコルタイ�?
        recvByte(8'h08);
        recvByte(8'h00);
        // ハ�?�ドウェア長
        recvByte(8'h06);   
        // プロトコル長
        recvByte(8'h04);   
        // オペレーション
        recvByte(8'h00);
        recvByte(8'h01);  
        // SrcMAC
        recvMac(48'hF8_32_E4_BA_0D_57);
        // SrcIP 172.31.203.41
        recvIp({8'd172, 8'd31, 8'd210, 8'd129});
        // DstMAC
        recvMac(48'h00_00_00_00_00_00);
        // DstIP 172.31.203.236
        recvIp({8'd172, 8'd31, 8'd210, 8'd160});
        /* パディング */
        repeat(18) recvByte(8'h00);  
        /* CRC */
        recvByte(8'h9B);
        recvByte(8'h89);
        recvByte(8'h30);
        recvByte(8'hC8);
        recv_end();
        //P_RXCLK = 0;
        @(posedge P_RXCLK)
        P_RXD = 4'h0;
        end
    endtask
    
    task sendimage();
    integer i;
    begin
        for (i=0;i<1024;i=i+1) begin
            if(imageArray[i]==0)
                recvByte(8'h00);
            else
                recvByte(8'h01);
        end
    end
    endtask
    
    task sendimage2();
    integer i;
    begin
        for (i=0;i<1024;i=i+1) begin
            if(imageArray2[i]==0)
                recvByte(8'h00);
            else
                recvByte(8'h01);
        end
    end
    endtask
    
    reg testclk30;
    initial begin
        testclk30 = 0;
        #14.66666666 testclk30 = 1;
        #16.66666666 testclk30 = 0;
        #16.66666666 testclk30 = 1;
        #16.66666666 testclk30 = 0;
    end
    reg testclk125;
    initial begin
        testclk125 = 0;
        forever begin
            #4 testclk125 = 0;
            #4 testclk125 = 1;
        end
    end
    
    reg teststart;
    initial begin
        teststart = 0;
        #8 teststart = 1;
        #40 teststart = 0;
    end
    
    
    //parameter   FILE_PATH  = "/home/akayashima/Desktop/UDP2Prob20201218.xpr/UDP2Prob/UDP2Prob.srcs/sim_1/su.txt";
    //parameter   FILE_PATH  = "/home/akayashima/Desktop/UDP2Prob20201221.xpr/UDP2Prob/UDP2Prob.srcs/sim_1/su.txt";
    //parameter   FILE_PATH  = "C:/Users/AkihiroKayashima/Desktop/UDP2Prob20210105/UDP2Prob.srcs/sim_1/su.txt";
    parameter FILE_PATH = "/home/tmitsuhashi/bin/vivado_R3/UDP2Prob_test/UDP2Prob.srcs/sim_1/su.txt";
    //parameter   FILE_PATH  = "C:/proj_Cnn/UDP2ProbCnnMaster20210114/UDP2Prob.srcs/sim_1/su.txt";
    parameter WO_PATH =  "C:/Users/AkihiroKayashima/Downloads/UDP2ProbCnnMaster20210114/UDP2Prob.srcs/sim_1/wo.txt";
    parameter   IDLE       = 4'b0000;
    parameter   FILE_OPEN  = 4'b0001;
    parameter   FILE_READ  = 4'b0010;
    parameter   FILE_CLOSE = 4'b0011;
    parameter   DFLT       = 4'b1111;
    
    /* Read image from text file */
    always @ (posedge P_RXCLK) begin
        if(i_start)begin
            case(state)
                IDLE : begin
                    state <= FILE_OPEN;
                end
                FILE_OPEN : begin
                    //file open
                    fd=$fopen(FILE_PATH,"r");
                    fd2=$fopen(WO_PATH,"r");
            
                    if(fd==0)begin
                        //output error to screen
                        $display("File Open Error !");
                        //to the state to close the file
                        state <= FILE_CLOSE;
                    end else begin
                        //output Normal operation to screen
                        $display("File Open OK !");
                        //to the state to open the file
                        state <= FILE_READ;
                    end
            
                end
                
                FILE_READ : begin
                    //exit the loop at the end of the file
                    while(lf!=1) begin
                    //a value other than 0 indicates the end of the file
                    if($feof(fd) != 0)begin
                        $display("File End !");
                        state <= FILE_CLOSE;
                        lf <= 1;
                    end
                
                    //clock synchronization
                    @(posedge P_RXCLK);
                
                    //write to register
                    $fscanf(fd,"%b",imageArray);
                    $fscanf(fd2,"%b",imageArray2);
                    
                    end
                end
                
            FILE_CLOSE : begin
                //close file
                $fclose(fd);
                @(posedge P_RXCLK);
                state <= DFLT;
            end
            
            DFLT : begin
                i_start <= 0; //passive start trigger
                i_end <= 1;   //activate end trigger
            end
            
            endcase
        end
    end
    

    
    
    
endmodule
