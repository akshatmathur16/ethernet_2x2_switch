`include "defines.svh"
//TODO include src address, crc in packet.
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
        output reg portAstall, portBstall //will use to disable output data signals of A,B FIFOs, feature unsupported
    );

    bit out_wr_en [`PORT_COUNT];

    bit fifo_empty_out [`PORT_COUNT];
    bit fifo_full_out [`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_dest_addr[`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_src_addr[`PORT_COUNT];
    bit [`DATA_WIDTH-1: 0] fifo_crc_data[`PORT_COUNT];

    bit [`FIFO_WIDTH-1: 0] out_data[`PORT_COUNT-1: 0];

    bit [`FIFO_WIDTH -1: 0] fifo_data_out [`PORT_COUNT];

    initial begin
        portAstall = 0;
        portBstall = 0;
    end

    assign fifo_dest_addr[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][32:1] :0):0); 
    assign fifo_dest_addr[1] = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][32:1] :0):0); 
    assign fifo_src_addr[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][96:65] :0):0); 
    assign fifo_src_addr[1]  = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][96:65] :0):0); 
    assign fifo_crc_data[0] = (rd_en[0] && ~rd_en[1] ? (~portAstall ? fifo_data_out[0][128:97] :0):0); 
    assign fifo_crc_data[1]  = (rd_en[1] && ~rd_en[0] ? (~portBstall ? fifo_data_out[1][128:97] :0):0); 


    eth_rx_fsm inst_eth_rx_fsm_A
        (
            .clk(clk),
            .rstn(rstn),
            .indata(indataA),
            .insop(insopA),
            .ineop(ineopA),
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
            .full(fifo_full_out[0])

        );

    eth_rx_fsm inst_eth_rx_fsm_B
        (
            .clk(clk),
            .rstn(rstn),
            .indata(indataB),
            .insop(insopB),
            .ineop(ineopB),
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
            .full(fifo_full_out[1])

        );


        always @(posedge clk)
        begin
            if(~rstn)
            begin
                outdataA <= 0;
                outsopA <= 0;
                outeopA <= 0;
                portAstall <= 0;
            end
            else
            begin
                if(rd_en[0] && ~rd_en[1]) // application wants to transmit from portA fifo 
                begin 
                    if(~portAstall)
                    begin
                        if(~fifo_empty_out[0])
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
                                $display("SW_DEBUG TOP: Incorrect CRC address received at Input Port A, PKT Corrupted \n");
                            end
                        end
                        else
                        begin
                            $display("SW_DEBUG TOP: Port A FIFO is empty, Cannot read \n");
                        end
                    end
                    else
                    begin
                        $display("SW_DEBUG TOP: Port A stall signal asserted, FIFO will not be read \n");
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
                portBstall <= 0;
            end
            else
            begin
                if(rd_en[1] && ~rd_en[0]) 
                begin 
                    if(~portBstall)
                    begin
                        if(~fifo_empty_out[1])
                        begin
                            if(fifo_crc_data[1] == `CRC_DATA)
                            begin
                                if(fifo_dest_addr[1] == `PORT_A_ADDR)
                                begin
                                    outdataA <= fifo_data_out[1][64:33];
                                    outsopA <= fifo_data_out[1][0];
                                    outeopA <= fifo_data_out[1][129];
                                    $display("SW_DEBUG TOP: Data from Port B read and transmitted to output portA \n");
                                end
                                else if(fifo_dest_addr[1] == `PORT_B_ADDR)
                                begin
                                    outdataB <= fifo_data_out[1][64:33];
                                    outsopB <= fifo_data_out[1][0];
                                    outeopB <= fifo_data_out[1][129];
                                    $display("SW_DEBUG TOP: Data from Port B read and transmitted to output portB \n");
                                end
                                else
                                    $display("SW_DEBUG TOP: Incorrect destination address in the packet \n");
                            end
                            else
                            begin
                                $display("SW_DEBUG TOP: Incorrect CRC address received at Input Port B, PKT Corrupted \n");
                            end
                        end
                        else
                            $display("SW_DEBUG TOP: Port B FIFO is empty, Cannot read \n");
                    end
                    else
                        $display("SW_DEBUG TOP: Port B stall signal asserted, FIFO will not be read \n");
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
