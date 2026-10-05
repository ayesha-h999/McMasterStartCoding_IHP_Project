# GitHub Codespaces IHP Template

This is an IHP template configured to run on GitHub Codespaces and [VSCode Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers). 

## Getting Started

### For New Projects
1. Create a repository from this template.
2. Run it in Codespaces / Devcontainers.
3. Once the Codespace launches, run `./install-nix.sh` to install the necessary things. This may take 10+ minutes the first time.
4. Once it fully finishes, close the running terminal and open a new one.  This will download a few more things to actually run the server.
5. Run `devenv up` to start the server.
6. Once the server starts, find the 8000 port on the ports screen and click the globe icon to open it.
7. Have fun with IHP! :)

_**NOTE:**_ Codespaces storage use is calculated hourly and is measured in gb-months. If your Codespace is bigger than 15gb (20gb if you get GitHub Pro 
through the Student Developer Pack), you will have to delete it when you're not actively coding, or else you will run out of gb-months of 
storage before the end of the month. **_Make sure you commit your code first if you delete the Codespace!!_** You can always recreate it, though you'll 
have to wait for the things to download again, unfortunately. Most times it should only take up about 17-19gb which won't exhaust the 20gb limit, but would exhaust 
the 15gb limit. **_Be careful not to have more than one Codespace in your account at once as this will eat up your storage too!_**

**Update:** It looks like the new IHP version has 21gb of dependencies. So we'll have to find another solution so we don't always have to delete the
Codespaces.

### An existing IHP project
To add support to an existing IHP project, simply copy the [devcontainer configuration](.devcontainer/devcontainer.json) to your project, 
placing it in `.devcontainer/devcontainer.json`. Then follow the above instructions.

## Note
Sometimes GitHub updates Codespaces or their base container image, which may break this devcontainer configuration. Please check here regularly for 
updates and post an issue if you have problems running a Codespace / Devcontainer. To update, simply copy the new `devcontainer.json` 
to your project, and then rebuild the container or recreate your Codespace / Devcontainer entirely.

See also [ihp.digitallyinduced.com](https://ihp.digitallyinduced.com/)
