## To build from source you need / should have:

- nodemon (for building on file change, not needed)
- luabundler (npm install -g luabundler)

*These arent dev dependencies since i was lazy lmao*

## naming convention

- PascalCase for roblox apis (services, etc), classes / functions in tables that use roblox apis (Teleporter class for example), UI elements, requires / imports, constants, most tables
- camelCase for variables not related to roblox, standalone functions, functions in tables that dont use roblox apis
- lowercase for exploit apis