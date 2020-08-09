`include "defines.svh"
`define MON vif.MONITOR.monitor_cb

class eth_monitor;

    virtual eth_if vif;
    mailbox mon2scb[4];
    int num_txn_ip_A;
    int num_txn_ip_B;
    int num_txn_op_A;
    int num_txn_op_B;

    function new(virtual eth_if vif, mailbox mon2scb[4]);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        fork
            parse_ip_A_pkt();
            parse_ip_B_pkt();
            parse_op_A_pkt();
            parse_op_B_pkt();
        join
    endtask

    task parse_ip_A_pkt();
        eth_pkt pkt;
        pkt = new();

        forever @(posedge vif.clk) 
        begin
            @(posedge `MON.insopA)
            begin
                $display($time, "eth_monitor: Pkt sop detected at Input port A");
                pkt.sop = `MON.insopA;
                pkt.eop = `MON.ineopA;
                pkt.rd_en[0] = `MON.rd_en[0];
                pkt.rd_en[1] = `MON.rd_en[1];
                @(posedge vif.clk); 
                pkt.dest_addr = `MON.indataA;
                @(posedge vif.clk); 
                pkt.src_addr = `MON.indataA;
                @(posedge vif.clk); 
                pkt.pkt_addr = `MON.indataA;
                @(posedge vif.clk); 

                mon2scb[0].put(pkt);
                ip_pkt_display(pkt);
                num_txn_ip_A++;
                  
                $display($time, "eth_monitor: packet = %d put in Input A mailbox", num_txn_ip_A);
            end
        end
    endtask

    task parse_ip_B_pkt();
        eth_pkt pkt;
        pkt = new();

        forever @(posedge vif.clk) 
        begin
            @(posedge `MON.insopB)
            begin
                $display($time, "eth_monitor: Pkt sop detected at Input port B");
                pkt.sop = `MON.insopB;
                pkt.eop = `MON.ineopB;
                pkt.rd_en[0] = `MON.rd_en[0];
                pkt.rd_en[1] = `MON.rd_en[1];
                @(posedge vif.clk); 
                pkt.dest_addr = `MON.indataB;
                @(posedge vif.clk); 
                pkt.src_addr = `MON.indataB;
                @(posedge vif.clk); 
                pkt.pkt_addr = `MON.indataB;
                @(posedge vif.clk); 

                mon2scb[1].put(pkt);
                ip_pkt_display(pkt);
                num_txn_ip_B++;
                  
                $display($time, "eth_monitor: packet = %d put in Input B mailbox", num_txn_ip_B);
            end
        end
    endtask

    task parse_op_A_pkt();
        eth_pkt pkt;
        pkt = new();

        forever @(posedge vif.clk) 
        begin
            @(posedge `MON.outsopA)
            begin
                $display($time, "eth_monitor: Pkt sop detected at Output port A");
                pkt.sop = `MON.outsopA;
                pkt.eop = `MON.outeopA;
                pkt.rd_en[0] = `MON.rd_en[0];
                pkt.rd_en[1] = `MON.rd_en[1];
                @(posedge vif.clk); 
                pkt.dest_addr = `MON.outdataA;
                @(posedge vif.clk); 
                pkt.src_addr = `MON.outdataA;
                @(posedge vif.clk); 
                pkt.pkt_addr = `MON.outdataA;
                @(posedge vif.clk); 

                mon2scb[2].put(pkt);
                op_pkt_display(pkt);
                num_txn_op_A++;

                $display($time, "eth_monitor: packet = %d put in Output A mailbox", num_txn_op_A);
            end
        end
    endtask

    task parse_op_B_pkt();
        eth_pkt pkt;
        pkt = new();

        forever @(posedge vif.clk) 
        begin
            @(posedge `MON.outsopB)
            begin
                $display($time, "eth_monitor: Pkt sop detected at Output port B");
                pkt.sop = `MON.outsopB;
                pkt.eop = `MON.outeopB;
                pkt.rd_en[0] = `MON.rd_en[0];
                pkt.rd_en[1] = `MON.rd_en[1];
                @(posedge vif.clk); 
                pkt.dest_addr = `MON.outdataB;
                @(posedge vif.clk); 
                pkt.src_addr = `MON.outdataB;
                @(posedge vif.clk); 
                pkt.pkt_addr = `MON.outdataB;
                @(posedge vif.clk); 

                mon2scb[3].put(pkt);
                op_pkt_display(pkt);
                num_txn_op_B++;

                $display($time, "eth_monitor: packet = %d put in Output B mailbox", num_txn_op_B);
            end
        end
    endtask
    task parse_op_A_pkt();
        eth_pkt pkt;
        pkt = new();

        forever @(posedge vif.clk) 
        begin
            @(posedge `MON.outsopA)
            begin
                $display($time, "eth_monitor: Pkt sop detected at Output port A");
                pkt.sop = `MON.outsopB;
                pkt.eop = `MON.outeopB;
                pkt.rd_en[0] = `MON.rd_en[0];
                pkt.rd_en[1] = `MON.rd_en[1];
                @(posedge vif.clk); 
                pkt.dest_addr = `MON.outdataA;
                @(posedge vif.clk); 
                pkt.src_addr = `MON.outdataA;
                @(posedge vif.clk); 
                pkt.pkt_addr = `MON.outdataA;
                @(posedge vif.clk); 

                mon2scb[2].put(pkt);
                op_pkt_display(pkt);
                num_txn_op_A++;

                $display($time, "eth_monitor: packet = %d put in Output A mailbox", num_txn_op_A);
            end
        end
    endtask
    function void ip_pkt_display(eth_pkt pkt);
        $display($time, "eth_monitor: ip_pkt_display: Packet at pkt.src_addr = %h \t pkt.sop = %h, pkt.eop = %h, pkt.dest_addr = %h, pkt.rd_en[0] = %h, pkt.rd_en[1] = %h, pkt.pkt_data = %h", pkt.src_addr, pkt.sop, pkt.eop, pkt.dest_addr, pkt.rd_en[0], pkt.rd_en[1], pkt.pkt_data);
    endfunction

    function void op_pkt_display(eth_pkt pkt);
        $display($time, "eth_monitor: op_pkt_display: Packet at pkt.sop = %h, pkt.eop = %h, pkt.rd_en[0] = %h, pkt.rd_en[1] = %h, pkt.pkt_data = %h",pkt.sop, pkt.eop, pkt.rd_en[0], pkt.rd_en[1], pkt.pkt_data);
    endfunction


endclass
