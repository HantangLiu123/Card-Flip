module random_assign(input clk, input resetn, input start, output [0:47]random_num, output done);
    recieve8_and_16 myrecieve(.clk(clk), .resetn(resetn), .start(start), .map(random_num), .done(done));
    
endmodule

module recieve8_and_16(
    input  wire clk,
    input  wire resetn,       
    input  wire start,         
    output reg [0:47] map,  
    output reg done        
);
    wire [2:0]value8;
    wire valid8, valid16;
    wire [3:0]value16;
    random8 myrand8(.clk(clk), .resetn(resetn), .start(start), .value(value8), .valid(valid8));
    random16 myrand16(.clk(clk), .resetn(resetn), .start(start), .value(value16), .valid(valid16));


    reg [63:0] buf16;    
    reg [23:0] buf8;     
    reg [4:0] idx_16;  // 0-15
    reg [3:0] idx_8;   // 0-7

    reg [3:0] idx0, idx1;
    reg [2:0] extrack3;
    reg [5:0] base0, base1;

    reg [3:0] pair_cnt;
    reg [1:0] state;

    parameter START = 2'd0, STORE = 2'd1, ASSIGN = 2'd2, DONE = 2'd3;
    always@(posedge clk)begin
        if(!resetn)begin
            map <= 48'd0;
            done <= 1'b0;
            buf8 <= 24'd0;
            buf16 <= 64'd0;
            idx_16 <= 5'd0;
            idx_8 <= 4'd0;
            pair_cnt <= 4'd0;
            state <= START;
        end
        else begin
				done <= 1'b0;
            case (state)
                START: begin
                    if(start) begin
                        map <= 48'd0;
                        buf16 <= 64'd0;
                        buf8 <= 24'd0;
                        idx_16 <= 5'd0;
                        idx_8 <= 4'd0;
                        pair_cnt <= 4'd0;
                        state <= STORE;
                    end
                end

                STORE: begin
                    if(valid16 && (idx_16 < 5'd16))begin
                        buf16[idx_16 * 4 +:4] <= value16;
                        idx_16 <= idx_16 + 5'd1;
                    end
                    if(valid8 && (idx_8 < 4'd8))begin
                        buf8[idx_8 * 3 +:3] <= value8;
                        idx_8 <= idx_8 + 4'd1;
                    end
                    if((idx_16 == 5'd16) && (idx_8 == 4'd8))begin
                        state <= ASSIGN;
                    end
                end

                ASSIGN: begin
                    idx0 = buf16[pair_cnt * 8 +:4];      // value of random16
                    idx1 = buf16[pair_cnt * 8 + 4 +:4];  
                    extrack3 = buf8[pair_cnt * 3 +:3];
                    base0 = idx0 * 6'd3;
                    base1 = idx1 * 6'd3;
                    map[base0 +:3] <= extrack3;
                    map[base1 +:3] <= extrack3;

                    if(pair_cnt == 4'd7)begin
                        pair_cnt <= 4'd0;
                        state <= DONE;
                    end
                    else begin
                        pair_cnt <= pair_cnt + 4'd1;
                    end
                end

                DONE: begin
                    done <= 1'b1;
                    state <= START;
                end
                
            endcase
        end
    end

endmodule


module lfsr_fib_16 #(parameter INITIAL_SEED = 16'hDEAD) (  // change the initial seed when using the model, #(.INITIAL_SEED(16'hDEAD))
    input wire resetn,
    input wire clk,
    output reg [15:0] seed
);
    wire next_bit;
    assign next_bit = ((seed[15] ^ seed[13]) ^ seed[12]) ^ seed[10];

    always @(posedge clk) begin
        if(!resetn)begin
            seed <= INITIAL_SEED;
        end
        else begin
            seed <= {seed[14:0], next_bit};
        end
    end

endmodule

module random8 #(parameter SEED = 16'hDEAD) (
    input wire clk,
    input wire resetn,      // 低有效复位
    input wire start,        // 拉高 1 拍启动一轮
    output reg [2:0]value,  // 当前输出（0..7）
    output reg valid        // 一轮输出期间恒为 1
);
    wire [15:0] seed;
    lfsr_fib_16 #(.INITIAL_SEED(SEED)) mylfsr (.clk(clk), .resetn(resetn), .seed(seed));

    reg [2:0] a, b, k;
	 reg running;

    wire [2:0] a_next = {seed[2:1], 1'b1};      // a must be odd num
    wire [2:0] b_next = seed[5:3];              // make an offset to prevent the first(k:0-7) or the last(k:1-8) always be zero 

    always @(posedge clk) begin
        if (!resetn) begin
            running <= 1'b0;
            k <= 3'd0;
            valid <= 1'b0;
            value <= 3'd0;
            a <= 3'd1;  // always make sure a is a odd number
            b <= 3'd0;
        end 
        else begin
				valid <= 1'b0;
            if (start && !running) begin
                a <= a_next;
                b <= b_next;
                k <= 3'd0;
                running <= 1'b1;
            end 
            else if (running) begin
                value <= (a * k + b) % 8;
					 valid <= 1'b1;
                if (k == 3'd7) begin
                    running <= 1'b0;
                end
                k <= k + 3'd1;
            end
        end
    end
endmodule

module random16 #(parameter SEED = 16'hBEEF) (
    input wire clk,
    input wire resetn,      
    input wire start,         
    output reg [3:0] value,  
    output reg valid
);
    wire [15:0]seed;
    lfsr_fib_16 #(.INITIAL_SEED(SEED)) mylfsr (.clk(clk), .resetn(resetn), .seed(seed));

    reg [3:0] a, b, k;
	 reg running;

    wire [3:0]a_next = {seed[3:1], 1'b1};  
    wire [3:0]b_next = seed[7:4];

    always @(posedge clk) begin
        if (!resetn) begin
            running <= 1'b0;
            k <= 4'd0;
            valid <= 1'b0;
            value <= 4'd0;
            a <= 4'd1;
            b <= 4'd0;
        end 
        else begin
				valid <= 1'b0;
            if (start && !running) begin
                a <= a_next;
                b <= b_next;
                k <= 4'd0;
                running <= 1'b1;
            end else if (running) begin
                // y = (a*k + b) mod 16
                value <= (a * k + b) % 16;
					 valid <= 1'b1;
                if (k == 4'd15) begin
                    running <= 1'b0;
                end
                k <= k + 4'd1;
            end
        end
    end
endmodule
