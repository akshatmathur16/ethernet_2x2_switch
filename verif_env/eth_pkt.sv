`include "defines.svh"
class eth_pkt;
   // import define::*;
    randc bit [`DATA_WIDTH -1: 0] src_addr;
    randc bit [`DATA_WIDTH -1: 0] dest_addr;
    rand bit [`DATA_WIDTH -1: 0] pkt_data;
    rand bit [`DATA_WIDTH -1: 0] crc_data;
    randc bit rd_en[`PORT_COUNT];
    rand bit sop;
    rand bit eop;
    
    constraint c1
    {
        src_addr inside {`IP_PORT_A_ADDR, `IP_PORT_B_ADDR};
        src_addr dist {`IP_PORT_A_ADDR:/6, `IP_PORT_B_ADDR:/4};
        dest_addr inside {`PORT_A_ADDR, `PORT_B_ADDR};
        dest_addr dist {`PORT_A_ADDR:/6, `PORT_B_ADDR:/4};
        rd_en[0] != rd_en[1];
        rd_en[0] dist {1:/6, 0:/4};
        rd_en[1] dist {0:/6, 1:/4};
        sop == 1'b1;
        eop == 1'b1;
    };


    function new ();
    endfunction


    function bit [`DATA_WIDTH -1: 0] compute_crc();

        return `CRC_DATA;  // hardcoding for now 

    endfunction

    function void post_randomize();
        // fill packet here, since i have fixed size packet, so no queue or Dyn
        // array is implemented
        crc_data = compute_crc();

    endfunction

    function string to_string();
        string msg; 
        // the following statment will convert the data into string format to be
        // used later
        
        msg = $psprintf("crc_data = %h, src_addr = %h, pkt_data = %h, dest_addr = %h, rd_en = %p \n",crc_data, src_addr, pkt_data, dest_addr,rd_en);
    endfunction

    //will be useful when Scoreboard is implemented
    function bit compare_pkt(eth_pkt pkt);
        if(pkt.crc_data == this.crc_data &&
           pkt.src_addr == this.src_addr &&
           pkt.dest_addr == this.dest_addr && 
           is_data_match(pkt.pkt_data, this.pkt_data) // need not implement a separate funciton for data compare, it has been done here to maintain a generic format
          )
          begin
              return 1;
          end
          else
              return 0;
    endfunction

    function bit is_data_match(bit [`DATA_WIDTH -1: 0] data1, bit [`DATA_WIDTH -1: 0] data2);
        if(data1 == data2)
            return 1;
        else
            return 0;
    endfunction


endclass
