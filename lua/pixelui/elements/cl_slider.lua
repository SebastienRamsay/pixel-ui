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

AccessorFunc(PANEL, "Min", "Min", FORCE_NUMBER)
AccessorFunc(PANEL, "Max", "Max", FORCE_NUMBER)
AccessorFunc(PANEL, "Decimals", "Decimals", FORCE_NUMBER)

function PANEL:Init()
    self.Fraction = 0
    self:SetDecimals(0) -- default = integers
    self:SetMin(0)
    self:SetMax(1)

    self.Grip = vgui.Create("PIXEL.ImageButton", self)
    self.Grip:NoClipping(false)

    self.Grip:SetImageURL("https://pixel-cdn.lythium.dev/i/g6e8z4pz")
    self.Grip:SetNormalColor(PIXEL.CopyColor(PIXEL.Colors.Primary))
    self.Grip:SetHoverColor(PIXEL.OffsetColor(PIXEL.Colors.Primary, -15))
    self.Grip:SetClickColor(PIXEL.OffsetColor(PIXEL.Colors.Primary, 15))

    self.LastValue = self:GetValue()

    self.Grip.OnCursorMoved = function(pnl, x, y)
        if not pnl.Depressed then return end

        x, y = pnl:LocalToScreen(x, y)
        x = self:ScreenToLocal(x, y)

        self.Fraction = math.Clamp(x / self:GetWide(), 0, 1)

        self:OnValueChanged(self:GetValue(), self.LastValue == self:GetValue())
        self:InvalidateLayout()
        self.LastValue = self:GetValue()
    end

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 20)
    self.FillCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 10)
end

function PANEL:OnMousePressed()
    local w = self:GetWide()

    self.Fraction = math.Clamp(self:CursorPos() / w, 0, 1)
    self:OnValueChanged(self:GetValue(), self.LastValue == self:GetValue())
    self:InvalidateLayout()
end

function PANEL:GetValue()
    local val = Lerp(self.Fraction, self:GetMin(), self:GetMax())

    local decimals = self:GetDecimals() or 0
    local mult = 10 ^ decimals

    return math.Round(val * mult) / mult
end

function PANEL:SetValue(val)
    local min, max = self:GetMin(), self:GetMax()
    self.Fraction = math.Clamp((val - min) / (max - min), 0, 1)

    self:OnValueChanged(self:GetValue(), self.LastValue == self:GetValue())
    self:InvalidateLayout()
end

function PANEL:OnValueChanged(fraction, isSameValue) end

function PANEL:Paint(w, h)
    local rounding = h * .5
    local pad = h * 0.5
    local usableW = w - (pad * 2)

    local fillW = self.Fraction * usableW

    PIXEL.DrawRoundedBox(rounding, pad, h / 4, usableW, h / 2, self.BackgroundCol)
    PIXEL.DrawRoundedBox(rounding, pad, h / 4, fillW, h / 2, self.FillCol)
end

function PANEL:PerformLayout(w, h)
    local gripW = h
    self.Grip:SetSize(h, h)

    local pad = gripW * 0.5
    local usableW = w - (pad * 2)
    local x = pad + (self.Fraction * usableW)

    self.Grip:SetPos(x - (gripW * 0.5), 0)
end

vgui.Register("PIXEL.Slider", PANEL, "PIXEL.Button")