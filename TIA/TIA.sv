/*
 _____ ____   ____    _   _             _ 
|  ___|  _ \ / ___|  / \ | |_ __ _ _ __(_)
| |_  | |_) | |  _  / _ \| __/ _` | '__| |
|  _| |  __/| |_| |/ ___ \ || (_| | |  | |
|_|   |_|    \____/_/   \_\__\__,_|_|  |_|

ASU Senior Capstone Project 2024-2025

*/

// Module for the Television Interface Adapter (TIA) [A201]


// 40 Pin Package

/* 

Input Ports:

Data Bus (8 bits) 								[D0,D1,D2,D3,D4,D5,D6*,D7*]
Address Bus from MOS6507 (6 bits) 				[A0,A1,A2,A3,A4,A5] 
Chip Selects 									[CS0,CS1*,CS2,CS3]
Dumped Input Ports          					[I0,I1,I2,I3]
Latched Input Ports 	                        [I4,I5]
Clock Input 									[OSC]
Phase Clock from MOS6507 						[O2]
Read/Write from MOS6507 						[R/W]
Color Delay Input								[DEL]

Output Ports:

Data Bus (8 bits) 								[D0,D1,D2,D3,D4,D5,D6*,D7*]
Video Luminance									[LUM0,LUM1,LUM2]
Audio											[AUD0,AUD1]
Composite Video Sync							[SYNC]
Processor Halt to MOS6507						[RDY]
Phase Clock to MOS6507							[O0]
Vertical Blanking								[BLK]
Video Color										[COLU]

Synchronizations:


Master System Clock - 3.58 Mhz
Color Clock - 3.58 Mhz / 3

Horizontal Timing - Entirely done internally by the TIA
Vertical Timing - VSYNC and VBLANK are written to by the CPU
Composite Sync - HSYNC and VSYNC are combined to produce CSYNC

*/

`timescale 1ns / 1ps

// Main TIA Module
module TIA (

input CLK,
input RES,

input CHIP_SEL, 
input WE,
input [1:0] IO_LATCH,
input [3:0] IO_DUMP,
input [5:0] AB_IN,
input [7:0] DB_IN,

output logic RDY, 
output [1:0] AUD,
output logic [7:0] DB_OUT,

output logic [23:0] VGA_RGB,
output logic VGA_VBLANK,
output logic VGA_VSYNC,
output [15:0] VGA_ADDR, 
output [7:0] VGA_X,
output [8:0] VGA_Y,
output logic VGA_WR,

input CPU_ENABLE,
input TIA_ENABLE,
input INPT_4,

input audio_clk

);

// RGB COLOR TABLE
logic [6:0] COLU;

TIA_COLOR RGB (.YIQ(COLU),.RGB_OUT(VGA_RGB));


//Audio stuff
logic AUDC0_OUT, AUDF0_OUT, AUDC1_OUT, AUDF1_OUT;

//Channel 0
AUDC AUDC0(audio_clk, RES, AUD_C0, AUDC0_OUT);
AUDF AUDF0(AUDC0_OUT, RES, AUD_F0, AUDF0_OUT);
AUDV AUDV0(AUDF0_OUT, RES, AUD_V0, AUD[0]);

//Channel 1
AUDC AUDC1(audio_clk, RES, AUD_C1, AUDC1_OUT);
AUDF AUDFC1(AUDC1_OUT, RES, AUD_F1, AUDF1_OUT);
AUDV AUDV1(AUDF1_OUT, RES, AUD_V1, AUD[1]);



//
//  REGISTERS
//                                                

logic VSYNC;                // Vertical sync set-clear                  
logic VBLANK;               // Vertical blank set-clear                 
logic WSYNC;                // Wait for Sync                            
logic RSYNC;                // Reset Horizontal Sync Counter            
logic [7:0] P0_POSI;        // Position for Player 0
logic [7:0] P1_POSI;        // Position for Player 1 
logic [7:0] M0_POSI;        // Position for Missile 0 
logic [7:0] M1_POSI;        // Position for Missile 1 
logic [7:0] BL_POSI;        // Position for Ball                    
logic [5:0] P0_SIZ = 8;     // Number-size for Player 0
logic [5:0] P1_SIZ = 8;     // Number-size for Player 1
logic [3:0] M0_SIZ = 1;     // Number-size for Missile 0
logic [3:0] M1_SIZ = 1;     // Number-size for Missile 1
logic [3:0] BL_SIZ = 1;     // Number-size for Ball
logic [6:0] P0_COLU;        // Color-lum for Player 0 and Missile 0     
logic [6:0] P1_COLU;        // Color-lum for Player 1 and Missile 1     
logic [6:0] PF_COLU;        // Color-lum for Playfield and Ball         
logic [6:0] BK_COLU;        // Color-lum for Background                 
logic PF_SCORE;             // Playfield Score
logic PF_PRIORITY;          // Playfield Priority                       
logic PF_REF;               // Reflect Playfield                        
logic P0_REF;               // Reflect Player 0                         (P0_REFG)
logic P1_REF;               // Reflect Player 1                         (P1_REF)
logic [19:0] PF;            // Playfield Register 0,1,2                 (PF0, PF1, PF2)
logic [3:0] AUD_C0;         // Audio Control 0                          (AUDC0)
logic [3:0] AUD_C1;         // Audio Control 1                          (AUDC1)
logic [3:0] AUD_V0;         // Audio Volume 0                           (AUDV0)
logic [3:0] AUD_V1;         // Audio Volume 1                           (AUDV1)
logic [4:0] AUD_F0;         // Audio Frequency 0                        (AUDF0)
logic [4:0] AUD_F1;         // Audio Frequency 1                        (AUDF1)
logic [7:0] P0_GRP;         // Player 0 Graphics                        (P0_GRP)
logic [7:0] P1_GRP;         // Player 0 Graphics                        (P1_GRP)
logic M0_ENA;               // Enable Missile 0 Graphics                (ENAM0)
logic M1_ENA;               // Enable Missile 1 Graphics                (ENAM1)
logic BL_ENA;               // Enable Ball Graphics                     (ENABL)
logic signed [7:0] P0_HM;   // Horizontal Motion for Player 0           (HMP0)
logic signed [7:0] P1_HM;   // Horizontal Motion for Player 1           (HMP1)
logic signed [7:0] M0_HM;   // Horizontal Motion for Missile 0          (HMM0)
logic signed [7:0] M1_HM;   // Horizontal Motion for Missile 1          (HMM1)
logic signed [7:0] BL_HM;   // Horizontal Motion for Ball               (HMBL)
logic P0_VDEL;              // Vertical Delay for Player 0              (P0_VDEL)
logic P1_VDEL;              // Vertical Delay for Player 1              (P1_VDEL)
logic BL_VDEL;              // Vertical Delay for Ball                  (VDELBL)
logic CX_RES;               // Clear Collision Latches                  (CXCLR)

logic [14:0] CX;            // Read collision                           (CX)
logic INPT_0 = 0;           // Read potentiometor port                  (INPT0)
logic INPT_1 = 0;           // Read potentiometor port                  (INPT1)
logic INPT_2 = 0;           // Read potentiometor port                  (INPT2)
logic INPT_3 = 0;           // Read potentiometor port                  (INPT3)
//logic INPT_4 = 0;           // Read input                               (INPT4)
logic INPT_5 = 0;           // Read input                               (INPT5)

logic LATCH;
logic DUMP;

// Variables for Player Sizing and Spacing

// Size of Screen Objects
logic M0_LOCK, M1_LOCK;

// Normal, Double, Quad Sized
logic [1:0] P0_SCALE, P1_SCALE;

// Zero, One, Two Duplicates
logic [1:0] P0_DUPE, P1_DUPE;

// Close, Medium, Wide Spacing
logic [6:0] P0_SPACE, P1_SPACE;

logic [7:0] P0_GRP_DEL, P1_GRP_DEL;

assign RDY = WSYNC;

// Video
logic [9:0] VID_X;
logic [9:0] VID_Y;

assign VGA_ADDR = VID_Y * 160 + VID_X;
assign VGA_VSYNC = VSYNC;
assign VGA_VBLANK = VBLANK;
assign VGA_X = VID_X;
assign VGA_Y = VID_Y;

integer i;

wire       PF_OBJ   = PF[VID_X < 80 ? (VID_X >> 2) : ((!PF_REF ? VID_X - 80 : 159 - VID_X) >> 2)];

wire       P0_OBJ  = (VID_X >= P0_POSI && VID_X < P0_POSI + P0_SIZ || (P0_DUPE > 0 && ((VID_X - P0_SPACE) >= P0_POSI && (VID_X - P0_SPACE) < P0_POSI + P0_SIZ)) || (P0_DUPE > 1 && ((VID_X - (P0_SPACE << 1)) >= P0_POSI && (VID_X - (P0_SPACE << 1)) < P0_POSI + P0_SIZ))) && (P0_VDEL ?  P0_GRP_DEL[P0_REF ? (VID_X - P0_POSI) >> P0_SCALE  : 7 - ((VID_X - P0_POSI) >> P0_SCALE)] : P0_GRP[P0_REF ? (VID_X - P0_POSI) >> P0_SCALE  : 7 - ((VID_X - P0_POSI) >> P0_SCALE)]);
wire       P1_OBJ  = (VID_X >= P1_POSI && VID_X < P1_POSI + P0_SIZ || (P1_DUPE > 0 && ((VID_X - P1_SPACE) >= P1_POSI && (VID_X - P1_SPACE) < P1_POSI + P0_SIZ)) || (P1_DUPE > 1 && ((VID_X - (P1_SPACE << 1)) >= P1_POSI && (VID_X - (P1_SPACE << 1)) < P1_POSI + P0_SIZ))) && (P1_VDEL ? P1_GRP_DEL[P1_REF ? (VID_X - P1_POSI) >> P1_SCALE : 7 - ((VID_X - P1_POSI) >> P1_SCALE)] : P1_GRP[P1_REF ? (VID_X - P1_POSI) >> P1_SCALE : 7 - ((VID_X - P1_POSI) >> P1_SCALE)]);
wire       BL_OBJ  = BL_ENA && VID_X >= BL_POSI && VID_X < BL_POSI + BL_SIZ;
wire       M0_OBJ  = M0_ENA && VID_X >= M0_POSI && VID_X < M0_POSI + M0_SIZ;
wire       M1_OBJ  = M1_ENA && VID_X >= M1_POSI && VID_X < M1_POSI + M1_SIZ;
wire [6:0] PF_TEMP = (PF_SCORE ? (VID_X < 160 ? P0_COLU : P1_COLU) : PF_COLU);

// 
// TIA LOGIC
//

always @ (posedge CLK)
begin
    if (CHIP_SEL && ~WE)
    begin
        DB_OUT <= 8'b0;
        case (AB_IN[3:0])
            'h0 : DB_OUT <= CX[14:13] << 6;             // CXM0P
            'h1 : DB_OUT <= CX[12:11] << 6;             // CXM1P
            'h2 : DB_OUT <= CX[10:9] << 6;              // CXP0FB
            'h3 : DB_OUT <= CX[8:7] << 6;               // CXP1FB
            'h4 : DB_OUT <= CX[6:5] << 6;               // CXM0FB
            'h5 : DB_OUT <= CX[4:3] << 6;               // CXM1FB
            'h6 : DB_OUT <= CX[2] << 7;                 // CXBLPF
            'h7 : DB_OUT <= CX[1:0] << 6;               // CXPPMM
            'h8 : DB_OUT <= INPT_0 << 7;                // INPT0
            'h9 : DB_OUT <= INPT_1 << 7;                // INPT1
            'hA : DB_OUT <= INPT_2 << 7;                // INPT2
            'hB : DB_OUT <= INPT_3 << 7;                // INPT3
            'hC : DB_OUT <= INPT_4 << 7;                // INPT4
            'hD : DB_OUT <= INPT_5 << 7;                // INPT5
        endcase
    end
end

always @ (posedge CLK) 
begin
    if (RES)
        begin
            VSYNC <= 0;                 // VSYNC (Vertical Sync Set-Clear)                                                                                            
            VBLANK <= 0;                // VBLANK (Vertical Blank Set-Clear)
            WSYNC <= 0;                 // WSYNC (Wait for Leading Edge of Horizontal Blank)
            RSYNC <= 0;                 // RSYNC (Reset Horizontal Sync Counter)
            P0_SIZ <= 0;                // NUSIZ0 (Number-Size Player-Missile 0)
            P1_SIZ <= 0;                // NUSIZ1 (Number-Size Player-Missile 1)
            P0_COLU <= 0;               // COLUP0 (Color-Lum Player O)
            P1_COLU <= 0;               // COLUP1 (Color-Lum Player 1)
            PF_COLU <= 0;               // COLUPF (Color-Lum Playfield)
            BK_COLU <= 0;               // COLUBK (Color-Lum Background)
            PF_SCORE <= 0;              // CTRLPF (Control Playfield Ball Size & Collisions)
            PF_PRIORITY <= 0;
            PF_REF <= 0;
            BL_SIZ <= 0;                                                                      
            P0_REF <= 0;                // P0_REFG (Reflect Player 0)
            P1_REF <= 0;                // P1_REF (Reflect Player 1)
            PF <= 0;                    // PF0-2 (Playfield Register 0-2)
            AUD_C0 <= 0;                // AUDC0 (Audio Control 0)
            AUD_C1 <= 0;                // AUDC1 (Audio Control 1)
            AUD_F0 <= 0;                // AUDF0 (Audio Frequency 0)
            AUD_F1 <= 0;                // AUDF1 (Audio Frequency 1)
            AUD_V0 <= 0;                // AUDV0 (Audio Volume 0)
            AUD_V1 <= 0;                // AUDV1 (Audio Volume 1)
            P0_GRP <= 0;                // P0_GRP (Graphics Player 0)
            P1_GRP <= 0;                // P1_GRP (Graphics Player 1)
            M0_ENA <= 0;                // ENAM0 (Graphics Enable Missile 0)
            M1_ENA <= 0;                // ENAM1 (Graphics Enable Missile 1)
            BL_ENA <= 0;                // ENABL (Graphics Enable Ball)
            P0_HM  <= 0;                // HMP0 (Horizontal Motion Player 0)
            P1_HM  <= 0;                // HMP1 (Horizontal Motion Player 1)
            M0_HM  <= 0;                // HMM0 (Horizontal Motion Missile 0)
            M1_HM  <= 0;                // HMM1 (Horizontal Motion Missile 1)
            BL_HM  <= 0;                // HMBL (Horizontal Motion Ball)
            P0_VDEL <= 0;               // P0_VDEL (Vertical Delay Player 0)
            P1_VDEL <= 0;               // P1_VDEL (Vertical Delay Player 1)
            BL_VDEL <= 0;               // VDELBL (Vertical Delay Ball)
            CX_RES <= 0;                // CXCLR (Clear Collision Latches)
            CX <= 0;
            P0_POSI <= 0;
            P1_POSI <= 0;
            M0_POSI <= 0;
            M1_POSI <= 0;
            BL_POSI <= 0;
            M0_LOCK <= 0;
            M1_LOCK <= 0;
            M0_SIZ <= 0;
            M1_SIZ <= 0;
            P0_SCALE <= 0;
            P1_SCALE <= 0;
            P0_SPACE <= 0;
            P1_SPACE <= 0;
            P0_DUPE <= 0;
            P1_DUPE <= 0;
            VID_X <= 0;
            VID_Y <= 0;
            WSYNC <= 0;
            VGA_WR <= 0;
            COLU <= 0;
        end

    else if (CPU_ENABLE)
    begin
    
        CX_RES <= 0;

        if (CHIP_SEL && WE)
        begin
            case (AB_IN)
                'h00 :                                                                                              // VSYNC (Vertical Sync Set-Clear)
                begin
                    VSYNC <= DB_IN[1];

                    if (VSYNC == 0 && DB_IN[1] == 1) 
                        begin
                            VID_X <= 0;
                            VID_Y <= 0;
                        end
                end
                'h01 :                                                                                              // VBLANK (Vertical Blank Set-Clear)
                begin
                    VBLANK <= DB_IN[1];
                    LATCH <= DB_IN[6];
                    DUMP <= DB_IN[7];
                    begin
                        VID_X <= 0;
                        VID_Y <= 0;
                    end
                end
                'h02 : WSYNC <= 1'b1;                                                                               // WSYNC (Wait for Leading Edge of Horizontal Blank)                                                                                        
                'h03 : VID_Y <= 0;                                                                                  // RSYNC (Reset Horizontal Sync Counter)
                'h04 :                                                                                              // NUSIZ0 (Number-Size Player-Missile 0)
                begin
                    M0_SIZ <= (1 << DB_IN[5:4]);
                    P0_SCALE <= 0;
                    case (DB_IN[2:0])
                        0 : begin P0_SIZ <= 8; P0_DUPE <= 0;                 end // One Copy
                        1 : begin P0_SIZ <= 8; P0_DUPE <= 1; P0_SPACE <= 16; end // Two Copies - Close
                        2 : begin P0_SIZ <= 8; P0_DUPE <= 1; P0_SPACE <= 32; end // Two Copies - Medium
                        3 : begin P0_SIZ <= 8; P0_DUPE <= 2; P0_SPACE <= 16; end // Three Copies - Close
                        4 : begin P0_SIZ <= 8; P0_DUPE <= 1; P0_SPACE <= 64; end // Two Copies - Wide
                        5 : begin P0_SIZ <= 16; P0_SCALE <= 1; P0_DUPE <= 0; end // Double Size Player
                        6 : begin P0_SIZ <= 8; P0_DUPE <= 2; P0_SPACE <= 32; end // 3 Copies - Medium
                        7 : begin P0_SIZ <= 32; P0_SCALE <= 2; P0_DUPE <= 0; end // Quad Sized Player
                    endcase
                end
                'h05 :                                                                                              // NUSIZ1 (Number-Size Player-Missile 1)
                begin
                    M1_SIZ <= (1 << DB_IN[5:4]);
                    P1_SCALE <= 0;
                    case (DB_IN[2:0])
                        0 : begin P1_SIZ <= 8; P1_DUPE <= 0;                 end // One Copy
                        1 : begin P1_SIZ <= 8; P1_DUPE <= 1; P1_SPACE <= 16; end // Two Copies - Close
                        2 : begin P1_SIZ <= 8; P1_DUPE <= 1; P1_SPACE <= 32; end // Two Copies - Medium
                        3 : begin P1_SIZ <= 8; P1_DUPE <= 2; P1_SPACE <= 16; end // Three Copies - Close
                        4 : begin P1_SIZ <= 8; P1_DUPE <= 1; P1_SPACE <= 64; end // Two Copies - Wide
                        5 : begin P1_SIZ <= 16; P1_SCALE <= 1; P1_DUPE <= 0; end // Double Size Player
                        6 : begin P1_SIZ <= 8; P1_DUPE <= 2; P1_SPACE <= 32; end // 3 Copies - Medium
                        7 : begin P1_SIZ <= 32; P1_SCALE <= 2; P1_DUPE <= 0; end // Quad Sized Player
                    endcase
                end
                'h06 : P0_COLU <= DB_IN[7:1];                                                                       // COLUP0 (Color-Lum Player O)
                'h07 : P1_COLU <= DB_IN[7:1];                                                                       // COLUP1 (Color-Lum Player 1)
                'h08 : PF_COLU <= DB_IN[7:1];                                                                       // COLUPF (Color-Lum Playfield)
                'h09 : BK_COLU <= DB_IN[7:1];                                                                       // COLUBK (Color-Lum Background)
                'h0A :                                                                                              // CTRLPF (Control Playfield Ball Size & Collisions)
                begin                                                                                                
                    PF_REF <= DB_IN[0];
                    PF_SCORE <= DB_IN[1];
                    PF_PRIORITY <= DB_IN[2];
                    BL_SIZ <= (1 << DB_IN[5:4]);                                                 
                end
                'h0B : P0_REF <= DB_IN[3];                                                                          // P0_REFG (Reflect Player 0)
                'h0C : P1_REF <= DB_IN[3];                                                                          // P1_REF (Reflect Player 1)
                'h0D : for(i = 0; i<4; i = i + 1) PF[i] <= DB_IN[4+i];                                              // PF0 (Playefield Register Byte 0)
                'h0E : for(i = 0; i<8; i = i + 1) PF[4+i] <= DB_IN[7-i];                                            // PF1 (Playfield Register Byte 1)
                'h0F : for(i = 0; i<8; i = i + 1) PF[12+i] = DB_IN[i];                                              // PF2 (Playfield Register Byte 2)
                'h10 : P0_POSI <= (VID_X >= 160) ? 0 : VID_X + 5;                                                   // RESP0 (Reset Player 0)
                'h11 : P1_POSI <= (VID_X >= 160) ? 0 : VID_X + 5;                                                   // RESP1 (Reset Player 2)
                'h12 : M0_POSI <= (VID_X >= 160) ? 0 : VID_X + 5;                                                   // RESM0 (Reset Missile 0)
                'h13 : M1_POSI <= (VID_X >= 160) ? 0 : VID_X + 5;                                                   // RESM1 (Reset Missile 2)
                'h14 : BL_POSI <= (VID_X >= 160) ? 0 : VID_X + 5;                                                   // RESBL (Reset Ball)
                'h15 : AUD_C0 <= DB_IN[3:0];                                                                        // AUDC0 (Audio Control 0)
                'h16 : AUD_C1 <= DB_IN[3:0];                                                                        // AUDC1 (Audio Control 1)
                'h17 : AUD_F0 <= DB_IN[4:0];                                                                        // AUDF0 (Audio Frequency 0)
                'h18 : AUD_F1 <= DB_IN[4:0];                                                                        // AUDF1 (Audio Frequency 1)
                'h19 : AUD_V0 <= DB_IN[3:0];                                                                        // AUDV0 (Audio Volume 0)
                'h1A : AUD_V1 <= DB_IN[3:0];                                                                        // AUDV1 (Audio Volume 1)
                'h1B : begin P0_GRP <= DB_IN; P1_GRP_DEL <= P1_GRP; end                                             // P0_GRP (Graphics Player 0)
                'h1C : begin P1_GRP <= DB_IN; P0_GRP_DEL <= P0_GRP; end                                             // P1_GRP (Graphics Player 1)
                'h1D : M0_ENA <= DB_IN[1];                                                                          // ENAM0 (Graphics Enable Missile 0)
                'h1E : M1_ENA <= DB_IN[1];                                                                          // ENAM1 (Graphics Enable Missile 1)
                'h1F : BL_ENA <= DB_IN[1];                                                                          // ENABL (Graphics Enable Ball)
                'h20 : P0_HM  <= $signed(DB_IN[7:4]);                                                               // HMP0 (Horizontal Motion Player 0)
                'h21 : P1_HM  <= $signed(DB_IN[7:4]);                                                               // HMP1 (Horizontal Motion Player 1)
                'h22 : M0_HM  <= $signed(DB_IN[7:4]);                                                               // HMM0 (Horizontal Motion Missile 0)
                'h23 : M1_HM  <= $signed(DB_IN[7:4]);                                                               // HMM1 (Horizontal Motion Missile 1)
                'h24 : BL_HM  <= $signed(DB_IN[7:4]);                                                               // HMBL (Horizontal Motion Ball)
                'h25 : P0_VDEL <= DB_IN[0];                                                                         // P0_VDEL (Vertical Delay Player 0)
                'h26 : P1_VDEL <= DB_IN[0];                                                                         // P1_VDEL (Vertical Delay Player 1)
                'h27 : BL_VDEL <= DB_IN[0];                                                                         // VDELBL (Vertical Delay Ball)
                'h28 :                                                                                              // RESMP0 (Reset Missile 0 to Player 0)
                begin
                    M0_POSI <= P0_POSI + (P0_SIZ >> 1);
                    M0_LOCK <= DB_IN[1];
                end
                'h29 :                                                                                              // RESMP1 (Reset Missile 1 to Player 1)
                begin 
                    M1_POSI <= P0_POSI + (P1_SIZ >> 1);
                    M1_LOCK <= DB_IN[1]; 
                end
                'h2A :                                                                                              // HMOVE (Apply Horizontal Motion)
                begin
                    P0_POSI <= P0_POSI - P0_HM;
                    P1_POSI <= P1_POSI - P1_HM;
                    M0_POSI <= M0_POSI - M0_HM;
                    M1_POSI <= M1_POSI - M1_HM;
                    BL_POSI <= BL_POSI - BL_HM;                                                                                               
                end
                'h2B :                                                                                              // HMCLR (Clear Horizontal Motion Registers)
                begin
                    P0_HM <= 0;              
                    P1_HM <= 0;
                    M0_HM <= 0;  
                    M1_HM <= 0;  
                    BL_HM <= 0;
                end
                'h2C : CX_RES <= 1;                                                                                 // Clear Collision Latches (CXCLR)
            endcase
        end
    end

    if (VID_X == 160)
        WSYNC <= 0;

    if (TIA_ENABLE) 
    begin
        if (CX_RES) CX <= 0;

        VGA_WR <= 0;
        
        if (VID_Y < 261)
        begin
            if (VID_X < 227)
                begin
                    VID_X <= VID_X + 1;
                end
            else
                begin
                    VID_X <= 0;
                    VID_Y <= VID_Y + 1;
                end

            //
            // Collisions
            // 

            // (M0 & P1) and (M0 & P0)
            if (M0_OBJ) 
                begin
                    if (P1_OBJ) 
                        CX[14] <= 1;
                    if (P0_OBJ) 
                        CX[13] <= 1;
                end

            // (M1 & P0) and (M1 & P1)
            if (M1_OBJ) 
                begin
                    if (P0_OBJ) 
                        CX[12] <= 1;
                    if (P1_OBJ) 
                        CX[11] <= 1;
                end
            
            // (P0 & PF) and (P0 & BL)
            if (P0_OBJ) 
                begin
                    if (PF_OBJ) 
                        CX[10] <= 1;
                    if (BL_OBJ) 
                        CX[9] <= 1;
                end

            // (P1 & PF) and (P1 & BL)
            if (P1_OBJ) 
                begin
                    if (PF_OBJ) 
                        CX[8] <= 1;
                    if (BL_OBJ) 
                        CX[7] <= 1;
                end

            // (M0 & PF) and (M0 & BL)
            if (M0_OBJ) 
                begin
                    if (PF_OBJ) 
                        CX[6] <= 1;
                    if (BL_OBJ) 
                        CX[5] <= 1;
                end

            // (M1 & PF) and (M1 & BL)
            if (M1_OBJ) 
                begin
                    if (PF_OBJ) 
                        CX[4] <= 1;
                    if (BL_OBJ) 
                        CX[3] <= 1;
                end

            if (BL_OBJ && PF_OBJ)
                CX[2] <= 1;

            if (P0_OBJ && P1_OBJ)
                CX[1] <= 1;

            if (M0_OBJ && M1_OBJ)
                CX[0] <= 1;
                
            // Draw VGA Display
            if (VID_Y < 192 && VID_X < 160 && VBLANK == 0)
            begin
                COLU <= BL_OBJ ? PF_COLU : 
                    M0_OBJ ? P0_COLU : 
                    M1_OBJ ? P1_COLU : 
                    PF_PRIORITY && PF_OBJ ? PF_TEMP : 
                    P0_OBJ ? P0_COLU : 
                    P1_OBJ ? P1_COLU : 
                    PF_OBJ ? PF_TEMP : BK_COLU;
                VGA_WR <= 1;
            end
        end
        else
        begin
            VID_Y <= 0;
        end
    end
end
endmodule

