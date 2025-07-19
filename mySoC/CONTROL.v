`include "defines.vh"

module CONTROL #( //according to miniRV指令总表 
    parameter R_    =    7'b0110011,
    parameter I_    =    7'b0010011,
    parameter LW_   =    7'b0000011,
    parameter JALR_ =    7'b1100111,
    parameter SW_   =    7'b0100011,
    parameter B_    =    7'b1100011,
    parameter LUI_  =    7'b0110111,
    parameter JAL_  =    7'b1101111
)(
    input wire [6:0] opcode,
    input wire [2:0] func3,
    input wire [6:0] func7,
    output reg [3:0] npc_op,
    output reg [2:0] sext_op,
    output reg [2:0] rf_wsel,
    output reg      rf_we,
    output reg      alu_b_sel,
    output reg [3:0]alu_op,
    output reg      en_data_trans
);


//the combination logic part is based on the "TWO TABLE"
//generate signals for npc
    always @ (*) begin
        case(opcode) 
            R_ : npc_op = `NPC_PC4;
            I_ : npc_op = `NPC_PC4;
            LW_: npc_op = `NPC_PC4;
            JALR_: npc_op = `NPC_ALU;
            SW_: npc_op = `NPC_PC4;
            B_ : npc_op = `NPC_B;//这里的macro其实涵盖了三个情况，但是共用一个命名
            LUI_: npc_op = `NPC_PC4;
            JAL_ : npc_op = `NPC_JMP;
            default: npc_op = `NPC_PC4;// cover no case
        endcase
    end
            

//to be 

//for register file(rf)
    always @ (*) begin
        case(opcode) 
            SW_: rf_we = 1'b0;
            B_  : rf_we = 1'b0;
            default: rf_we = 1'b1;  //因为简单，所以偷懒
        endcase
    end

    always @(*) begin
        case(opcode) 
            R_: rf_wsel = `WB_ALU;
            I_: rf_wsel = `WB_ALU;
            LW_: rf_wsel =`WB_OUTSIDE;
            JALR_:rf_wsel=`WB_PC4;
            LUI_: rf_wsel=`WB_EXT;
            JAL_: rf_wsel=`WB_PC4;
            default: rf_wsel = `WB_PC4;//这是可以乱写的，赋值是为了避免锁存器！ 胡乱赋值的！ //如果不用写回，rf_we会处理
        endcase
    end

//for sext
    always @(*) begin
        case(opcode) 
            //R_ to default
            I_:     sext_op = (func3 == 001 || func3 == 101) // for shamt
                             ? `EXT_SHIFT : `EXT_I;
            LW_:    sext_op = `EXT_I;
            JALR_:  sext_op = `EXT_I;
            SW_:    sext_op = `EXT_S;
            B_ :    sext_op = `EXT_B;
            LUI_:   sext_op = `EXT_U;
            JAL_:   sext_op = `EXT_J;
            default:sext_op = `EXT_I;//这是可以乱写的！      //目前我觉得不用
        endcase
    end

//for alu
    always @ (*) begin
        case(opcode)  //specifically for this part i write according to "TWO TABLE"
            R_: case(func3) 
                    3'b000: alu_op = `ALU_ADD;
                    3'b111: alu_op = `ALU_AND;
                    3'b110: alu_op = `ALU_OR;
                    3'b100: alu_op = `ALU_XOR;
                    3'b001: alu_op = `ALU_SLL;
                    3'b101: alu_op = (func7 == 7'b0000000)
                                     ? `ALU_SRL : `ALU_SRA;
                    default:alu_op = `ALU_ADD ;//这是可以乱写的！
                endcase
            I_: case(func3) 
                    3'b000: alu_op = `ALU_ADD;
                    3'b111: alu_op = `ALU_AND;
                    3'b110: alu_op = `ALU_OR;
                    3'b100: alu_op = `ALU_XOR;
                    3'b001: alu_op = `ALU_SLL;
                    3'b101: alu_op = (func7 == 7'b0000000)
                                     ? `ALU_SRL : `ALU_SRA;
                    default:alu_op = `ALU_ADD ;//这是可以乱写的！
                endcase
            LW_:            alu_op = `ALU_ADD;
            JALR_:           alu_op = `ALU_ADD;
            SW_:            alu_op = `ALU_ADD;
            B_: case(func3)
                    3'b000: alu_op = `ALU_BEQ;
                    3'b001: alu_op = `ALU_BNE;
                    3'b100: alu_op = `ALU_BLT;
                    default:alu_op = `ALU_ADD; //for lui and jal, 可以可以乱写
                endcase
            default:        alu_op = `ALU_ADD; //乱写的
        endcase
    end
 
    // for alu_sel, my method is to find the ones using rd_2, and the extra is to be sext(imm-extending)
    always @ (*) begin
        case(opcode) 
            R_:     alu_b_sel = `ALUB_RS2;
            SW_:    alu_b_sel = `ALUB_EXT;
            B_:     alu_b_sel = `ALUB_RS2;
            default: alu_b_sel = `ALUB_EXT; //这里稍微有点不规范，因为这里的default
                                            //同时包含了有效情况与无效情况（即可乱写情况）
        endcase
    end

//for outside
    always @ (*) begin
        case(opcode) 
            SW_:    en_data_trans = `WRITE;
            LW_:    en_data_trans = `WRITE;
            default: en_data_trans = `READ;
        endcase
    end
endmodule
