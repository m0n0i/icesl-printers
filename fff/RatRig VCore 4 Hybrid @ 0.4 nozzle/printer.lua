-- RatRig V-Core 4 Hybrid
-- Bernet-Rollande Emmanuel 2024-07-31


layer_z = 0.0
current_z = 0.0

extruder_e = 0.0
extruder_e_restart = 0.0

current_fan_speed = 0

current_temperature = 0

current_frate = 0
changed_frate = false

current_path = 0
path_type = 3 -- 1:default, 2:Craftware, 3:Prusa/Super Slicer, 4:Cura
path_tag = {
--{ 'default',          'Craftware',              'Prusa/Super Slicer',       'Cura'            }
  { 'travel',          ';segType:Travel',        ';TYPE:Travel',             ';TYPE:TRAVEL'    },
  { 'perimeter',       ';segType:Perimeter',     ';TYPE:External perimeter', ';TYPE:WALL-OUTER'},
  { 'outer_perimeter', ';segType:Perimeter',     ';TYPE:External perimeter', ';TYPE:WALL-OUTER'},
  { 'shell',           ';segType:HShell',        ';TYPE:Internal perimeter', ';TYPE:WALL-INNER'},
  { 'cover',           ';segType:Infill',        ';TYPE:Solid infill',       ';TYPE:FILL'      },
  { 'infill',          ';segType:Infill',        ';TYPE:Internal infill',    ';TYPE:FILL'      },
  { 'gapfill',         ';segType:Infill',        ';TYPE:Gap fill',           ';TYPE:FILL'      },
  { 'bridge',          ';segType:SupportTouch',  ';TYPE:Bridge infill',      ';TYPE:WALL-OUTER'},
  { 'support',         ';segType:Support',       ';TYPE:Support material',   ';TYPE:SUPPORT'   },
  { 'brim',            ';segType:Skirt',         ';TYPE:Skirt/Brim',         ';TYPE:SKIRT'     },
  { 'raft',            ';segType:Raft',          ';TYPE:Skirt/Brim',         ';TYPE:SKIRT'     },
  { 'shield',          ';segType:Pillar',        ';TYPE:Skirt/Brim',         ';TYPE:SKIRT'     },
  { 'tower',           ';segType:Pillar',        ';TYPE:Skirt/Brim',         ';TYPE:SKIRT'     },
  { 'top_cover',       '',                       ';TYPE:Top solid infill',   ''                },
  { 'shell_cover',     ';segType:HShell',        ';TYPE:Internal perimeter', ';TYPE:WALL-INNER'},
  { 'cover_infill',    '',                       ';TYPE:Solid infill',       ''                },
  { 'cover_gapfill',   '',                       ';TYPE:Solid infill',       ''                }
}


-- helpers ---------------------------------------------------------------------

function comment(c)
  output('; ' .. c)
end

function output_debug(d)
  if debug_messages then
    comment(d)
  end
end

function round(number, decimals)
  local power = 10^decimals
  return math.floor(number * power) / power
end

function vol_to_mass(volume, density)
  return density * volume
end

function e_to_mm_cube(filament_diameter, e)
  local r = filament_diameter / 2
  return (math.pi * r^2 ) * e
end

-- get the E value (for G1 move) from a specified deposition move
function e_from_dep(dep_length, dep_width, dep_height, extruder)
  local r1 = dep_width / 2
  local r2 = filament_diameter_mm[extruder] / 2
  local extruded_vol = dep_length * math.pi * r1 * dep_height
  return extruded_vol / (math.pi * r2^2)
end

function get_path()
  local path = 0

  if path_is_travel then path = 1                       -- travel
  elseif path_is_perimeter then path = 2                -- perimeter
    if layer_id == number_of_layers - 1 then path = 14  -- top cover (perimeter)
    elseif path_is_outer_perimeter then path = 3        -- outer perimeter
    end
  elseif path_is_shell then path = 4                    -- shell
    if layer_id == number_of_layers - 1 then path = 14  -- top cover (shell)
    elseif path_is_cover then path = 15                 -- shell cover
    end
  elseif path_is_cover then path = 5                    -- cover
    if layer_id == number_of_layers - 1 then path = 14  -- top cover
    elseif path_is_infill then path = 16                -- cover infill
    elseif path_is_gapfill then path = 17               -- cover gapfill
    end
  elseif path_is_infill then path = 6                   -- infill
  elseif path_is_gapfill then path = 7                  -- gapfill
  elseif path_is_bridge then path = 8                   -- bridge
  elseif path_is_support then path = 9                  -- support
  elseif path_is_brim then path = 10                    -- brim
  elseif path_is_raft then path = 11                    -- raft
  elseif path_is_shield then path = 12                  -- shield
  elseif path_is_tower then path = 13                   -- tower
  end

  return path
end

function tag_path(path)
  output(path_tag[path][path_type])
end

function tag_path_attributes(path)
  if debug_messages then
    output_debug('* path : ' .. path_tag[path][1] .. ' (' .. path .. ')')
    output_debug('* path_length = ' .. f(path_length) .. ' [mm]')
    output_debug('* flow_miltiplier  = ' .. f(path_attributes['flow_multiplier']))
    output_debug('* speed_multiplier = ' .. f(path_attributes['speed_multiplier']))
  end
end

function set_path_acceleration(path)
  local acc = default_acc       -- acceleration
  local mcr = min_cruise_ratio  -- minimum cruise ratio
  local scv = default_scv       -- scare corner velocity

  if layer_id < 1 then      -- first layer
    output_debug('* set 1st layer path acceleration :')
    acc = first_layer_acc
    scv = default_scv
  else
    output_debug('* set ' .. path_tag[path][1] .. ' path acceleration :')
    if     path == 1 then     -- travel
      acc = default_acc
      scv = infill_scv
    elseif path == 2 then     -- perimeter
      acc = perimeter_acc
    elseif path == 3 then     -- outer perimeter
      acc = outer_perimeter_acc
    elseif path == 4 then     -- shell
      acc = shell_acc
      scv = infill_scv
    elseif path == 8 then     -- bridge
      acc = perimeter_acc
    elseif path == 9 then     -- support
      acc = support_acc
    elseif path == 10 or      -- brim
           path == 11 or      -- raft
           path == 12 then    -- shield
      acc = first_layer_acc
    elseif path == 14 then    -- top cover
      acc = top_layer_acc
    elseif path == 5  or      -- cover
           path == 6  or      -- infill
           path == 7  or      -- gapfil
           path == 13 or      -- tower
           path == 15 or      -- cover shell
           path == 16 or      -- cover infill
           path == 17 then    -- cover gapfill
      acc = infill_acc
      scv = infill_scv
    end
  end
  
  output('SET_VELOCITY_LIMIT' .. ' ' ..
         'ACCEL=' .. acc .. ' ' ..
         'MINIMUM_CRUISE_RATIO=' .. mcr .. ' ' ..
         'SQUARE_CORNER_VELOCITY=' .. scv)
end

function set_speed_override(path, frate)
  local frate_override = frate
  
  if layer_id > 0 then
    if path == 8 then       -- bridge
      if bridge_override_print_speed_mm_per_sec ~= 0 then
        frate_override = bridge_override_print_speed_mm_per_sec * speed_multiplier_0 * 60
      end
    elseif path == 14 then  -- top cover
      if top_cover_override_print_speed_mm_per_sec ~= 0 then
        frate_override = top_cover_override_print_speed_mm_per_sec * speed_multiplier_0 * 60
      end
    elseif path == 3 then   -- outer_perimeter
      if outer_perimeter_override_print_speed_mm_per_sec ~= 0 then
        frate_override = outer_perimeter_override_print_speed_mm_per_sec * speed_multiplier_0 * 60
      end
    elseif path == 6 then   -- infill
      if infill_limit_print_speed_mm_per_sec ~= 0 and
         infill_limit_print_speed_mm_per_sec < frate / 60 then
        frate_override = infill_limit_print_speed_mm_per_sec * 60
      end
    end
  end
  
  if frate_override ~= frate then
    output_debug('* override speed for ' .. path_tag[path][1] .. ' path')
  end
  
  return frate_override
end


-- Profile functions -----------------------------------------------------------

-- called to create the header of the G-Code file
function header()
  output_debug('*** header()')
  
  output("; generated by " .. slicer_name .. " " .. slicer_version)
  output("; print_height_mm : \t" .. f(extent_z))
  output("; layer_count : \t" .. f(number_of_layers))
  output("; filament_type : \t" .. name_en)
  output("; filament_name : \t" .. name_en)
  output("; filament_used_mm : \t" .. f(filament_tot_length_mm[0]) )
  -- caution! density is in g/cm3, convertion to g/mm3 needed!
  output("; filament_used_g : \t" ..
         f(vol_to_mass(e_to_mm_cube(filament_diameter_mm[0],
                                    filament_tot_length_mm[0]),
                                    filament_density/1000)))
  output("; estimated_print_time_s : \t" .. f(time_sec))
  
  output_debug('')
  
  output('SET_VELOCITY_LIMIT' .. ' ' ..
         'VELOCITY=' .. (x_max_speed + y_max_speed) / 2 .. ' ' ..
         'ACCEL=' .. (x_max_acc + y_max_acc) / 2 .. ' ' ..
         'MINIMUM_CRUISE_RATIO=' .. min_cruise_ratio .. ' ' ..
         'SQUARE_CORNER_VELOCITY=' .. infill_scv)

  output('START_PRINT' .. ' ' ..
         'EXTRUDER_TEMP=' .. extruder_temp_degree_c_0 .. ' ' ..
         'BED_TEMP=' .. bed_temp_degree_c .. ' ' ..
         'CHAMBER_TEMP=' .. chamber_temp_degree_c  .. ' ' ..
         'TOTAL_LAYER_COUNT=' .. number_of_layers .. ' ' ..
         'X0=' .. f(min_corner_x) .. ' ' ..
         'Y0=' .. f(min_corner_y) .. ' ' ..
         'X1=' .. f(min_corner_x + extent_x) .. ' ' ..
         'Y1=' .. f(min_corner_y + extent_y))

  output('G21 ; set units to millimeters')
  output('G90 ; use absolute coordinates')

  if firmware_retraction then
    output('SET_RETRACTION' .. ' ' ..
           'RETRACT_LENGTH=' .. f(filament_priming_mm_0) .. ' ' ..
           'RETRACT_SPEED=' .. retract_mm_per_sec_0 .. ' ' .. 
           'UNRETRACT_EXTRA_LENGTH=' .. priming_extra_length_mm_0 .. ' ' ..
           'UNRETRACT_SPEED=' .. priming_mm_per_sec_0)
  end
  
  if relative_extrusion then
    output('M83 ; extrusion relative mode')
  else
    output('M82 ; extrusion absolute mode')
  end

  output('SET_PRESSURE_ADVANCE ADVANCE=' .. f(filament_pressure_advance_0))

  output_debug('')
  
  current_temperature = extruder_temp_degree_c_0
end

-- called to create footer of the G-code file
function footer()
  output_debug('')
  output_debug('*** footer()')

  output('END_PRINT')
  
  output('SET_VELOCITY_LIMIT' .. ' ' ..
         'VELOCITY=' .. (x_max_speed + y_max_speed) / 2 .. ' ' ..
         'ACCEL=' .. (x_max_acc + y_max_acc) / 2 .. ' ' ..
         'MINIMUM_CRUISE_RATIO=' .. min_cruise_ratio .. ' ' ..
         'SQUARE_CORNER_VELOCITY=' .. infill_scv)
end

-- called at the start of a layer at height 'z' (mm)
function layer_start(z)
  local speed = z_lift_speed_mm_per_sec * 60
  layer_z = f(z)

  output_debug('')
  output_debug('*** layer_start()')

  output(';AFTER_LAYER_CHANGE')
  output(';Z:' .. layer_z)
  output(';' .. layer_z)
  output('G92 E0')
  output('_ON_LAYER_CHANGE LAYER=' .. layer_id + 1)

  if not layer_spiralized then
    output('G1 F' .. speed .. ' Z' .. layer_z)
  end

  extruder_e_restart = extruder_e
  current_frate = speed
  changed_frate = true
end

-- called at the end of a layer
function layer_stop()
  output_debug('')
  output_debug('*** layer_stop()')
  
  output(';LAYER_CHANGE')
  output(';Z:' .. layer_z)
  output(';' .. layer_z)
end

-- called before extruding
function extruder_start()
  output_debug('')
  output_debug('*** extruder_start()')  
end

-- called after extruding
function extruder_stop()
  output_debug('')
  output_debug('*** extruder_stop()')
end

-- called when setting-up the extruder 'ext'. This function is called for each
-- available extruder at the beginning of the G-Code and once for the first
-- used extruder in the print. After this, IceSL calls 'swap_extruder'
function select_extruder(ext)
  output_debug('')
  output_debug('*** select_extruder()')
end

-- called when swapping extruder 'ext1' to 'ext2' at position 'x,y,z'
function swap_extruder(ext1,ext2,x,y,z)
  output_debug('')
  output_debug('*** swap_extruder()')
end

-- called when priming from value 'e' with extruder 'ext'.
-- This function must return the absolute value of the E-axis after priming
function prime(ext,e)
  local e_string = ''
  local len   = filament_priming_mm_0
  local speed = priming_mm_per_sec_0 * 60

  output_debug('')
  output_debug('*** prime()')
  
  if firmware_retraction then
    output_debug('* firmware prime')
    output('G11')
  else
    if relative_extrusion then
      output_debug('* relative prime')
      e_string = ff(len + priming_extra_length_mm_0)
    else
      output_debug('* absolute prime')
      e_string = ff(e - extruder_e_restart + len + priming_extra_length_mm_0)
    end
    
    output('G1 F' .. speed .. ' E' .. e_string)
  end
  
  extruder_e = e + len
  current_frate = speed
  changed_frate = true
  
  return e + len
end

-- called when retracting from value 'e' with extruder 'ext'.
-- This function must return the absolute value of the-E axis after retracting
function retract(ext,e)
  local e_string = ''
  local len   = filament_priming_mm_0
  local speed = retract_mm_per_sec_0 * 60

  output_debug('')
  output_debug('*** retract()')

  if firmware_retraction then
    output_debug('* firmware retract')
    output('G10')
  else
    if relative_extrusion then
      output_debug('* relative retract')
      e_string = '-' .. ff(len)
    else
      output_debug('* absolute retract')
      e_string = ff(e - extruder_e_restart - len)
    end
    
    output('G1 F' .. speed .. ' E' .. e_string)
  end

  extruder_e = e - len
  current_frate = speed
  changed_frate = true

  return e - len
end

-- called when moving the E-axis to value 'e' with the current extruder
function move_e(e)
  local e_relative = e - extruder_e
  local e_absolute = e - extruder_e_restart
  local e_string = ''
  local f_string = ''

  output_debug('')
  output_debug('*** move_e()')

  if relative_extrusion then
    e_string = ' E' .. ff(e_relative)
  else
    e_string = ' E' .. ff(e_absolute)
  end

  if changed_frate == true then
    f_string = ' F' .. round(current_frate, 0)
    changed_frate = false
  end

  output('G1' .. f_string .. e_string)

  extruder_e = e
end

-- called when traveling to 'x,y,z'
function move_xyz(x,y,z)
  local path = get_path()
  local f_string = ''
  local z_string = ''

  if current_path ~= path then
    output_debug('')
    output_debug('*** move_xyz()')
    tag_path(path)
    set_path_acceleration(path)
    current_path = path
  end

  if changed_frate == true then
    f_string = ' F' .. round(current_frate, 0)
    changed_frate = false
  end

  if z ~= current_z then
    z_string = ' Z' .. ff(z)
    current_z = z
  end

  output('G0' .. f_string .. ' X' .. f(x) .. ' Y' .. f(y) .. z_string)
end

-- called when traveling to 'x,y,z' while extruding to value 'e'
function move_xyze(x,y,z,e)
  local path = get_path()
  local e_relative = e - extruder_e
  local e_absolute = e - extruder_e_restart
  local f_string = ''
  local z_string = ''
  local e_string = ''

  if current_path ~= path then
    output_debug('')
    output_debug('*** move_xyze()')
    tag_path(path)
    tag_path_attributes(path)
    set_path_acceleration(path)
    current_path = path
  end

  if changed_frate == true then
    f_string = ' F' .. round(current_frate, 0)
    changed_frate = false
  end

  if z ~= current_z then
    z_string = ' Z' .. ff(z)
    current_z = z
  end

  if relative_extrusion then
    e_string = ' E' .. ff(e_relative)
  else
    e_string = ' E' .. ff(e_absolute)
  end

  output('G1' .. f_string .. ' X' .. f(x) .. ' Y' .. f(y) .. z_string .. e_string)

  extruder_e = e
end

-- called on each step of producing the GCode;
-- 'percent' is the total progress of the print
function progress(percent)
  output_debug('')
  output_debug('*** progress()')
  output('M73 P' .. f(percent))
end

-- called when setting the feed-rate of the printer  to 'rate'
function set_feedrate(rate)
  local path = get_path()
  
  if current_frate ~= rate then
    output_debug('')
    output_debug('*** set_feedrate()')
    
    rate = set_speed_override(path, rate)
        
    output_debug('* from ' .. round(current_frate / 60, 0) ..
                 ' to ' .. round(rate / 60, 0) .. ' [mm/s]')
                 
    current_frate = rate
    changed_frate = true
  end
end

-- called when setting the part cooling fan velocity to 'speed' (%)
function set_fan_speed(speed)
  if speed ~= current_fan_speed then
    output_debug('')
    output_debug('*** set_fan_speed()')
    output('M106 S'.. math.floor(255 * speed/100))
    current_fan_speed = speed
  end
end

-- called when setting the extruder 'ext' temperature to 'temp'
function set_extruder_temperature(ext,temp)
  temp = round(temp, 0)
  
  if temp ~= current_temperature then
    output_debug('')
    output_debug('*** set_extruder_temperature()')
    output('M104 T' .. ext .. ' S' .. temp)
    current_temperature = temp
  end
end

-- called when setting the extruder 'ext' temperature to 'temp' while waiting.
-- Used when printing with multiple extruders
function set_and_wait_extruder_temperature(ext,temp)
  temp = round(temp, 0)
  
  if temp ~= current_temperature then
    output_debug('')
    output_debug('*** set_and_wait_extruder_temperature()')
    output('M109 T' .. ext .. ' S' .. temp)
    current_temperature = temp
  end
end

-- called when the parameter enable_min_layer_time is set to true
-- and the printing time for the layer is less than 'min_layer_time_sec'.
-- 'sec' is the remaining time to achieve 'min_layer_time_sec' and 'x,y,z'
-- is where IceSL expects the head to be after the wait
function wait(sec,x,y,z)
  output_debug('')
  output_debug('*** wait()')
  output("; WAIT -- " .. sec .. "s remaining" )
  output('PAUSE')
  output("G4 P" .. sec * 1000 .. "; wait for " .. sec .. "s")
  output('RESUME')
end

-- called when setting the mixing ratios of each filament fed onto the
-- mixing extruder; 'ratios' is a table containing the ratio for each
-- filament (the add up to 1).
-- This function is only called when using color mixing
function set_mixing_ratios(ratios)
  output_debug('')
  output_debug('*** set_mixing_ratio()')
end

