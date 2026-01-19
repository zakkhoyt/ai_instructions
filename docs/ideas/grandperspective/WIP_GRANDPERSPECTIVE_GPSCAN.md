




* [ ] Since we now have a script that will generate gpscan files (under `docs/ideas/grandperspective/references/disk_management`), let's start a grandperspective replacement
  * Again, read `scripts/patches/1.1.1/notes/grandperspective/**/*` for significant history/notes. 
  * The goal here is to write another script that will act like grandperspective
    * This version will generate non-interactive images. Interactive can wait
      * rendered images (png, jpg). 
      * vector graphic support would be highly valued (svg, pdf)
    * inputs
      * accept an optional gpscan file (via args): `--report <gpscan_file>`
      * accept an optional dir to scan (call investigate_disk_fast.zsh) then use it's generatred file
        * maybe need to update `investigate_disk_fast.zsh` to write the output files to stdout/stderr (via arg?)
      * accept args to define graph type: `--graph <type>` defaulting to `tree-map`
        * Not sure what other graph types are mentioned in the ntoes, this is the main I want though
      * args for treemap specifics
        * since this is noninteractive we will want some info in each box
          * file name in boxes. EX: `temp/` `README.md` : `--treemap-box-file true`. default true
            * since the boxes represent files only, dirs are groups of boxes. Not sure how to represent this on a rendered image
          * render size in boxes. EX: `10.1 MB` `1.1 GB` : `--treemap-box-disk true`. default false
        * box color: `--treemap-box-color <style>`. EX: file-extentsion, parent-dir, etc..
      * render type: `--output <path>`. NOTE: infer render type from file extension. EX: *.png -> png, *.svg -> svg, etc...
      * image-size: some canvas size to fit the graph into: EX: 640x480, 1080x1920, etc... Default: 2k
