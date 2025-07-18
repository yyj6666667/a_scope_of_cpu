module timer(
    input wire rst,  
    input wire clk,               
    input wire wen,     
    input wire [31:0] windex_to_timer,
    output reg[31:0] rdata  
);  

    reg [31:0] index;
    reg [31:0] count;
    reg [31:0] count_pro;
    wire [31:0] count_end = index + 1'b1;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            index <= 32'd0;
            count <= 32'd0;
            count_pro <= 32'd0;
            rdata <= 32'd66;
        end else begin
            if(wen) begin
                index <= windex_to_timer;
            end 
            if(count < count_end) begin
                count <= count + 1'd1;
                rdata <= count_pro;
            end else begin
                count <= 32'd0;
                count_pro <= count_pro + 1'd1;
            end
        end
    end

endmodule 