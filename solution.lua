#!lua

package.path = './?.lua;' .. package.path
dofile("./premake_data.lua")


-- Solution data? Should this contain the the project names?
solution_data = {

  name = "RepublicOfAlmost",

}

-- Defaults will be based on platform in the future.
-- Currently only supports buildoptions.
project_defaults = {

  buildoptions_macosx = {
    "-std=c++14",
    "-stdlib=libc++",
  },

  buildoptions_windows = {
    "/IGNORE:C4577",
  },

  flags = {
    "EnableSSE2",
    "ExtraWarnings",
    "FloatFast",
    "NoExceptions", -- deprecated premake5
    "NoRTTI", -- deprecated premake5
  },

  defines = {
    "MATH_USE_SIMD",
  },

  defines_windows = {
    "_HAS_EXCEPTIONS=0",
    "_CRT_NO_WARNINGS",
  },

  exceptions = false,
  rtti = false,
}


projects = {}
matches = os.matchdirs("../*")

for i, proj in ipairs(matches) do
  if(os.isfile(proj .. "/project.lua")) then
    print("Found: " .. proj .. "/project.lua")
    dofile(proj .. "/project.lua")
  end
end

-- Generates the premake code calls.
make.create_solution(
  solution_data,
  project_defaults,
  projects
)
