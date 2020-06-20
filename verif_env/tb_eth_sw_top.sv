`include "defines.svh"
module tb_eth_sw_top();

        bit clk =0;
        bit rstn;
        bit [`DATA_WIDTH -1:0] indataA;
        bit insopA;
        bit ineopA;
        bit [`DATA_WIDTH -1: 0] indataB;
        bit insopB;
        bit ineopB;
        logic rd_en[`PORT_COUNT];
        bit [`DATA_WIDTH -1: 0] outdataA;
        bit outsopA;
        bit outeopA;
        bit [`DATA_WIDTH -1: 0] outdataB;
        bit outsopB;
        bit outeopB;
        bit portAstall, portBstall;

        parameter DELAY1 = 10;
        parameter DELAY2 = 30;


        // TOP module instantiation
        eth_sw_top inst_eth_sw_top
           (
               .clk(clk),
               .rstn(rstn),
               .indataA(indataA),
               .insopA(insopA),
               .ineopA(ineopA),
               .indataB(indataB),
               .insopB(insopB),
               .ineopB(ineopB),
               .rd_en(rd_en),
               .outdataA(outdataA),
               .outsopA(outsopA),
               .outeopA(outeopA),
               .outdataB(outdataB),
               .outsopB(outsopB),
               .outeopB(outeopB),
               .portAstall(portAstall),
               .portBstall(portBstall) 
           );

           initial begin
               #4 rstn = 1; rd_en[0] =0; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF);
            
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF);
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF); 
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF);indataB = $urandom_range(32'h0000, 32'hFFFF); 
               #DELAY2 rstn = 1; rd_en[0] =1; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF);
               
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF);  indataB = $urandom_range(32'h0000, 32'hFFFF);

               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF);indataB = $urandom_range(32'h0000, 32'hFFFF); 
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF); 
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF);  indataB = $urandom_range(32'h0000, 32'hFFFF);
               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF);indataB = $urandom_range(32'h0000, 32'hFFFF); 

               #DELAY2 rstn = 1; rd_en[0] =0; rd_en[1]=1;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF); 

               #DELAY2 rd_en[0] =1;
               #DELAY1 rd_en[0] =1;
               #DELAY1 rd_en[1] =1;
               #DELAY1 rd_en[1] =1;
               #DELAY1 rd_en[1] =1;
               #DELAY1 rd_en[1] =1;
              
               #DELAY2 rstn = 0; rd_en[0] =0; rd_en[1]=0;insopA =1; ineopA = 1;  insopB =1; ineopB = 1;
               randcase
                  1:indataA = 32'hABCD;
                  1:indataA = 32'hEFEF;
               endcase
               randcase
                  1:indataB = 32'hABCD;
                  1:indataB = 32'hEFEF;
               endcase
               #DELAY1 indataA = $urandom_range(32'h0000, 32'hFFFF); indataB = $urandom_range(32'h0000, 32'hFFFF); 

          #100 $stop;

           end 
           initial begin
               $monitor("%t:clk=%d, rstn=%d, indataA, insopA=%h, ineopA=%h, indataB=%h, insopB=%h, ineopB=%h, rd_en[0]=%h, rd_en[1]=%h, outdataA=%h, outsopA=%h, outeopA=%h, outdataB=%h, outsopB=%h, outeopB=%h, portAstall=%h, portBstall=%h \n", $time,clk, rstn, indataA, insopA, ineopA, indataB, insopB, ineopB, rd_en[0], rd_en[1], outdataA, outsopA, outeopA, outdataB, outsopB, outeopB, portAstall, portBstall );
           end


  

           //clock generator 
           initial begin
               forever #5 clk = ~clk;
           end
    

endmodule
