/*一个是card_num register，
它是用来存那个48位的卡的信息的。
接口要有一个48位的load，一个load_enable，
和一个48位的输出用来输出它自己*/
module card_num_regsiter (
    input resetn,
    input clk,
    input [0:47]load,
    input load_enable,
    output reg[0:47]new_state
);
    always @(posedge clk) begin
        if(!resetn)
            new_state <= 48'b0;
        else if(load_enable)
            new_state <= load;
    end
    
endmodule