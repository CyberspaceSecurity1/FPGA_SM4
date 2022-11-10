`timescale 1ns / 1ps

module div_even #(
    parameter    fre_div = 4    //frequency division
) (
    input            clk,
    input            rst_n,
    output reg       clk_out
);

reg  [fre_div/2-1:0]    cnt;  

always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
       cnt     <= 0;
       clk_out <= 1'b0;
   end
   else if (cnt == (fre_div/2-1)) begin
       cnt     <= 0;
       clk_out <= ~clk_out;
   end
   else
       cnt <= cnt + 1;
end

endmodule
