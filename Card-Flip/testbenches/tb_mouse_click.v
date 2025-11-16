`timescale 1ns/1ps

module tb_mouse_click;
	reg clock, left_button;
	reg [9:0] mouse_x;
	reg [8:0] mouse_y;
	reg [0:47] card_num;
	reg [0:15] show;
	wire [2:0] card_num_out;
	wire click_done;
	
	mouse_click MC (clock, mouse_x, mouse_y, left_button, card_num, show, card_num_out, click_done);
	
	integer i, j;
	
	initial begin
		// initialize
		left_button = 1'b0;
		mouse_x = 10'd0;
		mouse_y = 9'd0;
		show = 16'b0;
		show[0] = 1'b1;
		for (i = 0; i < 16; i = i + 1) begin
			card_num[3 * i +: 3] = i / 2;
		end
	end
	
	initial begin
		// clock
		for (j = 0; j < 10; j = j + 1) begin
			clock = 1'b0;
			#10;
			clock = 1'b1;
			#10;
		end
	end
	
	initial begin
		// monitor
		$monitor("time = %0t | mouse_x = %d mouse_y = %d left_button = %b card_num_out = %d click_done = %b", $time, mouse_x, mouse_y, left_button, card_num_out, click_done);
	end
	
	initial begin
		#20;
		// not on anything
		mouse_x = 10'd640;
		mouse_y = 9'd480;
		left_button = 1'b1;
		#20;
		left_button = 1'b0;
		#20;
		// on an unflipped card
		mouse_x = 10'd374;
		mouse_y = 9'd77;
		left_button = 1'b1;
		#20;
		left_button = 1'b0;
		#20;
		// on a flipped card
		mouse_x = 10'd156;
		mouse_y = 9'd77;
		left_button = 1'b1;
		#20;
		left_button = 1'b0;
		#20;
	end
endmodule
