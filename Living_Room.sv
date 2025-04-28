`define GRANDPRIX
/*
 _____ ____   ____    _   _             _ 
|  ___|  _ \ / ___|  / \ | |_ __ _ _ __(_)
| |_  | |_) | |  _  / _ \| __/ _` | '__| |
|  _| |  __/| |_| |/ ___ \ || (_| | |  | |
|_|   |_|    \____/_/   \_\__\__,_|_|  |_|

ASU Senior Capstone Project 2024-2025

*/

// This module represents the living room where you're playing an 50 year old game console in the year 2025
// In this distance, you can here small children laughing at you



module Living_Room(
    input logic clk,
    input logic manclk,
    input logic game_reset,
    input logic reset,
    input logic up,
	 input logic down,
    input logic left,
	 input logic right,
    input logic action,
    input logic clk_fwd,
    input logic [1:0] hex_choice,
    output logic [6:0] SevSeg5, SevSeg4, SevSeg3, SevSeg2, SevSeg1, SevSeg0,
    output logic [6:0] cs_we_rdy,

    output logic [3:0] oVGA_R,
    output logic [3:0] oVGA_G,
    output logic [3:0] oVGA_B,
    output logic oVGA_HS,
    output logic oVGA_VS,

	output [12:0]   DRAM_ADDR,
	output [1:0]    DRAM_BA,
	output          DRAM_CAS_N,
	output          DRAM_CKE,
	output          DRAM_CLK,
	output          DRAM_CS_N,
	inout  [15:0]   DRAM_DQ,
	output          DRAM_LDQM,
	output          DRAM_RAS_N,
	output          DRAM_UDQM,
	output          DRAM_WE_N
        //audio out
//,	output logic [1:0] AUD

//	`ifdef REALROM
	, output logic [12:0] address_bus,
	input logic [7:0] data_bus

//	`endif 

);

	//Comment/Uncommet depending on if you're connecting to real cart
	//`REALROM

logic clk25Mhz;
logic clk100Mhz;
logic clk1d9Mhz;

pll clker 
(
.inclk0(clk),       // 50 MHz clk
.c0(clk25Mhz),      // 25 MHz clk
.c1(clk100Mhz),     // 100 MHz clk
.c2(clk1d9Mhz),      // 1.19 MHz clk
.c3(audio_clk)
);

	logic system_clock;
    logic tv_type;
    logic left_diff;
    logic right_diff;
    logic game_sel;
    logic [6:0] l_contr;
    logic [6:0] r_contr;

    logic [23:0] TIA_RGB;
    logic [7:0] TIA_X;
    logic [8:0] TIA_Y;
    logic TIA_VSYNC;
    logic TIA_VBLANK;
    logic TIA_WR;
    logic [15:0] TIA_ADDR;

    wire [23:0] VGA_RGB;

    //logic [1:0] AUD;
    logic [7:0] seg [5:0];
	 
	 assign game_sel = 1'b1;
	 assign left_diff = 1'b1;
	 assign right_diff = 1'b1;


	//Pick Clocking Mode
	always_comb begin
		system_clock = clk1d9Mhz;
		if (manclk) begin	
			system_clock = ~clk_fwd;
		end
		else begin
			system_clock = clk1d9Mhz;
		end
	end

	//Pre-Loaded Game
//	`ifndef REALROM
//    //read/write cycle signals
//    logic [12:0] address_bus;
//    logic [7:0] data_bus;
	
	logic [12:0] addr_disp;
		assign addr_disp = address_bus;
	logic [7:0] data_disp;
		assign data_disp = data_bus;
    
//	memory mem (
//        .addr(address_bus),
//        .data(data_bus)
//    );
//	`endif
    
    //f. cycles
    logic [31:0] f_cycle;

    // Instantiate the atari2600 module
    atari2600 uut 
    (
        .clk(system_clock),
        .reset(reset),
        .db_rom_to_ctrl(data_bus),
        .ab_ctrl_to_rom(address_bus),
        .tv_type(tv_type),
        .left_diff(left_diff),
        .right_diff(right_diff),
        .game_sel(game_sel),
        .game_reset(game_reset),
        .l_contr(l_contr),
		  .l_action(action),
		  .l_left(~left),
		  .l_right(~right),
        .l_up(~up),
        .l_down(~down),
        .r_contr(r_contr),
        .VGA_RGB(TIA_RGB),
        .VGA_X(TIA_X),
        .VGA_Y(TIA_Y),
        .VGA_VSYNC(TIA_VSYNC),
        .VGA_VBLANK(TIA_VBLANK),
        .VGA_ADDR(TIA_ADDR),
        .VGA_WR(TIA_WR),
        .AUD(AUD),
		.CS_WE_RDY(cs_we_rdy),
	.audio_clk(audio_clk)
    );
	 
    // VGA timing parameters for 640x480 @ 60Hz, 25MHz pixel clock
    localparam H_ACTIVE = 640;
    localparam H_FP = 16;
    localparam H_SYNC = 96;
    localparam H_BP = 48;
    localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;

localparam V_ACTIVE = 480;
localparam V_FP = 10;
localparam V_SYNC = 2;
localparam V_BP = 33;
localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;

// Counters for scanning
logic [9:0] h_count;
logic [9:0] v_count;

always_ff @(posedge clk25Mhz or posedge reset) 
begin
    if (reset) begin
        h_count <= 0;
        v_count <= 0;
    end else begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end
end


logic        sdram_read_ack;
logic        sdram_write_ack;
logic [15:0] sdram_read_addr;
logic [15:0] sdram_data_out;
wire  [15:0] sdram_write_data = {TIA_RGB[23:20], TIA_RGB[15:12], TIA_RGB[7:4], 4'b0000};

wire [8:0] scaled_x = h_count >> 1;
wire [8:0] scaled_y = v_count >> 1;

assign sdram_read_addr = scaled_y * 160 + scaled_x;

sdram_controller sdram
(
    .iclk(clk100Mhz),
    .ireset(reset),
    .iwrite_req(TIA_WR),
    .iwrite_address(TIA_ADDR),
    .iwrite_data(sdram_write_data),
    .owrite_ack(sdram_write_ack),

    .iread_req(visible_area),
    .iread_address(sdram_read_addr),
    .oread_data(sdram_data_out),
    .oread_ack(sdram_read_ack),

    .DRAM_ADDR(DRAM_ADDR),
    .DRAM_BA(DRAM_BA),
    .DRAM_CAS_N(DRAM_CAS_N),
    .DRAM_CKE(DRAM_CKE),
    .DRAM_CLK(DRAM_CLK),
    .DRAM_CS_N(DRAM_CS_N),
    .DRAM_DQ(DRAM_DQ),
    .DRAM_LDQM(DRAM_LDQM),
    .DRAM_RAS_N(DRAM_RAS_N),
    .DRAM_UDQM(DRAM_UDQM),
    .DRAM_WE_N(DRAM_WE_N)
);

assign visible_area = (h_count < 320) && (v_count < 384);
// assign active_video = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

// Generate sync signals
assign oVGA_HS = (h_count >= H_ACTIVE + H_FP) && (h_count < H_ACTIVE + H_FP + H_SYNC);
assign oVGA_VS = (v_count >= V_ACTIVE + V_FP) && (v_count < V_ACTIVE + V_FP + V_SYNC);

// Generate colors dynamically (example pattern based on scan position)
assign oVGA_R = (visible_area) ? sdram_data_out[15:12]   : 4'b0;
assign oVGA_G = (visible_area) ? sdram_data_out[11:8]    : 4'b0;
assign oVGA_B = (visible_area) ? sdram_data_out[7:4]     : 4'b0;



	//Hex Display Information
	localparam ATARI = 2'b00, ADDR = 2'b01, DATA = 2'b10;

    always_comb begin
		seg[5] = "";
		seg[4] = "";
		seg[3] = "";
		seg[2] = "";
		seg[1] = "";
		seg[0] = "";
        case(hex_choice)
            ATARI : begin		//Default funny message
                seg[5] = "A";
                seg[4] = "t";
                seg[3] = "a";
                seg[2] = "r";
                seg[1] = "i";
                seg[0] = " ";
            end
            ADDR : begin		//Address Bus
                seg[5] = "A";
                seg[4] = "'";
                seg[3] = addr_disp[12];  
                seg[2] = addr_disp[11:8];
                seg[1] = addr_disp[7:4];
                seg[0] = addr_disp[3:0];
            end
            DATA : begin		//Data Bus
                seg[5] = "D";
                seg[4] = "A";
                seg[3] = "T";
                seg[2] = "'";
                seg[1] = data_disp[7:4];
                seg[0] = data_disp[3:0];
            end

			///UNFORTUNATLEY i have learned these are inaccessible w/out rewrites all the way down
			// PROGCOUNT : begin	//Program Counter
			// 	seg[5] = "P";
			// 	seg[4] = "C";
			// 	seg[3] = uut.cpu_6507.cpu6502.PC[15:12];  
			// 	seg[2] = uut.cpu_6507.cpu6502.PC[11:8];
			// 	seg[1] = uut.cpu_6507.cpu6502.PC[7:4];
			// 	seg[0] = uut.cpu_6507.cpu6502.PC[3:0];
			// end
			// XYREG : begin		//X & Y Registers
			// 	seg[5] = "X";
			// 	seg[4] = uut.cpu_6507.cpu6502.X[7:4];
			// 	seg[3] = uut.cpu_6507.cpu6502.X[3:0];
			// 	seg[2] = "Y";
			// 	seg[1] = uut.cpu_6507.cpu6502.Y[7:4];
			// 	seg[0] = uut.cpu_6507.cpu6502.Y[3:0];
			// end
			// SPACREG : begin		//Stack Pointer & Accumulator
			// 	seg[5] = "S";
			// 	seg[4] = uut.cpu_6507.cpu6502.S[7:4];
			// 	seg[3] = uut.cpu_6507.cpu6502.S[3:0];
			// 	seg[2] = "A";
			// 	seg[1] = uut.cpu_6507.cpu6502.A[7:4];
			// 	seg[0] = uut.cpu_6507.cpu6502.A[3:0];
			// end
        endcase
    end


	//Conv to Hex Display
    ASCII27Seg SevH0(seg[0], SevSeg0);
    ASCII27Seg SevH1(seg[1], SevSeg1);
    ASCII27Seg SevH2(seg[2], SevSeg2);
    ASCII27Seg SevH3(seg[3], SevSeg3);
    ASCII27Seg SevH4(seg[4], SevSeg4);
    ASCII27Seg SevH5(seg[5], SevSeg5);

endmodule


module clockdivider #(parameter DIVISOR = 2) (clk_in, rst, clk_out);

    input clk_in;
    input rst;
    output logic clk_out;
    
    logic [5:0] counter = 0;
    logic clk_reg = 0;
    
    always_ff @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_reg <= 0;
        end else if (counter == (DIVISOR/2 - 1)) begin
            counter <= 0;
            clk_reg <= ~clk_reg;
        end else begin
            counter <= counter + 1;
        end
    end
    
    assign clk_out = clk_reg;

endmodule
