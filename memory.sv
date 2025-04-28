module memory(
	input logic [12:0] addr,
	output logic [7:0] data
	// input logic WE,
	// input logic [7:0] DO
);

	// logic [7:0] test_data [65279:0];
    // logic [7:0] zeropage [255:0]; //= '{default: 8'h01}; //01 is just so i can ensure it exists

    logic [7:0] mem [4095:0];

    always_comb begin
        //we have to bring it down some so that its in the right rom addr
        //i.e. opcode at addr 0x1000 is stored in the mem array at mem[0]
        //so when we pass in 0x1000 - 13'h1000, we get the 0 index'd
        data = mem[addr-13'h1000];
        //this actually needs to change once we get to physical b/c it'll have this offset
        //built into the physical cartridges essentially.
    end

    //Old fake RAM
	// always_ff @(negedge WE) begin
	// 	zeropage[addr[7:0]] = DO;
	// 	// zeropage[2] = 8'h0F;
	// end


    //load in test file
    initial begin
        //You can sub in whatever .hex file you want here
        $readmemh("atari.hex", mem);

    end

    // how we fake broke up memory space
    // assign mem[255:0] = zeropage;
    // assign mem[65535:256] = test_data;

endmodule




