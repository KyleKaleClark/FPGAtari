module ASCII27Seg(input [7:0] AsciiCode, output reg [6:0] HexSeg);

	always @ (*) begin
	HexSeg = 7'd0;
	$display("AsciiCode %b", AsciiCode);
	case (AsciiCode)
		//A / a
		8'h41: HexSeg[3] = 1;
		8'h61: HexSeg[3] = 1;
		//B / b
		8'h42: begin
			HexSeg[0] = 1; HexSeg[1] = 1;
			end
		8'h62: begin
			HexSeg[0] = 1; HexSeg[1] = 1;
			end
		//C / c
		8'h43: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[6] = 1;
			end
		8'h63: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[6] = 1;
			end

		//D / d
		8'h44: begin
			HexSeg[5] = 1; HexSeg[0] = 1;
			end
		8'h64: begin
			HexSeg[5] = 1; HexSeg[0] = 1;
			end

		//E / e
		8'h45: begin
			HexSeg[1] = 1; HexSeg[2] = 1;
			end
		8'h65: begin
			HexSeg[1] = 1; HexSeg[2] = 1;
			end
		
		//F / f
		8'h46: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1;
			end
		8'h66: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1;
			end
		
		//G / g
		8'h47: HexSeg[4] = 1;
		8'h67: HexSeg[4] = 1;
		
		// H / h
		8'h48: begin
			HexSeg[0] = 1; HexSeg[3] = 1; HexSeg[1] = 1;
			end
		8'h68: begin
			HexSeg[0] = 1; HexSeg[3] = 1; HexSeg[1] = 1;
			end
			
		// I / i	
		8'h49: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1; HexSeg[6] = 1;
			end
		8'h69: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1; HexSeg[6] = 1;
			end
			
		//J / j
		8'h4A: begin
			HexSeg[0] = 1; HexSeg[5] = 1; HexSeg[6] = 1;
			end
		8'h6A: begin
			HexSeg[0] = 1; HexSeg[5] = 1; HexSeg[6] = 1;
			end	
			
		// K / k
		8'h4B: begin
			HexSeg[0] = 1; HexSeg[3] = 1;
			end
		8'h6B: begin
			HexSeg[0] = 1; HexSeg[3] = 1;
			end
			
		//L / l
		8'h4C: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[6] = 1; 
			end
		8'h6C: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[6] = 1; 
			end
			
		//M / m (kind of)
		8'h4D: begin
			HexSeg[5] = 1; HexSeg[1] = 1; HexSeg[6] = 1; HexSeg[3] = 1; 
			end
		8'h6D: begin
			HexSeg[5] = 1; HexSeg[1] = 1; HexSeg[6] = 1; HexSeg[3] = 1; 
			end
			
		//N / n
		8'h4E: begin
			HexSeg[0] = 0; HexSeg[1] = 1; HexSeg[5] = 1; HexSeg[3] = 1; 
			end
		8'h6E: begin
			HexSeg[0] = 0; HexSeg[1] = 1; HexSeg[5] = 1; HexSeg[3] = 1; 
			end

		//O / o
		8'h4F: HexSeg[6] = 1;
		8'h6F: HexSeg[6] = 1;
		
		//P / p
		8'h50: begin
			HexSeg[2] = 1; HexSeg[3] = 1;
			end
		8'h70: begin
			HexSeg[2] = 1; HexSeg[3] = 1;
			end
		
		//Q / q
		8'h51: begin
			HexSeg[3] = 1; HexSeg[4] = 1;
			end
		8'h71: begin
			HexSeg[3] = 1; HexSeg[4] = 1;
			end
		
		//R / r
		8'h52: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[5] = 1; HexSeg[2] = 1; HexSeg[3] = 1; 
			end
		8'h72: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[5] = 1; HexSeg[2] = 1; HexSeg[3] = 1; 
			end
			
		//S / s
		8'h53: begin
			HexSeg[1] = 1; HexSeg[4] = 1;
			end
		8'h73: begin
			HexSeg[1] = 1; HexSeg[4] = 1;
			end
			
		//T / t
		8'h54: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1;
			end
		8'h74: begin
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1;
			end
		
		//U / u
		8'h55: begin
			HexSeg[0] = 1; HexSeg[6] = 1;
			end
		8'h75: begin
			HexSeg[0] = 1; HexSeg[6] = 1;
			end
		
		//V / v
		8'h56: begin
			HexSeg[0] = 1; HexSeg[6] = 1; HexSeg[5] = 1; HexSeg[1] = 1; 
			end
		8'h76: begin
			HexSeg[0] = 1; HexSeg[6] = 1; HexSeg[5] = 1; HexSeg[1] = 1; 
			end
			
		// W / w (in a way)
		8'h57: begin
			HexSeg[0] = 1; HexSeg[6] = 1; HexSeg[4] = 1; HexSeg[2] = 1;
			end
		8'h77: begin
			HexSeg[0] = 1; HexSeg[6] = 1; HexSeg[4] = 1; HexSeg[2] = 1;
			end
				
		// X / x
		8'h58: begin
			HexSeg[0] = 1; HexSeg[3] = 1;
			end
		8'h78: begin
			HexSeg[0] = 1; HexSeg[3] = 1;
			end
			
		// Y / y
		8'h59: begin
			HexSeg[0] = 1; HexSeg[4] = 1;
			end
		8'h79: begin
			HexSeg[0] = 1; HexSeg[4] = 1;
			end
			
		//Z / z
		8'h5A: begin
			HexSeg[5] = 1; HexSeg[2] = 1;
			end
		8'h7A: begin
			HexSeg[5] = 1; HexSeg[2] = 1;
			end
		
		//numba 0
		8'h30: HexSeg[6] = 1;
		8'h31: begin
			HexSeg[0] = 1; HexSeg[3] = 1; HexSeg[4] = 1; HexSeg[5] = 1; HexSeg[6] = 1;
			end
		8'h32: begin
			HexSeg[5] = 1; HexSeg[2] = 1;
			end
		8'h33: begin
			HexSeg[5] = 1; HexSeg[4] = 1;
			end
		8'h34: begin
			HexSeg[0] = 1; HexSeg[4] = 1; HexSeg[3] = 1;
			end
		8'h35: begin
			HexSeg[1] = 1; HexSeg[4] = 1;
			end
		8'h36: HexSeg[1] = 1; 
		8'h37: begin
			HexSeg[5] = 1; HexSeg[4] = 1; HexSeg[6] = 1; HexSeg[3] = 1;
			end
		8'h38: HexSeg[0] = 0; //Im unsure how to not turn anything off (?) Could I have just left this entire entry blank? 
		8'h39: HexSeg[4] = 1;
		
		//Special Characters
		8'h27: begin // ' apostrophe
			HexSeg[0] = 1; HexSeg[2] = 1; HexSeg[3] = 1; HexSeg[4] = 1; HexSeg[5] = 1; HexSeg[6] = 1;
		end
		
		8'h20: begin // [Space]
			HexSeg[0] = 1; HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1; HexSeg[4] = 1; HexSeg[5] = 1; HexSeg[6] = 1;
		end
		
		//Integers
		8'h0: begin
			HexSeg[6] = 1;
			end
		8'h1: begin
			HexSeg[6] = 1; HexSeg[5] = 1; HexSeg[4] = 1; HexSeg[3] = 1; HexSeg[0] = 1;
			end
		8'h2: begin
			HexSeg[5] = 1; HexSeg[2] = 1;
			end
		8'h3: begin
			HexSeg[5] = 1; HexSeg[4] = 1;	
			end
		8'h4: begin
			HexSeg[4] = 1; HexSeg[3] = 1; HexSeg[0] = 1;
			end
		8'h5: begin
			HexSeg[4] = 1; HexSeg[1] = 1; 
			end
		8'h6: begin
			HexSeg[1] = 1;
			end
		8'h7: begin
			HexSeg[6] = 1; HexSeg[5] = 1; HexSeg[4] = 1; HexSeg[3] = 1;
			end
		//8'h8: begin pretend its here but technically nothing to do for it :)
			
		8'h9: begin
			HexSeg[4] = 1;
			end
		
		//Hex Values
		8'hA: HexSeg[3] = 1;
		
		8'hB: begin
			HexSeg[0] = 1; HexSeg[1] = 1;
			end
			
		8'hC: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[6] = 1;
			end
		
		8'hD: begin
			HexSeg[5] = 1; HexSeg[0] = 1;
			end
			
		8'hE: begin
			HexSeg[1] = 1; HexSeg[2] = 1;
			end
			
		8'hF: begin
			HexSeg[1] = 1; HexSeg[2] = 1; HexSeg[3] = 1;
			end
			
		default: HexSeg[1] = 0;
		endcase
	end
endmodule //ascii