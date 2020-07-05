`include "defines.svh"
module eth_rx_fsm
    (
        input clk,
        input rstn,
        input [`DATA_WIDTH -1:0] indata,
        input insop, ineop,
        input fifo_full,
        output reg out_wr_en,
        output reg [`PKT_WIDTH-1:0] out_data
    );

    bit [2:0] current_state;
    bit [2:0] next_state ='b1;
    parameter IDLE = 4'd0;
    parameter DEST_ADDR_RX= 4'd1;
    parameter SRC_ADDR_RX= 4'd2;
    parameter DATA_RX= 4'd3;
    parameter DONE = 4'd4;

    bit pkt_sop, pkt_eop;
    bit data_begin;
    bit [`DATA_WIDTH -1:0] pkt_dest_addr, pkt_src_addr, pkt_data, pkt_crc_data;

//    parameter PORT_A_ADDR = 32'hABCD;
//    parameter PORT_B_ADDR = 32'hEFEF;
//    parameter IP_PORT_A_ADDR = 32'h0123;
//    parameter IP_PORT_B_ADDR = 32'h4567;
    

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
                    next_state = DEST_ADDR_RX;
                end
                else
                begin
                    next_state = IDLE;
                end
            end

           DEST_ADDR_RX:
           begin
               if(indata == `PORT_A_ADDR || indata == `PORT_B_ADDR)
               begin
                   pkt_dest_addr = indata;
                   next_state = SRC_ADDR_RX;
               end
               else
               begin
                   next_state = current_state;
               end
           end

           SRC_ADDR_RX:
               begin
                   if(indata == `IP_PORT_A_ADDR || indata == `IP_PORT_B_ADDR)
                   begin
                       pkt_src_addr = indata;
                       next_state = DATA_RX;
                   end
                   else
                   begin
                       next_state = current_state;
                   end
               end

           DATA_RX:
           begin
               pkt_data = indata;
               next_state = DONE;
           end

           DONE:
           begin
               //Generating CRC data, Hardcoding for now
               pkt_crc_data = `CRC_DATA;
               pkt_eop = ineop;

               //             127,      126-97,       96-65,      64-33,   32-1        ,    0
               //out_data = {pkt_eop, pkt_crc_data, pkt_src_addr, pkt_data, pkt_dest_addr, pkt_sop}; //[127......0]
               //             129,      128-97,       96-65,      64-33,   32-1        ,    0
               out_data = {pkt_eop, pkt_crc_data, pkt_src_addr, pkt_data, pkt_dest_addr, pkt_sop}; //[127......0]
               if(fifo_full)
               begin
                   out_wr_en = 0;
                   next_state = DONE;
               end
               else
               begin
                   out_wr_en = 1;
                   next_state = IDLE;
               end
           end
        endcase
    end
endmodule
