local types = {}

-- Character ------------------------------------

export type CharacterCore = {
    character: Model?,
    humanoid: Humanoid?,
    root: BasePart?,
    
    measurements: {[string]: Vector3 | number},
    character_spawned: any?,-- replace with signal
}

-- character controller data
export type CharacterState = "idle" |
    "walking" |
    "jumping" |
    "freefall" |
    "catching" |
    "grinding" |
    "landing" |
    "dead"


-- Input ----------------------------------------

export type Control = {
    keys: {Enum.KeyCode},
}

export type ControlBinding = {
    control_name: string,
    keys: {Enum.KeyCode}
}

-- Rail -----------------------------------------

export type RailType = "Free" | "Fixed"

export type CurvePoint = {
    _connectedPointIDs: {number}, -- table of curvePoint IDs
    id: number,
    attachment: Attachment
}
export type Curve = {
    _looped: boolean,
    _rootPart: BasePart,
    points: {
        CurvePoint
    }
}

export type Rail = {
    _segments: {BasePart}, -- segments represent the rail mesh. each segment holds a CurvePoint id as an attribute
    _curve: Curve,
    railType: RailType
}


-- Misc. ----------------------------------------

export type RuntimeEventName = "Heartbeat"
| "PreSimulation"
| "PreAnimation"
| "PostSimulation"
| "PostAnimation"
| "PreRender"
| "RenderStepped"
| "Stepped"

return types