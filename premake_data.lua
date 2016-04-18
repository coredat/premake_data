
make = {}



function
make.get_proj_root()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end


function
make.create_solution(solution_data, ...)

  -- Create the solution for the project.
  print("Creating Solution")

  solution("VortexApplication")
  location("./")

  configurations(
    "Debug",
    "Release"
  )

  -- Create the projects
  for i,proj in ipairs(arg) do

    -- Fill in missing information
    if not proj.kind                  then proj.kind = "C++"               end
    if not proj.lib_directories       then proj.lib_directories = {""}     end
    if not proj.linkoptions           then proj.linkoptions = {""}         end
    if not proj.links                 then proj.links = {""}               end
    if not proj.include_directories   then proj.include_directories = {""} end

    -- Generate the project data.
    print("Creating Project: " .. proj.name)

    project(proj.name)
    location(proj.location)
    language(proj.language)
    kind(proj.kind)
    files(proj.src_files)
    includedirs(proj.include_directories)
    libdirs(proj.lib_directories)
    linkoptions(proj.linkoptions)
    links(proj.links)
    buildoptions(proj.buildoptions)

    -- Hardcoded
    configuration "Debug"
    defines { "DEBUG" }
    flags { "Symbols", "Unicode"}

    configuration "Release"
    defines { "NDEBUG" }
    flags { "Optimize", "Unicode" }
  end

end
