`include "defines.vh"

module RF (
    input wire  clk,
    input wire  rst,

    input wire [31:0] inst, // a little 不规范,需要解析一遍
    //data of wD to be selected
    input wire [31:0] sext,
    input wire [31:0] data_to_cpu,
    input wire [31:0] pc_4,
    input wire [31:0] alu_c,  //这里有点多余

    input wire [2:0 ] rf_wsel,
    input wire        rf_we,
    
    output wire [31:0] rd_1,
    output wire [31:0] rd_2,
    output reg [31:0] wD
);
    //输入解析
    wire [4:0] rR1, rR2, wR;
    assign rR1 = inst[19:15];
    assign rR2 = inst[24:20];
    assign wR  = inst[11:7];
    //register 声明
    reg [31:0] register[31:0];
    //输出解析
    assign rd_1 = register[rR1];
    assign rd_2 = register[rR2];

    always @(*) begin
            case(rf_wsel)
                `WB_ALU : wD = alu_c;
                `WB_EXT : wD = sext;
                `WB_OUTSIDE: wD = data_to_cpu;
                `WB_PC4 : wD = pc_4;
                default : wD = data_to_cpu;       //应该包含了lw            //debug标志：有出入！
            endcase     
 //           register[0] = 0; //不知道这样写安不安全
    end

    integer i;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            for( i = 0; i < 32; i = i+1) begin
                register[i] <= 32'd0;
            end
        end else if(rf_we&&(wR!=0)) begin              //debug 出入
            register[wR] <= wD;
        end else begin
            register[0]  <= 0;
        end                                   //有出入
    end
endmodule
    