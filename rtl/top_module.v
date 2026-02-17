/******************************************
   Organization Name: SURE ProEd
   
   Engineer Name: Korrapolu Eswar Adithya
   
   Project Name: ram_system_design
   
   Module Name: ram_system_design.v
   
   Description: 
   
   Latency: 
   
   Version:
******************************************/

module top_module 
   (
      // ---------- Input signals ----------
      input             i_clk              ,
      input             i_rst              ,
      input             i_start_system  ,  // control pulse to start the data generation : Like a turn on button
      input             i_stop_system   ,  // control pulse to stop the data generation  : Like a turn off button
      // ---------- Output signals ---------
      output reg [15:0] data_sets_generated,  // counter indicating total data packets being generated
      output reg [15:0] data_sets_matched     // counter indicating correctly receieved data packets
   );
   
   /*
      Our objective:
      
      Generator ------->  RAM -----------> Checker
          ^                ^                 ^
          |                |                 |
          ------------control_unit------------
   */
   
   /*
      DATA GENERATOR:
      - Port list:
         - i_clk        : system clk
         - i_rst        : data generated in the generator resets to 0
         - i_start      : whenever start pulse is recieved, generator starts 
                          generating data from the previous stop value (or 0 for first iteration)
                          -- once start pulse is recieved; data generation starts
         - o_data_valid : indicates valid data generated from the generator
         - o_data [31:0]: generated data from the generator
   */
   
   /*
      DATA CHECKER:
         - We require a generator (Let's reuse the data generator)
           It's Latency is 1 clk, so the refernce data is received from 
           generator in next clk
         - Pipeline the recieved data with the generated data
         - Compare the two data streams and increment the error_data_cntr
           on every mismatch
         - At the end of frame if error_data_cntr == 0; packet received is valid

         - How do we detect end of frame ?
           - One way is to use a control counter similar to generator
           - Use a falling edge detector on the data valid signal

   */
    /*
        RAM Instantiation (we will get it thorugh the IP Catalog)
        blk_mem_gen_0 your_instance_name (
            .clka(clka),    // input wire clka
            .ena(ena),      // input wire ena
            .wea(wea),      // input wire [3 : 0] wea
            .addra(addra),  // input wire [5 : 0] addra
            .dina(dina),    // input wire [31 : 0] dina
            .douta(douta)  // output wire [31 : 0] douta
                    );
    */
   
    /*
        COntrol Unit:
        - Control unit becomes active, when it receives i_start_system pulse
            - once it gets the start system pulse, it should send start stimulas
            - along with this it should drive write address to the RAM (wr address with wea=0xf)
            - After 64 addresses generation it should it should stop generating the write address

            - Next it should start - read operation
            - It should send a stimulas to the checker
            - It should send a stimulas to the RAM (Send read address with wea=0)

            - To know that write/read is over: the control unit should run a counter
            - The counter should count in the range? 0-63 (i.e., Counting Data transmitted)
        
        - To Control thr process of write to and read from RAM
        - Control unit's role would be to handle wea signal
            - Control unit should send 4'b1111 when we perform write operation
            - Control unit should send 4'b0000 when we perform read operation
            
    */
     data_generator data_generator_inst
            (
                   .i_clk(i_clk)       ,
                   .i_rst(i_rst)       ,
                   .i_start(i_start)   ,
                   .o_data_valid(ref_data_valid)      , 
                   .o_data(ref_data)               
            );



    blk_mem_gen_0 your_instance_name (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [3 : 0] wea
  .addra(addra),  // input wire [5 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(douta)  // output wire [31 : 0] douta
    );

endmodule