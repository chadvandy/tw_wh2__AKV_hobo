local lm = _G._LICHEMANAGER
local UTILITY = lm._UTILITY
local LOG = lm._LOG

--v function(turns: number, is_locked: boolean, button_number: string?)
local function set(turns, is_locked, button_number)
    local root = core:get_ui_root()

    local panel = find_uicomponent(root, "settlement_captured")
    local parent = find_uicomponent(panel, "button_parent")

    root:CreateComponent("turnsRuined", "ui/templates/buildingframe")
    root:CreateComponent("templateOption", "ui/campaign ui/settlement_captured")

    local turn_center = find_uicomponent(root, "turnsRuined", "turns_center")
    local option = find_uicomponent(root, "templateOption", "button_parent", "template_button_occupy")

    panel:Adopt(turn_center:Address())
    parent:Adopt(option:Address())


    --[[ Occupy Button Additions!]]

    local option_button = find_uicomponent(option, "option_button")

    local state = "active"
    if is_locked then
        state = "inactive"
    end

    option_button:SetTooltipText("{{tr:kemmler_ruins_option_button_tt_"..state.."}}", true)
    option_button:SetState(state)

    local option_text = find_uicomponent(option, "option_button", "dy_option")
    option_text:SetStateText("{{tr:kemmler_ruins_option_button_text}}")

    local picture = find_uicomponent(option, "picture_parent", "dy_pic")
    picture:SetImagePath("ui/campaign ui/settlement_captured_pics/AK_hobo_ruin_stuff.png")

    local replen = find_uicomponent(option, "frame", "icon_parent", "dy_replenish")
    local replen_icon = find_uicomponent(replen, "icon")
    replen:SetTooltipText("{{tr:kemmler_ruins_replen_tt}}", false)
    replen:SetStateText("100%")

    local do_nothing_uic = find_uicomponent(parent, "915")
    local defile_barrow_uic = find_uicomponent(parent, "template_button_occupy")

    local mX, mY = do_nothing_uic:Position()
    local nX, nY = defile_barrow_uic:Position()

    turn_center:SetVisible(true)
    turn_center:SetStateText(tostring(turns))

    if button_number then
        panel:Resize(option:Width() * 3 + option:Width() / 3, panel:Height())

        local extra_button = find_uicomponent(parent, button_number)

        do_nothing_uic:MoveTo(mX - option:Width(), mY)
        defile_barrow_uic:MoveTo(mX, mY)
        extra_button:MoveTo(nX, nY)
    else
        panel:Resize(option:Width() * 2 + option:Width() / 3, panel:Height())
    end

    local pX, pY = panel:Position()
    local pW, pH = panel:Width(), panel:Height()
    local tW, tH = turn_center:Width(), turn_center:Height()

    turn_center:MoveTo(pX + (pW - (tW)), pY + (tH / 3))

    local icons = find_uicomponent(option, "frame", "icon_parent")

    local kill1 = find_uicomponent(root, "turnsRuined")
    local kill2 = find_uicomponent(root, "templateOption")
    local kill3 = find_uicomponent(icons, "dy_slaves")
    local kill4 = find_uicomponent(icons, "dy_settlers")
    local kill5 = find_uicomponent(icons, "dy_conquest")
    local kill6 = find_uicomponent(icons, "dy_public_order")
    local kill7 = find_uicomponent(option, "skaven_settlement_level")
    local kill8 = find_uicomponent(icons, "dy_income")
    local kill9 = find_uicomponent(icons, "icon_vassals")
    local kill10 = find_uicomponent(icons, "template_effect_icon")
    local kill11 = find_uicomponent(icons, "template_pooled_resource")


    local die = {kill1, kill2, kill3, kill4, kill5, kill6, kill7, kill8, kill9, kill10, kill11}--:vector<CA_UIC>
    UTILITY.remove_component(die)

end

return { set = set }