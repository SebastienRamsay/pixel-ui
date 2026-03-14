--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local PANEL = {}

AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "Color", "Color")
AccessorFunc(PANEL, "CenterItems", "CenterItems", FORCE_BOOL)

PIXEL.RegisterFont("UI.NavbarItem", "Open Sans SemiBold", 22)

function PANEL:Init()
    self:SetName("N/A")
    self:SetColor(PIXEL.Colors.Primary)

    self.NormalCol = PIXEL.Colors.PrimaryText
    self.HoverCol = PIXEL.Colors.SecondaryText

    self.TextCol = PIXEL.CopyColor(self.NormalCol)
    self.Font = "UI.NavbarItem"
    self.CenterItems = false
end

function PANEL:GetItemSize()
    PIXEL.SetFont(self.Font)
    return PIXEL.GetTextSize(self:GetName())
end

function PANEL:Paint(w, h)
    local textCol = self.NormalCol

    if self:IsHovered() then
        textCol = self.HoverCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = PIXEL.LerpColor(animTime, self.TextCol, textCol)

    PIXEL.DrawSimpleText(self:GetName(), self.Font, w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.NavbarItem", PANEL, "PIXEL.Button")

PANEL = {}

AccessorFunc(PANEL, "CenterItems", "CenterItems", FORCE_BOOL)

function PANEL:Init()
    self.Items = {}
    self.CenterItems = false

    self.SelectionX = 0
    self.SelectionW = 0
    self.SelectionColor = Color(0, 0, 0)

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 10)
end

function PANEL:AddItem(id, name, doClick, order, color)
    local btn = vgui.Create("PIXEL.NavbarItem", self)

    btn.Font = self.Font or "UI.NavbarItem"
    btn:SetName(name:upper())
    btn.Order = order or table.Count(self.Items) + 1
    btn:SetColor((IsColor(color) and color) or PIXEL.Colors.Primary)

    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn
end

function PANEL:RemoveItem(id)
    local item = self.Items[id]
    if not item then return end

    item:Remove()
    self.Items[id] = nil

    if self.SelectedItem != id then return end
    self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
    local item = self.Items[id]
    if not item then return end

    if self.SelectedItem and self.SelectedItem == id then return end
    self.SelectedItem = id

    for k,v in pairs(self.Items) do
        v:SetToggle(false)
    end

    item:SetToggle(true)
    item.Function(item)
end

function PANEL:PerformLayout(w, h)
    local totalWidth = 0
    local items = {}

    for _, v in pairs(self.Items) do
        local itemW = v:GetItemSize() + PIXEL.Scale(30)
        table.insert(items, {panel = v, width = itemW, order = v.Order})
    end

    table.sort(items, function(a, b)
        return a.order < b.order
    end)

    for _, data in ipairs(items) do
        totalWidth = totalWidth + data.width
    end

    local startX = 0
    if self.CenterItems then
        startX = (w - totalWidth) * 0.5
    end

    local x = startX

    for _, data in ipairs(items) do
        local v = data.panel
        local itemW = data.width

        v:Dock(NODOCK)
        v:SetPos(x, 0)
        v:SetSize(itemW, h)

        x = x + itemW
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.BackgroundCol)
    surface.DrawRect(0, 0, w, h)

    if not self.SelectedItem then
        self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionW = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionColor = PIXEL.LerpColor(FrameTime() * 10, self.SelectionColor, PIXEL.Colors.Primary)
        return
    end

    local selectedItem = self.Items[self.SelectedItem]
    self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, selectedItem.x)
    self.SelectionW = Lerp(FrameTime() * 10, self.SelectionW, selectedItem:GetWide())
    self.SelectionColor = PIXEL.LerpColor(FrameTime() * 10, self.SelectionColor, selectedItem:GetColor())

    local selectorH = PIXEL.Scale(6)
    surface.SetDrawColor(self.SelectionColor)
    surface.DrawRect(self.SelectionX + 2, h - selectorH, self.SelectionW - 4, selectorH / 2)
end

vgui.Register("PIXEL.Navbar", PANEL, "Panel")