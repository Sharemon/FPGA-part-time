
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name IIC_eeprom -dir "C:/Users/Roy/Desktop/Proj Local/FPGA-part-time/IIC_eeprom/planAhead_run_1" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "C:/Users/Roy/Desktop/Proj Local/FPGA-part-time/IIC_eeprom/source/cons/top.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/clk_gen/clk_gen.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {source/iic/clk_div_iic.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {source/iic/iic_ctrl.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {source/eeprom/eeprom_ctrl.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {source/top/top.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top top $srcset
add_files [list {C:/Users/Roy/Desktop/Proj Local/FPGA-part-time/IIC_eeprom/source/cons/top.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
