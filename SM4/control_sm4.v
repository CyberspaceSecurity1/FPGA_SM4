`timescale 1ns / 1ps

module control_sm4(
    input clk, 
    input rst_n, 
    input start, 
    input [383:0] sm4_din,
    input [127:0] key, 
    input [1:0] Battery_level, 
    input [31:0]all_group_num,
    input send_ok,
    input out_ok,
    output reg [383:0] sm4_dout_o,
    output reg one_round_ok,
    output reg all_en_ok 
    );
    reg [31:0]end_group_num; 
	
    wire all_en_ok1; 
    wire all_en_ok2; 
    wire all_en_ok3; 
	wire all_en_ok_temp; 
    wire res_vld1; 
    wire res_vld2;
    wire res_vld3;
    reg [383:0] sm4_dout_temp; 
    wire [383:0] sm4_dout1;
    wire [383:0] sm4_dout2;
    wire [383:0] sm4_dout3;
    reg [31:0]start_group_num1; 
    reg [31:0]start_group_num2;
    reg [31:0]start_group_num3;
    wire [31:0]end_group_num1; 
    wire [31:0]end_group_num2;
    wire [31:0]end_group_num3;
    reg [1:0]my_cmd; //00:pause 01:key_exp 10:encrypt 11:decrypt
    reg hight_level_start; 
    reg secondary_level_start;
    reg low_level_start;
    reg state;
    
    wire one_round_ok1;
    wire one_round_ok2;
    wire one_round_ok3;
    wire all_res_vld;
    assign all_en_ok_temp=all_en_ok1||all_en_ok2||all_en_ok3;
    assign all_res_vld = res_vld1&&res_vld2&&res_vld3;
    localparam GROUP_CHANGE = 3'd1;
    localparam EN_DE = 3'd2;
    localparam BEGIN = 3'd0; 
    localparam END = 3'd3;
    
    always@(posedge clk) 
    begin
        if(rst_n==0)
        begin
            state<=0;
            my_cmd=2;
            hight_level_start<=0;
            secondary_level_start<=0;
            low_level_start<=0;
        end
        else 
        begin
            if(start && ~state)
            begin
                hight_level_start<=1;
                secondary_level_start<=1;
                low_level_start<=1;
                if(all_res_vld)
                begin
                    state<=1;
                end
            end
            else if(start && state) 
            begin
            /*
                if(end_group_num>=all_group_num-3)
                begin
                    hight_level_start<=0;
                    secondary_level_start<=0;
                    low_level_start<=1;
                end
                
                else
                begin
                */
                case (Battery_level)
                    2'b00:
                    begin
                        hight_level_start<=0;
                        secondary_level_start<=0;
                        low_level_start<=0;
                    end
                    2'b01:
                    begin
                        hight_level_start<=1;
                        secondary_level_start<=0;
                        low_level_start<=0;
                    end
                    2'b10:
                    begin
                        hight_level_start<=0;
                        secondary_level_start<=1;
                        low_level_start<=0;
                    end
                    2'b11:
                    begin
                        hight_level_start<=0;
                        secondary_level_start<=0;
                        low_level_start<=1;    
                    end
                
                endcase
                end
            end        
       // end
    end
    
    always@(posedge clk) 
    begin
        if(rst_n==0)
        begin
            start_group_num1<=0;
            start_group_num2<=0;
            start_group_num3<=0;
            sm4_dout_temp<=0;
            all_en_ok<=1;
        end
        else 
        begin
        if(one_round_ok1 ||one_round_ok2 ||one_round_ok3)
        begin
            case (Battery_level)
                    2'b01:
                    begin
                        start_group_num2<=end_group_num1;
                        start_group_num3<=end_group_num1;
                        end_group_num<=end_group_num1;
                        sm4_dout_o<=sm4_dout1 |sm4_dout_temp;
                        one_round_ok<=1;
                    end
                    2'b10:
                    begin
                        start_group_num1<=end_group_num2;
                        start_group_num3<=end_group_num2;
                        end_group_num<=end_group_num2;
                        sm4_dout_o<=sm4_dout2 |sm4_dout_temp;
                        one_round_ok<=1;
                    end
                    2'b11:
                    begin
                        start_group_num1<=end_group_num3;
                        start_group_num2<=end_group_num3;
                        end_group_num<=end_group_num3;
                        sm4_dout_o<=sm4_dout3 |sm4_dout_temp; 
                        one_round_ok<=1;   
                    end
              
                endcase
        end
        else if(one_round_ok1 ||one_round_ok2 ||one_round_ok3==0)
        begin
        	one_round_ok<=0;
        end
        if(all_en_ok_temp)
        begin
            sm4_dout_o<=sm4_dout_temp;
									all_en_ok<=~all_en_ok_temp;
        end
        
        end
    end
    
    
    
    Hight_lavel_SM4 U_HLsm4(
        .clk(clk),
        .rst_n(rst_n),
        .H_SM4_start(hight_level_start),
        .start_group_num(start_group_num1),
        .all_group_num(all_group_num),
        .key(key),
        .end_group_num(end_group_num1),
        .sm4_din(sm4_din),
        .my_cmd(my_cmd),
        .send_ok(send_ok),
        .out_ok(out_ok),
        .sm4_dout(sm4_dout1),
        .res_vld(res_vld1),
        .one_round_ok(one_round_ok1),
        .all_en_ok(all_en_ok1)
    );
    
    Secondary_lavel_SM4 U_SLsm4(
        .clk(clk),
        .rst_n(rst_n),
        .H_SM4_start(secondary_level_start),
        .start_group_num(start_group_num2),
        .all_group_num(all_group_num),
        .key(key),
        .end_group_num(end_group_num2),
        .sm4_din(sm4_din),
        .my_cmd(my_cmd),
        .send_ok(send_ok),
        .out_ok(out_ok),
        .sm4_dout(sm4_dout2),
        .res_vld(res_vld2),  
        .one_round_ok(one_round_ok2),
        .all_en_ok(all_en_ok2)
    );
    
    Low_lavel_SM4 U_LLsm4(
        .clk(clk),
        .rst_n(rst_n),
        .H_SM4_start(low_level_start),
        .start_group_num(start_group_num3),
        .all_group_num(all_group_num),
        .key(key),
        .end_group_num(end_group_num3),
        .sm4_din(sm4_din),
        .my_cmd(my_cmd),
        .send_ok(send_ok),
        .out_ok(out_ok),
        .sm4_dout(sm4_dout3),
        .res_vld(res_vld3),
        .one_round_ok(one_round_ok3),
        .all_en_ok(all_en_ok3)
    );
    
    
endmodule
