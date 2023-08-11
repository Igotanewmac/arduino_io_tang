





module arduino_io (
    // arduino connections
    input wire sysclk,
    input wire [7:0] arduino_datain,
    output reg [7:0] arduino_dataout,
    input wire [1:0] arduino_databank,
    input wire arduino_readwrite,
    input wire arduino_clock,
    input wire arduino_reset,
    


    // internal ram connections
    // src
    input wire [7:0] mem_src_dout,
    output reg mem_src_clk,
    output reg mem_src_oce,
    output reg mem_src_ce,
    output reg mem_src_reset,
    output reg mem_src_wre,
    output reg [13:0] mem_src_ad,
    output reg [7:0] mem_src_din,
    // key
    input wire [7:0] mem_key_dout,
    output reg mem_key_clk,
    output reg mem_key_oce,
    output reg mem_key_ce,
    output reg mem_key_reset,
    output reg mem_key_wre,
    output reg [13:0] mem_key_ad,
    output reg [7:0] mem_key_din,
    // cmd
    input wire [7:0] mem_cmd_dout,
    output reg mem_cmd_clk,
    output reg mem_cmd_oce,
    output reg mem_cmd_ce,
    output reg mem_cmd_reset,
    output reg mem_cmd_wre,
    output reg [13:0] mem_cmd_ad,
    output reg [7:0] mem_cmd_din,
    // dst
    input wire [7:0] mem_dst_dout,
    output reg mem_dst_clk,
    output reg mem_dst_oce,
    output reg mem_dst_ce,
    output reg mem_dst_reset,
    output reg mem_dst_wre,
    output reg [13:0] mem_dst_ad,
    output reg [7:0] mem_dst_din
    
);




    // registers

    // address registers
    reg [13:0] addressregister_src;
    reg [13:0] addressregister_key;
    reg [13:0] addressregister_cmd;
    reg [13:0] addressregister_dst;

    // arduino clock state machine
    reg [7:0] statemachine_arduino_clock;

    // memory access state machine
    reg [7:0] statemachine_memory;
    


    // actual work!
    always @(posedge sysclk) begin
        // lets goo!
        // are we in a reset condition?
        if (arduino_reset) begin
            // in a reset condition!
            addressregister_src <= 14'd0;
            addressregister_key <= 14'd0;
            addressregister_cmd <= 14'd0;
            addressregister_dst <= 14'd0;
            statemachine_arduino_clock <= 8'h00;
            statemachine_memory <= 8'h00;
            mem_src_reset <= 1'b1;
            mem_key_reset <= 1'b1;
            mem_cmd_reset <= 1'b1;
            mem_dst_reset <= 1'b1;
        end
        else begin
            // not in a reset condition, do more!
            mem_src_reset <= 1'b0;
            mem_key_reset <= 1'b0;
            mem_cmd_reset <= 1'b0;
            mem_dst_reset <= 1'b0;
            
            // check if our dataclock line has gone high
            case (statemachine_arduino_clock)
                // wait for the dataclock line to go high
                8'h00 : begin
                    if (arduino_clock) statemachine_arduino_clock <= 8'h01;
                end
                // clock has gone high, so process it
                8'h01 : begin
                    // select our databank and operation
                    case ({arduino_databank[1],arduino_databank[0],arduino_readwrite})

                        // 000 src read
                        3'b000 : begin
                            case (statemachine_memory)
                                
                                // initialise memory
                                8'h00 : begin
                                    mem_src_ad <= addressregister_src;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // read data
                                8'h03 : begin
                                    arduino_dataout <= mem_src_dout;
                                    statemachine_memory <= 8'h04;
                                end

                                // finished
                                8'h04 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    addressregister_src = addressregister_src + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 001 src write
                        3'b001 : begin
                            case (statemachine_memory)
                            // initoalise memory
                                8'h00 : begin
                                    mem_src_ad <= addressregister_src;
                                    mem_src_din <= arduino_datain;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // finished
                                8'h03 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    addressregister_src = addressregister_src + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 010 key read
                        3'b010 : begin
                            case (statemachine_memory)
                                
                                // initialise memory
                                8'h00 : begin
                                    mem_key_ad <= addressregister_key;
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_key_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // read data
                                8'h03 : begin
                                    arduino_dataout <= mem_key_dout;
                                    statemachine_memory <= 8'h04;
                                end

                                // finished
                                8'h04 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    addressregister_key = addressregister_key + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 011 key write
                        3'b011 : begin
                            case (statemachine_memory)
                            // initoalise memory
                                8'h00 : begin
                                    mem_key_ad <= addressregister_key;
                                    mem_key_din <= arduino_datain;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_key_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // finished
                                8'h03 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    addressregister_key = addressregister_key + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 100 cmd read
                        3'b100 : begin
                            case (statemachine_memory)
                                
                                // initialise memory
                                8'h00 : begin
                                    mem_cmd_ad <= addressregister_cmd;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_oce <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // read data
                                8'h03 : begin
                                    arduino_dataout <= mem_cmd_dout;
                                    statemachine_memory <= 8'h04;
                                end

                                // finished
                                8'h04 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_oce <= 1'b0;
                                    addressregister_cmd = addressregister_cmd + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 101 cmd write
                        3'b101 : begin
                            case (statemachine_memory)
                            // initoalise memory
                                8'h00 : begin
                                    mem_cmd_ad <= addressregister_cmd;
                                    mem_cmd_din <= arduino_datain;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // finished
                                8'h03 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    addressregister_cmd = addressregister_cmd + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 110 dst read
                        3'b110 : begin
                            case (statemachine_memory)
                                
                                // initialise memory
                                8'h00 : begin
                                    mem_dst_ad <= addressregister_dst;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_oce <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // read data
                                8'h03 : begin
                                    arduino_dataout <= mem_dst_dout;
                                    statemachine_memory <= 8'h04;
                                end

                                // finished
                                8'h04 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_oce <= 1'b0;
                                    addressregister_dst <= addressregister_dst + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                        // 111 dst write
                        3'b111 : begin
                            case (statemachine_memory)
                            // initoalise memory
                                8'h00 : begin
                                    mem_dst_ad <= addressregister_dst;
                                    mem_dst_din <= arduino_datain;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_memory <= 8'h01;
                                end
                                // clock high
                                8'h01 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_memory <= 8'h02;
                                end
                                // clock low
                                8'h02 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_memory <= 8'h03;
                                end
                                // finished
                                8'h03 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    addressregister_dst = addressregister_dst + 1;
                                    statemachine_memory <= 8'h00;
                                    statemachine_arduino_clock <= 8'h02;
                                end

                            endcase
                        end

                    endcase
                    
                end
                // wait for clock low to reset
                8'h02 : begin
                    if (!arduino_clock) statemachine_arduino_clock <= 8'h00;
                end

            endcase
        end
    end

    

    
endmodule





















module central_processor (
    // sysclk
    input wire sysclk,
    // arduino
    input wire arduino_execute,
    output reg arduino_isfinished,
    input wire arduino_reset,
    // src mem
    input wire [7:0] mem_src_dout,
    output reg mem_src_clk,
    output reg mem_src_oce,
    output reg mem_src_ce,
    output reg mem_src_reset,
    output reg mem_src_wre,
    output reg [13:0] mem_src_ad,
    output reg [7:0] mem_src_din,
    // key mem
    input wire [7:0] mem_key_dout,
    output reg mem_key_clk,
    output reg mem_key_oce,
    output reg mem_key_ce,
    output reg mem_key_reset,
    output reg mem_key_wre,
    output reg [13:0] mem_key_ad,
    output reg [7:0] mem_key_din,
    // cmd mem
    input wire [7:0] mem_cmd_dout,
    output reg mem_cmd_clk,
    output reg mem_cmd_oce,
    output reg mem_cmd_ce,
    output reg mem_cmd_reset,
    output reg mem_cmd_wre,
    output reg [13:0] mem_cmd_ad,
    output reg [7:0] mem_cmd_din,
    // dst mem
    input wire [7:0] mem_dst_dout,
    output reg mem_dst_clk,
    output reg mem_dst_oce,
    output reg mem_dst_ce,
    output reg mem_dst_reset,
    output reg mem_dst_wre,
    output reg [13:0] mem_dst_ad,
    output reg [7:0] mem_dst_din,
    // ram mem
    input wire [7:0] mem_ram_dout,
    output reg mem_ram_clk,
    output reg mem_ram_oce,
    output reg mem_ram_ce,
    output reg mem_ram_reset,
    output reg mem_ram_wre,
    output reg [13:0] mem_ram_ad,
    output reg [7:0] mem_ram_din
);
    


    // registers

    // program counter
    reg [13:0] programcounter;

    // address register
    reg [13:0] addressregisterA;

    // data registers
    reg [7:0] dataregisterA;
    reg [7:0] dataregisterB;
    reg [7:0] dataregisterC;

    // internal buffers
    reg [7:0] commandbuffer;


    // state machines

    // program execution state machine
    reg [7:0] statemachine_program;

    // command execution state machine
    reg [7:0] statemachine_command;




    // command registers

    reg [13:0] reg_int_address;
    reg [7:0]  reg_int_data;


    // special registers
    reg [15:0] reg_lfsr_single;











    // do stuff!
    always @(posedge sysclk) begin
        
        // are we in a reset condition?
        if (arduino_reset) begin
            // reset condition
            programcounter <= 14'd0;
            addressregisterA <= 14'd0;
            dataregisterA <= 8'd0;
            dataregisterB <= 8'd0;
            dataregisterC <= 8'd0;
            commandbuffer <= 8'd0;
            statemachine_program <= 8'd0;
            statemachine_command <= 8'd0;
            arduino_isfinished <= 1'b0;
            mem_src_reset <= 1'b1;
            mem_key_reset <= 1'b1;
            mem_cmd_reset <= 1'b1;
            mem_dst_reset <= 1'b1;
            mem_ram_reset <= 1'b1;
            reg_int_address <= 14'd0;
            reg_int_data <= 8'd0;
        end
        else begin
            // not a reset
            mem_src_reset <= 1'b0;
            mem_key_reset <= 1'b0;
            mem_cmd_reset <= 1'b0;
            mem_dst_reset <= 1'b0;
            mem_ram_reset <= 1'b0;
            // lets run a program!
            case (statemachine_program)

                // initialise and wait for execute
                8'h00 : begin
                    if (arduino_execute) statemachine_program <= 8'h01;
                end

                // load byte from cmd ram at programcounter, into commandbuffer

                // initialise memory
                8'h01 : begin
                    mem_cmd_ad <= programcounter;
                    mem_cmd_ce <= 1'b1;
                    mem_cmd_oce <= 1'b1;
                    arduino_isfinished <= 1'b0;
                    statemachine_program <= 8'h02;
                end

                // clock high
                8'h02 : begin
                    mem_cmd_clk <= 1'b1;
                    statemachine_program <= 8'h03;
                end

                // clock low
                8'h03 : begin
                    mem_cmd_clk <= 1'b0;
                    statemachine_program <= 8'h04;
                end

                // fetch data into command buffer
                8'h04 : begin
                    commandbuffer <= mem_cmd_dout;
                    mem_cmd_ce <= 1'b0;
                    mem_cmd_oce <= 1'b0;
                    statemachine_command <= 8'd0;
                    statemachine_program <= 8'h05;
                end



                // switch on commandbuffer
                8'h05 : begin
                    
                    case (commandbuffer)
                        
                        // 0x00 no-op,
                        8'h00 : begin
                            statemachine_program <= 8'hFE;
                        end

                        // 0x01 program end
                        8'h01 : begin
                            statemachine_program <= 8'hFF;
                        end

                        
                        // 0x02 fill src with byte from src
                        8'h02 : begin
                                
                            case (statemachine_command)
                                // load byte from 0x00 in src
                                // set address and clocks
                                8'h00 : begin
                                    mem_src_ad <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end

                                // set clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                
                                // set clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h03;
                                end
                                
                                // read data
                                8'h03 : begin
                                    reg_int_data <= mem_src_dout;
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                
                                // set address counter to zero
                                8'h04 : begin
                                    reg_int_address <= 14'd0;
                                    statemachine_command <= 8'h05;
                                end

                                // set memory for write
                                8'h05 : begin
                                    mem_src_ad <= reg_int_address;
                                    mem_src_din <= reg_int_data;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // finish
                                8'h08 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // increment address counter
                                8'h09 : begin
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h0A;
                                end
                                // if address counter is zero, jmp
                                8'h0A : begin
                                    if (reg_int_address != 0 ) statemachine_command <= 8'h05;
                                    else statemachine_command <= 8'h0B;
                                end
                                // finish up
                                8'h0B : begin
                                    statemachine_program <= 8'hFE;
                                    
                                end
                                
                            endcase
                        end

                        // 0x03 fill key with byte from src
                        8'h03 : begin
                                
                            case (statemachine_command)
                                // load byte from 0x00 in src
                                // set address and clocks
                                8'h00 : begin
                                    mem_src_ad <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end

                                // set clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                
                                // set clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h03;
                                end
                                
                                // read data
                                8'h03 : begin
                                    reg_int_data <= mem_src_dout;
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                
                                // set address counter to zero
                                8'h04 : begin
                                    reg_int_address <= 14'd0;
                                    statemachine_command <= 8'h05;
                                end

                                // set memory for write
                                8'h05 : begin
                                    mem_key_ad <= reg_int_address;
                                    mem_key_din <= reg_int_data;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_key_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // finish
                                8'h08 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // increment address counter
                                8'h09 : begin
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h0A;
                                end
                                // if address counter is zero, jmp
                                8'h0A : begin
                                    if (reg_int_address != 0 ) statemachine_command <= 8'h05;
                                    else statemachine_command <= 8'h0B;
                                end
                                // finish up
                                8'h0B : begin
                                    statemachine_program <= 8'hFE;
                                    
                                end
                                
                            endcase
                        end

                        // 0x04 fill cmd with byte from src
                        8'h04 : begin
                                
                            case (statemachine_command)
                                // load byte from 0x00 in src
                                // set address and clocks
                                8'h00 : begin
                                    mem_src_ad <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end

                                // set clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                
                                // set clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h03;
                                end
                                
                                // read data
                                8'h03 : begin
                                    reg_int_data <= mem_src_dout;
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                
                                // set address counter to zero
                                8'h04 : begin
                                    reg_int_address <= 14'd0;
                                    statemachine_command <= 8'h05;
                                end

                                // set memory for write
                                8'h05 : begin
                                    mem_cmd_ad <= reg_int_address;
                                    mem_cmd_din <= reg_int_data;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_cmd_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // finish
                                8'h08 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // increment address counter
                                8'h09 : begin
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h0A;
                                end
                                // if address counter is zero, jmp
                                8'h0A : begin
                                    if (reg_int_address != 0 ) statemachine_command <= 8'h05;
                                    else statemachine_command <= 8'h0B;
                                end
                                // finish up
                                8'h0B : begin
                                    statemachine_program <= 8'hFF;
                                    
                                end
                                
                            endcase
                        end

                        // 0x05 fill dst with byte from src
                        8'h05 : begin
                                
                            case (statemachine_command)
                                // load byte from 0x00 in src
                                // set address and clocks
                                8'h00 : begin
                                    mem_src_ad <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end

                                // set clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                
                                // set clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h03;
                                end
                                
                                // read data
                                8'h03 : begin
                                    reg_int_data <= mem_src_dout;
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                
                                // set address counter to zero
                                8'h04 : begin
                                    reg_int_address <= 14'd0;
                                    statemachine_command <= 8'h05;
                                end

                                // set memory for write
                                8'h05 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_dst_din <= reg_int_data;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // finish
                                8'h08 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // increment address counter
                                8'h09 : begin
                                    reg_int_address <= reg_int_address + 1;
                                    statemachine_command <= 8'h0A;
                                end
                                // if address counter is zero, jmp
                                8'h0A : begin
                                    if (reg_int_address != 0 ) statemachine_command <= 8'h05;
                                    else statemachine_command <= 8'h0B;
                                end
                                // finish up
                                8'h0B : begin
                                    statemachine_program <= 8'hFE;
                                    
                                end
                                
                            endcase
                        end

                        // 0x06 fill ram with byte from src
                        8'h06 : begin
                                
                            case (statemachine_command)
                                // load byte from 0x00 in src
                                // set address and clocks
                                8'h00 : begin
                                    mem_src_ad <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end

                                // set clock high
                                8'h01 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                
                                // set clock low
                                8'h02 : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h03;
                                end
                                
                                // read data
                                8'h03 : begin
                                    reg_int_data <= mem_src_dout;
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                
                                // set address counter to zero
                                8'h04 : begin
                                    reg_int_address <= 14'd0;
                                    statemachine_command <= 8'h05;
                                end

                                // set memory for write
                                8'h05 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_ram_din <= reg_int_data;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_wre <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_ram_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // finish
                                8'h08 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_wre <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // increment address counter
                                8'h09 : begin
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h0A;
                                end
                                // if address counter is zero, jmp
                                8'h0A : begin
                                    if (reg_int_address != 0 ) statemachine_command <= 8'h05;
                                    else statemachine_command <= 8'h0B;
                                end
                                // finish up
                                8'h0B : begin
                                    statemachine_program <= 8'hFE;
                                    
                                end
                                
                            endcase
                        end

                        // 0x07 fillall memories with byte from src







                        // 0x08 copy ram to dst
                        8'h08 : begin
                            case (statemachine_command)

                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    reg_int_data <= 8'd0;
                                    statemachine_command <= 8'h01;
                                end

                                // read byte into register
                                // set address
                                8'h01 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_oce <= 1'b1;
                                    statemachine_command <= 8'h02;
                                end
                                // clock high
                                8'h02 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock low
                                8'h03 : begin
                                    mem_ram_clk <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                // fetch data
                                8'h04 : begin
                                    reg_int_data <= mem_ram_dout;
                                    statemachine_command <= 8'h05;
                                end
                                // finish up
                                8'h05 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_oce <= 1'b0;
                                    statemachine_command <= 8'h06;
                                end


                                // write byte to dst
                                // set adress
                                8'h06 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_dst_din <= reg_int_data;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock high
                                8'h07 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h08;
                                end
                                // clock low
                                8'h08 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_command <= 8'h09;
                                end
                                // finish up
                                8'h09 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_command <= 8'h0A;
                                end


                                // increment address pointer
                                8'h0A : begin
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h0B;
                                end


                                // jne
                                8'h0B : begin
                                    if ( reg_int_address != 14'd0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h0C;
                                end


                                // finish up
                                8'h0C : begin
                                    statemachine_program <= 8'hFE;
                                end


                            endcase
                        end






                        

                        // 0x10 (src^key)=dst
                        8'h10 : begin
                            case (statemachine_command)

                            // initialise
                            8'h00 : begin
                                reg_int_address <= 14'd0;
                                mem_src_ce <= 1'b1;
                                mem_src_oce <= 1'b1;
                                mem_key_ce <= 1'b1;
                                mem_key_oce <= 1'b1;
                                mem_dst_ce <= 1'b1;
                                mem_dst_wre <= 1'b1;
                                statemachine_command <= 8'h01;
                            end
                            
                            // set address on src and key and dst
                            8'h01 : begin
                                mem_src_ad <= reg_int_address;
                                mem_key_ad <= reg_int_address;
                                mem_dst_ad <= reg_int_address;
                                statemachine_command <= 8'h02;
                            end
                            
                            // clock high on src and key
                            8'h02 : begin
                                mem_src_clk <= 1'b1;
                                mem_key_clk <= 1'b1;
                                statemachine_command <= 8'h03;
                            end
                            
                            // clock low on src and key
                            8'h03 : begin
                                mem_src_clk <= 1'b0;
                                mem_key_clk <= 1'b0;
                                statemachine_command <= 8'h04;
                            end
                            
                            // copy data
                            8'h04 : begin
                                mem_dst_din <= mem_src_dout ^ mem_key_dout;
                                statemachine_command <= 8'h05;
                            end
                            
                            // clock high on dst
                            8'h05 : begin
                                mem_dst_clk <= 1'b1;
                                statemachine_command <= 8'h06;
                            end
                            
                            // clock low on dst
                            8'h06 : begin
                                mem_dst_clk <= 1'b0;
                                statemachine_command <= 8'h07;
                            end
                            
                            // increment address counter
                            8'h07 : begin
                                reg_int_address = reg_int_address + 1;
                                statemachine_command <= 8'h08;
                            end
                            
                            // jne
                            8'h08 : begin
                                if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                else statemachine_command <= 8'h09;
                            end
                            
                            // finish up
                            8'h09 : begin
                                mem_src_ce <= 1'b0;
                                mem_src_oce <= 1'b0;
                                mem_key_ce <= 1'b0;
                                mem_key_oce <= 1'b0;
                                mem_dst_ce <= 1'b0;
                                mem_dst_wre <= 1'b0;
                                statemachine_program <= 8'hFE;
                            end
                            
                            endcase
                        end









                        // 0x20 load 2 bytes of key into lfsr
                        8'h20 : begin
                            //
                            case (statemachine_command)
                                // initiaise
                                8'h00 : begin
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // // set address for byte 0
                                8'h01 : begin
                                    mem_key_ad <= 14'd0;
                                    statemachine_command <= 8'h02;
                                end
                                // clock high
                                8'h02 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock low
                                8'h03 : begin
                                    mem_key_clk <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                // read data
                                8'h04 : begin
                                    reg_lfsr_single[7:0] <= mem_key_dout;
                                    statemachine_command <= 8'h05;
                                end
                                // set address to byte 1
                                8'h05 : begin
                                    mem_key_ad <= 14'd1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock high
                                8'h06 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h07;
                                end
                                // clock low
                                8'h07 : begin
                                    mem_key_clk <= 1'b0;
                                    statemachine_command <= 8'h08;
                                end
                                // read data
                                8'h08 : begin
                                    reg_lfsr_single[15:8] <= mem_key_dout;
                                    statemachine_command <= 8'h09;
                                end
                                // finish up
                                8'h09 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end

                        // 0x21 (src^lfsr)=dst
                        8'h21 : begin
                            case (statemachine_command)
                                
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    reg_int_data <= 8'd0;
                                    statemachine_command <= 8'h01;
                                end
                                

                                // step lfsr 8 time into data register
                                // step lfsr 0
                                8'h01 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h02;
                                end
                                8'h02 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h03;
                                end
                                8'h03 : begin
                                    reg_int_data[0] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h04;
                                end
                                // step lfsr 1
                                8'h04 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h05;
                                end
                                8'h05 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h06;
                                end
                                8'h06 : begin
                                    reg_int_data[1] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h07;
                                end
                                // step lfsr 2
                                8'h07 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h08;
                                end
                                8'h08 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h09;
                                end
                                8'h09 : begin
                                    reg_int_data[2] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h0A;
                                end
                                // step lfsr 3
                                8'h0A : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h0B;
                                end
                                8'h0B : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h0C;
                                end
                                8'h0C : begin
                                    reg_int_data[3] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h0D;
                                end
                                // step lfsr 4
                                8'h0D : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h0E;
                                end
                                8'h0E : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h0F;
                                end
                                8'h0F : begin
                                    reg_int_data[4] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h10;
                                end
                                // step lfsr 5
                                8'h10 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h11;
                                end
                                8'h11 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h12;
                                end
                                8'h12 : begin
                                    reg_int_data[5] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h13;
                                end
                                // step lfsr 6
                                8'h13 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h14;
                                end
                                8'h14 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h15;
                                end
                                8'h15 : begin
                                    reg_int_data[6] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h16;
                                end
                                // step lfsr 7
                                8'h16 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h17;
                                end
                                8'h17 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_command <= 8'h18;
                                end
                                8'h18 : begin
                                    reg_int_data[7] <= reg_lfsr_single[0];
                                    statemachine_command <= 8'h19;
                                end
                                
                                

                                // load byte from src into data register
                                // set up chip
                                8'h19 : begin
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    mem_src_ad <= reg_int_address;
                                    statemachine_command <= 8'h1A;
                                end
                                // clock high
                                8'h1A : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h1B;
                                end
                                // clock low
                                8'h1B : begin
                                    mem_src_clk <= 1'b0;
                                    statemachine_command <= 8'h1C;
                                end
                                // read data
                                8'h1C : begin
                                    reg_int_data <= reg_int_data ^ mem_src_dout;
                                    statemachine_command <= 8'h1D;
                                end
                                // finish up
                                8'h1D : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    statemachine_command <= 8'h1E;
                                end
                                

                                // write byte to dst
                                //  set up chip
                                8'h1E : begin
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    mem_dst_ad <= reg_int_address;
                                    mem_dst_din <= reg_int_data;
                                    statemachine_command <= 8'h1F;
                                end
                                // clock high
                                8'h1F : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h20;
                                end
                                // clock low
                                8'h20 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_command <= 8'h21;
                                end
                                // finish up
                                8'h21 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_command <= 8'h22;
                                end
                                

                                // increment address counter
                                8'h22 : begin
                                    reg_int_address <= reg_int_address + 1;
                                    statemachine_command <= 8'h23;
                                end

                                // jne
                                8'h23 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h24;
                                end

                                // finish up
                                8'h24 : begin
                                    statemachine_program <= 8'hFE;
                                end
                                
                                
                                




                            endcase
                        end

                        // 0x22 step lfsr
                        8'h22 : begin
                            case (statemachine_command)
                                // step the lfsr
                                8'h00 : begin
                                    reg_lfsr_single[15:1] <= reg_lfsr_single[14:0];
                                    statemachine_command <= 8'h01;
                                end
                                8'h01 : begin
                                    reg_lfsr_single[0] <= (((reg_lfsr_single[15]^reg_lfsr_single[13])^reg_lfsr_single[12])^reg_lfsr_single[10]);
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end

                        // 0x23 copy lfsr to dst
                        8'h23 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address and data for byte 0
                                8'h01 : begin
                                    mem_dst_ad <= 14'd0;
                                    //mem_dst_din <= reg_lfsr_single[7:0];
                                    mem_dst_din <= 8'hDE;
                                    statemachine_command <= 8'h02;
                                end
                                // clock high
                                8'h02 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock low
                                8'h03 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_command <= 8'h04;
                                end
                                // set address and data for byte 1
                                8'h04 : begin
                                    mem_dst_ad <= 14'd1;
                                    //mem_dst_din <= reg_lfsr_single[15:8];
                                    mem_dst_din <= 8'hAD;
                                    statemachine_command <= 8'h05;
                                end
                                // clock high
                                8'h05 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h06;
                                end
                                // clock low
                                8'h06 : begin
                                    mem_dst_clk <= 1'b0;
                                    statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end













                        // 0xE0 src -> ram
                        8'hE0 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_src_ad <= reg_int_address;
                                    mem_ram_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_src_clk <= 1'b0;
                                    mem_ram_din <= mem_src_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_ram_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE1 src -> key
                        8'hE1 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_src_ad <= reg_int_address;
                                    mem_key_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_src_clk <= 1'b0;
                                    mem_key_din <= mem_src_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_key_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE2 src -> cmd
                        8'hE2 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_src_ad <= reg_int_address;
                                    mem_cmd_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_src_clk <= 1'b0;
                                    mem_cmd_din <= mem_src_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_cmd_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    statemachine_program <= 8'hFF;
                                end
                            endcase
                        end
                        // 0xE3 src -> dst
                        8'hE3 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_src_ce <= 1'b1;
                                    mem_src_oce <= 1'b1;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_src_ad <= reg_int_address;
                                    mem_dst_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_src_clk <= 1'b0;
                                    mem_dst_din <= mem_src_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_dst_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_src_ce <= 1'b0;
                                    mem_src_oce <= 1'b0;
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE4 key -> src
                        8'hE4 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_key_ad <= reg_int_address;
                                    mem_src_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_key_clk <= 1'b0;
                                    mem_src_din <= mem_key_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_src_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE5 key -> ram
                        8'hE5 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_key_ad <= reg_int_address;
                                    mem_ram_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_key_clk <= 1'b0;
                                    mem_ram_din <= mem_key_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_ram_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE6 key -> cmd
                        8'hE6 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_key_ad <= reg_int_address;
                                    mem_cmd_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_key_clk <= 1'b0;
                                    mem_cmd_din <= mem_key_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_cmd_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    statemachine_program <= 8'hFF;
                                end
                            endcase
                        end
                        // 0xE7 key -> dst
                        8'hE7 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_key_ce <= 1'b1;
                                    mem_key_oce <= 1'b1;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_key_ad <= reg_int_address;
                                    mem_dst_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_key_clk <= 1'b0;
                                    mem_dst_din <= mem_key_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_dst_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_key_ce <= 1'b0;
                                    mem_key_oce <= 1'b0;
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE8 cmd -> src
                        8'hE8 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_oce <= 1'b1;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_cmd_ad <= reg_int_address;
                                    mem_src_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_cmd_clk <= 1'b0;
                                    mem_src_din <= mem_cmd_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_src_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_oce <= 1'b0;
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xE9 cmd -> key
                        8'hE9 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_oce <= 1'b1;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_cmd_ad <= reg_int_address;
                                    mem_key_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_cmd_clk <= 1'b0;
                                    mem_key_din <= mem_cmd_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_key_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_oce <= 1'b0;
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xEA cmd -> ram
                        8'hEA : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_oce <= 1'b1;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_cmd_ad <= reg_int_address;
                                    mem_ram_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_cmd_clk <= 1'b0;
                                    mem_ram_din <= mem_cmd_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_ram_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_oce <= 1'b0;
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xEB cmd -> dst
                        8'hEB : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_oce <= 1'b1;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_cmd_ad <= reg_int_address;
                                    mem_dst_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_cmd_clk <= 1'b0;
                                    mem_dst_din <= mem_cmd_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_dst_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_oce <= 1'b0;
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xEC dst -> src
                        8'hEC : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_oce <= 1'b1;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_src_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_dst_clk <= 1'b0;
                                    mem_src_din <= mem_dst_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_src_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_oce <= 1'b0;
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xED dst -> key
                        8'hED : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_oce <= 1'b1;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_key_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_dst_clk <= 1'b0;
                                    mem_key_din <= mem_dst_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_key_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_oce <= 1'b0;
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xEE dst -> cmd
                        8'hEE : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_oce <= 1'b1;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_cmd_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_dst_clk <= 1'b0;
                                    mem_cmd_din <= mem_dst_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_cmd_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_oce <= 1'b0;
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    statemachine_program <= 8'hFF;
                                end
                            endcase
                        end
                        // 0xEF dst -> ram
                        8'hEF : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_oce <= 1'b1;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_dst_ad <= reg_int_address;
                                    mem_ram_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_dst_clk <= 1'b0;
                                    mem_ram_din <= mem_dst_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_dst_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_oce <= 1'b0;
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xF0 ram -> src
                        8'hF0 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_oce <= 1'b1;
                                    mem_src_ce <= 1'b1;
                                    mem_src_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_src_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_ram_clk <= 1'b0;
                                    mem_src_din <= mem_ram_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_src_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_src_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_oce <= 1'b0;
                                    mem_src_ce <= 1'b0;
                                    mem_src_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xF1 ram -> key
                        8'hF1 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_oce <= 1'b1;
                                    mem_key_ce <= 1'b1;
                                    mem_key_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_key_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_ram_clk <= 1'b0;
                                    mem_key_din <= mem_ram_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_key_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_key_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_oce <= 1'b0;
                                    mem_key_ce <= 1'b0;
                                    mem_key_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        // 0xF2 ram -> cmd
                        8'hF2 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_oce <= 1'b1;
                                    mem_cmd_ce <= 1'b1;
                                    mem_cmd_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_cmd_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_ram_clk <= 1'b0;
                                    mem_cmd_din <= mem_ram_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_cmd_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_cmd_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_oce <= 1'b0;
                                    mem_cmd_ce <= 1'b0;
                                    mem_cmd_wre <= 1'b0;
                                    statemachine_program <= 8'hFF;
                                end
                            endcase
                        end
                        // 0xF3 ram -> dst
                        8'hF3 : begin
                            case (statemachine_command)
                                // initialise
                                8'h00 : begin
                                    reg_int_address <= 14'd0;
                                    mem_ram_ce <= 1'b1;
                                    mem_ram_oce <= 1'b1;
                                    mem_dst_ce <= 1'b1;
                                    mem_dst_wre <= 1'b1;
                                    statemachine_command <= 8'h01;
                                end
                                // set address to source and destination
                                8'h01 : begin
                                    mem_ram_ad <= reg_int_address;
                                    mem_dst_ad <= reg_int_address;
                                    statemachine_command <= 8'h02;
                                end
                                // clock source up
                                8'h02 : begin
                                    mem_ram_clk <= 1'b1;
                                    statemachine_command <= 8'h03;
                                end
                                // clock source down
                                8'h03 : begin
                                    mem_ram_clk <= 1'b0;
                                    mem_dst_din <= mem_ram_dout;
                                    statemachine_command <= 8'h04;
                                end
                                // clock destination up
                                8'h04 : begin
                                    mem_dst_clk <= 1'b1;
                                    statemachine_command <= 8'h05;
                                end
                                // clock destination down
                                8'h05 : begin
                                    mem_dst_clk <= 1'b0;
                                    reg_int_address = reg_int_address + 1;
                                    statemachine_command <= 8'h06;
                                end
                                // jne
                                8'h06 : begin
                                    if ( reg_int_address != 0 ) statemachine_command <= 8'h01;
                                    else statemachine_command <= 8'h07;
                                end
                                // finish up
                                8'h07 : begin
                                    mem_ram_ce <= 1'b0;
                                    mem_ram_oce <= 1'b0;
                                    mem_dst_ce <= 1'b0;
                                    mem_dst_wre <= 1'b0;
                                    statemachine_program <= 8'hFE;
                                end
                            endcase
                        end
                        


                    endcase


                end


                // special state
                // loop around for next comand
                8'hFE : begin
                    programcounter <= programcounter + 1;
                    statemachine_program <= 8'h01;
                end


                // special state
                // set isfnished and halt.
                8'hFF : begin
                    arduino_isfinished <= 1'b1;
                end


            endcase
        end




    end







endmodule












































module top (
    input wire sysclk,
    input wire [7:0] arduino_datain,
    output reg [7:0] arduino_dataout,
    input wire [1:0] arduino_databank,
    input wire arduino_readwrite,
    input wire arduino_clock,
    input wire arduino_reset,
    input wire arduino_execute,
    output reg arduino_isfinished
);
    
    wire [7:0] wire_arduino_data_out;
    always @(wire_arduino_data_out) begin
        arduino_dataout <= wire_arduino_data_out;
    end

    wire wire_arduino_isfinished;
    always @(wire_arduino_isfinished) begin
        arduino_isfinished <= wire_arduino_isfinished;
    end
    


    // define a memory block for src , key , cmd , dst

    wire [7:0] wire_mem_src_douta;
    wire [7:0] wire_mem_src_doutb;
    wire wire_mem_src_clka;
    wire wire_mem_src_ocea;
    wire wire_mem_src_cea;
    wire wire_mem_src_reseta;
    wire wire_mem_src_wrea;
    wire wire_mem_src_clkb;
    wire wire_mem_src_oceb;
    wire wire_mem_src_ceb;
    wire wire_mem_src_resetb;
    wire wire_mem_src_wreb;
    wire [13:0] wire_mem_src_ada;
    wire [7:0] wire_mem_src_dina;
    wire [13:0] wire_mem_src_adb;
    wire [7:0] wire_mem_src_dinb;
    
    Gowin_DPB_16k bankmem_src(
        .douta(wire_mem_src_douta), //output [7:0] douta
        .doutb(wire_mem_src_doutb), //output [7:0] doutb
        .clka(wire_mem_src_clka), //input clka
        .ocea(wire_mem_src_ocea), //input ocea
        .cea(wire_mem_src_cea), //input cea
        .reseta(wire_mem_src_reseta), //input reseta
        .wrea(wire_mem_src_wrea), //input wrea
        .clkb(wire_mem_src_clkb), //input clkb
        .oceb(wire_mem_src_oceb), //input oceb
        .ceb(wire_mem_src_ceb), //input ceb
        .resetb(wire_mem_src_resetb), //input resetb
        .wreb(wire_mem_src_wreb), //input wreb
        .ada(wire_mem_src_ada), //input [13:0] ada
        .dina(wire_mem_src_dina), //input [7:0] dina
        .adb(wire_mem_src_adb), //input [13:0] adb
        .dinb(wire_mem_src_dinb) //input [7:0] dinb
    );



    wire [7:0] wire_mem_key_douta;
    wire [7:0] wire_mem_key_doutb;
    wire wire_mem_key_clka;
    wire wire_mem_key_ocea;
    wire wire_mem_key_cea;
    wire wire_mem_key_reseta;
    wire wire_mem_key_wrea;
    wire wire_mem_key_clkb;
    wire wire_mem_key_oceb;
    wire wire_mem_key_ceb;
    wire wire_mem_key_resetb;
    wire wire_mem_key_wreb;
    wire [13:0] wire_mem_key_ada;
    wire [7:0] wire_mem_key_dina;
    wire [13:0] wire_mem_key_adb;
    wire [7:0] wire_mem_key_dinb;
    
    Gowin_DPB_16k bankmem_key(
        .douta(wire_mem_key_douta), //output [7:0] douta
        .doutb(wire_mem_key_doutb), //output [7:0] doutb
        .clka(wire_mem_key_clka), //input clka
        .ocea(wire_mem_key_ocea), //input ocea
        .cea(wire_mem_key_cea), //input cea
        .reseta(wire_mem_key_reseta), //input reseta
        .wrea(wire_mem_key_wrea), //input wrea
        .clkb(wire_mem_key_clkb), //input clkb
        .oceb(wire_mem_key_oceb), //input oceb
        .ceb(wire_mem_key_ceb), //input ceb
        .resetb(wire_mem_key_resetb), //input resetb
        .wreb(wire_mem_key_wreb), //input wreb
        .ada(wire_mem_key_ada), //input [13:0] ada
        .dina(wire_mem_key_dina), //input [7:0] dina
        .adb(wire_mem_key_adb), //input [13:0] adb
        .dinb(wire_mem_key_dinb) //input [7:0] dinb
    );



    wire [7:0] wire_mem_cmd_douta;
    wire [7:0] wire_mem_cmd_doutb;
    wire wire_mem_cmd_clka;
    wire wire_mem_cmd_ocea;
    wire wire_mem_cmd_cea;
    wire wire_mem_cmd_reseta;
    wire wire_mem_cmd_wrea;
    wire wire_mem_cmd_clkb;
    wire wire_mem_cmd_oceb;
    wire wire_mem_cmd_ceb;
    wire wire_mem_cmd_resetb;
    wire wire_mem_cmd_wreb;
    wire [13:0] wire_mem_cmd_ada;
    wire [7:0] wire_mem_cmd_dina;
    wire [13:0] wire_mem_cmd_adb;
    wire [7:0] wire_mem_cmd_dinb;
    
    Gowin_DPB_16k bankmem_cmd(
        .douta(wire_mem_cmd_douta), //output [7:0] douta
        .doutb(wire_mem_cmd_doutb), //output [7:0] doutb
        .clka(wire_mem_cmd_clka), //input clka
        .ocea(wire_mem_cmd_ocea), //input ocea
        .cea(wire_mem_cmd_cea), //input cea
        .reseta(wire_mem_cmd_reseta), //input reseta
        .wrea(wire_mem_cmd_wrea), //input wrea
        .clkb(wire_mem_cmd_clkb), //input clkb
        .oceb(wire_mem_cmd_oceb), //input oceb
        .ceb(wire_mem_cmd_ceb), //input ceb
        .resetb(wire_mem_cmd_resetb), //input resetb
        .wreb(wire_mem_cmd_wreb), //input wreb
        .ada(wire_mem_cmd_ada), //input [13:0] ada
        .dina(wire_mem_cmd_dina), //input [7:0] dina
        .adb(wire_mem_cmd_adb), //input [13:0] adb
        .dinb(wire_mem_cmd_dinb) //input [7:0] dinb
    );



    wire [7:0] wire_mem_dst_douta;
    wire [7:0] wire_mem_dst_doutb;
    wire wire_mem_dst_clka;
    wire wire_mem_dst_ocea;
    wire wire_mem_dst_cea;
    wire wire_mem_dst_reseta;
    wire wire_mem_dst_wrea;
    wire wire_mem_dst_clkb;
    wire wire_mem_dst_oceb;
    wire wire_mem_dst_ceb;
    wire wire_mem_dst_resetb;
    wire wire_mem_dst_wreb;
    wire [13:0] wire_mem_dst_ada;
    wire [7:0] wire_mem_dst_dina;
    wire [13:0] wire_mem_dst_adb;
    wire [7:0] wire_mem_dst_dinb;
    
    Gowin_DPB_16k bankmem_dst(
        .douta(wire_mem_dst_douta), //output [7:0] douta
        .doutb(wire_mem_dst_doutb), //output [7:0] doutb
        .clka(wire_mem_dst_clka), //input clka
        .ocea(wire_mem_dst_ocea), //input ocea
        .cea(wire_mem_dst_cea), //input cea
        .reseta(wire_mem_dst_reseta), //input reseta
        .wrea(wire_mem_dst_wrea), //input wrea
        .clkb(wire_mem_dst_clkb), //input clkb
        .oceb(wire_mem_dst_oceb), //input oceb
        .ceb(wire_mem_dst_ceb), //input ceb
        .resetb(wire_mem_dst_resetb), //input resetb
        .wreb(wire_mem_dst_wreb), //input wreb
        .ada(wire_mem_dst_ada), //input [13:0] ada
        .dina(wire_mem_dst_dina), //input [7:0] dina
        .adb(wire_mem_dst_adb), //input [13:0] adb
        .dinb(wire_mem_dst_dinb) //input [7:0] dinb
    );




    arduino_io myarduino_io(    .sysclk(sysclk),
                                // arduino side
                                .arduino_datain(arduino_datain),
                                .arduino_dataout(wire_arduino_data_out),
                                .arduino_databank(arduino_databank),
                                .arduino_readwrite(arduino_readwrite),
                                .arduino_clock(arduino_clock),
                                .arduino_reset(arduino_reset),
                                
                                // src mem
                                .mem_src_dout(wire_mem_src_douta),
                                .mem_src_clk(wire_mem_src_clka),
                                .mem_src_oce(wire_mem_src_ocea),
                                .mem_src_ce(wire_mem_src_cea),
                                .mem_src_reset(wire_mem_src_reseta),
                                .mem_src_wre(wire_mem_src_wrea),
                                .mem_src_ad(wire_mem_src_ada),
                                .mem_src_din(wire_mem_src_dina),
                                // key mem
                                .mem_key_dout(wire_mem_key_douta),
                                .mem_key_clk(wire_mem_key_clka),
                                .mem_key_oce(wire_mem_key_ocea),
                                .mem_key_ce(wire_mem_key_cea),
                                .mem_key_reset(wire_mem_key_reseta),
                                .mem_key_wre(wire_mem_key_wrea),
                                .mem_key_ad(wire_mem_key_ada),
                                .mem_key_din(wire_mem_key_dina),
                                // cmd mem
                                .mem_cmd_dout(wire_mem_cmd_douta),
                                .mem_cmd_clk(wire_mem_cmd_clka),
                                .mem_cmd_oce(wire_mem_cmd_ocea),
                                .mem_cmd_ce(wire_mem_cmd_cea),
                                .mem_cmd_reset(wire_mem_cmd_reseta),
                                .mem_cmd_wre(wire_mem_cmd_wrea),
                                .mem_cmd_ad(wire_mem_cmd_ada),
                                .mem_cmd_din(wire_mem_cmd_dina),
                                // dst mem
                                .mem_dst_dout(wire_mem_dst_douta),
                                .mem_dst_clk(wire_mem_dst_clka),
                                .mem_dst_oce(wire_mem_dst_ocea),
                                .mem_dst_ce(wire_mem_dst_cea),
                                .mem_dst_reset(wire_mem_dst_reseta),
                                .mem_dst_wre(wire_mem_dst_wrea),
                                .mem_dst_ad(wire_mem_dst_ada),
                                .mem_dst_din(wire_mem_dst_dina)
                                
                            );



    // now onto the actual processor!

    // define its ram chip
    
    wire [7:0] wire_mem_ram_dout;
    wire wire_mem_ram_clk;
    wire wire_mem_ram_oce;
    wire wire_mem_ram_ce;
    wire wire_mem_ram_reset;
    wire wire_mem_ram_wre;
    wire [13:0] wire_mem_ram_ad;
    wire [7:0] wire_mem_ram_din;

    Gowin_SP16k bankmem_ram(
        .dout(wire_mem_ram_dout), //output [7:0] dout
        .clk(wire_mem_ram_clk), //input clk
        .oce(wire_mem_ram_oce), //input oce
        .ce(wire_mem_ram_ce), //input ce
        .reset(wire_mem_ram_reset), //input reset
        .wre(wire_mem_ram_wre), //input wre
        .ad(wire_mem_ram_ad), //input [13:0] ad
        .din(wire_mem_ram_din) //input [7:0] din
    );





    // central processor
    
    central_processor mycentral_processor(
        // sysclk
        .sysclk(sysclk),
        // arduino
        .arduino_execute(arduino_execute),
        .arduino_isfinished(wire_arduino_isfinished),
        .arduino_reset(arduino_reset),
        // src mem
        .mem_src_dout(wire_mem_src_doutb),
        .mem_src_clk(wire_mem_src_clkb),
        .mem_src_oce(wire_mem_src_oceb),
        .mem_src_ce(wire_mem_src_ceb),
        .mem_src_reset(wire_mem_src_resetb),
        .mem_src_wre(wire_mem_src_wreb),
        .mem_src_ad(wire_mem_src_adb),
        .mem_src_din(wire_mem_src_dinb),
        // key mem
        .mem_key_dout(wire_mem_key_doutb),
        .mem_key_clk(wire_mem_key_clkb),
        .mem_key_oce(wire_mem_key_oceb),
        .mem_key_ce(wire_mem_key_ceb),
        .mem_key_reset(wire_mem_key_resetb),
        .mem_key_wre(wire_mem_key_wreb),
        .mem_key_ad(wire_mem_key_adb),
        .mem_key_din(wire_mem_key_dinb),
        // cmd mem
        .mem_cmd_dout(wire_mem_cmd_doutb),
        .mem_cmd_clk(wire_mem_cmd_clkb),
        .mem_cmd_oce(wire_mem_cmd_oceb),
        .mem_cmd_ce(wire_mem_cmd_ceb),
        .mem_cmd_reset(wire_mem_cmd_resetb),
        .mem_cmd_wre(wire_mem_cmd_wreb),
        .mem_cmd_ad(wire_mem_cmd_adb),
        .mem_cmd_din(wire_mem_cmd_dinb),
        // dst mem
        .mem_dst_dout(wire_mem_dst_doutb),
        .mem_dst_clk(wire_mem_dst_clkb),
        .mem_dst_oce(wire_mem_dst_oceb),
        .mem_dst_ce(wire_mem_dst_ceb),
        .mem_dst_reset(wire_mem_dst_resetb),
        .mem_dst_wre(wire_mem_dst_wreb),
        .mem_dst_ad(wire_mem_dst_adb),
        .mem_dst_din(wire_mem_dst_dinb),
        // ram mem
        .mem_ram_dout(wire_mem_ram_dout),
        .mem_ram_clk(wire_mem_ram_clk),
        .mem_ram_oce(wire_mem_ram_oce),
        .mem_ram_ce(wire_mem_ram_ce),
        .mem_ram_reset(wire_mem_ram_reset),
        .mem_ram_wre(wire_mem_ram_wre),
        .mem_ram_ad(wire_mem_ram_ad),
        .mem_ram_din(wire_mem_ram_din)
        
    );
    
    




endmodule




















































