library verilog;
use verilog.vl_types.all;
entity iic_ctrl is
    generic(
        freq_div        : integer := 124;
        cnt_width       : integer := 7
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        scl             : out    vl_logic;
        sda             : inout  vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        ack_in          : out    vl_logic;
        dout            : out    vl_logic_vector(7 downto 0);
        ack_out         : in     vl_logic;
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        start_en        : in     vl_logic;
        stop_en         : in     vl_logic;
        busy            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of freq_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end iic_ctrl;
