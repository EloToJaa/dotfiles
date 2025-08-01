{
  lib,
  config,
  ...
}:
with lib; let
  defaultApps = {
    browser = ["zen-beta.desktop"];
    text = ["org.gnome.TextEditor.desktop"];
    image = ["com.interversehq.qView.desktop"];
    audio = ["mpv.desktop"];
    video = ["mpv.desktop"];
    directory = ["nemo.desktop"];
    office = ["libreoffice.desktop"];
    pdf = ["org.gnome.Evince.desktop"];
    terminal = ["ghostty.desktop"];
    archive = ["org.gnome.FileRoller.desktop"];
    discord = ["discord.desktop"];
  };

  removedApps = {
    image = [
      "gimp.desktop"
      "swappy.desktop"
      "chromium-browser.desktop"
    ];
    video = ["umpv.desktop"];
    browser = ["chromium-browser.desktop"];
  };

  mimeMap = {
    text = ["text/plain"];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = ["inode/directory"];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/xhtml+xml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
    ];
    pdf = ["application/pdf"];
    terminal = ["terminal"];
    archive = [
      "application/zip"
      "application/rar"
      "application/7z"
      "application/*tar"
    ];
    discord = ["x-scheme-handler/discord"];
  };

  associations = with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );

  removedAssociations = with lists; let
    generateRemoved = category: let
      mimeTypeList = mimeMap."${category}" or []; # Handle missing categories
      removeList = removedApps."${category}" or []; # Handle missing categories
    in
      map (mimeType: attrsets.nameValuePair mimeType removeList) mimeTypeList;

    allRemoved = flatten (mapAttrsToList (cat: val: generateRemoved cat) removedApps);
  in
    listToAttrs allRemoved;
in {
  xdg = {
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      associations.added = associations;
      associations.removed = removedAssociations;
      defaultApplications = associations;
    };
  };

  home.sessionVariables = {
    # prevent wine from creating file associations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
  };
}
