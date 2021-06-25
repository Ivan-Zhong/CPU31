module dmem (
    input clk,
    input cs,
    input DM_R,
    input DM_W,
    input [10:0] DM_addr,
    input [31:0] DM_data_in,
    output [31:0] DM_data_out
);

reg [31:0] mem [0:127];
always @ (posedge clk)
begin
    if(cs && DM_W)
    begin
        mem[DM_addr] = DM_data_in;
    end
end

assign DM_data_out = (cs && DM_R) ? mem[DM_addr] : {32{1'bz}};

endmodule