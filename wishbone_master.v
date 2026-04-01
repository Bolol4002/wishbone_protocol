module wishbone_master(
    input clk,
    input rst,
    input ack,
    input [7:0] dat_i,
    input start,
    input [7:0] adr_in,
    input [7:0] dat_in,

    output reg cyc,
    output reg stb,
    output reg we,
    output reg [7:0] dat_o,
    output reg [7:0] adr,
    output reg busy
);

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        cyc <= 0;
        stb <= 0;
        we <= 0;
        adr <= 0;
        dat_o <= 0;
        busy <= 0;
    end
    else
    begin
        if (!busy && start)
        begin
            cyc <= 1;
            stb <= 1;
            we <= 1;          // write operation
            adr <= adr_in;
            dat_o <= dat_in;
            busy <= 1;
        end
        else if (busy && ack)
        begin
            cyc <= 0;
            stb <= 0;
            busy <= 0;
        end
    end
end

endmodule
