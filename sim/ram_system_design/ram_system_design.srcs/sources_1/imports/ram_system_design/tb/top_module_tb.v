/******************************************
   Organization Name: SURE ProEd
   
   Engineer Name: Korrapolu Eswar Adithya
   
   Project Name: ram_system_design
   
   Module Name: top_module_tb
   
   Description:
   
   Latency:
   
   Version:
******************************************/

`timescale 1ns/1ps   // This means, your time unit is in ns (10^-9)
                     // 1ps means, precison is in ps (10^-12)
                     // Your time scaling would be from 1.000ns

module top_module_tb ();

   localparam tclk = 10;  // Not specifying unit of time
   
   reg              i_clk              ;
   reg              i_rst              ;
   reg              i_start_system;  // control pulse to start the data generation : Like a turn on button
   reg              i_stop_system; // control pulse to stop the data generation  : Like a turn off button
   reg              i_error_en;      // control to toggle error injection
      // ---------- Output signals ---------
   wire [31:0] data_sets_generated;  // counter indicating total data packets being generated
   wire [31:0] data_sets_matched;
   
   
   top_module top_module_inst
   (
      .i_clk(i_clk)              ,
      .i_rst(i_rst)              ,
      .i_start_system(i_start_system)  ,  
      .i_stop_system(i_stop_system)   , 
      .i_error_en(i_error_en)         , 
      .data_sets_generated(data_sets_generated),  
      .data_sets_matched(data_sets_matched)  
   );
   
   // initilization of signals
   initial begin
      // we initialize the signals 
      // for time instant = 0
      i_clk          <= 1'b1;
      i_rst          <= 1'b1;
      i_start_system <= 1'b0;
      i_stop_system  <= 1'b0;
      i_error_en     <= 1'b0;
   end
   
   
   // Clock generation
   always #(tclk/2) i_clk <= ~i_clk;
   
   // FRAME-BY-FRAME MANUAL CONTROL
   initial begin
      // 1. Reset the System
      @(posedge i_clk);
      @(posedge i_clk);
      i_rst <= 0; 
      @(posedge i_clk);
      @(posedge i_clk);
      
      $display("------------------------------------------------");
      $display("Starting Frame-by-Frame Error Injection Test");
      $display("------------------------------------------------");

      // FRAME 1: ERROR ON (Should NOT match)
      // ==========================================
      $display("Starting Frame 1 (Error ON)...");
      
      // Pulse Start for 2 Clocks to ensure internal flags clear
      @(posedge i_clk) i_start_system = 1'b1;
      @(posedge i_clk); // Hold for extra clock
      
      // Release Start, Pulse Stop to prevent auto-looping
      @(posedge i_clk) begin
          i_start_system = 1'b0;
          i_stop_system = 1'b1;
      end
      @(posedge i_clk) i_stop_system = 1'b0;
      
      // Wait for Frame 1 to finish
      wait(data_sets_generated == 32'd1);
      $display("Frame 1 Complete! Matches so far: %d", data_sets_matched);
      $display("------------------------------------------------");
      
      // Rest between frames
      #100; 

      // FRAME 2: ERROR OFF (Should Match)
      i_error_en = 1'b0; // Turn Error OFF
      $display("Starting Frame 2 (Error OFF)...");
      
      // Pulse Start for 2 Clocks
      @(posedge i_clk) i_start_system = 1'b1;
      @(posedge i_clk);
      
      // Release Start, Pulse Stop
      @(posedge i_clk) begin
          i_start_system = 1'b0;
          i_stop_system = 1'b1;
      end
      @(posedge i_clk) i_stop_system = 1'b0;
      
      // Wait for Frame 2 to finish
      wait(data_sets_generated == 32'd2);
      $display("Frame 2 Complete! Matches so far: %d", data_sets_matched);
      $display("------------------------------------------------");
      
      // Rest between frames
      #100;

      // FRAME 3: ERROR ON (Should NOT match)
      i_error_en = 1'b1; // Turn Error ON again
      $display("Starting Frame 3 (Error ON)...");
      
      // Pulse Start for 2 Clocks
      @(posedge i_clk) i_start_system = 1'b1;
      @(posedge i_clk);
      
      // Release Start, Pulse Stop
      @(posedge i_clk) begin
          i_start_system = 1'b0;
          i_stop_system = 1'b1;
      end
      @(posedge i_clk) i_stop_system = 1'b0;
      
      // Wait for Frame 3 to finish
      wait(data_sets_generated == 32'd3);
      $display("Frame 3 Complete! Matches so far: %d", data_sets_matched);
      $display("------------------------------------------------");
      
      
      // Final
      #100;
      $display("FINAL RESULTS:");
      $display("Total Data Sets Generated: %d", data_sets_generated);
      $display("Total Data Sets Matched:   %d (Expected 1)", data_sets_matched);
      $display("------------------------------------------------");
      
      $finish;
   end
   
endmodule