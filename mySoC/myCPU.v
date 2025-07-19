`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,
 
    // Interface to Bridge
    input  wire [31:0]  data_to_cpu,  
    output wire         en_data_trans,
    output wire [31:0]  addr_out,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,                   
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);
    wire [31:0] pc;
    wire [31:0]  alu_c;
    // TODO: 完成你自己的单周期CPU设计
    //取指
`ifdef RUN_TRACE
    wire[15:0]   inst_addr = pc[17:2];
`else
    wire [13:0]  inst_addr = pc[15:2];
`endif 
    wire [31:0]  inst; 
    wire        rf_we;
    wire [2 :0] rf_wsel;
    wire  [3:0] npc_op;
    wire [2 :0] sext_op;
    wire [3 :0] alu_op;
    wire        alu_b_sel;
    //control part
    wire [6 :0] opcode;
    wire [2 :0] func3;
    wire [6 :0] func7;
    //npc part
    wire [31:0] npc;
    wire [31:0] pc_4; 
    wire [31:0] alu_result;
    //sext
    wire [31:0] sext;
    //rf
    wire [31:0] rd_1, rd_2;
    wire        alu_f;
    wire [31:0] wD;//to be finished

    assign opcode    = inst[6:0];
    assign func3     = inst[14:12];
    assign func7     = inst[31:25];

    assign addr_out  = (en_data_trans) ? alu_c : 32'hFFFF_FFFF; //直接在cpu接口处控制，预期处理问题十
    assign Bus_wdata = rd_2;
    //实例化
    CONTROL u_CONTROL(
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        //output
        .npc_op(npc_op),
        .sext_op(sext_op),
        .rf_wsel(rf_wsel),
        .rf_we(rf_we),
        .alu_b_sel(alu_b_sel),
        .alu_op(alu_op),
        .en_data_trans(en_data_trans)
    );

    PC u_PC(
        //input
        .clk(cpu_clk),
        .rst(cpu_rst),
        .din(npc),              
        //output
        .pc(pc)
    );

    NPC u_NPC(
        //input
        .pc(pc),
        .offset(sext),
        .alu_result(alu_c),
        .npc_op(npc_op),
        .br(alu_f),
        //output
        .npc(npc),
        .pc_4(pc_4)
    );

    SEXT u_SEXT(
        .din(inst[31:7]),
        .sext_op(sext_op),
        //output
        .sext(sext)
    );    

    RF u_RF(
        //input
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst(inst),
        .sext(sext),
        .data_to_cpu(data_to_cpu),
        .pc_4(pc_4),
        .alu_c(alu_c),
        .rf_wsel(rf_wsel),
        .rf_we(rf_we),
        //output
        .rd_1(rd_1),
        .rd_2(rd_2),          //出入
        .wD(wD)
    );

    ALU u_ALU(
        //input
        .data_1(rd_1),
        .data_2(rd_2),
        .imm(sext),
        .alu_op(alu_op),
        .alu_b_sel(alu_b_sel),
        //output
        .alu_c(alu_c),
        .alu_f(alu_f)
    );
   IROM u_IROM (
       .a          (inst_addr),
       .spo        (inst)
   );
`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = pc ;
    assign debug_wb_ena       = rf_we;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = wD;
`endif

endmodule
