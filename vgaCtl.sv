module vgaCtl#(parameter int pA = 10 ,parameter int fA = 32)(input clk, rst, output logic pix_v, hs, vs, output logic [pA-1:0] pix_x,pix_y ,output logic [fA-1:0] frame_id);

   // TAKEN FROM BASYS 3 DEMO
   localparam int frame_width  = 640;
   localparam int frame_height = 480 ;
   localparam int frames = 275625; // number of frames    
   localparam int black_bars = 48; //Height of black bar for bottom and top
   

   localparam int hpw = 96;  // hsync pulse length
   localparam int vpw =   2;  // vsync pulse length
   localparam int hbp = 48;  // end of horizontal back porch
   localparam int hfp =  16;  // beginning of horizontal front porch
   localparam int vbp =  33 ;  // end of vertical back porch
   localparam int vfp =  10 ;  // beginning of vertical front porch

   localparam int hpixels = frame_width  + hpw + hfp + hbp ; // horizontal pixels per line
   localparam int vlines =  frame_height + vpw + vfp + vbp ; // vertical lines per frame	
	
	
	
   logic [pA-1:0] countX, countY ;
   logic rowReturn, imgReturn ;
			

	
   //Yay for counters 
   counter #(pA, hpixels) ctrX(1'b1,1'b0, clk, rst, countX );
   counter #(pA, vlines)  ctrY(rowReturn,1'b0, clk, rst, countY );
   counter #(fA, frames)  ctrF(imgReturn,1'b0, clk, rst, frame_id );

   //Generate the increments for the outer loop counters
   assign rowReturn = countX == (hpixels-1);
   assign imgReturn = (countY == (vlines-1)) && rowReturn ;

   //Generate the sync pulses
   assign hs = !( countX >= (hfp+hbp+frame_width) ) ;
   assign vs = !( countY >= (vfp+vbp+frame_height) );

   //Scales horizontal pixels by 4. Original resolution: 160. Every 1 atari pixel corresponds to 4 vga pixels
   //Scales vertical by 2. Original resolution: 198. 480-(198*3) = 96 pixels left over. 
   //Defines the y-pixel space as being 48 pixels smaller 

   // Translate the counts into useful numbers
   assign pix_x = (countX - hbp)/4 ;
   assign pix_y = (countY - vbp-48)/2; 

   //pix_v represents active region of screen. Starts the display after the back porch + 48 pixels, and ends 48 pixels before edge of screen
   assign pix_v = (countX >= hbp) && (countX < (hbp+frame_width)  )&& (countY >= vbp+48)&& (countY < (vbp+frame_height-48) ) ;

endmodule //vgaCtl


