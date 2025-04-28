module div_2 (input clk, reset, output logic clk_out);

always_ff @ (posedge clk or negedge reset)

	if (~reset)
		clk_out <= 0;
	else
		clk_out <= ~clk_out;
endmodule

module freq_div #(parameter WIDTH = 7)(input clk,reset,input [WIDTH-1:0] div_num, output logic clk_out);
 

 
logic [WIDTH-1:0] pos_count, neg_count;
logic [WIDTH-1:0] r_nxt;
 
 always @(posedge clk or negedge reset)

 if (~reset)

 pos_count <= 0;


 else if (pos_count == div_num-1)

 pos_count <= 0;

 else 

 pos_count <= pos_count +1;
 
 always @(negedge clk or negedge reset)

 if (~reset)

 neg_count <=0;

 else  if (neg_count ==div_num-1)

 neg_count <= 0;

 else neg_count<= neg_count +1; 
 
assign clk_out = ((pos_count > (div_num>>1)) | (neg_count > (div_num>>1))); 

endmodule

//Audio frequency register

module AUDF (input clk,reset, input [4:0] data_in, output logic clk_out);



logic div1,div2,div3,div4,div5,div6,div7,div8,div9,div10,div11,div12,div13,div14,div15,div16,div17,div18,div19,div20,div21,div22,div23,div24,div25,div26,div27,div28,div29,div30,div31,div32, clk_out_comb;
//divide by 2 thru 32. The ~30kHz horizontal sync signal from VGA module
//freq_div #(5) f0(clk, reset, 5'd1, div1);
div_2 d1 (clk, reset, div2);
freq_div #(5) f2(clk, reset, 5'd3, div3);
freq_div #(5) f3(clk, reset, 5'd4, div4);
freq_div #(5) f4(clk, reset, 5'd5, div5);
freq_div #(5) f5(clk, reset, 5'd6, div6);
freq_div #(5) f6(clk, reset, 5'd7, div7);
freq_div #(5) f7(clk, reset, 5'd8, div8);
freq_div #(5) f8(clk, reset, 5'd9, div9);
freq_div #(5) f9(clk, reset, 5'd10, div10);
freq_div #(5) f10(clk, reset, 5'd11, div11);
freq_div #(5) f11(clk, reset, 5'd12, div12);
freq_div #(5) f12(clk, reset, 5'd13, div13);
freq_div #(5) f13(clk, reset, 5'd14, div14);
freq_div #(5) f14(clk, reset, 5'd15, div15);
freq_div #(5) f15(clk, reset, 5'd16, div16);
freq_div #(5) f16(clk, reset, 5'd17, div17);
freq_div #(5) f17(clk, reset, 5'd18, div18);
freq_div #(5) f18(clk, reset, 5'd19, div19);
freq_div #(5) f19(clk, reset, 5'd20, div20);
freq_div #(5) f20(clk, reset, 5'd21, div21);
freq_div #(5) f21(clk, reset, 5'd22, div22);
freq_div #(5) f22(clk, reset, 5'd23, div23);
freq_div #(5) f23(clk, reset, 5'd24, div24);
freq_div #(5) f24(clk, reset, 5'd25, div25);
freq_div #(5) f25(clk, reset, 5'd26, div26);
freq_div #(5) f26(clk, reset, 5'd27, div27);
freq_div #(5) f27(clk, reset, 5'd28, div28);
freq_div #(5) f28(clk, reset, 5'd29, div29);
freq_div #(5) f29(clk, reset, 5'd30, div30);
freq_div #(5) f30(clk, reset, 5'd31, div31);
freq_div #(5) f31(clk, reset, 5'd32, div32);

always_ff @(posedge clk or negedge reset) begin

	if (~reset)
		clk_out <=1'b0;
	
	else 
		

	case (data_in)
		
		//divide by 1
		5'd0: clk_out <= clk;
		//divide by 2
		5'd1: clk_out <=div2;
		//divide by 3
		5'd2: clk_out <=div3;
		//divide by 4
		5'd3: clk_out <=div4;
		//divide by 5
		5'd4: clk_out <=div5;
		//divide by 6
		5'd5: clk_out <=div6;
		//divide by 7
		5'd6: clk_out <=div7;
		//divide by 8
		5'd7: clk_out <=div8;
		//divide by 9
		5'd8: clk_out <=div9;
		//divide by 10
		5'd9: clk_out <=div10;	
		//divide by 11
		5'd10: clk_out <=div11;
		//divide by 12
		5'd11: clk_out <=div12;
		//divide by 13
		5'd12: clk_out <=div13;
		//divide by 14
		5'd13: clk_out <=div14;
		//divide by 15
		5'd14: clk_out <=div15;
		//divide by 16
		5'd15: clk_out <=div16;
		//divide by 17
		5'd16: clk_out <=div17;
		//divide by 18
		5'd17: clk_out <=div18;
		//divide by 19
		5'd18: clk_out <=div19;
		//divide by 20
		5'd19: clk_out <=div20;
		//divide by 21
		5'd20: clk_out <=div21;
		//divide by 22
		5'd21: clk_out <=div22;
		//divide by 23
		5'd22: clk_out <=div23;
		//divide by 24
		5'd23: clk_out <=div24;
		//divide by 25
		5'd24: clk_out <=div25;
		//divide by 26
		5'd25: clk_out <=div26;
		//divide by 27
		5'd26: clk_out <=div27;
		//divide by 28
		5'd27: clk_out <=div28;
		//divide by 29
		5'd28: clk_out <=div29;
		//divide by 30
		5'd29: clk_out <=div30;
		//divide by 31
		5'd30: clk_out <=div31;
		//divide by 32
		5'd31: clk_out <=div32;

		default: clk_out <=clk;
	
	endcase
end


endmodule

//Audio Volume Register, uses pulse width modulation to "change" volume

module AUDV (input clk, reset,input [3:0] data_in, output logic clk_out);

logic [3:0] count;

always_ff @ (posedge clk or negedge reset) begin
	if (~reset) begin
		clk_out<=0;
		count<=0;
		end
	else begin
		count<=count+1'd1;
			if (count < data_in) clk_out <=1'd1;
			else clk_out<=1'd0;
		end
	end

endmodule


//Audio type selection register, uses combination of divisions and poly-counts to create game sounds

module AUDC (input clk, reset, input [3:0] data_in, output logic audio_out);

logic div_2, div_6, div_15, div_31, div_93, poly_54, div15_poly4;
logic [3:0] poly4_count;
logic [4:0] poly5_count;
logic [8:0] poly9_count, setlast4_1_input, setlast4_1_output;

assign setlast4_1_input = {poly5_count , 4'b1111};

div_2 d2 (clk, reset, div_2);
freq_div #(5) f33(clk, reset, 5'd6, div_6);
freq_div #(5) f34(clk, reset, 5'd15, div_15);
freq_div #(5) f35(clk, reset, 5'd31, div_31);
freq_div #(5) f36(clk, reset, 5'd93, div_93);

always_ff @ (posedge clk or negedge reset) begin

	if (~reset) begin

		poly4_count <=4'd1;
		poly5_count <=5'd1;
		poly9_count <=9'd1;
	end

	else begin
		
		poly4_count <= {poly4_count[2:0] , poly4_count[3] ^ poly4_count[2]};
		poly5_count <= {poly5_count[3:0], poly5_count[4] ^ poly5_count[2]};
		poly9_count <= {poly9_count[7:0], poly9_count[8] ^ poly9_count[4]};
		setlast4_1_output <= {setlast4_1_input[7:0], setlast4_1_input[8] ^ setlast4_1_input[4]};
	end
end

	

always_comb begin

	case(data_in)

		//Set to 1
		4'h0: begin
		audio_out = 1'b1;
		end

		//4-bit poly
		4'h1: begin
		audio_out=poly4_count[3];
		end

		//divide by15 then 4 bit poly
		4'h2: begin
		audio_out = div_15 & poly4_count[3];
		end
		
		//5 bit poly - 4 bit poly
		4'h3: begin
		audio_out = poly5_count[4] ^ poly4_count[3];
		end
		
		//divide by 2
		4'h4: begin
		audio_out = div_2;
		end
	
		//divide by 2
		4'h5: begin
		audio_out = div_2;
		end

		//divide by 31
		4'h6: begin
		audio_out = div_31;
		end

		//5-bit poly divide by 2
		4'h7: begin
		audio_out = poly5_count[4] & div_2;
		end

		//9 bit poly
		4'h8: begin
		audio_out = poly9_count[8];
		end
		
		//5-bit poly
		4'h9: begin
		audio_out = poly5_count[4];
		end

		//divide by 31
		4'hA: begin
		audio_out = div_31;
		end

		//last 4 bits to 1
		4'hB: begin
		audio_out = setlast4_1_output[8];
		end
		
		//divide by 6
		4'hC: begin
		audio_out = div_6;
		end

		//divide by 6
		4'hD: begin
		audio_out = div_6;
		end

		//divide by 93
		4'hE: begin
		audio_out = div_93;
		end

		//5 bit poly divide by 6
		4'hF: begin
		audio_out = poly5_count[4] & div_6;
		end

	endcase
end

endmodule
