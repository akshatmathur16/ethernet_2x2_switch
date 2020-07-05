`include "defines.svh"

//typedef eth_pkt;

class eth_pkt_gen;

   // the generated packet will be kept in the mailbox and will be fetched by
   // the driver 
   mailbox gen2drv;
   int num_pkts;
   event ended;

   function new(mailbox gen2drv, event ended);
       this.gen2drv = gen2drv;
       this.ended = ended;
   endfunction

   task run();
       eth_pkt pkt;
       $display("eth_pkt_gen: %d packets to be transferred to drive \n",num_pkts);

       repeat(num_pkts)
       begin
           pkt = new();

           if(!pkt.randomize())
               $fatal("eth_pkt_gen: %t Randomization failiure \n",$time);
           gen2drv.put(pkt);
           $display("eth_pkt_gen: %t GEN-MAILBOX Packet put in gen2drv mailbox \n",$time);
       end
       ->ended;
   endtask

endclass
