module uart_head( 
    input clk,      
    output Rs232_Tx,
    input  Rst_n ,    
    input data_rx,
    input rst_n2,
    //output all_en_ok,
    output send_ok,
    output out_ok,
    output one_round_ok,
    output [7:0] num,
    output[1:0] Battery_level
);
//wire send_ok;
wire [383:0] sm4_din;
wire [383:0]sm4_dout_o;
wire [127:0]key;
//wire [1:0]Battery_level;
wire [31:0]all_group_num;
//wire all_en_ok;
//wire one_round_ok;
//wire out_ok;
wire [8:0]data_out;
wire [127:0]data_out_128;
wire [127:0]t_data_byte=data_out_128;
wire sm4_start;
wire clk1_tmp;
wire clk2_tmp;
wire clk_true;
assign clk_true = (Battery_level==1)?  clk0:  (Battery_level==2) ?clk1:clk2; 
assign clk0=clk;//&hight_level_start;
assign clk1=clk1_tmp;//&hight_level_start;
assign clk2=clk2_tmp;//&hight_level_start;
//wire en_data_out;
uart_tx u_tx(
    .Clk(clk),       
	.Rs232_Tx(Rs232_Tx),
    .Rst_n(Rst_n) ,    
    .cipher_tixt(sm4_dout_o),
    .start(one_round_ok),
    .Battery_level(Battery_level),
    .out_ok(out_ok),
    .all_group_num(all_group_num)
);

assign num=all_group_num[7:0];

UART_RXer u_rx(
	.clk(clk),
	.res(Rst_n),
	.RX(data_rx),
	.data_out(data_out),
	.en_data_out(en_data_out),
    .data_out_128(key),
    .data_out_128000(sm4_din),
    .send_ok(send_ok),
    .one_round_ok(one_round_ok),
    .Battery_level(Battery_level),
    .out_ok(out_ok),
   	.sm4_start(sm4_start),
    .all_group_num(all_group_num)  
);

control_sm4 u_sm4(
    .clk(clk_true), 
    .rst_n(Rst_n), 
    .start(sm4_start), 
    .sm4_din(sm4_din),
    .key(key), 
    .Battery_level(Battery_level), 
    .all_group_num(all_group_num),
   	.out_ok(out_ok),
    .send_ok(send_ok),
    .sm4_dout_o(sm4_dout_o),
    .one_round_ok(one_round_ok),
    .all_en_ok(all_en_ok) 
    );
defparam     div_even_1.fre_div = 4 ;
div_even  div_even_1 
(   
     .clk(clk),
     .rst_n(rst_n2),
     .clk_out(clk1_tmp)
);
    
defparam     div_even_2.fre_div = 8 ;
div_even div_even_2 
(
     .clk(clk),
     .rst_n(rst_n2),
     .clk_out(clk2_tmp)
);

led u_adc
(
.osc_clk(clk),
.Battery_level(Battery_level)
);   
                  
endmodule
