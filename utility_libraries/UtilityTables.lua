return {

    -- rotation cframe that orients given orientation face frontward
    ORIENTATION_FACE_TO_FRONT = {
        [Enum.NormalId.Front] = CFrame.Angles(0, 0, 0);
        [Enum.NormalId.Back] = CFrame.Angles(0, math.rad(180), 0);
        [Enum.NormalId.Left] = CFrame.Angles(0, math.rad(90), 0);
        [Enum.NormalId.Right] = CFrame.Angles(0, math.rad(-90), 0);
        [Enum.NormalId.Top] = CFrame.Angles(math.rad(-90), 0, 0);
        [Enum.NormalId.Bottom] = CFrame.Angles(math.rad(90), 0, 0);
    };

    -- rotation cframe that orients front to given orientation face
    FRONT_TO_ORIENTATION_FACE = {
        [Enum.NormalId.Front] = CFrame.Angles(0, 0, 0);
        [Enum.NormalId.Back] = CFrame.Angles(0, math.rad(180), 0);
        [Enum.NormalId.Left] = CFrame.Angles(0, math.rad(-90), 0);
        [Enum.NormalId.Right] = CFrame.Angles(0, math.rad(90), 0);
        [Enum.NormalId.Top] = CFrame.Angles(math.rad(90), 0, 0);
        [Enum.NormalId.Bottom] = CFrame.Angles(math.rad(-90), 0, 0);
    };

    -- rotation cframe that orients given root face frontward and parallel to the ground
    ROOT_FACE_TO_FRONT = {
        [Enum.NormalId.Front] = CFrame.Angles(math.rad(-90), 0, 0);
        [Enum.NormalId.Back] = CFrame.Angles(math.rad(90), 0, 0);
        [Enum.NormalId.Left] = CFrame.Angles(0, 0, math.rad(-90));
        [Enum.NormalId.Right] = CFrame.Angles(0, 0, math.rad(90));
        [Enum.NormalId.Top] = CFrame.Angles(0, 0, math.rad(180));
        [Enum.NormalId.Bottom] = CFrame.Angles(0, 0, 0);
    };

    -- localized vector directions facing outward depending on surface normal
    FACE_NORMALS = {
        [Enum.NormalId.Front] = Vector3.new(0, 0, 1);
        [Enum.NormalId.Back] = Vector3.new(0, 0, -1);
        [Enum.NormalId.Left] = Vector3.new(-1, 0, 0);
        [Enum.NormalId.Right] = Vector3.new(1, 0, 0);
        [Enum.NormalId.Top] = Vector3.new(0, 1, 0);
        [Enum.NormalId.Bottom] = Vector3.new(0, -1, 0);
    };

    -- gets opposite root face
    -- TODO: change name as this table can be used for more than root faces (orientation faces, part sides, etc.)
    INVERTED_ROOT_FACE = {
        [Enum.NormalId.Front] = Enum.NormalId.Back;
        [Enum.NormalId.Back] = Enum.NormalId.Front;
        [Enum.NormalId.Left] = Enum.NormalId.Right;
        [Enum.NormalId.Right] = Enum.NormalId.Left;
        [Enum.NormalId.Top] = Enum.NormalId.Bottom;
        [Enum.NormalId.Bottom] = Enum.NormalId.Top;
    }
}

