luvit-getopt
============
This module implements an easy to use getopt library for luvit.

It is inspired in Node's optimist

Example
-------
	#!/usr/bin/env luvit

	local opt = require ("getopt")
		:usage ("Usage: ./test.lua [-hk] [-a arg] [-b arg]")
		:default ("a", "patata")
		:describe ("a", "set an argument to this flag")
		:describe ("b", "set b flag")
		:describe ("k", "kakaka")
		:describe ("h", "showHelp")
		:alias ( {["a"]="arg"})
		:demand ({"a", "k"})
		:check(function(opt)
			return opt.b
		end)
		:argv ("ha:b:k")
	p(opt)
