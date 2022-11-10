
`timescale 1ns/10ps
module UART_RXer(
	clk,
 	res,
	RX,
	data_out,
	en_data_out,
  	sm4_start,
  	one_round_ok,
	data_out_128,
  	Battery_level,
 	data_out_128000,
   	out_ok,
  	send_ok,
 	all_group_num      
);
//input [1:0]         sent_pattern;
input			    clk;
input			    res;
input				RX;
input out_ok;
input one_round_ok;
input [2:0] Battery_level;
output[7:0]	data_out;
output reg sm4_start;
output reg send_ok;
output reg en_data_out;
output reg[127:0] data_out_128;
output reg[383:0] data_out_128000;
output reg[31:0] all_group_num;
reg [2:0] sent_pattern;
reg[7:0] state;
reg[12:0] con;

reg[4:0]				con_bits;
 
reg						RX_delay;
//reg                     en_data_out;
 reg [32:0] group_num;
reg[7:0]			    data_out;
wire [32:0] plaintext_group_number;
reg sendstate;
assign plaintext_group_number=(Battery_level==1)?384:(Battery_level==2)?256:128;
always@(posedge clk or negedge res)
if(~res)begin
    state<=0;
    con<=0;
    con_bits<=0;
    RX_delay<=0;
			data_out<=0;
    en_data_out<=0;
    group_num<=0;
    sent_pattern<=0;
    data_out_128=0;
    data_out_128000=0;
    all_group_num=32'h0;
    send_ok<=0;
    sm4_start<=0;
end
else begin

if(one_round_ok&& out_ok && sendstate==1)begin
  send_ok<=0;
  sendstate<=0;
	end
if (~one_round_ok)
begin
   sendstate<=1;
end

RX_delay<=RX;
case(state)
0:
begin
if(con==5000-1)begin
				con<=0;
			end
			else begin
				con<=con+1;
			end
			if(con==0)begin
				if(RX)begin
					con_bits<=con_bits+1;
				end
				else begin
					con_bits<=0;
				end
		end
		
		if(con_bits==12)begin
			state<=1;
			sent_pattern<=1;
		end
	end
	
	1:
	begin
	en_data_out<=0;
		if(~RX&RX_delay)begin
			state<=2;
		end
	end
	2:
	begin
			if(con==7500-1)begin
				con<=0;
				data_out[0]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num]<=RX;
				state<=3;
			end
			else begin
				con<=con+1;		
			end
	end
	3:
	begin
			if(con==5000-1)begin
				con<=0;
				data_out[1]<=RX;
                if(sent_pattern==1)
     	        data_out_128[group_num+1]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+1]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+1]<=RX;
				state<=4;
			end
			else begin
				con<=con+1;		
			end
	end
	4:
	begin
	if(con==5000-1)begin
	 con<=0;
	 data_out[2]<=RX;
     if(sent_pattern==1)
     	        data_out_128[group_num+2]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+2]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+2]<=RX;
	 state<=5;
	end
	else begin
		con<=con+1;		
	end
	end
	5:
	begin
	   if(con==5000-1)begin
		con<=0;
				data_out[3]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num+3]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+3]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+3]<=RX;
     state<=6;
			end
			else begin
				con<=con+1;		
			end
	end
	6:
	begin
			if(con==5000-1)begin
				con<=0;
				data_out[4]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num+4]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+4]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+4]<=RX;
     state<=7;
			end
			else begin
				con<=con+1;		
			end
	end
	7:
	begin
			if(con==5000-1)begin
				con<=0;
				data_out[5]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num+5]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+5]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+5]<=RX;
     state<=8;
			end
			else begin
				con<=con+1;		
			end
	end
	8:
	begin
			if(con==5000-1)begin
				con<=0;
				data_out[6]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num+6]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+6]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+6]<=RX;
     state<=9;
			end
			else begin
				con<=con+1;		
			end
	end
	9:
	begin
			if(con==5000-1)begin
				con<=0;
				data_out[7]<=RX;
				if(sent_pattern==1)
     	        data_out_128[group_num+7]<= RX; 
     	        else if (sent_pattern==2)
     	        all_group_num[group_num+7]<=RX;
     	        else if (sent_pattern==3)
     	        data_out_128000[group_num+7]<=RX;
     state<=10;
			end
			else begin
				con<=con+1;		
			end
	end
	10:
	begin
		//en_data_out<=1;
		state<=1;
   group_num<=group_num+8;
	end
	
	default:
	begin
		state<=0;
		con<=0;
		con_bits<=0;
	end
	endcase
	
	case(sent_pattern)
	1:begin
	if(group_num>=128) begin
	sent_pattern<=2;
	group_num<=0;
	end
	end
	
	2:begin
	if(group_num>=32) begin
	sent_pattern<=3;
	group_num<=0;
 	sm4_start<=1;
	end
	end
	
	3:begin
	if(group_num>=plaintext_group_number)begin
		 group_num<=0;
		 send_ok <=1;
    sendstate<=0;
	end
    end
	endcase
 
end
 
endmodule
