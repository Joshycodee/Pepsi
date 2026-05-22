local Library =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))() -- This line of code has errors because it is not supported by Selene.

local Login = {
	currentuser = nil,
	currentpass = nil,
}

local Version = "Premium"
local Settings = {
	KeybindMenuVisible = false,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
	Title = "Pepsi",
	Footer = Version,
	Icon = 4427304036,
	NotifySide = "Right",
	BackgroundImage = "rbxasset://textures/loading/darkLoadingTexture.png",
	GlobalSearch = true,
	SidebarCompacted = true,
})

Library:Notify({
	Title = "Pepsi",
	Description = "Welcome To Pepsi, " .. LocalPlayer.Name .. "!",
	Icon = "info",
	Time = 4,
})

local KeyPrompt = Window:AddDialog("KeyPrompt", {
	Title = "Sign In",
	Icon = "key-round",
	Description = "Sign into your account you created with the discord bot.",
	AutoDismiss = false,
	OutsideClickDismiss = true,
	FooterButtons = {
		Enter = {
			Title = "Enter",
			Variant = "Primary",
			WaitTime = 5,
			Order = 4,
			Callback = function()
				print(Login.currentuser, Login.currentpass)
			end,
		},
		Unload = {
			Title = "Unload",
			Variant = "Secondary",
			WaitTime = 5,
			Order = 4,
			Callback = function()
				Library:Unload()
			end,
		},
	},
})

KeyPrompt:AddInput("Username", {
	Text = "Username:",
	Callback = function(value)
		Login.currentuser = value
	end,
})

KeyPrompt:AddInput("Password", {
	Text = "Password:",
	AllowEmpty = false,
	Callback = function(value)
		Login.currentpass = value
	end,
})

Library.KeybindFrame.Visible = Settings.KeybindMenuVisible

Library.ToggleKeybind = "RightShift"

local Tab = Window:AddTab("Settings", "cog")

local SettingsTab = Tab:AddLeftGroupbox("Settings", "wrench")

local MenuBind = SettingsTab:AddToggle("MenuBind", {
	Text = "Menu Bind",
	Default = false,
})

SettingsTab:AddDivider("Main")

SettingsTab:AddButton({
	Text = "Unload",
	Func = function()
		Library:Unload()
	end,
}):AddButton({
	Text = "Restart",
	Func = function()
		Library:Unload() 
		task.spawn(function()
			task.wait(0.3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Joshycodee/Pepsi/refs/heads/main/Games/Global/script.lua"))()
		end)
	end,
})

MenuBind:AddKeyPicker("Toggle", {
	Default = "Insert",
	Text = "Menu Toggle",
	Mode = "Toggle",
	Callback = function()
		Window:Toggle()
	end,
})
