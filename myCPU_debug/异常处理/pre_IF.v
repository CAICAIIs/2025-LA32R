module pre_IF_stage (
    input        clk,
    input        reset,
    input        br_taken_cancel,
    input        stall,
    input [31:0] br_target,
    input [31:0] ex_entry,     // 异常入口地址
    input        wb_ex,        // 异常发生标志
    input        flush,        // 异常返回指令
    
    output        inst_sram_en,
    output [3:0]  inst_sram_we,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    output reg  [31:0] pc,
    output reg    to_fs_valid
);

wire [31:0] next_pc;
wire [31:0] normal_pc;
always @(posedge clk) begin
    if (reset) begin
        pc <= 32'h1c000000;
        to_fs_valid <= 1'b1;
    end
    else if (flush) begin
        pc <= ex_entry;
        to_fs_valid <= 1'b1;
    end
    else if (br_taken_cancel) begin
        pc <= br_target;
        to_fs_valid <= 1'b1;
    end 
    else if(stall) begin
        pc <= pc;
        to_fs_valid <= to_fs_valid;
    end
    else begin
        pc <= pc + 4;
        to_fs_valid <= 1'b1;
    end
    
end

assign normal_pc = br_taken_cancel ? br_target : stall ? pc : pc + 4;
assign next_pc = flush ? ex_entry : normal_pc;  
assign inst_sram_we = 4'b0000;
assign inst_sram_wdata = 32'b0;
assign inst_sram_addr = next_pc;
assign inst_sram_en = 1'b1;
endmodule