`include "defines.svh"

program eth_test(eth_if vif);
    import eth_pkg::*;

    eth_environment env;

    initial begin
        env = new(vif);
        env.gen.num_pkts = 10;
        env.run();
    end

endprogram
