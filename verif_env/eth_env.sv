`include "defines.svh"


class eth_environment;
    virtual eth_if vif;
    mailbox gen2drv;
    event gen_ended;
    eth_drvr drcv;
    eth_pkt_gen gen;
    eth_monitor mon;
    mailbox mon2scb[4];

    function new(virtual eth_if vif);
        gen2drv = new();
        for(int i =0; i<4; i++)
            mon2scb[i] = new();
        drv = new(vif, gen2drv);
        gen = new(gen2drv, gen_ended);
        mon = new(vif, mon2scb);
    endfunction

    task pre_test();
        drv.reset();
    endtask

    task test();
        fork
            gen.run();
            drv.run();
            mon.run();
        join_any
    endtask

    task post_test();
        wait(gen_ended.triggered);
        wait(gen.num_pkts == (drv.num_txnA + drv.num_txnB));
        // wait(mon.num_txn_ip_A + mon.num_txn_ip_B == mon.num_txn_op_A + mon.num_txn_op_B);
    endtask

    task run();
        pre_test();
        test();
        post_test();
        $finish;
    endtask

endclass
