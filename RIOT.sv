module RIOT
(
    input CLK,
    input RES,
    input WE,

    input RIOT_CS,
    input RAM_CS,

	input [7:0] DB_IN, 
    input [7:0] PA_IN, 
    input [7:0] PB_IN,
	input [6:0] AB_IN,

	output logic [7:0] DB_OUT, 
    output logic [7:0] PA_OUT, 
    output logic [7:0] PB_OUT, 
	output logic IRQ,

    input RIOT_ENABLE,
    input CPU_ENABLE
);						


// RAM Register
logic [7:0] RAM [127:0];

logic [7:0] irq_reg;
logic [1:0] irq_en;						

logic [7:0] DDRA;
logic [7:0] DDRB;
logic [7:0] DRA;
logic [7:0] DRB;

//setting data directions for peripheral ports:
assign PA_OUT = DDRA & DRA;
assign PB_OUT = DDRB & DRB; 

//setting PA7 line for edge detection 
logic PA7;
assign PA7 = (PA_IN[7] & ~DDRA[7]) | (DRA[7] & DDRA[7]);



// Timer Registers
logic [9:0] PRESCALE;
logic TIM_RES;
logic [1:0] MODE;

logic [23:0] TIMER_COUNTER;

logic [7:0] TIMER;
logic [7:0] TIMER_REG;

logic TIM_IRQ;
logic TIM_FLAG;

logic PA7_FLAG;
logic PA7_IRQ;
logic PA7_MODE;

logic [4:0] CNT;

// RIOT OPERATIONS
always @ (posedge CLK)
begin

	// Reset
	if (RES) 
	begin
		DRA <= 8'b0;    // Temporary
		DRB <= 8'b0;    // Temporary
		DDRA <= 8'b0;   // Temporary
		DDRB <= 8'b0;   // Temporary
            
        PRESCALE <= 0;
        TIM_RES <= 0;
        TIMER_COUNTER <= 0;
        TIMER <= 0;
        TIMER_REG <= 0;
        CNT <= 0;

        RAM <= '{128{8'h00}};
	end

    else
    begin
    
        if (RIOT_CS)
            TIMER_REG <= 0;
        // Write
        if (RAM_CS && WE)
            RAM[AB_IN] <= DB_IN;

        // Read
        if (CPU_ENABLE && RAM_CS && ~WE)
            DB_OUT <= RAM[AB_IN];

        // Write
        if (RIOT_CS && WE)
        begin
            case (AB_IN)
                'h01 : DRA <= PA_IN;                            // SWACNT - Write DDRA
                'h03 : DRB <= PB_IN;                            // SWBCNT - Write DDRB
                'h14 :                              // TIM1T    - Write Timer (Divide by 1)    - Disable int
                begin
                    PRESCALE <= 1;
                    TIMER_REG <= DB_IN;
                end                
                'h15 :                              // TIM8T    - Write Timer (Divide by 8)    - Disable int
                begin
                    PRESCALE <= 8;
                    TIMER_REG <= DB_IN;
                end         
                'h16 :                              // TIM64T   - Write Timer (Divide by 64)   - Disable int
                begin
                    PRESCALE <= 64;
                    TIMER_REG <= DB_IN;
                end
                'h17 :
                begin                               // T1024T   - Write Timer (Divide by 1024) - Disable int
                    PRESCALE <= 1024;
                    TIMER_REG <= DB_IN;
                end
            endcase
        end

        // Read
        if (RIOT_CS && ~WE)
        begin
            case (AB_IN) 
                'h00 : DB_OUT <= (PA_IN & ~DRA);                // SWCHA - Read DRA
                'h01 : DB_OUT <= DDRA;               // SWACNT - Read DDRA
//                'h02 : DB_OUT <= 8'b11111111;                // SWCHB - Read DRB
                'h02 : DB_OUT <= (PB_IN & ~DRB);                // SWCHB - Re
                'h03 : DB_OUT <= DDRB;               // SWBCNT - Read DDRB
                'h04 :                               // INTIM - Timer Output
                begin
                    DB_OUT <= TIMER;  
                    TIM_RES <= 0;
                end
                'h05 :                               // INSTAT - Timer Status
                begin
                    DB_OUT <= (TIMER << 6);
                    MODE[0] <= 0;
                end
            endcase
        end

        // Timer
        if (RIOT_ENABLE)
        begin
            if (TIMER_REG > 0)
            begin
                TIMER_COUNTER <= 0;
                TIMER <= (TIMER_REG - 1);

                if (TIMER_REG == 0)
                begin
                    TIM_RES <= 1;
                    MODE <= 2'b11;
                end
                else
                    MODE <= 2'b00;

                TIMER_REG <= 0;
            end

            // Timer Counting Up
            else
            begin
                TIMER_COUNTER <= TIMER_COUNTER + 1;
            end

            // Timer Counting Down from Prescale value
            if (TIMER_COUNTER == (TIM_RES ? 11'b1 : PRESCALE) - 1)
            begin
                if (TIMER == 0)
                begin
                    TIM_RES <= 1;
                    MODE <= 2'b11;
                end
                TIMER <= TIMER - 1;
                TIMER_COUNTER <= 0;
            end
        end
    end
end

endmodule