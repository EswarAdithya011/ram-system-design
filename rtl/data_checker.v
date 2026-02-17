/******************************************
   Organization Name: SURE ProEd
   
   Engineer Name: Korrapolu Eswar Adithya
   
   Project Name: ram_system_design
   
   Module Name: ram_system_design.v
   
   Description: 
   
   Latency: 1 clks
   
   Version:
******************************************/

module data_checker (
   // ---------- Input signals ----------
   input             i_clk              ,
   input             i_rst              ,
   input             i_start            ,  // control signal to start the data generation
   input             i_data_valid       ,  // Indicates valid data received from RAM
   input      [31:0] i_data             ,  // data to be checked
   // ---------- Output signals ---------
   output            o_checking_done    ,  // Pulse indicating checking is done
   output            o_valid_frame        //  Pulse indicating correct frame received
   );

  /*
      Working of Checker
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

   // Declaring Reference generated data signals
   reg        ref_data_valid;
   reg [31:0] ref_data;

   // Declaring counter to check the no. of errors
   reg [6:0]  error_data_cntr;

   // Declaring Register to store delayed version of data generated
   reg        reg_data_valid_d;

   // Declaring to indicate the end of the frame
   wire       end_of_frame;

   // Declaring to store the delayed version of the data generated
   reg [31:0] data_d;
   reg        data_valid_d;

   // Declaring to show whether the data received is correct or not
   reg        frame_valid;
   reg        checking_done;

   data_generator data_generator_for_checker
   (
                   i_clk(i_clk)       ,
                   i_rst(i_rst)       ,
                   i_start(i_start)   ,
                   o_data_valid(ref_data_valid)      , 
                   o_data(ref_data)               
   );

   // Comparing the received data from the delayed RAM version with the data generated
      always @(posedge i_clk) begin
         if (i_rst)  begin
            error_data_cntr <= 7'b0;
         end
         else begin
            if (i_start)
               error_data_cntr <= 7'b0;
               
            else if (ref_data_valid && data_d != ref_data)  begin
               error_data_cntr <= error_data_cntr + 7'b1;
            end
         end
      end

   // Falling Edge Detection
      assign end_of_frame = (~ref_data_valid & reg_data_valid_d);

   // Taking decision on whether received frame is correct or not
      always @(posedge i_clk) begin
         if (end_of_frame && error_data_cntr == 7'b0)
            frame_valid <= 1'b1;
         else
            frame_valid <= 1'b0;
      end

      assign o_valid_frame   = frame_valid;
      assign o_checking_done = checking_done;

   /* Delay Unit
         1. Delaying the received data from the RAM to match the latency of the data generated
            from the generator
         2. Falling Edge Detection */
      always@ (posedge i_clk)   begin
         data_d           <= i_data;
         data_valid_d     <= i_data_valid;
         reg_data_valid_d <= ref_data_valid;
         checking_done    <= end_of_frame;
      end

endmodule