/** @module : single_cycle_BRAM_top
 *  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory

 *  Copyright (c) 2021 STAM Center (ASCS Lab/CAES Lab/STAM Center/ASU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

module single_cycle_BRAM_top #(
  parameter CORE             = 0,
  parameter DATA_WIDTH       = 32,
  parameter ADDRESS_BITS     = 32,
  parameter MEM_ADDRESS_BITS = 14,
  parameter SCAN_CYCLES_MIN  = 0,
  parameter SCAN_CYCLES_MAX  = 1000
) (
  input clock,
  input reset,

  input start,
  //input [ADDRESS_BITS-1:0] program_address,

  output [ADDRESS_BITS-1:0] PC,
  output [7:0]PORTB_data_out,
  output [7:0]PORTD_data_out,
  input 	PIND2_in,
  input	PIND3_in,
  
  input scan
);

localparam [ADDRESS_BITS-1:0] program_address = 32'b0;
localparam NUM_BYTES = DATA_WIDTH/8;
// localparam scan = 1'b0;

//fetch stage interface
wire fetch_read;
wire [ADDRESS_BITS-1:0] fetch_address_out;
wire [DATA_WIDTH-1  :0] fetch_data_in;
wire [ADDRESS_BITS-1:0] fetch_address_in;
wire fetch_valid;
wire fetch_ready;
//memory stage interface
wire memory_read;
wire memory_write;
wire [NUM_BYTES-1   :0] memory_byte_en;
wire [ADDRESS_BITS-1:0] memory_address_out;
wire [DATA_WIDTH-1  :0] memory_data_out;
wire [DATA_WIDTH-1  :0] memory_data_in;
wire [ADDRESS_BITS-1:0] memory_address_in;
wire memory_valid;
wire memory_ready;
//instruction memory/cache interface
wire [DATA_WIDTH-1  :0] i_mem_data_out;
wire [ADDRESS_BITS-1:0] i_mem_address_out;
wire i_mem_valid;
wire i_mem_ready;
wire i_mem_read;
wire [ADDRESS_BITS-1:0] i_mem_address_in;
//data memory/cache interface
wire [DATA_WIDTH-1  :0] d_mem_data_out;
wire [ADDRESS_BITS-1:0] d_mem_address_out;
wire d_mem_valid;
wire d_mem_ready;
wire d_mem_read;
wire d_mem_write;
wire [DATA_WIDTH/8-1:0] d_mem_byte_en;
wire [ADDRESS_BITS-1:0] d_mem_address_in;
wire [DATA_WIDTH-1  :0] d_mem_data_in;

assign PC = fetch_address_in;

wire interrupt_execute;
wire interrupt_done;
wire interrupt_stall;
wire interrupt_jump;

wire [ADDRESS_BITS-1:0] saved_PC;

reg OCR0A_wren;
reg OCR0B_wren;
reg TCCR0A_wren;
reg TCCR0B_wren;
wire OC0A;
wire OC0B;
wire [7:0] Timer_Register_Set;
assign Timer_Register_Set = d_mem_data_in;


// pll clock to lower the system frequency to avoid timing issue
wire c0;

pll_clock pll(
	reset,
	clock,
	c0
);

single_cycle_core #(
  .CORE(CORE),
  .RESET_PC(32'd0),
  .DATA_WIDTH(DATA_WIDTH),
  .ADDRESS_BITS(ADDRESS_BITS),
  .SCAN_CYCLES_MIN(SCAN_CYCLES_MIN),
  .SCAN_CYCLES_MAX(SCAN_CYCLES_MAX)
) core (
  .clock(c0),
  .reset(reset),
  .start(start),
  .program_address(program_address),
  //memory interface
  .fetch_valid(fetch_valid),
  .fetch_ready(fetch_ready),
  .fetch_data_in(fetch_data_in),
  .fetch_address_in(fetch_address_in),
  .memory_valid(memory_valid),
  .memory_ready(memory_ready),
  .memory_data_in(memory_data_in),
  .memory_address_in(memory_address_in),
  .fetch_read(fetch_read),
  .fetch_address_out(fetch_address_out),
  .memory_read(memory_read),
  .memory_write(memory_write),
  .memory_byte_en(memory_byte_en),
  .memory_address_out(memory_address_out),
  .memory_data_out(memory_data_out),
  // interrupt
  .interrupt_execute(interrupt_execute),
  .interrupt_done(interrupt_done),
  .interrupt_jump(interrupt_jump),
  .interrupt_stall(interrupt_stall),
  .saved_PC(saved_PC),
  //scan signal
  .scan(scan)
);


memory_interface #(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDRESS_BITS(ADDRESS_BITS)
) mem_interface (
  //fetch stage interface
  .fetch_read(fetch_read),
  .fetch_address_out(fetch_address_out),
  .fetch_data_in(fetch_data_in),
  .fetch_address_in(fetch_address_in),
  .fetch_valid(fetch_valid),
  .fetch_ready(fetch_ready),
  //memory stage interface
  .memory_read(memory_read),
  .memory_write(memory_write),
  .memory_byte_en(memory_byte_en),
  .memory_address_out(memory_address_out),
  .memory_data_out(memory_data_out),
  .memory_data_in(memory_data_in),
  .memory_address_in(memory_address_in),
  .memory_valid(memory_valid),
  .memory_ready(memory_ready),
  //instruction memory/cache interface
  .i_mem_data_out(i_mem_data_out),
  .i_mem_address_out(i_mem_address_out),
  .i_mem_valid(i_mem_valid),
  .i_mem_ready(i_mem_ready),
  .i_mem_read(i_mem_read),
  .i_mem_address_in(i_mem_address_in),
  //data memory/cache interface
  .d_mem_data_out(d_mem_data_out),
  .d_mem_address_out(d_mem_address_out),
  .d_mem_valid(d_mem_valid),
  .d_mem_ready(d_mem_ready),
  .d_mem_read(d_mem_read),
  .d_mem_write(d_mem_write),
  .d_mem_byte_en(d_mem_byte_en),
  .d_mem_address_in(d_mem_address_in),
  .d_mem_data_in(d_mem_data_in),

  .scan(scan)
);

//dual_port_BRAM_byte_en_flat #(
dual_port_BRAM_memory_subsystem #(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDRESS_BITS(ADDRESS_BITS),
  .MEM_ADDRESS_BITS(MEM_ADDRESS_BITS),
  .SCAN_CYCLES_MIN(SCAN_CYCLES_MIN),
  .SCAN_CYCLES_MAX(SCAN_CYCLES_MAX)
) memory (
  .clock(c0),
  .reset(reset),
  //instruction memory
  .i_mem_read(i_mem_read),
  .i_mem_address_in(i_mem_address_in),
  .i_mem_data_out(i_mem_data_out),
  .i_mem_address_out(i_mem_address_out),
  .i_mem_valid(i_mem_valid),
  .i_mem_ready(i_mem_ready),
  //data memory
  .d_mem_read(d_mem_read),
  .d_mem_write(d_mem_write),
  .d_mem_byte_en(d_mem_byte_en),
  .d_mem_address_in(d_mem_address_in),
  .d_mem_data_in(d_mem_data_in),
  .d_mem_data_out(d_mem_data_out),
  .d_mem_address_out(d_mem_address_out),
  .d_mem_valid(d_mem_valid),
  .d_mem_ready(d_mem_ready),

  .scan(scan)
);


// Interrupt Setup
reg EIMSK_write_en;
wire [7:0] EIMSK;

wire [7:0] PORT_data_in;
assign PORT_data_in = d_mem_data_in[7:0];


// PORTB interface
reg PORTB_write_en;  				 
wire [7:0]PORTB_data_in;

// PORTD interface
reg PORTD_write_en;
wire [7:0]PORTD_data_in;

assign PORTB_data_in = d_mem_data_in[7:0];
assign PORTD_data_in = d_mem_data_in[7:0];

wire interrupt_happening;

// instantiate the port B and port D here
PORTB PORTB(
	.clock(c0),
	.reset(reset),
	.PORTB_write_en(PORTB_write_en),  				 
	.PORTB_data_in(PORTB_data_in),    		
	.PORTB_data_out(PORTB_data_out),  // output
	.OC0A(OC0A),
	.interrupt_happening(interrupt_happening)
);

PORTD PORTD(
	.clock(c0),
	.reset(reset),
	.PORTD_write_en(PORTD_write_en),  				 
	.PORTD_data_in(PORTD_data_in),    		
	.PORTD_data_out(PORTD_data_out)  // output
);

PORT EIMSK_PORT(
  .clock(c0),
  .reset(reset),
  .PORT_write_en(EIMSK_write_en),
  .PORT_data_in(PORT_data_in),
  .PORT_data_out(EIMSK)
);


eight_TC eight_TC(
	.clock(c0),
	.reset(reset),
	.T0(1'd0), // external clock input
	.OCR0A_wren(OCR0A_wren), //inputs for OCR0A
	.OCR0B_wren(OCR0B_wren), //inputs for OCR0B
	.TCCR0A_wren(TCCR0A_wren),    //input for multiple control registers
	.TCCR0B_wren(TCCR0B_wren),    //input for multiple control registers
	.Timer_Register_Set(Timer_Register_Set),
	//.TCNT0(TCNT0), // output
	.OC0A(OC0A),
	.OC0B(OC0B)
);



reg I_request;

Interrupt_Handler #(
	.ADDRESS_BITS(ADDRESS_BITS)
) Interrupt_Handler (
	.I_clk(c0),
	.I_rst(reset),
	.I_request(I_request),
	.I_current_PC(PC),						// current PC: from top module
	.I_i_mem_data_out(i_mem_data_out), 	// instruction: from top module
	.O_interrupt_execute(interrupt_execute),
	.O_interrupt_done(interrupt_done),
	.O_interrupt_jump(interrupt_jump),
	.O_interrupt_stall(interrupt_stall),
	.O_interrupt_happening(interrupt_happening),
	.O_target_PC(saved_PC)
);

//wire PIND2_out;
//wire PIND3_out;
//
//debouncer PIND2(
//    c0, 
//	 reset,
//    PIND2_in,  
//    PIND2_out
//);
//
//debouncer PIND3(
//	c0,
//	reset,
//	PIND3_in,
//	PIND3_out
//);

// INT0 and INT1 selection
always@(*) 
begin
	if (EIMSK[0] == 1'd1) 
		I_request = ~PIND2_in;
	else if (EIMSK[1] == 1'd1)	
		I_request = ~PIND3_in;
	else
		I_request = 1'd0;
end

always@(*) begin
	if (d_mem_address_in == 14'h2014 && d_mem_write == 1'b1) begin
		PORTB_write_en = 1;
	end
	else begin
		PORTB_write_en = 0;
	end
end

always@(*) begin
	if (d_mem_address_in == 14'h202c && d_mem_write == 1'b1) begin
		PORTD_write_en = 1;
	end
	else begin
		PORTD_write_en = 0;
	end
end

always@(*) begin
	if (d_mem_address_in == 14'h2074 && d_mem_write == 1'b1) begin
		EIMSK_write_en = 1;
	end
	else begin
		EIMSK_write_en = 0;
	end
end

always@(*) begin
	if (d_mem_address_in == 14'h2090 && d_mem_write == 1'b1) begin //TCR0A
		TCCR0A_wren = 1'b1;
	end
	else
	begin
		TCCR0A_wren = 1'b0;
	end
	if (d_mem_address_in == 14'h2094 && d_mem_write == 1'b1) begin
		TCCR0B_wren = 1'b1;
	end
	else
	begin
		TCCR0B_wren = 1'b0;
	end
	if (d_mem_address_in == 14'h209c && d_mem_write == 1'b1) begin
		OCR0A_wren = 1'b1;
	end
	else
	begin
		OCR0A_wren = 1'b0;
	end
	if (d_mem_address_in == 14'h20a0 && d_mem_write == 1'b1) begin
		OCR0B_wren = 1'b1;
	end
	else 
	begin
		OCR0B_wren = 1'b0;
	end
end


//always@(*) begin
//	if (d_mem_address_in == 14'h2416 && d_mem_write == 1'b1) begin
//		PCICR_write_en = 1;
//	end
//	else begin
//		PCICR_write_en = 0;
//	end
//end
//
//always@(*) begin
//	if (d_mem_address_in == 14'h2000 && d_mem_write == 1'b1) begin
//		INT_EN_write_en = 1;
//	end
//	else begin
//		INT_EN_write_en = 0;
//	end
//end


endmodule
