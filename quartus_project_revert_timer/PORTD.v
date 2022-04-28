/**
	I/O port for RISC-V Arduino on FPGA
	take data from memory and route to port B
*/
module PORTD(
	input clock,
	input reset,
	// will be use to check if the pin is write-enabled, could also be a bus because DDRB is a 8-bit Port B Data Direction register
	// each will be used to indicate RW status of each pin of port B data register
	input PORTD_write_en,  				 
	input [7:0]PORTD_data_in,    		// data from memory, will be written to output pin 
	output reg [7:0]PORTD_data_out		// portB bus 
);

/*
// DDRB interface
wire DDRB_write_en;
wire [7:0]DDRB_data;
wire [7:0]DDRB_out;			// result from DDRB, determine input/output 

// instantiate DDRB here
DDRB DDRB (
	.clock(clock),
	.reset(reset),
	.DDRB_write_en(DDRB_write_en),
	.DDRB_data(DDRB_data),
	.DDRB_out(DDRB_out) 			// input/output indicator
);

*/


/**
 * The following is not a typical asysnchronous reset circuit
 * the synthesizer cannot recognize the following which generates an error
 * the error message is Cannot match operand(s) in the condition to the corresponding edges in the enclosing event control of the always construct
 * Solution: https://stackoverflow.com/questions/52232515/cannot-match-operands-in-the-condition-to-the-corresponding-edges-in-the-enclo
 */
 /*
always@(posedge clock or negedge reset)
begin
	if (reset) begin
		PORTB_data_out <= 8'b0;
	end
	else begin
		if (PORTB_write_en == 1) begin
			// route the data to those output pins if DDRB is 1 (pinMode high)
			PORTB_data_out <= PORTB_data_in;
		end
	end
	
end
*/


/**
 * so I came up with the following solution which just switch the content in two if statements.
 * This did not work: inferred latches which is bad in our design
 */
/*
always@(posedge clock or negedge reset)
begin
	if (!reset) begin
		if (PORTB_write_en == 1) begin
			// route the data to those output pins if DDRB is 1 (pinMode high)
			PORTB_data_out <= PORTB_data_in;
		end
	end
	else begin
		PORTB_data_out <= 8'b0;
	end
	
end
*/

/**
 * solution: use synchronous reset: reset in our case is always off. There is no need for using asynchronous reset circuit.
 */
always@(posedge clock or posedge reset)
begin
	if (reset) begin
		PORTD_data_out <= 8'b0;
	end
	else begin
		if (PORTD_write_en == 1) begin
			// route the data to those output pins if DDRB is 1 (pinMode high)
			PORTD_data_out <= PORTD_data_in;
		end
	end
	
end
endmodule
