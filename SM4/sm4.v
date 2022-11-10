`timescale 1ns / 1ps


module sm4_top(
    input clk,
    input rst_n,
    input [1:0] cmd,    //00:pause 01:key_exp 10:encrypt 11:decrypt
    input [127:0] sm4_din,
    output reg [127:0] sm4_dout_2,
    output reg res_vld,
    output reg enc_ok
);
localparam IDLE     = 3'd0;
localparam KEYEXP   = 3'd1;
localparam ENCRYPT  = 3'd2;
localparam DECRYPT  = 3'd3;
localparam STRES    = 3'd4;
localparam OUTPUT   = 3'd5;
reg [2:0] state; 
wire state_is_idle      = (state==IDLE    );
wire state_is_decrypt   = (state==DECRYPT );
reg [1:0] counter;
reg [4:0] key_encryption,key_decryption;
reg [127:0] sm4_round_func_in;
wire [127:0] sm4_round_func_dout;
wire [31:0] key;
wire key_exp_done;
wire key_exp_start = state_is_idle&cmd==2'b01;
wire [4:0] key_n = (state_is_decrypt|cmd==2'b11)?key_decryption:key_encryption;

always @(posedge clk,negedge rst_n) begin
if(~rst_n)begin
    state<=IDLE;
    counter<=2'd0;
    key_encryption<=5'd0;
    key_decryption<=5'd31;
    sm4_round_func_in<=128'd0;
    res_vld<=1'b0;
    state<=IDLE;
    enc_ok<=0;
end
else begin
    case (state)
    IDLE:begin
        res_vld<=1'b0;
        sm4_round_func_in<=sm4_din;
        case (cmd)
        2'b00:state<=IDLE;
        2'b01:state<=KEYEXP;
        2'b10:begin
            key_encryption<=key_encryption+1'b1;
            state<=ENCRYPT;
        end
        2'b11:begin
            key_decryption<=key_decryption-1'b1;
            state<=DECRYPT;
        end
        default: state<=IDLE;
        endcase
    end
    KEYEXP:begin
        if(key_exp_done)begin
            res_vld<=1'b1;
            state<=IDLE;
        end
    end
    ENCRYPT:begin
        sm4_round_func_in<=sm4_round_func_dout;
        key_encryption<=key_encryption+1'b1;
        if(key_encryption==5'd31)
            state<=STRES;
    end
    DECRYPT:begin
        sm4_round_func_in<=sm4_round_func_dout;
        key_decryption<=key_decryption-1'b1;
        if(key_decryption==5'd0)
            state<=STRES;
    end
    STRES:begin
        sm4_round_func_in<={sm4_round_func_dout[31:0],sm4_round_func_dout[63:32],sm4_round_func_dout[95:64],sm4_round_func_dout[127:96]};
        //res_vld<=1'b1;
        enc_ok <=1;
        state<=OUTPUT;
    end
    OUTPUT:begin
        counter<=counter+1'b1;
        sm4_round_func_in<={sm4_round_func_in[95:0],32'd0};
        if(counter==2'd3)begin
            //res_vld<=1'b0;
            enc_ok <=0;
            state<=IDLE;
        end
    end
    default: state<=IDLE;
    endcase
end
end
always @(posedge enc_ok) begin
    sm4_dout_2<=sm4_round_func_in;
end




 
sm4_encdec_round u_sm4_round(
    .round_din(sm4_round_func_in),
    .round_key(key),
    .round_dout(sm4_round_func_dout) 
);
 
key_expansion u_key_exp(
    .clk(clk),
    .rst_n(rst_n),
    .mkey(sm4_din),
    .key_exp_start(key_exp_start),
    .key_n(key_n),
    .key(key),
    .key_exp_done(key_exp_done)
);
endmodule



module key_expansion(
    input clk,rst_n,
    input [127:0] mkey,
    input key_exp_start,
    input [4:0] key_n,
    output [31:0] key,
    output key_exp_done
);
localparam FK0 = 32'ha3b1bac6;
localparam FK1 = 32'h56aa3350;
localparam FK2 = 32'h677d9197;
localparam FK3 = 32'hb27022dc;
 
reg state_is_idle;
reg ram_key_wea;
reg [4:0] exp_counter;
reg [127:0] round_din_r;
wire [31:0] round_key_r;
wire [4:0] ram_key_addr;
wire [127:0] round_dout;
wire key_exp_trigger = state_is_idle&key_exp_start;
 
assign key_exp_done = ~state_is_idle&exp_counter==5'd31;
assign ram_key_addr = state_is_idle?key_n:exp_counter;
 
always @(posedge clk,negedge rst_n) begin
    if(~rst_n)state_is_idle<=1'b1;
    else if(key_exp_trigger)
        state_is_idle<=1'b0;
	 else if(key_exp_done)
		  state_is_idle<=1'b1;
	 else state_is_idle<=state_is_idle;
end
 
always @(posedge clk,negedge rst_n) begin
    if(~rst_n)ram_key_wea<=1'b0;
    else if(key_exp_trigger)
        ram_key_wea<=1'b1;
	 else if(key_exp_done)ram_key_wea<=1'b0;
	 else ram_key_wea<=ram_key_wea;
end
 
always @(posedge clk,negedge rst_n) begin
    if(~rst_n)exp_counter<=5'd0;
    else if(~state_is_idle)
        exp_counter<=exp_counter+1'b1;
end
 
always @(posedge clk,negedge rst_n) begin
    if(~rst_n)round_din_r<=128'd0;
    else if(key_exp_trigger)
		round_din_r<=mkey^{FK0,FK1,FK2,FK3};
	 else if(~state_is_idle)round_din_r<=round_dout;
    else round_din_r<=round_din_r;
end
 
get_cki u_cki(
	.round_cnt(exp_counter),
	.cki(round_key_r)
);
 
sm4_key_round u_key_round(
    .round_din(round_din_r),
    .round_ckey(round_key_r),
    .round_dout(round_dout) 
);
 
ram_key #(
	.DP(32),
    .AW(5),
    .DW(32)
) u_ram_key(
	.clk(clk),
	.din(round_dout[31:0]),
	.addr(ram_key_addr),
	.wea(ram_key_wea),
	.dout(key)
);
 
endmodule

module sm4_encdec_round(
    input	[127:0]		round_din,
    input	[31:0]		round_key,
    output	[127:0]		round_dout 
);
 
wire [31:0] word_0,word_1,word_2,word_3;
wire [31:0] transform_din;
wire [31:0] transform_dout;
wire [7:0] sbox_bin0,sbox_bin1,sbox_bin2,sbox_bin3;
wire [7:0] sbox_bout0,sbox_bout1,sbox_bout2,sbox_bout3;
wire [31:0] sbox_wout={sbox_bout0,sbox_bout1,sbox_bout2,sbox_bout3};
 
assign {word_0,word_1,word_2,word_3} = round_din;
assign transform_din = word_1^word_2^word_3^round_key;
assign {sbox_bin0,sbox_bin1,sbox_bin2,sbox_bin3}=transform_din;
assign transform_dout = ((sbox_wout^{sbox_wout[29:0],sbox_wout[31:30]})^({sbox_wout[21:0],sbox_wout[31:22]}
                        ^{sbox_wout[13:0],sbox_wout[31:14]}))^{sbox_wout[7:0],sbox_wout[31:8]};
assign round_dout = {word_1,word_2,word_3,transform_dout^word_0};
 
s_box sbox0(
    .sbox_in(sbox_bin0),
    .sbox_out(sbox_bout0)														
);
s_box sbox1(
    .sbox_in(sbox_bin1),
    .sbox_out(sbox_bout1)														
);
s_box sbox2(
    .sbox_in(sbox_bin2),
    .sbox_out(sbox_bout2)														
);
s_box sbox3(
    .sbox_in(sbox_bin3),
    .sbox_out(sbox_bout3)														
);
 
endmodule

module sm4_key_round(
    input	[127:0]		round_din,
    input	[31:0]		round_ckey,
    output	[127:0]		round_dout 
);
 
wire [31:0] word_0,word_1,word_2,word_3;
wire [31:0] transform_din;
wire [31:0] transform_dout;
wire [7:0] sbox_bin0,sbox_bin1,sbox_bin2,sbox_bin3;
wire [7:0] sbox_bout0,sbox_bout1,sbox_bout2,sbox_bout3;
wire [31:0] sbox_wout={sbox_bout0,sbox_bout1,sbox_bout2,sbox_bout3};
 
assign {word_0,word_1,word_2,word_3} = round_din;
assign transform_din = word_1^word_2^word_3^round_ckey;
assign {sbox_bin0,sbox_bin1,sbox_bin2,sbox_bin3}=transform_din;
assign transform_dout = (sbox_wout^{sbox_wout[18:0],sbox_wout[31:19]})^{sbox_wout[8:0],sbox_wout[31:9]};
assign round_dout = {word_1,word_2,word_3,transform_dout^word_0};
 
s_box sbox0(
    .sbox_in(sbox_bin0),
    .sbox_out(sbox_bout0)														
);
s_box sbox1(
    .sbox_in(sbox_bin1),
    .sbox_out(sbox_bout1)														
);
s_box sbox2(
    .sbox_in(sbox_bin2),
    .sbox_out(sbox_bout2)														
);
s_box sbox3(
    .sbox_in(sbox_bin3),
    .sbox_out(sbox_bout3)														
);
 
endmodule

module get_cki(
   input [4:0] round_cnt,
	output reg [31:0] cki
);
 
always@(*)
	case(round_cnt)
	5'h00: cki <= 32'h00070e15;
	5'h01: cki <= 32'h1c232a31;
	5'h02: cki <= 32'h383f464d;
	5'h03: cki <= 32'h545b6269;
	5'h04: cki <= 32'h70777e85;
	5'h05: cki <= 32'h8c939aa1;
	5'h06: cki <= 32'ha8afb6bd;
	5'h07: cki <= 32'hc4cbd2d9;
	5'h08: cki <= 32'he0e7eef5;
	5'h09: cki <= 32'hfc030a11;
	5'h0a: cki <= 32'h181f262d;
	5'h0b: cki <= 32'h343b4249;
	5'h0c: cki <= 32'h50575e65;
	5'h0d: cki <= 32'h6c737a81;
	5'h0e: cki <= 32'h888f969d;
	5'h0f: cki <= 32'ha4abb2b9;
	5'h10: cki <= 32'hc0c7ced5;
	5'h11: cki <= 32'hdce3eaf1;
	5'h12: cki <= 32'hf8ff060d;
	5'h13: cki <= 32'h141b2229;
	5'h14: cki <= 32'h30373e45;
	5'h15: cki <= 32'h4c535a61;
	5'h16: cki <= 32'h686f767d;
	5'h17: cki <= 32'h848b9299;
	5'h18: cki <= 32'ha0a7aeb5;
	5'h19: cki <= 32'hbcc3cad1;
	5'h1a: cki <= 32'hd8dfe6ed;
	5'h1b: cki <= 32'hf4fb0209;
	5'h1c: cki <= 32'h10171e25;
	5'h1d: cki <= 32'h2c333a41;
	5'h1e: cki <= 32'h484f565d;
	5'h1f: cki <= 32'h646b7279;
	default: cki <= 32'h0;
	endcase
 
endmodule

module s_box(
    input [7:0] sbox_in,
    output reg [7:0] sbox_out														
);
 
always@(*)
	case(sbox_in)
	8'h00: sbox_out <=	8'hd6;
	8'h01: sbox_out <=	8'h90;
	8'h02: sbox_out <=	8'he9;
	8'h03: sbox_out <=	8'hfe;
	8'h04: sbox_out <=	8'hcc;
	8'h05: sbox_out <=	8'he1;
	8'h06: sbox_out <=	8'h3d;
	8'h07: sbox_out <=	8'hb7;
	8'h08: sbox_out <=	8'h16;
	8'h09: sbox_out <=	8'hb6;
	8'h0a: sbox_out <=	8'h14;
	8'h0b: sbox_out <=	8'hc2;
	8'h0c: sbox_out <=	8'h28;
	8'h0d: sbox_out <=	8'hfb;
	8'h0e: sbox_out <=	8'h2c;
	8'h0f: sbox_out <=	8'h05;
	8'h10: sbox_out <=	8'h2b;
	8'h11: sbox_out <=	8'h67;
	8'h12: sbox_out <=	8'h9a;
	8'h13: sbox_out <=	8'h76;
	8'h14: sbox_out <=	8'h2a;
	8'h15: sbox_out <=	8'hbe;
	8'h16: sbox_out <=	8'h04;
	8'h17: sbox_out <=	8'hc3;
	8'h18: sbox_out <=	8'haa;
	8'h19: sbox_out <=	8'h44;
	8'h1a: sbox_out <=	8'h13;
	8'h1b: sbox_out <=	8'h26;
	8'h1c: sbox_out <=	8'h49;
	8'h1d: sbox_out <=	8'h86;
	8'h1e: sbox_out <=	8'h06;
	8'h1f: sbox_out <=	8'h99;
	8'h20: sbox_out <=	8'h9c;
	8'h21: sbox_out <=	8'h42;
	8'h22: sbox_out <=	8'h50;
	8'h23: sbox_out <=	8'hf4;
	8'h24: sbox_out <=	8'h91;
	8'h25: sbox_out <=	8'hef;
	8'h26: sbox_out <=	8'h98;
	8'h27: sbox_out <=	8'h7a;
	8'h28: sbox_out <=	8'h33;
	8'h29: sbox_out <=	8'h54;
	8'h2a: sbox_out <=	8'h0b;
	8'h2b: sbox_out <=	8'h43;
	8'h2c: sbox_out <=	8'hed;
	8'h2d: sbox_out <=	8'hcf;
	8'h2e: sbox_out <=	8'hac;
	8'h2f: sbox_out <=	8'h62;
	8'h30: sbox_out <=	8'he4;
	8'h31: sbox_out <=	8'hb3;
	8'h32: sbox_out <=	8'h1c;
	8'h33: sbox_out <=	8'ha9;
	8'h34: sbox_out <=	8'hc9;
	8'h35: sbox_out <=	8'h08;
	8'h36: sbox_out <=	8'he8;
	8'h37: sbox_out <=	8'h95;
	8'h38: sbox_out <=	8'h80;
	8'h39: sbox_out <=	8'hdf;
	8'h3a: sbox_out <=	8'h94;
	8'h3b: sbox_out <=	8'hfa;
	8'h3c: sbox_out <=	8'h75;
	8'h3d: sbox_out <=	8'h8f;
	8'h3e: sbox_out <=	8'h3f;
	8'h3f: sbox_out <=	8'ha6;
	8'h40: sbox_out <=	8'h47;
	8'h41: sbox_out <=	8'h07;
	8'h42: sbox_out <=	8'ha7;
	8'h43: sbox_out <=	8'hfc;
	8'h44: sbox_out <=	8'hf3;
	8'h45: sbox_out <=	8'h73;
	8'h46: sbox_out <=	8'h17;
	8'h47: sbox_out <=	8'hba;
	8'h48: sbox_out <=	8'h83;
	8'h49: sbox_out <=	8'h59;
	8'h4a: sbox_out <=	8'h3c;
	8'h4b: sbox_out <=	8'h19;
	8'h4c: sbox_out <=	8'he6;
	8'h4d: sbox_out <=	8'h85;
	8'h4e: sbox_out <=	8'h4f;
	8'h4f: sbox_out <=	8'ha8;
	8'h50: sbox_out <=	8'h68;
	8'h51: sbox_out <=	8'h6b;
	8'h52: sbox_out <=	8'h81;
	8'h53: sbox_out <=	8'hb2;
	8'h54: sbox_out <=	8'h71;
	8'h55: sbox_out <=	8'h64;
	8'h56: sbox_out <=	8'hda;
	8'h57: sbox_out <=	8'h8b;
	8'h58: sbox_out <=	8'hf8;
	8'h59: sbox_out <=	8'heb;
	8'h5a: sbox_out <=	8'h0f;
	8'h5b: sbox_out <=	8'h4b;
	8'h5c: sbox_out <=	8'h70;
	8'h5d: sbox_out <=	8'h56;
	8'h5e: sbox_out <=	8'h9d;
	8'h5f: sbox_out <=	8'h35;
	8'h60: sbox_out <=	8'h1e;
	8'h61: sbox_out <=	8'h24;
	8'h62: sbox_out <=	8'h0e;
	8'h63: sbox_out <=	8'h5e;
	8'h64: sbox_out <=	8'h63;
	8'h65: sbox_out <=	8'h58;
	8'h66: sbox_out <=	8'hd1;
	8'h67: sbox_out <=	8'ha2;
	8'h68: sbox_out <=	8'h25;
	8'h69: sbox_out <=	8'h22;
	8'h6a: sbox_out <=	8'h7c;
	8'h6b: sbox_out <=	8'h3b;
	8'h6c: sbox_out <=	8'h01;
	8'h6d: sbox_out <=	8'h21;
	8'h6e: sbox_out <=	8'h78;
	8'h6f: sbox_out <=	8'h87;
	8'h70: sbox_out <=	8'hd4;
	8'h71: sbox_out <=	8'h00;
	8'h72: sbox_out <=	8'h46;
	8'h73: sbox_out <=	8'h57;
	8'h74: sbox_out <=	8'h9f;
	8'h75: sbox_out <=	8'hd3;
	8'h76: sbox_out <=	8'h27;
	8'h77: sbox_out <=	8'h52;
	8'h78: sbox_out <=	8'h4c;
	8'h79: sbox_out <=	8'h36;
	8'h7a: sbox_out <=	8'h02;
	8'h7b: sbox_out <=	8'he7;
	8'h7c: sbox_out <=	8'ha0;
	8'h7d: sbox_out <=	8'hc4;
	8'h7e: sbox_out <=	8'hc8;
	8'h7f: sbox_out <=	8'h9e;
	8'h80: sbox_out <=	8'hea;
	8'h81: sbox_out <=	8'hbf;
	8'h82: sbox_out <=	8'h8a;
	8'h83: sbox_out <=	8'hd2;
	8'h84: sbox_out <=	8'h40;
	8'h85: sbox_out <=	8'hc7;
	8'h86: sbox_out <=	8'h38;
	8'h87: sbox_out <=	8'hb5;
	8'h88: sbox_out <=	8'ha3;
	8'h89: sbox_out <=	8'hf7;
	8'h8a: sbox_out <=	8'hf2;
	8'h8b: sbox_out <=	8'hce;
	8'h8c: sbox_out <=	8'hf9;
	8'h8d: sbox_out <=	8'h61;
	8'h8e: sbox_out <=	8'h15;
	8'h8f: sbox_out <=	8'ha1;
	8'h90: sbox_out <=	8'he0;
	8'h91: sbox_out <=	8'hae;
	8'h92: sbox_out <=	8'h5d;
	8'h93: sbox_out <=	8'ha4;
	8'h94: sbox_out <=	8'h9b;
	8'h95: sbox_out <=	8'h34;
	8'h96: sbox_out <=	8'h1a;
	8'h97: sbox_out <=	8'h55;
	8'h98: sbox_out <=	8'had;
	8'h99: sbox_out <=	8'h93;
	8'h9a: sbox_out <=	8'h32;
	8'h9b: sbox_out <=	8'h30;
	8'h9c: sbox_out <=	8'hf5;
	8'h9d: sbox_out <=	8'h8c;
	8'h9e: sbox_out <=	8'hb1;
	8'h9f: sbox_out <=	8'he3;
	8'ha0: sbox_out <=	8'h1d;
	8'ha1: sbox_out <=	8'hf6;
	8'ha2: sbox_out <=	8'he2;
	8'ha3: sbox_out <=	8'h2e;
	8'ha4: sbox_out <=	8'h82;
	8'ha5: sbox_out <=	8'h66;
	8'ha6: sbox_out <=	8'hca;
	8'ha7: sbox_out <=	8'h60;
	8'ha8: sbox_out <=	8'hc0;
	8'ha9: sbox_out <=	8'h29;
	8'haa: sbox_out <=	8'h23;
	8'hab: sbox_out <=	8'hab;
	8'hac: sbox_out <=	8'h0d;
	8'had: sbox_out <=	8'h53;
	8'hae: sbox_out <=	8'h4e;
	8'haf: sbox_out <=	8'h6f;
	8'hb0: sbox_out <=	8'hd5;
	8'hb1: sbox_out <=	8'hdb;
	8'hb2: sbox_out <=	8'h37;
	8'hb3: sbox_out <=	8'h45;
	8'hb4: sbox_out <=	8'hde;
	8'hb5: sbox_out <=	8'hfd;
	8'hb6: sbox_out <=	8'h8e;
	8'hb7: sbox_out <=	8'h2f;
	8'hb8: sbox_out <=	8'h03;
	8'hb9: sbox_out <=	8'hff;
	8'hba: sbox_out <=	8'h6a;
	8'hbb: sbox_out <=	8'h72;
	8'hbc: sbox_out <=	8'h6d;
	8'hbd: sbox_out <=	8'h6c;
	8'hbe: sbox_out <=	8'h5b;
	8'hbf: sbox_out <=	8'h51;
	8'hc0: sbox_out <=	8'h8d;
	8'hc1: sbox_out <=	8'h1b;
	8'hc2: sbox_out <=	8'haf;
	8'hc3: sbox_out <=	8'h92;
	8'hc4: sbox_out <=	8'hbb;
	8'hc5: sbox_out <=	8'hdd;
	8'hc6: sbox_out <=	8'hbc;
	8'hc7: sbox_out <=	8'h7f;
	8'hc8: sbox_out <=	8'h11;
	8'hc9: sbox_out <=	8'hd9;
	8'hca: sbox_out <=	8'h5c;
	8'hcb: sbox_out <=	8'h41;
	8'hcc: sbox_out <=	8'h1f;
	8'hcd: sbox_out <=	8'h10;
	8'hce: sbox_out <=	8'h5a;
	8'hcf: sbox_out <=	8'hd8;
	8'hd0: sbox_out <=	8'h0a;
	8'hd1: sbox_out <=	8'hc1;
	8'hd2: sbox_out <=	8'h31;
	8'hd3: sbox_out <=	8'h88;
	8'hd4: sbox_out <=	8'ha5;
	8'hd5: sbox_out <=	8'hcd;
	8'hd6: sbox_out <=	8'h7b;
	8'hd7: sbox_out <=	8'hbd;
	8'hd8: sbox_out <=	8'h2d;
	8'hd9: sbox_out <=	8'h74;
	8'hda: sbox_out <=	8'hd0;
	8'hdb: sbox_out <=	8'h12;
	8'hdc: sbox_out <=	8'hb8;
	8'hdd: sbox_out <=	8'he5;
	8'hde: sbox_out <=	8'hb4;
	8'hdf: sbox_out <=	8'hb0;
	8'he0: sbox_out <=	8'h89;
	8'he1: sbox_out <=	8'h69;
	8'he2: sbox_out <=	8'h97;
	8'he3: sbox_out <=	8'h4a;
	8'he4: sbox_out <=	8'h0c;
	8'he5: sbox_out <=	8'h96;
	8'he6: sbox_out <=	8'h77;
	8'he7: sbox_out <=	8'h7e;
	8'he8: sbox_out <=	8'h65;
	8'he9: sbox_out <=	8'hb9;
	8'hea: sbox_out <=	8'hf1;
	8'heb: sbox_out <=	8'h09;
	8'hec: sbox_out <=	8'hc5;
	8'hed: sbox_out <=	8'h6e;
	8'hee: sbox_out <=	8'hc6;
	8'hef: sbox_out <=	8'h84;
	8'hf0: sbox_out <=	8'h18;
	8'hf1: sbox_out <=	8'hf0;
	8'hf2: sbox_out <=	8'h7d;
	8'hf3: sbox_out <=	8'hec;
	8'hf4: sbox_out <=	8'h3a;
	8'hf5: sbox_out <=	8'hdc;
	8'hf6: sbox_out <=	8'h4d;
	8'hf7: sbox_out <=	8'h20;
	8'hf8: sbox_out <=	8'h79;
	8'hf9: sbox_out <=	8'hee;
	8'hfa: sbox_out <=	8'h5f;
	8'hfb: sbox_out <=	8'h3e;
	8'hfc: sbox_out <=	8'hd7;
	8'hfd: sbox_out <=	8'hcb;
	8'hfe: sbox_out <=	8'h39;
	8'hff: sbox_out <=	8'h48;
	default: sbox_out <= 8'h00;
	endcase
endmodule


module ram_key #(
	parameter DP = 32,
    parameter AW = 8,
    parameter DW = 32
)(
	input clk,
	input [DW-1:0] din,
	input [AW-1:0] addr,
	input wea,
	output [DW-1:0] dout
);
reg [DW-1:0] mem_r [0:DP-1];
reg [AW-1:0] addr_r;
 
always @(posedge clk)
    if(~wea)addr_r<=addr;
 
always @(posedge clk)
    if(wea)
		mem_r[addr] <= din;
 
assign dout=mem_r[addr_r];
 
endmodule


