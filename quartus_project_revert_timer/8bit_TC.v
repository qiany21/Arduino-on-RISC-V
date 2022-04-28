module eight_TC (
	input clock,
	input reset,
	input T0, // external clock input
	input OCR0A_wren, //inputs for OCR0A
	input OCR0B_wren, //inputs for OCR0B
	input TCCR0A_wren,    //input for multiple control registers
	input TCCR0B_wren,    //input for multiple control registers
	input [7:0] Timer_Register_Set,
	//output reg [7:0]TCNT0, // output
	output reg OC0A,
	output reg OC0B
);

reg [7:0] TCCR0A;
reg [7:0] TCCR0B;
reg [7:0] OCR0A_temp; //used for TOP or BOTTOM
reg [7:0] OCR0B_temp; //used for TOP or BOTTOM
reg [7:0] OCR0A; //used for TOP or BOTTOM
reg [7:0] OCR0B; //used for TOP or BOTTOM
reg [7:0] TCNT0;

always@(posedge clock or posedge reset)
begin
	if (reset) begin
		OCR0A_temp <= 8'b0;
		OCR0B_temp <= 8'b0;
		TCCR0A <= 8'b0;
		TCCR0B <= 8'b0;
		//TCNT0 <= 8'b0;
	end
	else begin
		if (OCR0A_wren == 1) begin
			OCR0A_temp <= Timer_Register_Set;
		end
		if (OCR0B_wren == 1) begin
			OCR0B_temp <= Timer_Register_Set;
		end
		if (TCCR0A_wren == 1) begin
			TCCR0A <= Timer_Register_Set;
		end
		if (TCCR0B_wren == 1) begin
			TCCR0B <= Timer_Register_Set;
		end
	end
end

reg TOV0; // Timer/counter overflow flag

reg OCF0A; //Compare flag (comparing TCNT0 and OCR0A)
reg OCF0B; //Compare flag (comparing TCNT0 and OCR0B)
wire [2:0]CS0;//Clock select
assign CS0[2:0] = TCCR0B[2:0];
wire [1:0]COM0A; //Compare Output mode for OCF0A
wire [1:0]COM0B; //Compare Output mode for OCF0A
assign COM0A = TCCR0A[7:6];
assign COM0B = TCCR0A[5:4];
//reg OC0A; //Output of waveform generator from OCF0A - NOTE: never 1 when OCR0A is being written
//reg OC0B; //Output of waveform generator from OCF0B - NOTE: never 1 when OCR0B is being written
wire FOC0A; //force OC0A to 1, 0, or toggle as defined by COM0A
wire FOC0B; //force OC0B to 1, 0, or toggle as defined by COM0B
assign FOC0A = TCCR0B[7];
assign FOC0B = TCCR0B[6];

//Counter Unit Registers
reg clk_T0; // the final clock put into the timer
reg [7:0] TOP; //max of the counter (set by WGM0)
reg [7:0] BOT; //min of the counter (set by WGM0)
wire [2:0] WGM0; //Wave Generation Mode - effects which way the counter counts
                //if WGM0 = 3'd0 -> Normal Mode: count up and when you reach 0xFF (TOP), go back to 0x00 (BOTTOM). Turn TOV0 to 1 (timer overflow interrupt resets TOV0)
                //if WGM0 = 3'd2 -> Clear Timer on Compare mode (CTC): go back to 0x00 when count = OCR0A
					 //if WGM0 = 3'd3 or 3'd7 -> Fast PWM mode: TOP is 0xFF and Bottom is set by OCR0x. TOV0 goes to 1 when TOP is reached
					 //if WGM0 = 3'd1 or 3'd5 -> Phase Correct PWM mode: Counts from Bottom to TOP to BOTTOM again. When TOP is reached, direction = 1
					 //When WGM0 = 1: TOP is 0xFF, When WGM0 = 5: TOP is OCR0A
assign WGM0[1:0] = TCCR0A[1:0];
assign WGM0[2] = TCCR0B[3];

wire out8;
wire out64;
wire out256;
wire out1024;
														
reg PhCM; //Phase Correct Mode						
	
parameter 	INIT = 1'd0,
				CNT  = 1'd1;

reg S;
reg NS;

always @(*) //clock selection
begin
	case(CS0)
		3'd0: clk_T0 = 1'b0;
		3'd1: clk_T0 = clock;
		3'd2: clk_T0 = out8;
		3'd3: clk_T0 = out64;
		3'd4: clk_T0 = out256;
		3'd5: clk_T0 = out1024;
		3'd6: clk_T0 = T0;
		3'd7: clk_T0 = T0;
	endcase
	
end


always @(posedge clock)
begin
	if(reset || CS0 == 1'b0)
	begin
		S <= INIT;
	end
	else
	begin
		S <= NS;
	end
end

always @ (posedge clk_T0 or posedge reset)
begin
if(reset)
	begin
		NS <= INIT;
		OCR0A <= OCR0A_temp;
		OCR0B <= OCR0B_temp;
		OC0A <= 1'b0;
		OC0B <= 1'b0;
		PhCM <= 1'b0;
		TCNT0 <= 8'd0;
		TOP <= 8'b0;
		BOT <= 8'b0;
	end
else if (CS0 == 1'b0)
begin
		NS <= INIT;
		OCR0A <= OCR0A_temp;
		OCR0B <= OCR0B_temp;
		OC0A <= 1'b0;
		OC0B <= 1'b0;
		PhCM <= 1'b0;
		TCNT0 <= 8'd0;
		TOP <= 8'b0;
		BOT <= 8'b0;
end
else
begin
case(S)
	INIT: begin
		NS <= CNT;
		if (WGM0 == 3'd0)//normal mode init
		begin
			TOP <= 8'hFF;
			BOT <= 8'h00;
		end
		if (WGM0 == 3'd1)//Phase correct pwm mode init
		begin
			TOP <= 8'hFF;
			BOT <= 8'h00;
		end
		if (WGM0 == 3'd2)//CTC mode init
		begin
			TOP <= OCR0A;
			BOT <= 8'h00;
		end
		if (WGM0 == 3'd3)//Fast PWM mode init
		begin
			TOP <= 8'hFF;
			BOT <= 8'h00;
		end
		if (WGM0 == 3'd5)//Phase Correct PWM mode init
		begin
			TOP <= OCR0A;
			BOT <= 8'h00;
		end
		if (WGM0 == 3'd7)//Fast PWM mode init
		begin
			TOP <= OCR0A;
			BOT <= 8'h00;
		end
	end
	CNT: begin
	
		NS <= CNT;
		if (WGM0 == 3'd0 || WGM0 == 3'd2) //NORMAL MODE & CTC MODE
		begin
			OCR0A <= OCR0A_temp;
			OCR0B <= OCR0B_temp;
			
			if (FOC0A == 1) // check to see if bit is forced
			begin
				OC0A <= 1;
			end
			else if (TCNT0 == OCR0A)
			begin
				case(COM0A)
					2'b00: begin // normal
						OC0A <= 1'b0;
					end
					2'b01: begin // toggle OC0A
						OC0A <= ~OC0A;
					end
					2'b10: begin // Clear OC0A
						OC0A <= 1'b0;
					end
					2'b11: begin // Set OC0A
						OC0A <= 1'b1;
					end
					default: begin
						OC0A <= 1'b0;
					end
				endcase
			end
			else
			begin
				OC0A <= OC0A;
			end
			if (FOC0B == 1) // check to see if bit is forced
			begin
				OC0B <= 1;
			end
			else if (TCNT0 == OCR0B)
			begin
				case(COM0B)
					2'b00: begin // normal
						OC0B <= 1'b0;
					end
					2'b01: begin // toggle OC0B
						OC0B <= ~OC0B;
					end
					2'b10: begin // Clear OC0B
						OC0B <= 1'b0;
					end
					2'b11: begin // Set OC0B
						OC0B <= 1'b1;
					end
					default: begin
						OC0B <= 1'b0;
					end
				endcase
			end
			else
			begin
				OC0B <= OC0B;
			end
			if (TCNT0 == TOP || TCNT0 == 8'hFF) // reaches the top
			begin
				TOV0 <= 1'b1; // overflow bit is set to 1
				//TRIGGER INTERRUPT
				TCNT0 <= 8'd0;
			end
			else
			begin
				TCNT0 <= TCNT0 + 1'b1;
			end
		end
		
		else if (WGM0 == 3'd3 || WGM0 == 3'd7) //FAST PWM MODE
		begin
			if (TCNT0 == OCR0A)
			begin
				case(COM0A)
					2'b00: begin // normal
						OC0A <= 1'b0;
					end
					2'b01: begin
						if(WGM0[2] == 1'b1) // if WGM0 = 7: toggle
							OC0A <= ~OC0A;
						else
						begin
							OC0A <= 1'b0;
							//normal operation
						end
					end
					2'b10: begin // Clear OC0A
						OC0A <= 1'b0;
					end
					2'b11: begin // Set OC0A
						OC0A <= 1'b1;
					end
					default: begin
						OC0A <= 1'b0;
					end
				endcase
			end
			else if (TCNT0 == OCR0B)
			begin
				case(COM0B)
					2'b00: begin // normal
						OC0B <= 1'b0;
					end
					2'b01: begin // reserved
						OC0B <= 1'b0;
					end
					2'b10: begin // Clear OC0B
						OC0B <= 1'b0;
					end
					2'b11: begin // Set OC0B
						OC0B <= 1'b1;
					end
					default: begin
						OC0B <= 1'b0;
					end
				endcase
			end
			else
			begin
				OC0A <= OC0A;
				OC0B <= OC0B;
			end
			if (TCNT0 == TOP || TCNT0 == 8'hFF) // reaches the top
			begin
				TOV0 <= 1'b1; // overflow bit is set to 1
				//TRIGGER INTERRUPT
				TCNT0 <= 8'h00;
			end
			else if (TCNT0 == 8'd0) //What to do at BOTTOM
			begin
				case(COM0A)
					2'b10: begin // set OC0A
						OC0A <= 1'b1;
					end
					2'b11: begin // clear OC0A
						OC0A <= 1'b0;
					end
					default: begin
						OC0A <= 1'b0;
					end
					endcase
					case(COM0B)
					2'b10: begin // Clear OC0A
						OC0B <= 1'b1;
					end
					2'b11: begin // Set OC0A
						OC0B <= 1'b0;
					end
					default: begin
						OC0B <= 1'b0;
					end
					endcase
				TCNT0 <= TCNT0 + 1'b1;
				OCR0A <= OCR0A_temp;
				OCR0B <= OCR0B_temp;
			end
			else
			begin
					TCNT0 <= TCNT0 + 1'b1;
			end
			
		end
		
		else if (WGM0 == 3'd1 || WGM0 == 3'd5) //Phase Correct PWM mode
		begin
			if (TCNT0 == OCR0A)
			begin
				case(COM0A)
					2'b00: begin // normal
						OC0A <= 1'b0;
					end
					2'b01: begin
						if(WGM0[2] == 1'b1) // if WGM0 = 5: toggle
							OC0A <= ~OC0A;
						else
						begin
							//normal operation
							OC0A <= 1'b0;
						end
					end
					2'b10: begin 
						if (PhCM == 0)// clear OC0A (counting up)
							OC0A <= 1'b0;
						else          //set OC0A (counting down)
							OC0A <= 1'b1;
					end
					2'b11: begin
						if (PhCM == 0)// set OC0A (counting up)
							OC0A <= 1'b1;
						else          //clear OC0A (counting down)
							OC0A <= 1'b0;
					end
					default: begin
						OC0A <= 1'b0;
					end
				endcase
			end
			else if (TCNT0 == OCR0B)
			begin
				case(COM0B)
					2'b00: begin // normal
						OC0B <= 1'b0;
					end
					2'b01: begin //reserved
						OC0B <= 1'b0;
					end
					2'b10: begin 
						if (PhCM == 0)// clear OC0B (counting up)
							OC0B <= 1'b0;
						else          //set OC0B (counting down)
							OC0B <= 1'b1;
					end
					2'b11: begin
						if (PhCM == 1)// set OC0B (counting up)
							OC0B <= 1'b1;
						else          //clear OC0B (counting down)
							OC0B <= 1'b0;
					end
					default: begin
						OC0B <= 1'b0;
					end
				endcase
			end
			else
			begin
				OC0A <= OC0A;
				OC0B <= OC0B;
			end
			if (TCNT0 == TOP || TCNT0 == 8'hFF) // reaches the top
			begin
				PhCM <= 1'b1; // start counting down
				TCNT0 <= TCNT0 - 1'b1;
				OCR0A <= OCR0A_temp;
				OCR0B <= OCR0B_temp;
			end
			else if (TCNT0 == BOT)// reaches bottom
			begin
				TOV0 <= 1'b1; // overflow bit is set to 1
				//TRIGGER INTERRUPT
				PhCM <= 1'b0; // start counting up
				TCNT0 <= TCNT0 + 1'b1;
			end
			else
			begin
				if(PhCM == 1'b0)
					TCNT0 <= TCNT0 + 1'b1;
				if(PhCM == 1'b1)
					TCNT0 <= TCNT0 - 1'b1;
			end
		end
	end
	
endcase
end
end

prescaler prescaler(
	.clock(clock),
	.reset(reset),
	.out8(out8),
	.out64(out64),
	.out256(out256),
	.out1024(out1024)
);



endmodule
