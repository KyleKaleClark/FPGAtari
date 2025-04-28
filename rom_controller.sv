module rom_controller(
    input clk,
    input logic [12:0] addr_cpu2ctrl,
    output logic [12:0] addr_ctrl2rom,
    input logic [7:0] data_rom2ctrl,
    output logic [7:0] data_ctrl2cpu
);

    // always_ff @(posedge clk) begin
    always_comb begin
        addr_ctrl2rom = {3'b000, addr_cpu2ctrl};
        
    end
    always_ff @(posedge clk) begin
        data_ctrl2cpu <= data_rom2ctrl;
    end


endmodule