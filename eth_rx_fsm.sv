`include "defines.svh"
module eth_rx_fsm
    (
        input clk,
        input rstn,
        input [31:0] indata,
        input insop, ineop,
        output reg out_wr_en,
        output reg [66:0] out_data
    );

    //TODO support for src and crc
    // pkt structure 
    // [eop] [31:0 data] [31: 0 destination address] [sop]

    bit [2:0] current_state, next_state;
    parameter IDLE = 4'd0;
    parameter DEST_ADDR_RX= 4'd1;
    parameter DATA_RX= 4'd2;
    parameter DONE = 4'd3;

    bit pkt_sop, pkt_eop;
    bit data_begin;
    bit [31:0] pkt_dest_addr, pkt_data;

    parameter PORT_A_ADDR = 32'hABCD;
    parameter PORT_B_ADDR = 32'hEFEF;
    

    always @(posedge clk)
    begin
        if(!rstn)
        begin
            current_state <= IDLE;
            out_wr_en <= 0;
            out_data <= 33'd0;
        end
        else
        begin
            current_state <= next_state;
        end
    end

    always @(*)
    begin
        case(current_state)
            IDLE:
            begin
                out_wr_en = 'b0;
                if(insop)
                begin
                    pkt_sop = insop;
                    pkt_eop = ineop;
                    next_state = DEST_ADDR_RX;
                end
                else
                begin
                    next_state = IDLE;
                end
            end

           DEST_ADDR_RX:
           begin
               if(indata == PORT_A_ADDR || indata == PORT_B_ADDR)
               begin
                   pkt_dest_addr = indata;
                   next_state = DATA_RX;
               end
               else
               begin
                   $display("SW_DEBUG: Invalid Destination address \n");
               end
           end

           DATA_RX:
           begin
               pkt_data = indata;
               next_state = DONE;
           end

           DONE:
           begin
               out_data = {pkt_eop, pkt_data, pkt_dest_addr, pkt_sop}; //[66......0]
               out_wr_en = 1;
               next_state = IDLE;
           end
        endcase
    end
endmodule
