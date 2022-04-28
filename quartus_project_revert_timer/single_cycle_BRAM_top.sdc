create_clock -period 20 [get_ports clock]

derive_pll_clocks

derive_clock_uncertainty