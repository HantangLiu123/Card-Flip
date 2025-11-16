module mouse_click (clock, mouse_x, mouse_y, left_button, card_num, show, card_num_out, click_done);
	parameter nX = 10;
	parameter nY = 9;
	
	integer IX [0:15];
	integer IY [0:15];
	parameter integer START_X = 156;
   parameter integer START_Y = 77;
   parameter integer GAP_X = 109; 
   parameter integer GAP_Y = 109;
	
	// constants for checking the mouse' location
	integer i;
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			IX[i] = START_X + (i % 4) * GAP_X;
			IY[i] = START_Y + (i / 4) * GAP_Y;
		end
	end
	
	input clock;
	input [nX-1:0] mouse_x;
	input [nY-1:0] mouse_y;
	input left_button;
	input [0:47] card_num;
	input [0:15] show;
	output reg [2:0] card_num_out;
	output reg click_done;
	
	reg on_card;
	reg [2:0] card_idx_on;
	
	integer idx;
	
	always @(*) begin
		// defaults
		on_card = 1'b0;
		card_idx_on = 3'b000;
		
		for (idx = 0; idx < 16; idx = idx + 1)
			if (mouse_x > IX[idx] - 32 && mouse_x < IX[idx] + 32 && mouse_y > IY[idx] - 32 && mouse_y < IY[idx] + 32 && !show[idx]) begin
				on_card = 1'b1;
				card_idx_on = card_num[idx * 3 +: 3];
			end
	end
	
	always @(posedge clock) begin
		click_done <= 1'b0;
		if (on_card && left_button) begin
			click_done <= 1'b1;
			card_num_out <= card_idx_on;
		end
	end

endmodule
