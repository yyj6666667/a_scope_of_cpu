`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/17 10:44:36
// Design Name: 
// Module Name: SW
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


module SW(
        input wire [15:0] sw,
        output wire [31:0] sw_pro
    );
    assign sw_pro = {16'd0, sw};
endmodule
