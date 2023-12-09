return {
    create = function(name, parent, properties)
        local instance = Instance.new(name)
        if properties then
            for property_name, value in pairs(properties) do
                if property_name == "Attributes" then
                    for attribute_name, attribute_value in pairs(value) do
                        instance:SetAttribute(attribute_name, attribute_value)
                    end
                end
                instance[property_name] = value
            end
        end
        instance.Parent = parent
        return instance
    end,
    updateProperties = function(instance, properties)
        for property_name, value in pairs(properties) do
            if property_name == "Attributes" then
                for attribute_name, attribute_value in pairs(value) do
                    instance:SetAttribute(attribute_name, attribute_value)
                end
            end
            instance[property_name] = value
        end
    end
}