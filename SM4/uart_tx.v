module uart_tx(
    Clk,       
    Rs232_Tx,
    Rst_n ,    
    cipher_tixt,
    Battery_level,
    start,
    out_ok,
    all_group_num
);
input[383:0] cipher_tixt;
input Clk;
input Rst_n;
input start;
input [31:0] all_group_num;
input [2:0] Battery_level;
reg[32:0] plaintext_group_number;
output reg out_ok;
output reg Rs232_Tx;
wire [383:0] t_data_byte;
assign t_data_byte=cipher_tixt;
localparam START_BIT = 1'b0;
localparam STOP_BIT = 1'b1;
//localparam [12799:0]t_data_byte = {8'hCC,12792'hAAAAAAAAAAAAAA};
reg [31:0] group_num;
 
reg [15:0]div_cnt;
reg [4:0]bps_cnt;
 
//counter
always@(posedge Clk or negedge Rst_n)
    if(!Rst_n)
            div_cnt <= 16'd0;
    else begin
        if(div_cnt == 16'd5000)
            div_cnt <= 16'd0;
        else
            div_cnt <= div_cnt + 1'b1;
    end
 
 reg a;
 reg state1;
always@(posedge Clk or negedge Rst_n)
begin
	if(!Rst_n)	
		bps_cnt <= 4'd0;
	else if(~start) 
 	begin
    out_ok<=0;
    state1<=0;
  		a<=1;
			bps_cnt <= 4'd0;
  		group_num<=0;
 	end
 else if(start&&state1==0)
        begin
			if(div_cnt == 16'd5000)
				bps_cnt <= bps_cnt + 1'b1;
        
 			else if(bps_cnt==11) begin
 				group_num<=group_num+8;
    			bps_cnt=0;
 			end
 			else if(group_num>=plaintext_group_number) begin
 						a<=0;
    			group_num<=0;
        out_ok<=1;
        state1<=1;
 			end
			else
				bps_cnt <= bps_cnt;	
    	end
   end

always @(Clk) 	plaintext_group_number=(Battery_level==1)?384:(Battery_level==2)?256:128;
		
always@(posedge Clk or negedge Rst_n)
begin
if(!Rst_n)
    Rs232_Tx <= 1'b1;
else if(start&a)
begin
    case(bps_cnt)
        0:Rs232_Tx <= 1'b1;
        1:Rs232_Tx <= START_BIT;
        2:Rs232_Tx <= t_data_byte[group_num];
        3:Rs232_Tx <= t_data_byte[group_num+1];
        4:Rs232_Tx <= t_data_byte[group_num+2];
        5:Rs232_Tx <= t_data_byte[group_num+3];
        6:Rs232_Tx <= t_data_byte[group_num+4];
        7:Rs232_Tx <= t_data_byte[group_num+5];
        8:Rs232_Tx <= t_data_byte[group_num+6];
        9:Rs232_Tx <= t_data_byte[group_num+7];
        10:Rs232_Tx <= STOP_BIT;
        default:Rs232_Tx <= 1'b1;
    endcase
end	
 end
endmodule