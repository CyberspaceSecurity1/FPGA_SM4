module led
(
input wire osc_clk,
output wire [1:0]Battery_level
);

wire clk_adc;
wire adc_ok;

reg [11:0] 	adc_value;
wire [11:0] adc_data_wire;
assign Battery_level = (adc_value>2699)? 1:(adc_value>2389)?2:3;


always@(posedge adc_ok)
begin
	adc_value <= adc_data_wire;
end

pll p
(
    .refclk(osc_clk),
    .reset(1'b0),
    .stdby(1'b0),	
    .extlock(),
    .clk0_out(clk_adc)
);

adc a
(
    .eoc(adc_ok),
    .dout(adc_data_wire),
    .clk(clk_adc),
    .pd(3'b0),
    .s(3'b001),
    .soc(1'b1)
);

endmodule
