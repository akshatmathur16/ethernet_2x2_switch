`include "defines.svh"

interface eth_if(input clk, rst);
    logic [`DATA_WIDTH -1:0] indataA;
    logic insopA;
    logic ineopA;
    logic [`DATA_WIDTH -1:0] indataB;
    logic insopB;
    logic ineopB;
    logic rd_en[`PORT_COUNT];
    logic [`DATA_WIDTH -1:0] outdataA;
    logic outsopA;
    logic outeopA;
    logic [`DATA_WIDTH -1:0] outdataB;
    logic outsopB;
    logic outeopB;
    logic portAstall_full;
    logic portBstall_full;
    logic portAstall_empty;
    logic portBstall_empty;


    clocking driver_cb @(posedge clk);
        output indataA;
        output insopA;
        output ineopA;
        output indataB;
        output insopB;
        output ineopB;
        output rd_en;
        input outdataA;
        input outsopA;
        input outeopA;
        input outdataB;
        input outsopB;
        input outeopB;
        input portAstall_full;
        input portBstall_full;
        input portAstall_empty;
        input portBstall_empty;
    endclocking

    clocking monitor_cb @(posedge clk);
        input indataA;
        input insopA;
        input ineopA;
        input indataB;
        input insopB;
        input ineopB;
        input rd_en;
        input outdataA;
        input outsopA;
        input outeopA;
        input outdataB;
        input outsopB;
        input outeopB;
        input portAstall_full;
        input portBstall_full;
        input portAstall_empty;
        input portBstall_empty;
    endclocking

    modport DRIVER (clocking driver_cb, clk, rst);
    modport MONITOR (clocking montor_cb, clk, rst);

endinterface
