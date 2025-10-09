module tb_elevator;
    reg clk, reset;
    reg [3:0] up_req, down_req;
    wire [1:0] current_floor;
    wire moving_up, moving_down, door_open;

    // Instantiate the elevator module
    elevator_control uut(
        .clk(clk),
        .reset(reset),
        .up_req(up_req),
        .down_req(down_req),
        .current_floor(current_floor),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .door_open(door_open)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation stimulus
    initial begin
        $dumpfile("elevator.vcd");
        $dumpvars(0, tb_elevator);

        reset = 1; up_req = 0; down_req = 0;
        #10 reset = 0;

        #10 up_req = 4'b0101;   
        #20 up_req = 4'b0000;
        #50 down_req = 4'b1000; 
        #40 down_req = 4'b0000;
        #30 up_req = 4'b0010;   
        #20 up_req = 4'b0000;

        #25 down_req = 4'b0100; 
        #30 down_req = 4'b0000;

        #40 up_req = 4'b1001;   
        #20 up_req = 4'b0000;

        #600 $finish;           
    end

    
    always @(posedge clk) begin
        $display("Time: %0d | Floor: %0d | Up: %b | Down: %b | Door: %b | Requests: %b",
                 $time, current_floor, moving_up, moving_down, door_open, uut.requests);
    end

endmodule
