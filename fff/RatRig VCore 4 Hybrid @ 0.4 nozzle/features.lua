-- RatRig V-Core 4 Hybrid based on Seckit Sk-Go unviversal profile
-- Bernet-Rollande Emmanuel 2024-07-13


-- Build Area dimensions -------------------------------------------------------

bed_size_x_mm = 500
bed_size_y_mm = 500
bed_size_z_mm = 500


-- Printer Extruders -----------------------------------------------------------

extruder_count = 1
nozzle_diameter_mm = 0.4 -- 0.4, 0.5, 0.6, 0.8
filament_diameter_mm = 1.75
filament_pressure_advance = 0

path_width_speed_adjustment_exponent = 3

shell_flow_multiplier = 1.0
support_flow_multiplier = 1.0


-- Retraction Settings ---------------------------------------------------------

filament_priming_mm = 0.8 -- min 0.5 - max 2
priming_extra_length_mm = 0
priming_mm_per_sec = 120
retract_mm_per_sec = 120


-- Layer height ----------------------------------------------------------------

z_layer_height_mm = 0.2
z_layer_height_mm_min = nozzle_diameter_mm * 0.15
z_layer_height_mm_max = nozzle_diameter_mm * 0.75


-- Printing temperatures -------------------------------------------------------

extruder_temp_degree_c = 215
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 285

bed_temp_degree_c = 60
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 120

chamber_temp_degree_c = 0


-- Printing speeds -------------------------------------------------------------

print_speed_mm_per_sec = 400 -- buit-in
print_speed_mm_per_sec_min = 20
print_speed_mm_per_sec_max = 500

perimeter_print_speed_mm_per_sec = 250 -- buit-in
perimeter_print_speed_mm_per_sec_min = 50
perimeter_print_speed_mm_per_sec_max = 500

cover_print_speed_mm_per_sec = 250 -- buit-in
cover_print_speed_mm_per_sec_min = 50
cover_print_speed_mm_per_sec_max = 500

first_layer_print_speed_mm_per_sec = 80 -- buit-in
first_layer_print_speed_mm_per_sec_min = 20
first_layer_print_speed_mm_per_sec_max = 150

travel_speed_mm_per_sec = 600 -- buit-in
travel_speed_mm_per_sec_min = 50
travel_speed_mm_per_sec_max = 800

support_print_speed_mm_per_sec = 80  -- buit-in
support_print_speed_mm_per_sec_min = 50
support_print_speed_mm_per_sec_max = 120

outer_perimeter_override_print_speed_mm_per_sec = 0
outer_perimeter_override_print_speed_mm_per_sec_min = 0
outer_perimeter_override_print_speed_mm_per_sec_max = perimeter_print_speed_mm_per_sec_max

infill_limit_print_speed_mm_per_sec = 0
infill_limit_print_speed_mm_per_sec_min = 0
infill_limit_print_speed_mm_per_sec_max = print_speed_mm_per_sec_max

crossing_infill_limit_print_speed_mm_per_sec = 0
crossing_infill_limit_print_speed_mm_per_sec_min = 0
crossing_infill_limit_print_speed_mm_per_sec_max = print_speed_mm_per_sec_max

bridge_override_print_speed_mm_per_sec = 0
bridge_override_print_speed_mm_per_sec_min = 0
bridge_override_print_speed_mm_per_sec_max = print_speed_mm_per_sec_max

top_cover_override_print_speed_mm_per_sec = 0
top_cover_override_print_speed_mm_per_sec_min = 0
top_cover_override_print_speed_mm_per_sec_max = cover_print_speed_mm_per_sec_max

raft_speed_multiplier = 1.0 -- default 1st layer print speed


-- Acceleration settings -------------------------------------------------------

x_max_speed = 800 -- mm/s
y_max_speed = 800 -- mm/s
z_max_speed = 50 -- mm/s
e_max_speed = 120 -- mm/s

x_max_acc = 6000 -- mm/s²
y_max_acc = 6000 -- mm/s²
z_max_acc = 200 -- mm/s²
e_max_acc = 6000 -- mm/s²

default_acc = 5000 -- mm/s²
e_prime_max_acc = 200 -- mm/s²
perimeter_acc = 2500 -- mm/s²
outer_perimeter_acc = 2500 -- mm/s²
shell_acc = 5000 -- mm/s²
infill_acc = 5000 -- mm/s²
support_acc = 2000 -- mm/s²
first_layer_acc = 2000 -- mm/s²
top_layer_acc = 2000 -- mm/s²

min_cruise_ratio = 0.5

default_scv = 5 -- mm/s, scv : square corner velocity
infill_scv = 12 -- mm/s, scv : square corner velocity


-- Misc default settings -------------------------------------------------------

add_brim = true
brim_distance_to_print_mm = 10
brim_num_contours = 4

enable_z_lift = true
z_lift_mm = 0.4
z_lift_speed_mm_per_sec = 50

enable_travel_straight = true

export_gcode_thumbnails = true


-- default filament infos (when using "custom" profile) ------------------------

name_en = "PLA"
filament_density = 1.25 --g/cm3 PLA


-- Custom Settings -------------------------------------------------------------

debug_messages = false
add_checkbox_setting("debug_messages",
                     "Debug Messages",
                     "Enable printer profile debug messages in GCode output")

relative_extrusion = true
add_checkbox_setting("relative_extrusion",
                     "Relative Extrusion",
                     "Create relative extruder movement commands in GCode output.\n\nIf disabled, create absolute extruder movement.")

firmware_retraction = false
add_checkbox_setting("firmware_retraction",
                     "Firmware Retraction",
                     "Generate firmware retraction G10/G11 commands.\n\nNon-zero 'Filament retract' must be set in GUI to produce G10/\nG11 retraction commands!")
                     
add_setting("infill_limit_print_speed_mm_per_sec","Infill Limit Print Speed Override", 0, infill_limit_print_speed_mm_per_sec_max, "Infill paths will have their print speed limited by this value.\n\nSet to 0 to revert to default speed.\n\nunit: mm/sec")
                     
add_setting("outer_perimeter_override_print_speed_mm_per_sec","Outer Perimeter Print Speed Override", 0, outer_perimeter_override_print_speed_mm_per_sec_max, "Outer perimeter paths will have their print speed set to this value.\n\nSet to 0 to revert to default speed.\n\nunit: mm/sec")
                     
add_setting("bridge_override_print_speed_mm_per_sec","Bridge Print Speed Override", 0, bridge_override_print_speed_mm_per_sec_max, "Bridge paths will have their print speed set to this value.\n\nSet to 0 to revert to default speed.\n\nunit: mm/sec")

add_setting("top_cover_override_print_speed_mm_per_sec","Top Cover Print Speed Override", 0, top_cover_override_print_speed_mm_per_sec_max, "Top cover paths will have their print speed set to this value.\n\nSet to 0 to revert to default speed.\n\nunit: mm/sec")

add_setting("filament_pressure_advance","Filament Pressure Advance", 0, 1, "Pressure advance to apply for this print.")


-- Internal procedure to fill brushes / extruder settings ----------------------

for i = 0, max_number_extruders, 1 do
  _G['nozzle_diameter_mm_'..i] = nozzle_diameter_mm
  _G['filament_diameter_mm_'..i] = filament_diameter_mm
  _G['filament_priming_mm_'..i] = filament_priming_mm
  _G['priming_extra_length_mm_'..i] = priming_extra_length_mm
  _G['priming_mm_per_sec_'..i] = priming_mm_per_sec
  _G['retract_mm_per_sec_'..i] = retract_mm_per_sec
  _G['extruder_temp_degree_c_' ..i] = extruder_temp_degree_c
  _G['extruder_temp_degree_c_'..i..'_min'] = extruder_temp_degree_c_min
  _G['extruder_temp_degree_c_'..i..'_max'] = extruder_temp_degree_c_max
  _G['extruder_mix_count_'..i] = 1
end

