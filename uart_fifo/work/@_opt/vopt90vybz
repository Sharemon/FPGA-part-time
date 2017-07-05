library verilog;
use verilog.vl_types.all;
entity uart_rx is
    generic(
        baud_div        : integer := 216;
        cnt_width       : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        rx              : in     vl_logic;
        rx_dat          : out    vl_logic_vector(7 downto 0);
        rx_rdy          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of baud_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end uart_rx;
