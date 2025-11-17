module counter(input game_start, input game_end, input clk, input resetn, output [6:0]HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    reg [11:0]dout;
    reg [25:0]Q;
    reg running;

    always @(posedge clk)begin
        if(!resetn)
            running <= 1'b0;
        else if(game_start)
            running <= 1'b1;
        else if(game_end)
            running <= 1'b0;
    end

    always @(posedge clk)begin
        if(!resetn)
            Q <= 26'b0;
        else if(running)begin
            if(Q == 26'd49999999)
                Q <= 26'b0;
            else
                Q <= Q + 1;
        end
    end
    always @(posedge clk)begin
        if(!resetn)
            dout <= 12'd0;
        else if(Q == 26'd49999999 && running)begin
            dout <= dout + 1'b1;
        end
    end

    reg [3:0]bcd1, bcd2, bcd3;
    always @(*)begin
        bcd1 = dout / 100;
        bcd2 = (dout % 100) / 10;
        bcd3 = dout % 10;
    end

    seg7_decoder seg1(.N(bcd3), .display(HEX0));
    seg7_decoder seg2(.N(bcd2), .display(HEX1));
    seg7_decoder seg3(.N(bcd1), .display(HEX2));
    seg7_decoder seg4(.N(4'd0), .display(HEX3));
    seg7_decoder seg5(.N(4'd0), .display(HEX4));
    seg7_decoder seg6(.N(4'd0), .display(HEX5));

endmodule

module seg7_decoder (N, display);
	input [3:0] N;
	output reg [6:0] display;
	
	always @(*) begin
		case (N)
			4'd0: display = 7'b1000000;
            4'd1: display = 7'b1111001;
            4'd2: display = 7'b0100100;
            4'd3: display = 7'b0110000;
            4'd4: display = 7'b0011001;
            4'd5: display = 7'b0010010;
            4'd6: display = 7'b0000010;
            4'd7: display = 7'b1111000;
            4'd8: display = 7'b0000000;
            4'd9: display = 7'b0010000;
		endcase
	end
endmodule