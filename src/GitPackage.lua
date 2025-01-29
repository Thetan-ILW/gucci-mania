local class = require("class")
local env = require("env")
local files = require("src.files")

---@class GitPackage
---@operator call: GitPackage
local GitPackage = class()

---@param url string
---@param id string
function GitPackage:new(url, id)
	assert(url and id)
	assert(id ~= "" and url ~= "")
	self.url = url
	self.id = id
	self.path = env.gitDirectory .. "/" .. id
end

return GitPackage
