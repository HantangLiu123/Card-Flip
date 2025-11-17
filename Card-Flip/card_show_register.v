/*还有一个是一个card_show register，16位，
用来存储每个卡是在翻开状态还是在盖上的状态。
接口要一个reset(16位都变成0），idx（用来确认需要改哪一位），
new_status（改的那一位改成什么），
enable（激活更改），和一个16位的输出来输出它自己*/

module card_show_register (
    input resetn,
    input clk,
    input enable,
    input [3:0]idx,
    input new_status,
    output reg [0:15]new_map
);
    always @(posedge clk)begin
        if(!resetn)begin
            new_map <= 16'b0;
        end
        else begin
            if(enable)begin
                new_map[idx] <= new_status;
            end
        end
    end

endmodule
