module counter(input game_start, input game_end, input clk, input reset, output [6:0]HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    reg [11:0]dout;
    reg [25:0]Q;
    reg running;

    always @(posedge clk)begin
        if(!reset)
            running <= 1'b0;
        else if(game_start)
            running <= 1'b1;
        else if(game_end)
            running <= 1'b0;
    end

    always @(posedge clk)begin
        if(!reset)
            Q <= 26'b0;
        else if(running)begin
            if(Q == 26'd49999999)
                Q <= 26'b0;
            else
                Q <= Q + 1;
        end
    end
    always @(posedge clk)begin
        if(!reset)
            dout <= 12'd0;
        else if(Q == 26'd49999999 && running)begin
            dout <= dout + 1'b1;
        end
    end
    seg7_4bit_decoder seg1(.N(dout[3:0]), .display(HEX0));
    seg7_4bit_decoder seg2(.N(dout[7:4]), .display(HEX1));
    seg7_4bit_decoder seg3(.N(dout[11:8]), .display(HEX2));
    seg7_4bit_decoder seg4(.N(4'd0), .display(HEX3));
    seg7_4bit_decoder seg5(.N(4'd0), .display(HEX4));
    seg7_4bit_decoder seg6(.N(4'd0), .display(HEX5));

endmodule



module seg7_4bit_decoder (N, display);
	input [3:0] N;
	output reg [6:0] display;
	
	always @(*) begin
		case (N)
			4'h0: display = 7'b1000000;
			4'h1: display = 7'b1111001;
			4'h2: display = 7'b0100100;
			4'h3: display = 7'b0110000;
			4'h4: display = 7'b0011001;
			4'h5: display = 7'b0010010;
			4'h6: display = 7'b0000010;
			4'h7: display = 7'b1111000;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0010000;
			4'hA: display = 7'b0001000;
			4'hB: display = 7'b0000011;
			4'hC: display = 7'b1000110;
			4'hD: display = 7'b0100001;
			4'hE: display = 7'b0000110;
			4'hF: display = 7'b0001110;
		endcase
	end
endmodule