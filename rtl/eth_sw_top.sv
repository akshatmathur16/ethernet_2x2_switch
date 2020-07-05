`include "defines.svh"
module eth_sw_top
    (
        input clk,
        input rstn,
        input [`DATA_WIDTH -1:0] indataA,
        input insopA,
        input ineopA,
        input [`DATA_WIDTH -1: 0] indataB,
        input insopB,
        input ineopB,
        input rd_en[`PORT_COUNT],
        output reg [`DATA_WIDTH -1: 0] outdataA,
        output reg outsopA,
        output reg outeopA,
        output reg [`DATA_WIDTH -1: 0] outdataB,
        output reg outsopB,
        output reg outeopB,
        output portAstall_full, portBstall_full,
        output portAstall_empty, portBstall_empty 
    );

    bit out_wr_en [`PORT_COUNT];

    bit fifo_empty_out [`PORT_COUNT];
    bit fifo_full_out [`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_dest_addr[`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_src_addr[`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_crc_data[`PORT_COUNT];

    bit [`FIFO_WIDTH-1: 0] out_data[`PORT_COUNT-1: 0];

    bit [`FIFO_WIDTH -1: 0] fifo_data_out [`PORT_COUNT];

    wire validA;
    wire validB;

    initial begin
        portAstall = 0;
        portBstall = 0;
    end

//    assign fifo_dest_addr[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][32:1] :0):0); 
//    assign fifo_dest_addr[1] = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][32:1] :0):0); 
//    assign fifo_src_addr[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][96:65] :0):0); 
//    assign fifo_src_addr[1]  = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][96:65] :0):0); 
//    assign fifo_crc_data[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][128:97] :0):0); 
//    assign fifo_crc_data[1]  = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][128:97] :0):0); 
//

    assign fifo_dest_addr[0] = (rd_en[0] && ~rd_en[1]) ? fifo_data_out[0][32:1] :0;
    assign fifo_dest_addr[1] = (rd_en[1] && ~rd_en[0]) ? fifo_data_out[1][32:1] :0;
    assign fifo_src_addr [0] = (rd_en[0] && ~rd_en[1]) ? fifo_data_out[0][96:65] :0;
    assign fifo_src_addr [1] = (rd_en[1] && ~rd_en[0]) ? fifo_data_out[1][96:65] :0;
    assign fifo_crc_data [0] = (rd_en[0] && ~rd_en[1]) ? fifo_data_out[0][128:97] :0;
    assign fifo_crc_data [1] = (rd_en[1] && ~rd_en[0]) ? fifo_data_out[1][128:97] :0;

    assign portAstall_full = fifo_full_out[0];
    assign portAstall_empty = fifo_empty_out[0];
    assign portBstall_full = fifo_full_out[1];
    assign portBstall_empty = fifo_empty_out[1];

    eth_rx_fsm inst_eth_rx_fsm_A
        (
            .clk(clk),
            .rstn(rstn),
            .indata(indataA),
            .insop(insopA),
            .ineop(ineopA),
            .fifo_full(fifo_full_out[0]),
            .out_wr_en(out_wr_en[0]),
            .out_data(out_data[0])
        );

    eth_port_fifo inst_eth_port_fifo_A
        (
            .clk(clk),
            .rstn(rstn),
            .wr_en(out_wr_en[0]),
            .rd_en(rd_en[0]),
            .data_in(out_data[0]),
            .data_out(fifo_data_out[0]),
            .empty(fifo_empty_out[0]), 
            .full(fifo_full_out[0]),
            .valid(validA)

        );

    eth_rx_fsm inst_eth_rx_fsm_B
        (
            .clk(clk),
            .rstn(rstn),
            .indata(indataB),
            .insop(insopB),
            .ineop(ineopB),
            .fifo_full(fifo_full_out[1]),
            .out_wr_en(out_wr_en[1]),
            .out_data(out_data[1])
        );
        
    eth_port_fifo inst_eth_port_fifo_B
        (
            .clk(clk),
            .rstn(rstn),
            .wr_en(out_wr_en[1]),
            .rd_en(rd_en[1]),
            .data_in(out_data[1]),
            .data_out(fifo_data_out[1]),
            .empty(fifo_empty_out[1]), 
            .full(fifo_full_out[1]),
            .valid(validB)
        );

        always @(posedge clk)
        begin
            if(~rstn)
            begin
                outdataA <= 0;
                outsopA <= 0;
                outeopA <= 0;
            end
            else
            begin
                if(rd_en[0] && ~rd_en[1]) // application wants to transmit from portA fifo 
                begin 
                if(fifo_data_out[0][0] && validA)
                begin
                    if(fifo_crc_data[0] == `CRC_DATA)
                    begin
                        if(fifo_dest_addr[0] == `PORT_A_ADDR)
                        begin
                            outdataA <= fifo_data_out[0][64:33];
                            outsopA <= fifo_data_out[0][0];
                            outeopA <= fifo_data_out[0][129];
                            $display("SW_DEBUG TOP: Data =%h from Port A read and transmitted to output portA \n",fifo_data_out[0][64:33]);
                            @(posedge clk);
                            outsopA <= 'b0; 
                            outeopA <= 'b0; 
                        end
                        else if(fifo_dest_addr[0] == `PORT_B_ADDR)
                        begin
                            outdataB <= fifo_data_out[0][64:33];
                            outsopB <= fifo_data_out[0][0];
                            outeopB <= fifo_data_out[0][129];
                            $display("SW_DEBUG TOP: Data = %h from Port A read and transmitted to output portB \n",fifo_data_out[0][64:33]);
                            @(posedge clk);
                            outsopB <= 'b0; 
                            outeopB <= 'b0; 
                        end
                        else
                        begin
                            $display("SW_DEBUG TOP: Incorrect destination address in the packet \n");
                        end
                    end
                    else
                    begin
                        $display($time, "SW_DEBUG TOP: Incorrect CRC address received at Input Port A, PKT Corrupted = %h\n",fifo_crc_data[0]);
                    end
                end
            end
        end
        always @(posedge clk)
        begin
            if(~rstn)
            begin
                outdataB <= 0;
                outsopB <= 0;
                outeopB <= 0;
            end
            else
            begin
                if(rd_en[1] && ~rd_en[0]) 
                begin
                    if(fifo_data_out[1][0] && validB)
                    begin
                        if(fifo_crc_data[1] == `CRC_DATA)
                        begin
                            if(fifo_dest_addr[1] == `PORT_A_ADDR)
                            begin
                                outdataA <= fifo_data_out[1][64:33];
                                outsopA <= fifo_data_out[1][0];
                                outeopA <= fifo_data_out[1][129];
                                $display("SW_DEBUG TOP: Data from Port B read and transmitted to output portA \n");
                                @(posedge clk);
                                outsopA <= 'b0; 
                                outeopA <= 'b0; 
                            end
                            else if(fifo_dest_addr[1] == `PORT_B_ADDR)
                            begin
                                outdataB <= fifo_data_out[1][64:33];
                                outsopB <= fifo_data_out[1][0];
                                outeopB <= fifo_data_out[1][129];
                                $display("SW_DEBUG TOP: Data from Port B read and transmitted to output portB \n");
                                @(posedge clk);
                                outsopB <= 'b0; 
                                outeopB <= 'b0; 
                            end
                            else
                                $display("SW_DEBUG TOP: Incorrect destination address in the packet \n");
                        end
                        else
                        begin
                            $display("SW_DEBUG TOP: Incorrect CRC address received at Input Port B, PKT Corrupted \n");
                        end
                    end
                end
            end
        end

        always @(posedge clk)
        begin
            if(rstn)
            begin
                if(rd_en[0] && rd_en[1]) 
                    $display("SW_DEBUG TOP: Trying to Read from both FIFOs, Feature Unsupported \n");
                if(~rd_en[0] && ~rd_en[1]) 
                    $display("SW_DEBUG TOP: %t Application not reading from any port \n", $time);
            end
        end

endmodule
