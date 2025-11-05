module mouse (clock, reset, mouse_x, mouse_y, left_button, PS2_CLK, PS2_DAT);
	
	input reset; // active high reset
	input clock;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	// the mouse data from PS2_Controller
	wire [7:0] mouse_data;
	wire mouse_data_en;
	
	// mouse coordinates registers
	// decide to use 640 * 480
	output reg [9:0] mouse_x;
	output reg [8:0] mouse_y;
	output left_button;
	
	// register for the packets
	reg [7:0] packet_0, packet_1, packet_2;
	
	wire [9:0] next_x;
	wire [8:0] next_y;
	
	// three state for the three packets of mouse
	parameter recieve_0 = 2'b00, recieve_1 = 2'b01, recieve_2 = 2'b10;
	
	reg [1:0] current_s, next_s;
	always @(*) begin
		// fsm
		case (current_s)
			recieve_0: if (mouse_data_en && mouse_data[3]) next_s = recieve_1;
						  else next_s = recieve_0;
			recieve_1: if (mouse_data_en) next_s = recieve_2;
						  else next_s = recieve_1;
			recieve_2: if (mouse_data_en) next_s = recieve_0;
						  else next_s = recieve_2;
			default: next_s = 2'bxx;
		endcase
	end
	
	// done of a pakcet cycle
	wire done;
	assign done = (current_s == recieve_2) && mouse_data_en;
	
	// wires for cal_coor
	wire [7:0] info_0, info_1, info_2;
	assign info_0 = (current_s == recieve_0 && mouse_data_en && mouse_data[3]) ? mouse_data : packet_0;
	assign info_1 = (current_s == recieve_1 && mouse_data_en) ? mouse_data : packet_1;
	assign info_2 = (current_s == recieve_2 && mouse_data_en) ? mouse_data : packet_2;
	
	always @(posedge clock)
		if (reset) begin
			current_s <= recieve_0;
			packet_0 <= 8'b0;
			packet_1 <= 8'b0;
			packet_2 <= 8'b0;
		end else begin
			current_s <= next_s;
			
			if (current_s == recieve_0 && mouse_data_en && mouse_data[3])
				packet_0 <= mouse_data;
			if (current_s == recieve_1 && mouse_data_en)
				packet_1 <= mouse_data;
			if (current_s == recieve_2 && mouse_data_en)
				packet_2 <= mouse_data;
		end
			
	// calculate the next coordinates
	cal_coor CAL (
		.packet_0(info_0),
		.packet_1(info_1),
		.packet_2(info_2),
		.cur_x(mouse_x),
		.cur_y(mouse_y),
		.next_x(next_x),
		.next_y(next_y),
		.left_button(left_button)
	);
	
	always @(posedge clock)
		if (reset) begin
			mouse_x <= 320;
			mouse_y <= 240;
		end else if (done) begin
			mouse_x <= next_x;
			mouse_y <= next_y;
		end
		
	PS2_Controller PS2C (
		.CLOCK_50(clock),
		.reset(reset),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.received_data(mouse_data),
		.received_data_en(mouse_data_en)
	);
		defparam PS2C.INITIALIZE_MOUSE = 1;

endmodule

// this module reset/calculate the coordinates of the mouse
module cal_coor (packet_0, packet_1, packet_2, cur_x, cur_y, next_x, next_y, left_button);
	input [7:0] packet_0, packet_1, packet_2;
	input [9:0] cur_x;
	input [8:0] cur_y;
	output reg [9:0] next_x;
	output reg [8:0] next_y;
	output left_button;
	
	wire x_overflow, y_overflow, x_sign, y_sign;
	wire [7:0] dx, dy;
	reg signed [8:0] dx_signed, dy_signed;
	
	integer temp_x, temp_y;
	
	assign y_overflow = packet_0[7];
	assign x_overflow = packet_0[6];
	assign y_sign = packet_0[5];
	assign x_sign = packet_0[4];
	assign left_button = packet_0[0];
	assign dx = packet_1;
	assign dy = packet_2;
	
	always @(*) begin
		temp_x = cur_x;
		temp_y = cur_y;
		
		dx_signed = {x_sign, dx};
		dy_signed = {y_sign, dy};

		// x
		if (x_overflow)
			temp_x = temp_x + (x_sign ? -255 : 255);
		else
			temp_x = temp_x + dx_signed;

		// clamp
		if (temp_x < 0) temp_x = 0;
		else if (temp_x > 639) temp_x = 639;

		// y
		if (y_overflow)
			temp_y = temp_y + (y_sign ? 255 : -255);
		else
			temp_y = temp_y - dy_signed;

		if (temp_y < 0) temp_y = 0;
		else if (temp_y > 479) temp_y = 479;

		next_x = temp_x[9:0];
		next_y = temp_y[8:0];
	end
	
endmodule
