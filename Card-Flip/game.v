module game (clock, resetn, game_start, rand_busy, mouse_x, mouse_y, left_button, show_busy,
					card_num_reg, show_reg,
					rand_start, load_card, resetn_show, resetn_timer, update_start, timer_start, 
					timer_end, E_show, status_show, card_show);
					
	parameter nX = 10, nY = 9;
					
	input clock, resetn;
	input game_start;
	input rand_busy; // indicate if the random generator is still busy
	input [nX-1:0] mouse_x;
	input [nY-1:0] mouse_y;
	input left_button;
	input show_busy; // indicate if the screen is still in the update process
	input [0:47] card_num_reg;
	input [0:15] show_reg;
	
	output rand_start; // tell the random generator to start
	output load_card; // tell the card register to load the card for this game
	output resetn_show; // reset the show register
	output resetn_timer; // reset the game timer
	output update_start; // to start updating the screen
	output timer_start, timer_end; // to start and end the game timer
	output E_show; // enable the update of the show register
	output status_show; // the status for updating the show register
	output [3:0] card_show; // tell the show register that which card should be changed
	
	parameter idle = 5'd0, start_pressed = 5'd1, loading_card = 5'd2, update_card_1 = 5'd3;
	parameter wait_update_1 = 5'd4, wait_click_1 = 5'd5, process_info_1 = 5'd6;
	parameter update_card_2 = 5'd7, wait_update_2 = 5'd8, wait_click_2 = 5'd9;
	parameter process_info_2 = 5'd10, update_card_3 = 5'd11, wait_update_3 = 5'd12;
	parameter wait_1sec = 5'd13, flip_back_1 = 5'd14, flip_back_2 = 5'd15;
	parameter update_card_4 = 5'd16, wait_update_4 = 5'd17, end_state = 5'd18;
	
	reg [4:0] current_s, next_s; // for states
	
	reg resetn_wait_cnt; // reset for the wait counter
	reg E_wait_cnt; // enable the wait counter
	wire done_wait_cnt; // done waiting
	
	reg [3:0] card1, card2; // the index of the cards flipped
	wire [3:0] card_idx_out; // idx out of the mouse click
	wire click_done;
	
	mouse_click MC (
		.clock(clock),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		.left_button(left_button),
		.show(show_reg),
		.card_idx_out(card_idx_out),
		.click_done(click_done)
	);
	
	cnt_wait CNT (
		.clock(clock),
		.resetn(resetn_wait_cnt),
		.enable(E_wait_cnt),
		.done(done_wait_cnt)
	);
	
endmodule

module cnt_wait (clock, resetn, enable, done);
	// the counter for waiting for a second
	input clock, resetn, enable;
	output reg done;
	
	reg [25:0] Q;
	always @(posedge clock) begin
		done <= 1'b0;
		if (!resetn) begin
			Q <= 25'd0;
		end else if (enable)
			if (Q == 25'd50000000)
				done <= 1'b1;
			else
				Q <= Q + 1;
	end
			
endmodule

module mouse_click (clock, mouse_x, mouse_y, left_button, show, card_idx_out, click_done);
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
	input [0:15] show;
	output reg [3:0] card_idx_out;
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
				card_idx_on = idx;
			end
	end
	
	always @(posedge clock) begin
		click_done <= 1'b0;
		if (on_card && left_button) begin
			click_done <= 1'b1;
			card_idx_out <= card_idx_on;
		end
	end

endmodule
