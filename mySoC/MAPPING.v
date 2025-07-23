`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/17 00:57:28
// Design Name: 
// Module Name: MAPPING
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MAPPING(
    input  wire [3:0]  data,
    output reg [7:0] data_after_mapping
    );
    always @(*) begin
        case(data)
            4'd0:   data_after_mapping  =8'b11111100;
            4'd1:   data_after_mapping  =8'b01100000;
            4'd2:   data_after_mapping  =8'b11011010;
            4'd3:   data_after_mapping  =8'b11110010;
            4'd4:   data_after_mapping  =8'b01100110;
            4'd5:   data_after_mapping  =8'b10110110;
            4'd6:   data_after_mapping  =8'b10111110;
            4'd7:   data_after_mapping  =8'b11100000;
            4'd8:   data_after_mapping  =8'b11111110;
            4'd9:   data_after_mapping  =8'b11100110;
            4'd10:  data_after_mapping  =8'b11101110;
            4'd11:  data_after_mapping  =8'b00111110;
            4'd12:  data_after_mapping  =8'b00011010;
            4'd13:  data_after_mapping  =8'b01111010;
            4'd14:  data_after_mapping  =8'b10011110;
            4'd15:  data_after_mapping  =8'b10001110;
            default: data_after_mapping =8'b11111100;
        endcase
    end
endmodule
