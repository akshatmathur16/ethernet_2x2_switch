`include "defines.svh"

module eth_test_top();
    bit clk = 0;
    bit rstn = 0;

    eth_if vif(clk, rstn);

    //DUT instance
    eth_sw_top i_eth_sw_top
       (
           .clk(vif.clk),
           .rstn(vif.rstn),
           .indataA(vif.indataA),
           .insopA(vif.insopA),
           .ineopA(vif.ineopA),
           .indataB(vif.indataB),
           .insopB(vif.insopB),
           .ineopB(vif.ineopB),
           .rd_en(vif.rd_en),
           .outdataA(vif.outdataA),
           .outsopA(vif.outsopA),
           .outeopA(vif.outeopA),
           .outdataB(vif.outdataB),
           .outsopB(vif.outsopB),
           .outeopB(vif.outeopB),
           .portAstall_full(vif.portAstall_full),
           .portBstall_full(vif.portBstall_full),
           .portAstall_empty(vif.portAstall_empty),
           .portBstall_empty(vif.portBstall_empty),
       );

       eth_test test(vif);

       initial begin
           forever
               #5 clk =~clk;
       end

       initial begin
           rstn =0;
           #12 rstn =1;
       end

endmodule
