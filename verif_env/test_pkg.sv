
package define;
    `include "defines.svh"
endpackage

package eth_pkg;
    `include "eth_pkt.sv"
    `include "eth_pkt_gen.sv"
    `include "eth_drvr.sv"
    `include "eth_monitor.sv"
    `include "eth_env.sv"
endpackage

`include "eth_interface.sv"
`include "eth_test.sv"
`include "eth_test_top.sv"

`include "eth_rx_fsm.sv"
`include "eth_port_fifo.sv"
`include "eth_sw_top.sv"
