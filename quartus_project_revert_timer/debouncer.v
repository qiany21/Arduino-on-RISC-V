module debouncer(
input clock,
input reset,
input pb_in,
output reg pb_out
);

reg [31:0]counter;
reg out;
reg S;
reg NS;

always @(posedge clock)
begin
	if(reset)
	begin
		S <= 1'b0;
	end
	else
	begin
		S <= NS;
	end
end

always @(posedge clock or posedge reset) begin
if(reset)
	begin
		NS <= 0;
		counter <= 0;
	end
else
begin
	if(S == 1'b0)
	begin
		if (pb_in)
		begin
			NS <= 1;
			pb_out <= 1'b1;
		end
		else
		begin
			NS <= 0;
			pb_out <= 1'b0;
		end
		counter <= 32'd0;
	end
	else if(S == 1)
	begin
		if(counter >= 32'd50000000)
		begin
			NS <= 0;
			counter <= 32'd0;
		end
		else
		begin
			NS <= 1;
			pb_out <= 1'b0;
			counter <= counter + 1'b1;
		end
	end
end
end




endmodule 