module elevator_control(
    input clk,
    input reset,
    input [3:0] up_req, down_req,
    output reg [1:0] current_floor,
    output reg moving_up, moving_down, door_open
);

    
    parameter IDLE = 2'd0;
    parameter MOVING_UP = 2'd1;
    parameter MOVING_DOWN = 2'd2;
    parameter DOOR_OPEN = 2'd3;

    reg [1:0] state, next_state;
    reg [3:0] requests;
    reg [1:0] target_floor;

    integer i;


    always @(posedge clk or posedge reset) begin
        if (reset)
            requests <= 4'b0000;
        else
            requests <= requests | up_req | down_req;
    end

    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

   
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_floor <= 0;
        else begin
            if (state == MOVING_UP && current_floor < target_floor)
                current_floor <= current_floor + 1;
            else if (state == MOVING_DOWN && current_floor > target_floor)
                current_floor <= current_floor - 1;
            else if (state == DOOR_OPEN)
                requests[current_floor] <= 0; 
        end
    end

    
    task find_next_up;
        input [3:0] reqs;
        input [1:0] floor;
        output [1:0] next_floor;
        begin
            next_floor = floor;
            for (i = floor+1; i < 4; i = i + 1)
                if (reqs[i])
                    next_floor = i[1:0];
        end
    endtask

    task find_next_down;
        input [3:0] reqs;
        input [1:0] floor;
        output [1:0] next_floor;
        begin
            next_floor = floor;
            for (i = floor-1; i >= 0; i = i - 1)
                if (reqs[i])
                    next_floor = i[1:0];
        end
    endtask

    // FSM logic
    always @(*) begin
        next_state = state;
        moving_up = 0;
        moving_down = 0;
        door_open = 0;

        case (state)
            IDLE: begin
                if (|requests) begin
                    if (requests > (1 << current_floor)) begin
                        next_state = MOVING_UP;
                        find_next_up(requests, current_floor, target_floor);
                    end else if (requests < (1 << current_floor)) begin
                        next_state = MOVING_DOWN;
                        find_next_down(requests, current_floor, target_floor);
                    end else
                        next_state = DOOR_OPEN;
                end
            end

            MOVING_UP: begin
                moving_up = 1;
                if (current_floor == target_floor)
                    next_state = DOOR_OPEN;
            end

            MOVING_DOWN: begin
                moving_down = 1;
                if (current_floor == target_floor)
                    next_state = DOOR_OPEN;
            end

            DOOR_OPEN: begin
                door_open = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule


