name_en = "FormFutura TitanX ABS"
name_fr = "FormFutura TitanX ABS"
name_es = "FormFutura TitanX ABS"

filament_density = 1.04 -- g/cm3 PLA
max_volumetric_speed = 30 -- mm³/s

flow_multiplier = 0.93
shell_flow_multiplier = 1
support_flow_multiplier = 1

filament_pressure_advance = 0.04

-- The speed depends on the flow multiplier. We correct the speed multiplier so that the speeds displayed by the ui are effective printing speeds.
speed_multiplier = flow_multiplier^path_width_speed_adjustment_exponent

-- We limit the speeds according to the maximum volumetric flow.
print_speed_mm_per_sec_limit = max_volumetric_speed /
                              (nozzle_diameter_mm * z_layer_height_mm)

if print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if perimeter_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  perimeter_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if cover_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  cover_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if first_layer_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  first_layer_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if support_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  support_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if infill_limit_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  infill_limit_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if outer_perimeter_override_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  outer_perimeter_override_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if bridge_override_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  bridge_override_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

if top_cover_override_print_speed_mm_per_sec_max > print_speed_mm_per_sec_limit then
  top_cover_override_print_speed_mm_per_sec_max = print_speed_mm_per_sec_limit
end

extruder_temp_degree_c_0 = 245
bed_temp_degree_c = 80
chamber_temp_degree_c = 45

filament_priming_mm_0 = 0.8
priming_extra_length_mm_0 = 0
priming_mm_per_sec_0 = 60
retract_mm_per_sec_0 = 60
travel_max_length_without_retract = 20
travel_no_retract_below_length = 0

-- enable fan only if the printer is enclosed !
enable_fan = true
fan_speed_percent = 50
fan_speed_percent_on_bridges = 60

enable_min_layer_time = false
min_layer_time_method = 'Tower'
min_layer_time_sec = 30

