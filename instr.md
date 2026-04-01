2. Simple Wishbone Master (Verilog)
module wishbone_master(
    input clk,
    input rst,
    input ack,
    input [7:0] dat_i,

    output reg cyc,
    output reg stb,
    output reg we,
    output reg [7:0] dat_o,
    output reg [7:0] adr
);

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        cyc <= 0;
        stb <= 0;
        we  <= 0;
        adr <= 0;
        dat_o <= 0;
    end
    else
    begin
        cyc <= 1;
        stb <= 1;
        we  <= 1;          // write operation
        adr <= 8'h10;
        dat_o <= 8'hAA;

        if(ack)
        begin
            cyc <= 0;
            stb <= 0;
        end
    end
end

endmodule
3. Simple Wishbone Slave (Verilog)
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
    if(rst)
    begin
        ack <= 0;
    end
    else
    begin
        if(cyc && stb)
        begin
            ack <= 1;

            if(we)
                memory[adr] <= dat_o;   // write
            else
                dat_i <= memory[adr];   // read
        end
        else
            ack <= 0;
    end
end

endmodule
4. What Happens in Operation

Write Cycle

Master sets cyc = 1, stb = 1

we = 1 (write enabled)

Address and data sent (adr, dat_o)

Slave receives and stores data

Slave sends ack = 1

Read Cycle

Master sets cyc and stb

we = 0

Slave sends data on dat_i

Slave sends ack

✅ If you want, I can also give:

Testbench for EDA Playground

Waveform explanation for your report

Simple Wishbone block diagram you can paste into your project.

YEA ALSO GIVE ME A GOOD TESTBENCH

Here is a simple but good Testbench you can use in EDA Playground to test the Wishbone Master and Slave modules implementing the Wishbone Bus Protocol.

This testbench:

Generates clock

Applies reset

Instantiates master and slave

Shows write and read operations

Verilog Testbench for Wishbone
`timescale 1ns/1ps

module wishbone_tb;

reg clk;
reg rst;

wire cyc;
wire stb;
wire we;
wire ack;

wire [7:0] adr;
wire [7:0] dat_o;
wire [7:0] dat_i;


// Instantiate Master
wishbone_master master (
    .clk(clk),
    .rst(rst),
    .ack(ack),
    .dat_i(dat_i),
    .cyc(cyc),
    .stb(stb),
    .we(we),
    .dat_o(dat_o),
    .adr(adr)
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


// Clock Generation
always #5 clk = ~clk;   // 10ns clock period


initial
begin
    $dumpfile("wishbone.vcd");
    $dumpvars(0, wishbone_tb);

    clk = 0;
    rst = 1;

    #20 rst = 0;

    // run simulation
    #200;

    $finish;
end

endmodule
What You Will See in the Waveform

Signals to observe in EDA Playground:

clk → system clock

rst → reset signal

cyc → bus cycle active

stb → transfer request

we → write enable

adr → memory address

dat_o → data from master

dat_i → data from slave

ack → slave acknowledge

Typical sequence in waveform:

Reset active

Master starts transaction (cyc and stb HIGH)

Write operation (we = 1)

Slave responds with ack

Transaction completes

✅ Tip for EDA Playground setup

Language: Verilog

Simulator: Icarus Verilog

Enable EPWave

If you want, I can also give you:

Complete single-file code for EDA Playground (Master + Slave + Testbench together)

Exact waveform explanation for your report section

A clean block diagram of Wishbone for your methodology slide.