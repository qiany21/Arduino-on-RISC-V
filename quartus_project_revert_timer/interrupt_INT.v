module interrupt_INT (
    input clk,
    input reset,
    input PIND2,
    input PIND3,
    input INT0,
    input INT1,
    output reg INTF0,
    output reg INTF1
);

reg pin_lat_2;
reg pin_lat_3;

always@(posedge clk or posedge reset)
begin
//    if (reset) begin
//        counter <= 0;
//        INTF0 <= 0;
//        INTF1 <= 0;
//    end else begin
//        if (INT0) begin
//            if (counter == 0)
//                pin_lat_2 <= PIND2;
//            INTF0 <= (counter == 4'b1111) ? (pin_lat_2 != PIND2) : 0;
//        end
//        if (INT1) begin
//            if (counter == 0)
//                pin_lat_3 <= PIND3;
//            INTF1 <= (counter == 4'b1111) ? (pin_lat_3 != PIND3) : 0;
//        end
//		  counter <= counter + 4'b1;
//    end
	if (reset) begin
		pin_lat_2 <= 0;
		pin_lat_3 <= 0;
		INTF0 <= 0;
		INTF1 <= 0;
	end else begin
		INTF0 <= (INT0) && (pin_lat_2 != PIND2) ? !INTF0 : INTF0;
		INTF1 <= (INT1) && (pin_lat_3 != PIND3) ? !INTF1 : INTF1;
		pin_lat_2 <= PIND2;
		pin_lat_3 <= PIND3;
	end
end

endmodule
