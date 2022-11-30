name_en = "High quality"
name_fr = "Haute qualité"
name_es = "Alta calidad"

z_layer_height_mm = 0.15

print_speed_mm_per_sec = 40
perimeter_print_speed_mm_per_sec = 35
cover_print_speed_mm_per_sec = 35
first_layer_print_speed_mm_per_sec = 20

travel_speed_mm_per_sec = 80

add_raft = false
raft_spacing = 1.0

gen_supports = false
support_extruder = 0

add_brim = true
brim_distance_to_print_mm = 1.0
brim_num_contours = 4

-- affecting settings to all brushes
for i = 0, max_number_brushes, 1 do
  _G['extruder_' .. i] = 0
  _G['num_shells_' .. i] = 3
  _G['cover_thickness_mm_' .. i] = 2
  _G['infill_percentage_' .. i] = 20
  _G['print_perimeter_' .. i] = true
end

procees_thin_features = false
