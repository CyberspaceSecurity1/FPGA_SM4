`timescale 1ns / 1ps

module VIP_RGB888_YCbCr(
    input clk,
    input rst_n,
			input				start,	//Prepared Image data output/capture enable clock	
    input      [23:0]         d_in,
			output	reg			all_end,	//Processed Image data output/capture enable clock	
			output  reg     [23:0]    d_out
    );

wire		[7:0]	per_img_red;	//Prepared Image red data to be processed
wire		[7:0]	per_img_green;		//Prepared Image green data to be processed
wire		[7:0]	per_img_blue;		//Prepared Image blue data to be processed  
assign per_img_red=d_in[23:16];		
assign per_img_green=d_in[15:8];
assign per_img_blue=d_in[7:0];

//Step 1 计算出Y\Cb\Cr中每一个乘法的乘积
reg [15:0] img_red_r0, img_red_r1, img_red_r2;
reg [15:0] img_green_r0, img_green_r1, img_green_r2;
reg [15:0] img_blue_r0, img_blue_r1, img_blue_r2;
//Step 2 计算出Y、Cb、Cr括号内的值
reg [15:0] img_Y_r0;
reg [15:0] img_Cb_r0;
reg [15:0] img_Cr_r0;

reg[2:0] state;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_red_r0 <= 0;
        img_red_r1 <= 0;
        img_red_r2 <= 0;
        img_green_r0 <= 0;
        img_green_r1 <= 0;
        img_green_r2 <= 0;
        img_blue_r0 <= 0;
        img_blue_r1 <= 0;
        img_blue_r2 <= 0;
        img_Y_r0 <= 0;
        img_Cb_r0 <= 0;
        img_Cr_r0 <= 0;
        state<=0;
    end
    else if(~start & state==3)
    begin
        state=0;
    end
    else if(start)
    begin
        case (state)
        0:begin
        img_red_r0 <= per_img_red * 8'd77;
        img_red_r1 <= per_img_red * 8'd43;
        img_red_r2 <= per_img_red * 8'd128;
        img_green_r0 <= per_img_green * 8'd150;
        img_green_r1 <= per_img_green * 8'd85;
        img_green_r2 <= per_img_green * 8'd107;
        img_blue_r0 <= per_img_blue * 8'd29;
        img_blue_r1 <= per_img_blue * 8'd128;
        img_blue_r2 <= per_img_blue * 8'd21;
        state<=1;
        end
        
        1:begin
        img_Y_r0 <= img_red_r0 + img_green_r0 + img_blue_r0;
        img_Cb_r0 <= img_blue_r1 - img_red_r1 - img_green_r1 + 16'd32768;
        img_Cr_r0 <= img_red_r2 - img_green_r2 - img_blue_r2 + 16'd32768;
        state<=2;
        end
        
        2:begin
        d_out[23:16] <= img_Y_r0[15:8];
        d_out[15:8] <= img_Cb_r0[15:8];
        d_out[7:0] <= img_Cr_r0[15:8];
        all_end<=1;
        state<=3;
        end
        
        3:begin
        all_end<=0;
        end
    endcase
    end
end

endmodule

