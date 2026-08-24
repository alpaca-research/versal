`timescale 1ns/1ps

module alpaca_led_blink #(
    parameter int unsigned CLOCK_HZ = 100_000_000,
    parameter int unsigned BLINK_HZ = 1
) (
    input  logic       clk,
    input  logic       resetn,
    output logic [1:0] User_LED_tri_o
);

    localparam int unsigned HALF_PERIOD_TICKS = CLOCK_HZ / (2 * BLINK_HZ);
    localparam int unsigned COUNTER_WIDTH =
        (HALF_PERIOD_TICKS <= 1) ? 1 : $clog2(HALF_PERIOD_TICKS);

    logic [COUNTER_WIDTH-1:0] counter;
    logic                     led_on;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            counter <= '0;
            led_on  <= 1'b0;
        end else if (counter == HALF_PERIOD_TICKS - 1) begin
            counter <= '0;
            led_on  <= ~led_on;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    // D10 and D8 are active-low. Blink D10 and hold D8 off.
    always_comb begin
        User_LED_tri_o[0] = ~led_on;
        User_LED_tri_o[1] = 1'b1;
    end

endmodule
