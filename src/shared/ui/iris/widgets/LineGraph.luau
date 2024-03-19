local LineGraph = {
    hasState = false,
    hasChildren = false,
    Args = {
        ["Data"] = 1,
        ["Resolution"] = 2
    },
    Events = {
        ["hovered"] = {
        }
    },
    Generate = function(thisWidget)
        local graphDisplay = Instance.new("ImageLabel")
        graphDisplay.Name = "GraphDisplay"
        graphDisplay.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        graphDisplay.BackgroundTransparency = 1
        graphDisplay.AutomaticSize = Enum.AutomaticSize.XY
        graphDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        graphDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        graphDisplay.BorderSizePixel = 0
        graphDisplay.LayoutOrder = 10000
        graphDisplay.ZIndex = 10000
        graphDisplay.Size = UDim2.fromScale(0.2, 0.075)

        local gradient = Instance.new("UIGradient", graphDisplay)
        gradient.Name = "LineColor"

        if not graphDisplay:FindFirstChild("Graph") then
            local graph = Instance.new("EditableImage")
            graph.Name = "Graph"
            graph.Parent = graphDisplay
            graph.Size = Vector2.new(57, 18)
        end

        return graphDisplay
    end,
    Update = function(thisWidget)
        print("updating graph...")
        local graph = thisWidget.Instance.Graph :: EditableImage
        local graph_data = thisWidget.arguments.Data

        local pixel_data = {}
        for i = 1, graph.Size.X * graph.Size.Y do
            table.insert(pixel_data, 0)
            table.insert(pixel_data, 0)
            table.insert(pixel_data, 0)
            table.insert(pixel_data, 0)
        end

        graph:WritePixels(Vector2.new(), graph.Size, pixel_data)

        if #graph_data < 3 then return end
    
        -- grab sizing data from 'data' argument
    
        local min_data_value = 0
        local max_data_value = 0
        local data_range
    
        for index, point_data in graph_data do
            min_data_value = math.min(min_data_value, point_data)
            max_data_value = math.max(max_data_value, point_data)
        end
    
        local datapoint_x_scalar = graph.Size.X / #graph_data
        local datapoint_y_scalar = graph.Size.Y / max_data_value
    
        for i = 1, #graph_data - 1 do
            local p1 = Vector2.new(math.clamp(math.floor(i * datapoint_x_scalar + 0.5), 0, graph.Size.X - 1), math.clamp(math.floor(graph_data[i] * datapoint_y_scalar + 0.5), 0, graph.Size.Y - 1))
            local p2 = Vector2.new(math.clamp(math.floor((i+1) * datapoint_x_scalar + 0.5), 0, graph.Size.X - 1), math.clamp(math.floor(graph_data[i+1] * datapoint_y_scalar + 0.5), 0, graph.Size.Y - 1))
            graph:DrawLine(p1, p2, Color3.new(0.8, 0.9, 1), 0)
        end

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}


return LineGraph