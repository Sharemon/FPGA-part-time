library verilog;
use verilog.vl_types.all;
entity top is
    port(
        i_clk           : in     vl_logic;
        i_rst_n         : in     vl_logic;
        uart_tx         : out    vl_logic;
        uart_rx         : in     vl_logic;
        led             : out    vl_logic_vector(7 downto 0)
    );
end top;
