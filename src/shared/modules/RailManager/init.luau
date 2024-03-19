local RunService = game:GetService("RunService")

export type Rail = {
    points: {Attachment},
    segments: {BasePart}
}

local RailManager = {
    _rails = {},
    utility = {
        findNearestPoints = function(at: Vector3, points: {Attachment})
            local nearest_attachment_index
            local second_nearest_attachment_index
            
            local closest_mag = math.huge
            local second_closest_mag = math.huge
    
            for index, attachment: Attachment in points do
                local mag = (at - attachment.WorldCFrame.Position).Magnitude
                if mag < closest_mag then
                    second_nearest_attachment_index = nearest_attachment_index
                    second_closest_mag = closest_mag
                    nearest_attachment_index = index
                    closest_mag = mag
                elseif mag < second_closest_mag then
                    second_nearest_attachment_index = index
                    second_closest_mag = mag
                end
            end
            return nearest_attachment_index, second_nearest_attachment_index
        end
    }
}

function RailManager:AddRail(rail: Rail)

    

    local function initializeSegments(segments: {BasePart | Model})
        local segments_by_point = {}
        local output = {}

        local segment_parent = segments[1].Parent

        for _, segment in segments do
            local id = math.min(self.utility.findNearestPoints(segment.Position, rail.points))
            segment:SetAttribute("RailId", #self._rails)
            segment:SetAttribute("PointId", id)

            if not segments_by_point[id] then
                segments_by_point[id] = {}
            end
            table.insert(segments_by_point[id], segment)
        end

        for id = 1, #segments_by_point do
            
            if not segments_by_point[id] then continue end
            
            local full_segment

            if #segments_by_point[id] > 1 then
                full_segment = Instance.new("Model")
            end
            
            for _, segment in segments_by_point[id] do
                if full_segment then
                    segment.Parent = full_segment
                else
                    full_segment = segment
                end
            end

            -- organize
            if full_segment then
                full_segment.Name = tostring(id)
                full_segment.Parent = segment_parent
                table.insert(output, id, full_segment)
            end
        end
        return output
    end

    -- validate rail variable, modify if needed
    assert(rail.points and rail.segments, "[RailManager:AddRail] 'rail' argument not valid")

    self._rails[#self._rails+1] = rail
    rail.segments = initializeSegments(rail.segments)

    print("Rail created!")
end

function RailManager:GetRailFromId(id: number)
    if self._rails[id] then return self._rails[id] end
end

return RailManager