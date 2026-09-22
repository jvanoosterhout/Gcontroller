Wireviz yaml code to generate Wiring diagram for subsystem on the MKcontroller. Use https://marketplace.visualstudio.com/items?itemName=pomdtr.markdown-kroki to preview the diagram. Optionally you can run [Kroki server](https://docs.kroki.io/kroki/setup/install/) in docker. 


```kroki-wireviz
connectors:
  PI Zero W2:
    pins: [5V, GPIO26, GND, GPIO25]

  Relay:
    pins: [VCC, R0, GND, "NC_0", COM_0]

  Optocoupler:
    pins: [OPT_G, OPT_V, OPT_IN, OPT_GND]

  Rectifier:
    pins: [DC_POS, DC_GND, AC1, AC2]

  GX12:
    type: GX12-4
    pins: [1, 2, 3, 4]

  External_connector:
    pins: [1, 2, 3, 4]

  Bell_wires:
    pins: [BELL_POS, BELL_NEG, To_bell_trafo, From_bell_btn]

cables:
  W_PI_RELAY:
    wirecount: 3
    colors: [RD, GN, BK]
    show_name: False
    show_wirecount: False

  W_RELAY_GX12:
    wirecount: 2
    colors: [BK, BK]
    show_name: False
    show_wirecount: False

  W_GX12_RECT:
    wirecount: 2
    colors: [BK, BK]
    show_name: False
    show_wirecount: False

  W_RECT_Optocoupler:
    wirecount: 2
    colors: [RD, BK]
    show_name: False
    show_wirecount: False

  W_OPTO_PI:
    wirecount: 2
    colors: [BN, WH]
    show_name: False
    show_wirecount: False

  W_UTP:
    wirecount: 4
    colors: [GN, OG, BU, BN]
    show_name: False
    show_wirecount: False

  W_TERMINAL_PASS:
    wirecount: 4
    colors: [BK, WH, BU, RD]
    show_name: False
    show_wirecount: False



connections:


  # Pi Zero W2 to relay board
  - - PI Zero W2: [5V, GPIO26, GND]
    - W_PI_RELAY: [1, 2, 3]
    - Relay: [VCC, R0, GND] 

  - - Relay: ["NC_0", COM_0]
    - W_RELAY_GX12: [1, 2]
    - GX12: [1, 2]

  - - Rectifier: [AC1, AC2]
    - W_GX12_RECT: [1, 2]
    - GX12: [3, 4]

  - - Optocoupler: OPT_IN
    - W_RECT_Optocoupler: 1
    - Rectifier: DC_POS
    
  - - Optocoupler: OPT_GND
    - W_RECT_Optocoupler: 2
    - Rectifier: DC_GND

  - - PI Zero W2: GPIO25
    - W_OPTO_PI: 2
    - Optocoupler: OPT_V

  - - PI Zero W2: GND
    - W_OPTO_PI: 1
    - Optocoupler: OPT_G

  - - GX12: [1, 2, 3, 4]
    - W_UTP: [1, 2, 3, 4]
    - External_connector: [1, 4, 3, 4]

  - - External_connector: [1, 2, 3, 4]
    - W_TERMINAL_PASS: [1, 2, 3, 4]
    - Bell_wires: [BELL_POS, BELL_NEG,  To_bell_trafo, From_bell_btn]
    
  - - External_connector: 2
    - W_TERMINAL_PASS: 3
    - Bell_wires: To_bell_trafo

tweak:
  override:
    graph:
      ranksep: "0.5"
    W_PI_RELAY:
      shape: none
      fontsize: "1"
      fontcolor: white
      
    W_RELAY_GX12:
      shape: none
      fontsize: "1"
      fontcolor: white
      
    W_GX12_RECT:
      shape: none
      fontsize: "1"
      fontcolor: white
      
    W_RECT_Optocoupler:
      shape: none
      fontsize: "1"
      fontcolor: white
      
    W_OPTO_PI:
      shape: none
      fontsize: "1"
      fontcolor: white

      
    W_UTP:
      shape: none
      fontsize: "1"
      fontcolor: white      

      
    W_TERMINAL_PASS:
      shape: none
      fontsize: "1"
      fontcolor: white

    W_TERMINAL_LOOP:
      shape: none
      fontsize: "1"
      fontcolor: white


   ```   