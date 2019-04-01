default
{
    state_entry()
    {
        llParticleSystem(
            [ 
                PSYS_SRC_TEXTURE,llGetInventoryName(INVENTORY_TEXTURE, 0), 
                PSYS_PART_START_SCALE, <0.1,0.1, 0>, 
                PSYS_PART_END_SCALE, <0.1,0.1, 0>, 
                PSYS_PART_START_COLOR, <1,1,1>, 
                PSYS_PART_END_COLOR, <1,1,1>, 
                PSYS_PART_START_ALPHA, 0.7, 
                PSYS_PART_END_ALPHA, 0.3, 
                PSYS_SRC_BURST_PART_COUNT, 10, 
                PSYS_SRC_BURST_RATE, 0.1, 
                PSYS_PART_MAX_AGE, 30.0, 
                PSYS_SRC_MAX_AGE, 0.0, 
                PSYS_SRC_PATTERN, 8, 
                PSYS_SRC_ACCEL, <0.0,0.0, -0.2>, 
                PSYS_SRC_BURST_RADIUS, 10.5, 
                PSYS_SRC_BURST_SPEED_MIN, 0.0, 
                PSYS_SRC_BURST_SPEED_MAX, 0.1, 
                PSYS_SRC_ANGLE_BEGIN, 0*DEG_TO_RAD, 
                PSYS_SRC_ANGLE_END, 45*DEG_TO_RAD, 
                PSYS_SRC_OMEGA, <0,0,0>, 
                PSYS_PART_FLAGS, ( 0 
                  | PSYS_PART_INTERP_COLOR_MASK 
                  | PSYS_PART_INTERP_SCALE_MASK 
                  | PSYS_PART_EMISSIVE_MASK 
                  | PSYS_PART_WIND_MASK )
            ]);
    }
}