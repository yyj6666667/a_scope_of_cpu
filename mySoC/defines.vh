// Annotate this macro before synthesis
 //`define RUN_TRACE

// TODO: 在此处定义你的宏  //已进行代码检查
// npc_op
`define NPC_PC4         2'b00
`define NPC_B           2'b01
`define NPC_JMP         2'b10
`define NPC_ALU         2'b11

//rigester file
`define WB_ALU          3'b000
`define WB_EXT          3'b001
`define WB_OUTSIDE         3'b010
`define WB_PC4          3'b011

//sext_op for immidiate extend
`define EXT_I           3'b000 //不要小瞧它，addi，ori一类，甚至lw，jalr，也要依靠它
`define EXT_U           3'b001 //only for lui
`define EXT_SHIFT       3'b010 // for all shift , like srli,slli,srai
`define EXT_S           3'b011 // for sw
`define EXT_B           3'b100 // beq, blt
`define EXT_J           3'b101 // only for jal

//alu_op 这个是直接抄的，所以手动警告
`define ALU_ADD            4'b0000
`define ALU_SUB            4'b0001
`define ALU_AND            4'b0010
`define ALU_OR             4'b0011
`define ALU_XOR            4'b0100
`define ALU_SLL            4'b0101
`define ALU_SRL            4'b0110
`define ALU_SRA            4'b0111
`define ALU_BEQ            4'b1000
`define ALU_BNE            4'b1001
`define ALU_BLT            4'b1010


//alub_sel
`define ALUB_RS2       1'b0
`define ALUB_EXT       1'b1 

//dram
`define READ              2'b00
`define WRITE_SW          2'b11
`define WRITE_LW          2'b01

//rf_we  cause of only needing one value, so i ignore them


// 外设I/O接口电路的端口地址
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
`define PERI_ADDR_TIMER_READ   32'hFFFF_F020
`define PERI_ADDR_TIMER_WRITE 32'hFFFF_F024 
//equalls write index macro
//还有4*4键盘没有写
