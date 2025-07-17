`timescale 1ns / 1ps
`include "defines.vh"

module ALU(
    //data
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] imm,
    //control
    input wire [3:0]  alu_op,
    input wire        alu_b_sel,
    //output
    output reg [31:0] alu_c, //怪怪的，可以问老师，为什么要声明成reg
    output reg        alu_f
);

    wire [31:0] A = data_1;
    wire [31:0] B = alu_b_sel ? imm : data_2;
    reg [31:0] C;
    wire [4: 0] shift_amount = B[4:0];

    always @(*) begin 
        case(alu_op)
            `ALU_ADD: alu_c = A + B;  // this includes jalr
            `ALU_AND: alu_c = A & B;
            `ALU_OR:  alu_c = A | B;
            `ALU_XOR: alu_c = A ^ B;
            `ALU_SLL: alu_c = A << shift_amount;                                       //而控制型号的命名与表格二不一致，因为是照着打的
            `ALU_SRL: alu_c = A >> shift_amount;
            `ALU_SRA: alu_c = A[31] ? ((32'hFFFFFFFF<<(32-shift_amount))|(A>>shift_amount))  //出入
                            : (A >> shift_amount);                                                       
            default: begin
                    alu_c = 32'hdeadbeef;
            end
        endcase
        case(alu_op) 
             `ALU_BEQ: alu_f = (A == B)? 1'b1 : 1'b0 ;    //注意，数据通路的信号命名与画图一致，现在还有不一致，慢慢改
             `ALU_BLT: begin
                          C = A + (~B) + 1;
                          alu_f = C[31] ? 1'b1 : 1'b0 ;
                       end
             `ALU_BNE: alu_f = (A !=B )? 1'b1: 1'b0;
             default:  alu_f = 1'b0;
        endcase
    end
endmodule