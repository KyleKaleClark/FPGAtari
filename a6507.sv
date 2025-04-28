/*
 _____ ____   ____    _   _             _ 
|  ___|  _ \ / ___|  / \ | |_ __ _ _ __(_)
| |_  | |_) | |  _  / _ \| __/ _` | '__| |
|  _| |  __/| |_| |/ ___ \ || (_| | |  | |
|_|   |_|    \____/_/   \_\__\__,_|_|  |_|

ASU Senior Capstone Project 2024-2025
*/

///////////////////////////////////////////////////////////////
//             6502 -> 6507 Conversion Module                //  
// Certain signals need to be "cut", as they aren't avail.   // 
// on the 6507 but are available on the 6502.                //
// NMI and IRQ interrupts DNE so hold high (active low pins) //
// to prevent them from ever getting activated.              //
// We also trim the Address bus, assigning top 3 bits        //
// to 0 to ensure that our max addressable value is $1FFF.   //
// Even if a higher value is passed into AB, we only grab    //
// bottom 13 bits                                            //
// i.e. Reset Vector -> $FFFC = 1111 1111 1111 1100          //                         
//             set top 3 to 0 = 0001 1111 1111 1100 = $1FFC  //
//                Atari's Reset Vector :D  -------------^    //
///////////////////////////////////////////////////////////////


module a6507(
    input clk, reset,
    output logic [12:0] AB_13b,
    input logic [7:0] DI,
    output logic [7:0] DO,
    output WE,
    input RDY
);
    //init intermediate signals
    logic [15:0] AB16b_2_13b;
    logic NMI_deactive, IRQ_deactive;

    //get signals from 6502
    cpu cpu6502(
        .clk(clk),
        .reset(reset),
        .AB(AB16b_2_13b), //pass in the padded address bus so comptible but still forced to a max of $1FFF
        .DO(DO),
        .DI(DI),
        .WE(WE),
        .IRQ(IRQ_deactive),
        .NMI(NMI_deactive),
        .RDY(RDY)
    );

    //conversions
    assign NMI_deactive = 1; //Keep this high to deactivate since it isn't compatible
    assign IRQ_deactive = 1; // samesy
    assign AB_13b = AB16b_2_13b[12:0]; // takes the bottom 13b/16b of 6502 Address Bus
    



endmodule