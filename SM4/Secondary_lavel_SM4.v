`timescale 1ns / 1ps


module Secondary_lavel_SM4(
    input clk,
    input rst_n,
    input H_SM4_start,
    input[31:0] start_group_num,
    input[31:0] all_group_num,
    input [127:0] key, 
    input [383:0] sm4_din,
    input [1:0] my_cmd,
    input send_ok,
    input out_ok,
    output reg [31:0] end_group_num,
    output reg [383:0] sm4_dout,
    output wire res_vld,
    output reg one_round_ok,
    output reg all_en_ok
    
    );
    localparam KETSET = 3'd0;
    localparam EN_OR_DE = 3'd1;
    localparam GROUP_ADD = 3'd3;
    localparam EN_OK= 3'd4;
    
    reg [1:0] cmd;    //00:pause 01:key_exp 10:encrypt 11:decrypt
    reg[31:0] group_num;
    reg[1:0] state;
    reg[2:0] enstate;
    reg[127:0]sm4_din1;
    reg[127:0]sm4_din2;
    wire[127:0]sm4_dout1;
    wire[127:0]sm4_dout2;
    wire[31:0] index1;
    wire[31:0] index2;
    wire res_vld1;
    wire res_vld2;
    wire enc_ok1;
    wire enc_ok2;
    
    //assign index1=group_num*128+127;
    //assign index2=group_num*128+255;
    //assign one_round_ok=enc_ok1 && enc_ok2;
    assign res_vld=res_vld1 &&res_vld2;
    always@(posedge clk) 
    begin
        if(rst_n==0) begin
             cmd=0;
             state=0;
             sm4_din1=128'h0;
             sm4_din2=128'h0;
             sm4_dout=0;
             all_en_ok=0; 
             one_round_ok<=0;  
        end
        else if((H_SM4_start==0) & (state==2) )
        begin
            state=0;
        end
        
        else 
        begin
            if(~H_SM4_start)
            begin
                group_num<=start_group_num;
                cmd<=0;
            end
            else if(H_SM4_start & (state==0)) 
            begin
                group_num<=start_group_num;
                state<=2'h1;
                enstate<=KETSET;
            end
            else if(H_SM4_start & (state==1))
            begin
                case(enstate)
                    KETSET:
                    begin
                        sm4_din1<= key;
                        sm4_din2<= key;
                        cmd<=1;  
                        if(res_vld1 && res_vld2 ) begin
                            enstate=EN_OR_DE;
                        end
                    end
                    EN_OR_DE:
                    begin
                    			if(send_ok)
                        begin
                        one_round_ok<=0;
                        cmd<=my_cmd;
                        sm4_din1<= sm4_din[127:0];
                        sm4_din2<= sm4_din[255:0];    
                        if(enc_ok1 && enc_ok2) begin
                            enstate<=GROUP_ADD;
                            end_group_num<=group_num;
                        end
                        end
                        else if(~send_ok)
                        begin
                        			cmd=0;
                        end
                    end
                    GROUP_ADD:
                    begin
                        sm4_dout[127:0]<=sm4_dout1;
                        sm4_dout[255:128]<= sm4_dout2;
                        cmd<=0; 
                        one_round_ok<=1; 
                        //if(group_num>=all_group_num-1)  begin
                        //    cmd<=0;
                        //    enstate<=EN_OK;
                        //end
                        if(out_ok) 
                        begin
                           group_num<=group_num+2;
                           enstate<=EN_OR_DE; 
                        end
                    end
                    EN_OK:
                    begin
                        state<=2;
                        all_en_ok<=1;
                    end
                endcase  
            end
        end
    end 
    sm4_top sm4_1(clk,rst_n,cmd,sm4_din1,sm4_dout1,res_vld1,enc_ok1);
    sm4_top sm4_2(clk,rst_n,cmd,sm4_din2,sm4_dout2,res_vld2,enc_ok2);
endmodule

