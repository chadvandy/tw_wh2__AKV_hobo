local lm = _G._LICHEMANAGER
local UTILITY = lm._UTILITY

--v function(key: string, text: string)
local function new_unit_card(key, text)
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end
    
    local parchment = find_uicomponent(frame, "parchment")

    -- create the new UIC
    parchment:CreateComponent(key.."_unit_card", "ui/templates/portrait_card")
    local unit_card = find_uicomponent(parchment, key.."_unit_card")

    -- hide the rank thingy
    find_uicomponent(unit_card, "rank"):SetVisible(false)

    --change the name text, and add the new unit card image
    local name = find_uicomponent(unit_card, "char_name", "name_tx")
    name:SetStateText(text)
    unit_card:SetImagePath("ui/units/icons/" .. key .. ".png")
    core:add_listener(
        "LicheLegionCardOnClick",
        "ComponentLClickUp",
        function(context)
            return context.string == key .. "_unit_card"
        end,
        function(context)
            local ok, err = pcall(function()
                lm:set_selected_legion(key)
            end)
            if not ok then lm:error(err) end
        end,
        true
    )
end

--[[
--v function(key: string)
local function kill_existing_uic(key)
    local existing_component = Util.getComponentWithName(key)
    --# assume existing_component: TEXT
    if not not existing_component then
        Util.unregisterComponent(key)
        if not not existing_component.uic and is_uicomponent(existing_component.uic) then
            utility.removeComponent(existing_component.uic)
        end
    end
end]]

--v function(key: string) --> string
local function key_to_text(key)
    local units = {
        ["AK_hobo_ror_doomed_legion"] = "Doomed Legion",
        ["AK_hobo_ror_caged"] = "The Caged",
        ["AK_hobo_ror_storm"] = "Guardians of Medhe",
        ["AK_hobo_ror_wight_knights"] = "The Wight Knights",
        ["AK_hobo_ror_beast"] = "Beast of Cailledh",
        ["AK_hobo_ror_skulls"] = "Skulls of Geistenmund",
        ["AK_hobo_ror_spider"] = "Terror of the Lichemaster",
        ["AK_hobo_ror_jacsen"] = "Mikeal Jacsen"
    }--: map<string, string>

    local text = units[key]
    return text
end

    
local function position_and_resize_components()
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end

    local parchment = find_uicomponent(frame, "parchment")

    -- first column, 2 3
    local beast_card = find_uicomponent(parchment, "AK_hobo_ror_beast_unit_card")
    local caged_card = find_uicomponent(parchment, "AK_hobo_ror_caged_unit_card")

    -- second column, 2 3
    local doomed_legion_card = find_uicomponent(parchment, "AK_hobo_ror_doomed_legion_unit_card")
    local guardians_card = find_uicomponent(parchment, "AK_hobo_ror_storm_unit_card")

    -- third column, 2 3
    local jacsen_card = find_uicomponent(parchment, "AK_hobo_ror_jacsen_unit_card")
    local skulls_card = find_uicomponent(parchment, "AK_hobo_ror_skulls_unit_card")

    -- fourth column, 2 3
    local terror_card = find_uicomponent(parchment, "AK_hobo_ror_spider_unit_card")
    local wight_card = find_uicomponent(parchment, "AK_hobo_ror_wight_knights_unit_card")

    -- width stuff
    local parchment_width = parchment:Width()
    local unit_card_width = doomed_legion_card:Width()
    local total_gap_width = parchment_width - unit_card_width*4
    local gap_width = total_gap_width/5

    -- height stuff
    local parchment_height = parchment:Height()
    local unit_card_height = doomed_legion_card:Height()
    local total_gap_height = parchment_height - unit_card_height*3
    local gap_height = total_gap_height/4
    
    local parchment_x, parchment_y = parchment:Position()

    -- set up columns and rows
    local column1 = parchment_x + gap_width
    local column2 = parchment_x + unit_card_width + gap_width*2
    local column3 = parchment_x + unit_card_width*2 + gap_width*3
    local column4 = parchment_x + unit_card_width*3 + gap_width*4

    local row1 = parchment_y + gap_height
    local row2 = parchment_y + unit_card_height + gap_height*2
    local row3 = parchment_y + unit_card_height*2 + gap_height*3

    -- move 'em!
    beast_card:MoveTo(column1, row2)
    caged_card:MoveTo(column1, row3)

    doomed_legion_card:MoveTo(column2, row2)
    guardians_card:MoveTo(column2, row3)

    jacsen_card:MoveTo(column3, row2)
    skulls_card:MoveTo(column3, row3)

    terror_card:MoveTo(column4, row2)
    wight_card:MoveTo(column4, row3)

    -- set up for the widget box positioning
    local widget_main_box = find_uicomponent(parchment, "widget_main_box")
    local widget_main_box_border = find_uicomponent(parchment, "widget_main_box_border")
    local widget_main_box_text = find_uicomponent(parchment, "widget_main_box_text")

    local widget_text_box = find_uicomponent(parchment, "widget_text_box")
    local widget_text_box_border = find_uicomponent(parchment, "widget_text_box_border")
    local widget_text_box_text = find_uicomponent(parchment, "widget_text_box_text")

    local resize_width, resize_height = parchment_width / 2, widget_main_box:Height() * 1.4

    widget_main_box:SetCanResizeHeight(true)
    widget_main_box:SetCanResizeWidth(true)
    widget_main_box:Resize(resize_width, resize_height)
    widget_main_box:SetCanResizeHeight(false)
    widget_main_box:SetCanResizeWidth(false)

    widget_main_box_border:SetCanResizeHeight(true)
    widget_main_box_border:SetCanResizeWidth(true)
    widget_main_box_border:Resize(resize_width, resize_height)
    widget_main_box_border:SetCanResizeHeight(false)
    widget_main_box_border:SetCanResizeWidth(false)

    widget_text_box:SetCanResizeHeight(true)
    widget_text_box:SetCanResizeWidth(true)
    widget_text_box:Resize(resize_width, resize_height)
    widget_text_box:SetCanResizeHeight(false)
    widget_text_box:SetCanResizeWidth(false)

    widget_text_box_border:SetCanResizeHeight(true)
    widget_text_box_border:SetCanResizeWidth(true)
    widget_text_box_border:Resize(resize_width, resize_height)
    widget_text_box_border:SetCanResizeHeight(false)
    widget_text_box_border:SetCanResizeWidth(false)

    local parchment_x, parchment_y = parchment:Position()
    local parchment_width = parchment:Width()

    local widget_box_width, widget_box_height = widget_main_box:Bounds()
    local parchment_center = parchment_x + parchment_width/2

    local move_x, move_y = parchment_center, row1

    widget_main_box:MoveTo(move_x, move_y)
    widget_main_box_border:MoveTo(move_x, move_y)

    widget_text_box:MoveTo(move_x - widget_text_box:Width(), move_y)
    widget_text_box_border:MoveTo(move_x - widget_text_box:Width(), move_y)

    do
        local text_width, text_height = widget_main_box_text:Bounds()
        widget_main_box_text:ResizeTextResizingComponentToInitialSize(text_width, text_height)
        text_width, text_height = widget_main_box_text:TextDimensions()

        local text_move_x, text_move_y = move_x + (widget_box_width/2 - text_width/2), move_y - text_height * 1.2
        widget_main_box_text:MoveTo(text_move_x, text_move_y)
    end
    do
        local text_width, text_height = widget_text_box_text:Bounds()
        widget_text_box_text:ResizeTextResizingComponentToInitialSize(text_width, text_height)
        text_width, text_height = widget_text_box_text:TextDimensions()

        local text_move_x, text_move_y = (move_x - widget_text_box:Width()) + (widget_text_box:Width()/2 - text_width/2), move_y - text_height * 1.2
        widget_text_box_text:MoveTo(text_move_x, text_move_y)
    end
end

local function create_new_widget_box()
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end

    local parchment = find_uicomponent(frame, "parchment")

    -- right box with selected unit & spawn button & np cost
    parchment:CreateComponent("widget_main_box", "ui/kemmler/custom_image")
    local widget_main_box = find_uicomponent(parchment, "widget_main_box")
    widget_main_box:SetState("custom_state_1")
    widget_main_box:SetImagePath("ui/skins/default/panel_leather_tile_blue.png")

    parchment:CreateComponent("widget_main_box_border", "ui/kemmler/custom_image")
    local widget_main_box_border = find_uicomponent(parchment, "widget_main_box_border")
    widget_main_box_border:SetState("custom_state_1")
    widget_main_box_border:SetImagePath("ui/skins/default/panel_leather_frame_blue.png")

    parchment:CreateComponent("widget_main_box_text", "ui/vandy_lib/black_text")
    local widget_main_box_text = find_uicomponent(parchment, "widget_main_box_text")
    widget_main_box_text:SetStateText("Selected Legion")

    -- left text box with the ui_tr's
    parchment:CreateComponent("widget_text_box", "ui/kemmler/custom_image")
    local widget_text_box = find_uicomponent(parchment, "widget_text_box")
    widget_text_box:SetState("custom_state_1")
    widget_text_box:SetImagePath("ui/skins/default/panel_leather_tile_blue.png")

    parchment:CreateComponent("widget_text_box_border", "ui/kemmler/custom_image")
    local widget_text_box_border = find_uicomponent(parchment, "widget_text_box_border")
    widget_text_box_border:SetState("custom_state_1")
    widget_text_box_border:SetImagePath("ui/skins/default/panel_leather_frame_blue.png")

    parchment:CreateComponent("widget_text_box_text", "ui/vandy_lib/black_text")
    local widget_text_box_text = find_uicomponent(parchment, "widget_text_box_text")
    widget_text_box_text:SetStateText("Legion Details")
end


local function initialize_widget_text_box_components()
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end

    local parchment = find_uicomponent(frame, "parchment")
    local widget_text_box = find_uicomponent(parchment, "widget_text_box")

    --v function(key: string)
    local function set_text_box(key)
        local parchment = find_uicomponent(core:get_ui_root(), "legions_of_undeath", "parchment")
        local widget_text_box = find_uicomponent(parchment, "widget_text_box")

        local text2 = key.."_quickie"
        local text3 = "" --: string

        if key == "AK_hobo_ror_doomed_legion" or key == "AK_hobo_ror_wight_knights" or key == "AK_hobo_ror_jacsen" or key == "AK_hobo_ror_skulls" or key == "AK_hobo_ror_spider" then
            text3 = "AK_hobo_units_risen"
        elseif key == "AK_hobo_ror_caged" or key == "AK_hobo_ror_storm" or key == "AK_hobo_ror_beast" then
            text3 = "AK_hobo_units_barrow"
        end

        parchment:CreateComponent("legions_of_undeath_middle_text", "ui/vandy_lib/black_text")
        local middle_text = find_uicomponent(parchment, "legions_of_undeath_middle_text")
        middle_text:SetStateText("[[col:alliance_neutral]]{{tr:"..text2.."}}[[/col]]")

        parchment:CreateComponent("legions_of_undeath_bottom_text", "ui/vandy_lib/black_text")
        local bottom_text = find_uicomponent(parchment, "legions_of_undeath_bottom_text")
        bottom_text:SetStateText("[[col:alliance_neutral]]{{tr:"..text3.."}}[[/col]]")


        local text_width, text_height = middle_text:Bounds()
        local box_width, box_height = widget_text_box:Bounds()
        local box_x, box_y = widget_text_box:Position()

        local total_gap_height = box_height - (text_height*2)
        local gap_height = total_gap_height / 3

        local row1 = box_y + gap_height
        local row2 = box_y + text_height + gap_height*2

        local column1 = box_x + (box_width * 0.1)

        middle_text:SetCanResizeHeight(true)
        middle_text:SetCanResizeWidth(true)
        middle_text:Resize(box_width * 0.85, text_height)
        middle_text:SetCanResizeHeight(false)
        middle_text:SetCanResizeWidth(false)

        bottom_text:SetCanResizeHeight(true)
        bottom_text:SetCanResizeWidth(true)
        bottom_text:Resize(box_width * 0.85, text_height)
        bottom_text:SetCanResizeHeight(false)
        bottom_text:SetCanResizeWidth(false)

        middle_text:ResizeTextResizingComponentToInitialSize(box_width * 0.85, text_height)
        bottom_text:ResizeTextResizingComponentToInitialSize(box_width * 0.85, text_height)

        middle_text:MoveTo(column1, row1)
        bottom_text:MoveTo(column1, row2)
    end

    core:add_listener(
        "LichemasterLegionSelectedLeftBox",
        "LichemasterLegionSelected",
        true,
        function(context)
            set_text_box(context.string)
        end,
        true
    )
end

local function initialize_widget_main_box_components()
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end

    local parchment = find_uicomponent(frame, "parchment")
    local widget_main_box = find_uicomponent(parchment, "widget_main_box")

    widget_main_box:CreateComponent("lichemaster_spawn_button", "ui/templates/square_large_text_button")
    local spawn_button = find_uicomponent(widget_main_box, "lichemaster_spawn_button")

    local spawn_button_text = UIComponent(spawn_button:Find("button_txt"))

    spawn_button:SetState("inactive")
    spawn_button:SetTooltipText("Select a unit to spawn", true)
    spawn_button_text:SetStateText("Spawn")

    widget_main_box:CreateComponent("np_cost_icon", "ui/kemmler/custom_image")
    local np_cost_icon = find_uicomponent(widget_main_box, "np_cost_icon")
    np_cost_icon:SetState("custom_state_1")
    np_cost_icon:SetInteractive(true)
    np_cost_icon:SetImagePath("ui/kemmler/AK_hobo_necropowa_lou_cost.png")
    np_cost_icon:SetTooltipText("Necromantic Power", true)

    np_cost_icon:SetCanResizeHeight(true)
    np_cost_icon:SetCanResizeWidth(true)
    np_cost_icon:Resize(np_cost_icon:Width() * 0.5, np_cost_icon:Height() * 0.5)
    np_cost_icon:SetCanResizeHeight(false)
    np_cost_icon:SetCanResizeWidth(false)

    local box_x = 0  --: number
    local box_y = 0 --:number
    local box_width = 0 --: number
    local box_height = 0  --: number

    --v function(text: string)
    local function set_selected_text(text)
        local widget_main_box = find_uicomponent(core:get_ui_root(), "legions_of_undeath", "parchment", "widget_main_box")
        local existing_text = find_uicomponent(widget_main_box, "legions_of_undeath_selected_text")
        if existing_text then
            UTILITY.remove_component(existing_text)
        end

        widget_main_box:CreateComponent("legions_of_undeath_selected_text", "ui/vandy_lib/black_text")
        local new_text = find_uicomponent(widget_main_box, "legions_of_undeath_selected_text")
        new_text:SetStateText("[[col:alliance_neutral]]"..text.."[[/col]]")
              
        box_x, box_y = widget_main_box:Position()
        box_width, box_height = widget_main_box:Width(), widget_main_box:Height()
        local text_width, text_height = new_text:TextDimensions()

        local gap = box_width/2 - text_width/2
        local spawn_button_height = spawn_button:Height()
        new_text:MoveTo(box_x + gap, box_y + spawn_button_height * 0.4)
    end

    --v function(state: string)
    local function set_button_state(state)
        local spawn_button_uic = find_uicomponent(core:get_ui_root(), "legions_of_undeath", "parchment", "widget_main_box", "lichemaster_spawn_button")
        if state == "active" then
            spawn_button_uic:SetState("active")
            spawn_button_uic:SetStateText("Spawn")
            spawn_button_uic:SetTooltipText("Spawn selected Legion", true)
            core:add_listener(
                "LichemasterSpawnLegion",
                "ComponentLClickUp",
                function(context)
                    return context.string == "lichemaster_spawn_button"
                end,
                function(context)
                    local selected_cqi = lm._characterSelected
                    local key = lm._selected_legion
                    if key == "" then
                        return
                    end
                    if not selected_cqi or not key then
                        lm:error("Tried to spawn an RoR, but no selected CQI or selected legion was found. Cancelling the input.")
                    else
                        if lm:is_regiment_unlocked(key) then
                            lm:spawn_ror_for_character(selected_cqi, key)
                            local spawn_button_uic = find_uicomponent(core:get_ui_root(), "legions_of_undeath", "parchment", "widget_main_box", "lichemaster_spawn_button")
                            if not spawn_button_uic then
                                lm:error("In ror.lua, spawnButtonUIC is not found. WHY?")
                            else
                                spawn_button_uic:SetState("inactive")
                                spawn_button_uic:SetTooltipText("Must first unlock Legion by Defiling Barrows", true)
                            end
                        end
                    end
                end,
                false
            )
        elseif state == "inactive" then
            spawn_button_uic:SetState("inactive")
            spawn_button_uic:SetTooltipText("Must first unlock Legion by Defiling Barrows", true)
            core:remove_listener("LichemasterSpawnLegion")
        elseif state == "broke" then
            spawn_button_uic:SetState("inactive")
            spawn_button_uic:SetTooltipText("Not enough Necromantic Power!", true)
            core:remove_listener("LichemasterSpawnLegion")
        end
    end

    set_selected_text("Please Select a Unit Below")

    spawn_button:SetCanResizeHeight(true)
    spawn_button:SetCanResizeWidth(true)
    spawn_button:Resize(spawn_button:Width() * 0.6, spawn_button:Height())
    spawn_button:SetCanResizeHeight(false)
    spawn_button:SetCanResizeWidth(false)

    local spawn_button_width, spawn_button_height = spawn_button:Bounds()
    local gap = box_width/2 - spawn_button_width/2
    lm:log("BOX SHTUFF")
    lm:log("POS: "..box_x ..",".. box_y)
    lm:log("DIMENSIONS: "..box_width..","..box_height)
    spawn_button:MoveTo(box_x + gap, box_y + box_height - (spawn_button_height * 1.2))

    local icon_width, icon_height = np_cost_icon:Bounds()
    local spawn_button_x, spawn_button_y = spawn_button:Position()
    np_cost_icon:MoveTo(spawn_button_x - icon_width * 2, spawn_button_y - np_cost_icon:Height() * 0.15)

    core:add_listener(
        "LichemasterLegionSelected",
        "LichemasterLegionSelected",
        true,
        function(context)
            local text = key_to_text(context.string)
            if not text then
                lm:error("LichemasterLegionSelected triggered, but the text returned blank?!?")
            else
                set_selected_text(text)
                if lm:is_regiment_unlocked(context.string) and lm:get_necropower() >= 5 then
                    set_button_state("active")
                elseif lm:is_regiment_unlocked(context.string) and not (lm:get_necropower() >= 5) then
                    set_button_state("broke")
                else
                    set_button_state("inactive")
                end
            end
        end,
        true
    )
end

local function populate_panel()
    local root = core:get_ui_root()
    local ui_panel_name = "legions_of_undeath"
    local frame = find_uicomponent(root, ui_panel_name)

    if not frame then
        lm:error("Legions of Undeath panel called, frame not found! Booooo!")
        return
    end

    local parchment = find_uicomponent(frame, "parchment")

    local units = {
        ["AK_hobo_ror_doomed_legion"] = "Doomed Legion",
        ["AK_hobo_ror_caged"] = "The Caged",
        ["AK_hobo_ror_storm"] = "Guardians of Medhe",
        ["AK_hobo_ror_wight_knights"] = "The Wight Knights",
        ["AK_hobo_ror_beast"] = "Beast of Cailledh",
        ["AK_hobo_ror_skulls"] = "Skulls of Geistenmund",
        ["AK_hobo_ror_spider"] = "Terror of the Lichemaster",
        ["AK_hobo_ror_jacsen"] = "Mikeal Jacsen"
    }--: map<string, string>

    local unit_cards = {}

    -- create a new unit card for all of the above!
    for key, text in pairs(units) do
        new_unit_card(key, text)
        --table.insert(unit_cards, find_uicomponent(parchment, key.."_unit_card"))
    end

    -- export some operations to external functions
    create_new_widget_box()

    position_and_resize_components()

    initialize_widget_main_box_components()

    initialize_widget_text_box_components()
end

local function create_panel()
    local ui_panel_name = "legions_of_undeath"
    local root = core:get_ui_root()

    local layout = find_uicomponent(root, "layout")
    if not not layout then
        layout:SetVisible(false)
    else
        lm:error("Create Panel called, layout not found? ABORT.")
        return
    end

    -- refresh the UI; some bugginess right now with editing an already-existing panel, so I destroy it and remake it. I'd like to fix that.
    -- TODO fix that
    local existing_frame = find_uicomponent(root, ui_panel_name)
    if not not existing_frame then
        UTILITY.remove_component(existing_frame)
    end

    -- create the panel UIC
    local panel = core:get_or_create_component(ui_panel_name, "ui/campaign ui/objectives_screen", root)

    local kill1 = UIComponent(panel:Find("TabGroup"))
    local kill2 = UIComponent(panel:Find("button_info"))
    UTILITY.remove_component({kill1, kill2})

    -- resize the panel slightly, center it on the screen
    panel:SetCanResizeHeight(true)
    panel:SetCanResizeWidth(true)
    panel:Resize(panel:Width() * 1.5, panel:Height() * 1.5)
    panel:SetCanResizeHeight(false)
    panel:SetCanResizeWidth(false)

    local sX, sY = core:get_screen_resolution()
    local fW, fH = panel:Bounds()
    panel:MoveTo(sX/2 - fW/2, sY/2 - fH/2)

    local parchment = find_uicomponent(panel, "parchment")

    -- assure that the parchment is properly oriented within the panel
    -- TODO figure out why da heck it's bugging out like it is
    local fX, fY = panel:Position()
    local fW, fH = panel:Bounds()

    parchment:SetCanResizeHeight(true)
    parchment:SetCanResizeWidth(true)
    parchment:Resize(fW * 0.98, fH * 0.8)
    parchment:SetCanResizeHeight(false)
    parchment:SetCanResizeWidth(false)

    local pW, pH = parchment:Bounds()
    local gapX, gapY = fW - pW, fH - pH

    --parchment:MoveTo(fX + gapX/2, fY + gapY/2)

    -- set the title for the top bar!
    local title = find_uicomponent(panel, "panel_title", "tx_objectives")
    title:SetStateText("Legions of Undeath")

    -- create the close button and give it functionality
    panel:CreateComponent(ui_panel_name.."_close_button", "ui/templates/round_medium_button")
    core:add_listener(
        "LicheRorCloseButton",
        "ComponentLClickUp",
        function(context)
            return context.string == "legions_of_undeath_close_button"
        end,
        function(context)
            local layout = find_uicomponent(core:get_ui_root(), "layout")
            if not not layout then
                -- make the regular UI stuff visible
                layout:SetVisible(true)
            end
            -- destroy the panel, since setting it visible and unvisible currently does some funky stuff
            UTILITY.remove_component(panel)
        end,
        false
    )

    -- set the close button's image and center it on the bottom of the panel
    local close_button = find_uicomponent(panel, ui_panel_name.."_close_button")
    close_button:SetImagePath("ui/skins/default/icon_check.png")

    local fX, fY = panel:Position()
    local fW, fH = panel:Width(), panel:Height()
    local bW, bH = close_button:Width(), close_button:Height()

    close_button:MoveTo(fX + (fW/2 - bW/2), fY + (fH - bH/2))

    populate_panel()
end

return create_panel