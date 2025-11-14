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
    parameter COLOR_DEPTH = 9;         // randomly pick one
    parameter OBJ_W = 64;        // block width
    parameter OBJ_H = 64;        // block height
    parameter ROWS = 4;
    parameter COLS = 4;


    wire Resetn = KEY[0];  
	 

    // starter, define start x,y and the gap between them
    // use integer to do calculations
    parameter integer START_X = 156;
    parameter integer START_Y = 77;
    parameter integer GAP_X = 109; 
    parameter integer GAP_Y = 109;
	 parameter integer WIDTH_BIT = 6;
	 parameter integer HEIGHT_BIT = 6;

    // the bus contain all the wire that is needed for 16 objects
    parameter integer N_OBJ = ROWS * COLS;

    wire [N_OBJ - 1:0] inst_done;
    wire [N_OBJ - 1:0] inst_write;
    wire [N_OBJ * 10 - 1:0] inst_x_bus;      // 10 input for x
    wire [N_OBJ * 9 - 1:0]  inst_y_bus;      // 9 input for y
    wire [N_OBJ * COLOR_DEPTH - 1:0] inst_color_bus;  // COLOR_DEPTH is the num of input    
	 wire [0:47] card_nums;
    wire [COLOR_DEPTH * 9 - 1 : 0] mem_color_bus;
	 wire [WIDTH_BIT * 16 - 1 : 0] mem_x_bus;
	 wire [HEIGHT_BIT * 16 - 1 : 0] mem_y_bus;

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
    card #(
        .XOFFSET(IX1),
        .YOFFSET(IY1),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX1]),
		  .card_num(card_nums[IDX1 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX1 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX1 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX1 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX1 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX1 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX1]),
        .done(inst_done[IDX1])
    );

    card #(
        .XOFFSET(IX2),
        .YOFFSET(IY2),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX2]),
		  .card_num(card_nums[IDX2 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX2 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX2 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX2 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX2 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX2 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX2]),
        .done(inst_done[IDX2])
    );

    card #(
        .XOFFSET(IX3),
        .YOFFSET(IY3),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX3]),
		  .card_num(card_nums[IDX3 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX3 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX3 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX3 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX3 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX3 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX3]),
        .done(inst_done[IDX3])
    );

    card #(
        .XOFFSET(IX4),
        .YOFFSET(IY4),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX4]),
		  .card_num(card_nums[IDX4 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX4 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX4 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX4 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX4 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX4 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX4]),
        .done(inst_done[IDX4])
    );

    card #(
        .XOFFSET(IX5),
        .YOFFSET(IY5),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card5 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX5]),
		  .card_num(card_nums[IDX5 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX5 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX5 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX5 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX5 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX5 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX5]),
        .done(inst_done[IDX5])
    );

    card #(
        .XOFFSET(IX6),
        .YOFFSET(IY6),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card6 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX6]),
		  .card_num(card_nums[IDX6 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX6 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX6 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX6 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX6 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX6 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX6]),
        .done(inst_done[IDX6])
    );

    card #(
        .XOFFSET(IX7),
        .YOFFSET(IY7),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card7 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX7]),
		  .card_num(card_nums[IDX7 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX7 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX7 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX7 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX7 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX7 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX7]),
        .done(inst_done[IDX7])
    );

    card #(
        .XOFFSET(IX8),
        .YOFFSET(IY8),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card8 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX8]),
		  .card_num(card_nums[IDX8 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX8 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX8 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX8 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX8 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX8 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX8]),
        .done(inst_done[IDX8])
    );

    card #(
        .XOFFSET(IX9),
        .YOFFSET(IY9),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card9 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX9]),
		  .card_num(card_nums[IDX9 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX9 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX9 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX9 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX9 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX9 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX9]),
        .done(inst_done[IDX9])
    );

    card #(
        .XOFFSET(IX10),
        .YOFFSET(IY10),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card10 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX10]),
		  .card_num(card_nums[IDX10 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX10 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX10 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX10 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX10 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX10 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX10]),
        .done(inst_done[IDX10])
    );

    card #(
        .XOFFSET(IX11),
        .YOFFSET(IY11),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card11 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX11]),
		  .card_num(card_nums[IDX11 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX11 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX11 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX11 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX11 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX11 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX11]),
        .done(inst_done[IDX11])
    );

    card #(
        .XOFFSET(IX12),
        .YOFFSET(IY12),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card12 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX12]),
		  .card_num(card_nums[IDX12 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX12 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX12 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX12 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX12 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX12 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX12]),
        .done(inst_done[IDX12])
    );

    card #(
        .XOFFSET(IX13),
        .YOFFSET(IY13),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card13 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX13]),
		  .card_num(card_nums[IDX13 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX13 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX13 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX13 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX13 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX13 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX13]),
        .done(inst_done[IDX13])
    );

    card #(
        .XOFFSET(IX14),
        .YOFFSET(IY14),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card14 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX14]),
		  .card_num(card_nums[IDX14 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX14 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX14 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX14 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX14 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX14 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX14]),
        .done(inst_done[IDX14])
    );

    card #(
        .XOFFSET(IX15),
        .YOFFSET(IY15),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card15 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX15]),
		  .card_num(card_nums[IDX15 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX15 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX15 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX15 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX15 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX15 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX15]),
        .done(inst_done[IDX15])
    );

    card #(
        .XOFFSET(IX16),
        .YOFFSET(IY16),
		  .xOBJ(WIDTH_BIT),
		  .yOBJ(HEIGHT_BIT),
        .COLOR_DEPTH(COLOR_DEPTH),
        .RESOLUTION("640x480")
    ) card16 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .draw(inst_go[IDX16]),
		  .card_num(card_nums[IDX16 * 3 +: 3]),
		  .show(1'b1),
		  .obj_color(mem_color_bus),
		  .XC(mem_x_bus[IDX16 * WIDTH_BIT +: WIDTH_BIT]),
		  .YC(mem_y_bus[IDX16 * HEIGHT_BIT +: HEIGHT_BIT]),
        .VGA_x(inst_x_bus[IDX16 * 10 +: 10]),
        .VGA_y(inst_y_bus[IDX16 * 9 +: 9 ]),
        .VGA_color(inst_color_bus[IDX16 * COLOR_DEPTH +: COLOR_DEPTH]),
        .VGA_write(inst_write[IDX16]),
        .done(inst_done[IDX16])
    );




	// display 16 objects in sequenses
	parameter N = N_OBJ;

	wire main_start = ~KEY[1];
	wire keypressed;                 
	reg  [3:0] current_idx;        // 4 digit num represent 16 objects
	reg  show_busy;
	reg  push;                         // sign for go, go for printing next oject

	reg [N-1:0] inst_go;                // 16 digit go sign
	integer i;
	always @(*) begin
		 for (i = 0; i < N; i = i + 1)
			  inst_go[i] = (push && (current_idx == i)) ? 1'b1 : 1'b0;    // if push and is the corresponding object
	end

	always @(posedge CLOCK_50) begin
		 if(!Resetn) begin
			  show_busy <= 1'b0;
			  current_idx <= 4'b0000;
			  push <= 1'b0;
		 end 
		 else begin
			  push <= 1'b0;
			  if(!show_busy) begin
					if (keypressed) begin
						 show_busy <= 1'b1;
						 current_idx <= 4'b0000;
						 push <= 1'b1;                 // print the first one 
					end
			  end 
			  else begin
					// if current one is done, then move to next one
					if (inst_done[current_idx]) begin   // if this object is done
						 if(current_idx == N-1) begin
							  show_busy <= 1'b0;             // all done
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
	
	// some memories
	wire [WIDTH_BIT - 1 : 0] XC = mem_x_bus[current_idx * WIDTH_BIT +: WIDTH_BIT];
	wire [HEIGHT_BIT - 1 : 0] YC = mem_y_bus[current_idx * HEIGHT_BIT +: HEIGHT_BIT];
	object_mem MEM1 ({YC,XC}, CLOCK_50, mem_color_bus[IDX1 * COLOR_DEPTH +: COLOR_DEPTH]);
      defparam MEM1.n = COLOR_DEPTH;
      defparam MEM1.Mn = WIDTH_BIT + HEIGHT_BIT;
      defparam MEM1.INIT_FILE = "./MIF/thumb.mif";
		  
	object_mem MEM2 ({YC,XC}, CLOCK_50, mem_color_bus[IDX2 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM2.n = COLOR_DEPTH;
		defparam MEM2.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM2.INIT_FILE = "./MIF/angry.mif";
		
	object_mem MEM3 ({YC,XC}, CLOCK_50, mem_color_bus[IDX3 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM3.n = COLOR_DEPTH;
		defparam MEM3.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM3.INIT_FILE = "./MIF/laugh.mif";
		
	object_mem MEM4 ({YC,XC}, CLOCK_50, mem_color_bus[IDX4 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM4.n = COLOR_DEPTH;
		defparam MEM4.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM4.INIT_FILE = "./MIF/sad.mif";
		
	object_mem MEM5 ({YC,XC}, CLOCK_50, mem_color_bus[IDX5 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM5.n = COLOR_DEPTH;
		defparam MEM5.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM5.INIT_FILE = "./MIF/reject.mif";
		
	object_mem MEM6 ({YC,XC}, CLOCK_50, mem_color_bus[IDX6 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM6.n = COLOR_DEPTH;
		defparam MEM6.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM6.INIT_FILE = "./MIF/cool.mif";
		
	object_mem MEM7 ({YC,XC}, CLOCK_50, mem_color_bus[IDX7 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM7.n = COLOR_DEPTH;
		defparam MEM7.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM7.INIT_FILE = "./MIF/shock.mif";
		
	object_mem MEM8 ({YC,XC}, CLOCK_50, mem_color_bus[IDX8 * COLOR_DEPTH +: COLOR_DEPTH]);
		defparam MEM8.n = COLOR_DEPTH;
		defparam MEM8.Mn = WIDTH_BIT + HEIGHT_BIT;
		defparam MEM8.INIT_FILE = "./MIF/six.mif";
		
	// random generator
	wire rand_busy, rand_start;
	random_start_ver Random_Generator (.clk(CLOCK_50), .resetn(Resetn), .start(rand_start), .random_num(card_nums), .random_assign_busy(rand_busy));
	
	control CRTL (.clock(CLOCK_50), .resetn(Resetn), .main_start(main_start), .rand_busy(rand_busy), .show_busy(show_busy), 
							.rand_start(rand_start), .update_start(keypressed));
endmodule

module control (
	input wire clock,
	input wire resetn,
	input wire main_start,
	input wire rand_busy,
	input wire show_busy,
	
	output wire rand_start,
	output wire update_start
);

	parameter idle = 2'b00, press = 2'b01, update = 2'b10, wait_update = 2'b11;
	
	reg [1:0] current_s, next_s;
	
	always @(*)
		case (current_s)
			idle: if (main_start) next_s = press; else next_s = idle;
			press: if (main_start || rand_busy) next_s = press; else next_s = update;
			update: next_s = wait_update;
			wait_update: if (show_busy) next_s = wait_update; else next_s = idle;
		endcase
		
	always @(posedge clock)
		if (!resetn)
			current_s <= idle;
		else
			current_s <= next_s;
			
	assign rand_start = (current_s == press) ? main_start : 1'b0;
	assign update_start = (current_s == update);

endmodule
