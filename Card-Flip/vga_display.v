`default_nettype none

module vga_demo16(
    input wire CLOCK_50,
    input wire [9:0]  SW,
    input wire [3:0]  KEY,   
    input wire flip,

    // VGA
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire VGA_CLK,
    output wire VGA_SYNC_N,
    output wire VGA_BLANK_N,
    output wire VGA_VS,
    output wire VGA_HS
);
    
    parameter RESOLUTION = "640x480"; 
    parameter COLOR_DEPTH = 6;         // randomly pick one
    parameter OBJ_W = 40;        // block width
    parameter OBJ_H = 40;        // block height
    parameter ROWS = 4;
    parameter COLS = 4;


    wire Resetn = KEY[0];  
    

    // starter, define start x,y and the gap between them
    // use integer to do calculations
    parameter integer START_X = 70;
    parameter integer START_Y = 50;
    parameter integer GAP_X = 20; 
    parameter integer GAP_Y = 20;

    // the bus contain all the wire that is needed for 16 objects
    parameter integer N_OBJ = ROWS * COLS;

    wire [N_OBJ - 1:0] inst_done;
    wire [N_OBJ - 1:0] inst_write;
    wire [N_OBJ * 10 - 1:0] inst_x_bus;      // 10 input for x
    wire [N_OBJ * 9 - 1:0]  inst_y_bus;      // 9 input for y
    wire [N_OBJ * COLOR_DEPTH - 1:0] inst_color_bus;  // COLOR_DEPTH is the num of input     

    // decompose for loop (row and column)
    parameter integer IDX1  = 0,  IX1  = START_X + 0*GAP_X, IY1  = START_Y + 0*GAP_Y;
    parameter integer IDX2  = 1,  IX2  = START_X + 1*GAP_X, IY2  = START_Y + 0*GAP_Y;
    parameter integer IDX3  = 2,  IX3  = START_X + 2*GAP_X, IY3  = START_Y + 0*GAP_Y;
    parameter integer IDX4  = 3,  IX4  = START_X + 3*GAP_X, IY4  = START_Y + 0*GAP_Y;

    parameter integer IDX5  = 4,  IX5  = START_X + 0*GAP_X, IY5  = START_Y + 1*GAP_Y;
    parameter integer IDX6  = 5,  IX6  = START_X + 1*GAP_X, IY6  = START_Y + 1*GAP_Y;
    parameter integer IDX7  = 6,  IX7  = START_X + 2*GAP_X, IY7  = START_Y + 1*GAP_Y;
    parameter integer IDX8  = 7,  IX8  = START_X + 3*GAP_X, IY8  = START_Y + 1*GAP_Y;

    parameter integer IDX9  = 8,  IX9  = START_X + 0*GAP_X, IY9  = START_Y + 2*GAP_Y;
    parameter integer IDX10 = 9,  IX10 = START_X + 1*GAP_X, IY10 = START_Y + 2*GAP_Y;
    parameter integer IDX11 = 10, IX11 = START_X + 2*GAP_X, IY11 = START_Y + 2*GAP_Y;
    parameter integer IDX12 = 11, IX12 = START_X + 3*GAP_X, IY12 = START_Y + 2*GAP_Y;

    parameter integer IDX13 = 12, IX13 = START_X + 0*GAP_X, IY13 = START_Y + 3*GAP_Y;
    parameter integer IDX14 = 13, IX14 = START_X + 1*GAP_X, IY14 = START_Y + 3*GAP_Y;
    parameter integer IDX15 = 14, IX15 = START_X + 2*GAP_X, IY15 = START_Y + 3*GAP_Y;
    parameter integer IDX16 = 15, IX16 = START_X + 3*GAP_X, IY16 = START_Y + 3*GAP_Y;
    // 16 object instances 
    object #(
        .XOFFSET(IX1),
        .YOFFSET(IY1),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX1]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX1 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX1 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX1 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX1]),
        .done(inst_done[IDX1])
    );

    object #(
        .XOFFSET(IX2),
        .YOFFSET(IY2),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX2]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX2 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX2 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX2 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX2]),
        .done(inst_done[IDX2])
    );

    object #(
        .XOFFSET(IX3),
        .YOFFSET(IY3),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX3]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX3 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX3 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX3 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX3]),
        .done(inst_done[IDX3])
    );

    object #(
        .XOFFSET(IX4),
        .YOFFSET(IY4),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX4]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX4 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX4 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX4 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX4]),
        .done(inst_done[IDX4])
    );

    object #(
        .XOFFSET(IX5),
        .YOFFSET(IY5),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj5 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX5]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX5 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX5 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX5 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX5]),
        .done(inst_done[IDX5])
    );

    object #(
        .XOFFSET(IX6),
        .YOFFSET(IY6),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj6 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX6]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX6 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX6 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX6 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX6]),
        .done(inst_done[IDX6])
    );

    object #(
        .XOFFSET(IX7),
        .YOFFSET(IY7),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj7 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX7]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX7 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX7 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX7 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX7]),
        .done(inst_done[IDX7])
    );

    object #(
        .XOFFSET(IX8),
        .YOFFSET(IY8),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj8 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX8]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX8 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX8 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX8 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX8]),
        .done(inst_done[IDX8])
    );

    object #(
        .XOFFSET(IX9),
        .YOFFSET(IY9),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj9 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX9]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX9 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX9 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX9 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX9]),
        .done(inst_done[IDX9])
    );

    object #(
        .XOFFSET(IX10),
        .YOFFSET(IY10),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj10 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX10]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX10 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX10 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX10 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX10]),
        .done(inst_done[IDX10])
    );

    object #(
        .XOFFSET(IX11),
        .YOFFSET(IY11),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj11 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX11]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX11 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX11 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX11 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX11]),
        .done(inst_done[IDX11])
    );

    object #(
        .XOFFSET(IX12),
        .YOFFSET(IY12),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj12 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX12]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX12 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX12 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX12 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX12]),
        .done(inst_done[IDX12])
    );

    object #(
        .XOFFSET(IX13),
        .YOFFSET(IY13),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj13 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX13]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX13 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX13 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX13 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX13]),
        .done(inst_done[IDX13])
    );

    object #(
        .XOFFSET(IX14),
        .YOFFSET(IY14),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj14 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX14]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX14 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX14 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX14 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX14]),
        .done(inst_done[IDX14])
    );

    object #(
        .XOFFSET(IX15),
        .YOFFSET(IY15),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj15 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX15]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX15 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX15 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX15 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX15]),
        .done(inst_done[IDX15])
    );

    object #(
        .XOFFSET(IX16),
        .YOFFSET(IY16),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480"),
        .INIT_FILE()
    ) obj16 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .go(inst_go[IDX16]),
        .ps2_rec(1'b0),
        .dir(2'b00),
        .VGA_x(inst_x_bus[IDX16 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX16 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX16 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX16]),
        .done(inst_done[IDX16])
    );



	// display 16 objects in sequenses
	parameter N = N_OBJ;

	wire keypressed = ~KEY[1];                  
	reg  [3:0] current_idx;        // 4 digit num represent 16 objects
	reg  busy;
	reg  push;                         // sign for go, go for printing next oject

	reg [N-1:0] inst_go;                // 16 digit go sign
	integer i;
	always @(*) begin
		 for (i = 0; i < N; i = i + 1)
			  inst_go[i] = (push && (current_idx == i)) ? 1'b1 : 1'b0;    // if push and is the corresponding object
	end

	always @(posedge CLOCK_50) begin
		 if(!Resetn) begin
			  busy <= 1'b0;
			  current_idx <= 4'b0000;
			  push <= 1'b0;
		 end 
		 else begin
			  push <= 1'b0;
			  if(!busy) begin
					if (keypressed) begin
						 busy <= 1'b1;
						 current_idx <= 4'b0000;
						 push <= 1'b1;                 // print the first one 
					end
			  end 
			  else begin
					// if current one is done, then move to next one
					if (inst_done[current_idx]) begin   // if this object is done
						 if(current_idx == N-1) begin
							  busy <= 1'b0;             // all done
						 end else begin
							  current_idx <= current_idx + 1'b1;
							  push <= 1'b1;             // reset the push to be one, next one can go
						 end
					end
			  end
		 end
	end

	// pass down to VGA, use this to break down the whole bus
	wire [9:0] putin_x = inst_x_bus [current_idx * 10 +: 10];
	wire [8:0] putin_y = inst_y_bus [current_idx * 9 +: 9];
	wire [COLOR_DEPTH-1:0] putin_color = inst_color_bus[current_idx * COLOR_DEPTH +: COLOR_DEPTH];
	wire putin_write = inst_write[current_idx];

	vga_adapter myVGA (
		 .resetn(Resetn),
		 .clock(CLOCK_50),
		 .color(putin_color),
		 .x(putin_x),
		 .y(putin_y),
		 .write(putin_write),
		 .VGA_R(VGA_R),
		 .VGA_G(VGA_G),
		 .VGA_B(VGA_B),
		 .VGA_HS(VGA_HS),
		 .VGA_VS(VGA_VS),
		 .VGA_CLK(VGA_CLK),
		 .VGA_BLANK_N(VGA_BLANK_N),
		 .VGA_SYNC_N(VGA_SYNC_N)
	);
endmodule
