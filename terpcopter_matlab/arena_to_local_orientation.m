function yaw_pixhawk = arena_to_local_orientation(yaw_arena, yaw_offset)
    pitch = 0; roll = 0;
    yaw_pixhawk = yaw_arena + yaw_offset;
end
