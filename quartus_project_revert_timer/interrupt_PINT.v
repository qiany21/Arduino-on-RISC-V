module interrupt_PINT (
    input clk,
    input reset,
    input [7:0] PINB,
    input [7:0] PINC,
    input [7:0] PIND,
    input PCIE0,
    input PCIE1,
    input PCIE2,
    output reg PCIF0,
    output reg PCIF1,
    output reg PCIF2
);

reg [7:0] PCINTB;
reg [7:0] PCINTC;
reg [7:0] PCINTD;

always@(posedge clk or posedge reset)
begin
//    if (reset) begin
//        counter <= 0;
//        PCIF0 <= 0;
//        PCIF1 <= 0;
//        PCIF2 <= 0;
//    end else begin
//        if (PCIE0) begin
//            if (counter == 0)
//                PCINTB <= PINB;
//            PCIF0 <= (counter == 4'b1111) ? (PCINTB & PINB) != 0 : 0;
//        end
//        if (PCIE1) begin
//            if (counter == 0)
//                PCINTC <= PINC;
//            PCIF1 <= (counter == 4'b1111) ? (PCINTC & PINC) != 0 : 0;
//        end
//        if (PCIE2) begin
//            if (counter == 0)
//                PCINTD <= PIND;
//            PCIF2 <= (counter == 4'b1111) ? (PCINTD & PIND) != 0 : 0;
//        end
//		  counter <= counter + 4'b1;
//    end
	if (reset) begin
		PCINTB <= 0;
		PCINTC <= 0;
		PCINTD <= 0;
		PCIF0 <= 0;
		PCIF1 <= 0;
		PCIF2 <= 0;
	end else begin
		PCIF0 <= (PCIE0) && ((PCINTB & PINB) != 0) ? 1'd1 : 1'd0;
		PCIF1 <= (PCIE1) && ((PCINTC & PINC) != 0) ? 1'd1 : 1'd0;
		PCIF2 <= (PCIE2) && ((PCINTD & PIND) != 0) ? 1'd1 : 1'd0;
		PCINTB <= PINB;
		PCINTC <= PINC;
		PCINTD <= PIND;
	end
end

endmodule
