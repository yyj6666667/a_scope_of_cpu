`include "defines.vh"

module NPC(
    input wire [31:0] offset,
    input wire [31:0] alu_result,  //哎呀！  //注意，我们自己绘制的流程图不是这样的，而是单独用了二选一开关
    input wire [31:0] pc,          //有风险，因为我选择不按仓库自己单干,但是我在7,13，20行注释掉了
    input wire [3:0]  npc_op,
    input wire        br,
    output reg [31:0] npc,
    output wire [31:0] pc_4
);
    assign pc_4 = pc + 32'd4;
    always @ (*) begin
        case(npc_op)
            `NPC_PC4: npc = pc_4;
            `NPC_B: npc = br ? (pc + offset) : pc_4;
            `NPC_JMP: npc = pc + offset;
           // `NPC_ALU: npc = pc;  // 此时的pc = alu_result 才对，但是我们好像偷懒了
            `NPC_ALU: npc = alu_result; //for instruct jalr
            default:  npc = pc_4;
        endcase
    end
endmodule