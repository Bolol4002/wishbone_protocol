module wishbone_slave(
    input clk,
    input rst,
    input cyc,
    input stb,
    input we,
    input [7:0] adr,
    input [7:0] dat_o,

    output reg ack,
    output reg [7:0] dat_i
);

reg [7:0] memory [0:255];

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        ack <= 0;
    end
    else
    begin
        if (cyc && stb)
        begin
            ack <= 1;

            if (we)
                memory[adr] <= dat_o;   
            else
                dat_i <= memory[adr];   
        end
        else
            ack <= 0;
    end
end

endmodule
