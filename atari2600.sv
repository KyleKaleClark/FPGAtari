/*
 _____ ____   ____    _   _             _ 
|  ___|  _ \ / ___|  / \ | |_ __ _ _ __(_)
| |_  | |_) | |  _  / _ \| __/ _` | '__| |
|  _| |  __/| |_| |/ ___ \ || (_| | |  | |
|_|   |_|    \____/_/   \_\__\__,_|_|  |_|

ASU Senior Capstone Project 2024-2025

*/


//////////////////////////////////////////
//             Top Module                /
//   THE Atari 2600, full intg syst      /
//////////////////////////////////////////


module atari2600(
	 
  // clock, reset, ready (starting signals)
  input clk,
	input reset,

  //CPU Signals
  //Buses
  input [7:0] db_rom_to_ctrl,
  output [12:0] ab_ctrl_to_rom,
    
  //Full Build Signals
  //Front Panel Switches
  input tv_type,
	input left_diff,
	input right_diff, 
  input game_sel,
	input game_reset,

  //Controller Ports - 9 pins, 2 vdd/gnd, 7 matter. 
  //order, 1-Up, 2-Down, 3-Left, 4-Right (pin5 nothing) 6-fire, 7nothing, 8gnd, 9nothing 
  //bits		0		1		   2         3       x             4        x       x       x
  input [6:0] l_contr,
  input l_left,
  input l_right,
  input l_up,
  input l_down,
  input l_action,
  input [6:0] r_contr,
	 


	 
  //TIA Signals
  // VGA Controller Connections
  output [23:0] VGA_RGB,
  output [7:0] VGA_X,
  output [8:0] VGA_Y,
  output VGA_VSYNC,
  output VGA_VBLANK,
  output VGA_WR,
  output [15:0] VGA_ADDR,

  // Audio Connections
  output [1:0] AUD,


  //Board Monitor Signals
  output [6:0] CS_WE_RDY,

  //Audio clock
  input audio_clk
);

wire RDY;
wire WE;

logic  [8:0] CYCLE;
always @(posedge clk) 
  begin
  if (reset)
    CYCLE <= 0;
  else
  begin
    if (CYCLE >= 3)
      CYCLE <= 0;
    else
      CYCLE <= CYCLE + 1;
  end
end

wire TIA_ENA  = (CYCLE == 0 || CYCLE == 2 || CYCLE == 3);
wire CPU_ENA  = (CYCLE == 1); 
wire RIOT_ENA = (CYCLE == 2);

//Funny Data Signals
logic [7:0] TIA_DATA_IN;
logic [7:0] RIOT_DATA_IN;
logic [7:0] ROM_DATA_IN;

logic [7:0] DATA_IN; 
logic [7:0] DATA_OUT;
logic [12:0] AB_W;
logic [12:0] AB_R;

wire [15:0] AB = CPU_ENA ? AB_W : AB_R;

//Chip Select
wire ROM_CS  = (AB[12] == 1);
wire TIA_CS  = (AB[12] == 0 && AB[7] == 0);
wire RIOT_CS = (AB[12] == 0 && AB[7] == 1 && AB[9] == 1);
wire RAM_CS  = (AB[12] == 0 && AB[7] == 1 && AB[9] == 0);

always @(posedge clk)
if (reset)
  AB_R <= 0;
else
  AB_R <= AB;

always @(posedge clk) 
begin
  if (RAM_CS) DATA_IN <= RIOT_DATA_IN;
  if (ROM_CS) DATA_IN <= ROM_DATA_IN;
  if (TIA_CS) DATA_IN <= TIA_DATA_IN;
  if (RIOT_CS) DATA_IN <= RIOT_DATA_IN;
end

//    
// CPU OPERATIONS
//

a6507 cpu_6507 
(
.clk(clk),                  //Main Clock
.reset(reset),              //Reset
.AB_13b(AB_W),              //Address Bus
.DI(DATA_IN),               //CPU -> ROM
.DO(DATA_OUT),              //Connection between cpu -> RIOT/TIA
.WE(WE),                    //Write Enable
.RDY(~RDY && CPU_ENA)       //CPU Ready  
);

//
//  ROM CONTROLLER
//  Turns the ROM synchronous b/c cpu is built for it

rom_controller rom_controller
(
.clk(clk),
.addr_cpu2ctrl(AB),             //connects Full Address Bus to ROM Controller
.data_ctrl2cpu(ROM_DATA_IN),    //connects Full Data Bus to ROM Controller
.addr_ctrl2rom(ab_ctrl_to_rom), // Connects AB from controller to ROM (syncs it)
.data_rom2ctrl(db_rom_to_ctrl)  //  Connects DB from controller to ROM 
);


//
//  TIA OPERATIONS
//

wire [7:0] TIA_DB_IN;
assign TIA_DB_IN = DATA_OUT;

wire [7:0] TIA_DB_OUT;

TIA A201 
(
.CLK(clk),
.RES(reset),
.CHIP_SEL(TIA_CS && CPU_ENA),
.WE(WE),
.IO_LATCH(),
.IO_DUMP(),
.AB_IN(AB[5:0]),
.DB_IN(DATA_OUT),
.RDY(RDY),
.AUD(AUD),
.DB_OUT(TIA_DATA_IN),
.VGA_VSYNC(VGA_VSYNC),
.VGA_VBLANK(VGA_VBLANK),
.VGA_RGB(VGA_RGB),
.VGA_X(VGA_X),
.VGA_Y(VGA_Y),
.VGA_ADDR(VGA_ADDR),
.VGA_WR(VGA_WR),
.CPU_ENABLE(CPU_ENA),
.TIA_ENABLE(TIA_ENA),
.INPT_4(l_action),
.audio_clk(audio_clk)
//.INPT_5()
);

//
//  RIOT OPERATIONS
//


						//swap to right when set up
logic [7:0] pa_lines;
logic [7:0] pb_lines;


							//left controller lines		  right controller lines
assign pa_lines = {l_right, l_left, l_down, l_up, 1'b0, 1'b0, 1'b0, 1'b0};

logic c_bw;
assign c_bw = 1'b1;

						//front switches
assign pb_lines = {right_diff, left_diff, 1'b0, 1'b0, c_bw, 1'b0, game_sel, game_reset};


RIOT A203 
(
.CLK(clk),
.RES(reset),
.WE(WE),

.RIOT_CS(RIOT_CS && CPU_ENA),
.RAM_CS(RAM_CS && CPU_ENA),

.DB_IN(DATA_OUT),
.PA_IN(pa_lines), 
.PB_IN(pb_lines),
.AB_IN(AB[6:0]),

.DB_OUT(RIOT_DATA_IN),
.PA_OUT(), 
.PB_OUT(), 
.IRQ(),

.RIOT_ENABLE(RIOT_ENA),
.CPU_ENABLE(CPU_ENA)
);

//update some output monitor signals
assign CS_WE_RDY = {ROM_CS, RIOT_CS, RAM_CS, TIA_CS, WE, RDY, clk};

endmodule