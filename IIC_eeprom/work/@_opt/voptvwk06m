library verilog;
use verilog.vl_types.all;
entity eeprom_ctrl is
    generic(
        freq_div        : integer := 124;
        cnt_width       : integer := 7
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        scl             : out    vl_logic;
        sda             : inout  vl_logic;
        ctrl_byte       : in     vl_logic_vector(7 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        req             : in     vl_logic;
        ack             : out    vl_logic;
        busy            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of freq_div : constant is 1;
    attribute mti_svvh_generic_type of cnt_width : constant is 1;
end eeprom_ctrl;
