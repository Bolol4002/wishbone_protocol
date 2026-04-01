`include "wishbone_master.v"
`include "wishbone_slave.v"
`timescale 1ns/1ps
module wishbone_tb;

reg clk;
reg rst;
reg start;
reg [7:0] adr_in;
reg [7:0] wr_dat_in;

wire cyc;
wire stb;
wire we;
wire ack;
wire busy;

wire [7:0] adr;
wire [7:0] dat_o;
wire [7:0] dat_i;

// Instantiate Master
wishbone_master master (
    .clk(clk),
    .rst(rst),
    .ack(ack),
    .dat_i(dat_i),
    .start(start),
    .adr_in(adr_in),
    .dat_in(wr_dat_in),
    .cyc(cyc),
    .stb(stb),
    .we(we),
    .dat_o(dat_o),
    .adr(adr),
    .busy(busy)
);

// Instantiate Slave
wishbone_slave slave (
    .clk(clk),
    .rst(rst),
    .cyc(cyc),
    .stb(stb),
    .we(we),
    .adr(adr),
    .dat_o(dat_o),
    .ack(ack),
    .dat_i(dat_i)
);

always #5 clk = ~clk;   

always @(posedge clk)
begin
    $display("%0t\t%0b    %0b   %0b   %0b  %0b   0x%0h  0x%0h  0x%0h", $time, busy, cyc, stb, we, ack, adr, dat_o, dat_i);
end

initial
begin
    $dumpfile("wishbone.vcd");
    $dumpvars(0, wishbone_tb);

    clk = 0;
    rst = 1;
    start = 0;
    adr_in = 8'h00;
    wr_dat_in = 8'h00;

    $display("Time\tbusy cyc stb we ack adr dat_o dat_i");

    #20 rst = 0;

    // Write 0xAA to address 0x10
    @(posedge clk);
    adr_in = 8'h10;
    wr_dat_in = 8'hAA;
    start = 1;
    @(posedge clk);
    start = 0;

    wait (ack == 1);
    wait (ack == 0);

    // Write 0x55 to address 0x20
    @(posedge clk);
    adr_in = 8'h20;
    wr_dat_in = 8'h55;
    start = 1;
    @(posedge clk);
    start = 0;

    wait (ack == 1);
    wait (ack == 0);
    repeat (3) @(posedge clk);

    $display("Memory[0x10]=0x%0h", slave.memory[8'h10]);
    $display("Memory[0x20]=0x%0h", slave.memory[8'h20]);

    #10;
    $finish;
end

endmodule
