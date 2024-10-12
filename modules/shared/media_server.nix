{ pkgs }:
with pkgs; [

  # Media management packages
  sonarr # tv shows
  radarr # films
  # lidarr # music # TODO fix for AARCH
  # jackett # search indices
  prowlarr # indices, similar to jackett
  # libtool # Necessary to build jellyseer
  # jellyseerr # centralised content search
  # audiobookshelf # audiobooks
  # kavita # books
  pkgs.unstable.bazarr
]
