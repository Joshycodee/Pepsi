local Library =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local localPlayer = players.LocalPlayer

local workerUrl = "https://pepsi.rbx-axiom.workers.dev"
local version = "Premium"

local paths = {
	folder = "Pepsi",
	settingsFolder = "Pepsi/Settings",
	loginFile = "Pepsi/Login.txt",
	settingsFile = "Pepsi/Settings/settings.json",
}

local login = {
	username = nil,
	password = nil,
}

local settings = {
	keybindMenuVisible = false,
	menuBind = nil,
}

local options = Library.Options

local function setupFolders()
	if not isfolder(paths.folder) then
		makefolder(paths.folder)
	end
	if not isfolder(paths.settingsFolder) then
		makefolder(paths.settingsFolder)
	end
end

local function saveCredentials(username, password)
	writefile(paths.loginFile, httpService:JSONEncode({ username = username, password = password }))
end

local function loadCredentials()
	if isfile(paths.loginFile) then
		local ok, data = pcall(httpService.JSONDecode, httpService, readfile(paths.loginFile))
		if ok and data and data.username and data.password then
			return data.username, data.password
		end
	end
	return nil, nil
end

local function wipeCredentials()
	if isfile(paths.loginFile) then
		writefile(paths.loginFile, "")
	end
end

local function saveSettings()
	writefile(paths.settingsFile, httpService:JSONEncode(settings))
end

local function loadSettings()
	if isfile(paths.settingsFile) then
		local ok, data = pcall(httpService.JSONDecode, httpService, readfile(paths.settingsFile))
		if ok and data then
			for key, value in pairs(data) do
				settings[key] = value
			end
		end
	end
end

loadSettings()

local window = Library:CreateWindow({
	Title = "Pepsi",
	Footer = version,
	Icon = 4427304036,
	NotifySide = "Right",
	BackgroundImage = "rbxasset://textures/loading/darkLoadingTexture.png",
	GlobalSearch = true,
	SidebarCompacted = true,
})

local tab = window:AddTab("Settings", "cog")
local settingsTab = tab:AddLeftGroupbox("Settings", "wrench")

local menuBind = settingsTab:AddLabel("Menu Bind")

local menubind = menuBind:AddKeyPicker("menubind", {
	Default = settings.menuBind,
	Text = "Menu Toggle",
	Mode = "Toggle",
	Callback = function()
		window:Toggle()
	end,
})

options.menubind:OnChanged(function()
	local bind = options.menubind.Value

	settings.menuBind = bind
	saveSettings()
end)

settingsTab:AddDivider("Main")

settingsTab
	:AddButton({
		Text = "Unload",
		Func = function()
			Library:Unload()
		end,
	})
	:AddButton({
		Text = "Restart",
		Func = function()
			Library:Unload()
			task.spawn(function()
				task.wait(0.3)
				loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Joshycodee/Pepsi/refs/heads/main/Games/Global/script.lua"
					)
				)()
			end)
		end,
	})

local function onLoginSuccess(username, hwid)
	local accountTab = tab:AddRightGroupbox("Account", "user")
	local userId = localPlayer.UserId
	accountTab:AddImage("Avatar", {
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150",
		Height = 80,
	})

	accountTab:AddLabel("Username: " .. username)
	accountTab:AddDivider("Logout")
	accountTab:AddButton({
		Text = "Logout",
		Risky = true,
		Func = function()
			wipeCredentials()
			Library:Unload()
			task.spawn(function()
				task.wait(0.3)
				loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Joshycodee/Pepsi/refs/heads/main/Games/Global/script.lua"
					)
				)()
			end)
		end,
	})
end

local function attemptLogin(username, password, silent)
	local hwid = gethwid()

	local ok, response = pcall(function()
		return request({
			Url = workerUrl .. "/login",
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = httpService:JSONEncode({ username = username, password = password, hwid = hwid }),
		})
	end)

	if not ok then
		if not silent then
			Library:Notify({ Title = "Error", Description = "Failed to reach the server.", Icon = "x", Time = 4 })
		end
		return false
	end

	local data = httpService:JSONDecode(response.Body)

	if response.StatusCode == 200 then
		saveCredentials(username, password)
		onLoginSuccess(username, hwid)
		return true
	else
		if not silent then
			Library:Notify({ Title = "Error", Description = data.error or "Login failed.", Icon = "x", Time = 4 })
		end
		return false
	end
end

setupFolders()
loadSettings()

Library:Notify({
	Title = "Pepsi",
	Description = "Welcome To Pepsi, " .. localPlayer.Name .. "!",
	Icon = "info",
	Time = 4,
})

Library.KeybindFrame.Visible = settings.keybindMenuVisible

local keyPrompt

keyPrompt = window:AddDialog("KeyPrompt", {
	Title = "Sign In",
	Icon = "key-round",
	Description = "Sign into your account you created with the discord bot.",
	AutoDismiss = false,
	OutsideClickDismiss = false,
	FooterButtons = {
		Enter = {
			Title = "Enter",
			Variant = "Primary",
			WaitTime = 5,
			Order = 4,
			Callback = function()
				local username = login.username
				local password = login.password

				if not username or not password then
					Library:Notify({
						Title = "Error",
						Description = "Please enter your username and password.",
						Icon = "x",
						Time = 4,
					})
					return
				end

				local success = attemptLogin(username, password, false)

				if success then
					Library:Notify({
						Title = "Success",
						Description = "Welcome back, " .. username .. "!",
						Icon = "check",
						Time = 4,
					})
					keyPrompt:Dismiss()
				end
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

keyPrompt:AddInput("Username", {
	Text = "Username:",
	Callback = function(value)
		login.username = value
	end,
})

keyPrompt:AddInput("Password", {
	Text = "Password:",
	AllowEmpty = false,
	Callback = function(value)
		login.password = value
	end,
})

local savedUsername, savedPassword = loadCredentials()

if savedUsername and savedPassword then
	Library:Notify({ Title = "Pepsi", Description = "Logging you in automatically...", Icon = "info", Time = 4 })

	task.spawn(function()
		local success = attemptLogin(savedUsername, savedPassword, true)

		if success then
			Library:Notify({
				Title = "Success",
				Description = "Welcome back, " .. savedUsername .. "!",
				Icon = "check",
				Time = 4,
			})
			keyPrompt:Dismiss()
		else
			wipeCredentials()
			Library:Notify({
				Title = "Error",
				Description = "Auto login failed. Please log in manually.",
				Icon = "x",
				Time = 4,
			})
		end
	end)
end
