module prescaler(
	input clock,
	input reset,
	output reg out8,
	output reg out64,
	output reg out256,
	output reg out1024
);

reg [9:0] ctr1024;

always@(posedge clock) begin
	if (reset) begin
		//set certain values to 0
		ctr1024 <= 10'd0;
	end
	else begin
		if (ctr1024[2:0] == 3'b111)
			out8 <= 1'b1;
		else
			out8 <= 1'b0;
		if (ctr1024[5:0] == 6'b111111)
			out64 <= 1'b1;
		else
			out64 <= 1'b0;
		if (ctr1024[7:0] == 8'b11111111)
			out256 <= 1'b1;
		else
			out256 <= 1'b0;
		if (ctr1024[9:0] == 10'b1111111111)
		begin
			out1024 <= 1'b1;
			ctr1024 <= 10'd0;
		end
		else
		begin
			out1024 <= 1'b0;
			ctr1024 <= ctr1024 + 1'b1;
		end
	end
end

endmodule
