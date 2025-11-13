`timescale 1ns/1ps

module tb_random;
	// nets for testing
	reg clk, resetn, start;
	wire [0:47] random_num;
	wire done;
	
	integer i;
	
	random_assign RA (clk, resetn, start, random_num, done);
	
	always @(posedge done)
		$display("Done at time %0t, results: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", $time, random_num[0:2], random_num[3:5], random_num[6:8], random_num[9:11], random_num[12:14], random_num[15:17], random_num[18:20], random_num[21:23], random_num[24:26], random_num[27:29], random_num[30:32], random_num[33:35], random_num[36:38], random_num[39:41], random_num[42:44], random_num[45:47]);
		
	initial begin
		clk = 1'b0;
		#5;
		resetn = 1'b0;
		#5;
		clk = 1'b1;
		#5;
		resetn = 1'b1;
		#5;
		
		for (i = 0; i < 10; i = i + 1) begin
			clk = 1'b0;
			#5;
			start = 1'b1;
			#5;
			clk = 1'b1;
			#5;
			start = 1'b0;
			#5;
			while (!done) begin
				clk = 1'b0;
				#10;
				clk = 1'b1;
				#10;
			end
			#100;
		end
		
	end

endmodule
