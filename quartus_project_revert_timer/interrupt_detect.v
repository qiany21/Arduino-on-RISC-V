module interrupt_detect (
    input clk,
    input reset,
    input INT_EN,
    input [7:0] PINB,
    input [7:0] PINC,
    input [7:0] PIND,
    input INT0,
    input INT1,
    input PCIE0,
    input PCIE1,
    input PCIE2,
    input TIMER0_COMPA,
    input TIMER0_COMPB,
    input TIMER0_OVF,
    output INT_FLAG
);

wire INTF0;
wire INTF1;
wire PCIF0;
wire PCIF1;
wire PCIF2;

interrupt_INT interruptIN(
    .clk(clk),
    .reset(reset),
    .PIND2(PIND[2]),
    .PIND3(PIND[3]),
    .INT0(INT0),
    .INT1(INT1),
    .INTF0(INTF0),
    .INTF1(INTF1)
);

interrupt_PINT interrupt_PINT (
    .clk(clk),
    .reset(reset),
    .PINB(PINB),
    .PINC(PINC),
    .PIND(PIND),
    .PCIE0(PCIE0),
    .PCIE1(PCIE1),
    .PCIE2(PCIE2),
    .PCIF0(PCIF0),
    .PCIF1(PCIF1),
    .PCIF2(PCIF2)
);

assign INT_FLAG = INT_EN && (INTF0 || INTF1|| PCIF0 || PCIF1 || PCIF2 || TIMER0_COMPA || TIMER0_COMPB || TIMER0_OVF);

endmodule