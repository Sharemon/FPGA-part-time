library verilog;
use verilog.vl_types.all;
entity clk_div_uart is
    generic(
        baud_div        : integer := 216;
        cnt_width       : integer := 8
    );
    port(
        i_clk           : in     vl_logic;
        i_rst_n         : in     vl_logic;
        i_en            : in     vl_logic;
        o_clk_half_pule : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of baud_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end clk_div_uart;
