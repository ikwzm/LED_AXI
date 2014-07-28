-----------------------------------------------------------------------------------
--!     @file    led3_axi_test_bench.vhd
--!     @brief   LEDx4 Control Status Registers with AXI Slave I/F Test Bench
--!     @version 0.0.1
--!     @date    2014/7/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
entity  LED4_AXI_TEST_BENCH is
    generic (
        NAME            : STRING  := "LED4_AXI_TEST";
        SCENARIO_FILE   : STRING  := "led4_axi_test.snr";
        AUTO_START      : boolean := TRUE
    );
end     LED4_AXI_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
architecture MODEL of LED4_AXI_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant AXI4_ADDR_WIDTH : integer := 32;
    constant C_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => 4,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 ALEN        => AXI3_ALEN_WIDTH,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 WDATA       => 32,
                                 RDATA       => 32,
                                 ARUSER      => 1,
                                 AWUSER      => 1,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   LED             : std_logic_vector(3 downto 0);
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    constant CLEAR           : std_logic := '0';
    ------------------------------------------------------------------------------
    -- CSR I/F 
    ------------------------------------------------------------------------------
    signal   C_ARADDR        : std_logic_vector(C_WIDTH.ARADDR -1 downto 0);
    signal   C_ARWRITE       : std_logic;
    signal   C_ARLEN         : std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal   C_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   C_ARBURST       : AXI4_ABURST_TYPE;
    signal   C_ARLOCK        : std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal   C_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   C_ARPROT        : AXI4_APROT_TYPE;
    signal   C_ARQOS         : AXI4_AQOS_TYPE;
    signal   C_ARREGION      : AXI4_AREGION_TYPE;
    signal   C_ARUSER        : std_logic_vector(C_WIDTH.ARUSER -1 downto 0);
    signal   C_ARID          : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_ARVALID       : std_logic;
    signal   C_ARREADY       : std_logic;
    signal   C_RVALID        : std_logic;
    signal   C_RLAST         : std_logic;
    signal   C_RDATA         : std_logic_vector(C_WIDTH.RDATA  -1 downto 0);
    signal   C_RRESP         : AXI4_RESP_TYPE;
    signal   C_RUSER         : std_logic_vector(C_WIDTH.RUSER  -1 downto 0);
    signal   C_RID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_RREADY        : std_logic;
    signal   C_AWADDR        : std_logic_vector(C_WIDTH.AWADDR -1 downto 0);
    signal   C_AWLEN         : std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal   C_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   C_AWBURST       : AXI4_ABURST_TYPE;
    signal   C_AWLOCK        : std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal   C_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   C_AWPROT        : AXI4_APROT_TYPE;
    signal   C_AWQOS         : AXI4_AQOS_TYPE;
    signal   C_AWREGION      : AXI4_AREGION_TYPE;
    signal   C_AWUSER        : std_logic_vector(C_WIDTH.AWUSER -1 downto 0);
    signal   C_AWID          : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_AWVALID       : std_logic;
    signal   C_AWREADY       : std_logic;
    signal   C_WLAST         : std_logic;
    signal   C_WDATA         : std_logic_vector(C_WIDTH.WDATA  -1 downto 0);
    signal   C_WSTRB         : std_logic_vector(C_WIDTH.WDATA/8-1 downto 0);
    signal   C_WUSER         : std_logic_vector(C_WIDTH.WUSER  -1 downto 0);
    signal   C_WID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_WVALID        : std_logic;
    signal   C_WREADY        : std_logic;
    signal   C_BRESP         : AXI4_RESP_TYPE;
    signal   C_BUSER         : std_logic_vector(C_WIDTH.BUSER  -1 downto 0);
    signal   C_BID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_BVALID        : std_logic;
    signal   C_BREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   C_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   C_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   C_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   C_FINISH        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    component LED4_AXI
        generic (
            C_ADDR_WIDTH    : integer range 1 to   64 :=  4;
            C_DATA_WIDTH    : integer range 8 to 1024 := 32;
            C_ID_WIDTH      : integer                 :=  8;
            AUTO_START      : boolean := TRUE;
            DEFAULT_TIMER   : integer := 100*1000*1000;
            DEFAULT_SEQ_0   : integer range 0 to 15   := 2#1111#;
            DEFAULT_SEQ_1   : integer range 0 to 15   := 2#1110#;
            DEFAULT_SEQ_2   : integer range 0 to 15   := 2#1100#;
            DEFAULT_SEQ_3   : integer range 0 to 15   := 2#1001#;
            DEFAULT_SEQ_4   : integer range 0 to 15   := 2#0011#;
            DEFAULT_SEQ_5   : integer range 0 to 15   := 2#0111#;
            DEFAULT_SEQ_LAST: integer range 0 to 5 := 5
        );
        port(
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            ACLOCK          : in    std_logic;
            ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_ARLEN         : in    std_logic_vector(3 downto 0);
            C_ARSIZE        : in    std_logic_vector(2 downto 0);
            C_ARBURST       : in    std_logic_vector(1 downto 0);
            C_ARVALID       : in    std_logic;
            C_ARREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_RRESP         : out   std_logic_vector(1 downto 0);
            C_RLAST         : out   std_logic;
            C_RVALID        : out   std_logic;
            C_RREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_AWLEN         : in    std_logic_vector(3 downto 0);
            C_AWSIZE        : in    std_logic_vector(2 downto 0);
            C_AWBURST       : in    std_logic_vector(1 downto 0);
            C_AWVALID       : in    std_logic;
            C_AWREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
            C_WLAST         : in    std_logic;
            C_WVALID        : in    std_logic;
            C_WREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_BRESP         : out   std_logic_vector(1 downto 0);
            C_BVALID        : out   std_logic;
            C_BREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            LED             : out   std_logic_vector(3 downto 0)
        );
    end component;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: LED4_AXI
        generic map (                               -- 
            C_ADDR_WIDTH    => AXI4_ADDR_WIDTH    , -- 
            C_DATA_WIDTH    => 32                 , --
            C_ID_WIDTH      => C_WIDTH.ID         , --
            AUTO_START      => AUTO_START         , --
            DEFAULT_TIMER   => 100                , --
            DEFAULT_SEQ_0   => 2#1111#            , --
            DEFAULT_SEQ_1   => 2#1110#            , --
            DEFAULT_SEQ_2   => 2#1100#            , --
            DEFAULT_SEQ_3   => 2#1001#            , --
            DEFAULT_SEQ_4   => 2#0011#            , --
            DEFAULT_SEQ_5   => 2#0111#            , --
            DEFAULT_SEQ_LAST=> 5                    --
        )
        port map(
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
            ACLOCK          => ACLK            , -- In :
            ARESETn         => ARESETn         , -- In :
            -----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
            C_ARID          => C_ARID          , -- In :
            C_ARADDR        => C_ARADDR        , -- In :
            C_ARLEN         => C_ARLEN         , -- In :
            C_ARSIZE        => C_ARSIZE        , -- In :
            C_ARBURST       => C_ARBURST       , -- In :
            C_ARVALID       => C_ARVALID       , -- In :
            C_ARREADY       => C_ARREADY       , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            C_RID           => C_RID           , -- Out:
            C_RDATA         => C_RDATA         , -- Out:
            C_RRESP         => C_RRESP         , -- Out:
            C_RLAST         => C_RLAST         , -- Out:
            C_RVALID        => C_RVALID        , -- Out:
            C_RREADY        => C_RREADY        , -- In :
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            C_AWID          => C_AWID          , -- In :
            C_AWADDR        => C_AWADDR        , -- In :
            C_AWLEN         => C_AWLEN         , -- In :
            C_AWSIZE        => C_AWSIZE        , -- In :
            C_AWBURST       => C_AWBURST       , -- In :
            C_AWVALID       => C_AWVALID       , -- In :
            C_AWREADY       => C_AWREADY       , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            C_WDATA         => C_WDATA         , -- In :
            C_WSTRB         => C_WSTRB         , -- In :
            C_WLAST         => C_WLAST         , -- In :
            C_WVALID        => C_WVALID        , -- In :
            C_WREADY        => C_WREADY        , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            C_BID           => C_BID           , -- Out:
            C_BRESP         => C_BRESP         , -- Out:
            C_BVALID        => C_BVALID        , -- Out:
            C_BREADY        => C_BREADY        , -- In :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            LED             => LED               -- Out:
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    C: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "CSR"           ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => C_WIDTH         ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => C_ARADDR        , -- I/O : 
            ARLEN           => C_ARLEN         , -- I/O : 
            ARSIZE          => C_ARSIZE        , -- I/O : 
            ARBURST         => C_ARBURST       , -- I/O : 
            ARLOCK          => C_ARLOCK        , -- I/O : 
            ARCACHE         => C_ARCACHE       , -- I/O : 
            ARPROT          => C_ARPROT        , -- I/O : 
            ARQOS           => C_ARQOS         , -- I/O : 
            ARREGION        => C_ARREGION      , -- I/O : 
            ARUSER          => C_ARUSER        , -- I/O : 
            ARID            => C_ARID          , -- I/O : 
            ARVALID         => C_ARVALID       , -- I/O : 
            ARREADY         => C_ARREADY       , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => C_RLAST         , -- In  :    
            RDATA           => C_RDATA         , -- In  :    
            RRESP           => C_RRESP         , -- In  :    
            RUSER           => C_RUSER         , -- In  :    
            RID             => C_RID           , -- In  :    
            RVALID          => C_RVALID        , -- In  :    
            RREADY          => C_RREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => C_AWADDR        , -- I/O : 
            AWLEN           => C_AWLEN         , -- I/O : 
            AWSIZE          => C_AWSIZE        , -- I/O : 
            AWBURST         => C_AWBURST       , -- I/O : 
            AWLOCK          => C_AWLOCK        , -- I/O : 
            AWCACHE         => C_AWCACHE       , -- I/O : 
            AWPROT          => C_AWPROT        , -- I/O : 
            AWQOS           => C_AWQOS         , -- I/O : 
            AWREGION        => C_AWREGION      , -- I/O : 
            AWUSER          => C_AWUSER        , -- I/O : 
            AWID            => C_AWID          , -- I/O : 
            AWVALID         => C_AWVALID       , -- I/O : 
            AWREADY         => C_AWREADY       , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => C_WLAST         , -- I/O : 
            WDATA           => C_WDATA         , -- I/O : 
            WSTRB           => C_WSTRB         , -- I/O : 
            WUSER           => C_WUSER         , -- I/O : 
            WID             => C_WID           , -- I/O : 
            WVALID          => C_WVALID        , -- I/O : 
            WREADY          => C_WREADY        , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => C_BRESP         , -- In  :    
            BUSER           => C_BUSER         , -- In  :    
            BID             => C_BID           , -- In  :    
            BVALID          => C_BVALID        , -- In  :    
            BREADY          => C_BREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => C_GPI           , -- In  :
            GPO             => C_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => C_REPORT        , -- Out :
            FINISH          => C_FINISH          -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        ACLK <= '0';
        wait for PERIOD / 2;
        ACLK <= '1';
        wait for PERIOD / 2;
    end process;

    ARESETn  <= '1' when (RESET = '0') else '0';
    C_GPI(0) <= LED(0);
    C_GPI(1) <= LED(1);
    C_GPI(2) <= LED(2);
    C_GPI(3) <= LED(3);
    C_GPI(C_GPI'high downto 4) <= (C_GPI'high downto 4 => '0');
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (C_FINISH'event and C_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,C_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,C_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,C_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert FALSE report "Simulation complete." severity FAILURE;
        wait;
    end process;
    
end MODEL;
