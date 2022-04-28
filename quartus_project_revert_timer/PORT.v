module PORT(
	input clock,
	input reset,
	// will be use to check if the pin is write-enabled, could also be a bus because DDRB is a 8-bit Port B Data Direction register
	// each will be used to indicate RW status of each pin of port B data register
	input PORT_write_en,  				 
	input [7:0]PORT_data_in,    		// data from memory, will be written to output pin 
	output reg [7:0]PORT_data_out		// portB bus 
);


always@(posedge clock or posedge reset)
begin
	if (reset) begin
		PORT_data_out <= 8'b0;
	end
	else begin
		if (PORT_write_en == 1) begin
			// route the data to those output pins if DDRB is 1 (pinMode high)
			PORT_data_out <= PORT_data_in;
		end
	end
	
end
endmodule

