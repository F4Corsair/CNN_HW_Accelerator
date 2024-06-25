`timescale 10ns / 1ps
// `include "simpleCNN.v"

module stimulus();
    reg CLK, nRST;
    reg [0:6271] img [0:99];
    reg [3:0] label [0:99];
    reg START;
    reg [199:0] IMGIN;
    reg [4:0] X;
    reg [4:0] Y;
    wire [3:0] OUT;
    wire DONE;

    reg continue;
    integer i;
    integer match_count;
//    wire [2:0] cur_state;
//    wire [2:0] next_state;

    simpleCNN simCNN(.CLK(CLK), .nRST(nRST), .START(START), .X(X), .Y(Y), .IMGIN(IMGIN), .DONE(DONE), .OUT(OUT)); // .cur_state(cur_state), .next_state(next_state));

    initial // file read
    begin
        $readmemh("image.mem", img);
        $readmemh("label.mem", label);
    end

    initial
        CLK = 1'b0;
    always
        #2 CLK = ~CLK;
    
    initial begin
        match_count = 0;
        START = 1'b0;
        X = 5'd0;
        Y = 5'd0;
        nRST = 1'b0;
        for (i = 0; i < 100; i = i + 1)
        begin
            continue = 1'b0;
            #20 nRST = 1'b0;
            #10 nRST = 1'b1;
            #10 START = 1'b1;
            #10 START = 1'b0;
            // send IMGIN from here
            for (X = 0; X < 24; X = X + 1)
            begin
                for (Y = 0; Y < 24; Y = Y + 1)
                begin
                    IMGIN[199:0] = {
                                    img[i][224*Y+8*X+:40],
                                    img[i][224*(Y+1)+8*X+:40],
                                    img[i][224*(Y+2)+8*X+:40],
                                    img[i][224*(Y+3)+8*X+:40],
                                    img[i][224*(Y+4)+8*X+:40]
                                    };
                    #10;
                end
            end
            
            while (continue == 1'b0) begin
                @ (negedge CLK);
            end
        end
        #5 $finish;
    end

    always @ (posedge DONE) begin // compare label and OUT
        if(OUT[3:0] == label[i][3:0])
            match_count = match_count + 1;
        continue = 1'b1;
    end
endmodule