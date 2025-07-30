//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

  //Analogizer settings
  localparam [7:0] ADDRESS_ANALOGIZER_CONFIG = 8'hF7;

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
// assign cart_tran_bank3 = 8'hzz;
// assign cart_tran_bank3_dir = 1'b0;
// assign cart_tran_bank2 = 8'hzz;
// assign cart_tran_bank2_dir = 1'b0;
// assign cart_tran_bank1 = 8'hzz;
// assign cart_tran_bank1_dir = 1'b0;
// assign cart_tran_bank0 = 4'hf;
// assign cart_tran_bank0_dir = 1'b1;
// assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
// assign cart_tran_pin30_dir = 1'bz;
// assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
// assign cart_tran_pin31 = 1'bz;      // input
// assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
        default: begin
            bridge_rd_data <= 0;
        end
        32'hF8xxxxxx: begin
            bridge_rd_data <= cmd_bridge_rd_data;
        end

        32'hf2000000: begin 
            bridge_rd_data <= {31'b0, ena_anologizer};
        end

        {ADDRESS_ANALOGIZER_CONFIG,24'h0}: begin 
            bridge_rd_data <= analogizer_bridge_rd_data; 
        end // Analogizer
    endcase
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )

);

//!-------------------------------------------------------------------------
    //! Pause Core (Analogue OS Menu/Module Request)
    //!-------------------------------------------------------------------------
    wire pause_core, pause_req;

    pause_crtl u_core_pause
    (
        .clk_sys    ( clk_48         ),
        .os_inmenu  ( osnotify_inmenu ),
        .pause_req  ( pause_req),
        .pause_core ( pause_core      )
    );

///////////////////////////////////////////////
// System
///////////////////////////////////////////////

// wire osnotify_inmenu_s;

// synch_3 OSD_S (osnotify_inmenu, osnotify_inmenu_s, clk_sys);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
reg   [7:0] ioctl_index = 0;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite)     ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(4'h0),
    .ADDRESS_SIZE(25)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_dout)
);

reg cs_reset;

reg [1:0] cs_lives;
reg [2:0] cs_difficulty;
reg [2:0] cs_bonus;
reg cs_demo_sounds;
reg ena_anologizer;

always @(posedge clk_74a) begin
  if(bridge_wr) begin
    casex(bridge_addr)	  
        32'h20000000: cs_lives       <= bridge_wr_data[1:0];
        32'h30000000: cs_difficulty  <= bridge_wr_data[2:0];
        32'h40000000: cs_bonus       <= bridge_wr_data[2:0];
        32'h50000000: cs_demo_sounds <= bridge_wr_data[0];
        32'hf2000000: ena_anologizer <= bridge_wr_data[0];
        32'h80000000: cs_reset	   <= ~cs_reset;
    endcase
  end  
end
    
wire ena_anologizer_s;
synch_3 #(1) analogizer_ena_sync(ena_anologizer, ena_anologizer_s, clk_48);


wire [15:0] dips = {cs_demo_sounds, 1'b0, cs_lives, 6'b0, cs_difficulty, cs_bonus}; 

// -- reset circuit
reg last_do_reset;
reg manual_reset = 1'b0;
reg [24:0] reset_count = 25'b0;

always @(posedge clk_sys) begin
	last_do_reset <= cs_reset;
	if (~manual_reset && (cs_reset != last_do_reset)) begin
		reset_count <= 25'd1;
		manual_reset <= 1'b1;
	end
	else begin
		if (reset_count == 25'b0001111111111111111111111) begin
			reset_count <= 25'b0;
			manual_reset <= 1'b0;
		end
		else begin
			reset_count <= reset_count + 25'd1;
		end
	end
end

///////////////////////////////////////////////
// Video
///////////////////////////////////////////////

wire hblank_core, vblank_core;
wire hs_core, vs_core;

wire [11:0] sfrgb;

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;

reg hs_prev;
reg vs_prev;

assign video_rgb_clock = clk_core_12;
assign video_rgb_clock_90 = clk_core_12_90deg;

assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
assign video_rgb = video_rgb_reg;
assign video_skip = 0;

always @(posedge clk_core_12) begin
    video_de_reg <= 0;
    video_rgb_reg <= 24'b0;
	
    if (~(vblank_core || hblank_core)) begin
        video_de_reg <= 1;
        video_rgb_reg[23:16] <= {2{video_rgb_sf[11:8]}};
        video_rgb_reg[15:8]  <= {2{video_rgb_sf[7:4]}};
        video_rgb_reg[7:0]   <= {2{video_rgb_sf[3:0]}};
    end

    video_hs_reg <= ~hs_prev && hs_core;
    video_vs_reg <= ~vs_prev && vs_core;
    hs_prev <= hs_core;
    vs_prev <= vs_core;
end


///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

wire [15:0] audio_out;

sound_i2s #(
    .CHANNEL_WIDTH(15),
    .SIGNED_INPUT(0)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),
    
    .audio_l(audio_out[15:1]),
    .audio_r(audio_out[15:1]),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Control
///////////////////////////////////////////////

wire [15:0] joy;

synch_3 #(
    .WIDTH(16)
) cont1_key_s (
    cont1_key,
    joy,
    clk_sys
);

wire m_up     = p1_controls[0];
wire m_down   = p1_controls[1];
wire m_left   = p1_controls[2];
wire m_right  = p1_controls[3];
wire m_fire1   = p1_controls[4];

wire m_start1 =  p1_controls[15];
wire m_coin1   = p1_controls[14];

wire m_coin1_pulse;
shortpulse coin_pulse(
	.clk(clk_sys),
	.inp(m_coin1),
	.pulse(m_coin1_pulse)
);

wire [6:0] controls = { m_up, m_down, m_left, m_right, m_fire1, m_start1, m_coin1_pulse };

///////////////////////////////////////////////
// Instance
///////////////////////////////////////////////
wire reset = ~reset_n | ioctl_download | manual_reset;
wire reset48;

    synch_3 #(
        .WIDTH(1)
    ) reset_sync (
        reset,
        reset48,
        clk_48
    );

wire [2:0] r, g;
wire [1:0] b;

wire clk_pix;
wire pxclk6_cen;
wire pxclk12_cen;

NANO_STARFORC starforce
(
    .reset ( reset ),
    //.nPauseCPU(~pause_core),
    .nPauseCPU(1'b1),
    .clk_48m ( clk_48 ),
    .clk_32m ( clk_32 ),

    .pxclk ( clk_pix ),
    .pxclk6_cen(pxclk6_cen),
    .pxclk12_cen(pxclk12_cen),

    .HBlank ( hblank_core ),
    .VBlank ( vblank_core ),
    .HSync ( hs_core ),
    .VSync ( vs_core ),
    .red ( r ),
    .blue ( b ),
    .green ( g ),
    .sfrgb ( sfrgb ),

    .clk_sys ( clk_sys ),
    .ROMCL ( clk_sys ),
    .ROMAD ( ioctl_addr ),
    .ROMDT ( ioctl_dout ),
    .ROMEN ( ioctl_wr & ioctl_download ),

    .SOUT ( audio_out ),

    .UDLRTSC ( controls ),
    .dipsw ( {dips[7:0], dips[15:8]} ),
    .muteki ( 1'b0 ) // Invincibility

);

/*[ANALOGIZER_HOOK_BEGIN]*/
    //reg analogizer_ena;
    wire [3:0] analogizer_video_type;
    wire [4:0] snac_game_cont_type;
    wire [3:0] snac_cont_assignment;
    wire       pocket_blank_screen;

    wire analogizer_ena;
    assign analogizer_ena = ena_anologizer_s; //mod_sw0[0]; //setting from Pocket Menu

    //create aditional switch to blank Pocket screen.
    wire [11:0] video_rgb_sf;
    assign video_rgb_sf = (pocket_blank_screen && analogizer_ena) ? 12'h000: sfrgb;

    //switch between Analogizer SNAC and Pocket Controls for P1-P4 (P3,P4 when uses PCEngine Multitap)
    wire [15:0] p1_btn, p2_btn, p3_btn, p4_btn;
    wire [31:0] p1_joy, p2_joy;
    reg [31:0] p1_joystick, p2_joystick;
    reg  [15:0] p1_controls, p2_controls;

    wire snac_is_analog = (snac_game_cont_type == 5'h12) || (snac_game_cont_type == 5'h13);

    //! Player 1 ---------------------------------------------------------------------------
    reg p1_up, p1_down, p1_left, p1_right;
    wire p1_up_analog, p1_down_analog, p1_left_analog, p1_right_analog;
    //using left analog joypad
    assign p1_up_analog    = (p1_joy[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
    assign p1_down_analog  = (p1_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
    assign p1_left_analog  = (p1_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
    assign p1_right_analog = (p1_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

    always @(posedge clk_74a) begin
        p1_up    <= (snac_is_analog) ? p1_up_analog    : p1_btn[0];
        p1_down  <= (snac_is_analog) ? p1_down_analog  : p1_btn[1];
        p1_left  <= (snac_is_analog) ? p1_left_analog  : p1_btn[2];
        p1_right <= (snac_is_analog) ? p1_right_analog : p1_btn[3];
    end
    //! Player 2 ---------------------------------------------------------------------------
    reg p2_up, p2_down, p2_left, p2_right;
    wire p2_up_analog, p2_down_analog, p2_left_analog, p2_right_analog;
    //using left analog joypad
    assign p2_up_analog    = (p2_joy[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
    assign p2_down_analog  = (p2_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
    assign p2_left_analog  = (p2_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
    assign p2_right_analog = (p2_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

    always @(posedge clk_74a) begin
        p2_up    <= (snac_is_analog) ? p2_up_analog    : p2_btn[0];
        p2_down  <= (snac_is_analog) ? p2_down_analog  : p2_btn[1];
        p2_left  <= (snac_is_analog) ? p2_left_analog  : p2_btn[2];
        p2_right <= (snac_is_analog) ? p2_right_analog : p2_btn[3];
    end
    always @(posedge clk_74a) begin
        reg [31:0] p1_pocket_btn, p1_pocket_joy;
        reg [31:0] p2_pocket_btn, p2_pocket_joy;

        if((snac_game_cont_type == 5'h0) || !analogizer_ena) begin //SNAC is disabled
        //if((snac_game_cont_type == 5'h0)) begin //SNAC is disabled
            p1_controls <= cont1_key;
            p2_controls <= cont2_key;
        end
        else begin
        case(snac_cont_assignment[1:0])
        2'h0:    begin  //SNAC P1 -> Pocket P1
            p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
            p2_controls <= cont1_key;
            end
        2'h1: begin  //SNAC P1 -> Pocket P2
            p1_controls <= cont1_key;
            p2_controls <= p1_btn;
            end
        2'h2: begin //SNAC P1 -> Pocket P1, SNAC P2 -> Pocket P2
            p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
            p2_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
            end
        2'h3: begin //SNAC P1 -> Pocket P2, SNAC P2 -> Pocket P1
            p1_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
            p2_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
            end
        default: begin 
            p1_controls <= cont1_key;
            p2_controls <= cont2_key;
            end
        endcase
        end
    end

    wire [15:0] p1_btn_CK, p2_btn_CK;
    wire [31:0] p1_joy_CK, p2_joy_CK;
    synch_3 #(
    .WIDTH(16)
    ) p1b_s (
        p1_btn_CK,
        p1_btn,
        clk_74a
    );

    synch_3 #(
        .WIDTH(16)
    ) p2b_s (
        p2_btn_CK,
        p2_btn,
        clk_74a
    );

    synch_3 #(
    .WIDTH(32)
    ) p3b_s (
        p1_joy_CK,
        p1_joy,
        clk_74a
    );
        
    synch_3 #(
        .WIDTH(32)
    ) p4b_s (
        p2_joy_CK,
        p2_joy,
        clk_74a
    );


    // Video Y/C Encoder settings
    // Follows the Mike Simone Y/C encoder settings:
    // https://github.com/MikeS11/MiSTerFPGA_YC_Encoder
    // SET PAL and NTSC TIMING and pass through status bits. ** YC must be enabled in the qsf file **
    wire [39:0] CHROMA_PHASE_INC;
    wire [26:0] COLORBURST_RANGE;

    wire PALFLAG;

    parameter NTSC_REF = 3.579545;   
    parameter PAL_REF = 4.43361875;

    // Parameters to be modifed
    parameter CLK_VIDEO_NTSC = 48.0; // Must be filled E.g XX.X Hz - CLK_VIDEO
    parameter CLK_VIDEO_PAL  = 48.0; // Must be filled E.g XX.X Hz - CLK_VIDEO

    localparam [39:0] NTSC_PHASE_INC1 = 40'd81994819784; // ((NTSC_REF * 2^40) / CLK_VIDEO_NTSC)
    localparam [39:0] PAL_PHASE_INC1  = 40'd101558653516; // ((PAL_REF * 2^40) / CLK_VIDEO_PAL)

	localparam [6:0] COLORBURST_START1 = (3.7 * (CLK_VIDEO_NTSC/NTSC_REF));
	localparam [9:0] COLORBURST_NTSC_END1 = (9 * (CLK_VIDEO_NTSC/NTSC_REF)) + COLORBURST_START1;
	localparam [9:0] COLORBURST_PAL_END1 = (10 * (CLK_VIDEO_PAL/PAL_REF)) + COLORBURST_START1;


    assign PALFLAG = (analogizer_video_type == 4'h4); 

	 always @(posedge clk_48) begin
		 CHROMA_PHASE_INC <= PALFLAG ? PAL_PHASE_INC1 : NTSC_PHASE_INC1; 
		 COLORBURST_RANGE <= {COLORBURST_START1, COLORBURST_NTSC_END1, COLORBURST_PAL_END1};
	 end

    // H/V offset
    // Assigned to START + UP/DOWN/LEFT/RIGHT buttons
    logic [4:0]	hoffset = 5'h0;
    logic [4:0]	voffset = 5'h0;

    logic start_r, up_r, down_r, left_r, right_r, btnA_r, p1r1_r, p2r1_r;

    always_ff @(posedge clk_48) begin 
       start_r <= p1_controls[15];
       up_r    <= p1_controls[0];
       down_r  <= p1_controls[1];
       left_r  <= p1_controls[2];
       right_r <= p1_controls[3]; 
       btnA_r  <= p1_controls[4];
       p1r1_r    <= p1_controls[9]; //R1 button toggles credits
       p2r1_r    <= p2_controls[9]; //R1 button toggles credits
    end
   wire HSync,VSync;
   jtframe_resync jtframe_resync
   (
       .clk(clk_48),
       .pxl_cen(pxclk6_cen),
       .hs_in(hs_core),
       .vs_in(vs_core),
       .LVBL(~vblank_core),
       .LHBL(~hblank_core),
       .hoffset(hoffset), //5bits signed
       .voffset(voffset), //5bits signed
    //    .hoffset(5'd0), //5bits signed
    //    .voffset(5'd0), //5bits signed
       .hs_out(HSync),
       .vs_out(VSync)
   );

    //Debug OSD: shows Xoffset and Yoffset values and the detected video resolution for Analogizer
    wire [7:0] RGB_out_R, RGB_out_G, RGB_out_B;
    wire HS_out, VS_out, HB_out, VB_out;

   osd_top #(
   .CLK_HZ(48_000_000),
   .DURATION_SEC(4)
   ) osd_debug_inst (
       .rot90(1'b1),
       .clk(clk_48),
       .reset(reset48),
       .pixel_ce(pxclk6_cen),
       .R_in({2{sfrgb[11:8]}}),
       .G_in({2{sfrgb[7:4]}}),
       .B_in({2{sfrgb[3:0]}}),
       .hsync_in(HSync),
       .vsync_in(VSync),
       .hblank(hblank_core),
       .vblank(vblank_core),
       .key_right(p1_controls[15] && !left_r && p1_controls[2]), //Detects if Start+Left was pressed
       .key_left(p1_controls[15] && !right_r && p1_controls[3] ),//Detects if Start+Right was pressed
       .key_down(p1_controls[15] && !up_r && p1_controls[0]),    //Detects if Start+Up was pressed
       .key_up(p1_controls[15] && !down_r && p1_controls[1]),    //Detects if Start+Down was pressed
       .key_A(p1_controls[15] && !btnA_r && p1_controls[4]),    //Detects if Start+A was pressed
       .R_out(RGB_out_R),
       .G_out(RGB_out_G),
       .B_out(RGB_out_B),
       .hsync_out(HS_out),
       .vsync_out(VS_out),
       .hblank_out(HB_out),
       .vblank_out(VB_out),
       .h_offset_out(hoffset),
       .v_offset_out(voffset),
       .analogizer_ready(!busy),
       .analogizer_video_type(analogizer_video_type),
       .snac_game_cont_type(snac_game_cont_type),
       .snac_cont_assignment(snac_cont_assignment),
       .vid_mode_in(1'b1),
       .osd_pause_out (pause_req)
   );

    //48_000_000
    wire [31:0] analogizer_bridge_rd_data;
    wire busy;
    wire VIDEO_DE = ~(hblank_core | vblank_core);
    openFPGA_Pocket_Analogizer #(.MASTER_CLK_FREQ(48_000_000), .LINE_LENGTH(256), .ADDRESS_ANALOGIZER_CONFIG(ADDRESS_ANALOGIZER_CONFIG)) analogizer (
        .clk_74a(clk_74a),
        .i_clk(clk_48),
        .i_rst_apf(reset48), //i_rst_apf is active high
        .i_rst_core(reset48), //i_rst_core is active high
        .i_ena(analogizer_ena),
        //.i_ena(1'b1),

        //Video interface
        .video_clk(clk_48),
        .R(RGB_out_R),
        .G(RGB_out_G),
        .B(RGB_out_B),
        .Hblank(HB_out),
        .Vblank(VB_out),
        .Hsync(HS_out), //composite SYNC on HSync.
        .Vsync(VS_out),
        // .video_clk(clk_sys),
        // .R(video_r_core),
        // .G(video_g_core),
        // .B(video_b_core),
        // .Hblank(hblank_core),
        // .Vblank(vblank_core),
        // .Hsync(hsync_core), //composite SYNC on HSync.
        // .Vsync(vsync_core),
        //openFPGA Bridge interface
        .bridge_endian_little(bridge_endian_little),
        .bridge_addr(bridge_addr),
        .bridge_rd(bridge_rd),
        .analogizer_bridge_rd_data(analogizer_bridge_rd_data),
        .bridge_wr(bridge_wr),
        .bridge_wr_data(bridge_wr_data),

        //Analogizer settings
        .snac_game_cont_type_out(snac_game_cont_type),
        .snac_cont_assignment_out(snac_cont_assignment),
        .analogizer_video_type_out(analogizer_video_type),
        .SC_fx_out(),
        .pocket_blank_screen_out(pocket_blank_screen),
        .analogizer_osd_out(),

        //Video Y/C Encoder interface
        .CHROMA_PHASE_INC(CHROMA_PHASE_INC),
        .COLORBURST_RANGE(COLORBURST_RANGE),
        .CHROMA_ADD(0),
        .CHROMA_MUL(0),
        .PALFLAG(PALFLAG),
        //Video SVGA Scandoubler interface
        .ce_pix(clk_pix),
        .scandoubler(1'b1), //logic for disable/enable the scandoubler
        //SNAC interface
        .p1_btn_state(p1_btn_CK),
        .p1_joy_state(p1_joy_CK),
        .p2_btn_state(p2_btn_CK),  
        .p2_joy_state(p2_joy_CK),
        .p3_btn_state(),
        .p4_btn_state(),  
        .busy(busy),    
        //Pocket Analogizer IO interface to the Pocket cartridge port
        .cart_tran_bank2(cart_tran_bank2),
        .cart_tran_bank2_dir(cart_tran_bank2_dir),
        .cart_tran_bank3(cart_tran_bank3),
        .cart_tran_bank3_dir(cart_tran_bank3_dir),
        .cart_tran_bank1(cart_tran_bank1),
        .cart_tran_bank1_dir(cart_tran_bank1_dir),
        .cart_tran_bank0(cart_tran_bank0),
        .cart_tran_bank0_dir(cart_tran_bank0_dir),
        .cart_tran_pin30(cart_tran_pin30),
        .cart_tran_pin30_dir(cart_tran_pin30_dir),
        .cart_pin30_pwroff_reset(cart_pin30_pwroff_reset),
        .cart_tran_pin31(cart_tran_pin31),
        .cart_tran_pin31_dir(cart_tran_pin31_dir),
        //debug
        .o_stb()
    );
    /*[ANALOGIZER_HOOK_END]*/
   
///////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////

wire    clk_core_12;
wire    clk_core_12_90deg;
wire    clk_48;
wire    clk_32;
wire    clk_sys; // 20MHz

wire    pll_core_locked;
    
mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),

    .outclk_0       ( clk_core_12 ),
    .outclk_1       ( clk_core_12_90deg ),
    .outclk_2       ( clk_48 ),
    .outclk_3       ( clk_32 ),
    .outclk_4       ( clk_sys ),

    .locked         ( pll_core_locked )
);

endmodule



module shortpulse
(
   input    clk,
   input    inp,
   output   pulse
);

reg        out;
reg [19:0] pulse_cnt = 0;

always_ff @(posedge clk) begin

   reg old_inp;
   out <= 1'b0;

   if (|pulse_cnt) begin
      pulse_cnt <= pulse_cnt - 1'b1;
      out <= 1'b1;
   end else begin
      old_inp <= inp;
      if (old_inp && !inp) pulse_cnt <= 20'hFFFFF;
   end

end

assign pulse = out;

endmodule