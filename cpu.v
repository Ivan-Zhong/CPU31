module cpu (
    input clk,
    input rst,
    input [31:0] inst,
    input [31:0] DM_data_out,
    output [31:0] pc,
    output DM_cs,
    output DM_R,
    output DM_W,
    output [10:0] DM_addr,
    output [31:0] DM_data_in
);

wire [3:0] aluc;
wire [1:0] M1;
wire [1:0] M2;
wire [1:0] M3;
wire M4;
wire [1:0] M5;
wire RF_W;
wire [31:0] npc;
wire [31:0] newpc;
wire [5:0] op;
wire [4:0] rsc;
wire [4:0] rtc;
wire [4:0] im_rdc;
wire [4:0] sa;
wire [5:0] func;
wire [4:0] ref_rdc;
wire [31:0] ref_rd;
wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_out;
wire [31:0] rs;
wire [31:0] rt;
wire [31:0] add_out;
wire [31:0] concat;
wire [31:0] zext5;
wire [31:0] sext16;
wire [31:0] zext16;
wire [31:0] sext18;
wire [31:0] M1_temp1;
wire [31:0] M1_temp2;
wire [31:0] M2_temp;
wire [31:0] M3_temp1;
wire [31:0] M3_temp2;
wire zero, carry, negative, overflow;

assign npc = pc + 4;
assign op = inst[31:26];
assign rsc = inst[25:21];
assign rtc = inst[20:16];
assign im_rdc = inst[15:11];
assign sa = inst[10:6];
assign func = inst[5:0];
assign concat = {pc[31:28], inst[25:0], 2'b00};
assign zext5 = {27'b0, sa};
assign sext16 = {{16{inst[15]}}, inst[15:0]};
assign zext16 = {16'b0, inst[15:0]};
assign sext18 = {{14{inst[15]}}, inst[15:0], 2'b0};
assign add_out = sext18 + npc;

wire _add_, _addu_, _sub_, _subu_, _and_, _or_, _xor_, _nor_, _slt_, _sltu_, _sll_, _srl_, _sra_, _sllv_, _srlv_, _srav_, _jr_;
wire _addi_, _addiu_, _andi_, _ori_, _xori_, _lw_, _sw_, _beq_, _bne_, _slti_, _sltiu_, _lui_, _j_, _jal_;

assign _add_ = (op == 6'b000000 && func == 6'b100000) ? 1'b1 : 1'b0;
assign _addu_ = (op == 6'b000000 && func == 6'b100001) ? 1'b1 : 1'b0;
assign _sub_ = (op == 6'b000000 && func == 6'b100010) ? 1'b1 : 1'b0;
assign _subu_ = (op == 6'b000000 && func == 6'b100011) ? 1'b1 : 1'b0;
assign _and_ = (op == 6'b000000 && func == 6'b100100) ? 1'b1 : 1'b0;
assign _or_ = (op == 6'b000000 && func == 6'b100101) ? 1'b1 : 1'b0;
assign _xor_ = (op == 6'b000000 && func == 6'b100110) ? 1'b1 : 1'b0;
assign _nor_ = (op == 6'b000000 && func == 6'b100111) ? 1'b1 : 1'b0;
assign _slt_ = (op == 6'b000000 && func == 6'b101010) ? 1'b1 : 1'b0;
assign _sltu_ = (op == 6'b000000 && func == 6'b101011) ? 1'b1 : 1'b0;
assign _sll_ = (op == 6'b000000 && func == 6'b000000) ? 1'b1 : 1'b0;
assign _srl_ = (op == 6'b000000 && func == 6'b000010) ? 1'b1 : 1'b0;
assign _sra_ = (op == 6'b000000 && func == 6'b000011) ? 1'b1 : 1'b0;
assign _sllv_ = (op == 6'b000000 && func == 6'b000100) ? 1'b1 : 1'b0;
assign _srlv_ = (op == 6'b000000 && func == 6'b000110) ? 1'b1 : 1'b0;
assign _srav_ = (op == 6'b000000 && func == 6'b000111) ? 1'b1 : 1'b0;
assign _jr_ = (op == 6'b000000 && func == 6'b001000) ? 1'b1 : 1'b0;
assign _addi_ = (op == 6'b001000) ? 1'b1 : 1'b0;
assign _addiu_ = (op == 6'b001001) ? 1'b1 : 1'b0;
assign _andi_ = (op == 6'b001100) ? 1'b1 : 1'b0;
assign _ori_ = (op == 6'b001101) ? 1'b1 : 1'b0;
assign _xori_ = (op == 6'b001110) ? 1'b1 : 1'b0;
assign _lw_ = (op == 6'b100011) ? 1'b1 : 1'b0;
assign _sw_ = (op == 6'b101011) ? 1'b1 : 1'b0;
assign _beq_ = (op == 6'b000100) ? 1'b1 : 1'b0;
assign _bne_ = (op == 6'b000101) ? 1'b1 : 1'b0;
assign _slti_ = (op == 6'b001010) ? 1'b1 : 1'b0;
assign _sltiu_ = (op == 6'b001011) ? 1'b1 : 1'b0;
assign _lui_ = (op == 6'b001111) ? 1'b1 : 1'b0;
assign _j_ = (op == 6'b000010) ? 1'b1 : 1'b0;
assign _jal_ = (op == 6'b000011) ? 1'b1 : 1'b0;

assign aluc[3] = _sll_ || _lui_ || _sllv_ || _slt_ || _slti_ || _sltiu_ || _sltu_ || _sra_ || _srav_ || _srl_ || _srlv_;

assign aluc[2] = _ori_ || _sll_ || _and_ || _andi_ || _nor_ || _or_ || _sllv_ || _sra_ || _srav_ || _srl_ || _srlv_ || _xor_ || _xori_;

assign aluc[1] = _sll_ || _add_ || _addi_ || _nor_ || _sllv_ || _slt_ || _slti_ || _sltiu_ || _sltu_ || _sub_ || _xor_ || _xori_ || _sw_ || _lw_;

assign aluc[0] = _subu_ || _ori_ || _nor_ || _or_ || _slt_ || _slti_ || _srl_ || _srlv_ || _sub_ || _beq_ || _bne_;

assign M1[1] = _add_ || _addu_ || _sub_ || _subu_ || _and_ || _or_ || _xor_ || _nor_ || _slt_ || _sltu_ || _sll_ || _srl_ || _sra_ || _sllv_ || _srlv_ || _srav_ || _addi_ || _addiu_ || _andi_ || _ori_ || _xori_ || _lw_ || _sw_ || (_beq_ == 1 && zero == 0) || (_bne_ == 1 && zero == 1) || _slti_ || _sltiu_ || _lui_ || _j_ || _jal_;

assign M1[0] = (_beq_ == 1 && zero == 1) || (_j_ == 1) || (_bne_ == 1 && zero == 0) || (_jal_ == 1);

assign M2[1] = _jal_;

assign M2[0] = _add_ || _addu_ || _sub_ || _subu_ || _and_ || _or_ || _xor_ || _nor_ || _slt_ || _sltu_ || _addi_ || _addiu_ || _andi_ || _ori_ || _xori_ || _lw_ || _sw_ || _beq_ || _bne_ || _slti_ || _sltiu_ || _sllv_ || _srav_ || _srlv_;

assign M3[1] = _ori_ || _lw_ || _sw_ || _addi_ || _addiu_ || _andi_ || _lui_ || _slti_ || _sltiu_ || _xori_;

assign M3[0] = _ori_ || _andi_ || _jal_ || _lui_ || _xori_ || _sltiu_;

assign M4 = _add_ || _addu_ || _sub_ || _subu_ || _and_ || _or_ || _xor_ || _nor_ || _slt_ || _sltu_ || _sll_ || _srl_ || _sra_ || _sllv_ || _srlv_ || _srav_ || _addi_ || _addiu_ || _andi_ || _ori_ || _xori_ || _slti_ || _sltiu_ || _lui_ || _jal_;

assign M5[1] = _jal_;

assign M5[0] = _ori_ || _lw_ || _addi_ || _addiu_ || _andi_ || _lui_ || _slti_ || _sltiu_ || _xori_;

assign RF_W = _add_ || _addu_ || _sub_ || _subu_ || _and_ || _or_ || _xor_ || _nor_ || _slt_ || _sltu_ || _sll_ || _srl_ || _sra_ || _sllv_ || _srlv_ || _srav_ || _addi_ || _addiu_ || _andi_ || _ori_ || _xori_ || _slti_ || _sltiu_ || _lui_ || _jal_ || _lw_;

assign DM_cs = _lw_ || _sw_;

assign DM_R = _lw_;

assign DM_W = _sw_;

assign M1_temp1 = M1[0] ? add_out : rs;
assign M1_temp2 = M1[0] ? concat : npc;
assign newpc = M1[1] ? M1_temp2 : M1_temp1;

assign M2_temp = M2[1] ? pc : zext5;
assign alu_a = M2[0] ? rs : M2_temp;

assign M3_temp1 = M3[0] ? zext16 : sext16;
assign M3_temp2 = M3[0] ? 4 : rt;
assign alu_b = M3[1] ? M3_temp1 : M3_temp2;

assign ref_rd = M4 ? alu_out : DM_data_out;

assign ref_rdc = (M5 == 2'b00) ? im_rdc : (M5 == 2'b01) ? rtc : 31;

assign DM_addr = alu_out;

assign DM_data_in = rt;

alu ALU(.a(alu_a), .b(alu_b), .aluc(aluc), .r(alu_out), .zero(zero), .carry(carry), .negative(negative), .overflow(overflow));

regfile cpu_ref(.clk(clk), .rst(rst), .RF_W(RF_W), .rd(ref_rd), .rdc(ref_rdc), .rtc(rtc), .rsc(rsc), .rs(rs), .rt(rt));

pcreg PCREG(.clk(clk), .rst(rst), .newpc(newpc), .pc(pc));
    
endmodule