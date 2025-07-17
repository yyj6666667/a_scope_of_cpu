`timescale 1ns / 1ps

module PC(
    input wire clk,
    input wire rst,
    input wire [31:0] din,
    output reg [31:0] pc
);
    reg       flag;
    always @ (posedge clk or posedge rst) begin
          if(rst) begin
            pc   <= 32'h0000_0000;
            flag <= 1'b0;
        end else begin
            if(flag) begin
                pc <= din;      //问老师： 我还是有点没想通pc为什么要慢一拍往回传
            end else begin
                flag <= 1'b1;            
            end

 /*           if(rst) begin
                pc <= 32'h0;
            end else begin
                pc <= din;

            end */
    end
    end

endmodule

