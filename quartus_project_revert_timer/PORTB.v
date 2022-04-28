/**
	I/O port for RISC-V Arduino on FPGA
	take data from memory and route to port B
*/
module PORTB(
	input clock,
	input reset,
	// will be use to check if the pin is write-enabled, could also be a bus because DDRB is a 8-bit Port B Data Direction register
	// each will be used to indicate RW status of each pin of port B data register
	input PORTB_write_en,  				 
	input [7:0]PORTB_data_in,    		// data from memory, will be written to output pin 
	output reg [7:0]PORTB_data_out,		// portB bus 
	input OC0A,
	input interrupt_happening
);


always@(posedge clock or posedge reset)
begin
	if (reset) begin
		PORTB_data_out <= 8'b0;
	end
	else begin
	if (!interrupt_happening)
	begin
		if (PORTB_write_en == 1) begin
			// route the data to those output pins if DDRB is 1 (pinMode high)
			PORTB_data_out <= PORTB_data_in;
		end
	end
	else
	begin
		PORTB_data_out[5] <= OC0A;
	end
	end
	
end
endmodule
