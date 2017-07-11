library verilog;
use verilog.vl_types.all;
entity clk_div_iic is
    generic(
        freq_div        : integer := 124;
        cnt_width       : integer := 7
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        en              : in     vl_logic;
        half_clk_pulse  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of freq_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end clk_div_iic;
