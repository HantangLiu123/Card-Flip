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
	
	output reg rand_start; // tell the random generator to start
	output reg load_card; // tell the card register to load the card for this game
	output reg resetn_show; // reset the show register
	output reg resetn_timer; // reset the game timer
	output reg update_start; // to start updating the screen
	output reg timer_start, timer_end; // to start and end the game timer
	output reg E_show; // enable the update of the show register
	output reg status_show; // the status for updating the show register
	output reg [3:0] card_show; // tell the show register that which card should be changed
	
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
	
	wire game_end = (show_reg == 16'b1111111111111111);
	wire same_card = (card_num_reg[3 * card1 +: 3] == card_num_reg[3 * card2 +: 3]);
	
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
	
	// state change
	always @(*) begin
		case (current_s)
			idle: if (game_start) next_s = start_pressed; else next_s = idle;
			start_pressed: if (game_start || rand_busy) next_s = start_pressed; else next_s = loading_card;
			loading_card: next_s = update_card_1;
			update_card_1: next_s = wait_update_1;
			wait_update_1: if (show_busy) next_s = wait_update_1; else next_s = wait_click_1;
			wait_click_1: if (game_end)
									next_s = end_state;
								else if (click_done)
									next_s = process_info_1;
								else
									next_s = wait_click_1;
			process_info_1: next_s = update_card_2;
			update_card_2: next_s = wait_update_2;
			wait_update_2: if (show_busy) next_s = wait_update_2; else next_s = wait_click_2;
			wait_click_2: if (click_done) next_s = process_info_2; else next_s = wait_click_2;
			process_info_2: next_s = update_card_3;
			update_card_3: next_s = wait_update_3;
			wait_update_3: if (show_busy)
									next_s = wait_update_3;
								else if (same_card)
									next_s = wait_click_1;
								else
									next_s = wait_1sec;
			wait_1sec: if (done_wait_cnt) next_s = flip_back_1; else next_s = wait_1sec;
			flip_back_1: next_s = flip_back_2;
			flip_back_2: next_s = update_card_4;
			update_card_4: next_s = wait_update_4;
			wait_update_4: if (show_busy) next_s = wait_update_4; else next_s = wait_click_1;
			end_state: next_s = idle;
			default: next_s = 5'bxxxxx;
		endcase
	end
	
	// update the state
	always @(posedge clock) begin
		if (!resetn) begin
			current_s <= idle;
			card1 <= 4'b0;
			card2 <= 4'b0;
		end else begin
			current_s <= next_s;
			
			// store card 1 and card 2 in the corresponding state
			if (current_s == process_info_1)
				card1 <= card_idx_out;
			else if (current_s == process_info_2)
				card2 <= card_idx_out;
		end
	end
	
	// set the output for each state
	always @(*) begin
		// defaults
		rand_start = 1'b0; load_card = 1'b0; 
		resetn_show = 1'b1; resetn_timer = 1'b1;
		update_start = 1'b0;
		timer_start = 1'b0; timer_end = 1'b0;
		E_show = 1'b0;
		resetn_wait_cnt = 1'b1; E_wait_cnt = 1'b0;
		
		status_show = 1'b0;
		card_show = 4'b0;
		
		case (current_s)
			idle: ;
			start_pressed: rand_start = game_start;
			loading_card: begin load_card = 1'b1; resetn_show = 1'b0; resetn_timer = 1'b0; end
			update_card_1: begin update_start = 1'b1; timer_start = 1'b1; end
			wait_update_1: ;
			wait_click_1: resetn_wait_cnt = 1'b0;
			process_info_1: 
				begin
					E_show = 1'b1;
					status_show = 1'b1;
					card_show = card_idx_out;
				end
			update_card_2: update_start = 1'b1;
			wait_update_2: ;
			wait_click_2: ;
			process_info_2:
				begin
					E_show = 1'b1;
					status_show = 1'b1;
					card_show = card_idx_out;
				end
			update_card_3: update_start = 1'b1;
			wait_update_3: ;
			wait_1sec: E_wait_cnt = 1'b1;
			flip_back_1: 
				begin
					E_show = 1'b1;
					status_show = 1'b0;
					card_show = card1;
				end
			flip_back_2:
				begin
					E_show = 1'b1;
					status_show = 1'b0;
					card_show = card2;
				end
			update_card_4: update_start = 1'b1;
			wait_update_4: ;
			end_state: timer_end = 1'b1;
			default: ;
		endcase
	end
	
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
	reg [3:0] card_idx_on;
	
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
