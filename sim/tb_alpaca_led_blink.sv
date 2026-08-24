`timescale 1ns/1ps

module tb_alpaca_led_blink;

    logic       clk = 1'b0;
    logic       resetn = 1'b0;
    logic [1:0] user_led_n;

    always #5 clk = ~clk;

    alpaca_led_blink #(
        .CLOCK_HZ(8),
        .BLINK_HZ(1)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .User_LED_tri_o(user_led_n)
    );

    initial begin
        repeat (2) @(posedge clk);
        #1;
        assert (user_led_n == 2'b11)
            else $fatal(1, "LEDs must be off during reset");

        @(negedge clk);
        resetn = 1'b1;

        repeat (3) @(posedge clk);
        #1;
        assert (user_led_n == 2'b11)
            else $fatal(1, "D10 turned on before the half period");

        @(posedge clk);
        #1;
        assert (user_led_n == 2'b10)
            else $fatal(1, "D10 did not turn on active-low");

        repeat (4) @(posedge clk);
        #1;
        assert (user_led_n == 2'b11)
            else $fatal(1, "D10 did not turn off after a full period");

        $display("ALPACA: RTL heartbeat simulation passed");
        $finish;
    end

endmodule
