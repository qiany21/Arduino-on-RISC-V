module interrupt_setup (
    input [7:0] EIMSK,
    output INT0,
    output INT1,
    input [7:0] PCICR,
    output PCIE0,
    output PCIE1,
    output PCIE2
);

assign INT0 = EIMSK[0];
assign INT1 = EIMSK[1];

assign PCIE0 = PCICR[0];
assign PCIE1 = PCICR[1];
assign PCIE2 = PCICR[2];

endmodule
