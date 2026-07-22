module transmit(
    input clk,input reset,input[7:0] din,input tick,
    input  tx_start,output reg tx,output reg tx_busy
);
reg [1:0] state,next_state;
reg [3:0]count16;
reg[7:0]data;
reg[2:0]bitcount;
parameter idle=2'b00,start=2'b01,dtransmit=2'b10,stop=2'b11;

always @(*) //for next state logic
begin
    next_state=state;
    tx=1'b1;
    tx_busy= 1'b0;
 case (state)
    idle:
        begin
            if (tx_start)
                next_state=start;
            else
                next_state=idle;
                tx=1'b1;
                tx_busy=1'b0;
                
        end

    start:
        begin
            tx=1'b0;
            tx_busy=1'b1;
            if (tick&&count16==4'd 15)
                next_state=dtransmit;
            else 
                next_state=start;
        end

    dtransmit:
        begin
            tx=data[0];
            tx_busy=1'b1;
            if ( tick && count16==4'd15 && bitcount==3'd 7)
                next_state=stop;
            else
                next_state=dtransmit;
        end
    stop:
        begin
            tx=1'b1;
            tx_busy=1'b1;
            if (tick && count16==4'd15)
                next_state=idle;
            else
                next_state=stop;
        end
 endcase
end

always @(posedge clk,posedge reset) // shift register part
begin
    if (reset)
        begin
            state<=idle; //everything is reinitialized
            data<=0;
            bitcount<=0;
            count16<=0;
        end
    else
        begin
            state<=next_state;
            case(state)
                idle:
                    begin
                        if (tx_start)
                            data<=din;
                    end
                start:
                    begin
                        if (tick)
                            if(count16==4'd15)
                                count16<=4'b0;
                            else
                                count16<=count16+1;
                

                    end
                dtransmit:
                    begin
                        if (tick )
                        begin
                            if(count16==4'd15)
                                begin
                                    count16 <= 0;
                                    if (bitcount==3'd7)
                                        bitcount<=0;
                                    else
                                        begin
                                            data<=data>>1;
                                            bitcount<=bitcount+1;
                                        end
                                    
                                end
                            else
                                 count16<=count16+1;
                        end
                    end
                stop: 
                    begin
                        if(tick)
                            begin
                                if(count16==4'd15)
                                    count16 <= 0;
                                else
                                    count16 <= count16 + 1;
                            end
                    end


            endcase

        end

end
