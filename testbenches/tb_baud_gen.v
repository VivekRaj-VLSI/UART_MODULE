`timescale 1ns/1ps

module baud_gen_tb;

    reg clk;
    reg reset;
    wire tick;

    // Instantiate DUT
    baud_gen uut (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );
    initial begin
    $dumpfile("baud.vcd");
    $dumpvars(0, baud_gen_tb);
end

    // 50 MHz clock (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        reset = 1;

        // Hold reset for a few cycles
        #50;
        reset = 0;

        // Run long enough to observe multiple ticks
        #(20 * 11000);

        $finish;
    end

    // Display whenever tick occurs
    always @(posedge clk) begin
        if (tick)
            $display("Time = %0t ns : Tick Generated", $time);
    end

endmodule