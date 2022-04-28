module Interrupt_Handler #(
	parameter ADDRESS_BITS = 32
)(
	input I_clk,
	input I_rst,
	input I_request,
	input [ADDRESS_BITS-1:0]I_current_PC,				// current PC: from top module
	input [ADDRESS_BITS-1:0]I_i_mem_data_out, 		// instruction: from top module
	// send these two signals back to the top module
	// those will be sent to single_cycle_core.v > single_cycle_control_unit.v > control_unit.v
	// so make sure you have the the following 4 regs defined in the above three files.
	// other changes:
	// in control_unit.v
	
	// 1.
	// add three target PC options
			/* assign target_PC = (interrupt_execute == 2'd1)		          ? 8'hc0		  :
			      (interrupt_execute == 2'd2)		          ? 8'h10		  :
		              (interrupt_done == 1)		          ? saved_PC	          :
		   	      (opcode_execute == JALR)                    ? JALR_target_execute   :
                              (opcode_execute == BRANCH) & branch_execute ? branch_target_execute :
                              (opcode_decode  == JAL)                     ? JAL_target_decode     :
                              {ADDRESS_BITS{1'b0}};
         */
         
         // 2.
         // add one stall option
         /*
         assign next_PC_sel = interrupt_stall    ? 2'b01 : // stall
										JALR_branch_hazard ? 2'b10 : // target_PC
                              true_data_hazard   ? 2'b01 : // stall
                     	      JAL_hazard         ? 2'b10 : // targeet_PC
                              i_mem_hazard       ? 2'b01 : // stall
                              d_mem_issue_hazard ? 2'b01 : // stall
                              d_mem_recv_hazard  ? 2'b01 : // stall
                              2'b00;                       // PC + 4
         */
	output reg O_interrupt_execute,
	output reg O_interrupt_done,
	output reg O_interrupt_jump,
	output reg O_interrupt_stall,
	output reg O_interrupt_happening,
	output reg [ADDRESS_BITS-1:0]O_target_PC
);


reg [2:0]S;
reg [2:0]NS;


reg exec1;

reg [ADDRESS_BITS-1:0]hold_PC;

localparam 	WAIT = 3'd0,
				SAVE = 3'd1,
				UPDATE_PC = 3'd2,
				ISR = 3'd3,
				ISR_1 = 3'd4,
				ISR_DONE = 3'd5,
				ERROR = 3'd6;
	  
	   
/* S update always block */
always@(posedge I_clk or posedge I_rst)
begin
	if (I_rst == 1'b1)
		S <= WAIT;
	else
		S <= NS;
end

always@(*)
begin
	if(S == 0)
		O_interrupt_happening = 1'b0;
	else
		O_interrupt_happening = 1'b1;
end

/* NS transitions always block */
always@(*)
begin
	case (S)
		WAIT:
		begin
			if (I_request)
				NS = SAVE;
			else
				NS = WAIT;
		end
		SAVE:
		begin
			NS = UPDATE_PC;
		end
		UPDATE_PC:
		begin
			NS = ISR;
		end
		ISR:
		begin
			NS = ISR_1;
		end
		ISR_1:
		begin
				if (I_i_mem_data_out == 32'h00007033)
				NS = ISR_DONE;
			else
				NS = ISR_1;
		end
		ISR_DONE:
		begin
			NS = WAIT; // wait for another Interrupt Request
		end
		default:
		begin
			NS = ERROR;
		end
	endcase
end

/* clocked control signals always lock */
always@(posedge I_clk or posedge I_rst)
begin
	if (I_rst == 1'b1)
	begin
		// reset all signals
		O_interrupt_execute 	<= 1'b0;
		O_interrupt_stall 	<= 1'b0;
		O_target_PC 			<= 32'b0;
		hold_PC					<= 32'b0;
		O_interrupt_done    	<= 1'b0;
		exec1 					<= 1'd0;
		O_interrupt_jump		<= 1'b0;
	end	
	else
	begin
		case (S)
			WAIT:
			begin
				// reset all signals
				O_interrupt_execute 	<= 1'b0;
				O_interrupt_stall 	<= 1'b0;
				O_target_PC 		<= 32'b0;
				hold_PC			<= 32'b0;
				O_interrupt_done    	<= 1'b0;
				exec1 <= 1'd0;
			end
			SAVE:
			begin
				// hold current PC in internal register and
				hold_PC 		<= I_current_PC;
				// stall enable
				O_interrupt_stall 	<= 1'b1;	
				exec1 <= 1'd1;
			end
			UPDATE_PC:
			begin
				// unstall
				O_interrupt_stall 	<= 1'b0;
				// send this signal to set the target PC to c0
				if (exec1)
					O_interrupt_execute 	<= 1'd1;
			end
			ISR:
			begin
				O_interrupt_jump <= 1'b1;
			end
			ISR_1:
			begin
				O_interrupt_execute 	<= 1'd0;
				O_interrupt_jump <= 1'b0;
			end
			ISR_DONE:
			begin
				O_interrupt_done    	<= 1'b1;
				// stall enable, might need a stall here, this will be set back to 0 in WAIT state.
				O_interrupt_stall 	<= 1'b1;
				// send signal to context load
				// change the target PC to the PC we recorded before.
				O_target_PC 		<= hold_PC;
			end
		endcase
	end

end

endmodule
