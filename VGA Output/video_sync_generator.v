module video_sync_generator(reset, vga_clk, blank_n, HC, VC, HS, VS);
                            
input reset;
input vga_clk;
output reg blank_n;
output reg HC;
output reg VC;
output reg HS; //Horizontal Sync
output reg VS; //Vertical Sync

///////////////////
/*
--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line

--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line
*////////////////////////////////////////////////////////////////////

// Horizontal Parameter
parameter hori_line  = 800;                          
parameter hori_back  = 144;  
parameter hori_front = 16;
parameter H_sync_cycle = 96; 

// Vertical Parameter
parameter vert_line  = 525;  
parameter vert_back  = 34;   
parameter vert_front = 11;   
parameter V_sync_cycle = 2; 

parameter H_BLANK = hori_front+H_sync_cycle ; //add by yang

//////////////////////////

reg [9:0] h_cnt;  //Horizontal Pixel count
reg [9:0] v_cnt; //Vertical Pixel count

wire cHD,cVD,cDEN,hori_valid,vert_valid;

//////////////////////////
always@(negedge vga_clk, posedge reset)
begin
   HC <= h_cnt;
   VC <= v_cnt;
   if (reset)
   begin
      h_cnt <= 0;
      v_cnt <= 0;
   end

   else
   begin
      if (h_cnt == hori_line - 1) //If location is at end of screen (horizontal) start back at left side
      begin 
         h_cnt <= 0;
         if (v_cnt == vert_line - 1) //If location is at bottom of screen start back at top
            v_cnt <= 0;
         else
            v_cnt <= v_cnt + 1; //If not at bottom, just move down a line
      end
      else
         h_cnt <= h_cnt + 1; //Default is move pixel right once
   end

end

//////////////////////////
assign cHD = (h_cnt<H_sync_cycle) ? 1'b0 : 1'b1;
assign cVD = (v_cnt<V_sync_cycle) ? 1'b0 : 1'b1;

assign hori_valid = (h_cnt<(hori_line-hori_front)&& h_cnt>=hori_back)?1'b1:1'b0;
assign vert_valid = (v_cnt<(vert_line-vert_front)&& v_cnt>=vert_back)?1'b1:1'b0;

assign cDEN = hori_valid && vert_valid;

always@(negedge vga_clk)
begin
  HS<=cHD;
  VS<=cVD;
  blank_n<=cDEN;
end

endmodule


