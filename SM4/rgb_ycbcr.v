`timescale 1ns / 1ps


module rgb_ycbcr(
    input clk,
    input rst_n,
    input start,
    input [383:0] d_in,
    output reg all_end,
    output reg[383:0] d_out
);  
    wire [23:0]din1;
    wire [23:0]din2;
    wire [23:0]din3;
    wire [23:0]din4;
    wire [23:0]din5;
    wire [23:0]din6;
    wire [23:0]din7;
    wire [23:0]din8;
    wire [23:0]din9;
    wire [23:0]din10;
    wire [23:0]din11;
    wire [23:0]din12;
    wire [23:0]din13;
    wire [23:0]din14;
    wire [23:0]din15;
    wire [23:0]din0;

    wire all_end1;
    wire all_end2;
    wire all_end3;
    wire all_end4;
    wire all_end5;
    wire all_end6;
    wire all_end7;
    wire all_end8;
    wire all_end9;
    wire all_end10;
    wire all_end11;
    wire all_end12;
    wire all_end13;
    wire all_end14;
    wire all_end15;
    wire all_end0;
    
    wire [23:0]dout1;
    wire [23:0]dout2;
    wire [23:0]dout3;
    wire [23:0]dout4;
    wire [23:0]dout5;
    wire [23:0]dout6;
    wire [23:0]dout7;
    wire [23:0]dout8;
    wire [23:0]dout9;
    wire [23:0]dout10;
    wire [23:0]dout11;
    wire [23:0]dout12;
    wire [23:0]dout13;
    wire [23:0]dout14;
    wire [23:0]dout15;
    wire [23:0]dout0;
    
    wire all_end_t;
    assign all_end_t=all_end1&&all_end2&&all_end3&&all_end4&&all_end5&&all_end6&&
                     all_end7&&all_end8&&all_end9&&all_end10&&all_end11&&all_end12&&
                     all_end13&&all_end14&&all_end15&&all_end0;
    
    assign din1=d_in[23:0];
    assign din2=d_in[47:24];
    assign din3=d_in[71:48];
    assign din4=d_in[95:72];
    assign din5=d_in[119:96];
    assign din6=d_in[143:120];
    assign din7=d_in[167:144];
    assign din8=d_in[191:168];
    assign din9=d_in[215:192];
    assign din10=d_in[239:216];
    assign din11=d_in[263:240];
    assign din12=d_in[287:264];
    assign din13=d_in[311:288];
    assign din14=d_in[335:312];
    assign din15=d_in[359:336];
    assign din0=d_in[383:360];
    
    
    always @(posedge clk)
    begin
        if(all_end_t)
        begin
            d_out[23:0]=dout1;
            d_out[47:24]=dout2;
            d_out[71:48]=dout3;
            d_out[95:72]=dout4;
            d_out[119:96]=dout5;
            d_out[143:120]=dout6;
            d_out[167:144]=dout7;
            d_out[191:168]=dout8;
            d_out[215:192]=dout9;
            d_out[239:216]=dout10;
            d_out[263:240]=dout11;
            d_out[287:264]=dout12;
            d_out[311:288]=dout13;
            d_out[335:312]=dout14;
            d_out[359:336]=dout15;
            d_out[383:360]=dout0;
            all_end<=1;
        end
        else if(~all_end_t)
        begin
        all_end<=0;
        end
    end
    
    VIP_RGB888_YCbCr ry1 (clk,rst_n,start,din1,all_end1,dout1);
    VIP_RGB888_YCbCr ry2 (clk,rst_n,start,din2,all_end2,dout2);
    VIP_RGB888_YCbCr ry3 (clk,rst_n,start,din3,all_end3,dout3);
    VIP_RGB888_YCbCr ry4 (clk,rst_n,start,din4,all_end4,dout4);
    VIP_RGB888_YCbCr ry5 (clk,rst_n,start,din5,all_end5,dout5);
    VIP_RGB888_YCbCr ry6 (clk,rst_n,start,din6,all_end6,dout6);
    VIP_RGB888_YCbCr ry7 (clk,rst_n,start,din7,all_end7,dout7);
    VIP_RGB888_YCbCr ry8 (clk,rst_n,start,din8,all_end8,dout8);
    VIP_RGB888_YCbCr ry9 (clk,rst_n,start,din9,all_end9,dout9);
    VIP_RGB888_YCbCr ry10 (clk,rst_n,start,din10,all_end10,dout10);
    VIP_RGB888_YCbCr ry11 (clk,rst_n,start,din11,all_end11,dout11);
    VIP_RGB888_YCbCr ry12 (clk,rst_n,start,din12,all_end12,dout12);
    VIP_RGB888_YCbCr ry13 (clk,rst_n,start,din13,all_end13,dout13);
    VIP_RGB888_YCbCr ry14 (clk,rst_n,start,din14,all_end14,dout14);
    VIP_RGB888_YCbCr ry15 (clk,rst_n,start,din15,all_end15,dout15);
    VIP_RGB888_YCbCr ry16 (clk,rst_n,start,din0,all_end0,dout0);
    
endmodule
