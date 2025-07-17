`include "defines.vh"

module SEXT(
    input wire [24:0] din,
    input wire [2:0]  sext_op,
    output reg [31:0] sext
);

always @ (*) begin
    case(sext_op) 
        `EXT_I : sext = din[24]? {20'hFFFFF, din[24:13]} : {20'h00000, din[24:13]};//addi, ori, jalr, etc
        `EXT_U : sext = {din[24:5], 12'h000};                                       //lui
        `EXT_SHIFT: sext = {27'd0, din[17:13]};                                     //srli, slli, srai
        `EXT_S : sext = din[24] ? {20'hFFFFF, din[24:18], din[4:0]} : {20'd0, din[24:18], din[4:0]};//sw
        `EXT_B : sext = din[24] ? {20'hFFFFF,  din[0], din[23:18], din[4:1], 1'b0}      
                                : {20'd0,      din[0], din[23:18], din[4:1], 1'b0};  //beq,blt
        `EXT_J : sext = din[24] ? {12'hFFF,   din[12:5], din[13], din[23:14], 1'b0}
                                : {12'd0,     din[12:5], din[13], din[23:14], 1'b0}; //jal
        default: sext = 32'd0;                                                        // for rigester to rigester operation
    endcase
end

endmodule

    