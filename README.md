# Setup qtcreator

One shot script to setup qtcreator to crosscompile using yocto sdk.

It sets up the C and C++ cross toolchains, the proper qt lib and it will add a kit that uses them. You can add an optional jpeg file that will be the icon displayed in qtcreator for your sdk (by default you will get a penguin).

## How to use

```bash
source <yocto_sdk_environment>
./setup-qtcreator.sh <sdktool_path> <sdk_id> [<optional_icon_file>]
```

where:
 - `<yocto_sdk_environment>` is the yocto environment setup script, like `/opt/poky/1.8.1/environment-setup-cortexa9hf-vfp-neon-poky-linux-gnueabi`
 - `<sdktool_path>` qtcreator's sdktool path, e.g. `~/Qt/Tools/QtCreator/libexec/qtcreator/sdktool`
 - `<sdk_id>` the name of your new sdk, e.g. `awesomeboard` (notice that if you want to update an existing sdk you must provide the same id)
 - `<optional_icon_file>` your jpeg icon filename, e.g.`~/Images/board-photo.jpg`