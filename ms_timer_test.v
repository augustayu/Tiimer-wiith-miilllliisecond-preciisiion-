`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:55:11 12/04/2014
// Design Name:   ms_timer
// Module Name:   E:/ISE/xilinx/ISEProgramm/ms_timer/ms_timer_test.v
// Project Name:  ms_timer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ms_timer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ms_timer_test;

	// Inputs
	reg clk;
	reg inc;
	reg switch;
	reg rst;

	// Outputs
	wire [7:0] num;
	wire [3:0] loc;

	// Instantiate the Unit Under Test (UUT)
	ms_timer uut (
		.clk(clk), 
		.inc(inc), 
		.switch(switch), 
		.rst(rst), 
		.num(num), 
		.loc(loc)
	);
   initial forever #50  clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		inc = 0;
		switch = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#50; // 测试start
		switch = 1;
      
		#10000// 一段时间后测试stop
		switch = 0;
		
		//stop下测试inc
		# 400
		inc = 1;
		
		# 300
		inc = 1;
		
		#100
		inc = 0;
		// 测试复位
		#600
	   rst  = 1;
		
		#300
		rst = 0;
		// 恢复start
		#1000
		switch = 1;
		
		#4000
		rst = 1;
		
		#1000
		rst = 0;
	end
      
endmodule

