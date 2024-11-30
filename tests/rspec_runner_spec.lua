local stub = require("luassert.stub")

describe("runner", function()
	it("can be required", function()
		local runner = require("rspec-runner")
		assert.is_not_nil(runner)
	end)
end)

describe("find_test_file", function()
	describe("when the file does not exist", function()
		stub(vim.fn, "filereadable").returns(0)

		it("returns nil", function()
			local runner = require("rspec-runner")
			local test_file = runner._find_test_file("/Users/me/projects/foo/app/models/user.rb")
			assert.is_nil(test_file)
		end)
	end)

	describe("when the file exists", function()
		stub(vim.fn, "filereadable").returns(1)

		describe("when the file is already a spec file", function()
			it("returns the file", function()
				local runner = require("rspec-runner")
				local test_file = runner._find_test_file("/Users/me/projects/foo/spec/models/user_spec.rb")
				assert.are.same("/Users/me/projects/foo/spec/models/user_spec.rb", test_file)
			end)
		end)

		describe("when the file is a model", function()
			it("replaces correctly the spec file", function()
				local runner = require("rspec-runner")
				local test_file = runner._find_test_file("/Users/me/projects/foo/app/models/user.rb")
				assert.are.same("/Users/me/projects/foo/spec/models/user_spec.rb", test_file)
			end)
		end)

		describe("when the file is a controller", function()
			it("replaces correctly the spec file", function()
				local runner = require("rspec-runner")
				local test_file = runner._find_test_file("/Users/me/projects/foo/app/controllers/users_controller.rb")
				assert.are.same("/Users/me/projects/foo/spec/controllers/users_controller_spec.rb", test_file)
			end)
		end)

		describe("when the file is in an engine", function()
			it("replaces correctly the spec file", function()
				local runner = require("rspec-runner")
				local test_file = runner._find_test_file(
					"/Users/me/projects/foo/engines/my_engine/app/controllers/users_controller.rb"
				)
				assert.are.same(
					"/Users/me/projects/foo/engines/my_engine/spec/controllers/users_controller_spec.rb",
					test_file
				)
			end)
		end)
	end)
end)
