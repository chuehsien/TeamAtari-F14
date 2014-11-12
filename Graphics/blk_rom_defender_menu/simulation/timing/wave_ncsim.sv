
 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"


      waveform add -signals /blk_rom_defender_menu_tb/status
      waveform add -signals /blk_rom_defender_menu_tb/blk_rom_defender_menu_synth_inst/bmg_port/CLKA
      waveform add -signals /blk_rom_defender_menu_tb/blk_rom_defender_menu_synth_inst/bmg_port/ADDRA
      waveform add -signals /blk_rom_defender_menu_tb/blk_rom_defender_menu_synth_inst/bmg_port/DOUTA
console submit -using simulator -wait no "run"
