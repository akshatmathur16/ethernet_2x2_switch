`include "defines.svh"
`define DRV vif.DRIVER.driver_cb

class eth_drvr;

    virtual eth_if vif;
    mailbox gen2drv;
    int num_txnA;
    int num_txnB;

    function new(virtual eth_if vif, mailbox gen2drv);
        this.vif = vif;
        this.mailbox = gen2drv;
    endfunction

    task reset();
        @(posedge vif.clk);
        wait(!vif.rst);
        $display($time,"eth_drvr: Reset asserted");
        `DRV.indataA <= 'b0;
        `DRV.insopA <= 'b0;
        `DRV.ineopA <= 'b0;
        `DRV.indataB <= 'b0;
        `DRV.insopB <= 'b0;
        `DRV.ineopB <= 'b0;
        `DRV.rd_en[0] <= 'b0;
        `DRV.rd_en[1] <= 'b0;

        wait(vif.rst);
        $display($time,"eth_drvr: Reset deasserted");
    endtask

    task run();
        eth_pkt pkt;

        forever @(posedge vif.clk)
        begin
            gen2drv.get(pkt);
            $display($time,"eth_drvr: GEN-DRV packet transfer complete");

            if(pkt.src_addr == `IP_PORT_A_ADDR)
                portAdrive(pkt);
            else if (pkt.src_addr == `IP_PORT_B_ADDR)
                portBdrive(pkt);
            else
                $display($time,"Driver: Incorrect source address");
        end
    endtask

    task portAdrive(eth_pkt pkt);

        if(~`DRV.portAstall_full)
        begin
            $display($time,"eth_drvr: Driving on DUT's PortA");
            `DRV.insopA <= pkt.sop;
            `DRV.ineopA <= pkt.eop;
            `DRV.rd_en[0] <= pkt.rd_en[0];
            `DRV.rd_en[1] <= 'b0; 
            @(posedge vif.clk);
            `DRV.indataA <= pkt.dest_addr;
            @(posedge vif.clk);
            `DRV.indataA <= pkt.src_addr;
            @(posedge vif.clk);
            `DRV.indataA <= pkt.pkt_data;
            @(posedge vif.clk);
            `DRV.insopA <= 'b0;
            `DRV.ineopA <= 'b0; 
            
            //NOTE: no need to drive crc since its hardcoded in the RTL
            pkt.to_string();
            num_txnA++;
            $display($time,"eth_drvr: Number of transactions to PortA = %d", num_txnA);
            @(posedge vif.clk);
        end
        else
            $display($time,"eth_drvr: PortAstall_full asserted caanot drive pkt");
    endtask

    task portBdrive(eth_pkt pkt);

        if(~`DRV.portBstall_full)
        begin
            $display($time,"eth_drvr: Driving on DUT's Port B");
            `DRV.insopB <= pkt.sop;
            `DRV.ineopB <= pkt.eop;
            `DRV.rd_en[1] <= pkt.rd_en[1];
            `DRV.rd_en[1] <= 'b0; 
            @(posedge vif.clk);
            `DRV.indataB <= pkt.dest_addr;
            @(posedge vif.clk);
            `DRV.indataB <= pkt.src_addr;
            @(posedge vif.clk);
            `DRV.indataB <= pkt.pkt_addr;
            @(posedge vif.clk);
            `DRV.insopB <= 'b0;
            `DRV.ineopB <= 'b0;
            //NOTE: no need to drive crc since its hardcoded in RTL
            pkt.to_string(); // to display pkt contents
            num_txnB++;
            $display($time,"eth_drvr: Number of transactions to PortB = %d",num_txnB);
            @(posedge vif.clk);
        end
        else
            $display($time,"eth_drvr: PortBstall_full asserted cannot drive pkt");
    endtask

endclass
