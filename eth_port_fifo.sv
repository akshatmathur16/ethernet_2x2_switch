`include "defines.svh"
module eth_port_fifo 
    (
        input clk,
        input rstn,
        input wr_en,
        input rd_en,
        input [`FIFO_WIDTH -1: 0] data_in,
        output reg [`FIFO_WIDTH -1: 0] data_out,
        output empty, full

    );

    reg [`FIFO_WIDTH -1: 0]mem[`FIFO_DEPTH -1: 0];
    bit [3:0] wr_ptr = 0;
    bit [3:0] rd_ptr = 0;

    bit empty_temp = 1'b1;
    bit full_temp = 1'b0;

    assign empty = empty_temp;
    assign full = full_temp;


    always @(*)
    begin
        if(wr_ptr == 0 && rd_ptr ==0)
            empty_temp = 1'b1;
        else 
            empty_temp = 1'b0;
        if(wr_ptr == `FIFO_DEPTH && rd_ptr ==0)
            full_temp = 1'b1;
        else
            full_temp = 1'b0;
    end

    always @(posedge clk)
    begin
        if(!rstn)
        begin
            data_out <= 'b0;
            wr_ptr <= 0;
            rd_ptr <= 0;
            for(int i=0; i < `FIFO_DEPTH -1; i++)
            begin
                mem[i] <= 'b0;
            end
        end
        else
        begin
            if(wr_en)
            begin
                if(~full)
                begin
                    mem[wr_ptr] <= data_in;
                    $display("SW_DEBUG: data = %h filled in fifo loc %h \n",mem[wr_ptr], wr_ptr);
                    if(wr_ptr == `FIFO_DEPTH -1)
                    begin
                        $display("SW_DEBUG: wr_ptr reached the end of fifo");
                        wr_ptr = 0;
                    end
                    else
                        wr_ptr++;
                end
                else
                begin
                    $display("SW_DEBUG: FIFO is full \n");
                end
            end
            else if(rd_en)
            begin
                if(~empty)
                begin
                    data_out <= mem[rd_ptr];
                    if(rd_ptr == `FIFO_DEPTH -1)
                    begin
                        $display("SW_DEBUG: rd_ptr reached the end of fifo");
                        rd_ptr = 0;
                    end
                    else
                        rd_ptr++;
                end
                else 
                begin
                    $display("SW_DEBUG: FIFO is empty \n");
                end
            end
        end
    end

endmodule
