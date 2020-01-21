ESX = nil
local connectedPlayers = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('b15d800c-e240-492e-ae8e-7b526e2d2ca9', function(source, cb)
	cb(connectedPlayers)
end)

AddEventHandler('a38b3249-c9ed-48a2-a336-fd5bbdbfa0e5', function(playerId, job, lastJob)
	connectedPlayers[playerId].job = job.name

	TriggerClientEvent('9ac610e7-417a-4b4f-ad3e-f0a7bf47ae49', -1, connectedPlayers)
end)

AddEventHandler('ab8d2fd8-bf65-40f2-8fde-b8b075af45e1', function(playerId, xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler('98c17b40-e1b2-4f51-9ea1-ec7c5f89436a', function(playerId)
	connectedPlayers[playerId] = nil

	TriggerClientEvent('9ac610e7-417a-4b4f-ad3e-f0a7bf47ae49', -1, connectedPlayers)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		UpdatePing()
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			AddPlayersToScoreboard()
		end)
	end
end)

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.source

	connectedPlayers[playerId] = {}
	connectedPlayers[playerId].ping = GetPlayerPing(playerId)
	connectedPlayers[playerId].name = Sanitize(xPlayer.getName())
	connectedPlayers[playerId].job = xPlayer.job.name

	if update then
		TriggerClientEvent('9ac610e7-417a-4b4f-ad3e-f0a7bf47ae49', -1, connectedPlayers)
	end

	if xPlayer.player.getGroup() == 'user' then
		Citizen.CreateThread(function()
			Citizen.Wait(3000)
			TriggerClientEvent('a445d551-4d6b-4c1d-930b-62a74fddd3d9', playerId, false)
		end)
	end
end

function AddPlayersToScoreboard()
	local players = ESX.GetPlayers()

	for i=1, #players, 1 do
		local xPlayer = ESX.GetPlayerFromId(players[i])
		AddPlayerToScoreboard(xPlayer, false)
	end

	TriggerClientEvent('9ac610e7-417a-4b4f-ad3e-f0a7bf47ae49', -1, connectedPlayers)
end

function UpdatePing()
	for k,v in pairs(connectedPlayers) do
		v.ping = GetPlayerPing(k)
	end

	TriggerClientEvent('6a771061-9fbf-4575-a8d6-c003bbb0941c', -1, connectedPlayers)
end

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end

Citizen.CreateThread(function()
	local uptimeMinute, uptimeHour, uptime = 0, 0, ''

	while true do
		Citizen.Wait(1000 * 60) -- every minute
		uptimeMinute = uptimeMinute + 1

		if uptimeMinute == 60 then
			uptimeMinute = 0
			uptimeHour = uptimeHour + 1
		end

		uptime = string.format("%02du %02dm", uptimeHour, uptimeMinute)
		SetConvarServerInfo('Draaitijd', uptime)


		TriggerClientEvent('3c60d216-83fb-4e30-9487-853f9e4a5919', -1, uptime)
		TriggerEvent('6b27c472-d41f-4a72-b5e0-196c8054d238', uptime)
	end
end)