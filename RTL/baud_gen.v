module baud_gen(
    input clk,output  tick,input reset
);
reg [12:0] gencount;
always @(posedge clk)
    begin
        if (reset)
            begin
                gencount<=1'b0;
            end
        else if (gencount==5207)
            begin

                gencount<=0;
            end
        else
            begin
                gencount<=gencount+1'b1;

            end
    end
    assign tick =(gencount==5207);
endmodule