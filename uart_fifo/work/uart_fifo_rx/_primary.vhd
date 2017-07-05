library verilog;
use verilog.vl_types.all;
entity uart_fifo_rx is
    generic(
        baud_div        : integer := 216;
        cnt_width       : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        uart_rx         : in     vl_logic;
        fifo_dout       : out    vl_logic_vector(63 downto 0);
        fifo_full       : out    vl_logic;
        fifo_empty      : out    vl_logic;
        fifo_rd_en      : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of baud_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end uart_fifo_rx;
