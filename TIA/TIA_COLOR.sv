module TIA_COLOR (input [6:0] YIQ, output [23:0] RGB_OUT);

// YIQ IN = 00 , 0000 , 000X

logic [23:0] YIQ_2_RGB [0:127];

assign RGB_OUT = YIQ_2_RGB[YIQ];

initial
begin
    // NTSC Color Palette
    //  Grayscale (0)
    YIQ_2_RGB[0] = 24'h000000;
    YIQ_2_RGB[1] = 24'h404040;
    YIQ_2_RGB[2] = 24'h6C6C6C;
    YIQ_2_RGB[3] = 24'h909090;
    YIQ_2_RGB[4] = 24'hB0B0B0;
    YIQ_2_RGB[5] = 24'hC8C8C8;
    YIQ_2_RGB[6] = 24'hDCDCDC;
    YIQ_2_RGB[7] = 24'hECECEC;

    // Yellow Tones (1)
    YIQ_2_RGB[8]  = 24'h444400;
    YIQ_2_RGB[9]  = 24'h646410;
    YIQ_2_RGB[10] = 24'h848424;
    YIQ_2_RGB[11] = 24'hA0A034;
    YIQ_2_RGB[12] = 24'hB8B840;
    YIQ_2_RGB[13] = 24'hD0D050;
    YIQ_2_RGB[14] = 24'hE8E85C;
    YIQ_2_RGB[15] = 24'hFCFC68;

    // Orange Tones (2)
    YIQ_2_RGB[16] = 24'h702800;
    YIQ_2_RGB[17] = 24'h844414;
    YIQ_2_RGB[18] = 24'h985C28;
    YIQ_2_RGB[19] = 24'hAC783C;
    YIQ_2_RGB[20] = 24'hBC8C4C;
    YIQ_2_RGB[21] = 24'hCCA05C;
    YIQ_2_RGB[22] = 24'hDCB468;
    YIQ_2_RGB[23] = 24'hECC878;

    // Red Tones (3)
    YIQ_2_RGB[24] = 24'h841800;
    YIQ_2_RGB[25] = 24'h983418;
    YIQ_2_RGB[26] = 24'hAC5030;
    YIQ_2_RGB[27] = 24'hC06848;
    YIQ_2_RGB[28] = 24'hD0805C;
    YIQ_2_RGB[29] = 24'hE09470;
    YIQ_2_RGB[30] = 24'hECA880;
    YIQ_2_RGB[31] = 24'hFCBC94;

    // Pink Tones (4)
    YIQ_2_RGB[32] = 24'h880000;
    YIQ_2_RGB[33] = 24'h9C2020;
    YIQ_2_RGB[34] = 24'hB03C3C;
    YIQ_2_RGB[35] = 24'hC05858;
    YIQ_2_RGB[36] = 24'hD07070;
    YIQ_2_RGB[37] = 24'hE08888;
    YIQ_2_RGB[38] = 24'hECA0A0;
    YIQ_2_RGB[39] = 24'hFCB4B4;

    // Violet Tones (5)
    YIQ_2_RGB[40] = 24'h78005C;
    YIQ_2_RGB[41] = 24'h8C2074;
    YIQ_2_RGB[42] = 24'hA03C88;
    YIQ_2_RGB[43] = 24'hB0589C;
    YIQ_2_RGB[44] = 24'hC070B0;
    YIQ_2_RGB[45] = 24'hD084C0;
    YIQ_2_RGB[46] = 24'hDC9CD0;
    YIQ_2_RGB[47] = 24'hECB0E0;

    // Purple Tones (6)
    YIQ_2_RGB[48] = 24'h480078;
    YIQ_2_RGB[49] = 24'h602090;
    YIQ_2_RGB[50] = 24'h783CA4;
    YIQ_2_RGB[51] = 24'h8C58B8;
    YIQ_2_RGB[52] = 24'hA070CC;
    YIQ_2_RGB[53] = 24'hB484DC;
    YIQ_2_RGB[54] = 24'hC49CEC;
    YIQ_2_RGB[55] = 24'hD4B0FC;

    // Indigo Tones (7)
    YIQ_2_RGB[56] = 24'h140084;
    YIQ_2_RGB[57] = 24'h302098;
    YIQ_2_RGB[58] = 24'h4C3CAC;
    YIQ_2_RGB[59] = 24'h6858C0;
    YIQ_2_RGB[60] = 24'h7C70D0;
    YIQ_2_RGB[61] = 24'h9488E0;
    YIQ_2_RGB[62] = 24'hA8A0EC;
    YIQ_2_RGB[63] = 24'hBCB4FC;

    // Blue Tones (8)
    YIQ_2_RGB[64] = 24'h000088;
    YIQ_2_RGB[65] = 24'h1C209C;
    YIQ_2_RGB[66] = 24'h3840B0;
    YIQ_2_RGB[67] = 24'h505CC0;
    YIQ_2_RGB[68] = 24'h6874D0;
    YIQ_2_RGB[69] = 24'h7C8CE0;
    YIQ_2_RGB[70] = 24'h90A4EC;
    YIQ_2_RGB[71] = 24'hA4B8FC;

    // Aqua Tones (9)
    YIQ_2_RGB[72] = 24'h00187C;
    YIQ_2_RGB[73] = 24'h1C3890;
    YIQ_2_RGB[74] = 24'h3854A8;
    YIQ_2_RGB[75] = 24'h5070BC;
    YIQ_2_RGB[76] = 24'h6888CC;
    YIQ_2_RGB[77] = 24'h7C9CDC;
    YIQ_2_RGB[78] = 24'h90B4EC;
    YIQ_2_RGB[79] = 24'hA4C8FC;

    // Teal Tones (A)
    YIQ_2_RGB[80] = 24'h002C5C;
    YIQ_2_RGB[81] = 24'h1C4C78;
    YIQ_2_RGB[82] = 24'h386890;
    YIQ_2_RGB[83] = 24'h5084AC;
    YIQ_2_RGB[84] = 24'h689CC0;
    YIQ_2_RGB[85] = 24'h7CB4D4;
    YIQ_2_RGB[86] = 24'h90CCE8;
    YIQ_2_RGB[87] = 24'hA4E0FC;

    // Green Tones (B)
    YIQ_2_RGB[88] = 24'h003C2C;
    YIQ_2_RGB[89] = 24'h1C5C48;
    YIQ_2_RGB[90] = 24'h387C64;
    YIQ_2_RGB[91] = 24'h509C80;
    YIQ_2_RGB[92] = 24'h68B494;
    YIQ_2_RGB[93] = 24'h7CD0AC;
    YIQ_2_RGB[94] = 24'h90E4C0;
    YIQ_2_RGB[95] = 24'hA4FCD4;

    // Lime Tones (C)
    YIQ_2_RGB[96] = 24'h003C00;
    YIQ_2_RGB[97] = 24'h205C20;
    YIQ_2_RGB[98] = 24'h407C40;
    YIQ_2_RGB[99] = 24'h5C9C5C;
    YIQ_2_RGB[100] = 24'h74B474;
    YIQ_2_RGB[101] = 24'h8CD08C;
    YIQ_2_RGB[102] = 24'hA4E4A4;
    YIQ_2_RGB[103] = 24'hB8FCB8;

    // Olive Tones (D)
    YIQ_2_RGB[104] = 24'h143800;
    YIQ_2_RGB[105] = 24'h345C1C;
    YIQ_2_RGB[106] = 24'h507C38;
    YIQ_2_RGB[107] = 24'h6C9850;
    YIQ_2_RGB[108] = 24'h84B468;
    YIQ_2_RGB[109] = 24'h9CCC7C;
    YIQ_2_RGB[110] = 24'hB4E490;
    YIQ_2_RGB[111] = 24'hC8FCA4;

    // Yellow Tones  (E)
    YIQ_2_RGB[112] = 24'h2C3000;
    YIQ_2_RGB[113] = 24'h4C501C;
    YIQ_2_RGB[114] = 24'h687034;
    YIQ_2_RGB[115] = 24'h848C4C;
    YIQ_2_RGB[116] = 24'h9CA864;
    YIQ_2_RGB[117] = 24'hB4C078;
    YIQ_2_RGB[118] = 24'hCCD488;
    YIQ_2_RGB[119] = 24'hE0EC9C;

    // Orange Tones (F)
    YIQ_2_RGB[120] = 24'h442800;
    YIQ_2_RGB[121] = 24'h644818;
    YIQ_2_RGB[122] = 24'h846830;
    YIQ_2_RGB[123] = 24'hA08444;
    YIQ_2_RGB[124] = 24'hB89C58;
    YIQ_2_RGB[125] = 24'hD0B46C;
    YIQ_2_RGB[126] = 24'hE8CC7C;
    YIQ_2_RGB[127] = 24'hFCE08C;

end

endmodule