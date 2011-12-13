-- luvit-getopt -- by pancake<nopcode.org> --
local string = require ("string")

local Getopt = {}
Getopt.tab = {}
Getopt._alias = {}
Getopt._describe = {}
Getopt._check = nil
Getopt._usage = nil
Getopt._demand = nil

function Getopt.usage (self, str)
	if #str == 0 then
		self._usage = nil
	else
		self._usage = str
	end
	return self
end


function Getopt.showUsage(self)
	print (self._usage)
	if self._describe then
		print ("Options:")
		local width = 12
		for k,v in pairs (self._describe) do
			local line = "  -"..k
			for i,j in pairs(self._alias) do
				if k == i then
					line = line ..", --"..j
				end
			end
			local w = width - #line
			line = line..string.rep (" ", w)
			-- TODO align columns
			line = line .."   "..v
			for i,j in pairs(self._demand) do
				if k == j then
					line = line .."  [required]"
				end
			end
			print(line)
		end
	end
end

-- getopt, POSIX style command line argument parser
-- param arg contains the command line arguments in a standard table.
-- param options is a string with the letters that expect string values.
-- returns a table where associated keys are true, nil, or a string value.
-- The following example styles are supported
--   -a one  ==> opts["a"]=="one"
--   -bone   ==> opts["b"]=="one"
--   -c      ==> opts["c"]==true
--   --no-c  ==> opts["c"]=false
--   --c=one ==> opts["c"]=="one"
--   -cdaone ==> opts["c"]==true opts["d"]==true opts["a"]=="one"
-- note POSIX demands the parser ends at the first non option
--      this behavior isn't implemented.
function Getopt.parse (self, arg, options)
	if #arg == 0 and self._usage then
		self:showUsage()
		process.exit(1)
	end

	local ind = 0
	local skip = 0
	local tab = self.tab
	tab["_"] = {}
	tab["$0"] = arg[0]

	for k, v in ipairs(arg) do
		if skip>0 then
			skip = skip - 1
		else
			for a,b in pairs (self._alias) do
				if v == "--"..b then
					v = "-"..a
				end
			end
			if string.sub(v, 1, 2) == "--" then
				local bool
				local boolk = ""
				if string.sub (v, 2,5) == "-no-" then
					bool = false
					boolk = string.sub (v,6)
				else
					boolk = string.sub (v,3)
					bool = true
				end
				local x = string.find(v, "=", 1, true)
				if x then tab[string.sub(v, 3, x-1)] = string.sub(v, x+1)
				else tab[boolk] = bool
				end
			elseif string.sub(v, 1, 1) == "-" then
				local y = 2
				local l = string.len(v)
				local jopt
				while (y <= l) do
					jopt = string.sub(v, y, y)
					local off = string.find(options, jopt, 1, true)
					if off then
						local ch = string.sub (options, off+1, off+1)
						if y < l then
							tab[jopt] = string.sub(v, y+1)
							y = l
						else
						if ch == ":" then
							skip = 1
							tab[jopt] = arg[k + 1]
							if not tab[jopt] then
								p ("Missing argument for "..v)
								process.exit (1)
							end
						else
							tab[jopt] = true
						end
						end
					else
						tab[jopt] = true
					end
					y = y + 1
				end
			else
				tab["_"][ind] = v
				ind = ind+1
			end
		end
	end
	if self._demand then
		for k,v in pairs(self._demand) do
			if not tab[v] then
				print ("Missing required argument -"..v)
				process.exit (1)
			end
		end
	end
	if self._check and not self._check(tab) then
		print ("luvit-getop: check condition failed")
		process.exit (1)
	end
	return tab
end

function Getopt.argv(self, opt)
	return self:parse (process.argv, opt)
end

function Getopt.demand(self, dem)
	self._demand = dem
	return self
end

function Getopt.default(self, k, v)
	if v then
		self.tab[k] = v
	else
		for i,j in pairs(k) do
			self.tab[i] = j
		end
	end
	return self
end

function Getopt.alias(self, k, v)
	if type (k) == "table" then
		for i,j in pairs(k) do
			self._alias[i] = j
		end
	else
		self._alias[k] = v
	end
	return self
end

function Getopt.check(self, fn)
	self._check = fn
	return self
end

function Getopt.describe(self, k,v)
	if type (k) == "table" then
		for i,j in pairs(k) do
			self._describe[i] = j
		end
	else
		self._describe[k] = v
	end
	return self
end

return Getopt
