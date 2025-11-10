module card (Resetn, Clock, draw, card_num, show, obj_color, XC, YC, VGA_x, VGA_y, VGA_color, VGA_write, done);
    parameter RESOLUTION = "160x120"; // "640x480" "320x240" "160x120"
    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);
    parameter COLOR_DEPTH = 3;
    // by default, use offsets to center the object on the VGA display
    parameter XOFFSET = (RESOLUTION == "640x480") ? 320 : 
                                ((RESOLUTION == "320x240") ? 160 : 80);
    parameter YOFFSET = (RESOLUTION == "640x480") ? 240 : 
                                ((RESOLUTION == "320x240") ? 120 : 60);
    parameter LEFT = 2'b00 /*'a'*/, RIGHT = 2'b11/*'s'*/, UP = 2'b01/*'w'*/, DOWN = 2'b10/*'z'*/;
    parameter xOBJ = 4, yOBJ = 4;   // object size is 2^xOBJ x 2^yOBJ
    parameter BOX_SIZE_X = 1 << xOBJ;
    parameter BOX_SIZE_Y = 1 << yOBJ;
    parameter Mn = xOBJ + yOBJ; // address lines needed for the object memory
    parameter INIT_FILE = 
            (COLOR_DEPTH == 9) ? "./MIF/object_mem_16_16_9.mif" : 
                ((COLOR_DEPTH == 6) ?  "./MIF/object_mem_16_16_6.mif" : 
                "./MIF/object_mem_16_16_3.mif");

    // state names for the FSM that draws the object
    parameter idle = 2'b00, draw_row = 2'b01, next_row = 2'b10, done_draw = 2'b11
    
    input wire Resetn, Clock;
    input wire draw;                           // for enabling drawing
    input wire [2:0] card_num;                 // for telling the card which memory to pick
	 input wire show;									  // for telling the card is flipped or not
	output wire [nX-1:0] VGA_x;                 // for syncing with object memory
	output wire [nY-1:0] VGA_y;                 // for syncing with object memory
	output wire [COLOR_DEPTH-1:0] VGA_color;    // used to draw pixels
    output wire VGA_write;                      // pixel write control
    output reg done;                            // done drawing cycle

	wire [nX-1:0] X;    // X location 
	wire [nY-1:0] Y;    // Y location 
	wire [nX-1:0] size_x = BOX_SIZE_X;   // store the X size (must be power of 2)
	wire [nY-1:0] size_y = BOX_SIZE_Y;   // store the Y size
    output wire [xOBJ-1:0] XC;                  // used to access object memory
    output wire [yOBJ-1:0] YC;                  // used to access object memory
    reg write, Lxc, Lyc, Exc, Eyc;       // object control signals
    wire Right, Left, Up, Down;          // object direction
    reg [1:0] y_Q, Y_D;                  // FSM
    
	input wire [COLOR_DEPTH * 9 - 1:0] obj_color;    // object pixel colors, read from memory
	
    // object (x,y) location. For x, counter will be enabled when moving L/R, increment
    // for R, decrement for L. For y, counter will be enabled when moving U/D, increment 
    // for D, decrement for U
    assign X = XOFFSET;
    assign Y = YOFFSET;

    // these counter are used to generate (x,y) coordinates to read the object's pixels
    upDn_count U3 ({xOBJ{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC); // object column counter
        defparam U3.n = xOBJ;
    upDn_count U4 ({yOBJ{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC); // object row counter
        defparam U4.n = yOBJ;

    // FSM state table
    always @ (*)
        case (y_Q)
            idle: if (draw) Y_D = draw_row;	// begin to draw
						else Y_D = idle;				// stays at idle
				draw_row: if (XC != size_x-1) Y_D = draw_row;	// draw the whole row
							 else Y_D = next_row;
				next_row: if (YC != size_y-1) Y_D = draw_row;	// change to next row
							 else Y_D = done_draw;
				done_draw: if (draw) Y_D = draw_row;
							  else Y_D = idle;
        endcase
    // FSM outputs
    always @ (*)
    begin
        // default assignments
        write = 1'b0; 
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; done = 1'b0;
        case (y_Q)
            idle: begin Lxc = 1'b1; Lyz = 1'b1; end
				draw_row: begin Exc = 1'b1; write = 1'b1; end
				next_row: begin Lxc = 1'b1; Eyc = 1'b1; end
				done_draw: done = 1'b1;
        endcase
    end

    // FSM state FFs
    always @(posedge Clock)
        if (!Resetn)
            y_Q <= 2'b0;
        else
            y_Q <= Y_D;

    // read a pixel color from the object memory. We can use {YC,XC} because the x dimension
    // of the object memory is a power of 2
    object_mem U6 ({YC,XC}, Clock, obj_color);
        defparam U6.n = COLOR_DEPTH;
        defparam U6.Mn = xOBJ + yOBJ;
        defparam U6.INIT_FILE = INIT_FILE;

    // compute the (x,y) location of the current pixel to be drawn (or erased). We subtract
    // half the object's width and height because we want the objec to be centered at its 
    // original (x,y) location. We add (Xc,YC) to form the correct address of the pixel. The
    // object memory takes one clock cycle to provide data, so we register the computed (x,y)
    // location to remain synchronized
    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;

    // synchronize write signal with VGA_x, VGA_y, VGA_color 
    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;

    // use the corresponding color from the corresponding memory
    assign VGA_color = (show) ? obj_color[card_num * COLOR_DEPTH +: COLOR_DEPTH] : obj_color[8 * COLOR_DEPTH +: COLOR_DEPTH];

endmodule
