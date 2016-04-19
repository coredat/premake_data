
make = {}


function
make.get_proj_root()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end


function
make.create_solution(solution_data, project_defaults, ...)

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

    -- Fill in the default information.
    if not proj.kind                  then proj.kind = "C++"               end
    if not proj.lib_directories       then proj.lib_directories = {""}     end
    if not proj.linkoptions           then proj.linkoptions = {""}         end
    if not proj.links                 then proj.links = {""}               end
    if not proj.include_directories   then proj.include_directories = {""} end

    -- Generate the project data.
    project(proj.name)
    location(proj.location)
    language(proj.language)
    kind(proj.kind)

    -- Thie function takes a string that represents a field
    -- to search in the table. it will then append the premakes
    -- platform name to the end, and search for that field.
    function
    find_table_with_platform(proj, string)
      local result_table = {}
      local call_str = "result_table = proj." .. string .. "_" .. os.get()

      -- Need to watch this loadstring is depreated, but premake's version of lua is old.
      local chunk = loadstring(call_str)
      setfenv( chunk, { result_table = result_table, proj = proj } )
      chunk()

      -- This is new method, should premake's lua version change.
      --load(call_str, nil, nil, my_env)()
      -- local my_env = { table = table, proj = proj}

      return getfenv(chunk).result_table
    end

    -- Src files
    if proj.src_files then files(proj.src_files) end

    local platform_src = find_table_with_platform(proj, "src_files")
    if platform_src then files(platform_src) end

    -- Excludes
    if proj.src_excludes then excludes(proj.src_excludes) end

    local platform_exclude = find_table_with_platform(proj, "src_files_exclude")
    if platform_exclude then excludes(platform_exclude) end

    -- Include dirs
    if proj.inc_dirs then includedirs(proj.inc_dirs) end

    local platform_inc_dirs = find_table_with_platform(proj, "inc_dirs")
    if platform_inc_dirs then includedirs(platform_inc_dirs) end

    -- Library directories
    if proj.lib_dirs then libdirs(proj.lib_dirs) end

    local platform_lib_dirs = find_table_with_platform(proj, "lib_dirs")
    if platform_lib_dirs then libdirs(platform_lib_dirs) end

    -- Link options
    if proj.linkoptions then  linkoptions(proj.linkoptions) end

    local platform_link_options = find_table_with_platform(proj, "linkoptions")
    if platform_link_options then linkoptions(platform_link_options) end

    -- Links and Link dependencies
    if proj.links then links(proj.links) end

    -- If we have project dependencies then we need
    -- to check if that project specifies any links
    -- as dependencies.
    if proj.project_dependencies then

      -- Loop through each of the dependencies
      for i, dep in ipairs(proj.project_dependencies) do

        -- Loop through the projects we have been given.
        for j, other_proj in ipairs(arg) do

          -- If a match then check for links
          if dep == other_proj then
            if other_proj.link_dependencies then links(other_proj.link_dependencies) end

            local platform_dep_links = find_table_with_platform(other_proj, "link_dependencies")
            if platform_dep_links then links(platform_dep_links) end
          end
        end

      end

    end


    buildoptions(proj.buildoptions)
    buildoptions(project_defaults.buildoptions)

    -- Hardcoded
    configuration "Debug"
    defines { "DEBUG" }
    flags { "Symbols", "Unicode"}

    configuration "Release"
    defines { "NDEBUG" }
    flags { "Optimize", "Unicode" }
  end

end
