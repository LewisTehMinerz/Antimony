<p align="center">
<img src="/antimony.png">
<h1>Antimony</h1>
An advanced, pluggable, open-source administration script for ROBLOX.
</p>

## Plugs
Antimony's key feature is the plugs system. It allows developers to write commands for Antimony with minimal effort. All you do is create a ModuleScript and put it in the `Plugs` folder. A very basic plug looks like this:

```lua
local Example = {}

function Example:register(antimony)
end

return Example
```

All this does is define the `Example:register` method. Antimony calls this when loading the plug and should be where you register commands and permissions. It passes itself to this method, which means you can access all Antimony methods and properties (such as `Antimony.config` or `Antimony:log`).

## Permissions System
Leading on from the previous topic, Antimony features a permissions and group system. Plugs define permissions which can then be used with commands or whatever they need. Groups can be modified to contain these permissions either through modifying the DataStore directly, or by using a graphical groups editor.

## Contributing
The first thing you should do before doing anything with this repository is install [Rojo](https://github.com/LPGhatguy/rojo). Antimony uses this tool to compile the scripts into ROBLOX model files for distribution (you can see one in the root of the repository called Antimony.rbxmx). Afterwards, you can clone the repository. We recommend running the `applyGitHook.js` script to install a git hook which will automatically rebuild the model file for you before your commit is sent. This makes sure that the other developers working on the project can easily pull down the project again and import the model file into Studio to test your changes, which you should be doing anyway. When committing, if you haven't installed the git hook, make sure you rebuild the model file by running `rojo build -o Antimony.rbxmx`. Please take note of the last `x` on the file extension. This is important because it generates an XML version of the model instead of a binary version, which means that changing scripts and recompiling the model file is quicker and doesn't require developers to re-get the entire model file over and over.

When creating a release build of Antimony, make sure to run `rojo build -o Antimony.rbxm` which will compile the scripts into a binary ROBLOX model file. The XML version of the model file (Antimony.rbxmx) is not appropriate for distribution due to its large size.