`timescale 1ns/1ps

module tb_random2;
	// nets for testing
	reg clk, resetn, start;
	wire [0:47] random_num;
	wire done;
	
	integer i;
	
	random_start_ver RSV (clk, resetn, start, random_num, done);
	
	always @(posedge done)
		if (!start)
			$display("Done at time %0t, results: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", $time, random_num[0:2], random_num[3:5], random_num[6:8], random_num[9:11], random_num[12:14], random_num[15:17], random_num[18:20], random_num[21:23], random_num[24:26], random_num[27:29], random_num[30:32], random_num[33:35], random_num[36:38], random_num[39:41], random_num[42:44], random_num[45:47]);
		
	initial begin
		clk = 1'b0;
		resetn = 1'b1;
		#5;
		resetn = 1'b0;
		#5;
		clk = 1'b1;
		#5;
		resetn = 1'b1;
		#5;
		
		for (i = 0; i < 10000; i = i + 1) begin
			clk = 1'b0;
			#10;
			clk = 1'b1;
			#10;
		end
		
	end
	
	initial begin
		start = 1'b0;
		#355;
		
		start = 1'b1;
		#700;
		start = 1'b0;
		#500;
		start = 1'b1;
		#1000;
		start = 1'b0;
		#500;
		start = 1'b1;
		#500;
		start = 1'b0;
		#500;
		start = 1'b1;
		#1300;
		start = 1'b0;
		#500;
		start = 1'b1;
		#900;
		start = 1'b0;
		#500;
	end

endmodule
